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

## Rendered captures

Precreate an output folder outside the project. Capture scripts require a render device; do not add `--headless`:

```powershell
New-Item -ItemType Directory -Path 'C:/your-output/survival-ui' -Force
godot --path . --fixed-fps 60 --script res://tests/survival_ui_capture.gd -- --capture-dir 'C:/your-output/survival-ui'
```

Other capture entry points include `ground_contact_capture.gd`, `scenery_placement_capture.gd` and `animation_feel_capture.gd`. Check each script’s argument handling before use. Some older fixtures assume earlier map coordinates; choose focused checks that match the system being changed.

Inspect each result marker, failure count and engine errors; an automated fixture is not a full human playthrough. Do not change production tuning to make a fixture pass. For ordinary gameplay, run the project normally and follow the [player guide](../README.md).
