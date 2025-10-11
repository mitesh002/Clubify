import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/club_model.dart';

class ClubProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ClubModel> _clubs = [];
  List<ClubModel> _approvedClubs = [];
  ClubModel? _currentClub;
  bool _isLoading = false;
  String? _error;

  List<ClubModel> get clubs => _clubs;
  List<ClubModel> get approvedClubs => _approvedClubs;
  ClubModel? get currentClub => _currentClub;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadClubs() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snap = await _firestore
          .collection('clubs')
          .where('status', isEqualTo: 'approved')
          .get();
      _clubs = snap.docs.map((d) => ClubModel.fromMap(d.data(), d.id)).toList();
      _approvedClubs = _clubs;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load clubs: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createClub({
    required String name,
    required String description,
    required String leaderId,
    String? imageUrl,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create club doc in Firestore
      final clubRef = await _firestore.collection('clubs').add({
        'name': name,
        'description': description,
        'leaderId': leaderId,
        'status': 'pending', // or 'approved' based on your flow
        'imageUrl': imageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Ensure leader is added as a member with role 'leader'
      await clubRef.collection('members').doc(leaderId).set({
        'role': 'leader',
        'requestedAt': FieldValue.serverTimestamp(),
        'approvedAt': FieldValue.serverTimestamp(),
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Update local cache (best-effort; server timestamps are not resolved here)
      final club = ClubModel(
        id: clubRef.id,
        name: name,
        description: description,
        leaderId: leaderId,
        status: 'pending',
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );
      _clubs.add(club);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create club: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestMembership({
    required String clubId,
    required String userId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final memberRef = _firestore
          .collection('clubs')
          .doc(clubId)
          .collection('members')
          .doc(userId);

      await memberRef.set({
        'role': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
        'approvedAt': null,
        'joinedAt': null,
      }, SetOptions(merge: true));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to request membership: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> approveMembership({
    required String clubId,
    required String userId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final memberRef = _firestore
          .collection('clubs')
          .doc(clubId)
          .collection('members')
          .doc(userId);

      await memberRef.set({
        'role': 'member',
        'approvedAt': FieldValue.serverTimestamp(),
        'joinedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to approve membership: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectMembership({
    required String clubId,
    required String userId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final memberRef = _firestore
          .collection('clubs')
          .doc(clubId)
          .collection('members')
          .doc(userId);

      await memberRef.set({
        'role': 'rejected',
        'approvedAt': null,
        'joinedAt': null,
      }, SetOptions(merge: true));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to reject membership: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateClub({
    required String clubId,
    required String name,
    required String description,
    String? imageUrl,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Mock update
      await Future.delayed(const Duration(seconds: 1));

      // Update local club
      final index = _clubs.indexWhere((club) => club.id == clubId);
      if (index != -1) {
        _clubs[index] = _clubs[index].copyWith(
          name: name,
          description: description,
          imageUrl: imageUrl,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update club: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<ClubModel?> getClubByLeaderId(String leaderId) async {
    try {
      final snap = await _firestore
          .collection('clubs')
          .where('leaderId', isEqualTo: leaderId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return ClubModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
    } catch (e) {
      _error = 'Failed to get club: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> loadCurrentClub(String leaderId) async {
    try {
      _currentClub = await getClubByLeaderId(leaderId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load current club: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
