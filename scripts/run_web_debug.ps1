param(
  [string]$ApiBaseUrl = "https://api.collaby.co",
  [int]$Port = 7357
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw "Required command not found: flutter"
}

Write-Host "== Flutter pub get =="
flutter pub get

Write-Host "== Running app in web-server mode =="
Write-Host "Open in Chrome: http://localhost:$Port"
if ([string]::IsNullOrWhiteSpace($ApiBaseUrl)) {
  flutter run -d web-server --web-port $Port
} else {
  flutter run -d web-server --web-port $Port --dart-define "API_BASE_URL=$ApiBaseUrl"
}
