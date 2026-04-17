import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/studio_course.dart';
import '../providers/studio_state.dart';
import '../studio_theme.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';
import '../models/studio_challenge.dart';
import '../services/studio_judge.dart';
import 'package:flutter/services.dart';

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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: StudioTheme.creatorGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.school_rounded, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.courseCurriculum,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _addCourse(context),
                icon: const Icon(Icons.add_rounded, size: 18),
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
                                      label: const Text('Lesson'), 
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
  late final TextEditingController _solutionCtrl;
  late List<StudioContentBlock> _blocks;
  late String _lessonType;
  late List<StudioLessonTest> _tests;
  late List<StudioLessonFile> _files;
  late List<TestRunResult?> _results;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _tabs       = TabController(length: 2, vsync: this);
    _titleCtrl  = TextEditingController(text: widget.lesson.title);
    _descCtrl   = TextEditingController(text: widget.lesson.description);
    _codeCtrl   = TextEditingController(text: widget.lesson.initialCode);
    _solutionCtrl = TextEditingController(text: widget.lesson.solutionCode);
    _blocks     = List.of(widget.lesson.contentBlocks);
    _lessonType = widget.lesson.type;
    _tests      = List.of(widget.lesson.tests);
    _files      = List.of(widget.lesson.files);
    _results    = List.filled(_tests.length, null, growable: true);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _codeCtrl.dispose();
    _solutionCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.lesson.title        = _titleCtrl.text;
    widget.lesson.description  = _descCtrl.text;
    widget.lesson.initialCode  = _codeCtrl.text;
    widget.lesson.solutionCode = _solutionCtrl.text;
    widget.lesson.contentBlocks = List.of(_blocks);
    widget.lesson.type         = _lessonType;
    widget.lesson.tests        = List.of(_tests);
    widget.lesson.files        = List.of(_files);
    
    if (widget.isNew) {
      widget.course.lessons.add(widget.lesson);
    }
    context.read<StudioState>().saveCourse(widget.course);
    Navigator.pop(context);
  }

  Future<void> _runTests() async {
    setState(() => _running = true);
    final judge = StudioJudge();
    final stTests = _tests.map((lt) => StudioTestCase(input: lt.input, expectedOutput: lt.expectedOutput, isHidden: lt.isHidden)).toList();
    final stFiles = _files.map((lf) => StudioFile(name: lf.name, content: lf.content)).toList();
    final res = await judge.runAll(_solutionCtrl.text, widget.course.language, stTests, stFiles);
    setState(() {
      _results = List<TestRunResult?>.from(res, growable: true);
      _running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCodeExercise = _lessonType == 'code';
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: StudioTheme.creatorGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.isNew ? Icons.add_box_rounded : Icons.edit_note_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.isNew ? 'New Lesson' : 'Edit Lesson'),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_rounded), text: 'Content'),
            Tab(icon: Icon(Icons.code_rounded),      text: 'Exercise'),
          ],
        ),
        actions: [
          if (isCodeExercise)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: OutlinedButton.icon(
                onPressed: _running ? null : _runTests,
                icon: _running
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.play_arrow_rounded,
                        size: 18, color: StudioTheme.primaryCyan),
                label: const Text('Test Run',
                    style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ChoiceChip(
              label: Text(isCodeExercise ? 'Code' : 'Theory'),
              avatar: Icon(
                isCodeExercise ? Icons.code_rounded : Icons.menu_book_rounded,
                size: 16,
              ),
              selected: isCodeExercise,
              onSelected: (_) {
                setState(() {
                  _lessonType = isCodeExercise ? 'lesson' : 'code';
                });
              },
              selectedColor: StudioTheme.primaryCyan.withOpacity(0.2),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.save_rounded),
            tooltip: 'Save lesson',
            onPressed: _save,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _ContentTab(blocks: _blocks, onChanged: (blocks) => setState(() => _blocks = blocks)),
          _ExerciseTab(
            titleCtrl: _titleCtrl,
            descCtrl: _descCtrl,
            codeCtrl: _codeCtrl,
            solutionCtrl: _solutionCtrl,
            tests: _tests,
            files: _files,
            results: _results,
            isCodeExercise: isCodeExercise,
            onTestsChanged: (t) => setState(() {
              _tests = t;
              if (_results.length < t.length) {
                _results.add(null);
              } else if (_results.length > t.length) {
                _results.removeLast();
              }
            }),
            onFilesChanged: (f) => setState(() => _files = f),
          ),
        ],
      ),
    );
  }
}

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
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    : _type == 'code'    ? '// Code...'
                    : _type == 'image'   ? 'https://...'
                    : 'Text here… Use [label](url) or [label](algo:id) for links',
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

