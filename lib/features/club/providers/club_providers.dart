import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/club_model.dart';
import '../data/club_repository.dart';
import '../../auth/providers/auth_providers.dart';

// Repository provider
final clubRepositoryProvider = Provider<ClubRepository>((ref) {
  return ClubRepository(FirebaseFirestore.instance);
});

// Stream of approved clubs for student views
final approvedClubsProvider = StreamProvider<List<ClubModel>>((ref) {
  final repo = ref.watch(clubRepositoryProvider);
  return repo.listApprovedClubs();
});

// Stream of clubs owned by the current leader
final leaderClubsProvider = StreamProvider<List<ClubModel>>((ref) {
  final repo = ref.watch(clubRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);

  return currentUser.when(
    data: (user) {
      if (user == null) return const Stream<List<ClubModel>>.empty();
      return repo.listLeaderClubs(user.id);
    },
    loading: () => const Stream<List<ClubModel>>.empty(),
    error: (_, __) => const Stream<List<ClubModel>>.empty(),
  );
});


