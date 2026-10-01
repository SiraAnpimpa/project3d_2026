## Current: GAMEPLAY & CHARACTER REFINEMENT COMPLETE — STOP FOR USER REVIEW (2026-10-02)

- CURRENT STAGE: A→B/C→D→E→F complete. Root only. Requested runtime checks/documentation/evidence/scope audit completed; no implementation remains in this pass.
- Stamina: max100/restart25%/walk4/sprint7/aim2.8 unchanged; drain22→14/s, recovery18→28/s, delay1.2→0.65s. Identical input measurement: sprint4.5667→7.1667s; first recovery1.2167→0.6667s; empty-to-full including delay6.7667→4.2333s. HUD/partial restart/20s finite sprint/grounded uphill/downhill/live Runner escape pass.
- Animation: actual Matt43bones/20clips; native Idle/Walk/Run and Gun variants retained, native Slash adapted for0.48s bat. Dedicated Sprint/Aim/Shoot/Reload/Strafe/Backward/Bat clips absent. Movement blends0.12/0.14s; bounded speed-correlated Walk2.2/Run~1.17 cadence. Matched full-speed stance-foot drift proxy improves26%/16%; rejected2.16 Run cadence is not used. Residual foot sliding remains.
- Holding/aim: same unit-scale WeaponSocket/local SkeletonModifier3D, torso-relative low-ready/aim transforms in WeaponData; SecondaryGrip aliases rifle SupportGrip. Tucked arms/bounded torso/muzzle convergence/near fallback and actual recoil/reload timers; root remains upright. Final vertical/strafe/backward/immediate-fire/reload/grip captures pass. Matt has no Hand bones; knuckle anchors and21 native gun finger tracks approximate grip; coarse skinning/clipping remain. Basic Rifle is the only usable firearm; Shotgun source-only.
- Bat: existing Wooden Bat Barbed.glb, two-hand scene/item/WeaponData MELEE=4; owned/equipped slot2 fromDay1, rifle defaultslot1; existing wheel/equipment/HUD/audio. Damage10/range1.6m/interval0.85s/contact0.18s/swing0.48s; one short forward shape query/nearest unblocked living target once per press. No ammo/reload/stamina cost. Cooldown survives swapping; switch/menu/mode/removal/death cancel windup. Two short procedural sound placeholders, native Slash/socket sweep and simple SVG icon. Frozen-variant Normal/Runner/Tank kills10/6/30 swings; zero-ammo fallback and rifle magazine/reserve persistence pass.
- Bat new files: scenes/weapons/WoodenBat.tscn,resources/items/wooden_bat.tres,resources/weapons/wooden_bat.tres,assets/ui/items/wooden_bat.svg,assets/audio/bat_swing.wav,assets/audio/bat_hit.wav. WeaponData/Runtime/Controller,PlayerVisual/RiflePose,GameRoot/Player scenes/catalog/HUD/audio extend existing services; Inventory/Equipment core unchanged.
- Plant asset audit complete before visual edits: all68 Nature sources; all remaining source filenames checked for vegetation; broader138 imported/rendered candidates include59 weapon-related (two Battery false positives),nine actors/two accents. No authored crop growth sets. All244 GLBs preserved.
- Plant mapping: Lead→Plant Big;Paper→Clover;Iron→tall alternate Plant Big;Copper→yellow-pod Flower Single;Herb→Fern;Fire→red Bush;Ice→pale Mushroom;Poison→Mushroom Laetiporus. Eight unique source models/static measured wrappers under scenes/farming/visuals. Existing seed/0.35/0.70/1.0 stages/thresholds and future stage_visuals[] preserved; optional show_produce_marker=false removes the generic floating prism. No FarmPlot per-plant hardcoding. Water/Electric absent in actual catalog, no invented content.
- Farming: all8 actual seed selection/E plant/clock growth/E harvest pass headless/rendered;24 grounded bounded stage geometries,one model/no plant collisions,full-inventory atomic crop retention,data-only future stage override.13 actual player-camera images inspected. Economic/stage fields/yields/seed IDs/recipes/unlocks unchanged.
- Night: live pursuit/player damage retained. Three real rifle rounds exhausted; wheel/approach/bat kills Normal and Runner; sprint outruns Runner using42stamina over3s,recovery begins after0.75s;Tank takes10 then player escapes. Headless finalHP30/rendered finalHP5 (capture frames allow extra Tank attacks); controlled fixture is not an ordinary wave or invulnerability.
- Ordinary regression: unchanged cleanup_full_day passes finite starter seeds/natural time/eight real crops/40ammo+medicine craft/six real damaged-combat rifle kills/earned E-bed to healthyDay2; separate damaged no-rest natural dawn passes without healing. No fresh ten-day campaign/human playtest/listening claim.
- Final gates:25 recorded relevant individual process entries (labelled baseline/audit/current/comparison),all expected results/functional diagnostics pass. Final import/normal rendered boot pass. Only pre-existing Windows certificate-store line excluded. Earlier harness faults/repairs and rejected cadence retained in full logs. tests/run_gameplay_refinement.ps1 prepared and syntax checked; individual gates run, no separate combined-wrapper claim.
- Performance: true source day mean15.010→5.243ms/night12 mean16.151→5.790ms, timing variance disclosed. Same-current-code art replay:day5.331→5.322/night12 5.767→5.942ms (+0.175/~3.0%);p99 9.750→9.417/10.964→10.628ms,draws−40,nodes equal,static memory−30,740B.600render frames/scenario,12grown plants,1080p,RTX4060Laptop/Godot4.7 debug; pre-existing background Godot remains. No minimum-hardware/release/sustained certification or speculative optimization.
- Scope:947-file dirty-source baseline. Exactly26 existing production files changed (13scripts,3scenes,10resources);317 other code/scene/resource/test/tool files,all571 original asset files incl244GLBs/21audio,project/export config preserved. Eight PlantData economic/stage records unchanged except source/produce-marker flag. Core inventory/farming/crafting/AI/waves/clock/progression/map/nav untouched. No missing/unexpected file changes; pre-existing dirty work retained. No commit/push/export.
- Docs: GAMEPLAY_REFINEMENT_REPORT.md complete in15 requested topics;PLANT_VISUAL_ASSET_MAPPING.md all68 audit/eight mappings/stages/verification;current README/CONTROLS/FINAL_BALANCE/PROJECT_ARCHITECTURE/KNOWN_ISSUES/asset docs/tests README/guide updated. docs/gameplay_refinement holds source audit/patch/hashes/status,25-gate manifest/all attempts,all138 source renders,8before/31after/13plant captures,16contact sheets,stamina/cadence/geometry/night/allfour profiles.
- Known issues: residual foot drift/coarse hands/occasional clipping; procedural actions/audio and scaled growth stages; fantasy crop analogues; starting damage10 needs human difficulty review; existing static rotor/unsaved campaigns/craft-only consumables; older EXE/PCK. No unresolved latest functional parser/runtime/assertion/navigation error.
- NEXT EXACT TASK: **STOP and await user review of this completed Gameplay & Character Refinement pass.** No new phase. Run current source/F5; Combat Q→wheel Wooden Bat→LMB without RMB/ammo.

