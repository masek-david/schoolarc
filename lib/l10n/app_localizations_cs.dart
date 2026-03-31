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
  String get missedHomeworkTitle => 'Zmeškané úkoly';

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
  String get no => 'Ne';

  @override
  String get yes => 'Ano';

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
  String get exit => 'Odejít';

  @override
  String get save => 'Uložit';

  @override
  String get add => 'Přidat';

  @override
  String get added => 'Přidáno';

  @override
  String get addedHomework => 'Úkol přidán';

  @override
  String get addedExam => 'Test přidán';

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
  String get home => 'Domov';

  @override
  String get calendar => 'Kalendář';

  @override
  String get personal => 'Osobní';

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
  String homework(num count) {
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
  String homeworkFor(String isEmpty, Object whenText) {
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
  String nothingPlannedFor(Object whenText) {
    return 'Na $whenText není nic naplánováno';
  }

  @override
  String get nothingPlanned => 'Nic není naplánováno';

  @override
  String get showMyName => 'Zobrazit moje jméno';

  @override
  String get showMyNameSubtitle =>
      'Pokud je povoleno a jste přihlášeni do Bakalářů, budete uvítáni svým jménem';

  @override
  String get showBakalariTimetable => 'Zobrazit rozvrh z Bakalářů';

  @override
  String get showMeals => 'Zobrazit jídla';

  @override
  String get mealsDisabled => 'Jídla jsou vypnuta';

  @override
  String get lunchTime => 'Čas oběda';

  @override
  String get lunchTimeSubtitle => 'Kdy se zobrazí jídla na další den';

  @override
  String get initialDate => 'Počáteční datum';

  @override
  String get showMissedHomework => 'Zobrazit zmeškané úkoly';

  @override
  String get showArrows => 'Zobrazit šipky';

  @override
  String get showArrowsSubtitle =>
      'Zobrazit šipky pro přepínání mezi stránkami';

  @override
  String get upcomingDayChannelDescription =>
      'Zde najdete nadcházející testy a úkoly';

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
  String get canteen => 'Jídelna';

  @override
  String get invalidCanteenNumber => 'Neplatné číslo jídelny';

  @override
  String get invalidCanteenNumberLength =>
      'Neplatná délka čísla jídelny, povoleny jsou pouze 4 číslice';

  @override
  String get canteenNumberMissing => 'Chybí číslo jídelny';

  @override
  String get checkConnection => 'Zkontrolujte připojení k internetu';

  @override
  String get offline => 'Jste offline';

  @override
  String get timedOut => 'Požadavek vypršel';

  @override
  String get serverError => 'Chyba serveru';

  @override
  String get unexpectedError => 'Došlo k neočekávané chybě';

  @override
  String get fillOutAllFields => 'Vyplňte prosím všechny pole';

  @override
  String get noCanteen => 'Žádná jídelna, prosím přihlaste se';

  @override
  String get emptyLesson => 'Prázdná hodina';

  @override
  String get subjectHasntBeenAdded => 'Tento předmět ještě nebyl přidán.';

  @override
  String get importedSubject => 'Importován předmět';

  @override
  String get tryImportingSubjectFromBakalari =>
      'Nejdříve zkuste importovat předměty z obrazovky Bakalářů';

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
  String get dataLoaded => 'Data načtena';

  @override
  String get newHomework => 'Nové úkoly';

  @override
  String get homeworkAlreadyAdded => 'Tento úkol již byl přidán';

  @override
  String get addAsHomework => 'Přidat jako úkol';

  @override
  String get addAsExam => 'Přidat jako test';

  @override
  String get bakalari => 'Bakaláři';

  @override
  String get useBakalari => 'Používat Bakaláře';

  @override
  String get bakalariDisabled => 'Bakaláři jsou vypnuty';

  @override
  String get loggedIn => 'Přihlášeni';

  @override
  String get loggedOut => 'Odhlášeni';

  @override
  String get schoolWebId => 'Školní web';

  @override
  String get username => 'Uživatelské jméno';

  @override
  String get changeUsername => 'Změnit uživatelské jméno';

  @override
  String get changeNickname => 'Změnit přezdívku';

  @override
  String get nicknameChanged => 'Přezdívka byla úspěšně změněna';

  @override
  String get newUsername => 'Nové uživatelské jméno';

  @override
  String get newNickname => 'Nová přezdívka';

  @override
  String get nicknameInfo =>
      'Přezdívka je veřejně viditelná ostatním uživatelům';

  @override
  String get nickname => 'Přezdívka';

  @override
  String get group => 'Skupina';

  @override
  String get notMemberOfAnyGroup => 'Nejste členem žádné skupiny';

  @override
  String get waitingForApproval => 'Čeká na schválení';

  @override
  String get removedFromGroup => 'Byli jste odebráni ze skupiny';

  @override
  String get leaveOldGroup => 'Nejprve opusťte starou skupinu';

  @override
  String get cantLeaveYourGroup =>
      'Nemůžete opustit skupinu, kterou jste vytvořili, musíte ji smazat';

  @override
  String get cantChangeGroupName => 'Nemůžete změnit název této skupiny';

  @override
  String get subjectIsntShared => 'Zvolený předmět není sdílen';

  @override
  String get password => 'Heslo';

  @override
  String get repeatPassword => 'Potvrďte heslo';

  @override
  String get notSamePassword => 'Potvrzované heslo není stejné.';

  @override
  String get oldPassword => 'Staré heslo';

  @override
  String get email => 'Email';

  @override
  String get rememberMe => 'Zapamatovat si mě';

  @override
  String get rememberMeTitle => 'Zapamatovat si mě?';

  @override
  String get rememberMeWarning =>
      'Pokud budete pokračovat, nebude možné zobrazit aktuální rozvrh a aktuální úkoly.';

  @override
  String get continueAction => 'Pokračovat';

  @override
  String get logOut => 'Odhlásit se';

  @override
  String get importTimetableTitle => 'Importovat rozvrh a předměty?';

  @override
  String get importTimetableWarning =>
      'Importování rozvrhu přepíše váš současný rozvrh. Existující předměty budou využity znovu. Chcete pokračovat?';

  @override
  String get import => 'Importovat';

  @override
  String get importTimetable => 'Importovat rozvrh a předměty';

  @override
  String get changeDateTo => 'Změnit datum na';

  @override
  String get actualTimetable => 'Aktuální rozvrh';

  @override
  String get noTimetableMessage =>
      'Nemáte žádný rozvrh. Můžete vytvořit časy lekcí kliknutím na tlačítko plus, nebo můžete importovat rozvrh z Bakalářů.';

  @override
  String get noHomework => 'Nebyly nalezeny žádné úkoly';

  @override
  String get noExams => 'Nebyly nalezeny žádné testy';

  @override
  String get noRecentlyDeleted =>
      'Nebyly nalezeny žádné nedávno smazané položky';

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
  String get youWereLoggedOut => 'Byli jste odhlášeni';

  @override
  String get loggedInSynced => 'Byli jste přihlášeni, vše je synchronizováno';

  @override
  String get errorLoggingIn => 'Při přihlašování došlo k chybě.';

  @override
  String get errorRegistering => 'Při registraci došlo k chybě.';

  @override
  String get errorChangingPassword => 'Při změně hesla došlo k chybě.';

  @override
  String get errorChangingEmail => 'Při změně emailové adresy došlo k chybě.';

  @override
  String get registeredSuccessfully =>
      'Byli jste úspěšně registrováni, vše je synchronizováno';

  @override
  String get changePassword => 'Změnit heslo';

  @override
  String get newPassword => 'Nové heslo';

  @override
  String get repeatNewPassword => 'Potvrďte nové heslo';

  @override
  String get samePasswords => 'Nové heslo nemůže být stejné jako staré heslo.';

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
  String noMealsOn(Object date) {
    return '$date žádná jídla';
  }

  @override
  String mealsOn(Object date) {
    return 'Jídla $date';
  }

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
  String get noLogsFound =>
      'Nebyly nalezeny žádné záznamy. Vše beží v pořádku!';

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
  String get styleMotionScreenSwitchAnimationSubtitle =>
      'V milisekundách (0 vypne animaci)';

  @override
  String get styleMotionShowBorderTitle => 'Zobrazit okraj aplikace';

  @override
  String get styleMotionShowBorderSubtitle =>
      'Na velké obrazovce, nebo když je aplikace na šířku, zobrazí okraje v aplikaci';

  @override
  String get expressiveHaptics => 'Expresivní vibrace';

  @override
  String get expressiveHapticsSub =>
      'Některé elemetny uživatelského prostředí vibrují s animacemi';

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
  String get themeSystemColorWarning =>
      'Momentálně používáte barvu systému. Pokud chcete vybrat vlastní barvu, vypněte Použít barvy zařízení.';

  @override
  String get themeAppColor => 'Barva aplikace';

  @override
  String get themeSchemeVariant => 'Varianta motivu';

  @override
  String get upcomingDayNotifications => 'Oznámení o dalším dni';

  @override
  String get receiveUpcomingDayNotifications =>
      'Dostávat notifikace o dalším dni?';

  @override
  String get notificationsNotAllowedMessage =>
      'Oznámení nejsou povolena, klikněte zde pro udělení oprávnění';

  @override
  String get upcomingDayNotificationsDescription =>
      'Dostávejte oznámení o úkolech a testech na další den';

  @override
  String get upcomingDayNotificationsReceiveBeforeWeekend =>
      'Dostávejte oznámení před víkendem';

  @override
  String get upcomingDayNotificationsReceiveBeforeWeekendSubtitle =>
      'Pokud je zapnuto, budete dostávat oznámení i v pátek a v sobotu';

  @override
  String get addWidgetToHomescreen => 'Přidat widget na domovskou obrazovku?';

  @override
  String get addMainWidget => 'Přidat hlavní widget';

  @override
  String get addMealsWidget => 'Přidat widget s jídly';

  @override
  String onWeekday(String weekday) {
    String _temp0 = intl.Intl.selectLogic(
      weekday,
      {
        '1': 'V pondělí',
        '2': 'V úterý',
        '3': 'Ve středu',
        '4': 'Ve čtvrtek',
        '5': 'V pátek',
        '6': 'V sobotu',
        '7': 'V neděli',
        'other': 'neznámé',
      },
    );
    return '$_temp0';
  }

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
  String get exportSuccess => 'Úspěšně exportováno';

  @override
  String get importSuccess => 'Úspěšně importováno';

  @override
  String get aborted => 'Přerušeno';

  @override
  String get chooseSaveLocation => 'Vybertre umístění pro uložení souboru:';

  @override
  String get pickSaveFile => 'Vyberte soubor:';

  @override
  String importConfirmationText(
    num subjectsCount,
    num hwsCount,
    num examsCount,
  ) {
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
  String get initialPageSubtitle =>
      'Výchozí stránka bude zobrazena při otevření aplikace';

  @override
  String get alreadyDeveloper => 'Již jste vývojář';

  @override
  String get pressMoreTimesToBecomeDeveloper =>
      'Po dvou dalších kliknutích se z vás stane vývojář';

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
  String get useStravaCz => 'Používat Strava.cz';

  @override
  String get viewAppChangelog => 'Zobrazit změny aplikace';

  @override
  String get developerMode => 'Režim vývojáře';

  @override
  String get useExperimentalHomeworkTileOverlay =>
      'Používat experimentální překrývané okno úkolu';

  @override
  String get colorShowcaseTitle =>
      'Takto bude aplikace vypadat s těmito barvami:';

  @override
  String get filledButton => 'Tlačítko';

  @override
  String get choiceChip => 'Výběr';

  @override
  String get loginToStrava => 'Přihlásit se do Strava.cz';

  @override
  String get schoolCanteenId => 'ID školní jídelny';

  @override
  String get schoolCanteenIdDescription =>
      'ID školní jídelny je 4místné číslo, které používáte k přihlášení do aplikace Strava.';

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
  String get noSubjectsMessage =>
      'Nemáte žádné předměty. Nové předměty můžete vytvořit kliknutím na tlačítko plus.';

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
  String get dontViewTutorial => 'Nezobrazovat tutoriál';

  @override
  String get tutorialCompleted => 'Tutoriál dokončen';

  @override
  String get localization => 'Lokalizace';

  @override
  String get localizationSubtitle => 'Přizpůsobte jazyk a formát dat';

  @override
  String get language => 'Jazyk';

  @override
  String get languageDefault => 'Výchozí jazyka';

  @override
  String get deviceLanguage => 'Jazyk zařízení';

  @override
  String get h24timeFormat => 'Vynutit 24 hodinový formát času';

  @override
  String get h24timeFormatSubtitle =>
      'Některé jazyky podporují pouze 24 hodinový formát';

  @override
  String get timeFormat12 => '12 hodinový';

  @override
  String get timeFormat24 => '24 hodinový';

  @override
  String get dateFormat => 'Formát data';

  @override
  String get weekStartsOnMonday => 'Týden začíná v pondělí';

  @override
  String get weekStartsOnMondaySubtitle =>
      'Pokud zapnuto, první den týdne bude pondělí. Jinak to bude neděle.';

  @override
  String get viewingOfflineTimetable => 'Zobrazen trvalý rozvrh';

  @override
  String get recover => 'Obnovit';

  @override
  String get recoverInfoContent =>
      'Pro obnovení stiskněte a vyberte obnovit. Po 7 dnech dojde k trvalému smazání.';

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
  String get asDividerUse =>
      '(jako oddělovací znak použijte \"mezeru\" / , . -)';

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
  String get notificationPermissionBody1 =>
      'Pokud chcete, aby vám tato aplikace zasílala oznámení, musíte jí to povolit.';

  @override
  String get notificationPermissionBody2 =>
      'Tlačítko Povolit vás přesměruje do nastavení aplikace, kde můžete oznámení povolit.';

  @override
  String get useExtensions => 'Můžete využít tato rozšíření:';

  @override
  String get bakalariSubtitle =>
      'Umožní importovat předměty a zobrazit aktuální rozvrh';

  @override
  String get stravaCzSubtitle => 'Dokáže zobrazit jídla ve vaší jídelně';

  @override
  String get cloudSyncSubtitle =>
      'Zálohuje a synchronizuje data mezi zařízeními';

  @override
  String get goToApp => 'Přejít do aplikace';

  @override
  String get welcome => 'Vítejte';

  @override
  String get onboardingWelcome =>
      'Děkuji za stažení aplikace Schoolarc. Jestli jste tu poprvé, můžete si projít tutoriál, který vám vysvětlí základy. Vždy si ho můžete zobrazit později.';

  @override
  String get setupComplete => 'Nastavení dokončeno';

  @override
  String get continueToApp => 'Pokračujte do aplikace';

  @override
  String get restoreData => 'Obnovit data';

  @override
  String get restoreDataChoiceTitle => 'Jak chcete obnovit data?';

  @override
  String get importBackupFile => 'Importovat soubor zálohy';

  @override
  String get importBackupFileSub =>
      'Exportujte .json z vašeho starého zařízení a importujte ho zde';

  @override
  String get skipRestoringQ => 'Přeskočit obnovení?';

  @override
  String get skipRestoring => 'Přeskočit obnovení';

  @override
  String get skipRestoringSub =>
      'Budete mít možnost obnovit data, i když to zde přeskočíte. Může to ale způsobit konflikty.';

  @override
  String get newUser => 'Nový uživatel';

  @override
  String get returningUser => 'Vracející se uživatel';

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
  String get tutorialPriorities =>
      'Každý úkol a test má svou prioritu. Ta je vyjádřena barvou. Zkuste prioritu změnit:';

  @override
  String get tutorialTryAssigningSubject =>
      'Každý úkol nebo test můžete přiřadit k jednomu předmětu. Zkuste předmět změnit:';

  @override
  String get tutorialCreateSubjectsLater =>
      'Své předměty si později vytvoříte v obrazovce předmětů v navigační nabídce.';

  @override
  String get tutorialCompleteHomework => 'Skvělá práce! Tímto dokončíte úkol';

  @override
  String get tutorialSlideToDelete =>
      'Přejetím doleva a klepnutím na smazat můžete cokoliv smazat.';

  @override
  String get tutorialTapCheckbox =>
      'A klepnutím na zaškrtávací políčko vpravo dokončíte úkol.';

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

  @override
  String get aboutApp => 'O aplikaci';

  @override
  String get reportBug => 'Nahlásit chybu';

  @override
  String get reportBugPolicy =>
      'Odesláním zprávy souhlasíte se sdílením uvedených informací výhradně za účelem opravy chyb.';

  @override
  String get viewLicenses => 'Zobrazit licence';

  @override
  String get sendReport => 'Odeslat zprávu o chybě?';

  @override
  String get sendAllReports => 'Odeslat zprávu o všech chybách?';

  @override
  String get send => 'Odeslat';

  @override
  String get deleteLog => 'Smazat záznam?';

  @override
  String get bugReportHint =>
      'Popište chybu: Také můžete přiložit snímek obrazovky.';

  @override
  String get cantOpenMail => 'Nepodařilo se otevřít email aplikaci';

  @override
  String get secureLogin => 'Bezpečnost přihlášení';

  @override
  String get secureLoginInfo =>
      'Údaje o přihlášení jsou bezpečně uschovány v tomto zařízení. Nikdy nejsou sdíleny, kamkoliv odeslány nebo dostupné jiným aplikacím.';

  @override
  String get cantDeleteData => 'Data nebyla úspěšně smazána. Zkuste to znovu.';

  @override
  String get cantLogin => 'Přihlášení se nepodařilo. Zkuste to znovu.';

  @override
  String get couldntLogIn => 'Přihlášení se nezdařilo';

  @override
  String get deleteAllData => 'Smazat všechna data';

  @override
  String get deletedAllData => 'Všechna data byla smazána.';

  @override
  String get deleteAllDataTitle => 'Smazat všechna data?';

  @override
  String get deleteAllDataText =>
      'Smazání všech dat smaže vaší synchronizovanou zálohu a váš účet. Místní data zůstanou nedotknutá. Tato akce je nevratná. Opravdu chcete všechna data smazat?';

  @override
  String get getAllData => 'Stáhnout všechna data';

  @override
  String get agree => 'Souhlasím';

  @override
  String get disagree => 'Nesouhlasím';

  @override
  String get view => 'Zobrazit';

  @override
  String newHomeworkFound(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nalezeno $count nových úkolů',
      few: 'Nalezeny $count nové úkoly',
      one: 'Nalezen $count nový úkol',
    );
    return '$_temp0';
  }

  @override
  String get privacyPolicy =>
      'Datum účinnosti: 31. Března 2026\nPoužíváním aplikace Schoolarc souhlasíte s těmito Zásadami ochrany osobních údajů. Tyto Zásady ochrany osobních údajů mohou být aktualizovány.\nAplikace Schoolarc je především offline, ale obsahuje i některé online funkce.\nVývojář není zodpovědný za žádné ztráty dat způsobené závadou zařízení, smazáním aplikace, softwarovou chybou, nebo neoprávněným přístupem.\n## Cloud Sync\n### Jaká data jsou shromažďována\n- Emailová adresa – používá se pro přihlášení a přiřazení účtu\n- Předměty, testy, domácí úkoly –  synchronizovánu mezi vašimi zařízeními\nVaše data nejsou používána k reklamním ani marketingovým účelům.\n### Vaše práva\nMáte právo:\n- Požádat o kopii svých dat\n- Požádat o smazání svého účtu a všech dat\nObojí lze provést přímo v aplikaci.\n### Třetí strany\nCloud sync data jsou uložena na serverech v Evropské Unii (Belgii) pomocí Google Cloud Firebase.\n## Hlášení chyb\nPokud povolíte odesílání hlášení chyb, budou data odesílána pomocí Firebase Crashlytics za účelem identifikace a opravy chyb.\nShromažďovaná data mohou zahrnovat:\n- záznamy o pádech a stack trace\n- informace o zařízení (např. model a verze operačního systému)\n- verzi aplikace a kontext použití v době pádu\n- časové údaje a jedinečný identifikátor instalace\n- vlastní logy generované aplikací\nTato data jsou využívána výhradně k diagnostice a opravě chyb a ke zlepšení stability aplikace.\n';

  @override
  String get privacyPolicyTitle => 'Zásady ochrany osobních údajů';

  @override
  String get privacyPolicyAgree =>
      'Pokračováním souhlasíte se Zásadami ochrany osobních údajů (klikněte pro zobrazení)';

  @override
  String get viewSourceCode => 'Zobrazit zdrojový kód (Github)';

  @override
  String get cloudSyncDisabled => 'Synchronizace je vypnutá';

  @override
  String get cloudSyncDisabledWarning =>
      'Při používání webové aplikace je doporučeno zapnout synchronizaci, aby nedošlo ke ztrátě dat.';

  @override
  String get enable => 'Zapnout';

  @override
  String get keepDisabled => 'Nechat vypnuté';

  @override
  String get dontShowAgain => 'Nezobrazovat znovu';

  @override
  String get alreadyUsedApp => 'Už jste aplikaci používali?';

  @override
  String get sorry => 'Omlouvám se';

  @override
  String get versionNotSupported =>
      'Tato verze aplikace Schoolarc už není podporována.';

  @override
  String get pleaseUpdateApp => 'Prosím aktualizujte aplikaci.';

  @override
  String get sendPasswordReset => 'Odeslat obnovení hesla';

  @override
  String get sent => 'Odesláno';

  @override
  String get verifyEmailAddress => 'Ověřit emailovou adresu';

  @override
  String emailVerificationOpenLinkInEmail(Object email) {
    return 'Otevřete odkaz v emailu zaslaném na $email a poté zde klepněte na Hotovo. Pokud jste e-mail neobdrželi, zkontrolujte spam a zkuste to znovu.';
  }

  @override
  String get sendAgain => 'Odeslat znovu';

  @override
  String get done => 'Hotovo';

  @override
  String get addressVerified => 'Adresa ověřena';

  @override
  String get changeEmail => 'Změnit email';

  @override
  String get changeEmailAddress => 'Změnit emailovou adresu';

  @override
  String get newEmailAddress => 'Nová emailová adresa';

  @override
  String get emailAddressChanged => 'Emailová adresa změněna';

  @override
  String changeEmailDontForgetClickLink(Object email) {
    return 'Nezapomeňte kliknout na odkaz v emailu zaslaném na $email, abyste se mohli přihlásit s touto adresou.';
  }

  @override
  String get forgotPassword => 'Zapomenuté heslo';

  @override
  String get emailNotVerified => 'Email není ověřen';

  @override
  String get tapToVerify => 'Stiskněte pro ověření';

  @override
  String get secondShort => ' sek';

  @override
  String get minutesShort => ' min';

  @override
  String get hoursShort => 'h';

  @override
  String get daysShort => 'd';
}
