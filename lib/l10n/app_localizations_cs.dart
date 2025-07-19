// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String greetingByHour(String hour) {
    String _temp0 = intl.Intl.selectLogic(
      hour,
      {
        'morning': 'Dobré ráno',
        'afternoon': 'Dobré odpoledne',
        'evening': 'Dobrý večer',
        'night': 'Dobrou noc',
        'other': 'Ahoj',
      },
    );
    return '$_temp0';
  }

  @override
  String get youHave => 'Máte';

  @override
  String missedHomework(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zmeškaných úkolů',
      few: 'Zmeškané úkoly',
      one: 'Zmeškaný úkol',
      zero: 'Zmeškaných úkolů',
    );
    return '$_temp0';
  }

  @override
  String upcomingHomework(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nadcházejících úkolů',
      few: 'Nadcházející úkoly',
      one: 'Nadcházející úkol',
      zero: 'Nadcházejících úkolů',
    );
    return '$_temp0';
  }

  @override
  String upcomingExams(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nadcházejících testů',
      few: 'Nadcházející testy',
      one: 'Nadcházející test',
      zero: 'Nadcházejících testů',
    );
    return '$_temp0';
  }

  @override
  String get and => 'a';

  @override
  String get zero => '0';

  @override
  String get no => 'žádný';

  @override
  String get high => 'Vysoká';

  @override
  String get medium => 'Střední';

  @override
  String get low => 'Nízká';

  @override
  String get noPriority => 'Bez priority';

  @override
  String get anotherYearBehind => 'Další rok za námi';

  @override
  String get viewYearStats => 'Zobrazit statistiky vašeho roku';

  @override
  String get importing => 'Importování';

  @override
  String get completed => 'Dokončeno';

  @override
  String get deadline => 'Termín';

  @override
  String get next => 'Další';

  @override
  String get now => 'Teď';

  @override
  String get today => 'Dnes';

  @override
  String get tomorrow => 'Zítra';

  @override
  String get yesterday => 'Včera';

  @override
  String get cancel => 'Zrušit';

  @override
  String get save => 'Uložit';

  @override
  String get add => 'Přidat';

  @override
  String get added => 'Přidáno';

  @override
  String get close => 'Zavřít';

  @override
  String get undo => 'Zpět';

  @override
  String get ok => 'Ok';

  @override
  String get login => 'Přihlásit se';

  @override
  String get logIn => 'Přihlásit se';

  @override
  String get pleaseLogIn => 'Prosím, přihlaste se';

  @override
  String get everythingDone => 'Všechno hotovo';

  @override
  String get error => 'Chyba';

  @override
  String get success => 'Úspěch';

  @override
  String get description => 'Popis';

  @override
  String get home => 'Domů';

  @override
  String get calendar => 'Kalendář';

  @override
  String exams(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Testů',
      few: 'Testy',
      one: 'Test',
    );
    return '$_temp0';
  }

  @override
  String get addNewExam => 'Přidat nový test';

  @override
  String get addNewExamFor => 'Přidat nový test na';

  @override
  String get deletedExam => 'Smazán test';

  @override
  String get toExam => 'Jako test';

  @override
  String examsFor(String isEmpty, Object whenText) {
    String _temp0 = intl.Intl.selectLogic(
      isEmpty,
      {
        'true': '$whenText žádné testy',
        'other': 'Testy na $whenText',
      },
    );
    return '$_temp0';
  }

  @override
  String examAbsence(String isAbsent) {
    String _temp0 = intl.Intl.selectLogic(
      isAbsent,
      {
        'true': 'Žádné testy',
        'other': 'Testy',
      },
    );
    return '$_temp0';
  }

  @override
  String homeworks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Úkolů',
      few: 'Úkoly',
      one: 'Úkol',
    );
    return '$_temp0';
  }

  @override
  String get addNewHomework => 'Přidat nový úkol';

  @override
  String get addNewHomeworkFor => 'Přidat nový úkol na';

  @override
  String get deletedHomework => 'Smazán úkol';

  @override
  String get toHomework => 'Jako úkol';

  @override
  String homeworksFor(String isEmpty, Object whenText) {
    String _temp0 = intl.Intl.selectLogic(
      isEmpty,
      {
        'true': '$whenText žádné úkoly',
        'other': 'Úkoly na $whenText',
      },
    );
    return '$_temp0';
  }

  @override
  String homeworkAbsence(String isAbsent) {
    String _temp0 = intl.Intl.selectLogic(
      isAbsent,
      {
        'true': 'Žádné úkoly',
        'other': 'Úkoly',
      },
    );
    return '$_temp0';
  }

  @override
  String get showMyName => 'Zobrazit moje jméno';

  @override
  String get showMyNameSubtitle => 'Pokud je povoleno a jste přihlášeni do Bakalářů, budete uvítáni svým jménem';

  @override
  String get showBakalariTimetable => 'Zobrazit rozvrh z Bakalářů';

  @override
  String get showMeals => 'Zobrazit jídla';

  @override
  String get lunchTime => 'Čas oběda';

  @override
  String get lunchTimeSubtitle => 'Kdy se zobrazí jídla na další den';

  @override
  String get initialDate => 'Počáteční datum';

  @override
  String get showMissedHomeworks => 'Zobrazit zmeškané úkoly';

  @override
  String get showArrows => 'Zobrazit šipky';

  @override
  String get showArrowsSubtitle => 'Zobrazit šipky pro přepínání mezi stránkami';

  @override
  String get upcomingDayChannelDescription => 'Zde najdete nadcházející testy a úkoly';

  @override
  String get mainChannel => 'Hlavní kanál';

  @override
  String get mainChannelDescription => 'Hlavní kanál pro oznámení';

  @override
  String get internalError => 'Došlo k vnitřní chybě.';

  @override
  String get tryAgain => 'Zkuste to znovu';

  @override
  String get noUserLoggedIn => 'Není přihlášen žádný uživatel';

  @override
  String get usernameMissing => 'Chybí uživatelské jméno';

  @override
  String get passwordMissing => 'Chybí heslo';

  @override
  String get passwordCantBeChanged => 'Heslo nelze změnit';

  @override
  String get invalidCanteenNumber => 'Neplatné číslo jídelny';

  @override
  String get invalidCanteenNumberLength => 'Neplatná délka čísla jídelny, povoleny jsou pouze 4 číslice';

  @override
  String get canteenNumberMissing => 'Chybí číslo jídelny';

  @override
  String get checkConnection => 'Zkontrolujte připojení k internetu';

  @override
  String get unexpectedError => 'Došlo k neočekávané chybě';

  @override
  String get fillOutAllInfo => 'Vyplňte prosím všechny informace';

  @override
  String get noCanteen => 'Žádná jídelna, prosím přihlaste se';

  @override
  String get emptyLesson => 'Prázdná hodina';

  @override
  String get subjectHasntBeenAdded => 'Tento předmět nebyl přidán.';

  @override
  String get importedSubject => 'Importován předmět';

  @override
  String get change => 'Změna';

  @override
  String get teacher => 'Učitel';

  @override
  String get room => 'Třída';

  @override
  String get hwFromBaka => 'Úkoly z Bakalářů';

  @override
  String get noData => 'Žádná data';

  @override
  String get newHomeworks => 'Nové úkoly';

  @override
  String get homeworkAlreadyAdded => 'Tento úkol již byl přidán';

  @override
  String get addAsHomework => 'Přidat jako úkol';

  @override
  String get addAsExam => 'Přidat jako test';

  @override
  String get bakalari => 'Bakaláři';

  @override
  String get loggedIn => 'Přihlášeni';

  @override
  String get schoolWebId => 'Školní web';

  @override
  String get username => 'Uživatelské jméno';

  @override
  String get password => 'Heslo';

  @override
  String get oldPassword => 'Staré heslo';

  @override
  String get email => 'Email';

  @override
  String get rememberMe => 'Zapamatovat si mě';

  @override
  String get rememberMeTitle => 'Zapamatovat si mě?';

  @override
  String get rememberMeWarning => 'Pokud budete pokračovat, nebude možné zobrazit aktuální rozvrh a aktuální úkoly.';

  @override
  String get continueAction => 'Pokračovat';

  @override
  String get logOut => 'Odhlásit se';

  @override
  String get importTimetableTitle => 'Importovat rozvrh a předměty?';

  @override
  String get importTimetableWarning => 'Importování rozvrhu přepíše váš současný rozvrh. Chcete pokračovat?';

  @override
  String get import => 'Importovat';

  @override
  String get importTimetable => 'Importovat rozvrh a předměty';

  @override
  String get changeDateTo => 'Změnit datum na';

  @override
  String get currentTimetable => 'Aktuální rozvrh';

  @override
  String get noTimetable => 'Nebyl nalezen žádný rozvrh';

  @override
  String get noHomeworks => 'Nebyly nalezeny žádné úkoly';

  @override
  String get noRecentlyDeleted => 'Nebyly nalezeny žádné nedávno smazané položky';

  @override
  String get timetable => 'Rozvrh';

  @override
  String get convertToHomework => 'Převést na úkol';

  @override
  String get convertToExam => 'Převést na test';

  @override
  String get cloudSync => 'Synchronizace';

  @override
  String get useCloudSync => 'Používat synchronizaci';

  @override
  String get register => 'Registrovat se';

  @override
  String get loggingIn => 'Přihlašování';

  @override
  String get loggedOut => 'Byli jste odhlášeni';

  @override
  String get loggedInSynced => 'Byli jste přihlášeni, vše je synchronizováno';

  @override
  String get registeredSuccessfully => 'Byli jste úspěšně registrováni';

  @override
  String get changePassword => 'Změnit heslo';

  @override
  String get passwordChangedSuccessfully => 'Heslo bylo úspěšně změněno';

  @override
  String get syncing => 'Synchronizování';

  @override
  String get loading => 'Načítání';

  @override
  String get meals => 'Jídla';

  @override
  String get mealsNotLoaded => 'Jídla se nepodařilo načíst';

  @override
  String get noMealsFound => 'Nebyla nalezena žádná jídla';

  @override
  String get noMealsFor => 'Žádná jídla na';

  @override
  String get mealsFor => 'Jídla na';

  @override
  String get lessons => 'Hodiny';

  @override
  String noLesson(Object whenText) {
    return '$whenText žádné hodiny';
  }

  @override
  String get addNewLessonTime => 'Přidat nový čas hodiny';

  @override
  String get delete => 'Smazat';

  @override
  String get edit => 'Upravit';

  @override
  String get logs => 'Záznamy';

  @override
  String get deleteAllLogs => 'Smazat všechny záznamy?';

  @override
  String get noLogsFound => 'Nebyly nalezeny žádné záznamy. Vše beží v pořádku!';

  @override
  String get shortcuts => 'Klávesové zkratky';

  @override
  String get createHomework => 'Vytvořit úkol';

  @override
  String get createExam => 'Vytvořit test';

  @override
  String get shortcutWhenCreating => 'Při vytváření:';

  @override
  String get searchForSubject => 'Vyhledat předmět';

  @override
  String get choosePriority => 'Vybrat prioritu';

  @override
  String get pickDate => 'Vybrat datum';

  @override
  String get styleMotion => 'Styl & Pohyb';

  @override
  String get styleMotionScreenSwitchAnimationTitle => 'Doba přechodu obrazovky';

  @override
  String get styleMotionScreenSwitchAnimationSubtitle => 'V milisekundách (0 vypne animaci)';

  @override
  String get styleMotionShowBorderTitle => 'Zobrazit okraj aplikace';

  @override
  String get styleMotionShowBorderSubtitle => 'Na velké obrazovce, nebo když je aplikace na šířku, zobrazí okraje v aplikaci';

  @override
  String get themePageTitle => 'Motiv';

  @override
  String get themeBrightness => 'Jas';

  @override
  String get themeFollowSystem => 'Podle systému';

  @override
  String get themeLight => 'Světlý';

  @override
  String get themeDark => 'Tmavý';

  @override
  String get themeOLEDTitle => 'OLED černá';

  @override
  String get themeOLEDSubtitle => 'Funguje pouze v tmavém režimu';

  @override
  String get themeUseDeviceColors => 'Použít barvy zařízení';

  @override
  String get themeSystemColorWarning => 'Momentálně používáte systémovou barvu. Pokud chcete vybrat vlastní barvu, vypněte Použít barvy zařízení.';

  @override
  String get themeAppColor => 'Barva aplikace';

  @override
  String get themeSchemeVariant => 'Varianta motivu';

  @override
  String get upcomingDayNotifications => 'Oznámení o dalším dni';

  @override
  String get notificationsNotAllowedMessage => 'Oznámení nejsou povolena, klikněte zde pro udělení oprávnění';

  @override
  String get upcomingDayNotificationsDescription => 'Dostávejte oznámení o úkolech a testech na další den';

  @override
  String get arrivalTimeTitle => 'Čas doručení';

  @override
  String get arrivalTimeSubtitle => 'Čas, kdy dostanete oznámení';

  @override
  String get sendNotificationNow => 'Poslat oznámení na nadcházející den teď';

  @override
  String get appDataLabel => 'Data aplikace';

  @override
  String get export => 'Exportovat';

  @override
  String get chooseSaveLocation => 'Vybertre umístění pro uložení souboru:';

  @override
  String get pickSaveFile => 'Vyberte soubor:';

  @override
  String importConfirmationText(num subjectsCount, num hwsCount, num examsCount) {
    String _temp0 = intl.Intl.pluralLogic(
      subjectsCount,
      locale: localeName,
      other: 'předmětů',
      few: 'předměty',
      one: 'předmět',
      zero: 'předmětů',
    );
    String _temp1 = intl.Intl.pluralLogic(
      hwsCount,
      locale: localeName,
      other: 'úkolů',
      few: 'úkoly',
      one: 'úkol',
      zero: 'úkolů',
    );
    String _temp2 = intl.Intl.pluralLogic(
      examsCount,
      locale: localeName,
      other: 'testů',
      few: 'testy',
      one: 'test',
      zero: 'testů',
    );
    return 'Chcete importovat $subjectsCount $_temp0, $hwsCount $_temp1 a $examsCount exam$_temp2?';
  }

  @override
  String get importErrorMessage => 'Při importování došlo k chybě.';

  @override
  String get initialPageTitle => 'Výchozí stránka';

  @override
  String get initialPageSubtitle => 'Výchozí stránka bude zobrazena při otevření aplikace';

  @override
  String get alreadyDeveloper => 'Již jste vývojář';

  @override
  String get pressMoreTimesToBecomeDeveloper => 'Po dvou dalších kliknutích se z vás stane vývojář';

  @override
  String get becameDeveloper => 'Stali jste se vývojářem';

  @override
  String get settings => 'Nastavení';

  @override
  String get colorTheme => 'Barevný motiv';

  @override
  String get colorThemeDescription => 'Přizpůsobte barvy aplikace';

  @override
  String get styleMotionDescription => 'Přizpůsobte animace a více';

  @override
  String get shortcutsDescription => 'Zobrazit klávesové zkratky';

  @override
  String get stravaCz => 'Strava.cz';

  @override
  String get viewAppChangelog => 'Zobrazit změny aplikace';

  @override
  String get developerMode => 'Režim vývojáře';

  @override
  String get useExperimentalHomeworkTileOverlay => 'Používat experimentální překrývané okno úkolu';

  @override
  String get colorShowcaseTitle => 'Takto bude aplikace vypadat s těmito barvami:';

  @override
  String get filledButton => 'Tlačítko';

  @override
  String get choiceChip => 'Výběr';

  @override
  String get loginToStrava => 'Přihlásit se do Strava.cz';

  @override
  String get schoolCanteenId => 'ID školní jídelny';

  @override
  String get schoolCanteenIdDescription => 'ID školní jídelny je 4místné číslo, které používáte k přihlášení do aplikace Strava.';

  @override
  String get allowStravaLogin => 'Povolit přihlášení (experimentální)';

  @override
  String get name => 'Název';

  @override
  String get shortcutMax5Chars => 'Zkratka (max 5 znaků)';

  @override
  String subjectUsedTimes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tento předmět je použit $count×',
      one: 'Tento předmět je použit 1×',
    );
    return '$_temp0';
  }

  @override
  String get addNewSubject => 'Přidat nový předmět';

  @override
  String get editSubject => 'Upravit předmět';

  @override
  String get subjects => 'Předměty';

  @override
  String get noSubjectsFoundMessage => 'Nebyly nalezeny žádné předměty. Nové předměty můžete vytvořit kliknutím na tlačítko plus.';

  @override
  String deletedSubjectMessage(Object name) {
    return 'Smazaný předmět $name';
  }

  @override
  String get createNewTimes => 'Vytvořit nové časy:';

  @override
  String get deleteThisLesson => 'Smazat tuto hodinu';

  @override
  String get beginningTime => 'Začátek:';

  @override
  String get endingTime => 'Konec:';

  @override
  String get select => 'Vybrat';

  @override
  String get selectSubject => 'Vyberte předmět:';

  @override
  String get setToEmpty => 'Nastavit na prázdné';

  @override
  String get show7DayWeek => 'Zobrazit 7denní týden';

  @override
  String get timetableTileWidth => 'Šířka políčka';

  @override
  String get permanentTimetable => 'Stálý rozvrh';

  @override
  String get recentlyDeleted => 'Nedávno smazané';

  @override
  String get showPerformanceOverlay => 'Ukazovat překryv výkonu';

  @override
  String get showFirebaseOverlay => 'Ukazovat firebase překryv';

  @override
  String get viewDatabase => 'Zobrazit databázi';

  @override
  String get viewLogs => 'Zobrazit záznamy';

  @override
  String get viewTutorial => 'Zobrazit tutoriál';

  @override
  String get localization => 'Lokalizace';

  @override
  String get localizationSubtitle => 'Přizpůsobte jazyk a formát dat';

  @override
  String get language => 'Jazyk';

  @override
  String get timeFormat => 'Používat 24 hodinový formát času';

  @override
  String get timeFormatSubtitle => 'Některé jazyky podporují pouze 24 hodinový formát';

  @override
  String get timeFormat12 => '12 hodinový';

  @override
  String get timeFormat24 => '24 hodinový';

  @override
  String get dateFormat => 'Formát data';

  @override
  String get weekStartsOnMonday => 'Týden začíná v pondělí';

  @override
  String get weekStartsOnMondaySubtitle => 'Pokud zapnuto, první den týdne bude pondělí. Jinak to bude neděle.';

  @override
  String get viewingOfflineTimetable => 'Zobrazen trvalý rozvrh';

  @override
  String get recover => 'Obnovit';

  @override
  String get recoverInfoContent => 'Pro obnovení stiskněte a vyberte obnovit. Po 7 dnech dojde k trvalému smazání.';

  @override
  String daysLeft(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zbývá $count dní',
      few: 'Zbývají $count dny',
      one: 'Zbývá 1 den',
    );
    return '$_temp0';
  }

  @override
  String get defaultWord => 'Defaultní';

  @override
  String get useDateFormat => 'Formát: den měsíc rok';

  @override
  String get asDividerUse => '(jako oddělovací znak použijte \"mezeru\" / , . -)';

  @override
  String missed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zmeškaných',
      few: 'Zmeškané',
      one: 'Zmeškaný',
    );
    return '$_temp0';
  }

  @override
  String nextNotificationInfo(Object dateWhen, Object timeWhen) {
    return 'Další notifikace přijde $dateWhen okolo $timeWhen';
  }

  @override
  String get notificationPermission => 'Povolení zasílat oznámení';

  @override
  String get stopAsking => 'Přestat se ptát';

  @override
  String get later => 'Později';

  @override
  String get grant => 'Povolit';

  @override
  String get notificationPermissionBody1 => 'Pokud chcete, aby vám tato aplikace zasílala oznámení, musíte jí to povolit.';

  @override
  String get notificationPermissionBody2 => 'Tlačítko Povolit vás přesměruje do nastavení aplikace, kde můžete oznámení povolit.';

  @override
  String get useExtensions => 'Můžete využít tato rozšíření:';

  @override
  String get bakalariSubtitle => 'Umožní importovat předměty a zobrazit aktuální rozvrh';

  @override
  String get stravaCzSubtitle => 'Dokáže zobrazit jídla ve vaší jídelně';

  @override
  String get cloudSyncSubtitle => 'Zálohuje a synchronizuje data mezi zařízeními';

  @override
  String get goToApp => 'Přejít do aplikace';

  @override
  String get tutorialIntro => 'Děkuji za stažení aplikace Schoolarc. Toto je tutoriál, který vám vysvětlí základy. Vždy si ho můžete zobrazit později.';

  @override
  String get welcome => 'Vítejte';

  @override
  String get skip => 'Přeskočit';

  @override
  String get tutorialHomeworkTitle => 'Toto je úkol:';

  @override
  String get tutorialExamTitle => 'A toto je test:';

  @override
  String get tutorialHomeworkDelete => 'Tímto smažete úkol';

  @override
  String get tutorialExamDelete => 'Tímto smažete test';

  @override
  String get tutorialPriorities => 'Každý úkol a test má svou prioritu. Ta je vyjádřena barvou. Zkuste prioritu změnit:';

  @override
  String get tutorialTryAssigningSubject => 'Každý úkol nebo test můžete přiřadit k jednomu předmětu. Zkuste předmět změnit:';

  @override
  String get tutorialCreateSubjectsLater => 'Své předměty si později vytvoříte v obrazovce předmětů v navigační nabídce.';

  @override
  String get tutorialCompleteHomework => 'Skvělá práce! Tímto dokončíte úkol';

  @override
  String get tutorialSlideToDelete => 'Přejetím doleva a klepnutím na smazat můžete cokoliv smazat.';

  @override
  String get tutorialTapCheckbox => 'A klepnutím na zaškrtávací políčko vpravo dokončíte úkol.';

  @override
  String get exampleSubjectName1 => 'Matematika';

  @override
  String get exampleSubjectShort1 => 'Ma';

  @override
  String get exampleSubjectName2 => 'Biologie';

  @override
  String get exampleSubjectShort2 => 'Bi';

  @override
  String get exampleSubjectName3 => 'Český jazyk';

  @override
  String get exampleSubjectShort3 => 'Čj';
}
