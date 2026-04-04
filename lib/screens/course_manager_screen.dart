import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/studio_course.dart';
import '../providers/studio_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CourseManagerScreen extends StatefulWidget {
  const CourseManagerScreen({super.key});

  @override
  State<CourseManagerScreen> createState() => _CourseManagerScreenState();
}

class _CourseManagerScreenState extends State<CourseManagerScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudioState>();
    final courses = state.courses;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.courseCurriculum,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _addCourse(context),
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.addCourse),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (ctx, i) {
                final course = courses[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${AppLocalizations.of(context)!.lessonsCount(course.lessons.length)} • ${course.language}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                                Wrap(
                                  alignment: WrapAlignment.end,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _editCourse(context, course),
                                      icon: const Icon(Icons.edit, size: 16),
                                      label: Text(AppLocalizations.of(context)!.editCourseInfo),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _deleteCourse(context, course),
                                      icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _addLesson(context, course),
                                      icon: const Icon(Icons.add, size: 16),
                                      label: const Text('Lesson'), // Removed "Add" to save space
                                    ),
                                  ],
                                ),
                                const Divider(),
                            ...course.lessons.map((lesson) => ListTile(
                                  leading: const Icon(Icons.play_lesson),
                                  title: Text(lesson.title),
                                  subtitle: Text(lesson.description, maxLines: 1),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _editLesson(context, course, lesson),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteLesson(context, course, lesson),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addCourse(BuildContext context) => _showCourseDialog(context, null);
  void _editCourse(BuildContext context, StudioCourse course) => _showCourseDialog(context, course);

  void _deleteCourse(BuildContext context, StudioCourse course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete the course "${course.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<StudioState>().deleteCourse(course.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteLesson(BuildContext context, StudioCourse course, StudioLesson lesson) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete the lesson "${lesson.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final newCourse = StudioCourse(
                id: course.id,
                title: course.title,
                description: course.description,
                language: course.language,
                lessons: course.lessons.where((l) => l.id != lesson.id).toList(),
              );
              context.read<StudioState>().saveCourse(newCourse);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCourseDialog(BuildContext context, StudioCourse? course) {
    final titleCtrl = TextEditingController(text: course?.title ?? '');
    final descCtrl  = TextEditingController(text: course?.description ?? '');
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
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.title),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: lang,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.language),
                  items: const [
                    DropdownMenuItem(value: 'cpp',    child: Text('C++')),
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

  void _editLesson(BuildContext context, StudioCourse course, StudioLesson lesson) {
    _showLessonEditor(context, course, lesson, isNew: false);
  }

  void _showLessonEditor(BuildContext context, StudioCourse course, StudioLesson lesson, {required bool isNew}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => _LessonEditorPage(
        course: course,
        lesson: lesson,
        isNew: isNew,
      )),
    );
  }
}

// ─── Full-screen tabbed lesson editor ────────────────────────────────────────

class _LessonEditorPage extends StatefulWidget {
  final StudioCourse course;
  final StudioLesson lesson;
  final bool isNew;

  const _LessonEditorPage({
    required this.course,
    required this.lesson,
    required this.isNew,
  });

  @override
  State<_LessonEditorPage> createState() => _LessonEditorPageState();
}

class _LessonEditorPageState extends State<_LessonEditorPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _codeCtrl;
  late List<StudioContentBlock> _blocks;

  @override
  void initState() {
    super.initState();
    _tabs       = TabController(length: 2, vsync: this);
    _titleCtrl  = TextEditingController(text: widget.lesson.title);
    _descCtrl   = TextEditingController(text: widget.lesson.description);
    _codeCtrl   = TextEditingController(text: widget.lesson.initialCode);
    _blocks     = List.of(widget.lesson.contentBlocks);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.lesson.title        = _titleCtrl.text;
    widget.lesson.description  = _descCtrl.text;
    widget.lesson.initialCode  = _codeCtrl.text;
    widget.lesson.contentBlocks = List.of(_blocks);

    if (widget.isNew) {
      widget.course.lessons.add(widget.lesson);
    }
    context.read<StudioState>().saveCourse(widget.course);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New Lesson' : 'Edit Lesson'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book), text: 'Content'),
            Tab(icon: Icon(Icons.code),      text: 'Exercise'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save lesson',
            onPressed: _save,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _ContentTab(blocks: _blocks, onChanged: (blocks) => setState(() => _blocks = blocks)),
          _ExerciseTab(titleCtrl: _titleCtrl, descCtrl: _descCtrl, codeCtrl: _codeCtrl),
        ],
      ),
    );
  }
}