## Historical: MAP FINAL CLEANUP COMPLETE — STOP FOR MAP REVIEW (2026-10-01)

- Root only; requested environment finishing complete. D01–D10 were recorded before edits after actual input/player/top/night inspection. All have a completed treatment; no authorized implementation remains.
- Structures: grounded four-post workshop/depot frames, roof-to-beam/wall joins, rafters; intentionally roofless depot bay. Sixteen fence posts/rails connect and contact terrain; two western fragments intersecting rocks removed.
- Cabin: copied muted exterior materials, same 9.5 m furnished model/continuous 0.135 m apron/open widened doorway/rest anchor. Decorative front board and three domestic props removed; compact chest/radio/aid correctly grounded. Yard lamp moved out of door sightline.
- Workbench: four visual legs/shelf/brace/vise/stock, original tabletop/physics/interaction/script/label unchanged. Five unrelated props removed; tools lean against wall with exact vertex-ground alignment; fuel can grounded; three-plus-two firewood stack and measured stock-chest lift. Existing lamp attached to front post.
- Rescue: same anchor/level ground/truck/cache/H/four cones/light/ending. Tiny asphalt, gantry, street lamp, barrier and spare cone removed; landing becomes blended earth clearing. All three decorative boards removed. Detached pipe bundle/four paving modules removed. Eighteen model placements /fourteen preloads removed, no raw asset deleted.
- Terrain: only ground colour edges/wear/path width transitions changed. Heights/trails/collision mesh/vegetation generation byte/function preserved. 56 models /11,707 placements /11,019 grass; 54 MultiMesh batches /377 mesh nodes /1,137 day nodes /178 static bodies /116 trunks /five lights. Nav resource rebaked 3,682 polygons, zero overlapping edges, unchanged actor/nav settings.
- Final tests: matched 99 before/99 after day/night/top/detail images, 27 actual-input walks; final five-walk/24-image workshop refresh after last lean. Geometry eight supports/four bench legs/sixteen posts/rails/forty rocks/three tools/Cabin/rotor passes. All 24 three-variant/four-entry/two-target zombie routes, 120 route cameras, twelve plot E plant/harvest, 22 zone/edge walks, 176 additional cameras, four bounds, rescue visibility/18.267 s road walk and five rendered ending captures pass.
- Night: separate rendered twelve real rifle variant/entry cases and ordinary grounded six-enemy/four-entry wave pass, sixteen frames inspected. Complete headless acceptance passes. Retained combined rendered acceptance and first survey 240-second timeouts; subsequent complete split/scenery runs pass. Initial rail type inference parser error repaired; final editor import/ordinary rendered boot pass. Only pre-existing Windows certificate-store diagnostic excluded.
- Core loop: ordinary finite-resource/natural-time crop/40-ammo/medicine craft/six real damaged-combat kills/earned rest to healthy Day 2 passes; separate damaged natural-dawn/no-rest passes. No new claim for historical broad suites or human/ten-day playtesting.
- Performance: same unmodified RTX4060 Laptop/Godot4.7 debug profile. First after sample contains 720p night p99 18.506 ms; retain it. Confirmation after image work stopped: day 8.100/14.757 ms, night720 8.169/10.997, night1080 8.462/11.632, ending 5.008/6.095 (mean/p99). All confirmation p99 below16.67 ms; background Godot remains, no OS-wide/low-end/release/sustained certification.
- Scope: exactly six existing production files changed (rural_environment.gd, rural_terrain.gd, environment_assets.gd, world_presentation.gd, Workbench.tscn, prototype_navigation.tres). 197 other scripts/scenes/resources, all244 GLBs/all571 asset files, supplied audio, MainWorld/GameRoot/GamePresentation/project/export/bake tool unchanged. Prior unrelated dirty work preserved; no commit/push/export.
- Docs: MAP_FINAL_CLEANUP_REPORT.md completed in all12 requested topics; current MAP_ASSET_USAGE/ASSET_ANALYSIS/ASSET_GAMEPLAY_MAPPING/ENVIRONMENT_ASSET_INVENTORY/PROJECT_ARCHITECTURE/README/KNOWN_ISSUES/tests README updated, historical versions retained. Evidence docs/map_final_cleanup holds images/logs/runtime records/both profiles/scope/hashes/diffs. Portable tests/run_cleanup_tests.ps1 prepared and syntax checked; individual gates were run, combined wrapper was not rerun.
- Remaining minor issues: mixed native low-poly detail colours, existing crop/UI labels/character/weapon/static rotor, distant horizon openings, decorative supplies, short hardware-specific timings. Historical EXE/PCK is older; run current source/F5.
- Next exact action: **STOP and await user map review.** No animation, weapon/aim/skip/UI/gameplay/new phase work authorized.

## Historical: Map Beautification & Spatial Recomposition COMPLETE — STOP FOR MAP REVIEW (2026-10-01)

