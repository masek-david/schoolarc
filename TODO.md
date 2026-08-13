# FIX
update/start listening to firebase on app reopen ???
should hw, exam and subject notifiers listen to firebaseLoginNotifier ???
? ios timetable still refresh pulls
bakalogin, strava login and firebase login are shared between debug and release on windows
tests
cant complete hw from widget
fix pull to refresh in calendar
scan qr

FILE PICKER DOESNT WORK ON WEB

# Material 3 Expressive
Bigger screen navigation:
    navigation rail - just for medium+ displays, keep the navigation drawer for mobile (even though its deprecated)
    https://m3.material.io/foundations/layout/breakpoints/overview#e87f7493-263d-4361-bd43-9b36a17407bb
check correct material colors - dynamic_color 1.9.0 should have fixed it, but doesnt look like it
add tooltips to buttons
settingtile shape animation
calendartiles animation
fabs - fab appear animation ???, fab hide text on scroll in calendar, remove the two fabs - expand for options - this should the user be able to change
refreshindicator as native - use material_3p ?

# RELEASE
- ✅ info about app, credits (font, svgs)
- ✅ info about bakalari loginch
- ✅ info about strava.cz login
- ✅ privacy policy info for cloud sync
- ✅ widgets
    - ✅ add from widget
    - ✅ cant complete homework from widget
        - ✅ just save info about completed hw, dont spawn it using isolate?
        - ✅ rework with isolatedHive??
- ✅ tutorial
    - ✅ offer import from bakalari
    - ✅ offer import from json
    - ✅ ask: new user? view tutorial? import data from json?
- ✅ move settings from screens to settings
- ✅ add to onboarding
    - ✅ notifications
    - ✅ add some images???
    - ✅ android widgets
- ✅ screenshots, readme
- ✅ actual timetable notifier
- ✅ push info to the app from web + min required version
- ✅ firebase verify email + forgot password for firebase
- ⬜ error tracking, error screen/messages
- ⬜ sync to my server
- ⬜ other timetable, hw, ... providers

# FEATURES

## Schoolarc Plus v2.4.0
- ⬜ 5 usd ?
- ⬜ sync everything (hws, exams, subjects) properly ‼️
- ⬜ google sign in
- ⬜ ask for email verification
- ⬜ sync, widgets ?, ...
- ⬜ add to onboarding

## UI
- ✅ settings use bigger headlines and scroll them
- ✅ check scrolling in timetable (dont overscroll, dont show pull tabs)
- ✅ add hide to found new homeworks
- ✅ better calendar screen scroll - shrink calendar, make betterwi missed, fix jump when switching pages
- ✅ scroll calendar vertically on big screens
- ✅ expressive buttons
- ✅ rethink addnewtask bottom sheet
    - ✅ share with qr
    - ✅ prevent from accidental scroll closing
    - ✅ fix the scrolling
- ⬜ ipad - change padding pro colored border (opening keyboard causes jitter)
- ⬜ improve performance for completed tasks in hw and exam screens (might require custom animated reorderable list)
- ⬜ on weekend, show info about upcoming week
- ⬜ custom icons - hws, exams, subjects ‼️
- ⬜ month calendar scroll on hover of dragged item
- ⬜ ? display tasks in timetable
- ⬜ ? homescreen cards horizontal pull to refresh - wouldn't be clear

## OTHER
- ✅ save only date for deadlines
- ✅ rework exceptions - string should be just shown in ui, not from service
- ✅ refactor to use date instead of datetime
- ⬜ android main widget doesnt open calendar to its date
- ⬜ create settings for initial task
    - ⬜ priority
    - ⬜ subject
    - ⬜ date
    - ⬜ auto set date to next appearance
- ⬜ create offline timetable provider
- ⬜ strava.cz stop saving the password
- ⬜ translation - google sheets
- ⬜ meals images - generate them using ai

