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
  void didUpdateWidget(covariant BlockEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.block.type != oldWidget.block.type) {
      _type = widget.block.type;
      if (_type == 'quiz') {
        _initQuizControllers();
      } else {
        _ctrl.text = widget.block.content;
      }
    } else if (widget.block.content != oldWidget.block.content) {
      if (_type != 'quiz') {
        if (_ctrl.text != widget.block.content) {
          _ctrl.text = widget.block.content;
        }
      } else {
        try {
          final data = jsonDecode(widget.block.content) as Map<String, dynamic>;
          final question = data['question']?.toString() ?? '';
          final optionsRaw = data['options'] as List<dynamic>?;
          final options = optionsRaw?.map((e) => e.toString()).toList() ?? [];
          final correctIndex = data['correctIndex'] as int? ?? 0;
          // Sync multiple-choice fields with backward compatibility.
          final isMultipleChoice = data['isMultipleChoice'] as bool? ?? false;
          final correctIndices = data['correctIndices'] != null
              ? List<int>.from(data['correctIndices'])
              : [correctIndex];
          final explanation = data['explanation']?.toString() ?? '';
          final explanationsRaw = data['explanations'] as List<dynamic>?;
          final explanations = explanationsRaw?.map((e) => e.toString()).toList() ?? [];
          while (explanations.length < options.length) {
            explanations.add('');
          }

          if (_questionCtrl.text != question) {
            _questionCtrl.text = question;
          }
          if (_correctIndex != correctIndex) {
            _correctIndex = correctIndex;
          }
          if (_isMultipleChoice != isMultipleChoice) {
            _isMultipleChoice = isMultipleChoice;
          }
          if (_correctIndices.join(',') != correctIndices.join(',')) {
            _correctIndices = correctIndices;
          }
          if (_explanationCtrl.text != explanation) {
            _explanationCtrl.text = explanation;
          }

          bool optionsChanged = _optionCtrls.length != options.length;
          if (!optionsChanged) {
            for (int i = 0; i < _optionCtrls.length; i++) {
              if (_optionCtrls[i].text != options[i]) {
                optionsChanged = true;
                break;
              }
            }
          }

          if (optionsChanged) {
            if (_optionCtrls.length == options.length) {
              for (int i = 0; i < _optionCtrls.length; i++) {
                if (_optionCtrls[i].text != options[i]) {
                  _optionCtrls[i].text = options[i];
                }
              }
            } else {
              for (var ctrl in _optionCtrls) {
                ctrl.dispose();
              }
              _optionCtrls.clear();
              for (var opt in options) {
                _optionCtrls.add(TextEditingController(text: opt));
              }
            }
          }

          bool explanationsChanged = _optionExplanationCtrls.length != explanations.length;
          if (!explanationsChanged) {
            for (int i = 0; i < _optionExplanationCtrls.length; i++) {
              if (_optionExplanationCtrls[i].text != explanations[i]) {
                explanationsChanged = true;
                break;
              }
            }
          }

          if (explanationsChanged) {
            if (_optionExplanationCtrls.length == explanations.length) {
              for (int i = 0; i < _optionExplanationCtrls.length; i++) {
                if (_optionExplanationCtrls[i].text != explanations[i]) {
                  _optionExplanationCtrls[i].text = explanations[i];
                }
              }
            } else {
              for (var ctrl in _optionExplanationCtrls) {
                ctrl.dispose();
              }
              _optionExplanationCtrls.clear();
              for (var exp in explanations) {
                _optionExplanationCtrls.add(TextEditingController(text: exp));
              }
            }
          }
        } catch (_) {}
      }
    }
  }

  // Dispose of all text controllers to avoid memory leaks.
  @override
  void dispose() {
    _ctrl.dispose();
    _questionCtrl.dispose();
    _explanationCtrl.dispose();
    for (var ctrl in _optionCtrls) {
      ctrl.dispose();
    }
    for (var ctrl in _optionExplanationCtrls) {
      ctrl.dispose();
    }
    super.dispose();
  }

  // Parse quiz content from block and populate the text controllers.
  void _initQuizControllers() {
    Map<String, dynamic> data = {};
    try {
      if (widget.block.content.isNotEmpty) {
        data = jsonDecode(widget.block.content) as Map<String, dynamic>;
      }
    } catch (_) {}

    final question = data['question']?.toString() ?? '';
    final optionsRaw = data['options'] as List<dynamic>?;
    final options = optionsRaw?.map((e) => e.toString()).toList() ?? ['', ''];
    final correctIndex = data['correctIndex'] as int? ?? 0;
    // Parse multiple-choice fields with backward compatibility.
    final isMultipleChoice = data['isMultipleChoice'] as bool? ?? false;
    final correctIndices = data['correctIndices'] != null
        ? List<int>.from(data['correctIndices'])
        : [correctIndex];
    final explanation = data['explanation']?.toString() ?? '';
    final explanationsRaw = data['explanations'] as List<dynamic>?;
    final explanations = explanationsRaw?.map((e) => e.toString()).toList() ?? [];
    while (explanations.length < options.length) {
      explanations.add('');
    }

    _questionCtrl.text = question;
    _correctIndex = correctIndex;
    _isMultipleChoice = isMultipleChoice;
    _correctIndices = correctIndices;
    _explanationCtrl.text = explanation;

    for (var ctrl in _optionCtrls) {
      ctrl.dispose();
    }
    _optionCtrls.clear();
    for (var opt in options) {
      _optionCtrls.add(TextEditingController(text: opt));
    }

    for (var ctrl in _optionExplanationCtrls) {
      ctrl.dispose();
    }
    _optionExplanationCtrls.clear();
    for (var exp in explanations) {
      _optionExplanationCtrls.add(TextEditingController(text: exp));
    }
  }

  // Serialize state changes back to block content field.
  void _emit() {
    if (_type == 'quiz') {
      final data = {
        'question': _questionCtrl.text,
        'options': _optionCtrls.map((c) => c.text).toList(),
        'correctIndex': _isMultipleChoice ? (_correctIndices.isNotEmpty ? _correctIndices.first : 0) : _correctIndex,
        // Save multiple-choice mode and all correct indices.
        'isMultipleChoice': _isMultipleChoice,
        'correctIndices': _isMultipleChoice ? _correctIndices : [_correctIndex],
        'explanation': _explanationCtrl.text,
        'explanations': _optionExplanationCtrls.map((c) => c.text).toList(),
      };
      widget.onChanged(StudioContentBlock(type: _type, content: jsonEncode(data)));
    } else {
      widget.onChanged(StudioContentBlock(type: _type, content: _ctrl.text));
    }
  }

  // Handle block type transition behavior.
  void _onTypeChanged(String newType) {
    if (newType == 'quiz' && _type != 'quiz') {
      _type = newType;
      final oldText = _ctrl.text;
      _questionCtrl.text = oldText;
      _correctIndex = 0;
      // Reset multiple-choice state on type change.
      _isMultipleChoice = false;
      _correctIndices = [0];
      _explanationCtrl.text = '';
      for (var ctrl in _optionCtrls) {
        ctrl.dispose();
      }
      _optionCtrls.clear();
      _optionCtrls.add(TextEditingController(text: ''));
      _optionCtrls.add(TextEditingController(text: ''));

      for (var ctrl in _optionExplanationCtrls) {
        ctrl.dispose();
      }
      _optionExplanationCtrls.clear();
      _optionExplanationCtrls.add(TextEditingController(text: ''));
      _optionExplanationCtrls.add(TextEditingController(text: ''));
      _emit();
    } else if (newType != 'quiz' && _type == 'quiz') {
      _type = newType;
      _ctrl.text = _questionCtrl.text;
      _emit();
    } else {
      _type = newType;
      _emit();
    }
  }

  // Return matching icon based on the content block type.
  IconData _iconForType(String type) {
    switch (type) {
      case 'heading':
        return Icons.title;
      case 'code':
        return Icons.code;
      case 'image':
        return Icons.image;
      case 'quiz':
        return Icons.quiz_rounded;
      default:
        return Icons.notes;
    }
  }

  // Render BlockEditor widget layout.
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
                Icon(_iconForType(_type),
                     size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _type,
                  underline: const SizedBox(),
                  items: [
                    DropdownMenuItem(
                        value: 'heading', child: Text(l.blockHeading)),
                    DropdownMenuItem(value: 'text', child: Text(l.blockText)),
                    DropdownMenuItem(value: 'code', child: Text(l.blockCode)),
                    DropdownMenuItem(
                        value: 'image', child: Text(l.blockImageURL)),
                    DropdownMenuItem(
                        value: 'quiz', child: Text(l.blockQuiz)),
                  ],
                  onChanged: (v) {
                    if (v != null)
                      setState(() {
                        _onTypeChanged(v);
                      });
                  },
                ),
                const Spacer(),
                const Icon(Icons.drag_handle, color: Colors.grey),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Color(0xFFE53935)),
                  onPressed: widget.onRemove,
                  tooltip: 'Remove block',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_type == 'quiz') ...[
              // Render quiz question input field.
              TextField(
                controller: _questionCtrl,
                maxLines: 2,
                onChanged: (_) => _emit(),
                decoration: InputDecoration(
                  labelText: l.quizQuestion,
                  hintText: l.enterQuestionText,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              // Render multiple choice toggle switch.
              Row(
                children: [
                  Text(
                    l.multipleChoice,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isMultipleChoice,
                    onChanged: (val) {
                      setState(() {
                        _isMultipleChoice = val;
                        if (!val) {
                          // Reset to single-choice when toggled off.
                          _correctIndices = [_correctIndex];
                        } else {
                          // Seed correctIndices from current single selection.
                          _correctIndices = [_correctIndex];
                        }
                        _emit();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Render localized option selection label.
              Text(
                l.optionsSelectCorrect,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              // Render dynamic list of quiz option text inputs with correct option selection.
              ...List.generate(_optionCtrls.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (_isMultipleChoice)
                            // Render checkbox for multiple-choice correct answer selection.
                            Checkbox(
                              value: _correctIndices.contains(index),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    if (!_correctIndices.contains(index)) _correctIndices.add(index);
                                  } else {
                                    _correctIndices.remove(index);
                                  }
                                  _emit();
                                });
                              },
                            )
                          else
                            // Render radio button for single-choice correct answer selection.
                            Radio<int>(
                              value: index,
                              groupValue: _correctIndex,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _correctIndex = val;
                                    _emit();
                                  });
                                }
                              },
                            ),
                          Expanded(
                            // Input text for a single quiz option.
                            child: TextField(
                              controller: _optionCtrls[index],
                              onChanged: (_) => _emit(),
                              decoration: InputDecoration(
                                labelText: l.optionLabel(index + 1),
                                hintText: l.enterOptionText,
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          if (_optionCtrls.length > 2) ...[
                            const SizedBox(width: 8),
                            // Remove quiz option and clean up selection state.
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  final ctrl = _optionCtrls.removeAt(index);
                                  ctrl.dispose();
                                  final expCtrl = _optionExplanationCtrls.removeAt(index);
                                  expCtrl.dispose();
                                  if (_correctIndex >= _optionCtrls.length) {
                                    _correctIndex = _optionCtrls.length - 1;
                                  }
                                  _correctIndices.remove(index);
                                  // Remap indices above removed index.
                                  _correctIndices = _correctIndices
                                      .map((i) => i > index ? i - 1 : i)
                                      .toList();
                                  _emit();
                                });
                              },
                              tooltip: l.removeOption,
                            ),
                          ],
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 48.0, top: 4.0, right: 48.0),
                        child: TextField(
                          controller: _optionExplanationCtrls[index],
                          onChanged: (_) => _emit(),
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: l.quizOptionExplanationHint,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (_optionCtrls.length < 6) ...[
                const SizedBox(height: 4),
                // Add quiz option.
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l.addOption),
                  onPressed: () {
                    setState(() {
                      _optionCtrls.add(TextEditingController());
                      _optionExplanationCtrls.add(TextEditingController());
                      _emit();
                    });
                  },
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _explanationCtrl,
                maxLines: 2,
                onChanged: (_) => _emit(),
                decoration: InputDecoration(
                  labelText: l.quizExplanation,
                  hintText: l.quizExplanationHint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ] else ...[
              // Input generic content for non-quiz blocks.
              TextField(
                controller: _ctrl,
                maxLines: _type == 'heading' ? 1 : (_type == 'image' ? 1 : 6),
                onChanged: (_) => _emit(),
                style: _type == 'code'
                    ? const TextStyle(fontFamily: 'monospace', fontSize: 13)
                    : _type == 'heading'
                        ? const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)
                        : null,
                decoration: InputDecoration(
                  hintText: _type == 'heading'
                      ? 'Section title...'
                      : _type == 'code'
                          ? '// Code...'
                          : _type == 'image'
                              ? 'https://...'
                              : 'Text here… Use [label](url) or [label](algo:id) for links',
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: _type == 'code',
                  fillColor: _type == 'code'
                      ? (isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFF4F4F4))
                      : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Provide interface component for Lesson File Row.
class LessonFileRow extends StatefulWidget {
  final StudioLessonFile file;
  final VoidCallback onRemove;

  const LessonFileRow({super.key, required this.file, required this.onRemove});

  @override
  State<LessonFileRow> createState() => LessonFileRowState();
}

// Manage state and provide providers for Lesson File Row State.
class LessonFileRowState extends State<LessonFileRow> {
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12),
                    ),
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
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
                  if (event.logicalKey == LogicalKeyboardKey.tab &&
                      event is KeyDownEvent) {
                    final text = _contentCtrl.text;
                    final selection = _contentCtrl.selection;
                    if (selection.start >= 0 && selection.end >= 0) {
                      final newText = text.replaceRange(
                          selection.start, selection.end, '    ');
                      _contentCtrl.value = TextEditingValue(
                        text: newText,
                        selection: TextSelection.collapsed(
                            offset: selection.start + 4),
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

// Exercise definition and initialization
class ExerciseTab extends StatefulWidget {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final TextEditingController codeCtrl;
  final TextEditingController solutionCtrl;
  final TextEditingController memoryLimitCtrl;
  final TextEditingController timeLimitCtrl;
  final List<StudioLessonTest> tests;
  final List<StudioLessonFile> files;
  final List<TestRunResult?> results;
  final bool isCodeExercise;
  final ValueChanged<List<StudioLessonTest>> onTestsChanged;
  final ValueChanged<List<StudioLessonFile>> onFilesChanged;
  final double topPad;

  const ExerciseTab({
    super.key,
    required this.titleCtrl,
    required this.descCtrl,
    required this.codeCtrl,
    required this.solutionCtrl,
    required this.memoryLimitCtrl,
    required this.timeLimitCtrl,
    required this.tests,
    required this.files,
    required this.results,
    required this.isCodeExercise,
    required this.onTestsChanged,
    required this.onFilesChanged,
    required this.topPad,
  });

  @override
  State<ExerciseTab> createState() => ExerciseTabState();
}

// Exercise definition and initialization
class ExerciseTabState extends State<ExerciseTab> {
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
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final results = widget.results;
    final allPassed =
        results.isNotEmpty && results.every((r) => r?.passed == true);
    final anyRan = results.any((r) => r != null);
    final passCount =
        results.whereType<TestRunResult>().where((r) => r.passed).length;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, widget.topPad + 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: widget.titleCtrl,
            decoration: InputDecoration(
              labelText: l.lessonTitle,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.descCtrl,
            decoration: InputDecoration(
              labelText: l.description,
              hintText: 'Supports **markdown** formatting',
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: null,
            minLines: 3,
          ),
          if (widget.isCodeExercise) ...[
            const SizedBox(height: 16),
            const Text('Starter Template (Visible to Students)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("This is the starting boilerplate the user sees.",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            TextField(
              controller: widget.codeCtrl,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              maxLines: 8,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 24),
            const Text('Validation Solution (Hidden from Students)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text(
                "This code is used internally for validation. Users in the Core app will NOT see it.",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic)),
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
                Expanded(
                  child: TextField(
                    controller: widget.timeLimitCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Time Limit (ms)',
                      hintText: 'e.g. 2000',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: widget.memoryLimitCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Memory Limit (MB)',
                      hintText: 'e.g. 256',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.attach_file_rounded,
                    size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Provided Files',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addFile,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l.add),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
                "Files attached here are available to the user's code at runtime.",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            ..._files.asMap().entries.map((e) => LessonFileRow(
                  key: ObjectKey(e.value),
                  file: e.value,
                  onRemove: () => _removeFile(e.key),
                )),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.science_rounded,
                    size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Test Cases',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addTest,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l.add),
                ),
              ],
            ),
            if (anyRan)
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      allPassed
                          ? Icons.check_circle_rounded
                          : Icons.error_rounded,
                      color: allPassed
                          ? StudioTheme.successGreen
                          : StudioTheme.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      allPassed
                          ? 'All ${_tests.length} tests passed!'
                          : '$passCount/${_tests.length} tests passed',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: allPassed
                            ? StudioTheme.successGreen
                            : StudioTheme.errorRed,
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
                borderColor = res.passed
                    ? StudioTheme.successGreen
                    : StudioTheme.errorRed;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: borderColor ??
                        (isDark ? Colors.grey[800]! : Colors.grey[300]!),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          const Spacer(),
                          if (res != null)
                            Icon(
                              res.passed ? Icons.check_circle : Icons.cancel,
                              color: res.passed
                                  ? const Color(0xFF4CAF50)
                                  : Colors.red,
                              size: 20,
                            ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Hidden',
                                  style: TextStyle(fontSize: 12)),
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
                            icon: const Icon(Icons.delete_outline,
                                color: Color(0xFFE53935), size: 20),
                            onPressed: () => _removeTest(i),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Input',
                          hintText: 'stdin input...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF1E1E1E)
                              : const Color(0xFFF4F4F4),
                        ),
                        maxLines: 3,
                        controller: TextEditingController(text: test.input),
                        onChanged: (v) {
                          test.input = v;
                          widget.onTestsChanged(_tests);
                        },
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Expected Output',
                          hintText: 'stdout output...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF1E1E1E)
                              : const Color(0xFFF4F4F4),
                        ),
                        maxLines: 3,
                        controller:
                            TextEditingController(text: test.expectedOutput),
                        onChanged: (v) {
                          test.expectedOutput = v;
                          widget.onTestsChanged(_tests);
                        },
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 13),
                      ),
                      if (res != null && !res.passed) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2C1315)
                                : const Color(0xFFFDEDED),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Actual Output:',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                res.compileError != null &&
                                        res.compileError!.isNotEmpty
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
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.grey.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.grey.withOpacity(0.15),
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.menu_book_rounded,
                      size: 48,
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
