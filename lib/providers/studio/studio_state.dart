import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/challenge/studio_challenge.dart';
import '../../services/auth/studio_auth.dart';
import '../../services/db/studio_firestore.dart';
import '../../services/db/studio_courses_firestore.dart';
import '../../models/course/studio_course.dart';

// Manage state and provide providers for Studio State.
class StudioState extends ChangeNotifier {
  final StudioAuthService _auth = StudioAuthService();
  final StudioFirestore _db = StudioFirestore();
  final StudioCoursesFirestore _courseDb = StudioCoursesFirestore();
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

  // Load persisted language preference and subscribe to auth state changes.
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
}