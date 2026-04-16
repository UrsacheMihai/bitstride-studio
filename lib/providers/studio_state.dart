import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/studio_challenge.dart';
import '../services/studio_auth.dart';
import '../services/studio_firestore.dart';
import '../services/studio_courses_firestore.dart';
import '../models/studio_course.dart';
class StudioState extends ChangeNotifier {
  final StudioAuthService _auth = StudioAuthService();
  final StudioFirestore _db = StudioFirestore();
  User? _user;
  String _role = 'user';
  List<StudioChallenge> _myChallenges = [];
  List<StudioChallenge> _allChallenges = [];
  List<StudioCourse> _courses = [];
  bool _isLoading = true;
  String _language = 'en';
  User? get user => _user;
  String get role => _role;
  bool get isAdmin => _role == 'admin';
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String get language => _language;
  List<StudioChallenge> get myChallenges => _myChallenges;
  List<StudioChallenge> get allChallenges => _allChallenges;
  List<StudioCourse> get courses => _courses;
  final StudioCoursesFirestore _courseDb = StudioCoursesFirestore();
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString('language') ?? 'en';
    _auth.authChanges.listen((user) async {
      _user = user;
      if (user != null) {
        try {
          _role = await _db.getRole(user.uid);
          await refreshChallenges();
        } catch (e) {
          debugPrint('Auth listener error: $e');
        }
      } else {
        _role = 'user';
        _myChallenges = [];
        _allChallenges = [];
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> refreshChallenges() async {
    if (_user == null) return;
    _myChallenges = await _db.getMyChallenges(_user!.uid);
    if (isAdmin) {
      _allChallenges = await _db.getAllChallenges();
      _courses = await _courseDb.getAllCourses();
      try {
        final practiceJson = await rootBundle.loadString('assets/practice_challenges.json');
        final decoded = json.decode(practiceJson);
        final List<dynamic> challs = decoded['challenges'];
        for (var c in challs) {
          if (!_allChallenges.any((dbC) => dbC.id == c['id'])) {
            _allChallenges.add(StudioChallenge.fromFirestore(c));
          }
        }
      } catch (e) { print('Failed practice: $e'); }
      try {
        final cppJson = await rootBundle.loadString('assets/cpp_basics_course.json');
        final pyJson = await rootBundle.loadString('assets/python_basics_course.json');
        final cppObj = json.decode(cppJson);
        final pyObj = json.decode(pyJson);
        if (!_courses.any((dbC) => dbC.id == 'cpp_basics')) {
          _courses.add(StudioCourse.fromJson('cpp_basics', cppObj));
        }
        if (!_courses.any((dbC) => dbC.id == 'python_basics')) {
          _courses.add(StudioCourse.fromJson('python_basics', pyObj));
        }
      } catch (_) {}
    }
    notifyListeners();
  }
  Future<void> saveCourse(StudioCourse course) async {
    await _courseDb.saveCourse(course);
    await refreshChallenges();
  }
  Future<void> deleteCourse(String id) async {
    await _courseDb.deleteCourse(id);
    await refreshChallenges();
  }
  Future<void> signInWithGoogle() async {
    await _auth.signInWithGoogle();
  }
  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmail(email, password);
  }
  Future<void> signUpWithEmail(
      String email, String password, String name) async {
    await _auth.signUpWithEmail(email, password, name);
  }
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
  Future<void> publishChallenge(StudioChallenge challenge) async {
    await _db.publishChallenge(challenge);
    await refreshChallenges();
  }
  Future<void> setApproval(String id, bool approved) async {
    await _db.setApproval(id, approved);
    await refreshChallenges();
  }
  Future<void> deleteChallenge(String id) async {
    await _db.deleteChallenge(id);
    await refreshChallenges();
  }
  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }
}

