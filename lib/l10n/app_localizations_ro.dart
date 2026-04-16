// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'BitStride Studio';

  @override
  String get loading => 'Se incarca...';

  @override
  String get error => 'Eroare';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Anuleaza';

  @override
  String get delete => 'Sterge';

  @override
  String get edit => 'Editeaza';

  @override
  String get editChallenge => 'Editează Provocarea';

  @override
  String get newChallenge => 'Provocare Nouă';

  @override
  String get title => 'Titlu';

  @override
  String get language => 'Limbă';

  @override
  String get difficulty => 'Dificultate';

  @override
  String get description => 'Descriere';

  @override
  String get testRun => 'Rulare Test';

  @override
  String get publish => 'Publică';

  @override
  String get testCases => 'Cazuri de Test';

  @override
  String get add => 'Adaugă';

  @override
  String get addProvidedFile => 'Adaugă Fișier Oferit';

  @override
  String get create => 'Crează';

  @override
  String get myChallenges => 'Provocările Mele';

  @override
  String get reviewQueue => 'Coadă de Revizuiri';

  @override
  String get courseManager => 'Manager Cursuri';

  @override
  String get syncEngine => 'Motor Sincronizare';

  @override
  String get easy => 'Usor';

  @override
  String get medium => 'Mediu';

  @override
  String get hard => 'Greu';

  @override
  String get providedFiles => 'Fisiere Oferite';

  @override
  String get allLevels => 'Toate Nivelurile';

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
