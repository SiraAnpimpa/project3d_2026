# Map beautification evidence — 2026-10-01

[Complete report](../../MAP_BEAUTIFICATION_REPORT.md). Implementation and current-map validation complete; STOP for map review.

## Visual review

- before/ and after/: 38 images each, matched overview/top/farmstead/rescue/boundaries/night plus four player views at eight actual walked destinations.
- rescue/: level clearing, reveal, farm-side occlusion, night and actual existing daylight ending.
- night_combat/: twelve Normal/Runner/Tank × entry rifle images and four ordinary-wave views.
- Native supplied Cabin inspection: logs/cabin_audit_fixed.log. Raw inspection views are retained in cabin_audit/.

## Data and scope

- metrics.json: terrain collision/slopes, scene counts, grass by role and structural transforms.
- asset_usage.json: real model instance/zone counts; MAP_ASSET_USAGE.md adds original paths and purpose.
- routes.json: 24 actual enemy routes and simulated travel times.
- rescue_distance.json: actual input walking time and four eyes × five landing-surface rays.
- performance_before.json / performance_after.json: same four-scenario debug profile (other current-map QA jobs completed; one separate Godot process remained).
- scope_integrity.json / source_hashes.json: 195 protected core files and 244 GLBs plus supplied audio preserved.
- diffs/: current pass changes compared with the dirty pre-pass snapshot. Historical reports/evidence remain separate.
- test_results.json: latest individual gate evidence; no claim of a new combined historical suite.
- logs/: successful final checks and failed intermediate attempts, including repairs and the known Windows certificate diagnostic.

## Reproduce

Run current source with Godot 4.7 / Compatibility. From the project directory:

```powershell
& tests/run_beautification_tests.ps1 -Godot 'C:/Users/ADMIN/Desktop/Godot_v4.7-stable_win64.exe/Godot_v4.7-stable_win64.exe' -WithProfiling
```

The focused runner checks import, metrics, edge topology, routes, ordinary-resource full day, rendered map acceptance/survey/rescue, normal boot and optional isolated profiling. It checks result markers and errors in addition to exit codes. It explicitly excludes only the existing Windows root-certificate-store diagnostic. It does not rebuild navigation; after editing static geometry, run tools/bake_prototype_navigation.gd first.

Geometry/capture/combat fixtures use controlled scene placement, paused clock/damage or resource grants. The full-day fixture uses production time, starter resources, real hits/kills and bed interaction; the performance fixture is synthetic stress. Automated input/render inspection is not human playtesting or minimum-hardware certification.
