import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_model.dart';

// Mock Auth State Provider (replaces Firebase auth)
final authStateProvider = StreamProvider<MockUser?>((ref) {
  final authController = ref.watch(authControllerProvider);
  if (authController.isAuthenticated) {
    return Stream.value(MockUser(
      uid: authController.user!.id,
      email: authController.user!.email,
      displayName: authController.user!.name,
      role: authController.user!.role,
    ));
  }
  return Stream.value(null);
});

// Mock Current User Provider
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authController = ref.watch(authControllerProvider);
  if (authController.isAuthenticated) {
    return Stream.value(authController.user);
  }
  return Stream.value(null);
});

// Mock Auth Controller
final authControllerProvider =
    StateNotifierProvider<MockAuthController, MockAuthState>((ref) {
  return MockAuthController();
});

class MockUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String role;

  MockUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.role = 'student',
  });
}

class MockAuthController extends StateNotifier<MockAuthState> {
  MockAuthController() : super(const MockAuthState.initial());

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const MockAuthState.loading();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Create mock user
      final now = DateTime.now();
      final user = UserModel(
        id: 'mock_user_${now.millisecondsSinceEpoch}',
        name: _getNameFromEmail(email),
        email: email,
        role: email.contains('leader') ? 'club_leader' : 'student',
        course: email.contains('leader') ? 'Faculty' : 'Computer Science',
        points: email.contains('leader') ? 0 : 1250,
        createdAt: now,
        updatedAt: now,
      );

      state = MockAuthState.authenticated(user);
    } catch (e) {
      state = MockAuthState.error(e.toString());
    }
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String course,
    required String role,
  }) async {
    state = const MockAuthState.loading();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final now = DateTime.now();
      final user = UserModel(
        id: 'mock_user_${now.millisecondsSinceEpoch}',
        name: name,
        email: email,
        role: role,
        course: course,
        points: 0,
        createdAt: now,
        updatedAt: now,
      );

      state = MockAuthState.authenticated(user);
    } catch (e) {
      state = MockAuthState.error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = const MockAuthState.loading();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final now = DateTime.now();
      final user = UserModel(
        id: 'mock_google_user_${now.millisecondsSinceEpoch}',
        name: 'Demo Google User',
        email: 'demo@gmail.com',
        role: 'student',
        course: 'Computer Science',
        points: 500,
        createdAt: now,
        updatedAt: now,
      );

      state = MockAuthState.authenticated(user);
    } catch (e) {
      state = MockAuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    state = const MockAuthState.loading();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      state = const MockAuthState.unauthenticated();
    } catch (e) {
      state = MockAuthState.error(e.toString());
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      state = MockAuthState.authenticated(user);
    } catch (e) {
      state = MockAuthState.error(e.toString());
    }
  }

  String _getNameFromEmail(String email) {
    final username = email.split('@')[0];
    final parts = username.split('.');
    if (parts.length >= 2) {
      return '${_capitalize(parts[0])} ${_capitalize(parts[1])}';
    }
    return _capitalize(username);
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

// Mock Auth State
class MockAuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;

  const MockAuthState._({
    this.isLoading = false,
    this.user,
    this.error,
  });

  const MockAuthState.initial() : this._();
  const MockAuthState.loading() : this._(isLoading: true);
  const MockAuthState.authenticated(UserModel user) : this._(user: user);
  const MockAuthState.unauthenticated() : this._();
  const MockAuthState.error(String error) : this._(error: error);

  bool get isAuthenticated => user != null;
  bool get isUnauthenticated => user == null && !isLoading;
  bool get hasError => error != null;
}
