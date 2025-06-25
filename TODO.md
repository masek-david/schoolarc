# FIX
baka current timetable maybe shouldnt save the subjects ???

# NEW:
- ✅ when should the widget be updated??
- ✅ rework reorder methods (dont include old priority, old index, instead the Homework)
- ✅ prejmenovat DTO na bez, ten pro hive na Data, Entity, DB, nebo DBO (database object)
- ✅ add errors message for baka/strava
- ✅ proper firebase error handling, if no user dont even try it,...
- ✅ fix arrows in calendar (not centered on web)
- ✅ create baka provider
- ⬜ unite the ui/ux for extensions (in settings and in welcome page)
    - ⬜ create providers for logins
- ⬜ add google sign in
- ⬜ rework tutorial (is it necessary to teach every interaction??)
- ⬜ persistance (tasks_app.dart refactor probably needed, maybe use go_router ??)
- ⬜ fix the frequency when is app searching for baka homeworks
- ⬜ create settings for initial task 
- ⬜ rethink addnewtask bottom sheet
    - ⬜ prevent from accidental scroll closing 
    - ⬜ fix the scrolling
    - ⬜ is everything needed to be shown ??
- ⬜ ipad - zmenit padding pro barevny okraje aplikace (otevreni klavesnice zpusobi jitter)

## notifications:
- ⬜ turn off notifications for weekend
- ⬜ edge case - when the app is opened at 18:00 the notification could be old

## new features:
- ✅ ask for notification permission when launching app for first time, maybe periodicaly
- ⬜ meals notifications (before meal?, remind to pick a week before?)
- ⬜ ? add option to mark day in calendar as empty (weekends, holidays)

## web features
- ✅ web - spatne se horizontalne scrolluje, pridat tlacitka
- ✅ web appbary jsou divne dole, asi protoze na webu neni safearea
- ✅ web FAB a appbary jsou divne dole, asi protoze na webu neni safearea
- ⬜ onHover
- ⬜ keyboard shortcuts

## year recap
- ⬜ in background move this years hws and exams tiles
- ⬜ something with timetable? (how many hours were with changes, with what hour did you begin...)

# MAYBE
- ⬜ refactor baka_service - add separate file for http requests
- ⬜ ? remake import to be faster (write everything to hive and reload, maybe add check for order to notifiers, which would be triggered on build)
- ⬜ ? add images to meals
- ⬜ ? remake app isWide as riverpod provider
- ⬜ ? remove slide to delete
    




# VERSION 2.0.0
- ✅ change package name (cz.masci.schoolarc)
- ✅ check widget
- ✅ move to hivece
- ✅ remove old migration stuff
- ✅ importing
- ✅ fix dates (save them just as utc)
- ✅ move to realtime database
- ✅ rework notifications - scheduling on app leave
- ✅ check app icon (consistency - dynamic icon, main icon, web, ios, splash screen (animated, normal), notification)

## settings:
- ✅ rework switch action and settings screen(state management)
- ✅ tapping on any setting tile should trigger its switch
- ✅ when choosing app theme, show its type (vibrant,...)
