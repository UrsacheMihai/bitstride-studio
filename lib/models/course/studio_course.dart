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
}