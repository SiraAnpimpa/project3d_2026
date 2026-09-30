# Final QA report - v0.1.0-demo

Automated QA verified on2026-09-30. Windows x86_64 candidate exported. **Feature freeze:** final changes are seed-supply balance, release cleanup and QA/documentation. Distribution rights for original GLB packs remain unverified. This is an automated-tested release candidate, not a claim of manual full-campaign or clean-machine certification.

## 1. Build/version

v0.1.0-demo. Normal build: release/SomchaisLastHarvest_v0.1.0_demo/SomchaisLastHarvest.exe + .pck. QA builds in release/qa are separate and not for submission. The campaign QA executable is byte-identical to the normal candidate executable; QA PCK changes entry scene to a test driver while using the same gameplay resources. Normal PCK excludes tests and opens MainMenu. See build_manifest.json for hashes.

## 2. Godot version

Godot4.7.2.stable.official.ed1daf0bf, Compatibility. Matching official Windows release template installed; no engine downgrade. Release CLI lacks editor --script, so export_qa.py generates a Node test adapter and restores project/export settings in finally.

## 3. Platform

Windows, Intel Core i5-9300H, NVIDIA RTX2060 (OpenGL driver610.74). Windows also reports Intel UHD630; recorded renderer selected RTX2060. No minimum hardware specification inferred.

## 4. Full game test

Balanced release-template campaign passed Day1 through ten cleared waves and rescue.739actual shots,321rounds remaining. Normal growth/time, finite owned seeds, E planting/harvest, Workbench UI crafting, real rifle hits/reloads, enemy damage and earned bed healing. No god mode, grants, instant growth, direct enemy damage, kill-all, unlock-all, day seeks or player teleports. Fixed60Hz simulation runs faster than wall time; game clock/economy values are unchanged. The bot reads enemy positions, uses precise camera aiming and navigation to issue movement input; this demonstrates feasibility, not human difficulty.

| Day | Ammo before night | Shots used | HP damage | Ammo after | Outcome |
|---|---:|---:|---:|---:|---|
| 1 | 60 | 35 | 0 | 25 | Cleared / bed |
| 2 | 85 | 40 | 0 | 45 | Cleared / bed |
| 3 | 125 | 47 | 0 | 78 | Cleared / bed |
| 4 | 158 | 56 | 0 | 102 | Cleared / bed |
| 5 | 202 | 63 | 0 | 139 | Cleared / bed |
| 6 | 239 | 69 | 0 | 170 | Cleared / bed |
| 7 | 290 | 81 | 0 | 209 | Cleared / bed |
| 8 | 349 | 104 | 0 | 245 | Cleared / bed |
| 9 | 405 | 108 | 0 | 297 | Cleared / bed |
| 10 | 457 | 136 | 26 | 321 | Cleared / bed |

Resources before/after every night, medicine0, Basic Rifle, zombie counts and node samples: docs/phase10/campaign.json. All medicine values are0 because it is unusable. No claim of consumable balancing.

## 5. Day1

Three each Lead/Paper/Copper crops produce60rounds through natural farming/crafting. First wave clears with finite ammo; bed enters Day2. Prior no-rest full-day regression remains relevant: unprepared player can run until dawn, retain damage, obtain daily supplies and resume farming. New final campaign verifies actual release-template Day1 inputs/farming/combat/rest.

## 6. Day10

Final mixed wave14Normal+7Runner+3Tank,24total.457rounds before combat,136used,26damage taken,321remain. All enemies killed with Basic Rifle and production HP/damage. Final day is feasible without elemental effects or medicine.

## 7. Ending

Earned rest after Night10 starts rescue once and reaches ending screen. Exported rendered fixture also verifies natural dawn, damage/input lock, duplicate guard, landed helicopter, UI at1080p and return/restart buttons. Final-night death cannot trigger rescue.

## 8. Game Over / Restart

Dedicated death matrix passed daytime, nighttime, aiming, reloading, inventory, crafting, pause, near dawn and Night10. UI closes, mouse releases, weapon actions cancel, gameover appears and R resets health/day/ammo/waves. Lethal event is injected only in this isolated QA fixture, not campaign.

## 9. Farming

Existing eight-plant growth/harvest/replant/full-inventory regressions form the Phase9 baseline (42checks). New legitimate campaign repeatedly plants/harvests finite supplies at ordinary timestamps. Only supply quantities changed; growth/yield/plots unchanged. New progression rerun verifies magical crops, grants and pending rewards after balance change.

## 10. Crafting

Basic Ammo crafted through actual Workbench button every day; affordability and no-negative-inventory transaction preserved. Six-recipe/UI/capacity/spam/unlock regression baseline retained, with elemental recipes exercised in final progression test. Medicine requires2herbs but has no use; limitation disclosed.

## 11. Weapons

Basic Rifle unchanged:20damage,5Hz,10magazine,1.5s reload.739actual shots in final run. Existing aim/muzzle obstruction, switching/reload/cancel/range regression baseline retained. Only one usable weapon; no invented comparison of nonexistent weapon roles.

## 12. Zombies

Existing shared AI/Normal/Runner/Tank tuning preserved. Full campaign fights all three with normal damage enabled. Initial stationary agent died Night8 with ample ammunition; movement matters. Previous variants/nav tests remain baseline; no collision/AI edits were made in final phase.

