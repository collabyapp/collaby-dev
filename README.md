# Collaby Mobile App

## Fast local testing (without TestFlight)

This is the recommended flow to validate UI/UX quickly before publishing.

### 1) Android emulator (Windows)

Requirements:
- Flutter SDK installed and in PATH
- Android Studio installed
- At least one Android Virtual Device (AVD) created in Device Manager

From project root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_android_emulator.ps1
```

Optional (launch a specific emulator):

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_android_emulator.ps1 -EmulatorId "YOUR_EMULATOR_ID"
```

To list emulator IDs:

```powershell
flutter emulators
```

### 2) Web debug (fast UI iteration)

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_web_debug.ps1
```

### 3) Physical device (USB)

```powershell
flutter devices
flutter run -d <device_id>
```

## Notes

- On Windows, you cannot run iOS Simulator. For iOS final validation, continue using TestFlight/Codemagic.
- API is configured in `lib/res/app_url/app_url.dart` (`https://api.collaby.co`).
