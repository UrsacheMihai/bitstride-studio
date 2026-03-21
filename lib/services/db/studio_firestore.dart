import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/challenge/studio_challenge.dart';

// Manage Firestore reads and writes for challenge records.
class StudioFirestore {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _challenges => _db.collection('user_challenges');

  CollectionReference get _users => _db.collection('users');

  // Retrieves the role value from the user's meta subcollection.
  Future<String> getRole(String uid) async {
    final doc = await _users.doc(uid).collection('meta').doc('role').get();
    if (!doc.exists) return 'user';
    return (doc.data() as Map<String, dynamic>?)?['value'] ?? 'user';
  }

  // Write the challenge document to Firestore using the challenge ID.
  Future<void> publishChallenge(StudioChallenge challenge) async {
    await _challenges.doc(challenge.id).set(challenge.toFirestore());
  }

  // Fetch all challenges created by the given user UID sorted by creation date.
}