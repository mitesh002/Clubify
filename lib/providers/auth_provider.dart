import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // void _onAuthStateChanged(User? firebaseUser) async {
  //   if (firebaseUser != null) {
  //     await _loadUserData(firebaseUser.uid);
  //   } else {
  //     _user = null;
  //     notifyListeners();
  //   }
  // }

  // Future<void> _loadUserData(String uid) async {
  //   try {
  //     final doc = await _firestore.collection('users').doc(uid).get();
  //     if (doc.exists) {
  //       _user = UserModel.fromMap(doc.data()!, doc.id);
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     _error = 'Failed to load user data: $e';
  //     notifyListeners();
  //   }
  // }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String course,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Mock authentication - simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Create mock user
      final userModel = UserModel(
        id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        course: course,
        role: role,
        points: 0,
      );

      _user = userModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Mock authentication - simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Create mock user for demo
      final userModel = UserModel(
        id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Demo User',
        email: email,
        course: 'Computer Science',
        role: 'student',
        points: 50,
      );

      _user = userModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // Mock sign out
      await Future.delayed(const Duration(milliseconds: 500));
      _user = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to sign out: $e';
      notifyListeners();
    }
  }

  Future<void> updateUserPoints(int points) async {
    if (_user != null) {
      try {
        // Mock update
        await Future.delayed(const Duration(milliseconds: 500));
        _user = _user!.copyWith(points: points);
        notifyListeners();
      } catch (e) {
        _error = 'Failed to update points: $e';
        notifyListeners();
      }
    }
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
