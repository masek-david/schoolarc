# FIX
notifications are set only for this day
in home screen, show info about today too, if it is already showing about tomorrow
home screen meals shouldnt always enlarge
errors messages for export/import

# RELEASE
- ✅ info about app, credits (font, svgs)
- ✅ info about bakalari login
- ✅ info about strava.cz login
- ✅ privacy policy info for cloud sync
- ⬜ push info to the app from web + min required version
- ⬜ widgets
    - ⬜ add from widget
    - ⬜ cant complete homework from widget
        - ⬜ just save info about completed hw, dont spawn it using isolate?
        - ⬜ rework with isolatedHive??
- ⬜ forgot password for firebase + verify email
- ⬜ tutorial
    - ✅ choose language
    - ✅ offer import from bakalari
    - ⬜ offer import from json
- ⬜ plus - 5 usd, limit to 100 users?
- ⬜ add to tutorial
    - ⬜ app theme
    - ⬜ ? widgets
    - ⬜ notifications
    - ⬜ plus

# FEATURES

## UI
- ✅ settings use bigger headlines and scroll them
- ⬜ in calendar tasks are hidden again a little bit
- ⬜ ipad - zmenit padding pro barevny okraje aplikace (otevreni klavesnice zpusobi jitter)
- ⬜ improve performance in hw and exam screens (might require custom animated reorderable list)
- ⬜ better calendar screen scroll - shrink calendar, make better missed, fix jank when switching pages
- ⬜ rethink addnewtask bottom sheet
    - ⬜ show on top if it is hw/exam
    - ⬜ prevent from accidental scroll closing 
    - ⬜ fix the scrolling
    - ⬜ animation FAB morph to the sheet?
    - ⬜ does everything need to be shown ??
- ⬜ on weekend, show info about upcoming week
- ⬜ icons - hws, exams, subjects
- ⬜ check scrolling in timetable (dont overscroll, dont show pull tabs)
- ⬜ ? use expressive progress

## OTHER
- ⬜ sync everything (hws, exams, subjects) properly
- ⬜ add google sign in + sign in with apple
- ⬜ ? refactor to use date instead of datetime
- ⬜ create settings for initial task
    - ⬜ priority
    - ⬜ subject
    - ⬜ date
    - ⬜ auto set date to next appearance
- ⬜ strava stop saving the password 
- ⬜ save only date for deadlines
- ⬜ translation - google sheets

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

## notifications:
- ⬜ edge case - when the app is opened before 18:00 the notification could be old when it is sent
- ⬜ turn off notifications for weekend
- ⬜ switch to local_notifications (awesome_notifications has some old code)
- ⬜ meals notifications (before meal?, remind to pick a week before?)

## year recap
- ⬜ translate
- ⬜ in background move this years hws and exams tiles
- ⬜ something with timetable? (how many hours were with changes, with what hour did you begin...)

## iOS
- ⬜ state restoration
- ⬜ widgets

# MAYBE
- ⬜ refactor baka_service - add separate file for http requests
- ⬜ make everything react to touch (shrink) 
- ⬜ ? add option to mark day in calendar as empty (weekends, holidays)
- ⬜ ? remake import to be faster (write everything to hive and reload, maybe add check for order to notifiers, which would be triggered on build)
- ⬜ ? add images to meals
- ⬜ ? remove slide to delete
- ⬜ ? remake subject, hw, exam notifiers - too much reading database, recursive edit() calls, ...
- ⬜ ? merge duplicate subjects (is it really needed?)
    


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
