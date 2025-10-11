import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/event_model.dart';

class EventRepository {
  final FirebaseFirestore _firestore;
  EventRepository(this._firestore);

  // Events for a specific club (upcoming first)
  Stream<List<EventModel>> listClubEvents(String clubId) {
    return _firestore
        .collection('events')
        .where('clubId', isEqualTo: clubId)
        .orderBy('dateTime')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => _fromFirestore(d.data(), d.id)).toList());
  }

  // Global upcoming feed
  Stream<List<EventModel>> listUpcomingEvents() {
    return _firestore
        .collection('events')
        .where('dateTime', isGreaterThan: Timestamp.now())
        .orderBy('dateTime')
        .limit(50)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => _fromFirestore(d.data(), d.id)).toList());
  }

  // Past/completed events feed
  Stream<List<EventModel>> listPastEvents() {
    return _firestore
        .collection('events')
        .where('dateTime', isLessThan: Timestamp.now())
        .orderBy('dateTime', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => _fromFirestore(d.data(), d.id)).toList());
  }

  // All events (combined) - lightweight, ordered by date
  Stream<List<EventModel>> listAllEvents() {
    return _firestore
        .collection('events')
        .orderBy('dateTime', descending: true)
        .limit(150)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => _fromFirestore(d.data(), d.id)).toList());
  }

  EventModel _fromFirestore(Map<String, dynamic> data, String id) {
    return EventModel(
      id: id,
      clubId: data['clubId'] ?? data['club_id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ??
          (data['date_time'] is int
              ? DateTime.fromMillisecondsSinceEpoch(data['date_time'])
              : DateTime.now()),
      venue: data['venue'] ?? '',
      maxParticipants: data['maxParticipants'] ?? data['max_participants'] ?? 0,
      status: data['status'] ?? 'upcoming',
      imageUrl: data['imageUrl'] ?? data['image_url'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          (data['created_at'] is int
              ? DateTime.fromMillisecondsSinceEpoch(data['created_at'])
              : DateTime.now()),
    );
  }
}


