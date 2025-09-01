import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isAdmin = false;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _initializeAuth() async {
    _user = _auth.currentUser;
    if (_user != null) {
      await _checkAdminStatus();
    }
    notifyListeners();
  }

  Future<void> _checkAdminStatus() async {
    if (_user?.email == 'testwtsm@gmail.com') {
      _isAdmin = true;
    } else {
      _isAdmin = false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAdmin', _isAdmin);
  }

  Future<String?> signUp(String email, String password) async {
    try {
      _setLoading(true);

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = credential.user;

      // Store user data in Firestore
      await _firestore.collection('users').doc(_user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': false,
      });

      await _checkAdminStatus();

      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'Registration failed';
    } catch (e) {
      _setLoading(false);
      return 'An unexpected error occurred';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _setLoading(true);

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = credential.user;
      await _checkAdminStatus();

      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'Login failed';
    } catch (e) {
      _setLoading(false);
      return 'An unexpected error occurred';
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);

      await _auth.signOut();
      _user = null;
      _isAdmin = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      // Handle signout error if needed
    }
  }
}
