# FIX
cant complete homework from widget

# NEW:

## RELEASE
- ✅ info about app, credits (font, svgs)
- ✅ info about bakalari login
- ✅ info about strava.cz login
- ✅ privacy policy info for cloud sync
- ⬜ plus plan - one time/yearly ???
    - ⬜ add to tutorial



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
- ⬜ restore state
    - ✅ routing
    - ✅ addbottomsheet
    - ⬜ calendar day
- ⬜ riverpod
    - ⬜ strava
    - ⬜ bakalari
- ⬜ reset password for firebase
- ⬜ better calendar screen scroll - shrink calendar, make better missed, fix jank when switching pages
- ⬜ improve performance in hw and exam screens (might require custom animated reorderable list)
- ⬜ ipad - zmenit padding pro barevny okraje aplikace (otevreni klavesnice zpusobi jitter)
- ⬜ sync everything (hws, exams, subjects) properly 
- ⬜ fix the frequency when is app searching for baka homeworks
- ⬜ strava service
    - ⬜ check it works 
    - ⬜ stop saving the password 
- ⬜ on weekend, show info about upcoming week
- ⬜ settings use bigger headlines and scroll them
- ⬜ create settings for initial task
    - ⬜ priority
    - ⬜ subject
    - ⬜ date
    - ⬜ auto set date to next appearance
- ⬜ icons - hws, exams, subjects
- ⬜ rethink addnewtask bottom sheet
    - ⬜ show on top if it is hw/exam
    - ⬜ prevent from accidental scroll closing 
    - ⬜ fix the scrolling
    - ⬜ is everything needed to be shown ??
- ⬜ add google sign in + sign in with apple
- ⬜ meals notifications (before meal?, remind to pick a week before?)
- ⬜ translation - google sheets

## notifications:
- ⬜ migrate to flutter_local_notifications
- ⬜ remove some code for awesome notifications that was fixing something (in podfiles, other os setup)
- ⬜ turn off notifications for weekend
- ⬜ edge case - when the app is opened at 18:00 the notification could be old

## year recap
- ⬜ translate
- ⬜ in background move this years hws and exams tiles
- ⬜ something with timetable? (how many hours were with changes, with what hour did you begin...)

# MAYBE
- ⬜ refactor baka_service - add separate file for http requests
- ⬜ ? share tasks
- ⬜ ? add option to mark day in calendar as empty (weekends, holidays)
- ⬜ ? remake import to be faster (write everything to hive and reload, maybe add check for order to notifiers, which would be triggered on build)
- ⬜ ? add images to meals
- ⬜ ? remove slide to delete
- ⬜ make everything react to touch (shrink)
    




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
