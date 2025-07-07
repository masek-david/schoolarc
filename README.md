# Schoolarc

App to help students manage their homeworks and exams, simply in one app.

## Features

- Save homework and exams
    - Priorities (🔴🟠🟢🔵)
    - Assign subjects
- Import subjects and timetable from Bakaláři
- View meals from Strava.cz

## Screenshots


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

## How to run
First, install [flutter sdk](https://docs.flutter.dev/install). Copy the repository and inside the console run
```
flutter pub get 
```
Wait few seconds for all problems to resolve. Select a device with pressing f1 and searching for *Flutter: Select device*. Then you can start debugging with pressing f5.

You can also build with (replace \<target> with desired platform)
```
flutter build <target>
```