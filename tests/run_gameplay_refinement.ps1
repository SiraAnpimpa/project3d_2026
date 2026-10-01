param(
    [Parameter(Mandatory=$true)][string]$Godot,
    [string]$LogDirectory,
    [string]$CaptureDirectory,
    [switch]$WithRendering,
    [switch]$WithProfiling
)
$ErrorActionPreference = 'Stop'
$projectPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not $LogDirectory) { $LogDirectory = Join-Path $projectPath '.godot/test-logs/gameplay_refinement' }
if (-not $CaptureDirectory) { $CaptureDirectory = Join-Path $projectPath '.godot/test-captures/gameplay_refinement' }
$LogDirectory = [IO.Path]::GetFullPath($LogDirectory)
$CaptureDirectory = [IO.Path]::GetFullPath($CaptureDirectory)
New-Item -ItemType Directory -Force -Path $LogDirectory,$CaptureDirectory | Out-Null
$results = [Collections.Generic.List[object]]::new()
$checks = @(
    @{ Name='import'; Extra='--editor --quit'; Render=$false; Pattern='Godot Engine'; Timeout=120 },
    @{ Name='stamina'; Script='tests/gameplay_stamina_measure.gd'; Render=$false; Pattern='GAMEPLAY_STAMINA_MEASURE_RESULT failures=0'; Timeout=90 },
    @{ Name='movement'; Script='tests/gameplay_movement_test.gd'; Render=$false; Pattern='GAMEPLAY_MOVEMENT_RESULT failures=0'; Timeout=90 },
    @{ Name='stride'; Script='tests/gameplay_stride_measure.gd'; Render=$false; Pattern='GAMEPLAY_STRIDE_MEASURE_RESULT failures=0'; Timeout=90 },
    @{ Name='aim'; Script='tests/refinement_aim_test.gd'; Render=$false; Pattern='REFINEMENT_AIM_RESULT failures=0'; Timeout=90 },
    @{ Name='bat'; Script='tests/gameplay_bat_test.gd'; Render=$false; Pattern='GAMEPLAY_BAT_RESULT failures=0'; Timeout=180 },
    @{ Name='plants'; Script='tests/gameplay_plants_test.gd'; Render=$false; Pattern='GAMEPLAY_PLANTS_RESULT failures=0'; Timeout=120 },
    @{ Name='night'; Script='tests/gameplay_night_test.gd'; Render=$false; Pattern='GAMEPLAY_NIGHT_RESULT failures=0'; Timeout=180 },
    @{ Name='full_day'; Script='tests/cleanup_full_day.gd'; Render=$false; Pattern='CLEANUP_FULL_DAY_RESULT failures=0'; Timeout=240 }
)
if ($WithRendering) {
    $checks += @(
        @{ Name='plants_rendered'; Script='tests/gameplay_plants_test.gd'; Render=$true; Pattern='GAMEPLAY_PLANTS_RESULT failures=0'; Timeout=180 },
        @{ Name='night_rendered'; Script='tests/gameplay_night_test.gd'; Render=$true; Pattern='GAMEPLAY_NIGHT_RESULT failures=0'; Timeout=360 },
        @{ Name='character_rendered'; Script='tests/gameplay_character_capture.gd'; Render=$true; Pattern='GAMEPLAY_CHARACTER_CAPTURE_RESULT failures=0'; Timeout=120 }
    )
}
if ($WithProfiling) {
    $checks += @{ Name='plant_performance'; Script='tests/gameplay_plant_performance.gd'; Render=$true; Realtime=$true; Pattern='GAMEPLAY_PLANT_PERFORMANCE_RESULT failures=0'; Timeout=120 }
}
$checks += @{ Name='normal_boot'; Extra='--quit-after 120'; Render=$true; Pattern='Godot Engine'; Timeout=90 }
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
        ($_ -match '^\s*(ERROR:|SCRIPT ERROR:|FAIL:)|Parse Error:|^WARNING:.*[Nn]avigation') -and
        ($_.Trim() -ne 'ERROR: Failed to read the root certificate store.')
    })
    $hasResult = ($lines -join "`n") -match ('(?m)^'+[regex]::Escape($check.Pattern)+'(?:\s|$)')
    $passed = $finished -and $process.ExitCode -eq 0 -and $errors.Count -eq 0 -and $hasResult
    $results.Add([pscustomobject]@{
        name=$check.Name; passed=$passed; exit_code=$process.ExitCode
        timeout=(-not $finished); result_found=$hasResult; errors=$errors; log=$logPath
    })
    Write-Output ($check.Name+': '+$(if($passed){'PASS'}else{'FAIL'}))
}
$results | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $LogDirectory 'results.json') -Encoding UTF8
$failed = @($results | Where-Object {-not $_.passed}).Count
Write-Output ('GAMEPLAY_REFINEMENT_SUITE_RESULT failures='+$failed)
exit $(if($failed){1}else{0})