- Rescue: anchor (29,0.70,43), southeast level clearing at 0.65 m, curved road/low reveal shoulder/checkpoint/aid cache. House separation 67.0 m; real 4 m/s road walk 18.38 simulated seconds. Four representative eyes hide all five landing samples. Existing daylight ending transforms follow the anchor; behavior/timing/UI unchanged.
- Home/farm: supplied Cabin inspected/native 221 meshes, home (-12,-10), static entry widened ~1.85 m, floor/veranda aligned to continuous 0.135 m earth apron. Old primitive shelter disabled. Twelve plots now two 6-plot groups with ≥2.15 m lanes,3.55 m middle lane, low western fence~3.38 m away. Actual E plant/harvest all 12 passes.
- Utility/props: bench (3,-8), independent workshop, rear heavy stock/firewood; root debug stock and retained cover bodies relocated to utility side. Domestic supplies in right cabin room/rest in left. Ten embedded rock clusters with medium/small pieces/understorey; leveled depot/tower/tent/landing foundations. Existing signboards supported by grounded posts.
- Nature: 11,019 tufts vs 100 before, four existing variants, varied authored patches/heights/empty pockets and zone exclusions. 70 model sources/11,725 placed instances / 68 MultiMesh mesh batches / 116 playable trunks. Clustered vegetation and green understorey, broad open work/combat/landing space. Five existing lights retained.
- Navigation: final 3737 polygons, 0.25 m XZ / 0.05 m Y, detail samples 3 cell units; matching map Y/merge precision 0.001. Zero shared-edge topology faults and no final navigation warning. Radius/height/climb/slope and all zombie controllers unchanged. All 24 Normal/Runner/Tank×entry×field/interior routes pass; async test setup now waits for usable paths.
- Tests: current-map metrics/edge audit/routes; 22 zone/entry/edge walks,296 shoulder clearance samples; 12 night variant/entry rifle kills;6-enemy ordinary grounded four-entry wave; ordinary-resource Day 1 natural crop/craft/combat/rest and separate damaged natural-dawn survival; 38 before / 38 after survey images, 5 rescue and 16 night images; final import/normal boot/sequential profile. Latest individual checks pass; no new claim for historical 40/48/52 suites or 10-day human playtest. Intermediate failure/repair logs retained.
- Performance: final 12 alive at 1080p: mean 5.684 ms / p99 9.194 ms, draw calls 804→2250. Day nodes 924→1130, static 66.08→88.88 MB. Added Cabin/grass cost is recorded; all sampled p99 below 16.67 ms on RTX 4060 Laptop / Godot 4.7 debug. A separate Godot process remained; OS-wide isolation was not certified. No low-end/release certification or new export.
- Scope: 195 protected preexisting core/character/weapon/UI/data files and 244 GLBs (243 originals + supplied Cabin), all 24 supplied game_sounds files match snapshot hashes. GameRoot only station transform; GamePresentation exact rescue spatial substitutions; project config only navigation. Ten production files changed: MainWorld, GameRoot, five map/spatial scripts, nav resource, bake tool, project.godot. New focused map tests/audits/runner+reports/evidence. Prior unrelated dirty work preserved; no commit/push.
- Reports/current docs: MAP_BEAUTIFICATION_REPORT.md, MAP_ASSET_USAGE.md, ENVIRONMENT_ASSET_INVENTORY.md, ASSET_ANALYSIS.md, ASSET_GAMEPLAY_MAPPING.md, PROJECT_ARCHITECTURE.md, README.md, KNOWN_ISSUES.md, tests/README.md; evidence docs/map_beautification incl captures/logs/metrics/routes/distance/profile/source/scope/diffs. Historical reports/evidence retained.
- Remaining visual limits: mixed stylized asset colours/bright Cabin surfaces/simple workshop, broad open far horizons, existing crop labels/placeholders/static rotor and prior character issues. Historical Phase10 EXE/PCK still contains an older map; run current source/F5. Only known Windows certificate-store diagnostic excluded; no unresolved current-map functional/parser/runtime/navigation error.
- Next exact action: **STOP and await user map review.** Authorized map implementation/testing/documentation complete. Do not start character/animation/holding/aim/skip/UI or gameplay changes without a new request.

# PROGRESS — Somchai's Last Harvest

## Historical: Major Map / Terrain Redesign COMPLETE — STOP FOR MAP REVIEW (2026-10-01)

- Terrain completed first:112 m playable /240 m visual; sampled heights−1.79..+5.07 m, gentle28.97° maximum sampled /28.74° triangle slope, flat36 m core. Curved dirt paths, north ridge, west hill, raised old field and dry drainage. Before/blockout/after/matched images retained.
- All8 zones complete: Farmstead, House/shelter, Workshop/storage, OpenCombat, Forest, AbandonedDepot, Road/rescue, OuterBoundary/background. Five major landmark groups, authored large/medium/small clusters, varied natural boundaries and distant hills/trees/road. No zone work remaining.
- Assets inspected:243 original GLBs instantiated/rendered;197 broad environment/decor candidates and13 current contact pages. Assets used:69 unique /709 placements /68 MultiMesh nodes; unused preload removed, scale-aware LOD fixed disappearing panels, tower native scene retained. Source243 GLBs unchanged by SHA-256.
- Navigation:final1794 polygons, all24 real Normal/Runner/Tank field+inside-house routes pass; per-route timings in docs/map_redesign/routes.json. Spawn points grounded and screened from representative farm eye in all4 directions. Ordinary Day1 wave uses all4 real entries and grounded spawning. All120 playable trunks physically collide; visual background/foliage has no collision.
- Camera/movement/farming/combat:real input through22 destinations/all4 physical edges,176 shoulder checks plus120 base samples; all12 plot E plant/harvest and12 three-variant/four-entry rifle cases pass. Rendered farm/camera/night checks and ordinary resource/time/damage full-day rest/no-rest pass. Real Lead growth 30.38 s. Automated input/image inspection, not human playtesting.
- Latest checks:48/48 per-check evidence passes (40 headless +8 rendered audit/map/core/capture/profile/boot). Initial headless37/40 repaired: old wall fixture and real post/barrel circulation; original logs retained. Initial steep transition/East visibility/class-import/output-directory capture faults resolved. Only known Windows certificate-store diagnostic excluded; no unresolved functional map assertion/parser/runtime failure in latest checks.
- Performance:same RTX4060 Laptop/Godot4.7 debug profile,12 alive1080p mean4.787 ms/p996.951 ms;draws652→823,day nodes812→924,static memory61.01→66.02 MB. Available-machine short samples; no low-end/release certification or new export.
- Modified map scope:MainWorld, nav resource,3 new world scripts+UIDs, WorldPresentation ownership comment,export dependency list,asset audit and map metrics/acceptance/capture tests,stage1 wall/route telemetry/test runner; requested reports and current docs/evidence. 173 pre-existing core/character/weapon/UI/gameplay/resources match the pre-map snapshot; all earlier refinement work preserved. Root only,no commit/push.
- Reports:MAP_REDESIGN_REPORT.md,MAP_ASSET_USAGE.md,ENVIRONMENT_ASSET_INVENTORY.md. Evidence:docs/map_redesign, including performance/test/route/asset/scope/source hashes and screenshots/logs. Historical Phase10 EXE/PCK still uses the old world; new map runs from current source/F5.
- Next exact task:STOP and await user MAP review. Do not start animation/character/holding/weapon/skip/UI refinement or new gameplay until a new user request. No pending authorized map implementation/test/documentation work.

