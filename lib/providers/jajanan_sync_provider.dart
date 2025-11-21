import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/jajanan.dart';
import 'jajanan_provider.dart';

class JajananSyncProvider extends ChangeNotifier {
  final JajananProvider _localProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSyncing = false;
  String? _errorMessage;
  int _syncedCount = 0;
  int _totalItems = 0;

  bool get isSyncing => _isSyncing;
  String? get errorMessage => _errorMessage;
  int get syncedCount => _syncedCount;
  int get totalItems => _totalItems;

  JajananSyncProvider(this._localProvider) {
    _setupRealtimeSync();
  }

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _jajananCollection =>
      _firestore.collection('users').doc(_userId).collection('jajanan');

  void _setupRealtimeSync() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        // User logged in, setup Firestore listener
        _jajananCollection.snapshots().listen((snapshot) {
          for (var change in snapshot.docChanges) {
            final data = change.doc.data() as Map<String, dynamic>?;

            if (data == null) continue;

            if (change.type == DocumentChangeType.added ||
                change.type == DocumentChangeType.modified) {
              // Update local Hive
              final jajanan = Jajanan.fromMap(data);
              _localProvider.updateFromFirestore(jajanan);
            } else if (change.type == DocumentChangeType.removed) {
              // Delete from local Hive
              _localProvider.deleteFromFirestore(change.doc.id);
            }
          }
        });
      }
    });
  }

  Future<void> syncToFirestore(Jajanan jajanan) async {
    if (_userId == null) return;

    try {
      await _jajananCollection.doc(jajanan.id).set(jajanan.toMap());
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteFromFirestore(String id) async {
    if (_userId == null) return;

    try {
      await _jajananCollection.doc(id).delete();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> initialSync() async {
    if (_userId == null) {
      throw Exception('User belum login');
    }

    _isSyncing = true;
    _errorMessage = null;
    _syncedCount = 0;
    notifyListeners();

    try {
      // Upload local data to Firestore
      final localItems = _localProvider.allJajanan;
      _totalItems = localItems.length;
      notifyListeners();

      if (localItems.isEmpty) {
        debugPrint('Tidak ada produk untuk disinkronkan');
      } else {
        debugPrint('Menyinkronkan ${localItems.length} produk...');

        for (var jajanan in localItems) {
          try {
            await _jajananCollection.doc(jajanan.id).set(jajanan.toMap());
            _syncedCount++;
            debugPrint(
              'Synced ${_syncedCount}/${_totalItems}: ${jajanan.nama}',
            );
            notifyListeners();
          } catch (e) {
            debugPrint('Error syncing item ${jajanan.nama}: $e');
            // Continue with next item
          }
        }

        debugPrint('Sinkronisasi produk selesai: $_syncedCount/$_totalItems');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error sync jajanan: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> downloadFromFirestore() async {
    if (_userId == null) {
      throw Exception('User belum login');
    }

    _isSyncing = true;
    _errorMessage = null;
    _syncedCount = 0;
    notifyListeners();

    try {
      // Download data from Firestore
      final snapshot = await _jajananCollection.get();
      _totalItems = snapshot.docs.length;
      notifyListeners();

      if (snapshot.docs.isEmpty) {
        debugPrint('Tidak ada produk di cloud');
      } else {
        debugPrint('Mengunduh ${snapshot.docs.length} produk...');

        for (var doc in snapshot.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final jajanan = Jajanan.fromMap(data);
            await _localProvider.updateFromFirestore(jajanan);
            _syncedCount++;
            debugPrint(
              'Downloaded ${_syncedCount}/${_totalItems}: ${jajanan.nama}',
            );
            notifyListeners();
          } catch (e) {
            debugPrint('Error downloading item ${doc.id}: $e');
            // Continue with next item
          }
        }

        debugPrint('Download produk selesai: $_syncedCount/$_totalItems');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error download jajanan: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
