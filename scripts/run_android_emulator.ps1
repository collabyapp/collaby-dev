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
$devicesOutput = flutter devices
$runningAndroid = $devicesOutput | Select-String -Pattern "android|emulator|sdk gphone|pixel" -CaseSensitive:$false

if (-not $runningAndroid) {
  Write-Host "No Android device/emulator running. Looking for emulators..."
  $emulatorsOutput = flutter emulators 2>&1

  if ($LASTEXITCODE -ne 0 -or ($emulatorsOutput -join "`n") -match "Unable to find any emulator sources") {
    throw "No Android emulator found. Create one in Android Studio > Device Manager > Create device."
  }

  if ([string]::IsNullOrWhiteSpace($EmulatorId)) {
    foreach ($line in $emulatorsOutput) {
      if ([string]::IsNullOrWhiteSpace($line)) { continue }
      if ($line -match "No emulators available") { continue }
      if ($line -match "To run an emulator") { continue }

      # flutter emulators format: "emulator_id • device name • platform"
      if ($line -match "^[A-Za-z0-9._-]+\s+[•*]") {
        $EmulatorId = ($line -split "\s+")[0].Trim()
        break
      }

      # fallback if output is just id on a line
      if ($line -match "^[A-Za-z0-9._-]+$") {
        $EmulatorId = $line.Trim()
        break
      }
    }
  }

  if ([string]::IsNullOrWhiteSpace($EmulatorId)) {
    throw "Could not auto-detect emulator id. Run 'flutter emulators' and pass -EmulatorId."
  }

  Write-Host "Launching emulator: $EmulatorId"
  flutter emulators --launch $EmulatorId

  Write-Host "Waiting for emulator to boot..."
  Start-Sleep -Seconds 15
}

Write-Host "== Running app in debug =="
flutter run
