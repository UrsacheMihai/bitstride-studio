import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/studio_course.dart';

class StudioCoursesFirestore {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<StudioCourse>> getAllCourses() async {
    final snap = await _db.collection('courses').get();
    return snap.docs.map((d) => StudioCourse.fromJson(d.id, d.data())).toList();
  }

  Future<void> saveCourse(StudioCourse course) async {
    if (course.id.isEmpty) {
      final docRef = await _db.collection('courses').add(course.toJson());
      course.id = docRef.id;
    } else {
      await _db.collection('courses').doc(course.id).set(course.toJson());
    }
  }

  Future<void> deleteCourse(String id) async {
    await _db.collection('courses').doc(id).delete();
  }
}