## 13. Progression / state

Final headless progression test passed ten-day clock-driven transitions, unlock registries, grant receipts, full-bag pending delivery, variant queue replacement,12living cap, both final dawn/rest paths and cleanup. Daytime node count528 on all ten sampled days. Synthetic accelerated state fixture is separate from the legitimate campaign.

## 14. UI

Exported rendered tests pass menu/guide, bag, all six crafting entries, pause/guide, gameover, final warning, rescue and ending.720p/1080p evidence under docs/phase10/rendered. Final actual Quit button is clicked with viewport-scaled coordinates; process exits0. An initial unscaled fixture missed Quit at1080p; corrected test coordinates, no game change required.

## 15. Input

Actual injected key/mouse events cover movement, selection, E, Q, R, aim/fire, bag, Esc nesting and UI buttons. Release F1 is tested and stays disabled. Native desktop helper was unavailable (native pipe missing after retry/reset), so no additional Windows-window click test is claimed. Programmatic exported UI tests use Godot input events.

## 16. Navigation

Production navmesh/obstacles unchanged. Campaign traverses farm/Workbench/shelter using actual movement input along navigable paths and evades attackers with local clearance checks. A first test agent incorrectly walked straight through the shelter wall; fixed its route rather than altering collision. Existing three-variant/camera obstacle regressions remain applicable.

## 17. Performance / memory

Release-template rendered profiling,600frames per steady-state sample, no concurrent campaign during capture. Synthetic final-night stress keeps12enemies alive with damage disabled only for profiling.

| Scenario | Mean ms | p99 ms | Max ms | Draw calls |
|---|---:|---:|---:|---:|
| Day720p | 4.158 | 5.291 | 7.793 | 319 |
| Final night720p | 4.424 | 8.246 | 9.481 | 433 |
| Final night1080p | 4.819 | 8.175 | 8.831 | 432 |
| Ending1080p | 4.319 | 7.813 | 10.747 | 299 |

These samples fit a16.67ms/60FPS budget on this machine; they are short, uncapped measurements, not a guarantee for all hardware or every loading spike. Final-night1080p physics average2.576ms/navigation0.0108ms. No measured bottleneck justified a speculative optimization/refactor. MEMORY_STATIC returns0 in release and is unavailable, not actual zero memory. Process private memory sampled across the balanced campaign:69.60MB initially,78.36MB peak/final as additional content loads;32samples over about161seconds. Node/state checks show no accumulated wave references. This is not proof of absence of every leak.

## 18. Export

Normal Windows release export succeeded; MainMenu boot works outside editor. QA builds test the release executable with identical gameplay plus a dedicated test entry. Full ten-day campaign passed headless; rendered UI/combat/ending and real Quit passed, with default audio on final presentation run. No missing scene/texture/import or critical runtime errors in final logs. No clean-machine test, signing or installer is claimed. Keep EXE/PCK together.

## 19. Fixes and balance

Removed developer TargetDummy from normal/release play, gated interaction prints to debug builds, added release version/preset and isolated QA export tooling. Final basic daily seed supply now3/4/4/5/5/6/7/8/8 on Days2-10. Baseline all-eight supply yielded1500ammo with720left after780shots; balanced supply yields1060 with321left after739shots in the final strategy run. Runs have different timing/strategy, so the change in shots is not attributed to supply alone. Growth, recipes, weapons, HP and waves unchanged. Issue history includes failed agent strategies and their corrections.

## 20. Remaining issues

See KNOWN_ISSUES.md: unresolved original asset rights, craft-only medicine/elemental ammo, no save, static rotor and missing authored weapon clips, reused crop/enemy models. No known remaining reproduced blocker/high gameplay bug in covered cases. Human difficulty/enjoyment and real listening mix remain unverified.

## 21. Balance summary

Progressive supplies reduce early surplus while preserving recovery at natural dawn. Perfect-hit campaign demand698rounds versus1060potential farmed rounds. Final campaign used739. Day1 teaching wave and Day10 challenge retained; supply changes were the sole economy tuning category. FINAL_BALANCE.md contains all current tables.

## 22. Debug / cleanup

Normal main scene is MainMenu. OS.is_debug_build gates F1/cheat input; actual release test verifies inactive debug and no target dummy. Test scripts/tools/docs excluded from normal PCK. Development scenes retained in source for regression. Placeholder audit: keep crop/enemy models, static rescue, solid test-station crate as map obstacle; remove dummy from ordinary gameplay and suppress debug labels/interactions. No critical TODO/FIXME/HACK found in production scripts. No massive rename or unrelated deletion.

## 23. Asset audit

Five used GLB models have no license information in project files. ASSET_CREDITS.md records exact paths without invented authors/licenses. Original UI/procedural audio and engine notices documented. Matching Godot MIT and third-party notices included in build. Confirm pack distribution terms before public distribution/submission requiring those rights.

## 24. Readiness / freeze

Automated technical candidate verification completed; build and source packages prepared separately. No new major feature added. **FEATURE FREEZE.** Remaining external/manual checks: asset rights, human listening/playthrough and optional clean-machine confirmation. This report does not label unresolved distribution rights as approved. Stop project work after delivery unless the user requests a change.
