import 'package:cloud_firestore/cloud_firestore.dart';

class EventAttendanceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mark user as attended an event
  static Future<bool> markAttendance({
    required String userId,
    required String eventId,
    required String clubId,
  }) async {
    try {
      await _firestore
          .collection('event_attendance')
          .doc('${eventId}_$userId')
          .set({
        'userId': userId,
        'eventId': eventId,
        'clubId': clubId,
        'attended': true,
        'attendedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error marking attendance: $e');
      return false;
    }
  }

  /// Check if user attended an event
  static Future<bool> didUserAttendEvent(String userId, String eventId) async {
    try {
      final doc = await _firestore
          .collection('event_attendance')
          .doc('${eventId}_$userId')
          .get();
      return doc.exists && (doc.data()?['attended'] == true);
    } catch (e) {
      print('Error checking attendance: $e');
      return false;
    }
  }

  /// Get attendance count for an event
  static Future<int> getEventAttendanceCount(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('event_attendance')
          .where('eventId', isEqualTo: eventId)
          .where('attended', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting attendance count: $e');
      return 0;
    }
  }

  /// Get user's attended events count
  static Future<int> getUserAttendedEventsCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('event_attendance')
          .where('userId', isEqualTo: userId)
          .where('attended', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting user attended events count: $e');
      return 0;
    }
  }

  /// Get attendance stream for an event
  static Stream<int> getEventAttendanceStream(String eventId) {
    return _firestore
        .collection('event_attendance')
        .where('eventId', isEqualTo: eventId)
        .where('attended', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get user's attendance history
  static Stream<List<Map<String, dynamic>>> getUserAttendanceHistory(String userId) {
    return _firestore
        .collection('event_attendance')
        .where('userId', isEqualTo: userId)
        .where('attended', isEqualTo: true)
        .orderBy('attendedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList());
  }
}
