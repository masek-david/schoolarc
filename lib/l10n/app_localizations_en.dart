// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String greetingByHour(String hour) {
    String _temp0 = intl.Intl.selectLogic(
      hour,
      {
        'morning': 'Good morning',
        'afternoon': 'Good afternoon',
        'evening': 'Good evening',
        'night': 'Good night',
        'other': 'Hello',
      },
    );
    return '$_temp0';
  }

  @override
  String get youHave => 'You have';

  @override
  String get missedHomeworkTitle => 'Missed homework';

  @override
  String missedHomework(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Missed pieces of homework',
      one: 'Missed piece of homework',
    );
    return '$_temp0';
  }

  @override
  String upcomingHomework(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Upcoming pieces of homework',
      one: 'Upcoming piece of homework',
    );
    return '$_temp0';
  }

  @override
  String upcomingExams(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Upcoming exams',
      one: 'Upcoming exam',
    );
    return '$_temp0';
  }

  @override
  String get and => 'and';

  @override
  String get zero => 'no';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';

  @override
  String get noPriority => 'No priority';

  @override
  String get anotherYearBehind => 'Another year behind';

  @override
  String get viewYearStats => 'View stats about your year';

  @override
  String get importing => 'Importing';

  @override
  String get completed => 'Completed';

  @override
  String get deadline => 'Deadline';

  @override
  String get next => 'Next';

  @override
  String get now => 'Now';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get added => 'Added';

  @override
  String get addedHomework => 'Homework added';

  @override
  String get addedExam => 'Exam added';

  @override
  String get close => 'Close';

  @override
  String get undo => 'Undo';

  @override
  String get ok => 'Ok';

  @override
  String get login => 'Login';

  @override
  String get logIn => 'Log in';

  @override
  String get pleaseLogIn => 'Please log in';

  @override
  String get everythingDone => 'Everything done';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get description => 'Description';

  @override
  String get home => 'Home';

  @override
  String get calendar => 'Calendar';

  @override
  String get personal => 'Personal';

  @override
  String exams(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exams',
      one: 'Exam',
    );
    return '$_temp0';
  }

  @override
  String get addNewExam => 'Add new exam';

  @override
  String get addNewExamFor => 'Add new exam for';

  @override
  String get deletedExam => 'Deleted exam';

  @override
  String get toExam => 'To exam';

  @override
  String examsFor(String isEmpty, Object whenText) {
    String _temp0 = intl.Intl.selectLogic(
      isEmpty,
      {
        'true': 'No exams',
        'other': 'Exams',
      },
    );
    return '$_temp0 $whenText';
  }

  @override
  String examAbsence(String isAbsent) {
    String _temp0 = intl.Intl.selectLogic(
      isAbsent,
      {
        'true': 'No exams',
        'other': 'Exams',
      },
    );
    return '$_temp0';
  }

  @override
  String homework(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Homework',
      one: 'Homework',
    );
    return '$_temp0';
  }

  @override
  String get addNewHomework => 'Add new homework';

  @override
  String get addNewHomeworkFor => 'Add new homework for';

  @override
  String get deletedHomework => 'Deleted homework';

  @override
  String get toHomework => 'To homework';

  @override
  String homeworkFor(String isEmpty, Object whenText) {
    String _temp0 = intl.Intl.selectLogic(
      isEmpty,
      {
        'true': 'No homework',
        'other': 'Homework',
      },
    );
    return '$_temp0 $whenText';
  }

  @override
  String homeworkAbsence(String isAbsent) {
    String _temp0 = intl.Intl.selectLogic(
      isAbsent,
      {
        'true': 'No homework',
        'other': 'Homework',
      },
    );
    return '$_temp0';
  }

  @override
  String nothingPlannedFor(Object whenText) {
    return 'Nothing planned for $whenText';
  }

  @override
  String get nothingPlanned => 'Nothing planned';

  @override
  String get showMyName => 'Show my name';

  @override
  String get showMyNameSubtitle =>
      'If enabled and logged in to Bakaláři, you will be greeted with your name';

  @override
  String get showBakalariTimetable => 'Show Bakaláři timetable';

  @override
  String get showMeals => 'Show meals';

  @override
  String get mealsDisabled => 'Meals disabled';

  @override
  String get lunchTime => 'Lunch time';

  @override
  String get lunchTimeSubtitle => 'When meals for next day appear';

  @override
  String get initialDate => 'Initial date';

  @override
  String get showMissedHomework => 'Show missed homework';

  @override
  String get showArrows => 'Show arrows';

  @override
  String get showArrowsSubtitle => 'Show arrows for switching between pages';

  @override
  String get upcomingDayChannelDescription =>
      'Here you will find upcoming exams and homework';

  @override
  String get mainChannel => 'Main channel';

  @override
  String get mainChannelDescription => 'Main channel for notifications';

  @override
  String get internalError => 'An internal error has occurred.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get noUserLoggedIn => 'No user logged in';

  @override
  String get usernameMissing => 'Username is missing';

  @override
  String get passwordMissing => 'Password is missing';

  @override
  String get passwordCantBeChanged => 'Password can\'t be changed';

  @override
  String get canteen => 'Canteen';

  @override
  String get invalidCanteenNumber => 'Invalid canteen number';

  @override
  String get invalidCanteenNumberLength =>
      'Invalid canteen number length, only allowed is 4';

  @override
  String get canteenNumberMissing => 'Canteen number is missing';

  @override
  String get checkConnection => 'Check your internet connection';

  @override
  String get offline => 'You are offline';

  @override
  String get timedOut => 'The request timed out';

  @override
  String get serverError => 'Server error';

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String get fillOutAllFields => 'Please fill out all fields';

  @override
  String get noCanteen => 'No canteen, please log in';

  @override
  String get emptyLesson => 'Empty lesson';

  @override
  String get subjectHasntBeenAdded => 'This subject hasn\'t been added yet.';

  @override
  String get importedSubject => 'Imported subject';

  @override
  String get tryImportingSubjectFromBakalari =>
      'Try importing subjects from Bakaláři screen before.';

  @override
  String get change => 'Change';

  @override
  String get teacher => 'Teacher';

  @override
  String get room => 'Room';

  @override
  String get hwFromBaka => 'Bakaláři homework';

  @override
  String get noData => 'No data';

  @override
  String get newHomework => 'New homework';

  @override
  String get homeworkAlreadyAdded => 'This homework has been already added';

  @override
  String get addAsHomework => 'Add as homework';

  @override
  String get addAsExam => 'Add as an exam';

  @override
  String get bakalari => 'Bakaláři';

  @override
  String get useBakalari => 'Use Bakaláři';

  @override
  String get bakalariDisabled => 'Bakaláři disabled';

  @override
  String get loggedIn => 'Logged in';

  @override
  String get loggedOut => 'Logged out';

  @override
  String get schoolWebId => 'School web';

  @override
  String get username => 'Username';

  @override
  String get changeUsername => 'Change username';

  @override
  String get changeNickname => 'Change nickname';

  @override
  String get nicknameChanged => 'Nickname changed successfully';

  @override
  String get newUsername => 'New username';

  @override
  String get newNickname => 'New nickname';

  @override
  String get nicknameInfo => 'Nickname is publicly visible to other users';

  @override
  String get nickname => 'Nickname';

  @override
  String get group => 'Group';

  @override
  String get notMemberOfAnyGroup => 'You aren\'t a member of any group';

  @override
  String get waitingForApproval => 'Waiting for approval';

  @override
  String get removedFromGroup => 'You have been removed from the group';

  @override
  String get leaveOldGroup => 'First leave the old group';

  @override
  String get cantLeaveYourGroup =>
      'You can\'t leave the group you created, you have to delete it';

  @override
  String get cantChangeGroupName => 'You can\'t change this group\'s name';

  @override
  String get subjectIsntShared => 'The selected subject isn\'t shared';

  @override
  String get password => 'Password';

  @override
  String get repeatPassword => 'Repeat password';

  @override
  String get notSamePassword => 'The repeated password isn\'t the same.';

  @override
  String get oldPassword => 'Old password';

  @override
  String get email => 'Email';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get rememberMeTitle => 'Remember me?';

  @override
  String get rememberMeWarning =>
      'If you continue, you won\'t be able to view your current timetable and current homework.';

  @override
  String get continueAction => 'Continue';

  @override
  String get logOut => 'Log out';

  @override
  String get importTimetableTitle => 'Import timetable and subjects?';

  @override
  String get importTimetableWarning =>
      'Importing the timetable will replace your existing timetable. Existing subjects will be reused. Are you sure?';

  @override
  String get import => 'Import';

  @override
  String get importTimetable => 'Import timetable and subjects';

  @override
  String get changeDateTo => 'Change date to';

  @override
  String get currentTimetable => 'Current timetable';

  @override
  String get noTimetableMessage =>
      'You don\'t have any timetable. You can create time of lessons by tapping the plus button.';

  @override
  String get noHomework => 'No homework found';

  @override
  String get noExams => 'No exams found';

  @override
  String get noRecentlyDeleted => 'No recently deleted items found';

  @override
  String get timetable => 'Timetable';

  @override
  String get convertToHomework => 'Convert to homework';

  @override
  String get convertToExam => 'Convert to exam';

  @override
  String get cloudSync => 'Cloud sync';

  @override
  String get useCloudSync => 'Use cloud sync';

  @override
  String get register => 'Register';

  @override
  String get loggingIn => 'Logging in';

  @override
  String get youWereLoggedOut => 'Logged out';

  @override
  String get loggedInSynced => 'Logged in, everything has been synced';

  @override
  String get errorLoggingIn => 'There was an issue during the login.';

  @override
  String get errorRegistering => 'There was an issue registering you.';

  @override
  String get errorChangingPassword =>
      'There was an issue changing the password.';

  @override
  String get registeredSuccessfully =>
      'Registered successfully, everything has been synced';

  @override
  String get changePassword => 'Change password';

  @override
  String get newPassword => 'New password';

  @override
  String get repeatNewPassword => 'Repeat new password';

  @override
  String get samePasswords =>
      'The new password can\'t be the same as the old password.';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get syncing => 'Syncing';

  @override
  String get loading => 'Loading';

  @override
  String get meals => 'Meals';

  @override
  String get mealsNotLoaded => 'Meals couldn\'t be loaded';

  @override
  String get noMealsFound => 'No meals found';

  @override
  String noMealsOn(Object date) {
    return 'No meals $date';
  }

  @override
  String mealsOn(Object date) {
    return 'Meals $date';
  }

  @override
  String get lessons => 'Lessons';

  @override
  String noLesson(Object whenText) {
    return 'No lessons $whenText';
  }

  @override
  String get addNewLessonTime => 'Add new lesson time';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get logs => 'Logs';

  @override
  String get deleteAllLogs => 'Delete all logs?';

  @override
  String get noLogsFound => 'No logs found. Everything runs well!';

  @override
  String get shortcuts => 'Shortcuts';

  @override
  String get createHomework => 'Create homework';

  @override
  String get createExam => 'Create an exam';

  @override
  String get shortcutWhenCreating => 'When creating:';

  @override
  String get searchForSubject => 'Search for a subject';

  @override
  String get choosePriority => 'Choose a priority';

  @override
  String get pickDate => 'Pick a date';

  @override
  String get styleMotion => 'Style & Motion';

  @override
  String get styleMotionScreenSwitchAnimationTitle =>
      'Screen switching animation duration';

  @override
  String get styleMotionScreenSwitchAnimationSubtitle =>
      'In milliseconds (0 disables animation)';

  @override
  String get styleMotionShowBorderTitle => 'Show app border';

  @override
  String get styleMotionShowBorderSubtitle =>
      'On big screen or in landscape, show borders in the app';

  @override
  String get expressiveHaptics => 'Expressive haptics';

  @override
  String get expressiveHapticsSub => 'Some UI elements vibrate with animations';

  @override
  String get themePageTitle => 'Theme';

  @override
  String get themeBrightness => 'Brightness';

  @override
  String get themeFollowSystem => 'Follow system';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeOLEDTitle => 'OLED black';

  @override
  String get themeOLEDSubtitle => 'Works only in dark mode';

  @override
  String get themeUseDeviceColors => 'Use device colors';

  @override
  String get themeSystemColorWarning =>
      'Currently using system color. If you want to use custom color, turn off Use device colors.';

  @override
  String get themeAppColor => 'App color';

  @override
  String get themeSchemeVariant => 'Scheme variant';

  @override
  String get upcomingDayNotifications => 'Upcoming day notifications';

  @override
  String get receiveUpcomingDayNotifications =>
      'Receive notifications about upcoming day?';

  @override
  String get notificationsNotAllowedMessage =>
      'Notifications not allowed, click here to grant permission';

  @override
  String get upcomingDayNotificationsDescription =>
      'Receive notifications with homework and exams for the next day';

  @override
  String get upcomingDayNotificationsReceiveBeforeWeekend =>
      'Receive notifications before weekend';

  @override
  String get upcomingDayNotificationsReceiveBeforeWeekendSubtitle =>
      'If enabled, you will receive notifications even on Friday and Saturday';

  @override
  String get addWidgetToHomescreen => 'Add widget to home screen?';

  @override
  String get addMainWidget => 'Add main widget';

  @override
  String get addMealsWidget => 'Add meals widget';

  @override
  String onWeekday(String weekday) {
    String _temp0 = intl.Intl.selectLogic(
      weekday,
      {
        '1': 'Monday',
        '2': 'Tuesday',
        '3': 'Wednesday',
        '4': 'Thursday',
        '5': 'Friday',
        '6': 'Saturday',
        '7': 'Sunday',
        'other': 'unknown',
      },
    );
    return 'On $_temp0';
  }

  @override
  String get arrivalTimeTitle => 'Arrival time';

  @override
  String get arrivalTimeSubtitle => 'Time when the notification will arrive';

  @override
  String get sendNotificationNow => 'Send upcoming day notification now';

  @override
  String get appDataLabel => 'App data';

  @override
  String get export => 'Export';

  @override
  String get exportSuccess => 'Exported successfully';

  @override
  String get importSuccess => 'Imported successfully';

  @override
  String get aborted => 'Aborted';

  @override
  String get chooseSaveLocation => 'Choose a location for save file:';

  @override
  String get pickSaveFile => 'Pick a save file:';

  @override
  String importConfirmationText(
    num subjectsCount,
    num hwsCount,
    num examsCount,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      subjectsCount,
      locale: localeName,
      other: 's',
      one: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      hwsCount,
      locale: localeName,
      other: 's',
      one: '',
    );
    String _temp2 = intl.Intl.pluralLogic(
      examsCount,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Do you want to import $subjectsCount subject$_temp0, $hwsCount piece$_temp1 of homework and $examsCount exam$_temp2?';
  }

  @override
  String get importErrorMessage => 'An error occurred during import.';

  @override
  String get initialPageTitle => 'Initial page';

  @override
  String get initialPageSubtitle =>
      'The page that will be displayed when opening the app';

  @override
  String get alreadyDeveloper => 'You are already the developer';

  @override
  String get pressMoreTimesToBecomeDeveloper =>
      'Press 2 more times to become the developer';

  @override
  String get becameDeveloper => 'You are now the developer';

  @override
  String get settings => 'Settings';

  @override
  String get colorTheme => 'Color theme';

  @override
  String get colorThemeDescription => 'Customize the colors of the app';

  @override
  String get styleMotionDescription => 'Customize animations and more';

  @override
  String get shortcutsDescription => 'View keyboard shortcuts';

  @override
  String get stravaCz => 'Strava.cz';

  @override
  String get useStravaCz => 'Use Strava.cz';

  @override
  String get viewAppChangelog => 'View app changelog';

  @override
  String get developerMode => 'Developer mode';

  @override
  String get useExperimentalHomeworkTileOverlay =>
      'Use experimental homework tile overlay';

  @override
  String get colorShowcaseTitle =>
      'This is how the app will look with these colors:';

  @override
  String get filledButton => 'Filled button';

  @override
  String get choiceChip => 'Choice chip';

  @override
  String get loginToStrava => 'Login to Strava.cz';

  @override
  String get schoolCanteenId => 'School canteen ID';

  @override
  String get schoolCanteenIdDescription =>
      'School canteen id is a 4-digit number you use to login to your Strava app.';

  @override
  String get allowStravaLogin => 'Allow logging in (experimental)';

  @override
  String get name => 'Name';

  @override
  String get shortcutMax5Chars => 'Shortcut (max 5 characters)';

  @override
  String subjectUsedTimes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This subject is used $count times',
      one: 'This subject is used 1 time',
    );
    return '$_temp0';
  }

  @override
  String get addNewSubject => 'Add new subject';

  @override
  String get editSubject => 'Edit subject';

  @override
  String get subjects => 'Subjects';

  @override
  String get noSubjectsMessage =>
      'You don\'t have any subjects. You can create new subjects by tapping the plus button.';

  @override
  String deletedSubjectMessage(Object name) {
    return 'Deleted subject $name';
  }

  @override
  String get createNewTimes => 'Create new times:';

  @override
  String get deleteThisLesson => 'Delete this lesson';

  @override
  String get beginningTime => 'Beginning time:';

  @override
  String get endingTime => 'Ending time:';

  @override
  String get select => 'Select';

  @override
  String get selectSubject => 'Select a subject:';

  @override
  String get setToEmpty => 'Set to empty';

  @override
  String get show7DayWeek => 'Show 7 day week';

  @override
  String get timetableTileWidth => 'Tile width';

  @override
  String get permanentTimetable => 'Permanent timetable';

  @override
  String get recentlyDeleted => 'Recently deleted';

  @override
  String get showPerformanceOverlay => 'Show performance overlay';

  @override
  String get showFirebaseOverlay => 'Show firebase overlay';

  @override
  String get viewDatabase => 'View database';

  @override
  String get viewLogs => 'View logs';

  @override
  String get viewTutorial => 'View tutorial';

  @override
  String get dontViewTutorial => 'Don\'t view tutorial';

  @override
  String get tutorialCompleted => 'Tutorial completed';

  @override
  String get localization => 'Localization';

  @override
  String get localizationSubtitle => 'Customize language and date format';

  @override
  String get language => 'Language';

  @override
  String get languageDefault => 'Language default';

  @override
  String get deviceLanguage => 'Device language';

  @override
  String get h24timeFormat => 'Force 24-hour time format';

  @override
  String get h24timeFormatSubtitle =>
      'Some languages support only 24-hour format';

  @override
  String get timeFormat12 => '12-hour';

  @override
  String get timeFormat24 => '24-hour';

  @override
  String get dateFormat => 'Date format';

  @override
  String get weekStartsOnMonday => 'Week starts on monday';

  @override
  String get weekStartsOnMondaySubtitle =>
      'If enabled, first day of the week will be monday. Otherwise it will be Sunday.';

  @override
  String get viewingOfflineTimetable => 'Viewing offline timetable';

  @override
  String get recover => 'Recover';

  @override
  String get recoverInfoContent =>
      'To recover something, tap on it and press recover. After 7 days, it will be deleted forever.';

  @override
  String daysLeft(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get defaultWord => 'Default';

  @override
  String get useDateFormat => 'Format: day month year';

  @override
  String get asDividerUse => '(as a divider use \"space\" / , . -)';

  @override
  String missed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Missed',
    );
    return '$_temp0';
  }

  @override
  String nextNotificationInfo(Object dateWhen, Object timeWhen) {
    return 'Next notification will arrive $dateWhen at around $timeWhen';
  }

  @override
  String get notificationPermission => 'Notification Permission';

  @override
  String get stopAsking => 'Stop asking';

  @override
  String get later => 'Later';

  @override
  String get grant => 'Grant';

  @override
  String get notificationPermissionBody1 =>
      'If you want this app to send you notifications, you need to grant it permission.';

  @override
  String get notificationPermissionBody2 =>
      'The Grant permission button will take you to app settings from where you can enable all notifications.';

  @override
  String get useExtensions => 'You can use these extensions:';

  @override
  String get bakalariSubtitle => 'Import subjects and view current timetable';

  @override
  String get stravaCzSubtitle => 'View meals in your canteen';

  @override
  String get cloudSyncSubtitle => 'Backup and sync your data between devices';

  @override
  String get goToApp => 'Go to app';

  @override
  String get welcome => 'Welcome';

  @override
  String get onboardingWelcome =>
      'Thank you for downloading Schoolarc. If you are new here, you can view a tutorial, which will explain the basics of the app. It will always be available to view later.';

  @override
  String get setupComplete => 'Setup completed';

  @override
  String get continueToApp => 'Continue to app';

  @override
  String get restoreData => 'Restore data';

  @override
  String get restoreDataChoiceTitle => 'How do you want to restore your data?';

  @override
  String get importBackupFile => 'Import backup file';

  @override
  String get importBackupFileSub =>
      'Export .json from your old device and import here';

  @override
  String get skipRestoringQ => 'Skip restoring?';

  @override
  String get skipRestoring => 'Skip restoring';

  @override
  String get skipRestoringSub =>
      'You will be able to restore your data even if you skip here. However, skipping restoring data can cause some conflicts.';

  @override
  String get newUser => 'New user';

  @override
  String get returningUser => 'Returning user';

  @override
  String get skip => 'Skip';

  @override
  String get tutorialHomeworkTitle => 'This is homework:';

  @override
  String get tutorialExamTitle => 'And this is an exam:';

  @override
  String get tutorialHomeworkDelete => 'This deletes the homework';

  @override
  String get tutorialExamDelete => 'This deletes the exam';

  @override
  String get tutorialPriorities =>
      'Every homework and exam also have their priority. That priority is displayed by its color. Try changing it:';

  @override
  String get tutorialTryAssigningSubject =>
      'You can assign each homework or exam to one subject. Try changing it:';

  @override
  String get tutorialCreateSubjectsLater =>
      'Create your subjects later in subjects screen inside the drawer.';

  @override
  String get tutorialCompleteHomework =>
      'Great job! This completes the homework';

  @override
  String get tutorialSlideToDelete =>
      'You can also delete anything by sliding it to left and tapping delete.';

  @override
  String get tutorialTapCheckbox =>
      'And by tapping the checkbox on the right, you complete the homework.';

  @override
  String get exampleSubjectName1 => 'Mathematics';

  @override
  String get exampleSubjectShort1 => 'Math';

  @override
  String get exampleSubjectName2 => 'Biology';

  @override
  String get exampleSubjectShort2 => 'Bio';

  @override
  String get exampleSubjectName3 => 'English';

  @override
  String get exampleSubjectShort3 => 'Eng';

  @override
  String get aboutApp => 'About app';

  @override
  String get reportBug => 'Report bug';

  @override
  String get reportBugPolicy =>
      'By sending the report, you agree to share the included information for the purpose of fixing bugs.';

  @override
  String get viewLicenses => 'View licenses';

  @override
  String get sendReport => 'Send bug report?';

  @override
  String get sendAllReports => 'Send report about all bugs?';

  @override
  String get send => 'Send';

  @override
  String get deleteLog => 'Delete log?';

  @override
  String get bugReportHint =>
      'Describe the bug: You can also attach a screenshot.';

  @override
  String get cantOpenMail => 'Couldn\'t open email app';

  @override
  String get secureLogin => 'Login security';

  @override
  String get secureLoginInfo =>
      'Your login is stored securely on this device. It\'s never shared, sent anywhere, or accessible by other apps.';

  @override
  String get cantDeleteData => 'Data wasn\'t deleted successfully. Try again.';

  @override
  String get cantLogin => 'Can\'t log in. Try again.';

  @override
  String get couldntLogIn => 'Couldn\'t log in.';

  @override
  String get deleteAllData => 'Delete all data';

  @override
  String get deletedAllData => 'All data was deleted.';

  @override
  String get deleteAllDataTitle => 'Delete all data?';

  @override
  String get deleteAllDataText =>
      'Deleting all data will clear your cloud backup and delete your account. Local data will remain intact. This action is irreversible. Are you sure you want to delete all data?';

  @override
  String get getAllData => 'Download all data';

  @override
  String get agree => 'Agree';

  @override
  String get disagree => 'Disagree';

  @override
  String get view => 'View';

  @override
  String newHomeworkFound(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pieces',
      one: 'piece',
    );
    return '$count new $_temp0 of homework found';
  }

  @override
  String get privacyPolicy =>
      '# Privacy Policy\nEffective Date: 11. January 2026\nBy using Schoolarc, you agree to this Privacy Policy. This Privacy Policy may be updated.\nSchoolarc is offline first, however it includes some online features.\nThe developer is not responsible for any data loss caused by device failure, app removal, software bugs, or unauthorized access.\n## Cloud Sync\n### What data is collected\n- Email address - used for login and account association\n- Subjects, exams, homework - uploaded to the cloud and synchronized between your devices\nYour data is not used for advertising or marketing.\n### Your rights\nYou have the right to:\n- Request a copy of your data\n- Request your account and all your data to be deleted\nBoth can be done directly in the app.\n### Third-party services\nCloud Sync data is stored on servers located in the European Union (Belgium) using Google Cloud Firebase.';

  @override
  String get privacyPolicyAgree =>
      'By continuing, you agree to our Privacy Policy (click to view)';

  @override
  String get cloudSyncDisabled => 'Cloud sync is disabled';

  @override
  String get cloudSyncDisabledWarning =>
      'When running Schoolarc as a web app, it is highly recommended to enable Cloud sync to prevent data loss.';

  @override
  String get enable => 'Enable';

  @override
  String get keepDisabled => 'Keep disabled';

  @override
  String get dontShowAgain => 'Don\'t show again';

  @override
  String get alreadyUsedApp => 'Already used the app?';

  @override
  String get sorry => 'Sorry';

  @override
  String get versionNotSupported =>
      'This version of Schoolarc is not supported anymore.';

  @override
  String get pleaseUpdateApp => 'Please update the app.';

  @override
  String get secondShort => ' sec';

  @override
  String get minutesShort => ' min';

  @override
  String get hoursShort => 'h';

  @override
  String get daysShort => 'd';
}