## Historical Refinement Pass 1

## Current: Post-production Refinement Pass 1 COMPLETE — STOP (2026-10-01)

- **Completed order:** A map → B movement → C holding → D aim → E confirmed Skip to Night → full regression/documentation. No pending implementation or test gate within this pass.
- **Map / scenes / assets:** retain 48 m world, 12 plots, player/bed/rescue and four spawn anchors; bench now (-4.5, -1). MainWorld/FarmDressing adds linked base yard/soil/porch, supplies, fences/rocks/pines and rescue road. Existing lights retained. Reuse seven existing GLB assets; all 243 source GLBs unchanged by SHA-256.
- **Navigation / camera:** final bake 149 polygons. All 24 three-variant entry routes, rear-shelter Tank, player paths to plots/bench/bed/rescue, 120 camera clearance samples and existing camera regressions pass. A horizontal-pallet climb trap was fixed by upright storage and a wider wall-side gap.
- **Animation / skeleton:** actual Matt 43-bone / 20-clip audit. Idle/Walk/Run plus Gun variants selected by mode, speed-linked playback, backward step and short blends. Imported skeleton, rest poses, animations and physics root unchanged.
- **Socket / holding / aim:** RiflePose modifier after animation, unit-scale socket, Basic Rifle scale 0.5, two grips/magazine/muzzle markers. Bounded torso/leg aim, strafe, visual recoil and timer-linked reload dip. Farming hides rifle. Current assets lack dedicated aim/fire/reload/strafe/tool clips; procedural adjustments are documented approximations.
- **UI / input / skip:** new N action and clock-side button always request confirmation. Default Cancel / Escape; local pause and input lock; same-day 18:00 through existing GameClock, elapsed crop growth and one normal night start. No heal/rest/day reward or automatic inventory action. Day 10 warning plus menu/reload/death/ending/stale-state/spam guards pass. No readiness/ammo gate.
- **Tests passed:** latest 52/52 per-check logs after targeted fixture correction; real menu-to-farm/craft/aim/confirmed-skip/combat/rest flow; separate natural-dawn no-rest case; sustained finite-resource 10-day campaign to rescue (723 shots, 337 rounds remaining, Night 10 HP 80); final rendered main boot and profiling. Automated input/screenshot inspection, not human playtesting.
- **Failures resolved:** pallet route, old bench approach fixture, initial modal sizing and headless-only mouse-capture assertion. Initial combined suite was 51/52; corrected headless test rerun and rendered counterpart pass. Original failed log retained. No unresolved functional test failure. Existing Windows certificate-store message is the only excluded engine diagnostic.
- **Performance:** final isolated RTX 4060 Laptop / Godot 4.7 debug sample with 12 enemies at 1080p: mean 2.575 ms, p99 4.544 ms; draw calls 436 → 652 compared with before. Day static memory 58.46 → 61.01 MB. Not a low-end/release or sustained-aim certification.
- **Changed files:** MainWorld, BasicRifle, nav resource, project input/export list; GameRoot, PlayerController/PlayerVisual/WeaponController, WorldPresentation/PresentationStyle; new FarmDressing/RiflePose/SkipNightDialog; focused tests/capture/audit tools, updated old bench/full-day fixtures and test runner; docs listed in the refinement report. Evidence: docs/refinement1/test_results.json, campaign.json, performance.json, asset_audit.json, screenshots/logs/source hashes.
- **Known limits:** some stylized hand/body clipping and foot sliding, no authored reload/strafe clips, decorative storage/tool props, existing craft-only medicine/special ammo, no save, original asset license metadata missing. Historical Phase 10 EXE/PCK has not been rebuilt; current changes run from source in Godot 4.7.
- **Git:** baseline clean at 6a0859c1a161069f2e7b77f8d7522fe042495ff0; no commit/push. Detailed completed report: POST_PRODUCTION_REFINEMENT_1.md.
- **Next exact action:** STOP and wait for a new refinement request. No pending work in the authorized pass.

## Historical Phase 10

## Current: Phase10 automated QA complete / v0.1.0-demo candidate (2026-09-30)

- Balanced release-template legitimate campaign passed all10waves and rescue:739shots,321remaining; Night10 used136shots and took26damage. No grants/godmode/instant growth/direct kills/teleports/day jumps. Actual input, normal clock/economy; automated precise aiming is not human playtesting.
- Only balance change: daily basic seed supplies3/4/4/5/5/6/7/8/8 for Days2-10, replacing8everyday. Other economy/combat/wave values unchanged. Before/after telemetry retained in docs/phase10.
- Release cleanup: TargetDummy removed from normal/release game, debug-only interaction prints, F1/cheats disabled in actual release. Version/export preset created. Baseline had no reproduced blocker/high defect.
- Passed: nine-scenario death/restart matrix; final accelerated progression/unlock/state regression; exported rendered menu/farming/crafting/combat/rest/gameover/ending/restart/real Quit; normal standalone rendered boot. Latest logs have no critical errors. Phase9's42check baseline remains applicable; no claim of a new wholesale43check run.
- Release performance on RTX2060/i5-9300H: final-night12alive1080p mean4.819ms,p99=8.175ms. Campaign process private memory69.60MBinitial/78.36MBpeak; accelerated daytime nodes528everyday. No speculative optimization.
- Candidate: release/SomchaisLastHarvest_v0.1.0_demo (EXE+PCK+docs/notices), matching playable ZIP; separate source archive. QA builds excluded from submission package. Normal entry MainMenu; no editor dependency.
- Documents: FINAL_QA_REPORT, FINAL_BALANCE, CONTROLS, ASSET_CREDITS, KNOWN_ISSUES, RELEASE_CHECKLIST, issue register; source architecture/plan/README updated. tools/export_qa.py reproduces isolated release-template QA entry; tests excluded from normal export.
- External/manual checks: original five GLB pack licenses missing, real listening mix/human difficulty and clean-machine test not certified. Desktop automation unavailable due missing native pipe; exported programmatic UI checks passed.
- **FEATURE FREEZE.** Deliver commit/push and local artifacts, then STOP. Do not add features or continue balance without a new user request.

