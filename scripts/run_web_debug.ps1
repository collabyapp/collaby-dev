$ErrorActionPreference = "Stop"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw "Required command not found: flutter"
}

Write-Host "== Flutter pub get =="
flutter pub get

Write-Host "== Running app in Chrome (debug) =="
flutter run -d chrome
