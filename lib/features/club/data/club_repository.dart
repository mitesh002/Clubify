import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/club_model.dart';

class ClubRepository {
  final FirebaseFirestore _firestore;
  ClubRepository(this._firestore);

  // List all approved clubs
  Stream<List<ClubModel>> listApprovedClubs() {
    return _firestore
        .collection('clubs')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => _fromFirestore(d.data(), d.id)).toList());
  }

  // List clubs for a leader
  Stream<List<ClubModel>> listLeaderClubs(String leaderId) {
    return _firestore
        .collection('clubs')
        .where('leaderId', isEqualTo: leaderId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => _fromFirestore(d.data(), d.id)).toList());
  }

  // Watch a single club
  Stream<ClubModel?> watchClub(String clubId) {
    return _firestore.collection('clubs').doc(clubId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _fromFirestore(doc.data()!, doc.id);
    });
  }

  ClubModel _fromFirestore(Map<String, dynamic> data, String id) {
    // Firestore uses camelCase in our writes elsewhere
    return ClubModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      leaderId: data['leaderId'] ?? data['leader_id'] ?? '',
      status: data['status'] ?? 'pending',
      imageUrl: data['imageUrl'] ?? data['image_url'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          (data['created_at'] is int
              ? DateTime.fromMillisecondsSinceEpoch(data['created_at'])
              : DateTime.now()),
    );
  }
}
