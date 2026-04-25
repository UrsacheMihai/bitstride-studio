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
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get editChallenge => 'Modifier le Défi';

  @override
  String get newChallenge => 'Nouveau Défi';

  @override
  String get title => 'Titre';

  @override
  String get language => 'Langue';

  @override
  String get difficulty => 'Difficulté';

  @override
  String get description => 'Description';

  @override
  String get testRun => 'Exécution Test';

  @override
  String get publish => 'Publier';

  @override
  String get testCases => 'Cas de Test';

  @override
  String get add => 'Ajouter';

  @override
  String get addProvidedFile => 'Ajouter Fichier Fourni';

  @override
  String get create => 'Créer';

  @override
  String get myChallenges => 'Mes Défis';

  @override
  String get reviewQueue => 'File de Révision';

  @override
  String get courseManager => 'Gestionnaire de Cours';

  @override
  String get syncEngine => 'Moteur de Synchronisation';

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
  String get dataSync => 'Synchronisation';

  @override
  String get syncDescription =>
      'Synchronisez vos données de programme entre la base de données Firestore en direct et votre dépôt bitstride-content local.';

  @override
  String get exportToRepo => 'Exporter vers le dépôt';

  @override
  String get exportDescription =>
      'Téléchargez l\'état actuel de la base de données en direct sous forme de .zip de fichiers JSON, correspondant directement à la structure de votre dépôt git.';

  @override
  String get downloadZip => 'Télécharger .zip';

  @override
  String get importFromRepo => 'Importer depuis le dépôt';

  @override
  String get importDescription =>
      'Téléchargez un .zip ou .json depuis votre dépôt bitstride-content. Cela ÉCRASERA les entrées existantes de la base de données.';

  @override
  String get uploadJsonZip => 'Télécharger JSON/ZIP';

  @override
  String get courseCurriculum => 'Programme du Cours';

  @override
  String get addCourse => 'Ajouter un Cours';

  @override
  String get editCourseInfo => 'Modifier les Infos du Cours';

  @override
  String get addLesson => 'Ajouter une Leçon';

  @override
  String get editCourse => 'Modifier le Cours';

  @override
  String get lessonTitle => 'Titre de la Leçon';

  @override
  String get initialCodeTemplate => 'Modèle de Code Initial (Optionnel)';

  @override
  String get save => 'Enregistrer';

  @override
  String lessonsCount(int count) {
    return '$count leçons';
  }

  @override
  String get exportSuccess => 'Programme exporté avec succès!';

  @override
  String exportFailed(String error) {
    return 'Échec de l\'exportation: $error';
  }

  @override
  String importSuccess(int count) {
    return '$count éléments importés avec succès!';
  }

  @override
  String importFailed(String error) {
    return 'Échec de l\'importation: $error';
  }

  @override
  String get noChallenges => 'Vous n\'avez encore publié aucun défi.';

  @override
  String get createFirst => 'Créez votre premier';

  @override
  String get approvedTitle => 'Approuvé';

  @override
  String get pendingTitle => 'En Attente';

  @override
  String get deleteChallengeTitle => 'Supprimer le défi?';

  @override
  String get cannotBeUndone => 'Cette action est irréversible.';

  @override
  String pendingReview(int count) {
    return ' En Attente de Révision ($count)';
  }

  @override
  String approvedReview(int count) {
    return ' Approuvés ($count)';
  }

  @override
  String get noChallengesSubmitted => 'Aucun défi soumis pour le moment.';

  @override
  String byCreator(String creator, String difficulty) {
    return 'par $creator  $difficulty';
  }

  @override
  String testCasesFiles(int tests, int files) {
    return '$tests cas de test  $files fichier(s)';
  }

  @override
  String get approveBtn => 'Approuver';

  @override
  String get revokeBtn => 'Révoquer';

  @override
  String get copyJsonBtn => 'Copier JSON';

  @override
  String get copiedJson => 'JSON copié dans le presse-papiers!';

  @override
  String get titleRequired => 'Le titre est requis';

  @override
  String get publishedAwaiting => 'Publié! En attente d\'approbation.';

  @override
  String get starterCode => 'Code de Départ';

  @override
  String testCaseTitle(int index) {
    return 'Test $index';
  }

  @override
  String get inputStdin => 'Entrée (stdin)';

  @override
  String get expectedOutput => 'Sortie Attendue';

  @override
  String get outputFileOpt => 'Fichier de Sortie (optionnel, ex. output.out)';

  @override
  String get hiddenTest => 'Test caché';

  @override
  String gotOutput(String output) {
    return 'Obtenu: $output';
  }

  @override
  String get fileName => 'Nom du Fichier (ex. data.txt)';

  @override
  String get fileContent => 'Contenu du Fichier';

  @override
  String get studioAdmin => 'Administration Studio';

  @override
  String get mineTab => 'À Moi';

  @override
  String get coursesTab => 'Cours';

  @override
  String get reviewTab => 'Révision';

  @override
  String get lesson => 'Leçon';

  @override
  String get confirmDelete => 'Confirmer la suppression';

  @override
  String get addContentBlock => 'Ajouter un bloc de contenu';

  @override
  String get blockHeading => 'En-tête';

  @override
  String get blockText => 'Texte';

  @override
  String get blockCode => 'Code';

  @override
  String get blockImageURL => 'URL de l\'image';

  @override
  String get privateCodeHint =>
      '🔒 Ce code est privé — utilisé UNIQUEMENT pour la validation. Les utilisateurs de l\'application Core NE le verront PAS.';

  @override
  String get cppSolution => 'Solution C++';

  @override
  String get pythonSolution => 'Solution Python';

  @override
  String get deleteConfirmTitle => 'Supprimer?';

  @override
  String editNode(String id) {
    return 'Modifier le nœud $id';
  }

  @override
  String get highlightGlow => 'Surligner (Éclat)';

  @override
  String get blockQuiz => 'Quiz';

  @override
  String get quizQuestion => 'Question du Quiz';

  @override
  String get multipleChoice => 'Choix Multiple';

  @override
  String get enterQuestionText => 'Entrez le texte de la question...';

  @override
  String get optionsSelectCorrect =>
      'Options (Sélectionnez la bonne réponse) :';

  @override
  String optionLabel(int index) {
    return 'Option $index';
  }

  @override
  String get enterOptionText => 'Entrez le texte de l\'option...';

  @override
  String get removeOption => 'Supprimer l\'option';

  @override
  String get addOption => 'Ajouter une Option';

  @override
  String get quizExplanation => 'Explication';

  @override
  String get quizExplanationHint =>
      'Entrez l\'explication pour les mauvaises réponses...';

  @override
  String get quizOptionExplanationHint =>
      'Explication si incorrecte (chaque peut différer)...';
}
