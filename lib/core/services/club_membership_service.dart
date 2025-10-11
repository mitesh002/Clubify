import 'package:cloud_firestore/cloud_firestore.dart';

class ClubMembershipService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if user is a member of a club
  static Future<String?> getUserClubStatus(String userId, String clubId) async {
    try {
      final doc = await _firestore
          .collection('clubs')
          .doc(clubId)
          .collection('members')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
      return null;
    } catch (e) {
      print('Error checking club membership: $e');
      return null;
    }
  }

  /// Get all clubs where user is a member
  static Future<List<Map<String, dynamic>>> getUserClubs(String userId) async {
    try {
      final clubs = <Map<String, dynamic>>[];
      
      // Get all clubs
      final clubsSnapshot = await _firestore.collection('clubs').get();
      
      for (final clubDoc in clubsSnapshot.docs) {
        final memberDoc = await _firestore
            .collection('clubs')
            .doc(clubDoc.id)
            .collection('members')
            .doc(userId)
            .get();
        
        if (memberDoc.exists) {
          final memberData = memberDoc.data()!;
          final role = memberData['role'] as String?;
          
          // Only include if user is a member (not pending or rejected)
          if (role == 'member' || role == 'leader') {
            final clubData = clubDoc.data();
            clubs.add({
              'clubId': clubDoc.id,
              'clubName': clubData['name'] ?? '',
              'clubDescription': clubData['description'] ?? '',
              'clubImageUrl': clubData['imageUrl'],
              'role': role,
              'joinedAt': memberData['joinedAt'],
              'approvedAt': memberData['approvedAt'],
            });
          }
        }
      }
      
      return clubs;
    } catch (e) {
      print('Error getting user clubs: $e');
      return [];
    }
  }

  /// Get user's clubs stream
  static Stream<List<Map<String, dynamic>>> getUserClubsStream(String userId) {
    return _firestore.collection('clubs').snapshots().asyncMap((clubsSnapshot) async {
      final clubs = <Map<String, dynamic>>[];
      
      for (final clubDoc in clubsSnapshot.docs) {
        final memberDoc = await _firestore
            .collection('clubs')
            .doc(clubDoc.id)
            .collection('members')
            .doc(userId)
            .get();
        
        if (memberDoc.exists) {
          final memberData = memberDoc.data()!;
          final role = memberData['role'] as String?;
          
          if (role == 'member' || role == 'leader') {
            final clubData = clubDoc.data();
            clubs.add({
              'clubId': clubDoc.id,
              'clubName': clubData['name'] ?? '',
              'clubDescription': clubData['description'] ?? '',
              'clubImageUrl': clubData['imageUrl'],
              'role': role,
              'joinedAt': memberData['joinedAt'],
              'approvedAt': memberData['approvedAt'],
            });
          }
        }
      }
      
      return clubs;
    });
  }

  /// Get user's club count
  static Future<int> getUserClubCount(String userId) async {
    try {
      final clubs = await getUserClubs(userId);
      return clubs.length;
    } catch (e) {
      print('Error getting user club count: $e');
      return 0;
    }
  }

  /// Request to join a club (only if not already a member)
  static Future<Map<String, dynamic>> requestClubMembership({
    required String userId,
    required String clubId,
  }) async {
    try {
      // Check if user is already a member
      final currentStatus = await getUserClubStatus(userId, clubId);
      
      if (currentStatus == 'member' || currentStatus == 'leader') {
        return {
          'success': false,
          'message': 'You are already a member of this club',
          'alreadyMember': true,
        };
      }
      
      if (currentStatus == 'pending') {
        return {
          'success': false,
          'message': 'You have already requested to join this club',
          'alreadyRequested': true,
        };
      }
      
      // Send join request
      await _firestore
          .collection('clubs')
          .doc(clubId)
          .collection('members')
          .doc(userId)
          .set({
        'role': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
        'approvedAt': null,
        'joinedAt': null,
      }, SetOptions(merge: true));
      
      return {
        'success': true,
        'message': 'Join request sent successfully',
      };
    } catch (e) {
      print('Error requesting club membership: $e');
      return {
        'success': false,
        'message': 'Failed to send join request: $e',
      };
    }
  }
}
