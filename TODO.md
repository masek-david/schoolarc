# FIX

- kouknout znova na kod pro urcovani vysky radek v kalendari
- na ipadu jsou tasky v kalendari moc dlouhy

# version 2.0.0
- ✅ change package name (cz.masci.schoolarc)
- ✅ check widget
- ✅ move to hivece
- ✅ remove old migration stuff
- ✅ importing
- ✅ fix dates (save them just as utc)
    - ⬜ test timezones
- ✅ move to realtime database
- ⬜ persistance (tasks_app.dart refactor probably needed, maybe use go_router ??)
- ✅ rework notifications - scheduling on app leave
    - ⬜ turn off notifications for weekend
    - ⬜ edge case - when the app is opened at 18:00 the notification could be old


optional:
- ✅ when should the widget be updated??
- ✅ rework reorder methods (dont include old priority, old index, instead the Homework)
- ✅ prejmenovat DTO na bez, ten pro hive na Data, Entity, DB, nebo DBO (database object)
- ✅ add errors message for baka/strava
- ✅ proper firebase error handling, if no user dont even try it,...
- ✅ fix arrows in calendar (not centered on web)
- ⬜ unite the ui/ux for extensions (in settings and in welcome page)
    - ⬜ create providers for logins
- ⬜ rework tutorial (is it necessary to teach every interaction??)
- ⬜ why are there two firebase_options files
- ⬜ fix the frequency when is app searching for baka homeworks
- ⬜ create settings for initial task 
- ⬜ rethink addnewtask bottom sheet
    - ⬜ prevent from accidental scroll closing 
    - ⬜ fix the scrolling
    - ⬜ is everything needed to be shown ??
- ⬜ ipad - zmenit padding pro barevny okraje aplikace (otevreni klavesnice zpusobi jitter)
- ⬜ check app icon (consistency - dynamic icon, main icon, web, ios, splash screen (animated, normal), notification)

- ⬜ ? add google sign in 
- ⬜ ? create baka provider
- ⬜ ? remake import to be faster (write everything to hive and reload, maybe add check for order to notifiers, which would be   triggered on build)
- ⬜ ? add images to meals
- ⬜ refactor baka_service - add separate file for http requests
    
settings:
- ✅ rework switch action and settings screen(state management)
- ✅ tapping on any setting tile should trigger its switch
- ✅ when choosing app theme, show its type (vibrant,...)

new features:
- ✅ ask for notification permission when launching app for first time, maybe periodicaly
- ⬜ meals notifications
- ⬜ ? add option to mark day in calendar as empty (weekends, holidays)

web features
- ✅ web - spatne se horizontalne scrolluje, pridat tlacitka
- ✅ web appbary jsou divne dole, asi protoze na webu neni safearea
- ✅ web FAB a appbary jsou divne dole, asi protoze na webu neni safearea
- ⬜ onHover
- ⬜ keyboard shortcuts

# maybe
- create baka provider
- ? remake app isWide as riverpod provider
 
- remove slide to delete?
- pass datetime better to widget (pass it as datetime, not a string) why though???
