#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$driverInterface = Join-Path $PSScriptRoot 'driver_interface_kernel.dll'
$diagnostics = Join-Path $PSScriptRoot 'readonly_diagnostics.exe'
foreach ($requiredFile in @($driverInterface, $diagnostics)) {
    if (-not (Test-Path -LiteralPath $requiredFile)) {
        Write-Host "Missing file: $requiredFile"
        Read-Host 'Press Enter to close'
        exit 1
    }
}

$gameProcesses = @(Get-Process -Name 'TslGame' -ErrorAction SilentlyContinue)
if ($gameProcesses.Count -eq 0) {
    Write-Host 'No TslGame.exe process was found. Start the authorized bot test first.'
    Read-Host 'Press Enter to close'
    exit 1
}

Write-Host 'TslGame.exe candidates (nothing is selected automatically):'
foreach ($process in $gameProcesses) {
    Write-Host ("  PID {0}  {1}" -f $process.Id, $process.ProcessName)
}

$enteredPid = Read-Host 'Enter the desired decimal PID manually'
$selectedPid = 0
if (-not [int]::TryParse($enteredPid, [ref]$selectedPid)) {
    Write-Host 'The PID must be a decimal number.'
    Read-Host 'Press Enter to close'
    exit 1
}
if ($gameProcesses.Id -notcontains $selectedPid) {
    Write-Host 'That PID is not in the displayed TslGame.exe candidate list.'
    Read-Host 'Press Enter to close'
    exit 1
}

$env:VT_DRIVER_PATH = $driverInterface
$env:PUBG_PROCESS_ID = [string]$selectedPid
Write-Host "Running read-only diagnostics for manually selected PID $selectedPid"
& $diagnostics $selectedPid
$diagnosticsExitCode = $LASTEXITCODE
Write-Host "Diagnostics exit code: $diagnosticsExitCode"
if ($diagnosticsExitCode -eq 0) {
    Write-Host 'Expected success marker: READ_ONLY_DIAGNOSTICS_OK'
} else {
    Write-Host 'Diagnostics failed. Do not treat this as a compatible or working radar.'
}
Read-Host 'Press Enter to close'
exit $diagnosticsExitCode
