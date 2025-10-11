import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';
import '../../../core/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.watchCurrentUserModel();
});

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _authRepo;
  AuthController(this._authRepo) : super(const AsyncValue.data(null));

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String course,
    required String role,
    String? leaderClubName,
    String? leaderClubDescription,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authRepo.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        course: course,
        role: role,
        leaderClubName: leaderClubName,
        leaderClubDescription: leaderClubDescription,
      );
      final user = await _authRepo.loadCurrentUserModel();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authRepo.signInWithEmailAndPassword(email: email, password: password);
      final user = await _authRepo.loadCurrentUserModel();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authRepo.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Implement when google_sign_in is added
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});


