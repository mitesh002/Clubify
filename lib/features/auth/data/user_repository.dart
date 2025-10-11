import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users');

  Future<UserModel?> getUser(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  Stream<UserModel?> watchUser(String uid) {
    return _col.doc(uid).snapshots().map((doc) => doc.exists ? _fromDoc(doc) : null);
  }

  Future<void> updateUser(UserModel user) async {
    await _col.doc(user.id).set({
      'name': user.name,
      'email': user.email,
      'role': user.role,
      'course': user.course,
      'points': user.points,
      'profileImageUrl': user.profileImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': user.isActive,
      'metadata': user.metadata,
    }, SetOptions(merge: true));
  }

  UserModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final created = data['createdAt'];
    final updated = data['updatedAt'];
    final createdAt = created is Timestamp ? created.toDate() : DateTime.tryParse('$created') ?? DateTime.now();
    final updatedAt = updated is Timestamp ? updated.toDate() : DateTime.tryParse('$updated') ?? createdAt;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      course: data['course'] ?? '',
      points: (data['points'] ?? 0) is int ? data['points'] ?? 0 : (data['points'] as num?)?.toInt() ?? 0,
      profileImageUrl: data['profileImageUrl'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: (data['isActive'] ?? true) as bool,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }
}


