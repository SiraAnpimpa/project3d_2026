# Runtime tests — Core phases, Refinement Pass 1 and Map Redesign

## Current: Gameplay & Character Refinement

Latest individual gates and evidence: [test results](../docs/gameplay_refinement/test_results.json), [report section12](../GAMEPLAY_REFINEMENT_REPORT.md#12-tests-performed). Current focused gates were executed individually; the portable wrapper is prepared and syntax checked, not claimed as a separate combined run. Earlier broad-suite/campaign counts below are historical.

```powershell
.\tests\run_gameplay_refinement.ps1 -Godot 'C:\path\to\Godot.exe'
# Add -WithRendering for player-camera plant/night/character captures.
# Add -WithProfiling for the 12-grown-plant, 1080p day/night timing fixture.
```

Optional -LogDirectory/-CaptureDirectory set outputs; defaults are .godot/test-logs/gameplay_refinement and .godot/test-captures/gameplay_refinement. Each process launches hidden; only its own timed-out process is stopped. Expected result/exit/parser/runtime/assertion/navigation errors are checked. Only the exact pre-existing Windows certificate-store line is excluded. Import, stamina, movement, stride, aim, bat, plants, live night, ordinary full-day/natural dawn and normal rendered boot are default gates; rendered captures and real-time profiling are optional.

| Script | Coverage |
|---|---|
| gameplay_stamina_measure.gd | Actual Shift full-to-empty and release recovery, HUD/range, before/after JSON |
| gameplay_movement_test.gd | Partial restart,20s finite sprint, uphill/downhill, upright root |
| gameplay_stride_measure.gd | Full-speed4/7m/s foot drift proxy and optional --cadence-audit |
| refinement_aim_test.gd | Existing vertical/strafe/backward/muzzle/reload/immediate-fire checks on current pose |
| gameplay_character_capture.gd | Rendered Idle/Walk/Run/rifle-ready/aim/bat phases; unit-scale socket/grips |
| gameplay_bat_test.gd | Actual equip/wheel/LMB, range/arc/cover/one hit/cooldown/cancel, zero ammo,10/6/30 variant kills, rifle state persistence |
| gameplay_plants_test.gd | Actual8 seed selections/E plant/harvest,24 growth geometries, capacity rollback and future stage art |
| gameplay_night_test.gd | Live damaging Normal/Runner/Tank, three rifle rounds exhausted, bat kills and paid Runner sprint escape |
| cleanup_full_day.gd | Unmodified ordinary seeds/time/input/natural crop/crafting/night/rest and separate damaged natural dawn |
| gameplay_plant_performance.gd | 12-grown-plant day/night600-frame render profile; --legacy-plant-art for art-only comparison |

Focused fixtures grant items/seek time or freeze enemies where explicitly noted in the report. Live night retains pursuit/player damage, but isolates enemies from waves. The ordinary full-day script separately uses natural time/resources/earned rest. Fixed-FPS headless simulation and rendered screenshots are automated evidence, not human keyboard/listening tests. The full-day run is headless; plant/night/character views were rendered and inspected.

## Historical: Final environment cleanup

Latest individual checks and full logs: [results](../docs/map_final_cleanup/test_results.json), [report](../MAP_FINAL_CLEANUP_REPORT.md). Seventeen recorded process gates (including two baselines and a performance confirmation) plus source scope audit pass. This is not a new combined run of older 40/48/52 suites. The portable wrapper below is prepared/syntax checked; the corresponding current individual gates were executed.

```powershell
.\tests\run_cleanup_tests.ps1 -Godot 'C:\path\to\Godot.exe'
# Add -WithProfiling for the unmodified four-scenario rendered timing fixture.
```

Optional -LogDirectory /-CaptureDirectory select output folders; defaults are .godot/test-logs/cleanup and .godot/test-captures/cleanup. Every process launches hidden and is terminated only by its own timeout; result/exit/error/navigation diagnostics are checked, excluding only the known certificate-store message. The wrapper runs import, geometry, metrics, nav-edge audit, routes, full-day, headless acceptance, rendered night, rendered survey, rendered rescue and normal rendered boot; profiling is optional. It does not automatically rebake navigation.

Fixtures: cleanup_geometry.gd (frame/bench/fence/rock/tool/floor/rotor contacts), cleanup_metrics.gd, cleanup_routes.gd (24 real enemies and 120 camera probes), cleanup_full_day.gd (ordinary resources/time/input), cleanup_acceptance.gd (all twelve E pairs, 22 walks/176 cameras/physical edges/reveal/night assertions), cleanup_night.gd (same live night assertion section, sixteen screenshots), cleanup_survey.gd (27 actual-input walks/99 day/night/detail/top images), cleanup_rescue_capture.gd (five ending images). cleanup_finish_views.gd refreshed only affected workshop views after the last decorative lean; normal full survey already includes that final geometry when rerun.

Headless acceptance and rendered night are separate because the aggregate rendered route tour exceeded 240 seconds. Controller/assertion limits remain intact; long rendered survey/night wrappers allow360 seconds. Scenery night survey controls time/damage and disables pursuit; night combat controls ammo/damage; full-day provides separate ordinary-resource/natural-time/damage evidence. Automated production input/framebuffer inspection is not human keyboard playtesting. Historical coordinate fixtures below target their stated map versions.

## Earlier phase records

The following sections preserve earlier versions and their stated counts; current source/evidence is described above.

## Historical Map Beautification gates

Current evidence: [MAP_BEAUTIFICATION_REPORT.md](../MAP_BEAUTIFICATION_REPORT.md) and [latest individual checks](../docs/map_beautification/test_results.json). Ten current runtime/import/boot/profile gates plus bake/native Cabin audit/source scope pass; this is not a new combined run of the historical40/48/52 suites. Those counts below refer to previous map versions. Some older fixtures use earlier house/bench/cover/rescue coordinates; the new focused scripts target current geometry.

Run from the project directory with Godot4.7 /Compatibility:

```powershell
& tests/run_beautification_tests.ps1 -Godot 'C:/Users/ADMIN/Desktop/Godot_v4.7-stable_win64.exe/Godot_v4.7-stable_win64.exe' -WithProfiling
```

Default logs/captures are .godot/test-logs/beautification and .godot/test-captures/beautification; LogDirectory/CaptureDirectory can be overridden. The runner checks exit, expected result and parser/runtime/navigation errors. Only the known Windows certificate-store line is excluded explicitly. It runs sequentially so optional profiling is isolated. Rebuild static navigation separately after geometry edits with tools/bake_prototype_navigation.gd.

| Script | Coverage |
|---|---|
| beautification_metrics.gd | 3025 height samples, actual terrain triangle slopes, structural transforms, grass/lanes/landing clearance |
| tools/audit_navigation_edges.gd | Fails for a navigation edge shared by more than two polygons |
| beautification_routes.gd | 24 actual enemy entry/variant routes to field/home, input walks to all interactions and120 camera samples; waits for usable async paths |
| beautification_acceptance.gd | All12 real E plant/harvest pairs;22 input destinations/four physical edges/176 camera checks; road timing/reveal;12 night rifle cases and ordinary6-enemy/four-entry grounded wave |
| beautification_full_day.gd | Ordinary time/starter seeds/natural growth/40 crafted ammo/real rifle kills/damage/E rest; separate damaged no-rest natural dawn |
| beautification_survey.gd | Actual player walk to eight places, four yaws each and matched top/high/night composition images |
| beautification_rescue_capture.gd | New clearing/reveal/night and existing daylight ending at relocated anchor |
| phase_10_performance_test.gd | Unmodified same four-scenario profile before/after; damage-disabled synthetic stress |

beautification_cabin_probe.gd and beautification_path_probe.gd are diagnostic helpers; the cabin cutaway is not a production view. tools/audit_cabin.gd inspected the supplied native model. Controlled map/capture fixtures use paused time/resources/damage-off; the full-day cases do not use gameplay cheats. Automation and image inspection are not human keyboard playtesting or a new ten-day campaign.

## Historical results

## Major Map / Terrain Redesign results

Latest40 headless results pass after targeted repairs from an initial37/40. Current map gates were repeated after all playable tree collisions/final bake. This pass's evidence manifest contains48 successful latest checks including the rendered asset audit, map acceptance, real-time farming, camera walkthrough, composition/matched captures, four-scenario profile and normal rendered boot; it does not claim a new combined55-check run. Logs and methods: ../docs/map_redesign/test_results.json and ../MAP_REDESIGN_REPORT.md.

New scripts: map_redesign_metrics.gd (height/actual triangle slopes/collision/scene/asset budgets), map_redesign_acceptance.gd (all12 plot E interactions,22 real movement destinations,4 physical edges/176 camera samples,12 actual rifle cases and ordinary6-enemy/four-entry night), map_redesign_capture.gd (terrain/zone composition images). Existing refinement_map_test now records24 per-variant/entry/shelter-field route travel times; stage_1 uses the current outer wall. Capture helpers need an existing --capture-dir; the tests/run_tests runner creates it. Static collision edits require tools/bake_prototype_navigation.gd before tests.

Run from project root with Godot 4.7:

```powershell
.\tests\run_tests.ps1 -Godot 'C:\Users\ADMIN\Desktop\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64.exe' -WithRendering
```

Without `-WithRendering`: **40 checks** (import, 36 focused scripts, two full-day simulations, main boot). With it: **55 checks**, adding 15 rendered checks including refinement aim/skip and Phase 2–9 UI/gameplay. `-WithCampaign` optionally adds the historical Phase 10 campaign script; `-WithProfiling` adds the four-scenario rendered profile. Allow several minutes. Ordinary checks have a60-second timeout; the original full-day simulation has 180 seconds and the refinement version 240 seconds; nonzero exit, missing result, assertion/parser/runtime errors fail the suite. The known Windows root-certificate-store message is reported in full logs and excluded explicitly. No other engine error is excluded.

Default logs: `.godot/test-logs/`; captures: `.godot/test-captures/`. Override with `-LogDirectory` and `-CaptureDirectory`. Historical Phase 3 logs remain under `.godot/test-logs/phase3/`; historical Camera logs are under `.godot/test-logs/camera/`. Current Input logs are `.godot/test-logs/input/`; screenshots in `docs/input/`.


## Refinement Pass 1 — current results

Latest **52/52 per-check logs pass**. The combined run was 51/52; the headless mouse-capture fixture was corrected and its targeted rerun passed. Its rendered counterpart also passed. Original failure evidence is retained in [the result manifest](../docs/refinement1/test_results.json), with full scope/limits in [the report](../POST_PRODUCTION_REFINEMENT_1.md). Counts below describe historical milestones.

| Added script | Coverage |
|---|---|
| refinement_map_test.gd | 24 routes across all enemy types/entries, player access to plots/bench/bed/rescue, 120 camera samples |
| refinement_shelter_probe.gd | Rear-shelter Tank regression for upright pallet / navigation gap |
| refinement_movement_test.gd | Actual imported movement/Gun clips, speed matching and backward motion |
| refinement_holding_test.gd | Two grips, mode visibility, scale, muzzle and switching |
| refinement_aim_test.gd | Vertical/strafe/backward, capsule upright, barrel alignment, recoil and timer-linked reload |
| refinement_skip_test.gd | Mandatory confirmation/default Cancel, input/pause, same-day growth/night-once, menu/death/reload/spam/final-day, 720p/1080p |
| refinement_full_day_test.gd | MainMenu → real farming/crafting/aim → confirmed skip → combat → earned rest, plus unprepared natural dawn |
| refinement_campaign_test.gd | Additional normal-play 10-day campaign to rescue with finite resources and no gameplay cheats |

The campaign wrapper was run separately and passed. To repeat it:

```powershell
& $Godot --headless --path . --fixed-fps 60 --script res://tests/refinement_campaign_test.gd
```

Map/pose capture helpers accept the existing `-- --capture-dir <existing directory>` argument and require rendering. `tools/inspect_player_rig.gd` records real imported bones/clips. Headless tests cannot assert OS mouse capture; rendered tests verify that behavior. Code-driven poses do not constitute newly authored animation clips.

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


## Input / selection coverage (historical)

- `input_selection_data_test.gd`: 29 checks for dynamic list filtering/order/tie-breaks/33seeds/depletion and configurable equipment, ownership, slot repair and empty states.
- `input_modes_integration_test.gd`: 39 headless / 47 rendered checks (including7captures+capturemode), physical Tab/Q/V/E/Esc/R, wheel routing/memory, Combat-onlyaim, farming finalseed fallback and harvest, equip/unequip through bag clicks, pause/resume, death/restart.
- Rendered input run has no fixed-fps. Test-only weapons are transientItemData with names labelled(test); they are not added to the productioncatalog or starterloadout.
- Prior tests adapt intentional contracts: Tab replacesI, VreplacesQforShoulder, QentersCombatbeforeAim, Escpauses, depletedseedclears/fallsforward, startupautoselectsvalidseed. Core movement/farming/stat/growth assertions remain.
- Synthetic wheel events send pressed AND release edges to avoid retainingGUI mouse focus on modalshade. No productionUI workaround was added for that harness bug.

Historical input milestone suite: **27runs, failures=0**, Leadgrowth30.297real seconds. The olderCamera24run andPhase3counts above are also historical. See PHASE_INPUT_SELECTION_TEST_REPORT.md for those results. The refinement suite above is current.

## Phase 4 coverage

`phase_4_crafting_test.gd` exercises physical E planting and harvesting of all five crops, the existing E workbench interaction, modal pause and key routing, all three recipes, inventory quantities and stacking, full bag rollback, synchronous craft reentry, repeated craft presses, a resource-only recipe with two outputs, and duplicate ID validation. It runs headless and rendered; rendered captures can be saved with `-WithRendering`. See `PHASE_4_TEST_REPORT.md` for verified results and limits.

Historical Phase 4 final suite: **29 runs, failures=0**. Logs are in `.godot/test-logs/phase4_final/`; inspected screenshots are in `docs/phase4/`.

## Phase 5 coverage

`phase_5_weapon_test.gd` runs headless and rendered: actual farming/crafting/reload/aim/fire/dummy death, ammo accounting, spam, per-weapon magazine memory, switching, semi-auto and automatic fire, 30/120 Hz cooldowns, near/far/range, cover and clipped muzzle, empty equipment, UI/mode/death guards, debug gates and restart. Temporary pistol data is test-only. Previous catalog/startup tests now expect 14 items and the starter rifle.

Historical Phase 5 final suite: **31 runs, failures=0**. Logs `.godot/test-logs/phase5_final/`; screenshots `docs/phase5/`. See [Phase 5 report](../PHASE_5_TEST_REPORT.md) for exact results, assets and limits. Phase 5 crop setup advances the game clock; separate rendered Phase 3 validates natural growth (30.384 real seconds).

## Phase 6 coverage

`phase_6_zombie_test.gd` covers actual debug bag spawning, safe markers/cap, idle/detect/chase, speed/facing, box and shelter detours, player sprint input and target refresh, windup/miss/cooldown/wall checks, generic weapon hits and reload, hit/death animation, delayed cleanup, farm/night/pause, 3/5-agent independent attacks and rifle kills, player death/rebind and death cancellation. It runs headless and rendered with fixed simulation deltas; screenshot inspection confirms model/animation/UI. Pack combat heals the player in the fixture for sustained observation; a separate melee death case verifies game over.

Historical Phase 6 suite: **33/33 passed**, logs `.godot/test-logs/phase6_final/`, images `docs/phase6/`, details in [Phase 6 report](../PHASE_6_TEST_REPORT.md). After the full suite, two assertions for moving-target chase and debug UI clicking were added and the focused headless/rendered tests rerun successfully. No unrelated production changes followed the regression run. Natural growth still has its separate real-time rendered test (30.409 seconds).

## Phase 7 coverage (historical)

- `phase_7_lifecycle_test.gd`: auto18:00, pending count/duplicate guards, distributed safe spawn, clear/rest restrictions, physical bed E/aim lock, healing/day increment/plant time skip, dawn cleanup without restoration, blocked/retry/replacement, death/restart, interrupted rest, backward seek and Day2 reuse. Runs headless and rendered; controlled clock seeks/damage isolate edge cases.
- `phase_7_full_day_test.gd`: headless production-clock simulation of two complete Day1 scenarios. Movement/wheel/E/crafting UI/Q/R/RMB/LMB prepare eight crops,40ammo+medicine, kill6with30shots, then walk/rest into Day2. Second unprepared night kites until natural dawn with reduced stats. No clock seek/time-scale changes/teleports/grants/heals/direct enemy damage; fixed engine deltas accelerate wall time. It is automated simulation, not manual realtime playtesting.180second timeout accommodates the full frame count.
- Historical Phase 7 suite size:36checks, all latest runs passed. Initial combined batch failed two rendered camera checks; unchanged isolated reruns passed both. Cause not isolated; see report caveat. Final results: PHASE_7_TEST_REPORT.md; logs `.godot/test-logs/phase7_final/`; inspected captures `docs/phase7/`.
