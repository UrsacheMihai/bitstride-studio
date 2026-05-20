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
  Future<List<StudioChallenge>> getMyChallenges(String uid) async {
    final snap = await _challenges.where('creator_uid', isEqualTo: uid).get();
    final list = snap.docs
        .map((d) =>
            StudioChallenge.fromFirestore(d.data() as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // Fetch all challenges ordered by creation date descending.
  Future<List<StudioChallenge>> getAllChallenges() async {
    final snap =
        await _challenges.orderBy('created_at', descending: true).get();
    return snap.docs
        .map((d) =>
            StudioChallenge.fromFirestore(d.data() as Map<String, dynamic>))
        .toList();
  }

  // Update the approved field for the given challenge ID.
  Future<void> setApproval(String challengeId, bool approved) async {
    await _challenges.doc(challengeId).update({'approved': approved});
  }

  // Delete the challenge document from Firestore.
  Future<void> deleteChallenge(String challengeId) async {
    await _challenges.doc(challengeId).delete();
  }

  // Read the Piston API base URL from the config collection.
  Future<String?> getPistonUrl() async {
    try {
      final doc = await _db.collection('config').doc('piston').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return (data['piston_base_url'] ??
            data['cloudflare_url'] ??
            data['url']) as String?;
      }
    } catch (_) {}
    return null;
  }
}
