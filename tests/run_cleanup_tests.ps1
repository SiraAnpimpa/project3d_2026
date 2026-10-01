param(
    [Parameter(Mandatory=$true)][string]$Godot,
    [string]$LogDirectory,
    [string]$CaptureDirectory,
    [switch]$WithProfiling
)
$ErrorActionPreference = 'Stop'
$projectPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not $LogDirectory) { $LogDirectory = Join-Path $projectPath '.godot/test-logs/cleanup' }
if (-not $CaptureDirectory) { $CaptureDirectory = Join-Path $projectPath '.godot/test-captures/cleanup' }
$LogDirectory = [IO.Path]::GetFullPath($LogDirectory)
$CaptureDirectory = [IO.Path]::GetFullPath($CaptureDirectory)
New-Item -ItemType Directory -Force -Path $LogDirectory,$CaptureDirectory | Out-Null
$results = [Collections.Generic.List[object]]::new()
$checks = @(
    @{ Name='import'; Extra='--editor --quit'; Render=$false; Pattern='Godot Engine'; Timeout=120 },
    @{ Name='geometry'; Script='tests/cleanup_geometry.gd'; Render=$false; Pattern='CLEANUP_GEOMETRY_RESULT failures=0'; Timeout=120 },
    @{ Name='metrics'; Script='tests/cleanup_metrics.gd'; Render=$false; Pattern='CLEANUP_METRICS_RESULT failures=0'; Timeout=90 },
    @{ Name='navigation_edges'; Script='tools/audit_navigation_edges.gd'; Render=$false; Pattern='NAV_EDGE_AUDIT_RESULT failures=0 overlapping_edges=0'; Timeout=60 },
    @{ Name='routes'; Script='tests/cleanup_routes.gd'; Render=$false; Pattern='CLEANUP_ROUTES_RESULT failures=0'; Timeout=240 },
    @{ Name='full_day'; Script='tests/cleanup_full_day.gd'; Render=$false; Pattern='CLEANUP_FULL_DAY_RESULT failures=0'; Timeout=240 },
    @{ Name='acceptance'; Script='tests/cleanup_acceptance.gd'; Render=$false; Pattern='CLEANUP_ACCEPTANCE_RESULT failures=0'; Timeout=240 },
    @{ Name='night'; Script='tests/cleanup_night.gd'; Render=$true; Pattern='CLEANUP_NIGHT_RESULT failures=0'; Timeout=360 },
    @{ Name='survey'; Script='tests/cleanup_survey.gd'; Render=$true; Pattern='CLEANUP_SURVEY_RESULT failures=0'; Timeout=360 },
    @{ Name='rescue'; Script='tests/cleanup_rescue_capture.gd'; Render=$true; Pattern='CLEANUP_RESCUE_RESULT failures=0'; Timeout=90 },
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
        ($_ -match '^ERROR:|^SCRIPT ERROR:|Parse Error:|^WARNING:.*[Nn]avigation|^FAIL:') -and
        ($_.Trim() -ne 'ERROR: Failed to read the root certificate store.')
    })
    $hasResult = ($lines -join "`n") -match ('(?m)^'+[regex]::Escape($check.Pattern)+'(?:\s|$)')
    $passed = $finished -and $process.ExitCode -eq 0 -and $errors.Count -eq 0 -and $hasResult
    $results.Add([pscustomobject]@{ name=$check.Name; passed=$passed; exit_code=$process.ExitCode; timeout=(-not $finished); result_found=$hasResult; errors=$errors; log=$logPath })
    Write-Output (($check.Name)+': '+$(if($passed){'PASS'}else{'FAIL'}))
}
$results | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $LogDirectory 'results.json') -Encoding UTF8
$failed = @($results | Where-Object {-not $_.passed}).Count
Write-Output ('CLEANUP_SUITE_RESULT failures='+$failed)
exit $(if($failed){1}else{0})
