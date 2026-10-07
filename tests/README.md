# Runtime checks

These Godot scripts exercise game systems and capture rendered views. Run commands from the project root with Godot 4.7 available as `godot`, or replace it with the executable path.

## Prepare imported resources

```powershell
godot --headless --path . --editor --quit
```

## Focused checks

```powershell
godot --headless --path . --fixed-fps 60 --script res://tests/ground_contact_audit.gd -- --validate
godot --headless --path . --fixed-fps 60 --script res://tests/cleanup_geometry.gd
godot --headless --path . --fixed-fps 60 --script res://tests/cleanup_routes.gd
godot --headless --path . --fixed-fps 60 --script res://tests/animation_feel_test.gd
godot --headless --path . --fixed-fps 60 --script res://tools/audit_navigation_edges.gd
```

The ground-contact audit samples rendered tree/rock basal geometry against terrain. Geometry and route checks cover world support and traversal. Animation checks cover locomotion, grips, weapon transitions and reactions. Navigation auditing checks mesh edges.

## Camera and skip actions

Use Godot 4.7.1 or compatible 4.7. Mouse capture needs a rendered window; headless runs explicitly verify that visible-cursor motion cannot rotate the camera.

```powershell
godot --headless --path . --fixed-fps 60 --script res://tests/camera_clarity_test.gd -- --idle-only
godot --path . --audio-driver Dummy --fixed-fps 60 --script res://tests/camera_clarity_test.gd
godot --headless --path . --fixed-fps 60 --script res://tests/refinement_skip_test.gd
godot --path . --audio-driver Dummy --fixed-fps 60 --script res://tests/refinement_skip_test.gd
godot --headless --path . --fixed-fps 60 --script res://tests/refinement_full_day_test.gd
```

The camera fixture covers seven 30-second simulated idle contexts, WASD/sprint, visible cursor and recapture, inventory/crafting/pause/Settings/focus transitions, low/default/high sensitivity in normal/aim play, and 30/120 physics Hz. The skip fixture uses actual wave clearing, N confirmation/cancel/spam, modal/reload/death/stale-state gates, overnight crop growth and daily supplies, unchanged cabin healing, and final rescue dawn. The full-day fixture uses the current map navigation through Main Menu, farming, crafting, rifle combat, cabin rest and a no-rest dawn.

For persistence, run the camera fixture in **two separate processes** with `-- --settings-write`, then `-- --settings-read`. The writer sets 1.7x; use an isolated Godot user-data directory for these tests (on Windows, point `APPDATA` and `LOCALAPPDATA` at a temporary test folder). Add `-- --capture-dir <existing-folder>` to rendered fixtures to capture Settings and E/N UI.

## Special ammo selection

```powershell
godot --headless --path . --fixed-fps 60 --script res://tests/special_ammo_test.gd
godot --headless --path . --fixed-fps 60 --script res://tests/special_ammo_edge_test.gd
godot --path . --audio-driver Dummy --fixed-fps 60 --script res://tests/special_ammo_test.gd -- --capture-dir 'C:/your-output/ammo'
```

Precreate the capture folder. Both fixtures enter via Main Menu Play. The full ammo fixture supplies real recipe ingredients and advances existing unlock data as fixture setup, then uses actual E/workbench recipe buttons/C/R/aim/hitscan. It covers every existing special ammo (Fire/Ice/Poison), inventory transfers, loaded versus selected types, impact scenes, timed statuses, real Ice chase speed, Normal fallback, per-weapon memory, melee/Normal-only UI, cancellations, pause/death and a new game reset. Electric is absent from the catalog and is not fabricated.

The edge fixture covers partial reserves, inventory capacity checks at start and commit, returned rounds, cancellation, missing reserve during reload, ammo conservation, independent statuses and DOT totals at 30/120 Hz. Status calculations use the production zombie tick with stationary fixture targets, plus an actual paused/resumed tick check. Rendered runs validate real item art and 720p/1080p HUD; these are automated checks, not a manual playthrough.

## Rendered captures

Precreate an output folder outside the project. Capture scripts require a render device; do not add `--headless`:

```powershell
New-Item -ItemType Directory -Path 'C:/your-output/survival-ui' -Force
godot --path . --fixed-fps 60 --script res://tests/survival_ui_capture.gd -- --capture-dir 'C:/your-output/survival-ui'
```

Other capture entry points include `ground_contact_capture.gd`, `scenery_placement_capture.gd` and `animation_feel_capture.gd`. Check each script’s argument handling before use. Some older fixtures assume earlier map coordinates; choose focused checks that match the system being changed.

Inspect each result marker, failure count and engine errors; an automated fixture is not a full human playthrough. Do not change production tuning to make a fixture pass. For ordinary gameplay, run the project normally and follow the [player guide](../README.md).
