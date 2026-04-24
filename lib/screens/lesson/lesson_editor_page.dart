// Provide interface for editing theory blocks and challenge associations.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course/studio_course.dart';
import '../../providers/studio/studio_state.dart';
import '../../theme/studio_theme.dart';
import '../../widgets/glass/glass_app_bar.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';
import '../../models/challenge/studio_challenge.dart';
import '../../services/judge/studio_judge.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

// Render layout and manage state for Lesson Editor Page.
class LessonEditorPage extends StatefulWidget {
  final StudioCourse course;
  final StudioLesson lesson;
  final bool isNew;

  const LessonEditorPage({
    super.key,
    required this.course,
    required this.lesson,
    required this.isNew,
  });

  @override
  State<LessonEditorPage> createState() => LessonEditorPageState();
}

// Manage state and provide providers for Lesson Editor Page State.
class LessonEditorPageState extends State<LessonEditorPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _solutionCtrl;
  late final TextEditingController _timeLimitCtrl;
  late final TextEditingController _memoryLimitCtrl;
  late List<StudioContentBlock> _blocks;
  late String _lessonType;
  late List<StudioLessonTest> _tests;
  late List<StudioLessonFile> _files;
  late List<TestRunResult?> _results;
  bool _running = false;

  String get _effectiveType {
    if (_lessonType == 'mixed') return 'mixed';
    if (_lessonType == 'lesson') return 'lesson';
    return 'code';
  }

  int get _tabCount => 2;

  void _rebuildTabs() {
    final newCount = _tabCount;
    if (_tabs.length != newCount) {
      _tabs.dispose();
      _tabs = TabController(length: newCount, vsync: this);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _tabCount, vsync: this);
    _titleCtrl = TextEditingController(text: widget.lesson.title);
    _descCtrl = TextEditingController(text: widget.lesson.description);
    _codeCtrl = TextEditingController(text: widget.lesson.initialCode);
    _solutionCtrl = TextEditingController(text: widget.lesson.solutionCode);
    _timeLimitCtrl = TextEditingController(
        text: widget.lesson.timeLimitMs?.toString() ?? '');
    _memoryLimitCtrl = TextEditingController(
        text: widget.lesson.memoryLimitMb?.toString() ?? '');
    _blocks = List.of(widget.lesson.contentBlocks);
    _lessonType = widget.lesson.type;
    _tests = List.of(widget.lesson.tests);
    _files = List.of(widget.lesson.files);
    _results = List.filled(_tests.length, null, growable: true);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _codeCtrl.dispose();
    _solutionCtrl.dispose();
    _timeLimitCtrl.dispose();
    _memoryLimitCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.lesson.title = _titleCtrl.text;
    widget.lesson.description = _descCtrl.text;
    widget.lesson.initialCode = _codeCtrl.text;
    widget.lesson.solutionCode = _solutionCtrl.text;
    widget.lesson.contentBlocks = List.of(_blocks);
    widget.lesson.type = _lessonType;
    widget.lesson.tests = List.of(_tests);
    widget.lesson.files = List.of(_files);
    widget.lesson.timeLimitMs = int.tryParse(_timeLimitCtrl.text);
    widget.lesson.memoryLimitMb = int.tryParse(_memoryLimitCtrl.text);

    if (widget.isNew) {
      widget.course.lessons.add(widget.lesson);
    }
    context.read<StudioState>().saveCourse(widget.course);
    Navigator.pop(context);
  }

  Future<void> _runTests() async {
    setState(() => _running = true);
    final judge = StudioJudge();
    final stTests = _tests
        .map((lt) => StudioTestCase(
            input: lt.input,
            expectedOutput: lt.expectedOutput,
            isHidden: lt.isHidden))
        .toList();
    final stFiles = _files
        .map((lf) => StudioFile(name: lf.name, content: lf.content))
        .toList();
    final res = await judge.runAll(
      _solutionCtrl.text,
      widget.course.language,
      stTests,
      stFiles,
      timeLimitMs: int.tryParse(_timeLimitCtrl.text),
      memoryLimitMb: int.tryParse(_memoryLimitCtrl.text),
    );
    setState(() {
      _results = List<TestRunResult?>.from(res, growable: true);
      _running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isCodeExercise = _effectiveType != 'lesson';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Tab> tabs = [
      const Tab(icon: Icon(Icons.menu_book_rounded), text: 'Content'),
      const Tab(icon: Icon(Icons.code_rounded), text: 'Exercise'),
    ];

    final Color typeBadgeColor = _effectiveType == 'lesson'
        ? StudioTheme.accentPurple
        : _effectiveType == 'mixed'
            ? const Color(0xFFFFD740)
            : StudioTheme.primaryCyan;
    final String typeBadgeLabel = _effectiveType == 'lesson'
        ? 'Theory'
        : _effectiveType == 'mixed'
            ? 'Mixed'
            : 'Code';
    final IconData typeBadgeIcon = _effectiveType == 'lesson'
        ? Icons.menu_book_rounded
        : _effectiveType == 'mixed'
            ? Icons.auto_awesome_rounded
            : Icons.code_rounded;

    _rebuildTabs();

    final double topPad =
        MediaQuery.of(context).padding.top + kToolbarHeight + 48.0;

    final tabBar = TabBar(
      controller: _tabs,
      tabs: tabs,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: StudioTheme.creatorGradient,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: StudioTheme.accentPurple.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                widget.isNew ? Icons.add_box_rounded : Icons.edit_note_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.isNew ? 'New Lesson' : 'Edit Lesson'),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: typeBadgeColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: typeBadgeColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(typeBadgeIcon, size: 11, color: typeBadgeColor),
                  const SizedBox(width: 4),
                  Text(
                    typeBadgeLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: typeBadgeColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: tabBar,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            tooltip: 'Save lesson',
            onPressed: _save,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              if (val == 'test' && !_running) _runTests();
              if (val == 'type_lesson')
                setState(() {
                  _lessonType = 'lesson';
                  _rebuildTabs();
                });
              if (val == 'type_code')
                setState(() {
                  _lessonType = 'code';
                  _rebuildTabs();
                });
              if (val == 'type_mixed')
                setState(() {
                  _lessonType = 'mixed';
                  _rebuildTabs();
                });
            },
            itemBuilder: (ctx) => [
              if (isCodeExercise)
                PopupMenuItem(
                  value: 'test',
                  child: Row(
                    children: [
                      _running
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(Icons.play_arrow_rounded,
                              color: StudioTheme.primaryCyan, size: 20),
                      const SizedBox(width: 12),
                      Text(l.testRun),
                    ],
                  ),
                ),
              const PopupMenuItem(
                enabled: false,
                height: 28,
                child: Text('Lesson type',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              PopupMenuItem(
                value: 'type_lesson',
                child: Row(children: [
                  Icon(Icons.menu_book_rounded,
                      size: 18,
                      color: _effectiveType == 'lesson'
                          ? StudioTheme.accentPurple
                          : null),
                  const SizedBox(width: 10),
                  const Text('Theory only'),
                  if (_effectiveType == 'lesson') ...[
                    const Spacer(),
                    Icon(Icons.check_rounded,
                        size: 16, color: StudioTheme.accentPurple),
                  ],
                ]),
              ),
              PopupMenuItem(
                value: 'type_code',
                child: Row(children: [
                  Icon(Icons.code_rounded,
                      size: 18,
                      color: _effectiveType == 'code'
                          ? StudioTheme.primaryCyan
                          : null),
                  const SizedBox(width: 10),
                  const Text('Code only'),
                  if (_effectiveType == 'code') ...[
                    const Spacer(),
                    Icon(Icons.check_rounded,
                        size: 16, color: StudioTheme.primaryCyan),
                  ],
                ]),
              ),
              PopupMenuItem(
                value: 'type_mixed',
                child: Row(children: [
                  Icon(Icons.auto_awesome_rounded,
                      size: 18,
                      color: _effectiveType == 'mixed'
                          ? const Color(0xFFFFD740)
                          : null),
                  const SizedBox(width: 10),
                  const Text('Mixed (Theory + Code)'),
                  if (_effectiveType == 'mixed') ...[
                    const Spacer(),
                    const Icon(Icons.check_rounded,
                        size: 16, color: Color(0xFFFFD740)),
                  ],
                ]),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: StudioTheme.meshBackground(isDark: isDark),
        child: TabBarView(
          controller: _tabs,
          children: [
            ContentTab(
              blocks: _blocks,
              onChanged: (blocks) => setState(() => _blocks = blocks),
              topPad: topPad,
            ),
            ExerciseTab(
              titleCtrl: _titleCtrl,
              descCtrl: _descCtrl,
              codeCtrl: _codeCtrl,
              solutionCtrl: _solutionCtrl,
              timeLimitCtrl: _timeLimitCtrl,
              memoryLimitCtrl: _memoryLimitCtrl,
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
              topPad: topPad,
            ),
          ],
        ),
      ),
    );
  }
}

// Render the content block editor tab for a lesson.
class ContentTab extends StatefulWidget {
  final List<StudioContentBlock> blocks;
  final ValueChanged<List<StudioContentBlock>> onChanged;
  final double topPad;

  const ContentTab({
    super.key,
    required this.blocks,
    required this.onChanged,
    required this.topPad,
  });

  @override
  State<ContentTab> createState() => ContentTabState();
}

// Manage state and provide providers for Content Tab State.
class ContentTabState extends State<ContentTab> {
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
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        Expanded(
          child: _blocks.isEmpty
              ? Padding(
                  padding: EdgeInsets.only(top: widget.topPad),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No content blocks yet.\nAdd headings, text, code snippets, or images.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  padding: EdgeInsets.fromLTRB(16, widget.topPad + 16, 16, 16),
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
                    return BlockEditor(
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
              label: Text(l.addContentBlock),
            ),
          ),
        ),
      ],
    );
  }
}

