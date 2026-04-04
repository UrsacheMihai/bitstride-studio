class StudioChallenge {
  final String id;
  final String title;
  final String language;
  final String difficulty;
  final String category;
  final String method;
  final String description;
  final String initialCode;
  final List<StudioTestCase> tests;
  final List<StudioFile> files;
  final String creatorUid;
  final String creatorName;
  final DateTime createdAt;
  final bool approved;

  StudioChallenge({
    required this.id,
    required this.title,
    required this.language,
    required this.difficulty,
    this.category = '',
    this.method = '',
    required this.description,
    required this.initialCode,
    required this.tests,
    required this.files,
    required this.creatorUid,
    required this.creatorName,
    required this.createdAt,
    this.approved = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'language': language,
      'difficulty': difficulty,
      'category': category,
      'method': method,
      'description': description,
      'initial_code': initialCode,
      'tests': tests.map((t) => t.toMap()).toList(),
      'files': files.map((f) => f.toMap()).toList(),
      'creator_uid': creatorUid,
      'creator_name': creatorName,
      'created_at': createdAt.toIso8601String(),
      'approved': approved,
    };
  }

  factory StudioChallenge.fromFirestore(Map<String, dynamic> data) {
    return StudioChallenge(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      language: data['language'] ?? 'cpp',
      difficulty: data['difficulty'] ?? 'Easy',
      category: data['category'] ?? '',
      method: data['method'] ?? '',
      description: data['description'] ?? '',
      initialCode: data['initial_code'] ?? '',
      tests: (data['tests'] as List? ?? [])
          .map((t) => StudioTestCase.fromMap(t))
          .toList(),
      files: (data['files'] as List? ?? [])
          .map((f) => StudioFile.fromMap(f))
          .toList(),
      creatorUid: data['creator_uid'] ?? '',
      creatorName: data['creator_name'] ?? 'Anonymous',
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      approved: data['approved'] ?? false,
    );
  }
}

class StudioTestCase {
  String input;
  String expectedOutput;
  bool isHidden;
  String? inputFile;
  String? outputFile;

  StudioTestCase({
    this.input = '',
    this.expectedOutput = '',
    this.isHidden = false,
    this.inputFile,
    this.outputFile,
  });

  Map<String, dynamic> toMap() => {
    'input': input,
    'expected_output': expectedOutput,
    'is_hidden': isHidden,
    if (inputFile != null) 'input_file': inputFile,
    if (outputFile != null) 'output_file': outputFile,
  };

  factory StudioTestCase.fromMap(Map<String, dynamic> m) => StudioTestCase(
    input: m['input'] ?? '',
    expectedOutput: m['expected_output'] ?? '',
    isHidden: m['is_hidden'] ?? false,
    inputFile: m['input_file'],
    outputFile: m['output_file'],
  );
}

class StudioFile {
  String name;
  String content;

  StudioFile({this.name = '', this.content = ''});

  Map<String, dynamic> toMap() => {'name': name, 'content': content};

  factory StudioFile.fromMap(Map<String, dynamic> m) =>
      StudioFile(name: m['name'] ?? '', content: m['content'] ?? '');
}
