import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String course,
    required String role,
    String? leaderClubName,
    String? leaderClubDescription,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userDoc = _firestore.collection('users').doc(credential.user!.uid);
    await userDoc.set({
      'name': name,
      'email': email,
      'role': role,
      'course': course,
      'points': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': true,
    }, SetOptions(merge: true));

    // Optionally update display name
    await credential.user!.updateDisplayName(name);

    // If leader, create club immediately
    if (role == 'club_leader') {
      final clubData = {
        'name': leaderClubName ?? 'Untitled Club',
        'description': leaderClubDescription ?? '',
        'leaderId': credential.user!.uid,
        'status': 'approved', // or 'pending' if you require admin approval
        'imageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      final clubRef = await _firestore.collection('clubs').add(clubData);
      await clubRef.collection('members').doc(credential.user!.uid).set({
        'role': 'leader',
        'requestedAt': FieldValue.serverTimestamp(),
        'approvedAt': FieldValue.serverTimestamp(),
        'joinedAt': FieldValue.serverTimestamp(),
      });
    }
    return credential;
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    // Ensure user doc exists (handles legacy users created outside our signup flow)
    final uid = result.user!.uid;
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'name': result.user!.displayName ?? '',
        'email': result.user!.email ?? email,
        'role': 'student',
        'course': '',
        'points': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'profileImageUrl': result.user!.photoURL,
        'isActive': true,
      });
    } else {
      await docRef.set({
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    return result;
  }

  Future<void> signOut() async => _auth.signOut();

  // Google sign-in can be implemented by adding the google_sign_in package
  // and wiring the credential to FirebaseAuth. Left out to avoid build errors
  // when the dependency is not added yet.

  Future<UserModel?> loadCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final snap = await _firestore.collection('users').doc(user.uid).get();
    if (!snap.exists) return null;
    return _mapUserDoc(snap);
  }

  Stream<UserModel?> watchCurrentUserModel() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(null);
      return _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map(_mapUserDocNullable);
    });
  }

  UserModel? _mapUserDocNullable(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) return null;
    return _mapUserDoc(doc);
  }

  UserModel _mapUserDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    DateTime createdAt;
    DateTime updatedAt;
    final created = data['createdAt'];
    final updated = data['updatedAt'];
    if (created is Timestamp) {
      createdAt = created.toDate();
    } else if (created is DateTime) {
      createdAt = created;
    } else {
      createdAt = DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (updated is Timestamp) {
      updatedAt = updated.toDate();
    } else if (updated is DateTime) {
      updatedAt = updated;
    } else {
      updatedAt = createdAt;
    }

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


