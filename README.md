# Schoolarc

App to help students manage their homeworks and exams, simply in one app.

## Features

- Save homework and exams
    - Priorities (🔴🟠🟢🔵)
    - Assign subjects
- Save subjects
- Save timetable
- Bakaláři integration
    - Import timetable, subjects
    - View current timetable with changes
    - View current homeworks
- Strava.cz integration - view meals
- Support Material You theming
- Support for big screens

## Screenshots

TODO

## Platforms
Schoolarc can run on most platforms, however, some functions don't work on some operating systems.

|         | Cloud synchronization | Bakaláři | Strava.cz | Notifications| Homescreen Widget |
|---------|:---------------------:|:--------:|:---------:|:------------:|:-----------------:|
| Android |           ✅         |    ✅    |    ✅    |      ✅      |         ✅       | 
| iOS     |           ✅         |    ✅    |    ✅    |      ✅      |         ❌       | 
| Web     |           ✅         |    ✅    |    ✅    |      ❌      |         ❌       | 
| Windows |           ❌         |    ✅    |    ✅    |      ❌      |         ❌       | 
| macOS   |           ❔         |    ❔    |    ❔    |      ❔      |         ❔       | 
| Linux   |           ❔         |    ❔    |    ❔    |      ❔      |         ❔       | 

 ✅ working       ❌ not working     ❔not tested

## How to run locally
First, install [flutter sdk](https://docs.flutter.dev/install). Copy the repository and inside the console run
```
flutter pub get 
```
Wait few seconds for all problems to resolve. Select a device with pressing f1 and searching for *Flutter: Select device*. Then you can start debugging with pressing f5.

You can also build with (replace \<target> with desired platform)
```
flutter build <target>
```

for android, i recommend
```
flutter build apk --flavor prod --target-platform=android-arm64
```
as it is compatible with most devices and has the smallest sizes