## Historical Phase9 delivery

## Current: Phase 9 complete, runtime verified (2026-09-30)

- MainMenu is the project entry; Play hides debug tools, How To Play explains controls and the loop. Pause supports guide, restart and return to menu.
- Final-day warning and final-night HUD/sky/ambience lead into guarded Day11 rescue: morning, fade, existing helicopter arrival, dedicated camera and ending buttons. Damage/input/waves stop; restarting creates a fresh campaign.
- Shared UI theme, all six recipes visible, nine elemental item icons, first-day guide, damage flash, rest fade, clearer lighting, zone signs, boundary decoration and three limited non-shadow lights. Camera distances/FOV and animation blends tuned; core economy/combat unchanged.
- Original generated SFX and ambience, reproducible generator; no external audio or music. Existing helicopter has a static rotor. Asset pack distribution licenses remain unverified.
- Latest 42/42 per-check logs pass after fixes and targeted reruns, including rendered UI, full-day survival and ending/restart/menu routes. See PHASE_9_TEST_REPORT.md and docs/phase9/test_results.json.
- Added MainMenu, GamePresentation, GameAudio, WorldPresentation, PresentationStyle, procedural audio generator and Phase9 integration test. Existing root/HUD/pause/camera/health/weapon/environment integration updated.
- Remaining: placeholder crop/enemy art, no dedicated aim/reload clips, craft-only medicine/elemental ammo, no save, target-hardware profiling and license verification. No export or full final balance performed.
- Next action: STOP and wait for Phase 10 - Final Balance, QA, Performance & Export.

## Historical Phase 8

## Current: Phase 8 complete, runtime verified (2026-09-30)

- Data-driven ten-day campaign, interleaved wave composition, Runner/Tank sharing original AI, living cap12 and exact-variant pending replacement. Day1 retains6Normal; final Day10 is14Normal+7Runner+3Tank,1.1s cadence.
- New central DayConfig/DayProgressionData/ProgressionManager; unlocked IDs are separate from owned quantities and grant receipts. New seeds3 once; five basic seeds8 each on Days2-10. Full-bag rewards remain pending and retry atomically without duplication. Debug reset retains grant receipts.
- Fire Pepper Day3/tier2, Ice Plant Day5/tier3, Poison Plant Day7/tier3;54game-minute growth/yield2, three corresponding materials/ammo items/recipes. Catalog23items/eightplants; six recipes. Special ammo is craft-only, unusable in Basic Rifle; descriptions disclose this. Water/Electric/new weapons omitted optional scope.
- HUD DayX/10, actual-data threat preview, unlock/Runner/Tank/FinalDay messages, pending rewards, compact debug dropdown. Night10 clear permits rest; natural/rest dawn triggers GAME_COMPLETED, stops clock/cleanup/gameplay, restart returns fresh Day1. No normal Day11 loop, cinematic or rescue scene.
- Baseline Phase7 full-day and lifecycle passed before edits. Focused progression and variants pass headless/rendered; 10-day accelerated clock (3s half-days, no seeks/kills/heals) produced exact ten dawns, daytime node count422 on every day, no tracked/pending remnants, persistent farm/magazine/inventory. Mixed real Rifle kills2Normal+Runner+Tank in28hits. Tests heal during sustained mixed observation, not in production.
- Regression initial batch had4 failures: debug restore guard and old catalog/farming/recipe fixture assumptions. Fixed guard and fixtures, targeted reruns passed. Latest40/40checks pass (import+27headless+boot+11rendered), with final focused rendered Phase8 rerun after terminal HUD cleanup. No remaining runtime/assertion errors. Inspected images and per-check summary are in docs/phase8. Full report `PHASE_8_TEST_REPORT.md` contains the complete day/unlock/composition table and honest test limitations.
- New scripts: scripts/data/{day_config,day_progression_data,wave_entry}.gd; scripts/progression/progression_manager.gd; tests/phase_8_{progression,variants}_test.gd (with .uid files).
- New resources: resources/progression/{ten_days,day_1..day_10}.tres; resources/waves/day_2..day_10.tres; resources/enemies/{runner_zombie,tank_zombie}.tres; scenes/enemies/{RunnerZombie,TankZombie}.tscn; resources/plants/{fire_pepper,ice_plant,poison_plant}.tres; resources/items/{seed_fire_pepper,seed_ice_plant,seed_poison_plant,fire_essence,ice_crystal,poison_extract,fire_ammo,ice_ammo,poison_ammo}.tres; resources/recipes/{fire_ammo,ice_ammo,poison_ammo}.tres.
- Modified: catalog/recipebook/day1wave; NightWaveData/ZombieData; shared zombie tint and spawn clearance; Inventory/CraftingSystem/CraftingUI; GameRoot, NightWaveManager, HUD/debug/bag; old fixtures for intentional new content, test runner; project docs. Original GLBs unchanged, no AI copies.
- Limits: placeholder enemy scale/tint and crop visuals/icons; temporary counts/timings/economy; elemental ammo effects and medicine use deferred; static nav/no crowd avoidance/save; no manual three-hour campaign, export or target-hardware FPS benchmark. Long-run state test had peak3tracked due short nights; separate cap fixture verifies12active+12pending, mixed combat verifies4live attackers.
- Next exact action: wait for Phase9 - Final Night Ending, Rescue, UI/UX & Game Polish. Phase8 delivery includes commit/push; no Phase9 work started.

### Current day / unlock table

