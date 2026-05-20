// Manage static configuration and URL resolution for the Piston judge endpoint.
class StudioJudgeConfig {
  StudioJudgeConfig._();

  static const String defaultLocalUrl = 'http://localhost:2001';

  static String? _explicitOverrideUrl;

  static String? _firestoreBaseUrl;

  static String get pistonBaseUrl {
    if (_explicitOverrideUrl != null &&
        _explicitOverrideUrl != defaultLocalUrl) {
      return _explicitOverrideUrl!;
    }
    if (_firestoreBaseUrl != null && _firestoreBaseUrl!.isNotEmpty) {
      return _firestoreBaseUrl!;
    }
    return _explicitOverrideUrl ?? defaultLocalUrl;
  }

  static String get pistonExecuteUrl => '$pistonBaseUrl/api/v2/execute';

  static String get pistonRuntimesUrl => '$pistonBaseUrl/api/v2/runtimes';

  static String? get firestoreBaseUrl => _firestoreBaseUrl;

  // Overrides the Piston base URL removing any trailing slash.
  static void setBaseUrl(String url) {
    final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    _explicitOverrideUrl = cleanUrl;
  }

  // Stores the Firestore-sourced Piston base URL removing any trailing slash.
  static void setFirestoreBaseUrl(String url) {
    final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    _firestoreBaseUrl = cleanUrl;
  }

  static const Map<String, StudioPistonRuntime> runtimes = {
    'cpp': StudioPistonRuntime(language: 'c++', version: '10.2.0'),
    'python': StudioPistonRuntime(language: 'python', version: '3.12.0'),
  };
}

// Store the runtime language and version pair for a Piston execution request.
class StudioPistonRuntime {
  final String language;
  final String version;

  const StudioPistonRuntime({required this.language, required this.version});
}
