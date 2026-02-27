import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String _userName = '';
  String _userEmail = '';
  String _profileUrl = '';
  bool _isLoading = false;

  User? get user => _user;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get profileUrl => _profileUrl;
  String get uid => _user?.uid ?? '';
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authStateChanges();
  }

  void _authStateChanges() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _fetchUserData();
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserData() async {
    if (_user == null) return;
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _userName = data['name'] ?? '';
        _userEmail = data['email'] ?? _user!.email ?? '';
        _profileUrl = data['profileUrl'] ?? '';
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user document if not exists
        await _createUserIfNotExists(credential.user!);
        await _fetchUserData();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _createUserIfNotExists(User user) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': 'User Name',
        'email': user.email,
        'profileUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    _userName = '';
    _userEmail = '';
    _profileUrl = '';
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? profileUrl}) async {
    if (_user == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (profileUrl != null) updates['profileUrl'] = profileUrl;

    if (updates.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update(updates);
      await _fetchUserData();
    }
  }
}

