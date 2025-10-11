import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/event_repository.dart';
import '../../../models/event_model.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(FirebaseFirestore.instance);
});

final clubEventsProvider =
    StreamProvider.family<List<EventModel>, String>((ref, clubId) {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.listClubEvents(clubId);
});

final upcomingEventsProvider = StreamProvider<List<EventModel>>((ref) {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.listUpcomingEvents();
});

final pastEventsProvider = StreamProvider<List<EventModel>>((ref) {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.listPastEvents();
});

final allEventsProvider = StreamProvider<List<EventModel>>((ref) {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.listAllEvents();
});