| Day | Normal / Runner / Tank | Spawn seconds | New seed + recipe |
|---|---|---|---|
| 1 | 6 / 0 / 0 | 2.0 | Five basic seeds; Basic Ammo, Medicine, Metal Component |
| 2 | 7 / 0 / 0 | 1.9 | Daily basic supplies begin |
| 3 | 7 / 2 / 0 | 1.8 | Fire Pepper + Fire Ammo |
| 4 | 8 / 3 / 0 | 1.7 | - |
| 5 | 9 / 4 / 0 | 1.6 | Ice Plant + Ice Ammo |
| 6 | 10 / 5 / 0 | 1.5 | - |
| 7 | 10 / 4 / 1 | 1.4 | Poison Plant + Poison Ammo |
| 8 | 11 / 5 / 2 | 1.3 | - |
| 9 | 12 / 6 / 2 | 1.2 | - |
| 10 | 14 / 7 / 3 | 1.1 | Final night; completion at dawn |

## Historical Phase 7

## Phase 7 complete, runtime verified (2026-09-30)

- NightWaveData and NightWaveManager add clock-driven DAY/ACTIVE/CLEARED/RESTING/GAME_OVER lifecycle; six Normal Zombies, 2s cadence, 12m minimum distance, four cardinal markers. Tracks alive/pending/corpses via signals; clear only after all spawned and none alive.
- ZombieSpawnFactory shares navigation/capsule checks with debug spawner. Wave pursuit overrides local detection without rewriting AI. Administrative despawn cancels attacks without kill credit.
- Bed/RestSystem: physical E after clear, pause and aim/weapon lock, full existing stats, clock skip to06:00 with one day increment and timestamp plant growth. Natural dawn safely removes unfinished wave without healing. Game over stops spawn/clock; R resets scene.
- Added night HUD, feedback and gated17:50/start-night/kill-active/05:50/dawn buttons. World marker visuals follow debug visibility. Navigation rebaked with bed,63polygons.
- New: scripts/data/night_wave_data.gd, scripts/survival/{night_wave_manager,rest_system,bed}.gd, scripts/enemies/zombie_spawn_factory.gd, resources/waves/day_1.tres, scenes/interactables/Bed.tscn; tests/phase_7_{lifecycle,full_day}_test.gd; PHASE_7_TEST_REPORT.md.
- Modified: GameRoot/MainWorld/HUD scenes, dependency wiring, HUD/debug UI, NormalZombie and test spawner, navigation resource, test runner. Clock/weapon/farming/crafting/player movement core unchanged.
- Passed focused lifecycle headless/rendered and full Day1 simulation without debug grants/heals/clock skips/teleports. Farm8crops -> craft40ammo+medicine -> natural night ->30shots kill6 -> rest: HP90 to100, Day2. Badnight naturally reaches Day2 HP70/stamina81.67 with safe cleanup. Old25headless regression passed.
- Latest verification36/36checks passed: import +25headless +boot +9rendered. Initial combined batch failed2renderedcamera checks; unchanged targeted reruns passed both, cause not isolated. Logs .godot/test-logs/phase7_final/; inspected screenshots and per-check results in docs/phase7/. No outstanding functional failure.
- Next exact step: wait for Phase8 prompt (Day1-10 progression, Runner/Tank, seed/recipe unlocks). No Phase8 work started.
- Limits: temporary balance, static nav/placeholder bed, no offscreen filter/audio/sleep animation/medicine consumption. Full-day simulation is automated fixed-delta runtime, not manual wall-time playtest.

## Historical Phase 6

## Phase 6 complete, runtime verified (2026-09-29)

- Implemented ZombieData, NormalZombie scene/controller and debug test spawner. IDLE / CHASE / ATTACK / DEAD, 12m detection, navigation every0.3s, 2m/s walk, 10 damage with0.3s windup/1.2s interval, shared Health and1.2s delayed death.
- Added baked prototype NavigationRegion (59 polygons) and reproducible tools/bake_prototype_navigation.gd. Static World geometry and TestInteractable included. Enemy layer8; player mask9, aim/weapon masks13; old layer4 remains Interactable.
- Actual Zombie.glb inspected: Idle, Walk, Punch, Death integrated; hit flash without stun. Original assets unchanged. No wave/night spawn or enemy variants.
- Added tests/phase_6_zombie_test.gd. Focused headless checks pass including obstacle/shelter routing, close gun hits, live reload, 3/5 agents and rifle kills, player death and cancellation. Full suite 33/33 passed (import +23 headless +boot +8 rendered); logs .godot/test-logs/phase6_final/. Focused test expanded with actual sprint and debug UI click, then headless/rendered rerun passed. Natural Lead growth 30.409s.
- Created scripts/data/zombie_data.gd, scripts/enemies/{normal_zombie,zombie_test_spawner}.gd, scenes/enemies/NormalZombie.tscn, resources/enemies/normal_zombie.tres, resources/navigation/prototype_navigation.tres, bake tool and PHASE_6_TEST_REPORT.md.
- Modified Player/MainWorld scene settings, GameRoot wiring, debug controls/bag spawn buttons, layer names, test runner. Core weapon/player/health/farming scripts not rewritten.
- Limits: static nav requires rebake after geometry changes, capsule-only hits, timer melee timing, no crowd avoidance/audio/headshots. Pack fixture heals the player for prolonged observation; player death is tested separately.
- Next exact step: wait for Phase 7 - Night Wave & Survival Loop prompt. No wave system started. Evidence and limits: PHASE_6_TEST_REPORT.md; inspected captures: docs/phase6/.

## Historical Phase 5

## Phase 5 complete, runtime verified (2026-09-29)

