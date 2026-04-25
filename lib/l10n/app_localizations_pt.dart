// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'BitStride Studio';

  @override
  String get loading => 'Carregando...';

  @override
  String get error => 'Erro';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get editChallenge => 'Editar Desafio';

  @override
  String get newChallenge => 'Novo Desafio';

  @override
  String get title => 'Título';

  @override
  String get language => 'Idioma';

  @override
  String get difficulty => 'Dificuldade';

  @override
  String get description => 'Descrição';

  @override
  String get testRun => 'Teste de Execução';

  @override
  String get publish => 'Publicar';

  @override
  String get testCases => 'Casos de Teste';

  @override
  String get add => 'Adicionar';

  @override
  String get addProvidedFile => 'Adicionar Arquivo Fornecido';

  @override
  String get create => 'Criar';

  @override
  String get myChallenges => 'Meus Desafios';

  @override
  String get reviewQueue => 'Fila de Revisão';

  @override
  String get courseManager => 'Gerenciador de Cursos';

  @override
  String get syncEngine => 'Motor de Sincronização';

  @override
  String get easy => 'Fácil';

  @override
  String get medium => 'Médio';

  @override
  String get hard => 'Difícil';

  @override
  String get providedFiles => 'Arquivos Fornecidos';

  @override
  String get allLevels => 'Todos os Níveis';

  @override
  String get dataSync => 'Sincronização de Dados';

  @override
  String get syncDescription =>
      'Sincronize os dados do seu currículo entre o banco de dados Firestore ativo e seu repositório local bitstride-content.';

  @override
  String get exportToRepo => 'Exportar para o Repositório';

  @override
  String get exportDescription =>
      'Baixe o estado atual do banco de dados ativo como um .zip de arquivos JSON, correspondendo diretamente à estrutura do seu repositório git.';

  @override
  String get downloadZip => 'Baixar .zip';

  @override
  String get importFromRepo => 'Importar do Repositório';

  @override
  String get importDescription =>
      'Envie um .zip ou .json do seu repositório bitstride-content. Isso SOBRESCREVERÁ as entradas existentes no banco de dados.';

  @override
  String get uploadJsonZip => 'Enviar JSON/ZIP';

  @override
  String get courseCurriculum => 'Currículo do Curso';

  @override
  String get addCourse => 'Adicionar Curso';

  @override
  String get editCourseInfo => 'Editar Informações do Curso';

  @override
  String get addLesson => 'Adicionar Lição';

  @override
  String get editCourse => 'Editar Curso';

  @override
  String get lessonTitle => 'Título da Lição';

  @override
  String get initialCodeTemplate => 'Modelo de Código Inicial (Opcional)';

  @override
  String get save => 'Salvar';

  @override
  String lessonsCount(int count) {
    return '$count lições';
  }

  @override
  String get exportSuccess => 'Currículo exportado com sucesso!';

  @override
  String exportFailed(String error) {
    return 'Falha na exportação: $error';
  }

  @override
  String importSuccess(int count) {
    return '$count itens importados com sucesso!';
  }

  @override
  String importFailed(String error) {
    return 'Falha na importação: $error';
  }

  @override
  String get noChallenges => 'Você ainda não publicou nenhum desafio.';

  @override
  String get createFirst => 'Crie o seu primeiro';

  @override
  String get approvedTitle => 'Aprovado';

  @override
  String get pendingTitle => 'Pendente';

  @override
  String get deleteChallengeTitle => 'Excluir desafio?';

  @override
  String get cannotBeUndone => 'Isso não pode ser desfeito.';

  @override
  String pendingReview(int count) {
    return ' Pendente de Revisão ($count)';
  }

  @override
  String approvedReview(int count) {
    return ' Aprovados ($count)';
  }

  @override
  String get noChallengesSubmitted => 'Nenhum desafio enviado ainda.';

  @override
  String byCreator(String creator, String difficulty) {
    return 'por $creator  $difficulty';
  }

  @override
  String testCasesFiles(int tests, int files) {
    return '$tests caso(s) de teste  $files arquivo(s)';
  }

  @override
  String get approveBtn => 'Aprovar';

  @override
  String get revokeBtn => 'Revogar';

  @override
  String get copyJsonBtn => 'Copiar JSON';

  @override
  String get copiedJson => 'JSON copiado para a área de transferência!';

  @override
  String get titleRequired => 'O título é obrigatório';

  @override
  String get publishedAwaiting => 'Publicado! Aguardando aprovação.';

  @override
  String get starterCode => 'Código Inicial';

  @override
  String testCaseTitle(int index) {
    return 'Teste $index';
  }

  @override
  String get inputStdin => 'Entrada (stdin)';

  @override
  String get expectedOutput => 'Saída Esperada';

  @override
  String get outputFileOpt => 'Arquivo de Saída (opcional, ex: output.out)';

  @override
  String get hiddenTest => 'Teste oculto';

  @override
  String gotOutput(String output) {
    return 'Obteve: $output';
  }

  @override
  String get fileName => 'Nome do Arquivo (ex: data.txt)';

  @override
  String get fileContent => 'Conteúdo do Arquivo';

  @override
  String get studioAdmin => 'Administração do Studio';

  @override
  String get mineTab => 'Meus';

  @override
  String get coursesTab => 'Cursos';

  @override
  String get reviewTab => 'Revisão';

  @override
  String get lesson => 'Lição';

  @override
  String get confirmDelete => 'Confirmar Exclusão';

  @override
  String get addContentBlock => 'Adicionar Bloco de Conteúdo';

  @override
  String get blockHeading => 'Título';

  @override
  String get blockText => 'Texto';

  @override
  String get blockCode => 'Código';

  @override
  String get blockImageURL => 'URL da Imagem';

  @override
  String get privateCodeHint =>
      '🔒 Este código é privado — usado APENAS para validação. Usuários no aplicativo Core NÃO verão isso.';

  @override
  String get cppSolution => 'Solução C++';

  @override
  String get pythonSolution => 'Solução Python';

  @override
  String get deleteConfirmTitle => 'Excluir?';

  @override
  String editNode(String id) {
    return 'Editar Nó $id';
  }

  @override
  String get highlightGlow => 'Destacar (Brilho)';

  @override
  String get blockQuiz => 'Quiz';

  @override
  String get quizQuestion => 'Pergunta do Quiz';

  @override
  String get multipleChoice => 'Múltipla Escolha';

  @override
  String get enterQuestionText => 'Digite o texto da pergunta...';

  @override
  String get optionsSelectCorrect => 'Opções (Selecione a correta):';

  @override
  String optionLabel(int index) {
    return 'Opção $index';
  }

  @override
  String get enterOptionText => 'Digite o texto da opção...';

  @override
  String get removeOption => 'Remover opção';

  @override
  String get addOption => 'Adicionar Opção';

  @override
  String get quizExplanation => 'Explicação';

  @override
  String get quizExplanationHint =>
      'Insira a explicação para respostas incorretas...';

  @override
  String get quizOptionExplanationHint =>
      'Explicação se incorreta (cada uma pode diferir)...';
}
