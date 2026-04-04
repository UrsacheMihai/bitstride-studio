class StudioContentBlock {
  String type;    // 'heading' | 'text' | 'code' | 'image'
  String content;

  StudioContentBlock({this.type = 'text', this.content = ''});

  Map<String, dynamic> toJson() => {'type': type, 'content': content};

  factory StudioContentBlock.fromJson(Map<String, dynamic> json) {
    return StudioContentBlock(
      type: json['type'] ?? 'text',
      content: json['content'] ?? '',
    );
  }
}

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

class StudioLesson {
  String id;
  String title;
  String description;
  String initialCode;
  String successMascot;
  String failMascot;
  List<StudioLessonTest> tests;
  List<StudioLessonFile> files;
  List<StudioContentBlock> contentBlocks;

  StudioLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.initialCode,
    this.successMascot = 'brain-celebrate.gif',
    this.failMascot = 'brain-crying.gif',
    this.tests = const [],
    this.files = const [],
    this.contentBlocks = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': 'code',
        'initial_code': initialCode,
        'success_mascot': successMascot,
        'fail_mascot': failMascot,
        'tests': tests.map((t) => t.toJson()).toList(),
        'files': files.map((f) => f.toJson()).toList(),
        'content_blocks': contentBlocks.map((b) => b.toJson()).toList(),
      };

  factory StudioLesson.fromJson(Map<String, dynamic> json) {
    return StudioLesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      initialCode: json['initial_code'] ?? '',
      successMascot: json['success_mascot'] ?? 'brain-celebrate.gif',
      failMascot: json['fail_mascot'] ?? 'brain-crying.gif',
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
    );
  }
}

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

  factory StudioLessonTest.fromJson(Map<String, dynamic> json) {
    return StudioLessonTest(
      input: json['input'] ?? '',
      expectedOutput: json['expected_output'] ?? '',
      isHidden: json['is_hidden'] == true,
    );
  }
}

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

  factory StudioLessonFile.fromJson(Map<String, dynamic> json) {
    return StudioLessonFile(
      name: json['name'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
