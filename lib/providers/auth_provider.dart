import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;
  bool _initialized = false;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeGoogleSignIn();
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> _initializeGoogleSignIn() async {
    _googleSignIn = GoogleSignIn.instance;
    await _googleSignIn.initialize(
      clientId: null, // Use platform config
    );
    _initialized = true;
  }

  Future<bool> signInWithGoogle() async {
    try {
      // Wait for initialization if needed
      if (!_initialized) {
        await _initializeGoogleSignIn();
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();

      if (googleUser == null) {
        // User canceled the sign-in
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get ID token
      final GoogleSignInAuthentication auth = googleUser.authentication;

      // Get access token using authorization client
      final authClient = googleUser.authorizationClient;
      final clientAuth = await authClient.authorizeScopes(['email']);

      if (clientAuth == null) {
        _errorMessage = 'Failed to get authentication tokens';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: clientAuth.accessToken,
        idToken: auth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await _auth.signInWithCredential(credential);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);

      _user = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
