import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/studio_challenge.dart';
class StudioFirestore {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference get _challenges => _db.collection('user_challenges');
  CollectionReference get _users => _db.collection('users');
  Future<String> getRole(String uid) async {
    final doc = await _users.doc(uid).collection('meta').doc('role').get();
    if (!doc.exists) return 'user';
    return (doc.data() as Map<String, dynamic>?)?['value'] ?? 'user';
  }
  Future<void> publishChallenge(StudioChallenge challenge) async {
    await _challenges.doc(challenge.id).set(challenge.toFirestore());
  }
  Future<List<StudioChallenge>> getMyChallenges(String uid) async {
    final snap = await _challenges
        .where('creator_uid', isEqualTo: uid)
        .get();
    final list = snap.docs
        .map((d) =>
            StudioChallenge.fromFirestore(d.data() as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
  Future<List<StudioChallenge>> getAllChallenges() async {
    final snap =
        await _challenges.orderBy('created_at', descending: true).get();
    return snap.docs
        .map((d) =>
            StudioChallenge.fromFirestore(d.data() as Map<String, dynamic>))
        .toList();
  }
  Future<void> setApproval(String challengeId, bool approved) async {
    await _challenges.doc(challengeId).update({'approved': approved});
  }
  Future<void> deleteChallenge(String challengeId) async {
    await _challenges.doc(challengeId).delete();
  }
}

