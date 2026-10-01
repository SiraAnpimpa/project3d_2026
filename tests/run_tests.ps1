param(
    [Parameter(Mandatory = $true)][string]$Godot,
    [string]$LogDirectory = (Join-Path $PSScriptRoot '..\.godot\test-logs'),
    [switch]$WithRendering,
    [switch]$WithCampaign,
    [switch]$WithProfiling,
    [string]$CaptureDirectory = (Join-Path $PSScriptRoot '..\.godot\test-captures')
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
New-Item -ItemType Directory -Force -Path $LogDirectory | Out-Null
$LogDirectory = (Resolve-Path -LiteralPath $LogDirectory).Path
$failures = 0

function Invoke-GodotCheck {
    param([string]$Name, [string]$Arguments, [bool]$ExpectResult = $true, [int]$TimeoutSeconds = 60)
    $logFile = Join-Path $LogDirectory ($Name + '.log')
    $arguments = '--path "' + $projectRoot + '" --log-file "' + $logFile + '" ' + $Arguments
    $process = Start-Process -FilePath $Godot -ArgumentList $arguments -WindowStyle Hidden -PassThru
    if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
        $process.Kill()
        $script:failures += 1
        Write-Output "FAIL $Name ($TimeoutSeconds-second timeout): $logFile"
        return
    }
    $content = Get-Content -LiteralPath $logFile -Raw
    $errors = @($content -split "`n" | Where-Object {
        ($_ -match '^SCRIPT ERROR:|^ERROR:|FAIL:') -and ($_ -notmatch 'Failed to read the root certificate store')
    })
    $missingResult = $ExpectResult -and ($content -notmatch '_RESULT')
    if ($process.ExitCode -ne 0 -or $errors.Count -gt 0 -or $missingResult -or $content -match 'pass=false|failures=[1-9]') {
        $script:failures += 1
        Write-Output "FAIL $Name (exit $($process.ExitCode)): $logFile"
        Write-Output $errors
    } else {
        Write-Output "PASS $Name (exit $($process.ExitCode))"
        $content -split "`n" | Where-Object { $_ -match '_RESULT|SKIP:|GROWTH_RUNTIME' } | Write-Output
    }
    if ($content -match 'Failed to read the root certificate store') {
        Write-Output 'Environment note: Godot could not read the Windows certificate store; see full log.'
    }
}

