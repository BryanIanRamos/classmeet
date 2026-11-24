<#
.SYNOPSIS
  Screenshot one route of the app on the running emulator.

.EXAMPLE
  tool/shoot.ps1 /home 360
  tool/shoot.ps1 /study/reader/week-1?tab=visual 428 -Scenario empty -Name reader

.NOTES
  Saves design/shots/<name>@<width>.png. Sets the emulator density so the
  screen is 360 or 428 dp wide, and always resets it at the end.
#>
param(
  [Parameter(Mandatory = $true, Position = 0)][string]$Route,
  [Parameter(Mandatory = $true, Position = 1)][ValidateSet('360', '428')][string]$Width,
  [ValidateSet('default', 'empty', 'error')][string]$Scenario = 'default',
  [string]$Name,
  [string]$Device = 'emulator-5554',
  [int]$SettleSeconds = 6,
  [int]$TimeoutSeconds = 300
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$adb = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
# 1080 px wide: 480 dpi gives 360 dp, 404 dpi gives about 428 dp.
$density = if ($Width -eq '360') { 480 } else { 404 }

if (-not $Name) {
  $Name = ($Route.Trim('/') -replace '[^A-Za-z0-9]+', '_').Trim('_')
  if (-not $Name) { $Name = 'root' }
}
$shots = Join-Path $root 'design\shots'
New-Item -ItemType Directory -Force $shots | Out-Null
$out = Join-Path $shots "$Name@$Width.png"

$logOut = Join-Path $env:TEMP 'classmeet_shoot_out.log'
$logErr = Join-Path $env:TEMP 'classmeet_shoot_err.log'
Remove-Item $logOut, $logErr -ErrorAction SilentlyContinue

$proc = $null
try {
  & $adb -s $Device shell wm density $density | Out-Null
  # Stop any running instance first, so the capture can't show the previous
  # route (the first shots of a session came out stale without this).
  & $adb -s $Device shell am force-stop com.example.classmeet | Out-Null

  $runArgs = @(
    'run', '-d', $Device,
    "--dart-define=INITIAL_ROUTE=$Route",
    "--dart-define=FAKE_SCENARIO=$Scenario"
  )
  $proc = Start-Process -FilePath 'flutter.bat' -ArgumentList $runArgs `
    -WorkingDirectory $root -PassThru -WindowStyle Hidden `
    -RedirectStandardOutput $logOut -RedirectStandardError $logErr

  # flutter run prints "Flutter run key commands" (and the VM service line)
  # once the app is up.
  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  $ready = $false
  while ((Get-Date) -lt $deadline) {
    if ($proc.HasExited) { break }
    if ((Test-Path $logOut) -and
        (Select-String -Path $logOut -Pattern 'Flutter run key commands' -Quiet)) {
      $ready = $true
      break
    }
    Start-Sleep -Seconds 2
  }
  if (-not $ready) {
    throw "The app did not start. See $logOut and $logErr"
  }
  Start-Sleep -Seconds $SettleSeconds

  # Raw PNG bytes straight from adb, no text-mode conversion.
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = $adb
  $psi.Arguments = "-s $Device exec-out screencap -p"
  $psi.RedirectStandardOutput = $true
  $psi.UseShellExecute = $false
  $p = [System.Diagnostics.Process]::Start($psi)
  $file = [System.IO.File]::Create($out)
  $p.StandardOutput.BaseStream.CopyTo($file)
  $file.Close()
  $p.WaitForExit()

  Write-Output $out
}
finally {
  if ($proc -and -not $proc.HasExited) {
    # flutter.bat starts dart; kill the whole tree.
    & taskkill /PID $proc.Id /T /F | Out-Null
  }
  & $adb -s $Device shell wm density reset | Out-Null
}
