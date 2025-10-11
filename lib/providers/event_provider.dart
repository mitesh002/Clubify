import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
// Registration model removed; events are member-only
import '../models/user_model.dart';

class EventProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<EventModel> _events = [];
  List<EventModel> _upcomingEvents = [];
  // Registrations removed
  bool _isLoading = false;
  String? _error;

  List<EventModel> get events => _events;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  // Registrations removed
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEvents() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snap = await _firestore
          .collection('events')
          .where('dateTime', isGreaterThan: Timestamp.now())
          .orderBy('dateTime')
          .limit(50)
          .get();
      _events =
          snap.docs.map((d) => EventModel.fromMap(d.data(), d.id)).toList();
      _upcomingEvents = _events;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load events: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEventsByClub(String clubId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snap = await _firestore
          .collection('events')
          .where('clubId', isEqualTo: clubId)
          .orderBy('dateTime')
          .get();
      _events =
          snap.docs.map((d) => EventModel.fromMap(d.data(), d.id)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load club events: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEvent({
    required String clubId,
    required String title,
    required String description,
    required DateTime dateTime,
    required String venue,
    required int maxParticipants,
    String? imageUrl,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Mock creation
      await Future.delayed(const Duration(seconds: 1));

      final event = EventModel(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
        clubId: clubId,
        title: title,
        description: description,
        dateTime: dateTime,
        venue: venue,
        maxParticipants: maxParticipants,
        status: 'upcoming',
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      _events.add(event);
      _upcomingEvents.add(event);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create event: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required DateTime dateTime,
    required String venue,
    required int maxParticipants,
    String? imageUrl,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Mock update
      await Future.delayed(const Duration(seconds: 1));

      final index = _events.indexWhere((event) => event.id == eventId);
      if (index != -1) {
        _events[index] = _events[index].copyWith(
          title: title,
          description: description,
          dateTime: dateTime,
          venue: venue,
          maxParticipants: maxParticipants,
          imageUrl: imageUrl,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update event: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // registerForEvent removed

  // loadRegistrationsForEvent removed

  // loadStudentRegistrations removed

  // updateRegistrationStatus removed

  Future<List<UserModel>> getLeaderboard() async {
    try {
      // Mock data
      await Future.delayed(const Duration(seconds: 1));

      return [
        UserModel(
          id: 'user1',
          name: 'John Doe',
          email: 'john@example.com',
          role: 'student',
          course: 'Computer Science',
          points: 150,
        ),
        UserModel(
          id: 'user2',
          name: 'Jane Smith',
          email: 'jane@example.com',
          role: 'student',
          course: 'Engineering',
          points: 120,
        ),
        UserModel(
          id: 'user3',
          name: 'Mike Johnson',
          email: 'mike@example.com',
          role: 'student',
          course: 'Business',
          points: 100,
        ),
      ];
    } catch (e) {
      _error = 'Failed to load leaderboard: $e';
      notifyListeners();
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
