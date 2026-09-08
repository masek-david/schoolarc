## [2.3.0](2026-;build)
### Added
- New buttons following Material 3 Expressive guidelines
- Updated dialog for creating homework and exams
  - Prevent discarding changes by accident
  - Option to share via QR code
  - Option to save homework as exam and vice versa

### Changed
- Appbar is now transparent
- Removed timetable settings, option to show 7 day week in timetable can now be found in Style & Motion page

### Fixed
- Fix vocative form of long names in czech
- Fix Android navigation bar not being transparent
- Fix settings pages being behind the navigation bar in landscape

---

## [2.2.6](2026-8-21;build65)
### Added
- New buttons following Material 3 Expressive guidelines

### Changed
- Notifications now won't arrive if they are empty (by default)

### Fixed
- Fixed error when opening app from widget
- Completing homework from widget now works

---

## [2.2.5](2026-06-21;build63)
### Added

### Changed
- Search now sorts by date
- Bakalari now doesnt show as logged out on token expiration
- Added a name field to settings

### Fixed

---

## [2.2.4](2026-06-11;build61)
### Added
- Added 2025-26 year recap and sticker
- Added license
- Added Contact developer
- Open web search with images of the meal

### Changed
- New icon for Bakaláři
- Improved the app theme color options

### Fixed
- Android notification now arrives more precisely
- Fixed offline messages on web
- Fixed haptic feedback in calendar

---

## [2.2.3](2026-04-19;build56)
### Added
- Show how many exams or pieces of homework are hidden in calendar
- Added haptics to web

### Changed
- Improved calendar today tile visibility
- Calendar now opens today tile on default

### Fixed
- Fixed PWA offline support for iOS
- Fixed web splash screen animation on iOS
- Fixed dragging in calendar

---

## [2.2.2](2026-04-10;build55)
### Added
- PWA offline support, faster load times
- Improved web loading page - animated logo, showing loading indicator only after some time
- Added pull to refresh to calendar

### Changed
- Dialogs now use Material design language on all platforms

### Fixed
- Fixed calendar on big screens not showing correct days of the week
- Tapping outside of editing dialog no longer closes the dialog

---

## [2.2.1](2026-04-06;build53)
### Added
- Improved web load times and app size
- Added haptic feedback to web

### Changed
- Added button to close Bakaláři homework snackbar

### Fixed
- Fixed Theme page images height
- Fixed Changelog page
- Fixed week not starting on Sunday when enabled
- Improve keyboard date picker
- Web loader now uses app color

---

## [2.2.0](2026-03-31;build50)
### Added
- Reworked Android widgets
- Added new refresh indicator
- Improved home screen UI and UX
- New calendar look
- Subjects can now be created when creating homework or an exam
- Improved fonts
- Improved onboarding and tutorial experience
- Improved Cloud sync account - you can now change your email, verify email, reset password
- Add Windows Cloud sync support
- Added crash reporting

### Changed
- Improved ordering of tasks
- Changed how dates are saved (should resolve any timezone issues)
- Improved timetable UI and UX
- Improved error messages
- Added messages to exporting app data
- The app now follows system language and formatting
- Finally resolved keyboard opening on web on ios
- Improved snackbars
- Added weekdays to meals

### Fixed
- Fixed notifications - now will arrive up to a week after the app had been opened
- Fixed meals not showing Doplněk
- Fixed meals widget not working
- Fixed color of status bar on Android
- Many other bug fixes

---

## [2.1.7](2025-10-14)
### Added

### Changed

### Fixed
- Improved dragging in calendar
- Improved translations
- Fixed dialog not closing when adding homework from Bakaláři
- Fixed some paddings
- Fixed tasks not showing in calendar after summer time change
- Improved multiline task support

---

## [2.1.6](2025-09-27)
### Added

### Changed
- Changed design of settings
- Improved autofill services

### Fixed
- You no longer have to scroll through the whole tutorial each time you opened it
- Improve main app bar

---

## [2.1.5](2025-09-25)
### Added
- Added loading animation for web

### Changed

### Fixed
- Fixed Bakaláři homeworks not assigning correct subjects
- Fixed Bakaláři homeworks not saving viewed homeworks
- Fixed some translation strings
- Fixed wrong calendar page in some time zones

---

## [2.1.4](2025-09-02)
### Added

### Changed
- Date no longer changes when updating subject when editing
- Updated web icon

### Fixed
- Fixed keyboard not opening on web on ios

---

## [2.1.3](2025-09-01)
### Added

### Changed
- Improved Animated shape
- Improved Firebase login screen

### Fixed
- Fix notifications

---

## [2.1.2](2025-08-11)
### Added

### Changed
- Improved Strava.cz login page
- Improved home page
- Improved fetching of meals
- Improved fetching of timetable and homeworks
- Current timetable now updates when subject is imported

### Fixed

---

## [2.1.1](2025-07-28)
### Added
- Added state restoration on Android

### Changed

### Fixed
- Fixed calendar issue when week starts on monday was disabled
- Notification now opens calendar correctly

---

## [2.1.0](2025-07-25)
### Added
- Added app logo to drawer
- Added image showing app colors in theme settings
- Added new animated component - shape shifting star
- Added new animation for completing homework
- Added option for reporting bugs
- Added license page
- Added option to delete all Cloud sync data
- Added option to export all Cloud sync data
- Added privacy policy for Cloud sync

### Changed
- Improved tutorial and welcome page
- Improved screens with empty info
- Improved shortcuts in calendar

### Fixed
- Fixed home screen overview capitalization
- Fixed time formatting
- Fixed sorting in calendar

---

## [2.0.2](2025-07-08)
### Added
- Added czech translation
- Added options for date and time formats

### Changed

### Fixed

---

## [2.0.1](2025-07-04)
### Added
- Added keyboard shortcut support
- Added option to change password for Cloud sync

### Changed
- Improved importing subjects from Bakaláři
- Improved logging in to Cloud sync
- Improved logging in to Strava.cz
- The color of the top bar on web is now the same as the app's

### Fixed
- Timetable no longer shows lesson active if it isn't today
- Strava.cz now works on web
- Fixed keyboard shorcuts on web

---

## [2.0.0](2025-06-25)
### Added
- Added option for importing app data, including subjects, homework and exams
- Added full Bakaláři support for web
- Added year recap
- Added info about how many times a subject is used
- Added new priority picker

### Changed
- Improved the order of tasks in calendar
- Changed database structure
- Changed package name
- Improved settings
- Improved firebase import interface
- Improved dialogs
- Improved calendar view for bigger screens

### Fixed
- Fix notification arriving at wrong time
- Fix padding for exam tiles
- Fixed how dates are shown

---

## [1.1.0](2025-03-30)
### Added
- Added option for exporting app data, including subjects, homework and exams

### Changed

### Fixed

---

## [1.0.1](2025-03-29)
### Added
- Added changelog

### Changed
- Improved ordering tasks in search

### Fixed
- Fixed app updating home screen widget on ios
