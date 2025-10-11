import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import '../models/club_model.dart';
import '../models/event_model.dart';
import '../models/registration_model.dart';
import '../config/app_config.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Collections
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _clubsCollection => _firestore.collection('clubs');
  CollectionReference get _eventsCollection => _firestore.collection('events');
  // Registrations collection removed: events are joinable only by club members

  // Auth Methods
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // User Methods
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).update(user.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Stream<UserModel?> getUserStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }
      return null;
    });
  }

  Future<List<UserModel>> getLeaderboard({int limit = 10}) async {
    try {
      final query = await _usersCollection
          .where('role', isEqualTo: 'student')
          .orderBy('points', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) {
        return UserModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Club Methods
  Future<List<ClubModel>> getClubs({String? status}) async {
    try {
      Query query = _clubsCollection.where('isActive', isEqualTo: true);
      
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        return ClubModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<ClubModel?> getClubById(String clubId) async {
    try {
      final doc = await _clubsCollection.doc(clubId).get();
      if (doc.exists) {
        return ClubModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<ClubModel?> getClubByLeaderId(String leaderId) async {
    try {
      final query = await _clubsCollection
          .where('leaderId', isEqualTo: leaderId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return ClubModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createClub(ClubModel club) async {
    try {
      final docRef = await _clubsCollection.add(club.toJson());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateClub(ClubModel club) async {
    try {
      await _clubsCollection.doc(club.id).update(club.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<ClubModel>> getClubsStream({String? status}) {
    Query query = _clubsCollection.where('isActive', isEqualTo: true);
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ClubModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }).toList();
    });
  }

  // Event Methods
  Future<List<EventModel>> getEvents({String? clubId, String? status}) async {
    try {
      Query query = _eventsCollection.where('isActive', isEqualTo: true);
      
      if (clubId != null) {
        query = query.where('clubId', isEqualTo: clubId);
      }
      
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('dateTime', descending: false);

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        return EventModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _eventsCollection.doc(eventId).get();
      if (doc.exists) {
        return EventModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createEvent(EventModel event) async {
    try {
      final docRef = await _eventsCollection.add(event.toJson());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEvent(EventModel event) async {
    try {
      await _eventsCollection.doc(event.id).update(event.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<EventModel>> getEventsStream({String? clubId, String? status}) {
    Query query = _eventsCollection.where('isActive', isEqualTo: true);
    
    if (clubId != null) {
      query = query.where('clubId', isEqualTo: clubId);
    }
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    query = query.orderBy('dateTime', descending: false);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }).toList();
    });
  }

  // Registration methods removed

  // Storage Methods
  Future<String> uploadImage(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      rethrow;
    }
  }

  // Messaging Methods
  Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      rethrow;
    }
  }

  // Batch Operations
  // Batch registration updates removed

  // Analytics and Statistics
  Future<Map<String, dynamic>> getClubStatistics(String clubId) async {
    try {
      final eventsQuery = await _eventsCollection
          .where('clubId', isEqualTo: clubId)
          .get();
      
      final totalEvents = eventsQuery.docs.length;
      final completedEvents = eventsQuery.docs
          .where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'completed')
          .length;
      
      // Registrations removed; return basic event stats only
      return {
        'totalEvents': totalEvents,
        'completedEvents': completedEvents,
        'totalRegistrations': 0,
        'attendedRegistrations': 0,
        'attendanceRate': 0.0,
      };
    } catch (e) {
      rethrow;
    }
  }
}
