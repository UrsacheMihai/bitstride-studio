// Provide a main portal for creating, editing, and listing creator courses.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course/studio_course.dart';
import '../../providers/studio/studio_state.dart';
import '../../theme/studio_theme.dart';
import '../../widgets/glass/glass_app_bar.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';
import '../../services/db/studio_courses_firestore.dart';
import '../lesson/lesson_editor_page.dart';

// Course definition and initialization
class CourseManagerScreen extends StatefulWidget {
  const CourseManagerScreen({super.key});

  @override
  State<CourseManagerScreen> createState() => _CourseManagerScreenState();
}

// Course definition and initialization
class _CourseManagerScreenState extends State<CourseManagerScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudioState>();
    final courses = state.courses;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: StudioTheme.creatorGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: StudioTheme.accentPurple.withOpacity(0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.school_rounded,
                  size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(l.courseCurriculum),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => _addCourse(context),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(l.addCourse, style: const TextStyle(fontSize: 13)),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: StudioTheme.meshBackground(isDark: isDark),
        child: courses.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? StudioTheme.darkCard
                            : StudioTheme.lightCard2,
                        border: Border.all(
                          color: isDark
                              ? StudioTheme.darkBorder
                              : StudioTheme.lightBorder,
                        ),
                      ),
                      child: Icon(
                        Icons.school_outlined,
                        size: 48,
                        color: isDark
                            ? const Color(0xFF4A5568)
                            : const Color(0xFFABB8CC),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No courses yet',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : StudioTheme.darkBg,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create your first course to get started',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFF6B7A99)
                            : const Color(0xFF8B9AB0),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _CourseGradientFab(
                      label: l.addCourse,
                      onPressed: () => _addCourse(context),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                  16,
                  32,
                ),
                itemCount: courses.length,
                itemBuilder: (ctx, i) {
                  final course = courses[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: StudioTheme.solidCard(
                          isDark: isDark, borderRadius: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 4),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: StudioTheme.creatorGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: StudioTheme.accentPurple
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.school_rounded,
                                  size: 20, color: Colors.white),
                            ),
                            title: Text(
                              course.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color:
                                    isDark ? Colors.white : StudioTheme.darkBg,
                              ),
                            ),
                            subtitle: Text(
                              '${l.lessonsCount(course.lessons.length)} • ${course.language.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? const Color(0xFF6B7A99)
                                    : const Color(0xFF8B9AB0),
                              ),
                            ),
                            children: [
                              Divider(
                                height: 1,
                                color: isDark
                                    ? StudioTheme.darkBorder
                                    : StudioTheme.lightBorder,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 12, 16, 16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Wrap(
                                      alignment: WrapAlignment.end,
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () =>
                                              _editCourse(context, course),
                                          icon: const Icon(Icons.edit_rounded,
                                              size: 15),
                                          label: Text(l.editCourseInfo,
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed: () =>
                                              _translateCourse(context, course),
                                          icon: const Icon(
                                              Icons.translate_rounded,
                                              size: 15),
                                          label: const Text('Auto-Translate',
                                              style: TextStyle(fontSize: 12)),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed: () =>
                                              _deleteCourse(context, course),
                                          icon: const Icon(Icons.delete_rounded,
                                              size: 15,
                                              color: StudioTheme.errorRed),
                                          label: const Text('Delete',
                                              style: TextStyle(
                                                  color: StudioTheme.errorRed,
                                                  fontSize: 12)),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                StudioTheme.errorRed,
                                            side: BorderSide(
                                                color: StudioTheme.errorRed
                                                    .withOpacity(0.4)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        ),
                                        FilledButton.icon(
                                          onPressed: () =>
                                              _addLesson(context, course),
                                          icon: const Icon(Icons.add_rounded,
                                              size: 15),
                                          label: const Text('Add Lesson',
                                              style: TextStyle(fontSize: 12)),
                                          style: FilledButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (course.lessons.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      ...course.lessons.map((lesson) =>
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 8),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? StudioTheme.darkBg
                                                      .withOpacity(0.5)
                                                  : StudioTheme.lightCard,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isDark
                                                    ? StudioTheme.darkBorder
                                                    : StudioTheme.lightBorder,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: StudioTheme
                                                        .primaryCyan
                                                        .withOpacity(0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: const Icon(
                                                    Icons.play_lesson_rounded,
                                                    size: 16,
                                                    color:
                                                        StudioTheme.primaryCyan,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        lesson.title,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 13,
                                                          color: isDark
                                                              ? Colors.white
                                                              : StudioTheme
                                                                  .darkBg,
                                                        ),
                                                      ),
                                                      if (lesson.description
                                                          .isNotEmpty)
                                                        Text(
                                                          lesson.description,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: isDark
                                                                ? const Color(
                                                                    0xFF6B7A99)
                                                                : const Color(
                                                                    0xFF8B9AB0),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit_rounded,
                                                    size: 18,
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF4A5568)
                                                        : const Color(
                                                            0xFF8B9AB0),
                                                  ),
                                                  onPressed: () => _editLesson(
                                                      context, course, lesson),
                                                  tooltip: 'Edit',
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_rounded,
                                                    size: 18,
                                                    color: StudioTheme.errorRed,
                                                  ),
                                                  onPressed: () =>
                                                      _deleteLesson(context,
                                                          course, lesson),
                                                  tooltip: 'Delete',
                                                ),
                                              ],
                                            ),
                                          )),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _addCourse(BuildContext context) => _showCourseDialog(context, null);

  void _editCourse(BuildContext context, StudioCourse course) =>
      _showCourseDialog(context, course);

  void _translateCourse(BuildContext context, StudioCourse course) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(
                child: Text(
                    'Auto-translating course content to ES, FR, PT, RO...')),
          ],
        ),
      ),
    );
    try {
      await StudioCoursesFirestore().autoTranslateCourse(course);
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Course translated and published successfully!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Translation Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _deleteCourse(BuildContext context, StudioCourse course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Course'),
        content: Text(
            'Are you sure you want to delete "${course.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: StudioTheme.errorRed),
            onPressed: () {
              context.read<StudioState>().deleteCourse(course.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteLesson(
      BuildContext context, StudioCourse course, StudioLesson lesson) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Lesson'),
        content: Text('Are you sure you want to delete "${lesson.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: StudioTheme.errorRed),
            onPressed: () {
              final newCourse = StudioCourse(
                id: course.id,
                title: course.title,
                description: course.description,
                language: course.language,
                lessons:
                    course.lessons.where((l) => l.id != lesson.id).toList(),
              );
              context.read<StudioState>().saveCourse(newCourse);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCourseDialog(BuildContext context, StudioCourse? course) {
    final titleCtrl = TextEditingController(text: course?.title ?? '');
    final descCtrl = TextEditingController(text: course?.description ?? '');
    String lang = course?.language ?? 'cpp';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(course == null
              ? AppLocalizations.of(context)!.addCourse
              : AppLocalizations.of(context)!.editCourse),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.title),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.description),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: lang,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.language),
                  items: const [
                    DropdownMenuItem(value: 'cpp', child: Text('C++')),
                    DropdownMenuItem(value: 'python', child: Text('Python')),
                  ],
                  onChanged: (v) => setDialogState(() => lang = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final newCourse = StudioCourse(
                  id: course?.id ?? '',
                  title: titleCtrl.text,
                  description: descCtrl.text,
                  language: lang,
                  lessons: course?.lessons ?? [],
                );
                context.read<StudioState>().saveCourse(newCourse);
                Navigator.pop(ctx);
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }

  void _addLesson(BuildContext context, StudioCourse course) {
    final newLesson = StudioLesson(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Lesson',
      description: '',
      initialCode: '',
    );
    _showLessonEditor(context, course, newLesson, isNew: true);
  }

  void _editLesson(
      BuildContext context, StudioCourse course, StudioLesson lesson) {
    _showLessonEditor(context, course, lesson, isNew: false);
  }

  void _showLessonEditor(
      BuildContext context, StudioCourse course, StudioLesson lesson,
      {required bool isNew}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) => LessonEditorPage(
                course: course,
                lesson: lesson,
                isNew: isNew,
              )),
    );
  }
}

// Course definition and initialization
class _CourseGradientFab extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _CourseGradientFab({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: StudioTheme.creatorGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: StudioTheme.accentPurple.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
