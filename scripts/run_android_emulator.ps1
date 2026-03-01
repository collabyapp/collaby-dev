param(
  [string]$EmulatorId = "",
  [ValidateSet("android", "chrome", "windows")]
  [string]$DeviceMode = "android",
  [switch]$NoBlock,
  [string]$ApiBaseUrl = "",
  [switch]$OfflineDemo
)

$ErrorActionPreference = "Stop"

function Require-Command($name) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    throw "Required command not found: $name"
  }
}

function Clear-FlutterLock {
  Write-Host "== Clearing stale Flutter startup locks/processes =="
  Get-Process dart -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
  Get-Process flutter -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 1
}

function Run-Flutter {
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
  )
  $cmd = "flutter " + ($Args -join " ")
  Write-Host ">> $cmd"
  & flutter @Args
}

function Get-ApiDefineArgs {
  $args = @()
  if (-not [string]::IsNullOrWhiteSpace($ApiBaseUrl)) {
    $args += @("--dart-define", "API_BASE_URL=$ApiBaseUrl")
  }
  if ($OfflineDemo) {
    $args += @("--dart-define", "ALLOW_OFFLINE_DEMO=true")
  }
  return $args
}

Require-Command flutter
Clear-FlutterLock

Write-Host "== Flutter pub get =="
Run-Flutter pub get

if ($DeviceMode -eq "chrome") {
  Write-Host "== Running app on Chrome =="
  if ($NoBlock) {
    $cmd = "cd `"$PSScriptRoot\..`"; flutter run -d chrome --web-port 60610"
    if (-not [string]::IsNullOrWhiteSpace($ApiBaseUrl)) {
      $cmd += " --dart-define `"API_BASE_URL=$ApiBaseUrl`""
    }
    if ($OfflineDemo) {
      $cmd += " --dart-define `"ALLOW_OFFLINE_DEMO=true`""
    }
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $cmd
    Write-Host "Launched in new terminal (non-blocking): http://localhost:60610"
    exit 0
  }
  $apiArgs = Get-ApiDefineArgs
  Run-Flutter run -d chrome --web-port 60610 @apiArgs
  exit 0
}

if ($DeviceMode -eq "windows") {
  Write-Host "== Running app on Windows desktop =="
  if ($NoBlock) {
    $cmd = "cd `"$PSScriptRoot\..`"; flutter run -d windows"
    if (-not [string]::IsNullOrWhiteSpace($ApiBaseUrl)) {
      $cmd += " --dart-define `"API_BASE_URL=$ApiBaseUrl`""
    }
    if ($OfflineDemo) {
      $cmd += " --dart-define `"ALLOW_OFFLINE_DEMO=true`""
    }
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $cmd
    Write-Host "Launched in new terminal (non-blocking)."
    exit 0
  }
  $apiArgs = Get-ApiDefineArgs
  Run-Flutter run -d windows @apiArgs
  exit 0
}

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

      if ($line -match "^[A-Za-z0-9._-]+\s+[•*]") {
        $EmulatorId = ($line -split "\s+")[0].Trim()
        break
      }

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
  Run-Flutter emulators --launch $EmulatorId

  Write-Host "Waiting for emulator to boot..."
  Start-Sleep -Seconds 20
}

Write-Host "== Running app in debug =="
if ($NoBlock) {
  $cmd = "cd `"$PSScriptRoot\..`"; flutter run -d android"
  if (-not [string]::IsNullOrWhiteSpace($ApiBaseUrl)) {
    $cmd += " --dart-define `"API_BASE_URL=$ApiBaseUrl`""
  }
  if ($OfflineDemo) {
    $cmd += " --dart-define `"ALLOW_OFFLINE_DEMO=true`""
  }
  Start-Process powershell -ArgumentList "-NoExit", "-Command", $cmd
  Write-Host "Launched in new terminal (non-blocking)."
  exit 0
}
$apiArgs = Get-ApiDefineArgs
Run-Flutter run -d android @apiArgs
