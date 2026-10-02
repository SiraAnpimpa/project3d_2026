# UI polish evidence

Final status COMPLETE — STOP,2026-10-02. Main report: ../../UI_POLISH_REPORT.md. All final result markers are failures=0; scope shows no unexpected source change.

| Evidence | Contents |
|---|---|
| before/ |27 original normal-Play UI captures |
| after/ |51 final UI/state/resolution captures |
| contact_sheets/ |Complete before and final inspection sheets |
| asset_contact_sheets/ |Six complete supplied PNG sheets plus PSD composites |
| free_asset_inventory.json |540 files, decode/type/size/SHA-256 audit |
| scope_audit.json |Original1527 hashes; approved UI/docs/test changes; all core/art preserved |
| test_results.json |Final gates, counts and environment-only message separation |
| logs/ |Before, intermediate repair attempts and final logs |
| performance_before.json / performance_after.json |Same three600-frame render profiles |
| stamina_measure.json |Exact existing stamina configuration and per-tick HUD trace |
| overview.png |Four representative final screens |

## Reproduce

From this project with Godot4.7, run tests/ui_polish_test.gd headless, tests/ui_polish_capture.gd with a renderer and `-- --capture-dir <absolute-directory> --all-resolutions`, and tests/ui_polish_performance.gd with a renderer and real time (no fixed-fps). Capture now creates its output directory. The profile scene is normal Play with clock paused; it is not a night/balance benchmark.

Other final regressions: gameplay_stamina_measure.gd, gameplay_bat_test.gd, gameplay_night_test.gd, gameplay_plants_test.gd, refinement_skip_test.gd. Bat changes only one historical HUD expectation. Use isolated user data when reproducing test fixtures.

## Attempt history

The first functional run identified an unsupported growth-time format specifier; repaired. First visual inspection identified a stretched button graphic, bottom-right inset and stale mode/swing labels. Confirmation setup initially lacked an output folder and used an unstable generated-node lookup; repaired. Bounds then identified the guide minimum height; repaired. `ui_visual_final`, `ui_contracts_final` and `ui_import_final` are authoritative; intermediate failed logs are retained for traceability.

All actual gameplay services/data/map/characters remained unchanged. Existing ending timing/vehicle/camera is hash-preserved. UI damage/hit capture fixtures deliberately trigger visual signals; separate live-zombie/weapon tests verify the actual damage path.
