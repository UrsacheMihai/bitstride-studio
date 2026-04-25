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
  String get loading => 'Se încarcă...';

  @override
  String get error => 'Eroare';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Anulare';

  @override
  String get delete => 'Șterge';

  @override
  String get edit => 'Editează';

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
  String get testRun => 'Rulare de Test';

  @override
  String get publish => 'Publică';

  @override
  String get testCases => 'Cazuri de Test';

  @override
  String get add => 'Adaugă';

  @override
  String get addProvidedFile => 'Adaugă Fișier Oferit';

  @override
  String get create => 'Creează';

  @override
  String get myChallenges => 'Provocările Mele';

  @override
  String get reviewQueue => 'Coadă de Recenzii';

  @override
  String get courseManager => 'Manager Cursuri';

  @override
  String get syncEngine => 'Motor de Sincronizare';

  @override
  String get easy => 'Ușor';

  @override
  String get medium => 'Mediu';

  @override
  String get hard => 'Greu';

  @override
  String get providedFiles => 'Fișiere Oferite';

  @override
  String get allLevels => 'Toate Nivelurile';

  @override
  String get dataSync => 'Sincronizare Date';

  @override
  String get syncDescription =>
      'Sincronizează datele curriculare între baza de date live Firestore și depozitul tău local bitstride-content.';

  @override
  String get exportToRepo => 'Exportă în Depozit';

  @override
  String get exportDescription =>
      'Descarcă starea actuală a bazei de date live sub formă de arhivă .zip cu fișiere JSON, care se potrivește direct cu structura ta de depozit git.';

  @override
  String get downloadZip => 'Descarcă .zip';

  @override
  String get importFromRepo => 'Importă din Depozit';

  @override
  String get importDescription =>
      'Încarcă un .zip sau .json din depozitul tău bitstride-content. Acest lucru va SUPRASCRIE intrările existente din baza de date.';

  @override
  String get uploadJsonZip => 'Încarcă JSON/ZIP';

  @override
  String get courseCurriculum => 'Curriculum Curs';

  @override
  String get addCourse => 'Adaugă Curs';

  @override
  String get editCourseInfo => 'Editează Informațiile Cursului';

  @override
  String get addLesson => 'Adaugă Lecție';

  @override
  String get editCourse => 'Editează Curs';

  @override
  String get lessonTitle => 'Titlul Lecției';

  @override
  String get initialCodeTemplate => 'Șablon de Cod Inițial (Opțional)';

  @override
  String get save => 'Salvează';

  @override
  String lessonsCount(int count) {
    return '$count lecții';
  }

  @override
  String get exportSuccess => 'Curriculum exportat cu succes!';

  @override
  String exportFailed(String error) {
    return 'Export eșuat: $error';
  }

  @override
  String importSuccess(int count) {
    return 'S-au importat $count elemente cu succes!';
  }

  @override
  String importFailed(String error) {
    return 'Import eșuat: $error';
  }

  @override
  String get noChallenges => 'Nu ai publicat nicio provocare încă.';

  @override
  String get createFirst => 'Creează prima ta provocare';

  @override
  String get approvedTitle => 'Aprobat';

  @override
  String get pendingTitle => 'În Așteptare';

  @override
  String get deleteChallengeTitle => 'Ștergi provocarea?';

  @override
  String get cannotBeUndone => 'Această acțiune nu poate fi anulată.';

  @override
  String pendingReview(int count) {
    return ' Așteaptă Recenzie ($count)';
  }

  @override
  String approvedReview(int count) {
    return ' Aprobate ($count)';
  }

  @override
  String get noChallengesSubmitted => 'Nicio provocare trimisă încă.';

  @override
  String byCreator(String creator, String difficulty) {
    return 'de $creator  $difficulty';
  }

  @override
  String testCasesFiles(int tests, int files) {
    return '$tests caz(uri) de test  $files fișier(e)';
  }

  @override
  String get approveBtn => 'Aprobă';

  @override
  String get revokeBtn => 'Revocă';

  @override
  String get copyJsonBtn => 'Copiază JSON';

  @override
  String get copiedJson => 'JSON copiat în clipboard!';

  @override
  String get titleRequired => 'Titlul este obligatoriu';

  @override
  String get publishedAwaiting => 'Publicat! Așteaptă aprobarea.';

  @override
  String get starterCode => 'Cod de Început';

  @override
  String testCaseTitle(int index) {
    return 'Test $index';
  }

  @override
  String get inputStdin => 'Intrare (stdin)';

  @override
  String get expectedOutput => 'Ieșire Așteptată';

  @override
  String get outputFileOpt => 'Fișier de Ieșire (opțional, de ex. output.out)';

  @override
  String get hiddenTest => 'Test ascuns';

  @override
  String gotOutput(String output) {
    return 'Obținut: $output';
  }

  @override
  String get fileName => 'Nume Fișier (de ex. data.txt)';

  @override
  String get fileContent => 'Conținut Fișier';

  @override
  String get studioAdmin => 'Admin Studio';

  @override
  String get mineTab => 'Ale Mele';

  @override
  String get coursesTab => 'Cursuri';

  @override
  String get reviewTab => 'Recenzii';

  @override
  String get lesson => 'Lecție';

  @override
  String get confirmDelete => 'Confirmă Ștergerea';

  @override
  String get addContentBlock => 'Adaugă Bloc de Conținut';

  @override
  String get blockHeading => 'Titlu';

  @override
  String get blockText => 'Text';

  @override
  String get blockCode => 'Cod';

  @override
  String get blockImageURL => 'URL Imagine';

  @override
  String get privateCodeHint =>
      '🔒 Acest cod este privat — utilizat DOAR pentru validare. Utilizatorii din aplicația Core NU îl vor vedea.';

  @override
  String get cppSolution => 'Soluție C++';

  @override
  String get pythonSolution => 'Soluție Python';

  @override
  String get deleteConfirmTitle => 'Șterge?';

  @override
  String editNode(String id) {
    return 'Editează Nodul $id';
  }

  @override
  String get highlightGlow => 'Evidențiere (Strălucire)';

  @override
  String get blockQuiz => 'Chestionar';

  @override
  String get quizQuestion => 'Întrebare Chestionar';

  @override
  String get multipleChoice => 'Răspuns Multiplu';

  @override
  String get enterQuestionText => 'Introduceți textul întrebării...';

  @override
  String get optionsSelectCorrect => 'Opțiuni (Selectați-o pe cea corectă):';

  @override
  String optionLabel(int index) {
    return 'Opțiunea $index';
  }

  @override
  String get enterOptionText => 'Introduceți textul opțiunii...';

  @override
  String get removeOption => 'Elimină opțiunea';

  @override
  String get addOption => 'Adaugă Opțiune';

  @override
  String get quizExplanation => 'Explicație';

  @override
  String get quizExplanationHint =>
      'Introdu explicația pentru răspunsurile incorecte...';

  @override
  String get quizOptionExplanationHint =>
      'Explicație dacă este incorect (fiecare poate diferi)...';
}
