# Gameplay refinement evidence — 2026-10-02

Current source pass, stages A→B/C→D→E→F. [Report with15 requested topics](../../GAMEPLAY_REFINEMENT_REPORT.md), [full Nature/plant mapping](../../PLANT_VISUAL_ASSET_MAPPING.md), [current controls](../../CONTROLS.md).

## Verification and preservation

- [test_results.json](test_results.json):25 relevant completed individual process gates, including labelled baselines/audits/comparisons. Expected result lines and diagnostics checked; only the known Windows certificate-store line excluded. Observed process exits were0. The portable wrapper is syntax checked, not a separate combined run.
- [scope_audit.json](scope_audit.json):947-file dirty-source baseline;26 existing production changes,317 other protected code files,571 unchanged existing assets/244 GLBs/21 audio files, preserved project/export settings and eight plant economic/stage records.
- [production_changes.patch](production_changes.patch):only this pass's existing production changes, compared with its actual starting source rather than Git HEAD.
- [hashes_before.json](hashes_before.json), [hashes_after.json](hashes_after.json), [git_status_before.txt](git_status_before.txt), [git_status_after.txt](git_status_after.txt):pre-existing dirty work retained. No commit/push/export.

## Actual assets and captures

- [asset_audit_combined.json](asset_audit_combined.json):138 actual imported models;131 initial candidates plus7 remaining weapon/arrow/shield sources. All68 Nature sources inspected before plant edits. [audit/](audit) holds138 renderer images; [contact/](contact) has audit and player-camera sheets.
- [before/](before):8 baseline images (stamina3, poses5).
- [after/](after):31 images covering stamina, rifle, bat, final character poses and live night. [Final character sheet](contact/character_final_qa.png), [night sheet](contact/night_qa.png).
- [plants/](plants):13 actual player-camera images:all8 crops, seed/sprout/growing/ready farm, real-clock ready. [Plant sheet](contact/plants_qa.png), [growth sheet](contact/growth_qa.png).
- [gameplay_plant_mapping.json](gameplay_plant_mapping.json):exact source bounds/scales/ground offsets. [gameplay_plant_geometry.json](gameplay_plant_geometry.json):24 stage measurements.

The audit field `triangle_upper_bound` is a legacy vertex-count/3 proxy, not a measured indexed triangle count. Crop cost is judged using actual mesh/material/collision checks and rendered profiles.

## Measurements

- Stamina: [before](gameplay_stamina_before.json), [after](gameplay_stamina_after.json). Actual input,60Hz physics; original HUD precision issue repaired in the harness.
- Cadence: [before sample](gameplay_stride_before.json), [initial after sample](gameplay_stride_after.json), [matched rate candidates](gameplay_stride_candidates.json), [final selected rate](gameplay_stride_selected.json). The matched candidate replay confirms full4/7m/s movement. Near-floor drift is a comparison proxy, not perfect foot locking.
- Live night: [gameplay_night_result.json](gameplay_night_result.json), rendered finalHP5, ammo0,3 rifle shots,11 bat hits and180 Runner sprint ticks/58 stamina. Headless finalHP30 is retained in its log; capture frames allow more Tank attacks. Pursuit/damage are active; controlled enemy/time setup differs from ordinary waves.
- True-source full-farm profiles: [before](gameplay_plant_performance_before.json), [after](gameplay_plant_performance_after.json).
- Same-current-code art-only profiles: [legacy](gameplay_plant_performance_matched_legacy.json), [current](gameplay_plant_performance_matched_current.json).600 real rendered frames per scenario,12 grown plants,1080p, RTX4060 Laptop. Current night mean+0.175ms; p99 and draw calls lower. Short samples with a pre-existing background Godot are not release/minimum-hardware certification.

## Log history and test boundaries

[logs/](logs) retains every attempt, not just the successful manifest selection. Earlier failed harness attempts:baseline_stamina (HUD precision);stride_audit (type),stride_audit_2 (Matt path/timeout);matched_legacy_art and matched_current_art (profile clone type). Their repaired counterparts pass. Other intermediate cadence measurements are retained; the too-fast Run rate was rejected by drift, not used in production.

Final current gates:stamina_after,movement_stage_a,stride_selected,bat_final_logic,plants_logic/plants_rendered,night_live/night_rendered,full_day_regression,character_grip_capture,aim_final,matched_*_2,final_import,final_normal_boot. Native rig/hand/assets and baseline measurements are separately labelled in the manifest.

Focused fixtures grant supplies/seek time/freeze variants where needed. All-eight crop setup unlocks Day7 in its test only. Separate live night retains player damage and chase; ordinary unchanged cleanup_full_day uses natural time/finite seeds/crafting/real rifle damage/earned rest plus damaged no-rest dawn. Fixed-FPS headless simulation and inspected rendered screenshots are automated evidence; no human keyboard/listening test, new ten-day campaign or release export is claimed. Only the exact pre-existing Windows certificate-store diagnostic is excluded.

Run current focused gates with `tests/run_gameplay_refinement.ps1`; see [tests/README.md](../../tests/README.md). **STOP for user review.**
