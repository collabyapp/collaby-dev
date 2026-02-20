param(
  [string]$EmulatorId = ""
)

$ErrorActionPreference = "Stop"

function Require-Command($name) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    throw "Required command not found: $name"
  }
}

Require-Command flutter

Write-Host "== Flutter pub get =="
flutter pub get

Write-Host "== Checking connected devices =="
$devices = flutter devices
$runningAndroid = $devices | Select-String -Pattern "android|emulator" -SimpleMatch

if (-not $runningAndroid) {
  Write-Host "No Android device/emulator running. Looking for emulators..."
  $json = flutter emulators --machine
  $parsed = $json | ConvertFrom-Json

  if (-not $parsed -or $parsed.Count -eq 0) {
    throw "No Flutter emulators found. Create one in Android Studio > Device Manager."
  }

  if ([string]::IsNullOrWhiteSpace($EmulatorId)) {
    $EmulatorId = $parsed[0].id
  }

  Write-Host "Launching emulator: $EmulatorId"
  flutter emulators --launch $EmulatorId

  Write-Host "Waiting for emulator to boot..."
  Start-Sleep -Seconds 12
}

Write-Host "== Running app in debug =="
flutter run