- Data-driven WeaponData, separate WeaponRuntime, WeaponController and starter Basic Rifle equipped in slot 1. Existing three configurable slots retain magazines per owned weapon ID.
- Combat + RMB + LMB hitscan from muzzle toward camera aim point, cover and barrel penetration checks. R reload consumes crafted Basic Ammo from Inventory on completion. Initial magazine/reserve are zero.
- Target Dummy at (3, 0, -8), existing HealthComponent, 100 HP, damage flash and death. Rifle: damage20, 5shots/s, mag10, reload1.5s, range60m. Temporary balance.
- HUD name/slot/mag/reserve/reloading, hit marker and muzzle flash. Debug-gated +30 ammo. Menus, mode changes, switching and death cancel reload without consuming ammo.
- Created: scripts/data/weapon_data.gd, scripts/weapons/{weapon_runtime,weapon_controller}.gd, scripts/combat/target_dummy.gd; scenes/weapons/BasicRifle.tscn, scenes/combat/TargetDummy.tscn; resources/items/basic_rifle.tres, resources/weapons/basic_rifle.tres; tests/phase_5_weapon_test.gd; PHASE_5_TEST_REPORT.md; docs/phase5/ captures.
- Modified: input map, catalog, GameRoot/Player/MainWorld/HUD scenes, root wiring, HUD/crosshair/debug UI, runner and startup/catalog expectation tests, project documentation. Camera, PlayerController and Inventory core scripts unchanged.
- Final suite: 31/31 runs passed (import, 22 headless, boot, 7 rendered). Full farming/craft/reload/aim/fire/death loop, obstruction, partial reload, spam, state retention, 30/120Hz rates and regressions pass. Logs .godot/test-logs/phase5_final/. Natural rendered Lead growth: 30.384 seconds.
- No functional bugs reproduced. Debt: idle/walk arms without dedicated aim/reload animation or IK, placeholder icon/dummy/flash, no audio/save/duplicate individual weapon instances. No human long-session/export/performance test.
- Next exact step: wait for Phase 6 - Zombie AI & Basic Enemy Combat prompt. Do not start AI. See PHASE_5_TEST_REPORT.md for architecture, evidence and limitations.

## Historical Phase 4 status

อัปเดต 2026-09-29 — **Phase 4 Crafting & Workbench เสร็จและ runtime verified**

## Current Phase 4 status

- RecipeEntry/CraftRecipe/RecipeBook Resources, category, outputหลายชนิด, `craft_amount`, `unlock_day` และ validation/duplicate ID พร้อมใช้งาน. สูตร Day 1: Basic Ammo (Lead1+Paper1+Copper1→10), Basic Medicine (Small Herb2→1), Metal Component (Iron2+Copper1→1). **TEMPORARY BALANCE**.
- ItemCatalog เพิ่ม crafted ItemData3รายการ; Basic Ammo typeAMMO, Medicine typeCONSUMABLE, Metal Component typeMATERIAL. ใช้ icon เดิมเป็น placeholder. ไม่มี shooting/reload/medicine usage.
- Inventory เพิ่ม `can_exchange_items`/`exchange_items` ที่จำลอง stack หลัง consume และก่อน add; commitครั้งเดียวพร้อม `inventory_changed`. CraftingSystem ตรวจสูตร/วัน/ของ/พื้นที่ใหม่ทุกครั้งและกัน reentrant craft.
- Workbench reusable scene แทน placeholder ใน MainWorld ใกล้ farm; ใช้ PlayerInteractor และ E เดิม. CraftingUI สร้าง recipe list จาก data, แสดงจำนวน/เหตุผล/ผล craft, pauseเวลา, release mouse, cancel aim, Escปิดก่อนPause, ไม่ซ้อน TabBag; กลับ mode เดิม.
- Files created: `scripts/data/{recipe_entry,craft_recipe,recipe_book}.gd`, `scripts/crafting/{crafting_system,workbench}.gd`, `scripts/ui/crafting_ui.gd`, `scenes/interactables/Workbench.tscn`, `scenes/ui/CraftingUI.tscn`, `resources/items/{basic_ammo,basic_medicine,metal_component}.tres`, `resources/recipes/{basic_ammo,basic_medicine,metal_component,book}.tres`, `tests/phase_4_crafting_test.gd`, `PHASE_4_TEST_REPORT.md`, `docs/phase4/` captures.
- Files modified: Inventory, ItemData, catalog, GameRoot/MainWorld, InventoryUI/PauseMenu, test runner, Phase 3 catalog-count tests, PROGRESS/PROJECT_ARCHITECTURE/DEVELOPMENT_PLAN/tests README.
- Tests: final 29-run suite exit0/failures0 (import, 21 headless scripts, boot, 6 rendered); Phase 4 end-to-end E plant/harvest/workbench/craft, full bag, stack reuse, reentry/spam, data-only two-output recipe, Day 2 lock, duplicate/invalid recipe all pass. Rendered Phase 3 growth 30.382s at x1. Details in `PHASE_4_TEST_REPORT.md`.
- Known issues: no failures reproduced in automated runs; human playthrough/export not performed. Technical debt: placeholder art/balance, no save, medicine use and weapon behavior deferred.
- **Next exact step:** stop Phase 4 here. Await a separate Phase 5 request for Weapon & Shooting Foundation; do not start gun behavior from this task.

## Previous input/selection milestone (historical)

อัปเดต 2026-09-29 — **Input / Inventory Access / Item Selection เสร็จแล้ว**

## Current status

Godot4.7 / Compatibility; F5เปิดGameRoot. เริ่มFARMING, dynamicseedselectionและequipment3slotsแยกกัน; QสลับCOMBATเพื่อAim. Final **27/27runs exit0, failures=0** รวมrenderer. หยุดรอpromptถัดไป; ไม่มีGunShooting/ammo/reload/weapon damage. ไม่ได้commit/push.

## งานที่เสร็จ

