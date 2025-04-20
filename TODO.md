# FIX

- kouknout znova na kod pro urcovani vysky radek v kalendari
- na ipadu jsou tasky v kalendari moc dlouhy
- na ipadu nevolat widget update

# version 2.0.0
- ✅ change package name (cz.masci.schoolarc)
- ✅ check widget
- ✅ move to hivece
- ✅ remove old migration stuff
- ✅ importing
- ✅ fix dates (save them just as utc)
    - ⬜ test timezones
- ✅ move to realtime database
- ⬜ ? refactor timetable models
- ✅ rework notifications - scheduling on app leave
    - ⬜ turn off notifications for weekend
    - ⬜ edge case - when the app is opened at 18:00 the notification could be old


optional:
- ✅ when should the widget be updated??
- ✅ rework reorder methods (dont include old priority, old index, instead the Homework)
- ✅ prejmenovat DTO na bez, ten pro hive na Data, Entity, DB, nebo DBO (database object)
- ⬜ check app icon (consistency - dynamic icon, main icon, web, ios, splash screen (animated, normal), notification)
- ⬜ rework tutorial (is it necessary to teach every interaction??)
- ⬜ rethink addnewtask bottom sheet
    - ⬜ prevent from accidental scroll closing 
    - ⬜ fix the scrolling
- ⬜ ipad - zmenit padding pro barevny okraje aplikace (otevreni klavesnice zpusobi jitter)
- ⬜ fix the frequency when is app searching for baka homeworks
- ⬜ create baka provider
- ⬜ create settings for initial task 
- ⬜ add google sign in 
- ⬜ remake import to be faster (write everything to hive and reload, maybe add check for order to notifiers, which would be triggered on build)
    
settings:
- ✅ rework switch action and settings screen(state management)
- ✅ tapping on any setting tile should trigger its switch
- ✅ when choosing app theme, show its type (vibrant,...)

new features:
- ✅ ask for notification permission when launching app for first time, maybe periodicaly
- ⬜ meals notifications
- ⬜ add option to mark day in calendar as empty (weekends, holidays)

web features
- ⬜ web - spatne se horizontalne scrolluje, pridat tlacitka
- ⬜ web FAB jsou divne dole, asi protoze tlacitka na webu nemaj margin
- ⬜ onHover
- ⬜ keyboard shortcuts

# maybe
- create baka provider
- ? remake app isWide as riverpod provider
 
- remove slide to delete?
- pass datetime better to widget (pass it as datetime, not a string) why???
