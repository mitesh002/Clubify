import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/firebase_service.dart';

// Auth State Provider
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseService().authStateChanges;
});

// Current User Provider
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user != null) {
        return FirebaseService().getUserStream(user.uid);
      }
      return Stream.value(null);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Auth Controller
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;
  final FirebaseService _firebaseService = FirebaseService();

  AuthController(this._ref) : super(const AuthState.initial());

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AuthState.loading();
    
    try {
      final userCredential = await _firebaseService.signInWithEmailAndPassword(email, password);
      
      if (userCredential?.user != null) {
        final user = await _firebaseService.getUserById(userCredential!.user!.uid);
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = const AuthState.error('User data not found');
        }
      }
    } on FirebaseAuthException catch (e) {
      state = AuthState.error(_getAuthErrorMessage(e));
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String course,
    required String role,
  }) async {
    state = const AuthState.loading();
    
    try {
      final userCredential = await _firebaseService.createUserWithEmailAndPassword(email, password);
      
      if (userCredential?.user != null) {
        final now = DateTime.now();
        final user = UserModel(
          id: userCredential!.user!.uid,
          name: name,
          email: email,
          role: role,
          course: course,
          points: 0,
          createdAt: now,
          updatedAt: now,
        );
        
        await _firebaseService.createUser(user);
        state = AuthState.authenticated(user);
      }
    } on FirebaseAuthException catch (e) {
      state = AuthState.error(_getAuthErrorMessage(e));
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();
    
    try {
      final userCredential = await _firebaseService.signInWithGoogle();
      
      if (userCredential?.user != null) {
        final firebaseUser = userCredential!.user!;
        
        // Check if user already exists
        UserModel? user = await _firebaseService.getUserById(firebaseUser.uid);
        
        if (user == null) {
          // Create new user
          final now = DateTime.now();
          user = UserModel(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
            role: 'student', // Default role
            course: '', // Will be updated in profile
            points: 0,
            profileImageUrl: firebaseUser.photoURL,
            createdAt: now,
            updatedAt: now,
          );
          
          await _firebaseService.createUser(user);
        }
        
        state = AuthState.authenticated(user);
      }
    } on FirebaseAuthException catch (e) {
      state = AuthState.error(_getAuthErrorMessage(e));
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    state = const AuthState.loading();
    
    try {
      await _firebaseService.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseService.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e);
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firebaseService.updateUser(user);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
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
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not allowed.';
      default:
        return e.message ?? 'An error occurred during authentication.';
    }
  }
}

// Auth State
class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;

  const AuthState._({
    this.isLoading = false,
    this.user,
    this.error,
  });

  const AuthState.initial() : this._();
  const AuthState.loading() : this._(isLoading: true);
  const AuthState.authenticated(UserModel user) : this._(user: user);
  const AuthState.unauthenticated() : this._();
  const AuthState.error(String error) : this._(error: error);

  bool get isAuthenticated => user != null;
  bool get isUnauthenticated => user == null && !isLoading;
  bool get hasError => error != null;
}