class _LessonFileRow extends StatefulWidget {
  final StudioLessonFile file;
  final VoidCallback onRemove;
  const _LessonFileRow({super.key, required this.file, required this.onRemove});
  @override
  State<_LessonFileRow> createState() => _LessonFileRowState();
}

class _LessonFileRowState extends State<_LessonFileRow> {
  late TextEditingController _nameCtrl;
  late TextEditingController _contentCtrl;
  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.file.name);
    _contentCtrl = TextEditingController(text: widget.file.content);
  }
  @override
  void dispose() {
    _nameCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    onChanged: (v) => widget.file.name = v,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.fileName,
                      hintText: "e.g. data.txt",
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: widget.onRemove,
                    color: Colors.red,
                    icon: const Icon(Icons.delete_outline, size: 20)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF23241f),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Focus(
                onKeyEvent: (node, event) {
                  if (event.logicalKey == LogicalKeyboardKey.tab && event is KeyDownEvent) {
                    final text = _contentCtrl.text;
                    final selection = _contentCtrl.selection;
                    if (selection.start >= 0 && selection.end >= 0) {
                      final newText = text.replaceRange(selection.start, selection.end, '    ');
                      _contentCtrl.value = TextEditingValue(
                        text: newText,
                        selection: TextSelection.collapsed(offset: selection.start + 4),
                      );
                      widget.file.content = newText;
                    }
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: _contentCtrl,
                  onChanged: (v) => widget.file.content = v,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: "File content goes here...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseTab extends StatefulWidget {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final TextEditingController codeCtrl;
  final TextEditingController solutionCtrl;
  final List<StudioLessonTest> tests;
  final List<StudioLessonFile> files;
  final List<TestRunResult?> results;
  final bool isCodeExercise;
  final ValueChanged<List<StudioLessonTest>> onTestsChanged;
  final ValueChanged<List<StudioLessonFile>> onFilesChanged;

  const _ExerciseTab({
    required this.titleCtrl,
    required this.descCtrl,
    required this.codeCtrl,
    required this.solutionCtrl,
    required this.tests,
    required this.files,
    required this.results,
    required this.isCodeExercise,
    required this.onTestsChanged,
    required this.onFilesChanged,
  });

  @override
  State<_ExerciseTab> createState() => _ExerciseTabState();
}

class _ExerciseTabState extends State<_ExerciseTab> {
  late List<StudioLessonTest> _tests;
  late List<StudioLessonFile> _files;

  @override
  void initState() {
    super.initState();
    _tests = widget.tests;
    _files = widget.files;
  }

  void _addTest() {
    setState(() {
      _tests.add(StudioLessonTest(input: '', expectedOutput: ''));
    });
    widget.onTestsChanged(_tests);
  }

  void _removeTest(int i) {
    setState(() => _tests.removeAt(i));
    widget.onTestsChanged(_tests);
  }

  void _addFile() {
    setState(() {
      _files.add(StudioLessonFile(name: '', content: ''));
    });
    widget.onFilesChanged(_files);
  }

  void _removeFile(int i) {
    setState(() => _files.removeAt(i));
    widget.onFilesChanged(_files);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final results = widget.results;
    final allPassed = results.isNotEmpty && results.every((r) => r?.passed == true);
    final anyRan = results.any((r) => r != null);
    final passCount = results.whereType<TestRunResult>().where((r) => r.passed).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: widget.titleCtrl,
            decoration: InputDecoration(
              labelText: l10n.lessonTitle,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.descCtrl,
            decoration: InputDecoration(
              labelText: l10n.description,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
          ),
          if (widget.isCodeExercise) ...[
            const SizedBox(height: 16),
            Text('Starter Template (Visible to Students)',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("This is the starting boilerplate the user sees.", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            TextField(
              controller: widget.codeCtrl,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              maxLines: 8,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            
            const SizedBox(height: 24),
            Text('Validation Solution (Hidden from Students)',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("This code is used internally for validation. Users in the Core app will NOT see it.", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            TextField(
              controller: widget.solutionCtrl,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              maxLines: 12,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.attach_file_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Provided Files', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addFile,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text("Files attached here are available to the user's code at runtime.", style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            ..._files.asMap().entries.map((e) => _LessonFileRow(
              key: ObjectKey(e.value),
              file: e.value,
              onRemove: () => _removeFile(e.key),
            )),

            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.science_rounded, size: 18,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Test Cases',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addTest,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),

            if (anyRan)
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: allPassed
                      ? StudioTheme.successGreen.withOpacity(0.08)
                      : StudioTheme.errorRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: allPassed
                        ? StudioTheme.successGreen.withOpacity(0.3)
                        : StudioTheme.errorRed.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      allPassed ? Icons.check_circle_rounded : Icons.error_rounded,
                      color: allPassed ? StudioTheme.successGreen : StudioTheme.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      allPassed
                          ? 'All ${_tests.length} tests passed!'
                          : '$passCount/${_tests.length} tests passed',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: allPassed ? StudioTheme.successGreen : StudioTheme.errorRed,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),
            ..._tests.asMap().entries.map((entry) {
              final i = entry.key;
              final test = entry.value;
              final res = i < results.length ? results[i] : null;
              Color? borderColor;
              if (res != null) {
                borderColor = res.passed ? StudioTheme.successGreen : StudioTheme.errorRed;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: borderColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                    width: borderColor != null ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Test ${i + 1}',
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          const Spacer(),
                          if (res != null)
                             Icon(
                               res.passed ? Icons.check_circle : Icons.cancel,
                               color: res.passed ? const Color(0xFF4CAF50) : Colors.red,
                               size: 20,
                             ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Hidden', style: TextStyle(fontSize: 12)),
                              Switch(
                                value: test.isHidden,
                                onChanged: (v) {
                                  setState(() => test.isHidden = v);
                                  widget.onTestsChanged(_tests);
                                },
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFE53935), size: 20),
                            onPressed: () => _removeTest(i),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Input',
                          hintText: 'stdin input...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F4F4),
                        ),
                        maxLines: 3,
                        controller: TextEditingController(text: test.input),
                        onChanged: (v) {
                          test.input = v;
                          widget.onTestsChanged(_tests);
                        },
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Expected Output',
                          hintText: 'stdout output...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F4F4),
                        ),
                        maxLines: 3,
                        controller: TextEditingController(text: test.expectedOutput),
                        onChanged: (v) {
                          test.expectedOutput = v;
                          widget.onTestsChanged(_tests);
                        },
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                      ),
                      if (res != null && !res.passed) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2C1315) : const Color(0xFFFDEDED),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                               const Text(
                                 'Actual Output:',
                                 style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                               ),
                               const SizedBox(height: 4),
                               Text(
                                 res.compileError != null && res.compileError!.isNotEmpty
                                     ? res.compileError!
                                     : res.error != null
                                         ? res.error!
                                         : res.actualOutput.isEmpty
                                             ? '(No output)'
                                             : res.actualOutput,
                                 style: const TextStyle(
                                   fontFamily: 'monospace',
                                   fontSize: 12,
                                   color: Colors.red,
                                 ),
                               ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ] else ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.15),
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.menu_book_rounded, size: 48,
                      color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Theory-only lesson',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No code editor or test cases.\nUse the Content tab to add theory blocks.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
