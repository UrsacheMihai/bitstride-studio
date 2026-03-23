import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/course/studio_course.dart';
import '../translation/translation_service.dart';

// Manage Firestore reads and writes for courses and their translations.
class StudioCoursesFirestore {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TranslationService _trans = TranslationService();

  // Fetch all course documents from the courses collection.
  Future<List<StudioCourse>> getAllCourses() async {
    final snap = await _db.collection('courses').get();
    return snap.docs.map((d) => StudioCourse.fromJson(d.id, d.data())).toList();
  }

  // Create a new course document or overwrites an existing one by ID.
  Future<void> saveCourse(StudioCourse course) async {
    if (course.id.isEmpty) {
      final docRef = await _db.collection('courses').add(course.toJson());
      course.id = docRef.id;
    } else {
      await _db.collection('courses').doc(course.id).set(course.toJson());
    }
  }

  // Delete the course document from Firestore by ID.
  Future<void> deleteCourse(String id) async {
    await _db.collection('courses').doc(id).delete();
  }

  // Translate all text fields of the course into the target languages and save them as subcollections.
}