// Render the editor for a single content block.
class BlockEditor extends StatefulWidget {
  final StudioContentBlock block;
  final int index;
  final ValueChanged<StudioContentBlock> onChanged;
  final VoidCallback onRemove;

  const BlockEditor({
    super.key,
    required this.block,
    required this.index,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<BlockEditor> createState() => BlockEditorState();
}

// // manages state and provides providers for Block Editor State
class BlockEditorState extends State<BlockEditor> {
  // Store the text controller for generic block contents.
  late TextEditingController _ctrl;
  // Store the content block type.
  late String _type;

  // Store the text controller for the quiz question text.
  late TextEditingController _questionCtrl;
  // Store the list of text controllers for the quiz option texts.
  final List<TextEditingController> _optionCtrls = [];
  // Store the list of text controllers for option-specific explanations when incorrect.
  final List<TextEditingController> _optionExplanationCtrls = [];
  // Store the correct index for a single-choice quiz.
  int _correctIndex = 0;
  // Toggle multiple-choice mode for quiz block.
  bool _isMultipleChoice = false;
  // Store all correct indices for a multiple-choice quiz.
  List<int> _correctIndices = [];
  // Store the text controller for the incorrect answer explanation text.
  late TextEditingController _explanationCtrl;


  // Initialize controller states and structures.
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.block.content);
    _questionCtrl = TextEditingController();
    _explanationCtrl = TextEditingController();
    _type = widget.block.type;
    if (_type == 'quiz') {
      _initQuizControllers();
    }
  }

  // Update controllers dynamically on widget changes to prevent cursor jumps.
  @override
}