## NOTIFICATIONS:
- ✅ turn off notifications for weekend
- ✅ add option to not send notification when its empty
- ✅ show at least something in empty notification
- ⬜ when user makes changes to app data and the notification is still shown, update it
- ⬜ edge case - when the app is opened before 18:00 the notification could be old when it is sent
- ⬜ switch to local_notifications ? (awesome_notifications has some old code)
- ⬜ meals notifications (before meal?, remind to pick a week before?)
- ⬜ add to windows

## SHARING
- ✅ show username in firebase login (create a provider for it?)
- ⬜ firebase rules
- ⬜ show shared indicator for hw, exam, subject
- ⬜ addbottomsheet 
    - ⬜ show which subjects are shared
    - ⬜ set isShared to true when shared subject is selected
- ⬜ add group names (create, view)
- ⬜ show only tasks that havent been saved yet
- ⬜ group notifier - group name, tasks, users?
- ⬜ translate
- ⬜ legal
    - ⬜ add name and groups? to export and delete data
    - ⬜ update privacy policy
- ⬜ qr group invite?

## YEAR RECAP
- ⬜ custom design - MD3E or something else (liquid glass 2027?)
- ⬜ in background move this years hws and exams tiles
- ⬜ something with timetable? (how many hours were with changes, with what hour did you begin...)

## iOS
- ⬜ state restoration
- ⬜ widgets

# MAYBE
- ⬜ ? refactor baka_service - add separate file for http requests
- ⬜ ? add option to mark day in calendar as empty (weekends, holidays)
- ⬜ ? remake import to be faster (write everything to hive and reload, maybe add check for order to notifiers, which would be triggered on build)
- ⬜ ? remove slide to delete
- ⬜ ? merge subjects with duplicate bakaId, show which one is more used (is it really needed?)
- ⬜ You can plan how long you need to learn for test or complete a homework and when you want to do it
- ⬜ Integration with device calendar




# DONE
- ✅ when should the widget be updated??
- ✅ rework reorder methods (dont include old priority, old index, instead the Homework)
- ✅ prejmenovat DTO na bez, ten pro hive na Data, Entity, DB, nebo DBO (database object)
- ✅ add errors message for baka/strava
- ✅ proper firebase error handling, if no user dont even try it,...
- ✅ create baka provider
- ✅ localizations
    - ✅ date format 
    - ✅ translation
    - ✅ start week with monday
- ✅ add emojis for empty screens, add no baka homeworks screen
- ✅ unite the ui/ux for extensions (in settings and in tutorial)
- ✅ tutorial
    - ✅ need to teach:
        - ✅ difference between hw and exam
        - ✅ complete hw
        - ✅ slide to delete
        - ✅ priorities
        - ✅ subjects
    - ✅ translation
- ✅ restore state
    - ✅ routing
    - ✅ addbottomsheet
    - ✅ calendar day

# VERSION 2.0.0
- ✅ change package name (cz.masci.schoolarc)
- ✅ check widget
- ✅ move to hivece
- ✅ remove old migration stuff
- ✅ importing
- ✅ fix dates (save them just as utc)
- ✅ move to realtime database
- ✅ rework notifications - scheduling on app leave
- ✅ ask for notification permission when launching app for first time, maybe periodicaly
- ✅ check app icon (consistency - dynamic icon, main icon, web, ios, splash screen (animated, normal), notification)

## settings:
- ✅ rework switch action and settings screen(state management)
- ✅ tapping on any setting tile should trigger its switch
- ✅ when choosing app theme, show its type (vibrant,...)

## web features
- ✅ web - spatne se horizontalne scrolluje, pridat tlacitka
- ✅ web appbary jsou divne dole, asi protoze na webu neni safearea
- ✅ web FAB a appbary jsou divne dole, asi protoze na webu neni safearea
- ✅ onHover
- ✅ keyboard shortcuts

## RIVERPOD
- ✅ bakalari
    - ✅ timetable
    - ✅ homeworks
        - ✅ fix the frequency when is app searching for baka homeworks
    - ✅ name

release - update pub, update pubspec version, update firebase realtimeDB versions, update changelog, github release - dont build for all abi - it would make build version wrong

for web - flutter build web --pwa-strategy=none ; node web/generate_service_worker.js, then firebase deploy