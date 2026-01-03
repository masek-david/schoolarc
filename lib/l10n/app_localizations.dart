import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_en.dart';

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
    Locale('cs'),
    Locale('en'),
  ];

  /// Greeting based on time of day: morning, afternoon, evening, night
  ///
  /// In en, this message translates to:
  /// **'{hour, select, morning{Good morning} afternoon{Good afternoon} evening{Good evening} night{Good night} other{Hello}}'**
  String greetingByHour(String hour);

  /// No description provided for @youHave.
  ///
  /// In en, this message translates to:
  /// **'You have'**
  String get youHave;

  /// No description provided for @missedHomeworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Missed homework'**
  String get missedHomeworkTitle;

  /// Label for missed homework count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Missed piece of homework} other{Missed pieces of homework}}'**
  String missedHomework(int count);

  /// Label for upcoming homework count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Upcoming piece of homework} other{Upcoming pieces of homework}}'**
  String upcomingHomework(int count);

  /// Label for upcoming exams count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Upcoming exam} other{Upcoming exams}}'**
  String upcomingExams(int count);

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// Represents the absence of number, or something like: 'No errors found', but in other languages can be '0 errors found'
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get zero;

  /// Represents the absence of number, or something like: 'No errors found'
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get no;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @noPriority.
  ///
  /// In en, this message translates to:
  /// **'No priority'**
  String get noPriority;

  /// No description provided for @anotherYearBehind.
  ///
  /// In en, this message translates to:
  /// **'Another year behind'**
  String get anotherYearBehind;

  /// No description provided for @viewYearStats.
  ///
  /// In en, this message translates to:
  /// **'View stats about your year'**
  String get viewYearStats;

  /// No description provided for @importing.
  ///
  /// In en, this message translates to:
  /// **'Importing'**
  String get importing;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @addedHomework.
  ///
  /// In en, this message translates to:
  /// **'Homework added'**
  String get addedHomework;

  /// No description provided for @addedExam.
  ///
  /// In en, this message translates to:
  /// **'Exam added'**
  String get addedExam;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @pleaseLogIn.
  ///
  /// In en, this message translates to:
  /// **'Please log in'**
  String get pleaseLogIn;

  /// No description provided for @everythingDone.
  ///
  /// In en, this message translates to:
  /// **'Everything done'**
  String get everythingDone;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @exams.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Exam} other{Exams}}'**
  String exams(num count);

  /// No description provided for @addNewExam.
  ///
  /// In en, this message translates to:
  /// **'Add new exam'**
  String get addNewExam;

  /// No description provided for @addNewExamFor.
  ///
  /// In en, this message translates to:
  /// **'Add new exam for'**
  String get addNewExamFor;

  /// No description provided for @deletedExam.
  ///
  /// In en, this message translates to:
  /// **'Deleted exam'**
  String get deletedExam;

  /// No description provided for @toExam.
  ///
  /// In en, this message translates to:
  /// **'To exam'**
  String get toExam;

  /// No description provided for @examsFor.
  ///
  /// In en, this message translates to:
  /// **'{isEmpty, select, true{No exams} other{Exams}} {whenText}'**
  String examsFor(String isEmpty, Object whenText);

  /// No description provided for @examAbsence.
  ///
  /// In en, this message translates to:
  /// **'{isAbsent, select, true{No exams} other{Exams}}'**
  String examAbsence(String isAbsent);

  /// No description provided for @homework.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Homework} other{Homework}}'**
  String homework(num count);

  /// No description provided for @addNewHomework.
  ///
  /// In en, this message translates to:
  /// **'Add new homework'**
  String get addNewHomework;

  /// No description provided for @addNewHomeworkFor.
  ///
  /// In en, this message translates to:
  /// **'Add new homework for'**
  String get addNewHomeworkFor;

  /// No description provided for @deletedHomework.
  ///
  /// In en, this message translates to:
  /// **'Deleted homework'**
  String get deletedHomework;

  /// No description provided for @toHomework.
  ///
  /// In en, this message translates to:
  /// **'To homework'**
  String get toHomework;

  /// No description provided for @homeworkFor.
  ///
  /// In en, this message translates to:
  /// **'{isEmpty, select, true{No homework} other{Homework}} {whenText}'**
  String homeworkFor(String isEmpty, Object whenText);

  /// No description provided for @homeworkAbsence.
  ///
  /// In en, this message translates to:
  /// **'{isAbsent, select, true{No homework} other{Homework}}'**
  String homeworkAbsence(String isAbsent);

  /// No description provided for @nothingPlannedFor.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for {whenText}'**
  String nothingPlannedFor(Object whenText);

  /// No description provided for @nothingPlanned.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned'**
  String get nothingPlanned;

  /// No description provided for @showMyName.
  ///
  /// In en, this message translates to:
  /// **'Show my name'**
  String get showMyName;

  /// No description provided for @showMyNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If enabled and logged in to Bakaláři, you will be greeted with your name'**
  String get showMyNameSubtitle;

  /// No description provided for @showBakalariTimetable.
  ///
  /// In en, this message translates to:
  /// **'Show Bakaláři timetable'**
  String get showBakalariTimetable;

  /// No description provided for @showMeals.
  ///
  /// In en, this message translates to:
  /// **'Show meals'**
  String get showMeals;

  /// No description provided for @mealsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Meals disabled'**
  String get mealsDisabled;

  /// No description provided for @lunchTime.
  ///
  /// In en, this message translates to:
  /// **'Lunch time'**
  String get lunchTime;

  /// No description provided for @lunchTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When meals for next day appear'**
  String get lunchTimeSubtitle;

  /// No description provided for @initialDate.
  ///
  /// In en, this message translates to:
  /// **'Initial date'**
  String get initialDate;

  /// No description provided for @showMissedHomework.
  ///
  /// In en, this message translates to:
  /// **'Show missed homework'**
  String get showMissedHomework;

  /// No description provided for @showArrows.
  ///
  /// In en, this message translates to:
  /// **'Show arrows'**
  String get showArrows;

  /// No description provided for @showArrowsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show arrows for switching between pages'**
  String get showArrowsSubtitle;

  /// No description provided for @upcomingDayChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Here you will find upcoming exams and homework'**
  String get upcomingDayChannelDescription;

  /// No description provided for @mainChannel.
  ///
  /// In en, this message translates to:
  /// **'Main channel'**
  String get mainChannel;

  /// No description provided for @mainChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Main channel for notifications'**
  String get mainChannelDescription;

  /// No description provided for @internalError.
  ///
  /// In en, this message translates to:
  /// **'An internal error has occurred.'**
  String get internalError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @noUserLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'No user logged in'**
  String get noUserLoggedIn;

  /// No description provided for @usernameMissing.
  ///
  /// In en, this message translates to:
  /// **'Username is missing'**
  String get usernameMissing;

  /// No description provided for @passwordMissing.
  ///
  /// In en, this message translates to:
  /// **'Password is missing'**
  String get passwordMissing;

  /// No description provided for @passwordCantBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Password can\'t be changed'**
  String get passwordCantBeChanged;

  /// No description provided for @canteen.
  ///
  /// In en, this message translates to:
  /// **'Canteen'**
  String get canteen;

  /// No description provided for @invalidCanteenNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid canteen number'**
  String get invalidCanteenNumber;

  /// No description provided for @invalidCanteenNumberLength.
  ///
  /// In en, this message translates to:
  /// **'Invalid canteen number length, only allowed is 4'**
  String get invalidCanteenNumberLength;

  /// No description provided for @canteenNumberMissing.
  ///
  /// In en, this message translates to:
  /// **'Canteen number is missing'**
  String get canteenNumberMissing;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get checkConnection;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get offline;

  /// No description provided for @timedOut.
  ///
  /// In en, this message translates to:
  /// **'The request timed out'**
  String get timedOut;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @fillOutAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill out all fields'**
  String get fillOutAllFields;

  /// No description provided for @noCanteen.
  ///
  /// In en, this message translates to:
  /// **'No canteen, please log in'**
  String get noCanteen;

  /// No description provided for @emptyLesson.
  ///
  /// In en, this message translates to:
  /// **'Empty lesson'**
  String get emptyLesson;

  /// No description provided for @subjectHasntBeenAdded.
  ///
  /// In en, this message translates to:
  /// **'This subject hasn\'t been added yet.'**
  String get subjectHasntBeenAdded;

  /// No description provided for @importedSubject.
  ///
  /// In en, this message translates to:
  /// **'Imported subject'**
  String get importedSubject;

  /// No description provided for @tryImportingSubjectFromBakalari.
  ///
  /// In en, this message translates to:
  /// **'Try importing subjects from Bakaláři screen before.'**
  String get tryImportingSubjectFromBakalari;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @teacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get teacher;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @hwFromBaka.
  ///
  /// In en, this message translates to:
  /// **'Bakaláři homework'**
  String get hwFromBaka;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @newHomework.
  ///
  /// In en, this message translates to:
  /// **'New homework'**
  String get newHomework;

  /// No description provided for @homeworkAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'This homework has been already added'**
  String get homeworkAlreadyAdded;

  /// No description provided for @addAsHomework.
  ///
  /// In en, this message translates to:
  /// **'Add as homework'**
  String get addAsHomework;

  /// No description provided for @addAsExam.
  ///
  /// In en, this message translates to:
  /// **'Add as an exam'**
  String get addAsExam;

  /// No description provided for @bakalari.
  ///
  /// In en, this message translates to:
  /// **'Bakaláři'**
  String get bakalari;

  /// No description provided for @useBakalari.
  ///
  /// In en, this message translates to:
  /// **'Use Bakaláři'**
  String get useBakalari;

  /// No description provided for @bakalariDisabled.
  ///
  /// In en, this message translates to:
  /// **'Bakaláři disabled'**
  String get bakalariDisabled;

  /// No description provided for @loggedIn.
  ///
  /// In en, this message translates to:
  /// **'Logged in'**
  String get loggedIn;

  /// No description provided for @loggedOut.
  ///
  /// In en, this message translates to:
  /// **'Logged out'**
  String get loggedOut;

  /// No description provided for @schoolWebId.
  ///
  /// In en, this message translates to:
  /// **'School web'**
  String get schoolWebId;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @changeUsername.
  ///
  /// In en, this message translates to:
  /// **'Change username'**
  String get changeUsername;

  /// No description provided for @changeNickname.
  ///
  /// In en, this message translates to:
  /// **'Change nickname'**
  String get changeNickname;

  /// No description provided for @nicknameChanged.
  ///
  /// In en, this message translates to:
  /// **'Nickname changed successfully'**
  String get nicknameChanged;

  /// No description provided for @newUsername.
  ///
  /// In en, this message translates to:
  /// **'New username'**
  String get newUsername;

  /// No description provided for @newNickname.
  ///
  /// In en, this message translates to:
  /// **'New nickname'**
  String get newNickname;

  /// No description provided for @nicknameInfo.
  ///
  /// In en, this message translates to:
  /// **'Nickname is publicly visible to other users'**
  String get nicknameInfo;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @notMemberOfAnyGroup.
  ///
  /// In en, this message translates to:
  /// **'You aren\'t a member of any group'**
  String get notMemberOfAnyGroup;

  /// No description provided for @waitingForApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get waitingForApproval;

  /// No description provided for @removedFromGroup.
  ///
  /// In en, this message translates to:
  /// **'You have been removed from the group'**
  String get removedFromGroup;

  /// No description provided for @leaveOldGroup.
  ///
  /// In en, this message translates to:
  /// **'First leave the old group'**
  String get leaveOldGroup;

  /// No description provided for @cantLeaveYourGroup.
  ///
  /// In en, this message translates to:
  /// **'You can\'t leave the group you created, you have to delete it'**
  String get cantLeaveYourGroup;

  /// No description provided for @cantChangeGroupName.
  ///
  /// In en, this message translates to:
  /// **'You can\'t change this group\'s name'**
  String get cantChangeGroupName;

  /// No description provided for @subjectIsntShared.
  ///
  /// In en, this message translates to:
  /// **'The selected subject isn\'t shared'**
  String get subjectIsntShared;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeatPassword;

  /// No description provided for @notSamePassword.
  ///
  /// In en, this message translates to:
  /// **'The repeated password isn\'t the same.'**
  String get notSamePassword;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old password'**
  String get oldPassword;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @rememberMeTitle.
  ///
  /// In en, this message translates to:
  /// **'Remember me?'**
  String get rememberMeTitle;

  /// No description provided for @rememberMeWarning.
  ///
  /// In en, this message translates to:
  /// **'If you continue, you won\'t be able to view your current timetable and current homework.'**
  String get rememberMeWarning;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @importTimetableTitle.
  ///
  /// In en, this message translates to:
  /// **'Import timetable and subjects?'**
  String get importTimetableTitle;

  /// No description provided for @importTimetableWarning.
  ///
  /// In en, this message translates to:
  /// **'Importing the timetable will replace your existing timetable. Existing subjects will be reused. Are you sure?'**
  String get importTimetableWarning;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @importTimetable.
  ///
  /// In en, this message translates to:
  /// **'Import timetable and subjects'**
  String get importTimetable;

  /// No description provided for @changeDateTo.
  ///
  /// In en, this message translates to:
  /// **'Change date to'**
  String get changeDateTo;

  /// No description provided for @currentTimetable.
  ///
  /// In en, this message translates to:
  /// **'Current timetable'**
  String get currentTimetable;

  /// No description provided for @noTimetable.
  ///
  /// In en, this message translates to:
  /// **'No timetable found'**
  String get noTimetable;

  /// No description provided for @noHomework.
  ///
  /// In en, this message translates to:
  /// **'No homework found'**
  String get noHomework;

  /// No description provided for @noExams.
  ///
  /// In en, this message translates to:
  /// **'No exams found'**
  String get noExams;

  /// No description provided for @noRecentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'No recently deleted items found'**
  String get noRecentlyDeleted;

  /// No description provided for @timetable.
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get timetable;

  /// No description provided for @convertToHomework.
  ///
  /// In en, this message translates to:
  /// **'Convert to homework'**
  String get convertToHomework;

  /// No description provided for @convertToExam.
  ///
  /// In en, this message translates to:
  /// **'Convert to exam'**
  String get convertToExam;

  /// No description provided for @cloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync'**
  String get cloudSync;

  /// No description provided for @useCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Use cloud sync'**
  String get useCloudSync;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in'**
  String get loggingIn;

  /// No description provided for @youWereLoggedOut.
  ///
  /// In en, this message translates to:
  /// **'Logged out'**
  String get youWereLoggedOut;

  /// No description provided for @loggedInSynced.
  ///
  /// In en, this message translates to:
  /// **'Logged in, everything has been synced'**
  String get loggedInSynced;

  /// No description provided for @errorLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'There was an issue during the login.'**
  String get errorLoggingIn;

  /// No description provided for @errorRegistering.
  ///
  /// In en, this message translates to:
  /// **'There was an issue registering you.'**
  String get errorRegistering;

  /// No description provided for @errorChangingPassword.
  ///
  /// In en, this message translates to:
  /// **'There was an issue changing the password.'**
  String get errorChangingPassword;

  /// No description provided for @registeredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Registered successfully, everything has been synced'**
  String get registeredSuccessfully;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @repeatNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat new password'**
  String get repeatNewPassword;

  /// No description provided for @samePasswords.
  ///
  /// In en, this message translates to:
  /// **'The new password can\'t be the same as the old password.'**
  String get samePasswords;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get syncing;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @meals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// No description provided for @mealsNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Meals couldn\'t be loaded'**
  String get mealsNotLoaded;

  /// No description provided for @noMealsFound.
  ///
  /// In en, this message translates to:
  /// **'No meals found'**
  String get noMealsFound;

  /// No description provided for @noMealsOn.
  ///
  /// In en, this message translates to:
  /// **'No meals {date}'**
  String noMealsOn(Object date);

  /// No description provided for @mealsOn.
  ///
  /// In en, this message translates to:
  /// **'Meals {date}'**
  String mealsOn(Object date);

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// No description provided for @noLesson.
  ///
  /// In en, this message translates to:
  /// **'No lesson {whenText}'**
  String noLesson(Object whenText);

  /// No description provided for @addNewLessonTime.
  ///
  /// In en, this message translates to:
  /// **'Add new lesson time'**
  String get addNewLessonTime;

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

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @deleteAllLogs.
  ///
  /// In en, this message translates to:
  /// **'Delete all logs?'**
  String get deleteAllLogs;

  /// No description provided for @noLogsFound.
  ///
  /// In en, this message translates to:
  /// **'No logs found. Everything runs well!'**
  String get noLogsFound;

  /// No description provided for @shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get shortcuts;

  /// No description provided for @createHomework.
  ///
  /// In en, this message translates to:
  /// **'Create homework'**
  String get createHomework;

  /// No description provided for @createExam.
  ///
  /// In en, this message translates to:
  /// **'Create an exam'**
  String get createExam;

  /// No description provided for @shortcutWhenCreating.
  ///
  /// In en, this message translates to:
  /// **'When creating:'**
  String get shortcutWhenCreating;

  /// No description provided for @searchForSubject.
  ///
  /// In en, this message translates to:
  /// **'Search for a subject'**
  String get searchForSubject;

  /// No description provided for @choosePriority.
  ///
  /// In en, this message translates to:
  /// **'Choose a priority'**
  String get choosePriority;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @styleMotion.
  ///
  /// In en, this message translates to:
  /// **'Style & Motion'**
  String get styleMotion;

  /// No description provided for @styleMotionScreenSwitchAnimationTitle.
  ///
  /// In en, this message translates to:
  /// **'Screen switching animation duration'**
  String get styleMotionScreenSwitchAnimationTitle;

  /// No description provided for @styleMotionScreenSwitchAnimationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'In milliseconds (0 disables animation)'**
  String get styleMotionScreenSwitchAnimationSubtitle;

  /// No description provided for @styleMotionShowBorderTitle.
  ///
  /// In en, this message translates to:
  /// **'Show app border'**
  String get styleMotionShowBorderTitle;

  /// No description provided for @styleMotionShowBorderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On big screen or in landscape, show borders in the app'**
  String get styleMotionShowBorderSubtitle;

  /// No description provided for @expressiveHaptics.
  ///
  /// In en, this message translates to:
  /// **'Expressive haptics'**
  String get expressiveHaptics;

  /// No description provided for @expressiveHapticsSub.
  ///
  /// In en, this message translates to:
  /// **'Some UI elements vibrate with animations'**
  String get expressiveHapticsSub;

  /// No description provided for @themePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themePageTitle;

  /// No description provided for @themeBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get themeBrightness;

  /// No description provided for @themeFollowSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get themeFollowSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeOLEDTitle.
  ///
  /// In en, this message translates to:
  /// **'OLED black'**
  String get themeOLEDTitle;

  /// No description provided for @themeOLEDSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Works only in dark mode'**
  String get themeOLEDSubtitle;

  /// No description provided for @themeUseDeviceColors.
  ///
  /// In en, this message translates to:
  /// **'Use device colors'**
  String get themeUseDeviceColors;

  /// No description provided for @themeSystemColorWarning.
  ///
  /// In en, this message translates to:
  /// **'Currently using system color. If you want to use custom color, turn off Use device colors.'**
  String get themeSystemColorWarning;

  /// No description provided for @themeAppColor.
  ///
  /// In en, this message translates to:
  /// **'App color'**
  String get themeAppColor;

  /// No description provided for @themeSchemeVariant.
  ///
  /// In en, this message translates to:
  /// **'Scheme variant'**
  String get themeSchemeVariant;

  /// No description provided for @upcomingDayNotifications.
  ///
  /// In en, this message translates to:
  /// **'Upcoming day notifications'**
  String get upcomingDayNotifications;

  /// No description provided for @notificationsNotAllowedMessage.
  ///
  /// In en, this message translates to:
  /// **'Notifications not allowed, click here to grant permission'**
  String get notificationsNotAllowedMessage;

  /// No description provided for @upcomingDayNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications with homework and exams for the next day'**
  String get upcomingDayNotificationsDescription;

  /// No description provided for @upcomingDayNotificationsReceiveBeforeWeekend.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications before weekend'**
  String get upcomingDayNotificationsReceiveBeforeWeekend;

  /// No description provided for @upcomingDayNotificationsReceiveBeforeWeekendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If enabled, you will receive notifications even on Friday and Saturday'**
  String get upcomingDayNotificationsReceiveBeforeWeekendSubtitle;

  /// No description provided for @onWeekday.
  ///
  /// In en, this message translates to:
  /// **'On {weekday, select, 1{Monday} 2{Tuesday} 3{Wednesday} 4{Thursday} 5{Friday} 6{Saturday} 7{Sunday} other{unknown}}'**
  String onWeekday(String weekday);

  /// No description provided for @arrivalTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Arrival time'**
  String get arrivalTimeTitle;

  /// No description provided for @arrivalTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Time when the notification will arrive'**
  String get arrivalTimeSubtitle;

  /// No description provided for @sendNotificationNow.
  ///
  /// In en, this message translates to:
  /// **'Send upcoming day notification now'**
  String get sendNotificationNow;

  /// No description provided for @appDataLabel.
  ///
  /// In en, this message translates to:
  /// **'App data'**
  String get appDataLabel;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Exported successfully'**
  String get exportSuccess;

  /// No description provided for @aborted.
  ///
  /// In en, this message translates to:
  /// **'Aborted'**
  String get aborted;

  /// No description provided for @chooseSaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose a location for save file:'**
  String get chooseSaveLocation;

  /// No description provided for @pickSaveFile.
  ///
  /// In en, this message translates to:
  /// **'Pick a save file:'**
  String get pickSaveFile;

  /// Confirmation message asking to import subjects, homework, and exams with correct plurals
  ///
  /// In en, this message translates to:
  /// **'Do you want to import {subjectsCount} subject{subjectsCount, plural, =1{} other{s}}, {hwsCount} piece{hwsCount, plural, =1{} other{s}} of homework and {examsCount} exam{examsCount, plural, =1{} other{s}}?'**
  String importConfirmationText(
    num subjectsCount,
    num hwsCount,
    num examsCount,
  );

  /// No description provided for @importErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during import.'**
  String get importErrorMessage;

  /// No description provided for @initialPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Initial page'**
  String get initialPageTitle;

  /// No description provided for @initialPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The page that will be displayed when opening the app'**
  String get initialPageSubtitle;

  /// No description provided for @alreadyDeveloper.
  ///
  /// In en, this message translates to:
  /// **'You are already the developer'**
  String get alreadyDeveloper;

  /// No description provided for @pressMoreTimesToBecomeDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Press 2 more times to become the developer'**
  String get pressMoreTimesToBecomeDeveloper;

  /// No description provided for @becameDeveloper.
  ///
  /// In en, this message translates to:
  /// **'You are now the developer'**
  String get becameDeveloper;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @colorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color theme'**
  String get colorTheme;

  /// No description provided for @colorThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Customize the colors of the app'**
  String get colorThemeDescription;

  /// No description provided for @styleMotionDescription.
  ///
  /// In en, this message translates to:
  /// **'Customize animations and more'**
  String get styleMotionDescription;

  /// No description provided for @shortcutsDescription.
  ///
  /// In en, this message translates to:
  /// **'View keyboard shortcuts'**
  String get shortcutsDescription;

  /// No description provided for @stravaCz.
  ///
  /// In en, this message translates to:
  /// **'Strava.cz'**
  String get stravaCz;

  /// No description provided for @useStravaCz.
  ///
  /// In en, this message translates to:
  /// **'Use Strava.cz'**
  String get useStravaCz;

  /// No description provided for @viewAppChangelog.
  ///
  /// In en, this message translates to:
  /// **'View app changelog'**
  String get viewAppChangelog;

  /// No description provided for @developerMode.
  ///
  /// In en, this message translates to:
  /// **'Developer mode'**
  String get developerMode;

  /// No description provided for @useExperimentalHomeworkTileOverlay.
  ///
  /// In en, this message translates to:
  /// **'Use experimental homework tile overlay'**
  String get useExperimentalHomeworkTileOverlay;

  /// No description provided for @colorShowcaseTitle.
  ///
  /// In en, this message translates to:
  /// **'This is how the app will look with these colors:'**
  String get colorShowcaseTitle;

  /// No description provided for @filledButton.
  ///
  /// In en, this message translates to:
  /// **'Filled button'**
  String get filledButton;

  /// No description provided for @choiceChip.
  ///
  /// In en, this message translates to:
  /// **'Choice chip'**
  String get choiceChip;

  /// No description provided for @loginToStrava.
  ///
  /// In en, this message translates to:
  /// **'Login to Strava.cz'**
  String get loginToStrava;

  /// No description provided for @schoolCanteenId.
  ///
  /// In en, this message translates to:
  /// **'School canteen ID'**
  String get schoolCanteenId;

  /// No description provided for @schoolCanteenIdDescription.
  ///
  /// In en, this message translates to:
  /// **'School canteen id is a 4-digit number you use to login to your Strava app.'**
  String get schoolCanteenIdDescription;

  /// No description provided for @allowStravaLogin.
  ///
  /// In en, this message translates to:
  /// **'Allow logging in (experimental)'**
  String get allowStravaLogin;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @shortcutMax5Chars.
  ///
  /// In en, this message translates to:
  /// **'Shortcut (max 5 characters)'**
  String get shortcutMax5Chars;

  /// No description provided for @subjectUsedTimes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {This subject is used 1 time} other {This subject is used {count} times}}'**
  String subjectUsedTimes(num count);

  /// No description provided for @addNewSubject.
  ///
  /// In en, this message translates to:
  /// **'Add new subject'**
  String get addNewSubject;

  /// No description provided for @editSubject.
  ///
  /// In en, this message translates to:
  /// **'Edit subject'**
  String get editSubject;

  /// No description provided for @subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get subjects;

  /// No description provided for @noSubjectsFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No subjects found. You can create new subjects by tapping the plus button.'**
  String get noSubjectsFoundMessage;

  /// No description provided for @deletedSubjectMessage.
  ///
  /// In en, this message translates to:
  /// **'Deleted subject {name}'**
  String deletedSubjectMessage(Object name);

  /// No description provided for @createNewTimes.
  ///
  /// In en, this message translates to:
  /// **'Create new times:'**
  String get createNewTimes;

  /// No description provided for @deleteThisLesson.
  ///
  /// In en, this message translates to:
  /// **'Delete this lesson'**
  String get deleteThisLesson;

  /// No description provided for @beginningTime.
  ///
  /// In en, this message translates to:
  /// **'Beginning time:'**
  String get beginningTime;

  /// No description provided for @endingTime.
  ///
  /// In en, this message translates to:
  /// **'Ending time:'**
  String get endingTime;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selectSubject.
  ///
  /// In en, this message translates to:
  /// **'Select a subject:'**
  String get selectSubject;

  /// No description provided for @setToEmpty.
  ///
  /// In en, this message translates to:
  /// **'Set to empty'**
  String get setToEmpty;

  /// No description provided for @show7DayWeek.
  ///
  /// In en, this message translates to:
  /// **'Show 7 day week'**
  String get show7DayWeek;

  /// No description provided for @timetableTileWidth.
  ///
  /// In en, this message translates to:
  /// **'Tile width'**
  String get timetableTileWidth;

  /// No description provided for @permanentTimetable.
  ///
  /// In en, this message translates to:
  /// **'Permanent timetable'**
  String get permanentTimetable;

  /// No description provided for @recentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Recently deleted'**
  String get recentlyDeleted;

  /// No description provided for @showPerformanceOverlay.
  ///
  /// In en, this message translates to:
  /// **'Show performance overlay'**
  String get showPerformanceOverlay;

  /// No description provided for @showFirebaseOverlay.
  ///
  /// In en, this message translates to:
  /// **'Show firebase overlay'**
  String get showFirebaseOverlay;

  /// No description provided for @viewDatabase.
  ///
  /// In en, this message translates to:
  /// **'View database'**
  String get viewDatabase;

  /// No description provided for @viewLogs.
  ///
  /// In en, this message translates to:
  /// **'View logs'**
  String get viewLogs;

  /// No description provided for @viewTutorial.
  ///
  /// In en, this message translates to:
  /// **'View tutorial'**
  String get viewTutorial;

  /// No description provided for @dontViewTutorial.
  ///
  /// In en, this message translates to:
  /// **'Don\'t view tutorial'**
  String get dontViewTutorial;

  /// No description provided for @localization.
  ///
  /// In en, this message translates to:
  /// **'Localization'**
  String get localization;

  /// No description provided for @localizationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize language and date format'**
  String get localizationSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDefault.
  ///
  /// In en, this message translates to:
  /// **'Language default'**
  String get languageDefault;

  /// No description provided for @deviceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get deviceLanguage;

  /// No description provided for @h24timeFormat.
  ///
  /// In en, this message translates to:
  /// **'Force 24-hour time format'**
  String get h24timeFormat;

  /// No description provided for @h24timeFormatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Some languages support only 24-hour format'**
  String get h24timeFormatSubtitle;

  /// No description provided for @timeFormat12.
  ///
  /// In en, this message translates to:
  /// **'12-hour'**
  String get timeFormat12;

  /// No description provided for @timeFormat24.
  ///
  /// In en, this message translates to:
  /// **'24-hour'**
  String get timeFormat24;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get dateFormat;

  /// No description provided for @weekStartsOnMonday.
  ///
  /// In en, this message translates to:
  /// **'Week starts on monday'**
  String get weekStartsOnMonday;

  /// No description provided for @weekStartsOnMondaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'If enabled, first day of the week will be monday. Otherwise it will be Sunday.'**
  String get weekStartsOnMondaySubtitle;

  /// No description provided for @viewingOfflineTimetable.
  ///
  /// In en, this message translates to:
  /// **'Viewing offline timetable'**
  String get viewingOfflineTimetable;

  /// No description provided for @recover.
  ///
  /// In en, this message translates to:
  /// **'Recover'**
  String get recover;

  /// No description provided for @recoverInfoContent.
  ///
  /// In en, this message translates to:
  /// **'To recover something, tap on it and press recover. After 7 days, it will be deleted forever.'**
  String get recoverInfoContent;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day left} other{{count} days left}}'**
  String daysLeft(num count);

  /// No description provided for @defaultWord.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultWord;

  /// No description provided for @useDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Format: day month year'**
  String get useDateFormat;

  /// No description provided for @asDividerUse.
  ///
  /// In en, this message translates to:
  /// **'(as a divider use \"space\" / , . -)'**
  String get asDividerUse;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{Missed}}'**
  String missed(num count);

  /// No description provided for @nextNotificationInfo.
  ///
  /// In en, this message translates to:
  /// **'Next notification will arrive {dateWhen} at around {timeWhen}'**
  String nextNotificationInfo(Object dateWhen, Object timeWhen);

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notificationPermission;

  /// No description provided for @stopAsking.
  ///
  /// In en, this message translates to:
  /// **'Stop asking'**
  String get stopAsking;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @grant.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get grant;

  /// No description provided for @notificationPermissionBody1.
  ///
  /// In en, this message translates to:
  /// **'If you want this app to send you notifications, you need to grant it permission.'**
  String get notificationPermissionBody1;

  /// No description provided for @notificationPermissionBody2.
  ///
  /// In en, this message translates to:
  /// **'The Grant permission button will take you to app settings from where you can enable all notifications.'**
  String get notificationPermissionBody2;

  /// No description provided for @useExtensions.
  ///
  /// In en, this message translates to:
  /// **'You can use these extensions:'**
  String get useExtensions;

  /// No description provided for @bakalariSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import subjects and view current timetable'**
  String get bakalariSubtitle;

  /// No description provided for @stravaCzSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View meals in your canteen'**
  String get stravaCzSubtitle;

  /// No description provided for @cloudSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Backup and sync your data between devices'**
  String get cloudSyncSubtitle;

  /// No description provided for @goToApp.
  ///
  /// In en, this message translates to:
  /// **'Go to app'**
  String get goToApp;

  /// No description provided for @tutorialIntro.
  ///
  /// In en, this message translates to:
  /// **'Thank you for downloading Schoolarc. If you are new here, you can view a tutorial, which will explain the basics of the app. It will always be available to view later.'**
  String get tutorialIntro;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @tutorialHomeworkTitle.
  ///
  /// In en, this message translates to:
  /// **'This is homework:'**
  String get tutorialHomeworkTitle;

  /// No description provided for @tutorialExamTitle.
  ///
  /// In en, this message translates to:
  /// **'And this is an exam:'**
  String get tutorialExamTitle;

  /// No description provided for @tutorialHomeworkDelete.
  ///
  /// In en, this message translates to:
  /// **'This deletes the homework'**
  String get tutorialHomeworkDelete;

  /// No description provided for @tutorialExamDelete.
  ///
  /// In en, this message translates to:
  /// **'This deletes the exam'**
  String get tutorialExamDelete;

  /// No description provided for @tutorialPriorities.
  ///
  /// In en, this message translates to:
  /// **'Every homework and exam also have their priority. That priority is displayed by its color. Try changing it:'**
  String get tutorialPriorities;

  /// No description provided for @tutorialTryAssigningSubject.
  ///
  /// In en, this message translates to:
  /// **'You can assign each homework or exam to one subject. Try changing it:'**
  String get tutorialTryAssigningSubject;

  /// No description provided for @tutorialCreateSubjectsLater.
  ///
  /// In en, this message translates to:
  /// **'Create your subjects later in subjects screen inside the drawer.'**
  String get tutorialCreateSubjectsLater;

  /// No description provided for @tutorialCompleteHomework.
  ///
  /// In en, this message translates to:
  /// **'Great job! This completes the homework'**
  String get tutorialCompleteHomework;

  /// No description provided for @tutorialSlideToDelete.
  ///
  /// In en, this message translates to:
  /// **'You can also delete anything by sliding it to left and tapping delete.'**
  String get tutorialSlideToDelete;

  /// No description provided for @tutorialTapCheckbox.
  ///
  /// In en, this message translates to:
  /// **'And by tapping the checkbox on the right, you complete the homework.'**
  String get tutorialTapCheckbox;

  /// No description provided for @exampleSubjectName1.
  ///
  /// In en, this message translates to:
  /// **'Mathematics'**
  String get exampleSubjectName1;

  /// No description provided for @exampleSubjectShort1.
  ///
  /// In en, this message translates to:
  /// **'Math'**
  String get exampleSubjectShort1;

  /// No description provided for @exampleSubjectName2.
  ///
  /// In en, this message translates to:
  /// **'Biology'**
  String get exampleSubjectName2;

  /// No description provided for @exampleSubjectShort2.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get exampleSubjectShort2;

  /// No description provided for @exampleSubjectName3.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get exampleSubjectName3;

  /// No description provided for @exampleSubjectShort3.
  ///
  /// In en, this message translates to:
  /// **'Eng'**
  String get exampleSubjectShort3;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About app'**
  String get aboutApp;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report bug'**
  String get reportBug;

  /// No description provided for @reportBugPolicy.
  ///
  /// In en, this message translates to:
  /// **'By sending the report, you agree to share the included information for the purpose of fixing bugs.'**
  String get reportBugPolicy;

  /// No description provided for @viewLicenses.
  ///
  /// In en, this message translates to:
  /// **'View licenses'**
  String get viewLicenses;

  /// No description provided for @sendReport.
  ///
  /// In en, this message translates to:
  /// **'Send bug report?'**
  String get sendReport;

  /// No description provided for @sendAllReports.
  ///
  /// In en, this message translates to:
  /// **'Send report about all bugs?'**
  String get sendAllReports;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @deleteLog.
  ///
  /// In en, this message translates to:
  /// **'Delete log?'**
  String get deleteLog;

  /// No description provided for @bugReportHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the bug: You can also attach a screenshot.'**
  String get bugReportHint;

  /// No description provided for @cantOpenMail.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open email app'**
  String get cantOpenMail;

  /// No description provided for @secureLogin.
  ///
  /// In en, this message translates to:
  /// **'Login security'**
  String get secureLogin;

  /// No description provided for @secureLoginInfo.
  ///
  /// In en, this message translates to:
  /// **'Your login is stored securely on this device. It\'s never shared, sent anywhere, or accessible by other apps.'**
  String get secureLoginInfo;

  /// No description provided for @cantDeleteData.
  ///
  /// In en, this message translates to:
  /// **'Data wasn\'t deleted successfully. Try again.'**
  String get cantDeleteData;

  /// No description provided for @cantLogin.
  ///
  /// In en, this message translates to:
  /// **'Can\'t log in. Try again.'**
  String get cantLogin;

  /// No description provided for @couldntLogIn.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t log in.'**
  String get couldntLogIn;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllData;

  /// No description provided for @deletedAllData.
  ///
  /// In en, this message translates to:
  /// **'All data was deleted.'**
  String get deletedAllData;

  /// No description provided for @deleteAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteAllDataTitle;

  /// No description provided for @deleteAllDataText.
  ///
  /// In en, this message translates to:
  /// **'Deleting all data will clear your cloud backup and delete your account. Local data will remain intact. This action is irreversible. Are you sure you want to delete all data?'**
  String get deleteAllDataText;

  /// No description provided for @getAllData.
  ///
  /// In en, this message translates to:
  /// **'Download all data'**
  String get getAllData;

  /// No description provided for @agree.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get agree;

  /// No description provided for @disagree.
  ///
  /// In en, this message translates to:
  /// **'Disagree'**
  String get disagree;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @newHomeworkFound.
  ///
  /// In en, this message translates to:
  /// **'{count} new {count, plural, one{piece} other{pieces}} of homework found'**
  String newHomeworkFound(num count);

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'# Privacy policy\n\nEffective Date: 20.7.2025\n\nTo use Cloud sync, you have to agree to this privacy policy.\n ## What data is collected\n- Email address - used for login and account association\n- Subjects, exams, homework - uploaded to the cloud and synchronized between your devices\n\nYour data is not used for advertising or marketing\n\n## Your rights\nYou have the right to:\n- Request a copy of your data\n- Request your account and all data to be deleted\n\nBoth can be done directly in the app\n\n## Third Parties\nYour data is securely stored using Google Cloud Firebase'**
  String get privacyPolicy;

  /// No description provided for @cloudSyncDisabled.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync is disabled'**
  String get cloudSyncDisabled;

  /// No description provided for @cloudSyncDisabledWarning.
  ///
  /// In en, this message translates to:
  /// **'When running Schoolarc as a web app, it is highly recommended to enable Cloud sync to prevent data loss.'**
  String get cloudSyncDisabledWarning;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @keepDisabled.
  ///
  /// In en, this message translates to:
  /// **'Keep disabled'**
  String get keepDisabled;

  /// No description provided for @dontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get dontShowAgain;

  /// No description provided for @alreadyUsedApp.
  ///
  /// In en, this message translates to:
  /// **'Already used the app?'**
  String get alreadyUsedApp;

  /// No description provided for @secondShort.
  ///
  /// In en, this message translates to:
  /// **' sec'**
  String get secondShort;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **' min'**
  String get minutesShort;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hoursShort;

  /// No description provided for @daysShort.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get daysShort;
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
      <String>['cs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
