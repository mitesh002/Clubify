import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'event_attendance_service.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user details by ID
  static Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  /// Get multiple users by IDs
  static Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];
      
      final futures = userIds.map((id) => getUserById(id));
      final results = await Future.wait(futures);
      return results.where((user) => user != null).cast<UserModel>().toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  /// Get user stream by ID
  static Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  /// Get member count for a club
  static Future<int> getClubMemberCount(String clubId) async {
    try {
      final snapshot = await _firestore
          .collection('clubs')
          .doc(clubId)
          .collection('members')
          .where('role', whereIn: ['member', 'leader'])
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting member count: $e');
      return 0;
    }
  }

  /// Get member count stream for a club
  static Stream<int> getClubMemberCountStream(String clubId) {
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('members')
        .where('role', whereIn: ['member', 'leader'])
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get user's event attendance count
  static Future<int> getUserEventCount(String userId) async {
    return await EventAttendanceService.getUserAttendedEventsCount(userId);
  }

  /// Get user's rank in leaderboard
  static Future<int> getUserRank(String userId) async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .orderBy('points', descending: true)
          .get();
      
      final users = usersSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
      
      final userIndex = users.indexWhere((user) => user.id == userId);
      return userIndex >= 0 ? userIndex + 1 : users.length + 1;
    } catch (e) {
      print('Error getting user rank: $e');
      return 0;
    }
  }
}
