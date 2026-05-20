// Represent the type and content of a single lesson content block.
class StudioContentBlock {
  String type;
  String content;

  StudioContentBlock({this.type = 'text', this.content = ''});

  Map<String, dynamic> toJson() => {'type': type, 'content': content};

  // Deserialize a JSON map into a StudioContentBlock.
  factory StudioContentBlock.fromJson(Map<String, dynamic> json) {
    return StudioContentBlock(
      type: json['type'] ?? 'text',
      content: json['content'] ?? '',
    );
  }
}

// Store course details, including the ID, title, language, and ordered list of lessons.
class StudioCourse {
  String id;
  String title;
  String description;
  String language;
  List<StudioLesson> lessons;

  StudioCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.language,
    this.lessons = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'language': language,
        'lessons': lessons.map((l) => l.toJson()).toList(),
      };

  // Deserialize a JSON map and a document ID into a StudioCourse.
  factory StudioCourse.fromJson(String id, Map<String, dynamic> json) {
    return StudioCourse(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      language: json['language'] ?? 'cpp',
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((l) => StudioLesson.fromJson(l))
              .toList() ??
          [],
    );
  }
}

// Store lesson details, including the code, tests, content blocks, and execution limits.
class StudioLesson {
  String id;
  String title;
  String type;
  String description;
  String initialCode;
  String solutionCode;
  String successMascot;
  String failMascot;
  List<StudioLessonTest> tests;
  List<StudioLessonFile> files;
  List<StudioContentBlock> contentBlocks;
  int? memoryLimitMb;
  int? timeLimitMs;

  StudioLesson({
    required this.id,
    required this.title,
    this.type = 'code',
    required this.description,
    required this.initialCode,
    this.solutionCode = '',
    this.successMascot = 'thumbs-up-4b8ec7e7-360.webm',
    this.failMascot = 'thinking-hard-e507f346-360.webm',
    this.tests = const [],
    this.files = const [],
    this.contentBlocks = const [],
    this.memoryLimitMb,
    this.timeLimitMs,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type,
        'initial_code': initialCode,
        'solution_code': solutionCode,
        'success_mascot': successMascot,
        'fail_mascot': failMascot,
        'tests': tests.map((t) => t.toJson()).toList(),
        'files': files.map((f) => f.toJson()).toList(),
        'content_blocks': contentBlocks.map((b) => b.toJson()).toList(),
        if (memoryLimitMb != null) 'memory_limit_mb': memoryLimitMb,
        if (timeLimitMs != null) 'time_limit_ms': timeLimitMs,
      };

  // Deserialize a JSON map into a StudioLesson.
  factory StudioLesson.fromJson(Map<String, dynamic> json) {
    return StudioLesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? 'code',
      description: json['description'] ?? '',
      initialCode: json['initial_code'] ?? '',
      solutionCode: json['solution_code'] ?? '',
      successMascot: json['success_mascot'] ?? 'thumbs-up-4b8ec7e7-360.webm',
      failMascot: json['fail_mascot'] ?? 'thinking-hard-e507f346-360.webm',
      tests: (json['tests'] as List<dynamic>?)
              ?.map((t) => StudioLessonTest.fromJson(t))
              .toList() ??
          [],
      files: (json['files'] as List<dynamic>?)
              ?.map((f) => StudioLessonFile.fromJson(f))
              .toList() ??
          [],
      contentBlocks: (json['content_blocks'] as List<dynamic>?)
              ?.map((b) => StudioContentBlock.fromJson(b))
              .toList() ??
          [],
      memoryLimitMb: json['memory_limit_mb'] as int?,
      timeLimitMs: json['time_limit_ms'] as int?,
    );
  }
}

// Represent a test case for a lesson, including input, expected output, and a hidden flag.
class StudioLessonTest {
  String input;
  String expectedOutput;
  bool isHidden;

  StudioLessonTest({
    required this.input,
    required this.expectedOutput,
    this.isHidden = false,
  });

  Map<String, dynamic> toJson() => {
        'input': input,
        'expected_output': expectedOutput,
        'is_hidden': isHidden,
      };

  // Deserialize a JSON map into a StudioLessonTest.
  factory StudioLessonTest.fromJson(Map<String, dynamic> json) {
    return StudioLessonTest(
      input: json['input'] ?? '',
      expectedOutput: json['expected_output'] ?? '',
      isHidden: json['is_hidden'] == true,
    );
  }
}

// Store the name and content of an extra file attached to a lesson.
class StudioLessonFile {
  String name;
  String content;

  StudioLessonFile({
    required this.name,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'content': content,
      };

  // Deserialize a JSON map into a StudioLessonFile.
  factory StudioLessonFile.fromJson(Map<String, dynamic> json) {
    return StudioLessonFile(
      name: json['name'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
