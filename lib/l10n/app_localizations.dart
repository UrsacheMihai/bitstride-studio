import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
    Locale('ro')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BitStride Studio'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editChallenge.
  ///
  /// In en, this message translates to:
  /// **'Edit Challenge'**
  String get editChallenge;

  /// No description provided for @newChallenge.
  ///
  /// In en, this message translates to:
  /// **'New Challenge'**
  String get newChallenge;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @testRun.
  ///
  /// In en, this message translates to:
  /// **'Test Run'**
  String get testRun;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @testCases.
  ///
  /// In en, this message translates to:
  /// **'Test Cases'**
  String get testCases;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addProvidedFile.
  ///
  /// In en, this message translates to:
  /// **'Add Provided File'**
  String get addProvidedFile;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @myChallenges.
  ///
  /// In en, this message translates to:
  /// **'My Challenges'**
  String get myChallenges;

  /// No description provided for @reviewQueue.
  ///
  /// In en, this message translates to:
  /// **'Review Queue'**
  String get reviewQueue;

  /// No description provided for @courseManager.
  ///
  /// In en, this message translates to:
  /// **'Course Manager'**
  String get courseManager;

  /// No description provided for @syncEngine.
  ///
  /// In en, this message translates to:
  /// **'Sync Engine'**
  String get syncEngine;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @providedFiles.
  ///
  /// In en, this message translates to:
  /// **'Provided Files'**
  String get providedFiles;

  /// No description provided for @allLevels.
  ///
  /// In en, this message translates to:
  /// **'All Levels'**
  String get allLevels;

  /// No description provided for @dataSync.
  ///
  /// In en, this message translates to:
  /// **'Data Sync'**
  String get dataSync;

  /// No description provided for @syncDescription.
  ///
  /// In en, this message translates to:
  /// **'Synchronize your curriculum data between the live Firestore database and your local bitstride-content repository.'**
  String get syncDescription;

  /// No description provided for @exportToRepo.
  ///
  /// In en, this message translates to:
  /// **'Export to Repo'**
  String get exportToRepo;

  /// No description provided for @exportDescription.
  ///
  /// In en, this message translates to:
  /// **'Download the current live database state as a .zip of JSON files, directly matching your git repo structure.'**
  String get exportDescription;

  /// No description provided for @downloadZip.
  ///
  /// In en, this message translates to:
  /// **'Download .zip'**
  String get downloadZip;

  /// No description provided for @importFromRepo.
  ///
  /// In en, this message translates to:
  /// **'Import from Repo'**
  String get importFromRepo;

  /// No description provided for @importDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload a .zip or .json from your bitstride-content repo. This will OVERWRITE existing database entries.'**
  String get importDescription;

  /// No description provided for @uploadJsonZip.
  ///
  /// In en, this message translates to:
  /// **'Upload JSON/ZIP'**
  String get uploadJsonZip;

  /// No description provided for @courseCurriculum.
  ///
  /// In en, this message translates to:
  /// **'Course Curriculum'**
  String get courseCurriculum;

  /// No description provided for @addCourse.
  ///
  /// In en, this message translates to:
  /// **'Add Course'**
  String get addCourse;

  /// No description provided for @editCourseInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Course Info'**
  String get editCourseInfo;

  /// No description provided for @addLesson.
  ///
  /// In en, this message translates to:
  /// **'Add Lesson'**
  String get addLesson;

  /// No description provided for @editCourse.
  ///
  /// In en, this message translates to:
  /// **'Edit Course'**
  String get editCourse;

  /// No description provided for @lessonTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson Title'**
  String get lessonTitle;

  /// No description provided for @initialCodeTemplate.
  ///
  /// In en, this message translates to:
  /// **'Initial Code Template (Optional)'**
  String get initialCodeTemplate;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @lessonsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} lessons'**
  String lessonsCount(int count);

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Curriculum exported successfully!'**
  String get exportSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} items successfully!'**
  String importSuccess(int count);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// No description provided for @noChallenges.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t published any challenges yet.'**
  String get noChallenges;

  /// No description provided for @createFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your first'**
  String get createFirst;

  /// No description provided for @approvedTitle.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approvedTitle;

  /// No description provided for @pendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingTitle;

  /// No description provided for @deleteChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete challenge?'**
  String get deleteChallengeTitle;

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get cannotBeUndone;

  /// No description provided for @pendingReview.
  ///
  /// In en, this message translates to:
  /// **' Pending Review ({count})'**
  String pendingReview(int count);

  /// No description provided for @approvedReview.
  ///
  /// In en, this message translates to:
  /// **' Approved ({count})'**
  String approvedReview(int count);

  /// No description provided for @noChallengesSubmitted.
  ///
  /// In en, this message translates to:
  /// **'No challenges submitted yet.'**
  String get noChallengesSubmitted;

  /// No description provided for @byCreator.
  ///
  /// In en, this message translates to:
  /// **'by {creator}  {difficulty}'**
  String byCreator(String creator, String difficulty);

  /// No description provided for @testCasesFiles.
  ///
  /// In en, this message translates to:
  /// **'{tests} test case(s)  {files} file(s)'**
  String testCasesFiles(int tests, int files);

  /// No description provided for @approveBtn.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveBtn;

  /// No description provided for @revokeBtn.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get revokeBtn;

  /// No description provided for @copyJsonBtn.
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get copyJsonBtn;

  /// No description provided for @copiedJson.
  ///
  /// In en, this message translates to:
  /// **'Copied JSON to clipboard!'**
  String get copiedJson;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @publishedAwaiting.
  ///
  /// In en, this message translates to:
  /// **'Published! Awaiting approval.'**
  String get publishedAwaiting;

  /// No description provided for @starterCode.
  ///
  /// In en, this message translates to:
  /// **'Starter Code'**
  String get starterCode;

  /// No description provided for @testCaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Test {index}'**
  String testCaseTitle(int index);

  /// No description provided for @inputStdin.
  ///
  /// In en, this message translates to:
  /// **'Input (stdin)'**
  String get inputStdin;

  /// No description provided for @expectedOutput.
  ///
  /// In en, this message translates to:
  /// **'Expected Output'**
  String get expectedOutput;

  /// No description provided for @outputFileOpt.
  ///
  /// In en, this message translates to:
  /// **'Output File (optional, e.g. output.out)'**
  String get outputFileOpt;

  /// No description provided for @hiddenTest.
  ///
  /// In en, this message translates to:
  /// **'Hidden test'**
  String get hiddenTest;

  /// No description provided for @gotOutput.
  ///
  /// In en, this message translates to:
  /// **'Got: {output}'**
  String gotOutput(String output);

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File Name (e.g. data.txt)'**
  String get fileName;

  /// No description provided for @fileContent.
  ///
  /// In en, this message translates to:
  /// **'File Content'**
  String get fileContent;

  /// No description provided for @studioAdmin.
  ///
  /// In en, this message translates to:
  /// **'Studio Admin'**
  String get studioAdmin;

  /// No description provided for @mineTab.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get mineTab;

  /// No description provided for @coursesTab.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get coursesTab;

  /// No description provided for @reviewTab.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTab;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'pt', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
