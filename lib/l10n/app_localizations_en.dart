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
  String missedHomework(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Missed homeworks',
      one: 'Missed homework',
    );
    return '$_temp0';
  }

  @override
  String upcomingHomework(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Upcoming homeworks',
      one: 'Upcoming homework',
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
  String get no => 'no';

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
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get added => 'Added';

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
  String homeworks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Homeworks',
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
  String homeworksFor(String isEmpty, Object whenText) {
    String _temp0 = intl.Intl.selectLogic(
      isEmpty,
      {
        'true': 'No homeworks',
        'other': 'Homeworks',
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
  String get showMyName => 'Show my name';

  @override
  String get showMyNameSubtitle => 'If enabled and logged in to Bakaláři, you will be greeted with your name';

  @override
  String get showBakalariTimetable => 'Show Bakaláři timetable';

  @override
  String get showMeals => 'Show meals';

  @override
  String get lunchTime => 'Lunch time';

  @override
  String get lunchTimeSubtitle => 'When meals for next day appear';

  @override
  String get initialDate => 'Initial date';

  @override
  String get showMissedHomeworks => 'Show missed homeworks';

  @override
  String get showArrows => 'Show arrows';

  @override
  String get showArrowsSubtitle => 'Show arrows for switching between pages';

  @override
  String get upcomingDayChannelDescription => 'Here you will find upcoming exams and homeworks';

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
  String get invalidCanteenNumber => 'Invalid canteen number';

  @override
  String get invalidCanteenNumberLength => 'Invalid canteen number length, only allowed is 4';

  @override
  String get canteenNumberMissing => 'Canteen number is missing';

  @override
  String get checkConnection => 'Check your internet connection';

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String get fillOutAllInfo => 'Please fill out all information';

  @override
  String get noCanteen => 'No canteen, please log in';

  @override
  String get emptyLesson => 'Empty lesson';

  @override
  String get subjectHasntBeenAdded => 'This subject hasn\\\'t been added.';

  @override
  String get importedSubject => 'Imported subject';

  @override
  String get change => 'Change';

  @override
  String get teacher => 'Teacher';

  @override
  String get room => 'Room';

  @override
  String get hwFromBaka => 'Homeworks from Bakaláři';

  @override
  String get noData => 'No data';

  @override
  String get newHomeworks => 'New homeworks';

  @override
  String get homeworkAlreadyAdded => 'This homework has been already added';

  @override
  String get addAsHomework => 'Add as homework';

  @override
  String get addAsExam => 'Add as an exam';

  @override
  String get bakalari => 'Bakaláři';

  @override
  String get loggedIn => 'Logged in';

  @override
  String get schoolWebId => 'School web';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get oldPassword => 'Old password';

  @override
  String get email => 'Email';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get rememberMeTitle => 'Remember me?';

  @override
  String get rememberMeWarning => 'If you continue, you won\'t be able to view your current timetable and current homeworks.';

  @override
  String get continueAction => 'Continue';

  @override
  String get logOut => 'Log out';

  @override
  String get importTimetableTitle => 'Import timetable and subjects?';

  @override
  String get importTimetableWarning => 'Importing the timetable will replace your existing timetable. Are you sure?';

  @override
  String get import => 'Import';

  @override
  String get importTimetable => 'Import timetable and subjects';

  @override
  String get changeDateTo => 'Change date to';

  @override
  String get currentTimetable => 'Current timetable';

  @override
  String get noTimetable => 'No timetable found';

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
  String get loggedOut => 'Logged out';

  @override
  String get loggedInSynced => 'Logged in, everything has been synced';

  @override
  String get registeredSuccessfully => 'Registered successfully';

  @override
  String get changePassword => 'Change password';

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
  String get noMealsFor => 'No meals for';

  @override
  String get mealsFor => 'Meals for';

  @override
  String get lessons => 'Lessons';

  @override
  String noLesson(Object whenText) {
    return 'No lesson $whenText';
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
  String get styleMotionScreenSwitchAnimationTitle => 'Screen switching animation duration';

  @override
  String get styleMotionScreenSwitchAnimationSubtitle => 'In milliseconds (0 disables animation)';

  @override
  String get styleMotionShowBorderTitle => 'Show app border';

  @override
  String get styleMotionShowBorderSubtitle => 'On big screen or in landscape, show borders in the app';

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
  String get themeSystemColorWarning => 'Currently using system color. If you want to use custom color, turn off Use device colors.';

  @override
  String get themeAppColor => 'App color';

  @override
  String get themeSchemeVariant => 'Scheme variant';

  @override
  String get upcomingDayNotifications => 'Upcoming day notifications';

  @override
  String get notificationsNotAllowedMessage => 'Notifications not allowed, click here to grant permission';

  @override
  String get upcomingDayNotificationsDescription => 'Receive notifications with homeworks and exams for the next day';

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
  String get chooseSaveLocation => 'Choose a location for save file:';

  @override
  String get pickSaveFile => 'Pick a save file:';

  @override
  String importConfirmationText(num subjectsCount, num hwsCount, num examsCount) {
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
  String get initialPageSubtitle => 'The page that will be displayed when opening the app';

  @override
  String get alreadyDeveloper => 'You are already the developer';

  @override
  String get pressMoreTimesToBecomeDeveloper => 'Press 2 more times to become the developer';

  @override
  String get becameDeveloper => 'You\'ve become the developer';

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
  String get viewAppChangelog => 'View app changelog';

  @override
  String get developerMode => 'Developer mode';

  @override
  String get useExperimentalHomeworkTileOverlay => 'Use experimental homework tile overlay';

  @override
  String get colorShowcaseTitle => 'This is how the app will look with these colors:';

  @override
  String get filledButton => 'Filled button';

  @override
  String get choiceChip => 'Choice chip';

  @override
  String get loginToStrava => 'Login to Strava.cz';

  @override
  String get schoolCanteenId => 'School canteen ID';

  @override
  String get schoolCanteenIdDescription => 'School canteen id is a 4-digit number you use to login to your Strava app.';

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
  String get noSubjectsFoundMessage => 'No subjects found. You can create new subjects by tapping the plus button.';

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
  String get localization => 'Localization';

  @override
  String get localizationSubtitle => 'Customize language and date format';

  @override
  String get language => 'Language';

  @override
  String get timeFormat => 'Time format';

  @override
  String get timeFormat12 => '12-hour';

  @override
  String get timeFormat24 => '24-hour';

  @override
  String get dateFormat => 'Date format';

  @override
  String get weekStartsOnMonday => 'Week starts on monday';

  @override
  String get weekStartsOnMondaySubtitle => 'If enabled, first day of the week will be monday. Else, it will be Sunday.';

  @override
  String get viewingOfflineTimetable => 'Viewing offline timetable';

  @override
  String get recover => 'Recover';

  @override
  String get recoverInfoContent => 'To recover something, tap on it and press recover. After 7 days, it will be deleted forever.';

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
  String get notificationPermissionBody1 => 'If you want this app to send you notifications, you need to grant it permission.';

  @override
  String get notificationPermissionBody2 => 'The Grant permission button will take you to app settings from where you can enable all notifications.';
}
