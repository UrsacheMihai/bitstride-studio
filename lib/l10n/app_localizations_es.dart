// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'BitStride Studio';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get ok => 'Aceptar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get editChallenge => 'Editar Desafío';

  @override
  String get newChallenge => 'Nuevo Desafío';

  @override
  String get title => 'Título';

  @override
  String get language => 'Idioma';

  @override
  String get difficulty => 'Dificultad';

  @override
  String get description => 'Descripción';

  @override
  String get testRun => 'Prueba de ejecución';

  @override
  String get publish => 'Publicar';

  @override
  String get testCases => 'Casos de prueba';

  @override
  String get add => 'Agregar';

  @override
  String get addProvidedFile => 'Agregar Archivo Proporcionado';

  @override
  String get create => 'Crear';

  @override
  String get myChallenges => 'Mis Desafíos';

  @override
  String get reviewQueue => 'Cola de revisión';

  @override
  String get courseManager => 'Administrador de Cursos';

  @override
  String get syncEngine => 'Motor de Sincronización';

  @override
  String get easy => 'Fácil';

  @override
  String get medium => 'Medio';

  @override
  String get hard => 'Difícil';

  @override
  String get providedFiles => 'Archivos Proporcionados';

  @override
  String get allLevels => 'Todos los niveles';

  @override
  String get dataSync => 'Sincronización de Datos';

  @override
  String get syncDescription =>
      'Sincroniza los datos de tu currículo entre la base de datos de Firestore en vivo y tu repositorio local de bitstride-content.';

  @override
  String get exportToRepo => 'Exportar al repositorio';

  @override
  String get exportDescription =>
      'Descarga el estado actual de la base de datos en vivo como un .zip de archivos JSON, coincidiendo directamente con la estructura de tu repositorio git.';

  @override
  String get downloadZip => 'Descargar .zip';

  @override
  String get importFromRepo => 'Importar del repositorio';

  @override
  String get importDescription =>
      'Sube un .zip o .json de tu repositorio bitstride-content. Esto SOBREESCRIBIRÁ las entradas existentes en la base de datos.';

  @override
  String get uploadJsonZip => 'Subir JSON/ZIP';

  @override
  String get courseCurriculum => 'Currículo del Curso';

  @override
  String get addCourse => 'Agregar Curso';

  @override
  String get editCourseInfo => 'Editar Información del Curso';

  @override
  String get addLesson => 'Agregar Lección';

  @override
  String get editCourse => 'Editar Curso';

  @override
  String get lessonTitle => 'Título de la Lección';

  @override
  String get initialCodeTemplate => 'Plantilla de Código Inicial (Opcional)';

  @override
  String get save => 'Guardar';

  @override
  String lessonsCount(int count) {
    return '$count lecciones';
  }

  @override
  String get exportSuccess => '¡Currículo exportado con éxito!';

  @override
  String exportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String importSuccess(int count) {
    return '¡Se importaron $count elementos con éxito!';
  }

  @override
  String importFailed(String error) {
    return 'Error al importar: $error';
  }

  @override
  String get noChallenges => 'Aún no has publicado ningún desafío.';

  @override
  String get createFirst => 'Crea el primero';

  @override
  String get approvedTitle => 'Aprobado';

  @override
  String get pendingTitle => 'Pendiente';

  @override
  String get deleteChallengeTitle => '¿Eliminar desafío?';

  @override
  String get cannotBeUndone => 'Esto no se puede deshacer.';

  @override
  String pendingReview(int count) {
    return ' Pendiente de Revisión ($count)';
  }

  @override
  String approvedReview(int count) {
    return ' Aprobados ($count)';
  }

  @override
  String get noChallengesSubmitted => 'Ningún desafío enviado aún.';

  @override
  String byCreator(String creator, String difficulty) {
    return 'por $creator  $difficulty';
  }

  @override
  String testCasesFiles(int tests, int files) {
    return '$tests caso(s) de prueba  $files archivo(s)';
  }

  @override
  String get approveBtn => 'Aprobar';

  @override
  String get revokeBtn => 'Revocar';

  @override
  String get copyJsonBtn => 'Copiar JSON';

  @override
  String get copiedJson => '¡JSON copiado al portapapeles!';

  @override
  String get titleRequired => 'El título es obligatorio';

  @override
  String get publishedAwaiting => '¡Publicado! Esperando aprobación.';

  @override
  String get starterCode => 'Código Inicial';

  @override
  String testCaseTitle(int index) {
    return 'Prueba $index';
  }

  @override
  String get inputStdin => 'Entrada (stdin)';

  @override
  String get expectedOutput => 'Salida Esperada';

  @override
  String get outputFileOpt => 'Archivo de Salida (opcional, ej. output.out)';

  @override
  String get hiddenTest => 'Prueba oculta';

  @override
  String gotOutput(String output) {
    return 'Obtenido: $output';
  }

  @override
  String get fileName => 'Nombre de Archivo (ej. data.txt)';

  @override
  String get fileContent => 'Contenido del Archivo';

  @override
  String get studioAdmin => 'Administración de Studio';

  @override
  String get mineTab => 'Míos';

  @override
  String get coursesTab => 'Cursos';

  @override
  String get reviewTab => 'Revisión';

  @override
  String get lesson => 'Lección';

  @override
  String get confirmDelete => 'Confirmar eliminación';

  @override
  String get addContentBlock => 'Agregar bloque de contenido';

  @override
  String get blockHeading => 'Encabezado';

  @override
  String get blockText => 'Texto';

  @override
  String get blockCode => 'Código';

  @override
  String get blockImageURL => 'URL de imagen';

  @override
  String get privateCodeHint =>
      '🔒 Este código es privado — usado SOLO para validación. Los usuarios en la aplicación Core NO lo verán.';

  @override
  String get cppSolution => 'Solución C++';

  @override
  String get pythonSolution => 'Solución Python';

  @override
  String get deleteConfirmTitle => '¿Eliminar?';

  @override
  String editNode(String id) {
    return 'Editar nodo $id';
  }

  @override
  String get highlightGlow => 'Resaltar (Brillo)';

  @override
  String get blockQuiz => 'Cuestionario';

  @override
  String get quizQuestion => 'Pregunta del Cuestionario';

  @override
  String get multipleChoice => 'Opción Múltiple';

  @override
  String get enterQuestionText => 'Introduce el texto de la pregunta...';

  @override
  String get optionsSelectCorrect => 'Opciones (Selecciona la correcta):';

  @override
  String optionLabel(int index) {
    return 'Opción $index';
  }

  @override
  String get enterOptionText => 'Introduce el texto de la opción...';

  @override
  String get removeOption => 'Eliminar opción';

  @override
  String get addOption => 'Añadir Opción';

  @override
  String get quizExplanation => 'Explicación';

  @override
  String get quizExplanationHint =>
      'Introduce la explicación para las respuestas incorrectas...';

  @override
  String get quizOptionExplanationHint =>
      'Explicación si es incorrecta (cada una puede diferir)...';
}
