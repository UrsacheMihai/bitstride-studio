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
  Future<void> autoTranslateCourse(StudioCourse course) async {
    if (course.id.isEmpty) return;

    final targetLanguages = ['es', 'fr', 'pt', 'ro'];

    for (final lang in targetLanguages) {
      final translatedTitle = await _trans.translateText(course.title, lang);
      final translatedDesc =
          await _trans.translateText(course.description, lang);

      final List<Map<String, dynamic>> translatedLessons = [];

      for (final lesson in course.lessons) {
        final lTitle = await _trans.translateText(lesson.title, lang);
        final lDesc = await _trans.translateText(lesson.description, lang);

        final List<Map<String, dynamic>> lBlocks = [];
        for (final block in lesson.contentBlocks) {
          // Translate text, heading, and quiz block contents for the target language.
          if (block.type == 'text' || block.type == 'heading') {
            final translatedContent =
                await _trans.translateText(block.content, lang);
            lBlocks.add({
              'type': block.type,
              'content': translatedContent,
            });
          } else if (block.type == 'quiz') {
            try {
              final Map<String, dynamic> quizData = jsonDecode(block.content);
              final String originalQuestion = quizData['question']?.toString() ?? '';
              final List<dynamic> originalOptions = quizData['options'] as List<dynamic>? ?? [];
              final String originalExplanation = quizData['explanation']?.toString() ?? '';
              
              final translatedQuestion = await _trans.translateText(originalQuestion, lang);
              final List<String> translatedOptions = [];
              for (final opt in originalOptions) {
                final transOpt = await _trans.translateText(opt.toString(), lang);
                translatedOptions.add(transOpt);
              }
              
                            String translatedExplanation = '';
              if (originalExplanation.isNotEmpty) {
                translatedExplanation = await _trans.translateText(originalExplanation, lang);
              }

              final List<dynamic> originalExplanations = quizData['explanations'] as List<dynamic>? ?? [];
              final List<String> translatedExplanations = [];
              for (final exp in originalExplanations) {
                if (exp.toString().isNotEmpty) {
                  final transExp = await _trans.translateText(exp.toString(), lang);
                  translatedExplanations.add(transExp);
                } else {
                  translatedExplanations.add('');
                }
              }
              
              final newQuizData = {
                'question': translatedQuestion,
                'options': translatedOptions,
                'correctIndex': quizData['correctIndex'] ?? 0,
                'isMultipleChoice': quizData['isMultipleChoice'] ?? false,
                'correctIndices': quizData['correctIndices'] ?? [quizData['correctIndex'] ?? 0],
                'explanation': translatedExplanation,
                'explanations': translatedExplanations,
              };
              lBlocks.add({
                'type': block.type,
                'content': jsonEncode(newQuizData),
              });
            } catch (_) {
              lBlocks.add(block.toJson());
            }
          } else {
            lBlocks.add(block.toJson());
          }
        }

        translatedLessons.add({
          'id': lesson.id,
          'title': lTitle,
          'description': lDesc,
          'content_blocks': lBlocks,
        });
      }

      final translationData = {
        'title': translatedTitle,
        'description': translatedDesc,
        'lessons': translatedLessons,
      };

      await _db
          .collection('courses')
          .doc(course.id)
          .collection('translations')
          .doc(lang)
          .set(translationData);
    }
  }
}
