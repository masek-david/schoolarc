<h1 align="center">Schoolarc</h1>

<h4 align="center">
    App to help students manage their homeworks and exams, simply in one app.
</h4>

<div align="center">
    <img src="screenshots/banner.png" width="500" style="border-radius:12px">
</div>

<div align="center">
<img src="https://github-production-user-asset-6210df.s3.amazonaws.com/30463115/393344052-713d71c5-3dec-4ec4-a3f2-8d28d025a9c6.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAVCODYLSA53PQK4ZA%2F20260502%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260502T201911Z&X-Amz-Expires=300&X-Amz-Signature=0eaedf9a40598ecd1dff2030cb8c57dc04f5d1c6ba54e17ec47de42b4cab4065&X-Amz-SignedHeaders=host&response-content-type=image%2Fpng" width=240 href="obtainium://add/https://github.com/masek-david/schoolarc">
<img alt="Get it on GitHub" src="https://raw.githubusercontent.com/Kunzisoft/Github-badge/main/get-it-on-github.png" width="240" href="https://github.com/masek-david/schoolarc/releases/latest/">
<!-- TODO download the apk -->
</div>

## Features

- Save homework and exams
    - Priorities (🔴🟠🟢🔵)
    - Assign subjects
- Calendar view
- Save and view timetable
- Bakaláři integration (Czech school system)
    - Import timetable, subjects
    - View current timetable with changes
    - View and import current homeworks
- Strava.cz integration (Czech canteen system)
- Material You theme
- Responsive design
  
## Screenshots

<details open>
    <summary>Dark mode screenshots</summary>
        <div align="center">
            <img src="screenshots/mobile/home_dark.png" width="250" style="border-radius:36px">
            <img src="screenshots/mobile/calendar_dark.png" width="250" style="border-radius:36px">
            <img src="screenshots/mobile/create_dark.png" width="250" style="border-radius:36px">
            <img src="screenshots/mobile/timetable_dark.png" width="250" style="border-radius:36px">
            <img src="screenshots/mobile/meals_dark.png" width="250" style="border-radius:36px">
        </div>
</details>

<details>
    <summary>Light mode screenshots</summary>
    <div align="center">
        <img src="screenshots/mobile/home_light.png" width="250" style="border-radius:36px">
        <img src="screenshots/mobile/calendar_light.png" width="250" style="border-radius:36px">
        <img src="screenshots/mobile/create_light.png" width="250" style="border-radius:36px">
        <img src="screenshots/mobile/timetable_light.png" width="250" style="border-radius:36px">
        <img src="screenshots/mobile/meals_light.png" width="250" style="border-radius:36px">
    </div>
</details>

<details>
    <summary>Dark mode desktop screenshots</summary>
    <div align="center">
        <img src="screenshots/desktop/home_dark.png" width="500" style="border-radius:8px">
        <img src="screenshots/desktop/calendar_dark.png" width="500" style="border-radius:8px">
        <img src="screenshots/desktop/create_dark.png" width="500" style="border-radius:8px">
        <img src="screenshots/desktop/timetable_dark.png" width="500" style="border-radius:8px">
        <img src="screenshots/desktop/meals_dark.png" width="500" style="border-radius:8px">
    </div>
</details>

<details>
    <summary>Light mode desktop screenshots</summary>
    <div align="center">
        <img src="screenshots/desktop/home_light.png" width="500" style="border-radius:8px">
        <img src="screenshots/desktop/calendar_light.png" width="500" style="border-radius:8px">
        <img src="screenshots/desktop/create_light.png" width="500" style="border-radius:8px">
        <img src="screenshots/desktop/timetable_light.png" width="500" style="border-radius:8px">
        <img src="screenshots/desktop/meals_light.png" width="500" style="border-radius:8px">
    </div>
</details>

## Platforms
Schoolarc can run on most platforms, however, it is optimized and tested mainly for use on Android and iOS. Some functions don't even work on other operating systems and on web data loss can occur.

|         | Cloud synchronization | Bakaláři | Strava.cz | Notifications | Homescreen Widget |
| ------- | :-------------------: | :------: | :-------: | :-----------: | :---------------: |
| Android |           ✅           |    ✅     |     ✅     |       ✅       |         ✅         |
| iOS     |           ✅           |    ✅     |     ✅     |       ✅       |         ❌         |
| Web     |           ✅           |    ✅     |     ✅     |       ❌       |         ❌         |
| Windows |           ✅           |    ✅     |     ✅     |       ❌       |         ❌         |
| macOS   |           ❔           |    ❔     |     ❔     |       ❔       |         ❔         |
| Linux   |           ❔           |    ❔     |     ❔     |       ❔       |         ❔         |

 ✅ working       ❌ not working     ❔not tested

# How to run locally

Note: This is only for development, you can download and install [here](https://github.com/masek-david/schoolarc/releases/latest). TODO

First, install [flutter sdk](https://docs.flutter.dev/install). Copy the repository and inside the console run
```
flutter pub get 
```
Wait few seconds for all problems to resolve. Select a device with pressing f1 and searching for *Flutter: Select device*. Then you can start debugging with pressing f5.

You can also build with (replace \<target> with desired platform)
```
flutter build <target>
```

For android, i recommend
```
flutter build apk --flavor prod --target-platform=android-arm64
```
as it is compatible with most devices and has the smallest sizes

## Firebase initialization

Configure [flutterfire](https://firebase.flutter.dev/docs/overview), run flutterfire configure and follow the instructions.

In firebase.json, hosting should look like this:
```
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "frameworksBackend": {
      "region": "europe-west1"
    }
  },
```

## Testing

Init Firebase emulator with
```
firebase init emulators
```
select a project, tick auth and database and before running, start the emulators with
```
firebase emulators:start --only "auth,database"
```

## Web

Schoolarc uses Workbox to give faster loading times and offline support for web. To install workbox-build, use
```
npm install workbox-build
```

Then, for building web, use
```
flutter build web --pwa-strategy=none ; node web/generate_service_worker.js
```

<!-- On windows, sometimes the windows is stuck on white or black - 
in that case, you can resize the windows using powertoys zones
 and rerun the project -->