- อ่านCamera progressและตรวจinput/UI/inventory/farm. Backup `work/input_backup/`; baseline20headlessrunsผ่านก่อนแก้.
- เปลี่ยนtoggle_inventory binding I→Tab; Qเป็นswitch_mode; VแทนQสำหรับswitch_shoulder; Escเป็นpause; wheelup/downเป็นcycle_item_previous/next. ไม่มีactionซ้ำ.
- GameplayModeControllerใหม่ defaultFARMING รับwheelกลางที่เดียว. Modeแต่ละตัวจำseed/weaponของตัวเอง. ไม่มีresetcamera/stats/position/inventoryเมื่อเปลี่ยนmode.
- Dynamicseedlistอยู่ในInventoryเดิม: SEED+plantable+quantity>0, uniqueIDรวมstacks, tier/display_order/IDsorting. เมล็ดหมดเลือกsuccessorและwrap; empty/reacquireปลอดภัย. ไม่มีfixedhotbar; ทดสอบ33seeds.
- ItemDataเพิ่มplantable(defaultfalse), tier1, display_order0. Seed5ชนิดเดิมexplicitplantabletrue/tier1/orders10..50. Testplantfixturetier2; พืชfantasyยังเป็นconceptและยังไม่มีunlocklogic.
- EquipmentLoadoutใหม่ default3slots/configurable, ownedWEAPONreference, equip/unequip/get/cycle APIs, selected_weapon_slot. Skipempty/unequipped, inventoryไม่ถูกconsume, pruneเมื่อownershipหาย/clear/shrink. ทดลอง5→2slotsผ่าน.
- InventoryUIเพิ่มownedweaponselectionและequip/unequipbuttons. Productionเริ่มด้วยemptyweaponslots; อาวุธ5ชนิดในtestเป็นtemporaryItemDataเท่านั้น.
- HUDแสดงmode/seedquantitytierหรือweapon/slot/emptystates. RMBและshootingcrosshairเฉพาะCOMBAT; กลับFarmingcancelAim. Camera mouse look/sprint/staminaเดิมยังทำงาน.
- FarmPlotเพิ่มmode/type/plantableguards; plant/harvestเฉพาะFarmingและผ่านEจริง. Growth/atomictransactions/HP/clockเดิมไม่rewrite.
- PauseMenuใหม่: EscPause/Resume, release/capturecursor. BagกับPauseไม่ซ้อน; pausedblocksQ/wheel/camera/aim/clock. Keyechoไม่toggleซ้ำ.

## Files / architecture

ใหม่3scripts: `scripts/inventory/equipment_loadout.gd`, `scripts/player/gameplay_mode_controller.gd`, `scripts/ui/pause_menu.gd`.

แก้8scripts: `item_data.gd`, `inventory.gd`, `farm_plot.gd`, `game_root.gd`, `camera_rig.gd`, `aim_crosshair.gd`, `inventory_ui.gd`, `prototype_hud.gd`.

เพิ่มPauseMenu.tscn; แก้Player/GameRoot/HUD/InventoryUI scenesและproject.godot. Productionรวม26scripts/10scenes/17Resources. Seed5resourcesเพิ่มmetadata; fixtureseed_testtier2. เพิ่ม2testsและปรับ7testsเดิมเฉพาะcontractใหม่; runnerรวม27runs. Docsรายงานใหม่PHASE_INPUT_SELECTION_TEST_REPORTพร้อม7screenshotsในdocs/input; updateREADME/architecture/roadmap/testsREADMEและhistoricalCamerareportnotice.

Playerchildren: Visual / CameraPivot→Pitch→ShoulderOffset→CameraBoom→Camera3D / AimRay / Interactor / Health / Stamina / Inventory / EquipmentLoadout / GameplayMode. Rootwireinventory→equipment→mode→camera; mode_changed→HUD/interactor. InventoryUIและPauseMenuส่งopened_changed→camera. ไม่ย้ายselectionlogicไปPlayerController.

## Controls / settings

WASDmovement, ShiftSprint, Einteract, TabBag, QFarming↔Combat, Wheelcurrentmodeitem, RMBCombatAim, VShoulder, EscPause/closebag, Rrestartเฉพาะdead. LMBยังไม่ยิง. DebugF1–F12ตามเดิม.

Demoequipment3slots; inventory24slots; selectorไม่มีlimitเพิ่มเติม. Tier>=1/order>=0. SlotAPIindex0..N−1/HUD1..N/none−1. Seedselectorเก็บstableID; equipmentเก็บItemDatareferencesที่owned.

Cameraเดิม: normal4.2m/FOV70/offset0.70; aim2.6m/FOV55/offset0.85; height1.65, sensitivity0.003, pitch−65..+45; aimrange100m. Modeเปลี่ยนpermissions/aimstate ไม่resettuning.

## Verification

- Final27runs: import1 +20headlesstests+mainboot1+5rendered. Logs `.godot/test-logs/input/`; workspaceต้นฉบับ `work/input_final_logs/`; manifest `work/input_final_manifest.json`.
- Data/selector/equipment29checks; input/modes39headlessและ47renderedchecks(รวม7screenshots/actualcapture). ทุกข้อผ่าน.
- Phase2/3/Camera regressionผ่านครบ รวมcollision/ray/strafe/movement/HP/stamina/night/growth/capacity/reentrancy/restart. Leadgrowth×1จริง30.297sและharvestLead×2.
- ตรวจภาพFarming/Combat/bagequipment/harvest/Pause/emptyloadout/emptyseedsและdebugbag. Automatedinput+rendererinspection;ไม่อ้างhumanplaytest.
- OriginalGLB243hashesunchanged. PlayerController/Visual/stats/clock/daynight/plantvisual/plantdataไม่เปลี่ยน. ไม่มีtestค้างหรือfail.

## Known issues / limitations

- Engineenvironmentยังมี `ERROR: Failed to read the root certificate store.` เดิม. ไม่มีScriptErrorใหม่; runnerยกเว้นเฉพาะข้อความนี้และเก็บlogเต็ม.
- Testpauseเคยถูกsyntheticwheelที่ไม่มีreleaseจับGUIfocusไว้; แก้harnessให้ส่ง2edgesแล้วclickResume/unequipผ่าน. ไม่แก้productionbehaviorเพื่อกลบtest.
- ไม่มีproductionweaponitems/weaponvisual/individualweaponinstances/save. EquipmentItemDataหนึ่งIDลงได้ช่องเดียว; weaponinstance/ammo/durabilityรอphaseอนาคต.
- Tier/orderเป็นdata ไม่ใช่unlocklogic; Resourcedefinitionsควรimmutableระหว่างruntime. Selectorquantityrefreshผ่านinventorysignals.
- AimstrafeWalkplaceholder/nearclipเมื่อชิดwall/nightgreyboxยังเป็นข้อจำกัดเดิม. ยังไม่ได้humanlongsession/export/mobile/performancebenchmark.

## Next exact step

**Historical note:** input milestone เสร็จก่อน Phase 4. สถานะและ next exact step ปัจจุบันอยู่ด้านบน. Weaponphaseพร้อมใช้current_mode, selected_equippedweapon/equipment_changed และaimray/targetจากCamera. ต้องรอคำขอเพื่อออกแบบWeaponData/instances/model/firing/muzzleblock/ammo/reload/damage.

Suggested commit: `feat: add farming combat modes and dynamic item selection` (ยังไม่ได้commit).
