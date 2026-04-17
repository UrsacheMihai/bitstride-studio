// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'BitStride Studio';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get ok => 'D\'accord';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get editChallenge => 'Modifier le défi';

  @override
  String get newChallenge => 'Nouveau défi';

  @override
  String get title => 'Titre';

  @override
  String get language => 'Langue';

  @override
  String get difficulty => 'Difficulté';

  @override
  String get description => 'Description';

  @override
  String get testRun => 'Exécution de test';

  @override
  String get publish => 'Publier';

  @override
  String get testCases => 'Cas de test';

  @override
  String get add => 'Ajouter';

  @override
  String get addProvidedFile => 'Ajouter un fichier';

  @override
  String get create => 'Créer';

  @override
  String get myChallenges => 'Mes défis';

  @override
  String get reviewQueue => 'File d\'attente';

  @override
  String get courseManager => 'Gestionnaire';

  @override
  String get syncEngine => 'Moteur de sync';

  @override
  String get easy => 'Facile';

  @override
  String get medium => 'Moyen';

  @override
  String get hard => 'Difficile';

  @override
  String get providedFiles => 'Fichiers Fournis';

  @override
  String get allLevels => 'Tous les niveaux';

  @override
  String get dataSync => 'Data Sync';

  @override
  String get syncDescription =>
      'Synchronize your curriculum data between the live Firestore database and your local bitstride-content repository.';

  @override
  String get exportToRepo => 'Export to Repo';

  @override
  String get exportDescription =>
      'Download the current live database state as a .zip of JSON files, directly matching your git repo structure.';

  @override
  String get downloadZip => 'Download .zip';

  @override
  String get importFromRepo => 'Import from Repo';

  @override
  String get importDescription =>
      'Upload a .zip or .json from your bitstride-content repo. This will OVERWRITE existing database entries.';

  @override
  String get uploadJsonZip => 'Upload JSON/ZIP';

  @override
  String get courseCurriculum => 'Course Curriculum';

  @override
  String get addCourse => 'Add Course';

  @override
  String get editCourseInfo => 'Edit Course Info';

  @override
  String get addLesson => 'Add Lesson';

  @override
  String get editCourse => 'Edit Course';

  @override
  String get lessonTitle => 'Lesson Title';

  @override
  String get initialCodeTemplate => 'Initial Code Template (Optional)';

  @override
  String get save => 'Save';

  @override
  String lessonsCount(int count) {
    return '$count lessons';
  }

  @override
  String get exportSuccess => 'Curriculum exported successfully!';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String importSuccess(int count) {
    return 'Imported $count items successfully!';
  }

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get noChallenges => 'You haven\'t published any challenges yet.';

  @override
  String get createFirst => 'Create your first';

  @override
  String get approvedTitle => 'Approved';

  @override
  String get pendingTitle => 'Pending';

  @override
  String get deleteChallengeTitle => 'Delete challenge?';

  @override
  String get cannotBeUndone => 'This cannot be undone.';

  @override
  String pendingReview(int count) {
    return ' Pending Review ($count)';
  }

  @override
  String approvedReview(int count) {
    return ' Approved ($count)';
  }

  @override
  String get noChallengesSubmitted => 'No challenges submitted yet.';

  @override
  String byCreator(String creator, String difficulty) {
    return 'by $creator  $difficulty';
  }

  @override
  String testCasesFiles(int tests, int files) {
    return '$tests test case(s)  $files file(s)';
  }

  @override
  String get approveBtn => 'Approve';

  @override
  String get revokeBtn => 'Revoke';

  @override
  String get copyJsonBtn => 'Copy JSON';

  @override
  String get copiedJson => 'Copied JSON to clipboard!';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get publishedAwaiting => 'Published! Awaiting approval.';

  @override
  String get starterCode => 'Starter Code';

  @override
  String testCaseTitle(int index) {
    return 'Test $index';
  }

  @override
  String get inputStdin => 'Input (stdin)';

  @override
  String get expectedOutput => 'Expected Output';

  @override
  String get outputFileOpt => 'Output File (optional, e.g. output.out)';

  @override
  String get hiddenTest => 'Hidden test';

  @override
  String gotOutput(String output) {
    return 'Got: $output';
  }

  @override
  String get fileName => 'File Name (e.g. data.txt)';

  @override
  String get fileContent => 'File Content';

  @override
  String get studioAdmin => 'Studio Admin';

  @override
  String get mineTab => 'Mine';

  @override
  String get coursesTab => 'Courses';

  @override
  String get reviewTab => 'Review';
}
