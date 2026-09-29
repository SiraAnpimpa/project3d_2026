# Runtime tests — Phases 2, 3, Camera and Input / Selection

Run from project root with Godot 4.7:

```powershell
.\tests\run_tests.ps1 -Godot 'C:\Users\ADMIN\Desktop\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64.exe' -WithRendering
```

Without `-WithRendering`: 22 runs (import,20 test scripts,main boot). With it: 27 runs, including Phase 2 mouse capture, Phase 3 real-time farming, camera controls, camera walkthrough and input/modes integration. Allow approximately two minutes. Every process has a60-second timeout; nonzero exit, missing result, assertion/parser/runtime errors fail the suite. The known Windows root-certificate-store message is reported in full logs and excluded explicitly. No other engine error is excluded.

Default logs: `.godot/test-logs/`; captures: `.godot/test-captures/`. Override with `-LogDirectory` and `-CaptureDirectory`. Historical Phase 3 logs remain under `.godot/test-logs/phase3/`; historical Camera logs are under `.godot/test-logs/camera/`. Current Input logs are `.godot/test-logs/input/`; screenshots in `docs/input/`.

## Phase 3 coverage

| Script | Coverage |
|---|---|
| phase_3_inventory_test.gd | add/remove, stack splitting/space, all-or-nothing failure, selection, loadout |
| phase_3_ui_test.gd | inventory opening/closing, keyboard selection, pause across systems, count updates |
| phase_3_data_test.gd | catalog integrity, unique IDs, invalid data diagnostics |
| phase_3_farming_test.gd | plant/grow/harvest, spam/reentrancy, capacity, night growth, persistence/death |
| phase_3_debug_test.gd | all6 farming actions, disabled and Inspector gates, menu pause |
| phase_3_extension_test.gd | sixth plant from3Resource fixtures, no core-script changes |
| phase_3_growth_rate_test.gd | identical growth at30/120 Hz; ready at30seconds |
| phase_3_integration_test.gd | mouse seed selection, walking, Eplant/harvest, natural growth, bag update, reuse/restart |

Phase 2tests remain and cover movement/camera/interaction/HP/stamina/clock/day-night/HUD/debug. The Phase 2 integration test changes only the intentional camera input contract: camera_orbit→aim and raw screen_relative mouse events.

Headless runs use `--fixed-fps 60`: time deltas are simulated and wall time is shorter. Rendered Phase 3 intentionally omits it and asserts Lead growth in28–36real seconds, recording the observed duration. Movement is driven by Input actions; instantaneous key/click events are injected through the viewport. These are automated tests, not claims of manual keyboard playtesting.

Expected final output: `SUITE_RESULT failures=0`. Read `PHASE_3_TEST_REPORT.md` for results, captures and known limitations. Test fixtures do not enter the demo starter catalog.

## Camera coverage

| Script | Coverage |
|---|---|
| camera_controls_test.gd | 33 headless / 35 rendered assertions: normal/aim, orientation, movement/strafe/sprint, input and UI lifecycle |
| camera_collision_ray_test.gd | 19 assertions: rear/side/corner/ground, immediate rotation clearance, smooth return, jitter, hit/miss/range/resize/self exclusion |
| camera_rate_test.gd | Equal framing after 0.5 seconds with 30/120 update steps per second |
| camera_walkthrough_test.gd | 18 headless / 28 rendered assertions: real scene farming, movement/look, near/far aiming, strafe, Q, bag, wall, night and 10 saved screenshots |

Rendered camera walkthrough omits --fixed-fps and inspects actual rendering; its crop segment uses x20. Rendered Phase 3 separately verifies normal x1 growth (30.297 real seconds in final run). Runtime inputs are automated; screenshots were visually inspected. This is not a human playtest or a high-refresh benchmark.

Final Camera suite: 24 runs, failures=0. See PHASE_CAMERA_TEST_REPORT.md for exact values and limitations. Scripts instantiate the real GameRoot; temporary ray targets live only in test runs.


## Input / selection coverage (current)

- `input_selection_data_test.gd`: 29 checks for dynamic list filtering/order/tie-breaks/33seeds/depletion and configurable equipment, ownership, slot repair and empty states.
- `input_modes_integration_test.gd`: 39 headless / 47 rendered checks (including7captures+capturemode), physical Tab/Q/V/E/Esc/R, wheel routing/memory, Combat-onlyaim, farming finalseed fallback and harvest, equip/unequip through bag clicks, pause/resume, death/restart.
- Rendered input run has no fixed-fps. Test-only weapons are transientItemData with names labelled(test); they are not added to the productioncatalog or starterloadout.
- Prior tests adapt intentional contracts: Tab replacesI, VreplacesQforShoulder, QentersCombatbeforeAim, Escpauses, depletedseedclears/fallsforward, startupautoselectsvalidseed. Core movement/farming/stat/growth assertions remain.
- Synthetic wheel events send pressed AND release edges to avoid retainingGUI mouse focus on modalshade. No productionUI workaround was added for that harness bug.

Current final suite: **27runs, failures=0**, Leadgrowth30.297real seconds. The olderCamera24run andPhase3counts above are historical. See PHASE_INPUT_SELECTION_TEST_REPORT.md for current results. Full logs retain the known certificate-store environment error; no other error is ignored.
