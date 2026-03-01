param(
  [int]$Port = 7357
)

$ErrorActionPreference = "Stop"

$targets = Get-CimInstance Win32_Process |
  Where-Object {
    $_.Name -match '^(dart|flutter)\.exe$' -and
    $_.CommandLine -like "*web-server*" -and
    $_.CommandLine -like "*--web-port $Port*"
  }

if (-not $targets) {
  Write-Host "No web-server process found on port $Port."
  exit 0
}

foreach ($p in $targets) {
  Write-Host "Stopping PID $($p.ProcessId): $($p.Name)"
  Stop-Process -Id $p.ProcessId -Force
}

Write-Host "Stopped web debug server on port $Port."
