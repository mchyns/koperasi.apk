import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction.dart' as model;
import 'transaction_provider.dart';

class TransactionSyncProvider extends ChangeNotifier {
  final TransactionProvider _localProvider;
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

  TransactionSyncProvider(this._localProvider) {
    _setupRealtimeSync();
  }

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _transactionCollection =>
      _firestore.collection('users').doc(_userId).collection('transactions');

  void _setupRealtimeSync() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        // User logged in, setup Firestore listener
        _transactionCollection.snapshots().listen((snapshot) {
          for (var change in snapshot.docChanges) {
            final data = change.doc.data() as Map<String, dynamic>?;

            if (data == null) continue;

            if (change.type == DocumentChangeType.added ||
                change.type == DocumentChangeType.modified) {
              // Update local Hive
              final transaction = model.Transaction.fromMap(data);
              _localProvider.updateFromFirestore(transaction);
            } else if (change.type == DocumentChangeType.removed) {
              // Delete from local Hive
              _localProvider.deleteFromFirestore(change.doc.id);
            }
          }
        });
      }
    });
  }

  Future<void> syncToFirestore(model.Transaction transaction) async {
    if (_userId == null) return;

    try {
      await _transactionCollection.doc(transaction.id).set(transaction.toMap());
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteFromFirestore(String id) async {
    if (_userId == null) return;

    try {
      await _transactionCollection.doc(id).delete();
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
      final localTransactions = _localProvider.allTransactions;
      _totalItems = localTransactions.length;
      notifyListeners();

      if (localTransactions.isEmpty) {
        debugPrint('Tidak ada transaksi untuk disinkronkan');
      } else {
        debugPrint('Menyinkronkan ${localTransactions.length} transaksi...');

        for (var transaction in localTransactions) {
          try {
            await _transactionCollection
                .doc(transaction.id)
                .set(transaction.toMap());
            _syncedCount++;
            debugPrint('Synced ${_syncedCount}/${_totalItems} transaksi');
            notifyListeners();
          } catch (e) {
            debugPrint('Error syncing transaction ${transaction.id}: $e');
            // Continue with next item
          }
        }

        debugPrint(
          'Sinkronisasi transaksi selesai: $_syncedCount/$_totalItems',
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error sync transaksi: $e');
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
      final snapshot = await _transactionCollection.get();
      _totalItems = snapshot.docs.length;
      notifyListeners();

      if (snapshot.docs.isEmpty) {
        debugPrint('Tidak ada transaksi di cloud');
      } else {
        debugPrint('Mengunduh ${snapshot.docs.length} transaksi...');

        for (var doc in snapshot.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final transaction = model.Transaction.fromMap(data);
            await _localProvider.updateFromFirestore(transaction);
            _syncedCount++;
            debugPrint('Downloaded ${_syncedCount}/${_totalItems} transaksi');
            notifyListeners();
          } catch (e) {
            debugPrint('Error downloading transaction ${doc.id}: $e');
            // Continue with next item
          }
        }

        debugPrint('Download transaksi selesai: $_syncedCount/$_totalItems');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error download transaksi: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