// ─── Tab 1: Theory / Content blocks ─────────────────────────────────────────

class _ContentTab extends StatefulWidget {
  final List<StudioContentBlock> blocks;
  final ValueChanged<List<StudioContentBlock>> onChanged;

  const _ContentTab({required this.blocks, required this.onChanged});

  @override
  State<_ContentTab> createState() => _ContentTabState();
}

class _ContentTabState extends State<_ContentTab> {
  late List<StudioContentBlock> _blocks;

  @override
  void initState() {
    super.initState();
    _blocks = List.of(widget.blocks);
  }

  void _notify() => widget.onChanged(List.of(_blocks));

  void _addBlock() {
    setState(() {
      _blocks.add(StudioContentBlock(type: 'text', content: ''));
    });
    _notify();
  }

  void _removeBlock(int index) {
    setState(() => _blocks.removeAt(index));
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _blocks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No content blocks yet.\nAdd headings, text, code snippets, or images.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _blocks.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final item = _blocks.removeAt(oldIndex);
                      _blocks.insert(newIndex, item);
                    });
                    _notify();
                  },
                  itemBuilder: (ctx, i) {
                    return _BlockEditor(
                      key: ValueKey('block_$i'),
                      block: _blocks[i],
                      index: i,
                      onChanged: (b) {
                        setState(() => _blocks[i] = b);
                        _notify();
                      },
                      onRemove: () => _removeBlock(i),
                    );
                  },
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              onPressed: _addBlock,
              icon: const Icon(Icons.add),
              label: const Text('Add Content Block'),
            ),
          ),
        ),
      ],
    );
  }
}

class _BlockEditor extends StatefulWidget {
  final StudioContentBlock block;
  final int index;
  final ValueChanged<StudioContentBlock> onChanged;
  final VoidCallback onRemove;

  const _BlockEditor({
    super.key,
    required this.block,
    required this.index,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_BlockEditor> createState() => _BlockEditorState();
}

class _BlockEditorState extends State<_BlockEditor> {
  late TextEditingController _ctrl;
  late String _type;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.block.content);
    _type = widget.block.type;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(StudioContentBlock(type: _type, content: _ctrl.text));
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'heading': return Icons.title;
      case 'code':    return Icons.code;
      case 'image':   return Icons.image;
      default:        return Icons.notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconForType(_type), size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _type,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'heading', child: Text('Heading')),
                    DropdownMenuItem(value: 'text',    child: Text('Text')),
                    DropdownMenuItem(value: 'code',    child: Text('Code')),
                    DropdownMenuItem(value: 'image',   child: Text('Image URL')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() { _type = v; _emit(); });
                  },
                ),
                const Spacer(),
                // drag handle
                const Icon(Icons.drag_handle, color: Colors.grey),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFE53935)),
                  onPressed: widget.onRemove,
                  tooltip: 'Remove block',
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              maxLines: _type == 'heading' ? 1 : (_type == 'image' ? 1 : 6),
              onChanged: (_) => _emit(),
              style: _type == 'code'
                  ? const TextStyle(fontFamily: 'monospace', fontSize: 13)
                  : _type == 'heading'
                      ? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      : null,
              decoration: InputDecoration(
                hintText: _type == 'heading' ? 'Section title...'
                    : _type == 'code'    ? '// Code snippet...'
                    : _type == 'image'   ? 'https://...'
                    : 'Write your explanation here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: _type == 'code',
                fillColor: _type == 'code'
                    ? (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F4F4))
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 2: Exercise (title, description, starter code) ──────────────────────

class _ExerciseTab extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final TextEditingController codeCtrl;

  const _ExerciseTab({
    required this.titleCtrl,
    required this.descCtrl,
    required this.codeCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: titleCtrl,
            decoration: InputDecoration(
              labelText: l10n.lessonTitle,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descCtrl,
            decoration: InputDecoration(
              labelText: l10n.description,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          Text(l10n.initialCodeTemplate,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: codeCtrl,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            maxLines: 15,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