Invoke-GodotCheck 'editor_import' '--headless --import' $false
foreach ($test in @(
    'stage_1_test', 'stage_2_interaction_test', 'stage_3_stats_test',
    'stage_4_clock_test', 'movement_rate_test', 'phase_2_integration_test',
    'phase_3_inventory_test', 'phase_3_ui_test', 'phase_3_data_test',
    'phase_3_farming_test', 'phase_3_debug_test', 'phase_3_extension_test',
    'phase_3_growth_rate_test', 'phase_3_integration_test',
    'camera_controls_test', 'camera_collision_ray_test', 'camera_rate_test',
    'camera_walkthrough_test', 'input_selection_data_test', 'input_modes_integration_test',
    'phase_4_crafting_test', 'phase_5_weapon_test', 'phase_6_zombie_test', 'phase_7_lifecycle_test', 'phase_8_progression_test', 'phase_8_variants_test', 'phase_9_presentation_test', 'phase_10_death_matrix_test',
    'refinement_map_test', 'map_redesign_metrics', 'map_redesign_acceptance', 'refinement_shelter_probe', 'refinement_movement_test', 'refinement_holding_test', 'refinement_aim_test', 'refinement_skip_test'
)) {
    Invoke-GodotCheck $test ('--headless --fixed-fps 60 --script res://tests/' + $test + '.gd')
}
Invoke-GodotCheck 'phase_7_full_day_test' '--headless --fixed-fps 60 --script res://tests/phase_7_full_day_test.gd' $true 180
Invoke-GodotCheck 'refinement_full_day_test' '--headless --fixed-fps 60 --script res://tests/refinement_full_day_test.gd' $true 240
Invoke-GodotCheck 'main_scene_boot' '--headless --fixed-fps 60 --quit-after 120' $false
if ($WithRendering) {
    New-Item -ItemType Directory -Force -Path $CaptureDirectory | Out-Null
    $capturePath = (Resolve-Path -LiteralPath $CaptureDirectory).Path
    Invoke-GodotCheck 'rendered_map_acceptance' ('--audio-driver Dummy --fixed-fps 60 --script res://tests/map_redesign_acceptance.gd -- --capture-dir "' + $capturePath + '"')
    Invoke-GodotCheck 'rendered_refinement_aim' ('--audio-driver Dummy --fixed-fps 60 --script res://tests/refinement_aim_test.gd -- --capture-dir "' + $capturePath + '"')
    Invoke-GodotCheck 'rendered_refinement_skip' ('--audio-driver Dummy --fixed-fps 60 --script res://tests/refinement_skip_test.gd -- --capture-dir "' + $capturePath + '"')
    Invoke-GodotCheck 'rendered_phase2' ('--audio-driver Dummy --fixed-fps 60 --script res://tests/phase_2_integration_test.gd -- --capture-dir "' + $capturePath + '"')
    # No --fixed-fps here: verify the farming loop against real elapsed time.
    Invoke-GodotCheck 'rendered_phase3' ('--audio-driver Dummy --script res://tests/phase_3_integration_test.gd -- --realtime --capture-dir "' + $capturePath + '"')
    Invoke-GodotCheck 'rendered_camera_controls' '--audio-driver Dummy --fixed-fps 60 --script res://tests/camera_controls_test.gd'
    Invoke-GodotCheck 'rendered_camera_walkthrough' ('--audio-driver Dummy --script res://tests/camera_walkthrough_test.gd -- --capture-dir "' + $capturePath + '"')
    Invoke-GodotCheck 'rendered_input_modes' ('--audio-driver Dummy --script res://tests/input_modes_integration_test.gd -- --capture-dir "' + $capturePath + '"')
    Invoke-GodotCheck 'rendered_phase4_crafting' ('--audio-driver Dummy --script res://tests/phase_4_crafting_test.gd -- --capture-dir "' + $capturePath + '"')
    Invoke-GodotCheck 'rendered_phase5_weapon' ('--audio-driver Dummy --script res://tests/phase_5_weapon_test.gd -- --capture-dir "' + $capturePath + '"')
    Invoke-GodotCheck 'rendered_phase6_zombie' ('--audio-driver Dummy --fixed-fps 60 --script res://tests/phase_6_zombie_test.gd -- --capture-dir "' + $capturePath + '"')
    Invoke-GodotCheck 'rendered_phase7_lifecycle' ('--audio-driver Dummy --fixed-fps 60 --script res://tests/phase_7_lifecycle_test.gd -- --capture-dir "' + $capturePath + '"')
    Invoke-GodotCheck 'rendered_phase8_progression' ('--audio-driver Dummy --fixed-fps 60 --script res://tests/phase_8_progression_test.gd -- --capture-dir "' + $capturePath + '"')
    Invoke-GodotCheck 'rendered_phase8_variants' ('--audio-driver Dummy --fixed-fps 60 --script res://tests/phase_8_variants_test.gd -- --capture-dir "' + $capturePath + '"')
    Invoke-GodotCheck 'rendered_phase9_presentation' ('--audio-driver Dummy --fixed-fps 60 --script res://tests/phase_9_presentation_test.gd -- --capture-dir "' + $capturePath + '"')
}
if ($WithCampaign) {
    Invoke-GodotCheck 'phase_10_campaign_test' '--headless --fixed-fps 60 --script res://tests/phase_10_campaign_test.gd' $true 900
}
if ($WithProfiling) {
    Invoke-GodotCheck 'phase_10_performance_test' '--audio-driver Dummy --script res://tests/phase_10_performance_test.gd' $true 120
}
Write-Output "SUITE_RESULT failures=$failures logs=$LogDirectory"
exit $failures
