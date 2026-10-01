param(
    [Parameter(Mandatory=$true)][string]$Godot,
    [string]$LogDirectory,
    [string]$CaptureDirectory,
    [switch]$WithProfiling
)
$ErrorActionPreference = 'Stop'
$projectPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not $LogDirectory) { $LogDirectory = Join-Path $projectPath '.godot/test-logs/beautification' }
if (-not $CaptureDirectory) { $CaptureDirectory = Join-Path $projectPath '.godot/test-captures/beautification' }
$LogDirectory = [IO.Path]::GetFullPath($LogDirectory)
$CaptureDirectory = [IO.Path]::GetFullPath($CaptureDirectory)
New-Item -ItemType Directory -Force -Path $LogDirectory,$CaptureDirectory | Out-Null
$results = [Collections.Generic.List[object]]::new()
$checks = @(
    @{ Name='import'; Extra='--editor --quit'; Render=$false; Pattern='Godot Engine'; Timeout=120 },
    @{ Name='metrics'; Script='tests/beautification_metrics.gd'; Render=$false; Pattern='BEAUTIFICATION_METRICS_RESULT failures=0'; Timeout=90 },
    @{ Name='navigation_edges'; Script='tools/audit_navigation_edges.gd'; Render=$false; Pattern='NAV_EDGE_AUDIT_RESULT failures=0 overlapping_edges=0'; Timeout=60 },
    @{ Name='routes'; Script='tests/beautification_routes.gd'; Render=$false; Pattern='BEAUTIFICATION_ROUTES_RESULT failures=0'; Timeout=180 },
    @{ Name='full_day'; Script='tests/beautification_full_day.gd'; Render=$false; Pattern='BEAUTIFICATION_FULL_DAY_RESULT failures=0'; Timeout=180 },
    @{ Name='acceptance'; Script='tests/beautification_acceptance.gd'; Render=$true; Pattern='BEAUTIFICATION_ACCEPTANCE_RESULT failures=0'; Timeout=180 },
    @{ Name='survey'; Script='tests/beautification_survey.gd'; Render=$true; Pattern='BEAUTIFICATION_SURVEY_RESULT failures=0'; Timeout=180 },
    @{ Name='rescue'; Script='tests/beautification_rescue_capture.gd'; Render=$true; Pattern='BEAUTIFICATION_RESCUE_RESULT failures=0'; Timeout=90 },
    @{ Name='normal_boot'; Extra='--quit-after 120'; Render=$true; Pattern='Godot Engine'; Timeout=90 }
)
if ($WithProfiling) {
    $checks += @{ Name='performance'; Script='tests/phase_10_performance_test.gd'; Render=$true; Realtime=$true; Pattern='PHASE_10_PERFORMANCE_RESULT failures=0'; Timeout=120 }
}
foreach ($check in $checks) {
    $logPath = Join-Path $LogDirectory ($check.Name+'.log')
    $arguments = '--path "'+$projectPath+'" --log-file "'+$logPath+'" --audio-driver Dummy '
    if (-not $check.Render) { $arguments += '--headless ' }
    if (-not $check.Realtime) { $arguments += '--fixed-fps 60 ' }
    if ($check.Script) { $arguments += '--script res://'+$check.Script+' ' }
    if ($check.Extra) { $arguments += $check.Extra+' ' }
    if ($check.Render -and $check.Script -and -not $check.Realtime) {
        $destination = Join-Path $CaptureDirectory $check.Name
        New-Item -ItemType Directory -Force -Path $destination | Out-Null
        $arguments += '-- --capture-dir "'+$destination+'"'
    }
    $process = Start-Process -FilePath $Godot -ArgumentList $arguments -WindowStyle Hidden -PassThru
    $finished = $process.WaitForExit($check.Timeout*1000)
    if (-not $finished) { $process.Kill(); $process.WaitForExit() }
    $lines = if (Test-Path -LiteralPath $logPath) { @(Get-Content -LiteralPath $logPath) } else { @() }
    $errors = @($lines | Where-Object {
        ($_ -match '^ERROR:|^SCRIPT ERROR:|Parse Error:|^WARNING:.*Navigation') -and
        ($_.Trim() -ne 'ERROR: Failed to read the root certificate store.')
    })
    $hasResult = ($lines -join "`n") -match [regex]::Escape($check.Pattern)
    $passed = $finished -and $process.ExitCode -eq 0 -and $errors.Count -eq 0 -and $hasResult
    $results.Add([pscustomobject]@{ name=$check.Name; passed=$passed; exit_code=$process.ExitCode; timeout=(-not $finished); result_found=$hasResult; errors=$errors; log=$logPath })
    Write-Output (($check.Name)+': '+$(if($passed){'PASS'}else{'FAIL'}))
}
$results | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $LogDirectory 'results.json') -Encoding UTF8
$failed = @($results | Where-Object {-not $_.passed}).Count
Write-Output ('BEAUTIFICATION_SUITE_RESULT failures='+$failed)
exit $(if($failed){1}else{0})
