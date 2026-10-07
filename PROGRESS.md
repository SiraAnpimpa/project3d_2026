# Camera Control + Skip Action Clarity Pass

## Camera Fix

- Root cause reproduced before changes in Godot 4.7.1, headless and rendered: `ThirdPersonCamera.can_control()` expresses gameplay intent but mouse-look never checks actual mouse capture. A visible-cursor motion of 100 px changed yaw by -0.3 rad. A queued 700 px motion immediately after menu recapture changed yaw by -2.1 rad.
- Baseline idle over 1,800 physics ticks (30 simulated seconds) had zero yaw/pitch drift. Rotation search confirmed CameraPivot owns orbit, character rotates Visual only, camera boom uses shape sweeps rather than SpringArm3D, and camera actions contain keyboard arrows only (no gamepad axis).
- Fix applied: actual captured-pointer gate for mouse motion, discard/flush buffered motion in each recapture frame, and use that same path after focus/pause restoration. Existing camera authority, character visual rotation, keyboard orbit, collision sweeps, aim framing, and weapon recoil remain in place.
- Files: `scripts/player/camera_rig.gd`, `scripts/player/camera_preferences.gd`, camera runtime fixtures.
- Verified: rendered mouse/control tests and UI transitions; 30 simulated seconds each in Farming, Combat, released RMB, Day, Night, near cabin and near workbench; no yaw/pitch drift or movement feedback. Mouse displacement gives equal turns at 30/120 physics Hz.

## Camera Sensitivity

- Range: 0.2–2.0x; default: 1.0x; slider step: 0.1; display: multiplier.
- Reuse `UiSettingsPanel` in Main Menu and Pause. `CameraPreferences` persists one multiplier in `user://settings.cfg`, section `camera`, key `camera_sensitivity`; no autoload or second settings screen.
- Mouse look reads `base mouse_sensitivity × user multiplier` on each motion event. No aim-only sensitivity existed; the original normal/aim ratio is preserved.
- Verified low/default/high mouse displacement in rendered normal/aim play, immediate shared slider updates, and 1.7x reloaded by a separate Godot process. Other presentation preferences retain session behavior.
- First-open Settings layout regression fixed: short explicit footer lines avoid hidden-panel autowrap minimum-height inflation. Actual-click Main Menu/Pause capture checks and 720p/1080p images now fit; keyboard slider input also updates the preference.

## Skip Actions

- Cabin E retains existing cleared-wave rest, healing, and dawn rules. Clarify its prompt to `Skip Night`.
- N currently waits until night. User explicitly instructed following the prompt after this mismatch was explained: change N to `Skip to Day` using existing GameClock dawn transition after the wave is cleared. Preserve cabin healing as cabin-only.
- Reused/adapted the existing confirmation as `SkipDayDialog`. HUD N hint uses the same rounded keycap as E beside the clock, visible in either mode only when usable. No second skip system.
- Conditions: living player, night cleared, no paused/other modal, no reload/rest/ending, current campaign day. Confirmation rechecks current day and clear condition. N calls existing `GameClock.skip_to_day()` without healing; E still invokes `RestSystem` with healing.
- Updated Main/Pause How to Play, README and CONTROLS. Rendered cabin/confirmation captures show short distinct prompts, blocked zombie counts, and 720p/1080p dialog fit.

## Regression Results

- Godot 4.7.1 on Windows; headless and real rendered windows. Current runs pass: camera clarity/controls/rate/collision, seven idle contexts, aim, Settings, UI polish, N skip, cabin E, lifecycle, progression across ten days, persistence across two processes, boot, and both updated UI capture fixtures.
- Full natural gameplay fixture enters through Main Menu, walks the current navigation map, plants/harvests, crafts 40 ammo and medicine, loads/fires the rifle to clear six zombies, rests at cabin to reach healthy Day 2, then separately survives a no-rest night to natural dawn without HP restoration. Result: `CLEANUP_FULL_DAY_RESULT failures=0`, approximately 72 seconds wall time at fixed 60 fps simulation.
- Older lifecycle/progression fixtures used previous HUD names and former bed/plot coordinates. Those fixture references and asynchronous navigation readiness were corrected to the current project; final results: `PHASE_7_LIFECYCLE_RESULT failures=0`, `PHASE_8_PROGRESSION_RESULT failures=0`. No game tuning was changed for fixtures.
- Rendered captures checked at 720p/1080p, and survival HUD layout checks cover 1024×768 and 1920×810 as well. Capture results: `SURVIVAL_UI_CAPTURE_RESULT failures=0`, `UI_POLISH_CAPTURE_RESULT failures=0`.

## Remaining Issues

- No blocking issue found in this pass's automated runtime and rendered checks. These are automated gameplay checks, not a human playthrough or a physical controller test. Existing camera bindings are mouse/keyboard only; no right-stick drift path exists in this project.
- Godot emits a Windows certificate-store warning in this environment; game tests do not require networking. Test user data is isolated under workspace `work/godot-data`.

## Next Exact Action

STOP — Camera Control + Skip Action Clarity Pass is complete. Changes are in the cloned project; review patch, progress copy, screenshots and final logs are packaged under the workspace outputs folder. Do not repeat completed work on `continue` without a new issue or request.

# Special Ammo Selection & Weapon Compatibility Fix

## Special Ammo Fix

- Root cause reproduced before product edits: the real workbench crafts ten Fire Ammo into Inventory, but `WeaponController.reserve_ammo()`, reload transfer and impact selection all use `WeaponData.ammo_type` (Basic Ammo). `WeaponRuntime` only stores a magazine count. The Fire item and recipe descriptions explicitly said the Basic Rifle could not use it yet.
- Existing architecture: four AMMO `ItemData` resources (Basic, Fire, Ice, Poison), catalog-backed recipes, atomic Inventory transfers, `WeaponData`, the controller's per-weapon `WeaponRuntime` dictionary, existing Health and elemental impact scenes. No separate AmmoData or existing gameplay status-effect owner was found. Electric/Water ammo and additional player firearms do not exist in the current catalog.
- Compatibility implementation: extend `WeaponData` with `compatible_ammo_types`. Its existing default `ammo_type` remains the default/fallback and older definitions with an empty compatibility list remain default-only. Basic Rifle declares the four real ammo resources. Validation checks AMMO items, catalog identity and duplicates; melee rejects all ammo. No weapon-name condition chain.
- Ammo selection input: `cycle_ammo` on C in Combat, independent of mouse-wheel weapon selection. Cycle only compatible reserve/loaded rounds, including the case where Fire is the only owned ammo and no Basic rounds exist. One-time contextual hint uses the existing HUD; existing feedback toast fades normally. Actions remain blocked by reload, UI, pause, farming and death.
- Magazine ammo state: `selected_ammo_type`, `magazine_ammo_type` and a timed `reload_ammo_type` snapshot live on each runtime, never shared WeaponData/ItemData. Ranged runtimes start empty with their default ammo. Switching rifle/bat/rifle retains both selection and loaded rounds; separate data-only test firearm proves independent state.
- Reload integration: C selects and starts the existing timed reload. On a type swap, atomically return all unused loaded rounds and deduct the selected reserve; one magazine has one ammo type. Same-type reload tops up missing rounds. Check inventory space at start and commit, and preserve loaded rounds if commit fails. Pause, bag, mode, weapon and death cancellation clear the reload snapshot without inventory transfer. Pending selection remains explicit as NEXT on HUD and R can resume it.
- Empty behavior: keep loaded special rounds when reserve is zero. After magazine and selected special reserve are empty, R falls back to the existing default only if default reserve exists, with `Switched to Basic Ammo` feedback. Otherwise report `Out of <ammo>`. C can also select a sole remaining available ammo type; no silent switch or free rounds.
- Shooting integration: shot damage remains WeaponData's original direct damage (20 for Basic Rifle). Shot reads the loaded magazine ItemData for its existing impact scene and applies the data-defined effect through NormalZombie; no status calculation in the weapon script. Existing hit marker, safety/muzzle ray, fire rate and recoil are preserved.
- Status integration: because no prior gameplay statuses existed, add bounded per-zombie timers in the existing NormalZombie physics tick and call existing Health for DOT. Fire burns at 3 HP/s for 3 s; Ice multiplies actual chase speed by 0.5 for 3 s; Poison deals 4 HP/s for 4 s. Same-kind hits refresh without stacking strength; different statuses coexist. Tree pause freezes timers, expiry restores speed, and death/despawn clears effects and overlays. Reuse existing material feedback with per-zombie colored overlays and all existing elemental impact scenes.
- HUD changes: show the actual loaded ammo item icon/name and loaded/reserve count; show reload target or NEXT when selected differs. Melee hides ammo type/count/selector; default-only guns do not show a selector hint. Existing workbench/bag use short data-derived effect summaries and C/R controls. No new icons, popup, crafting core, inventory, weapon framework or save feature.
- Tests completed: `special_ammo_test` passes headless and rendered, real Main Menu Play → E workbench → craft → C → timed R/swap → actual muzzle hitscan on a zombie. `special_ammo_edge_test` passes capacity/commit changes, refunds, no-Basic Fire, full-bag slot reuse, disappearing reserve, partial reload, cancellation/death, per-weapon/shared-resource safety, status coexistence and 30/120 Hz DOT totals. Rendered captures cover all four loaded ammo types, three special-ammo workbench recipes, timed swap at 720p and HUD at 1080p.

Fire Ammo Test: PASS

Ice Ammo Test: PASS

Poison Ammo Test: PASS

Electric Ammo Test: N/A — absent from this project's catalog, recipes and assets; not invented.

## Special Ammo Regression Results

- Godot 4.7.1 on Windows. Final script import succeeds with no script/parser errors. Focused ammo tests, existing elemental impacts (Normal/Runner/Tank), crafting, UI refinement/polish, camera controls and E/N skip checks pass. The full natural farming/crafting/Normal rifle/night/rest/no-rest dawn fixture also passes.
- Four old Phase 4 crafting assertions referred to old text embedded in buttons/prompts. Updated only those fixture assertions to current keycaps, item tooltips, bag-full copy and locked-day tooltips; all crafting/inventory atomicity checks pass without changing CraftingSystem.
- Visual inspection identified overly long ammo help text expanding the workbench beyond 720p. Replaced it with a two-line C/R and data-defined effect summary; runtime bounds checks and final rendered images now fit.
- Fixtures supply recipe ingredients and advance existing unlock data for special-ammo setup, then exercise real UI/input/reload/rays/status owners. They are automated runtime checks, not a human playthrough. No campaign/save design or existing Normal/melee balance was changed.

## Special Ammo Known Issues

- The old `input_modes_integration_test` has 12 failed assertions in headless mode both on the exact pre-Prompt-2 tree and after this pass. Failure descriptions compare identically (0 changed). It includes obsolete HUD/equipment/map expectations and assumes mouse capture in headless mode. Left that unrelated legacy fixture unchanged; current camera/UI/weapon and full gameplay checks pass.
- Godot's Windows certificate-store warning remains environmental. Test user data stays isolated under workspace `work/godot-data`. No blocking special-ammo issue remains in the focused runtime/rendered acceptance checks.

## Next Exact Action — Special Ammo

STOP — Prompt 2's craft → select → timed reload/swap → shoot → status/impact loop is complete. Review/report/patch and current logs/images are in `outputs/ammo-pass` and `outputs/AMMO_RESULT.md`. Preserve the completed Prompt 1 camera/E/N work and do not repeat completed work without a new issue or request. No commit or push has been made.

## Performance Optimization

### Initial Symptoms

- Main Menu Play blocked the complete window, followed by intermittent gameplay spikes. Reproduced through the real Play button with Godot 4.7.1 Compatibility, 1280x720, real time and no fixed FPS.
- Measurement machine: i7-13650HX, RTX 4050 Laptop GPU, 144 Hz display. First load means a fresh Godot resource cache; the filesystem was already warm. These are observed samples, not hardware-independent FPS promises.

### Measurements Before

- First menu transition: 3654.928 ms total; longest frame 3654.261 ms. Second: 1791.931 ms total; longest frame 1787.770 ms.
- Day: mean 7.343 ms (~136 FPS), p95 8.830 ms, max 35.813 ms. Night 10 with 12 alive: mean 6.959 ms (~144 FPS), p95 9.041 ms, max 12.668 ms. Staggered night spawning reached 65.943 ms.
- Nodes: 1501 day / 2065 night. Static memory 112.61 / 123.34 MiB; about 2455 / 2385 draw calls. GPU, physics and navigation monitors were captured. Performance TIME_PROCESS refreshes slowly and retains transition values temporarily; those stale values are not steady gameplay CPU measurements.
- First/repeat real hits: Basic 67.0/62.8 ms, Fire 69.7/61.9 ms, Ice 69.2/69.0 ms, Poison 67.4/63.9 ms maximum event frames. Zombie spawn setup approximately 7.3 ms. Raw before samples are packaged with the final traces.

### Main Loading Bottleneck

- Scratch instrumentation attributed approximately 1026 ms to synchronous scene resource loading, only 2 ms to PackedScene.instantiate, 711 ms to terrain generation, 711 ms to vegetation, 192 ms to structures and 45 ms to the remaining builders. No runtime directory scan or navigation bake was found.
- Terrain recalculated height/color for shared triangle corners. Sampling each grid corner once reduced terrain CPU work to approximately 180 ms. This first change alone reduced the first transition from 3655 to 2932 ms and the second from 1792 to 1253 ms.
- A later render spike (~550 ms) came from applying final fog/lights after the entire environment had rendered. Bind existing final lighting before preparing scenery.
- Cabin grounding extraction traversed every vertex although that landmark only uses bounds and the existing full-face collider. Skip unused support/footprint extraction for Cabin and Water Tower.

### Runtime Bottlenecks Found

- Each impact recreated ParticleProcessMaterial and its mesh/material/gradient, producing repeated render/shader stalls. Sharing the authored resources removes that work.
- Zombie setup deep-copied every imported animation although only four clips change loop settings. Copy only those four and share the untouched clips.
- First Basic impact needed several actual particle renders, not merely one draw callback, before its first visible shader path was ready. A focused render trace separated the ~0.5 ms shot call from subsequent 32/62 ms render stalls; warming four frames moved that work into Loading.
- Bag, crafting, pause, weapon equip, planting and grown-stage transitions were sampled first/repeat. No evidence justified a second UI cache, new object pool, texture reduction or AI rewrite.

### Changes Made

- Reuse terrain corner samples; distribute terrain and existing environment generation across frames during loading; pace MultiMesh and furnished-landmark uploads.
- Add a lightweight threaded Loading scene, real loader progress, preparation animation, input lock, opaque cover, readiness handshake, shader preparation, fade and failure return. Start, restart and Play Again use this route.
- Reuse baked particle subresources and selectively copy zombie clips. Keep existing Godot resource caching and all current gameplay owners.
- Fix the existing export resource list: it omitted the menu background and scripts used by dynamic paths. Include production scripts/scenes/data/audio and the actual UI icons, without exporting the entire unused icon library.
- Update async-aware fixtures and their obsolete Phase 9 HUD reference. Diagnostics remain in workspace work/, outside production and exports. No performance manager or pool was added.

### Loading Architecture

- Main Menu -> small Loading scene -> ResourceLoader.load_threaded_request -> poll status/progress -> load_threaded_get only after LOADED -> instantiate disabled GameRoot -> await terrain/environment/game readiness -> render first-use resources -> fade -> enable gameplay and capture cursor.
- Terrain uses approximately 4 ms CPU checkpoints; environment uses approximately 8 ms checkpoints, with eight mesh uploads per render group. Individual engine upload/shader operations can still exceed those script budgets.
- Direct scene entry and editor tool generation retain synchronous initialization; normal Play and restart use the new flow. Critical gameplay binds only after both world builders complete. Existing final lighting binds before scenery renders.

### Loading Screen

- Reuses the current presentation theme. Shows real resource progress while loading; hides the bar for world preparation and uses changing dots instead of a fake timer percentage.
- Rendered acceptance: 290 preparation frames, five observed animation states; opaque cover and disabled gameplay remain until ready. Input spam Q/Tab/Esc/E/N/C/R does not open UI, change mode, advance the clock or grant ammunition. Input resumes after fade.
- Missing-resource fixture returns a usable Main Menu with a retry notice and clears transition flags. Its two intentional missing-resource error lines are expected test output.
- Screenshots checked at 1280x720; existing campaign/pause/menu/ending checks also cover 1920x1080.

### Vegetation Optimization

- Preserve existing deterministic positions, seed, ground-contact algorithm, foliage cell culling, MultiMesh layout, collision, shaders, LOD and materials. No grass collision or new interactive-object batching was introduced.
- Compare terrain mesh arrays, playable collision faces, environment placements, tree positions, grass counts and generated batch placement data against the exact pre-pass snapshot. Headless RenderingServer does not expose populated MultiMesh GPU buffers, so empty buffer hashes alone are not preservation evidence.
- Node counts remain 1501 day / 2065 with 12 zombies; the improvement comes from removing repeated work and distributing initialization, not deleting scenery.

### Zombie Optimization

- Spawn setup falls to approximately 2.7-3.1 ms for Normal/Runner/Tank. First/repeat isolated spawn frames are approximately 13-16 ms.
- Keep private copies of the four clips whose loop mode changes; share all untouched clips. Resource checks prove imported animations are unchanged and active copies remain independent.
- Preserve wave spacing, alive cap, campaign composition, AI, damage, status timers and navigation interval. No pool or timing/balance change.

### VFX Optimization

- Seven existing impact/plant scenes carry shared mesh, StandardMaterial3D, ParticleProcessMaterial and gradient subresources. Per-node emission/restart/finished behavior stays local. Motion, fade, sizes, amount and lifetime match the original parameter builder.
- tools/bake_elemental_particles.gd regenerates resources after exported parameters change. The fallback builder still supports dynamically created instances.
- Loading warms the three existing wave models, their hit overlay, muzzle flash and Basic particle shader behind its cover. Previews never enter wave counters, shoot, alter inventory or become visible to the player. Basic burst remains for four actual render frames.
- Electric and Pistol/SMG/Assault Rifle/Shotgun/Hunting Rifle/Heavy Weapon are absent from this project's player catalog; no speculative weapons/effects were created. Test the existing Basic Rifle and Wooden Bat.

### Navigation Optimization

- Reuse the existing baked NavigationMesh. No runtime bake or costly per-frame repath was found; measured steady navigation cost is around 0.01-0.04 ms.
- Preserve the existing zombie repath interval. Plants already use clock signals and interactions use nearby spatial targets; no global scanning rewrite was needed. Existing light/shadow and texture settings remain unchanged because reducing their quality was not supported by the measured CPU bottlenecks.

### Measurements After

- Final source-project measurement uses the same real menu/probe/renderer/resolution as the baseline. No other Godot, export or browser workload ran during final measurements.

| Observed metric | Before | After |
|---|---:|---:|
| First Play -> ready | 3654.928 ms | 4326.119 ms |
| First transition longest frame | 3654.261 ms | 226.114 ms |
| First transition frames | synchronous blocked transition | 346 responsive frames, p95 19.080 ms |
| Second Play -> ready | 1791.931 ms | 2562.333 ms |
| Second transition longest frame | 1787.770 ms | 77.672 ms |
| Day mean / p95 / max | 7.343 / 8.830 / 35.813 ms | 7.086 / 7.865 / 19.119 ms |
| Night 10 mean / p95 / max | 6.959 / 9.041 / 12.668 ms | 7.695 / 12.442 / 15.133 ms |
| Staggered night spawn max | 65.943 ms | 66.336 ms |
| First Basic / Fire / Ice / Poison hit max | 67.0 / 69.7 / 69.2 / 67.4 ms | 13.181 / 13.288 / 14.643 / 14.816 ms |
| Repeat Basic / Fire / Ice / Poison hit max | 62.8 / 61.9 / 69.0 / 63.9 ms | 15.741 / 15.516 / 18.415 / 14.677 ms |

- Longest initial blocking frame falls by approximately 94%; total transition duration increases because initialization yields and shader work/fade complete before input is enabled. Day mean corresponds to ~141 FPS and night ~130 FPS on this machine. Night average FPS did not improve; frame pacing gains are the large loading stalls and repeated shot events.
- After monitors, day/night: viewport render CPU 4.13/4.16 ms, GPU 6.49/6.97 ms; physics 0.86/2.94 ms; navigation 0.039/0.007 ms. Static memory 113.80/120.63 MiB; sampled objects 6042/6791 (before 5946/6843). Nodes and draw calls retain the baseline counts. These are sampled monitors, not additive frame-time components.
- Final exported PCK independently runs from a folder without source assets: first transition 4041.429 ms, longest frame 229.280 ms; second 2472.056 ms, longest frame 75.618 ms. Source and pack probes finish with engine exit 0, and both night fixtures reach 12 alive.
- First/repeat UI maxima after: bag 30.5/14.4 ms, crafting 17.3/15.3 ms, pause 9.8/8.4 ms. Rifle/bat equip maxima approximately 13-15 ms. Plant/grown-stage and actual harvesting are covered by event and full-day fixtures; those systems were not rewritten.
- Exact before/after terrain/collision/placement/tree/grass/generated batch data match. Batch placement fingerprint: 72d72f5342f53df5413c751cae69f2d21f8ec4340e87a868e47f726b25b264bb.
- Shared-resource checks: 27 PASS. Ten headless suites: 519 PASS, including ammo/refunds/statuses, camera, E/N, crafting, UI and the full farming/harvest/craft/combat/night/rest/natural-dawn loop. Rendered ammo, camera and UI suites pass. Final rendered Loading and campaign rescue/death/restart/ending suites pass with direct engine exit 0. Full event probe confirms all eight actual ammo hits, failures=0.
- Web export and standalone PCK export succeed with matching 4.7.1 templates; no script/parser/resource errors in the final native pack run. No standalone Windows release executable was generated because matching Windows export templates are absent.

### Remaining Issues

- First driver uploads/shader preparation still produce occasional approximately 100-230 ms loading frames. Loading is responsive across hundreds of frames, but it is not a guarantee of zero stalls on every GPU. Total first transition is 4.0-4.3 seconds in final pack/source samples, and cached second entry is longer than the old blocking route because it includes preparation and fade.
- Final-night spawn period still has occasional approximately 70 ms frames; isolated spawn CPU work improved, but no claim of improved average night FPS or elimination of every wave spike is made. Further GPU/driver investigation needs a separate request after this measured pass.
- The browser-control tool could not initialize (kernel asset path error), so Web export succeeded but browser execution was not verified. The exported PCK was executed independently in the native engine.
- Godot's Windows certificate-store warning is environmental. Verbose threaded-load shutdown diagnostics previously reported RefCounted objects with zero reference count; no leaked gameplay Nodes were found. Final direct native runs exit 0 without gameplay errors. Unused original audio imports can emit Unicode surrogate warnings during full editor import; active gameplay uses the existing clean WAV files.
- Existing legacy input_modes fixture failures documented in Prompt 2 remain outside this pass. Automated fixtures are not a human playthrough.

### Next Exact Action

- STOP — Prompt 3's measured loading/runtime pass is complete. CURRENT STAGE: completed. ROOT CAUSE FOUND and COMPLETED OPTIMIZATIONS are recorded above. LOADING SCREEN STATUS: rendered input/progress/animation/failure checks pass. MEASUREMENTS and TESTS COMPLETED are recorded above; REMAINING BOTTLENECKS are explicit.
- FILES MODIFIED: scripts/world/rural_terrain.gd, scripts/world/rural_environment.gd, scripts/main/game_root.gd, scripts/ui/loading_screen.gd, scenes/main/Loading.tscn, menu/restart routing, scripts/enemies/normal_zombie.gd, scripts/effects/elemental_particles.gd, seven elemental scenes, tools/bake_elemental_particles.gd, async fixtures, README.md, PROGRESS.md and export_presets.cfg (plus new UIDs).
- Deliverables: outputs/performance-loading-pass.patch (Prompt 3 only, against pre-pass tree 42bf8d728baf527ca6c3f3b7e80d7960e667a0e8), outputs/PROGRESS.md and outputs/performance-pass/ logs, raw samples and images. Preserve all completed Prompt 1/2 work. No commit, push or real-index staging. Continue only for a new issue/request; do not repeat successful optimizations without evidence.

## Arsenal Expansion

### Existing Unused Materials Found

- Audit ran the actual Main Menu -> Loading -> game, bag and workbench before changes. Catalog has nine MATERIAL items, all with existing icons. Obtain raw ingredients through existing farm crops; Metal Component is crafted at the existing workbench. No mine/resource-node system exists in the playable map.
- Metal Component: current purpose was a craftable dead end (Iron x2 + Copper x1, zero consuming recipes). New purpose is the shared mechanism/blade/frame ingredient of all five craftable weapons.
- Iron: previously consumed only by Metal Component. Now also reinforces Pistol, Sword, SMG and Marksman Rifle; its existing crop/seed supply makes weapon investment possible.

| Real material | Existing purpose before this pass | Purpose after this pass |
|---|---|---|
| Lead | Basic Ammo | Preserved: ammunition for every firearm |
| Paper | Basic / Fire / Ice / Poison Ammo | Preserved; also Knife / Sword / Pistol grip wrapping |
| Iron | Metal Component only | Component plus Pistol / Sword / SMG / Marksman Rifle |
| Copper | Four ammo recipes and Metal Component | Preserved; also direct SMG / Marksman Rifle investment |
| Small Herb | Basic Medicine | Preserved existing medicine recipe |
| Metal Component | No consuming recipe | Five weapon recipes |
| Fire Essence | Fire Ammo | Preserved, compatible with all four player firearms |
| Ice Crystal | Ice Ammo | Preserved, compatible with all four player firearms |
| Poison Extract | Poison Ammo | Preserved, compatible with all four player firearms |

### New Weapons

All five validate and are acquired through the existing farm -> component -> workbench -> bag -> loadout -> combat route. WeaponData, WeaponRuntime, WeaponController, EquipmentLoadout and existing Health/status owners remain authoritative. Old Basic Rifle and Wooden Bat resource values and starter grants are unchanged.

| Weapon | Day | Damage | Attacks/s | Range | Magazine / reload | Holding / role |
|---|---:|---:|---:|---:|---|---|
| Knife | 1 | 9 | 3.2 | 0.95 m | No ammo | One hand; fast, very short reach; hit delay 0.075 s, swing 0.23 s |
| Pistol | 2 | 18 | 4 | 45 m | 12 / 1.2 s | One hand; semi-auto, quick reload |
| Sword | 3 | 28 | 1.6 | 2.05 m | No ammo | One hand; stronger melee, moderate speed; hit delay 0.16 s, swing 0.43 s |
| SMG | 4 | 12 | 10 | 35 m | 30 / 1.8 s | Two hands; automatic, lower damage per round, large magazine |
| Marksman Rifle | 7 | 60 | 1.2 | 85 m | 5 / 2.3 s | Two hands; semi-auto, precise high damage, slow recovery |

- Knife's theoretical direct DPS is 28.8 versus Sword's 44.8; its 0.95 m reach requires approaching inside Normal's 1.35 m attack range. One hit is committed per swing, clicks cannot duplicate contact, and holding LMB does not auto-swing.
- SMG versus unchanged Basic Rifle: 12 vs 20 damage, 10 vs 5 rounds/s, 30 vs 10 magazine, 35 vs 60 m range, 1.5 vs 0 degree spread, 1.8 vs 1.5 s reload. It trades ammo economy and precision for sustained close-range fire. Pistol/Marksman direct DPS ceilings are both 72 before reload; their roles are quick reload and long-range ammo efficiency respectively.
- Basic direct-hit counts for Normal / Runner / Tank (100 / 60 / 300 HP): Knife 12 / 7 / 34, Sword 4 / 3 / 11, Pistol 6 / 4 / 17, SMG 9 / 5 / 25, Marksman 2 / 1 / 5. These are arithmetic balance checks, not human accuracy/TTK or playtest claims; reload, misses, DOT and enemy movement change actual combat.
- Three new guns declare Basic/Fire/Ice/Poison compatibility in their data. All use the same round/status resources and atomic timed reload/refund path as the existing rifle. No extra ammo family or reload owner.

### New Components

None required. Reuse the already craftable Metal Component instead of adding a second frame/barrel/blade component chain. Its original Iron x2 + Copper x1 recipe is unchanged.

### New Materials

None. Existing crops, seed grants, progression and icons supply every ingredient. No new map nodes, ore distribution, terrain or procedural generation.

### Existing Materials Repurposed

- Metal Component changes from zero uses to five practical weapon recipes. Iron changes from one direct consuming recipe to five, including the unchanged component recipe. Copper remains a shared choice between ammunition and weapons; Paper stays useful for ammo and early weapon grips.
- Refresh obsolete future-use descriptions for Metal Component and raw ingredients. Generic item help now uses ItemData descriptions, so new weapon controls and current material purposes appear in the existing bag/workbench.
- Existing Basic Medicine remains craftable; using medicine is still an existing unimplemented action, outside this weapon pass. No claim that its consumption loop was implemented.

### Recipes Added

| Output x1 | Existing ingredient cost | Total raw cost including components | Unlock |
|---|---|---|---|
| Knife | Metal Component x1 + Paper x1 | Iron x2 + Copper x1 + Paper x1 | Day 1 |
| Pistol | Metal Component x2 + Iron x1 + Paper x1 | Iron x5 + Copper x2 + Paper x1 | Day 2 |
| Sword | Metal Component x3 + Iron x2 + Paper x2 | Iron x8 + Copper x3 + Paper x2 | Day 3 |
| SMG | Metal Component x4 + Iron x2 + Copper x2 | Iron x10 + Copper x6 | Day 4 |
| Marksman Rifle | Metal Component x6 + Iron x3 + Copper x2 | Iron x15 + Copper x8 | Day 7 |

- Register five ItemData/WeaponData/CraftRecipe resources in the original catalog, recipe book, Player weapon definitions and corresponding day data. Eleven actual recipes are shown by the existing UI. No weapon is granted for free at round start; all stacks have max_stack=1. New guns start with empty magazines.
- Starter Iron/Copper/Paper seeds and existing daily seed grants are sufficient for the recipes in the actual farming fixture. Crafting debits every ingredient once and rejects unavailable/locked recipes through the original owner.

### Assets Reused

- Knife: Asset/Survival Pack-glb/Knife.glb.
- Sword: Asset/Ultimate RPG Items Bundle-glb/Sword.glb.
- Pistol and SMG: Asset/Post Apocolypse Pack.undefined-glb/Pistol.glb and Smg.glb.
- Marksman Rifle: Asset/Ultimate Guns Pack-glb/Sniper Rifle.glb.
- Preserve original low-poly meshes/materials. Thin weapon scenes set model scale/orientation plus existing PrimaryGrip, SecondaryGrip and Muzzle/HitTip nodes. Existing Matt rig, arm solver, melee presentation, muzzle flash and elemental impacts are reused.
- Add WeaponData.two_handed with default true to preserve old holds. One-handed weapons solve only the primary hand; SMG/Marksman keep the existing support-arm/reload pose. Normalize melee torso animation to each authored swing duration; the old bat's 0.48 s timing is preserved.
- Own-weapon cells now use a three-column scrollable grid inside the same inventory. Seven owned weapons remain selectable without growing the panel beyond 720p or 1080p; loadout retains three slots.

### Assets Created

- Five native SVG item icons under assets/ui/items: knife, sword, pistol, smg, marksman_rifle. Follow the existing item-icon outline and palette; no new icon framework or generated bitmap.
- No new 3D model, texture or animation was needed. The requested survival-crafting, godot-resources and fps-shooter skills were not installed in this session's local skill catalog; this was disclosed before work and the available lean-build guidance was used with the real project architecture. Conditional create-game-assets/procedural-gen work was unnecessary because suitable models and resource supply already existed.

### Runtime Tests

- CURRENT STAGE: completed. Eighteen runtime suites/pack probes pass, with 1,691 PASS assertions and no unexpected script/resource errors, in Godot 4.7.1. Logs, JSON results, raw loading samples and screenshots are in outputs/arsenal-pass.
- arsenal_test passes headless and rendered: plant with E, advance actual crop growth, harvest with E, craft existing components and all five weapons through workbench buttons, assert exact ingredient debits, equip through Tab/loadout buttons and wheel input, and hit actual Normal/Runner/Tank models with every new weapon. Basic Ammo is also crafted from harvested crops. Progression fixture advances existing day data; it does not grant weapons/ingredients.
- Melee proves windup, authored contact damage, one committed hit per cycle, rapid-click rejection, no ammo/reload UI, no repeat recovery damage and out-of-range/behind misses. Firearms prove empty initial magazine, configured timed reload/capacity, one-round damage, auto versus semi-auto hold and independent loaded state after switching weapons.
- Focused SMG Fire/Ice/Poison cases use supplied elemental-round fixture setup after the acquisition loop, then real C/reload/muzzle/status/VFX paths. Presentation-only fixture supplies the five weapons to inspect daytime holds and both inventory resolutions; acquisition is proved independently by farming.
- arsenal_presentation_test passes rendered: all five visible models, right grip error under 0.15 m, configured one/two-hand stance, seven-weapon inventory enclosed at 1280x720 and 1920x1080. Screenshots are in outputs/arsenal-pass.
- Existing Phase 4 fixture was updated for eleven recipes and scrolls its Metal Component button into view before clicking. Its atomicity, capacity, reentrancy and actual ingredient assertions are preserved; no crafting code was changed to satisfy obsolete six-recipe expectations.
- Thirteen headless suites pass: arsenal, existing bat, special ammo, ammo edge cases, Phase 4 crafting, camera controls, UI polish/refinement, E/N skip, Loading, shared performance resources, original rifle holding and the full farming/night/rest/natural-dawn loop. Four rendered suites pass: arsenal, arsenal presentation, camera controls and UI refinement. The independent rendered PCK probe also passes (47 assertions), crafting components/weapons from a raw-ingredient fixture, loading all models/icons, equipping, swinging/firing and checking ammo compatibility without the source checkout.
- All new models/resources/icons are included in both existing export presets (330 explicit production entries). Editor import, Web export and production PCK export exit 0. The 73,096,488-byte PCK runs from work/arsenal-native, a folder without source scenes/assets; the probe is external and tests are excluded from the pack. Browser execution remains unverified; successful native PCK execution is separate evidence.
- Same real Main Menu button/loading probe, 1280x720 Compatibility, i7-13650HX/RTX 4050 Laptop/144 Hz, no fixed FPS and no concurrent engine/export workload: first entry 4,242.841 ms with longest frame 214.313 ms; second 2,493.131 ms with longest frame 69.110 ms. Prior Prompt 3 source measurement was 4,326.119/226.114 and 2,562.333/77.672 ms respectively. New resources do not show a loading regression in this sample; the existing occasional driver/upload stalls remain. First entry renders 347 preparation frames, p95 18.609 ms. Day mean is 6.968 ms (p95 7.666 ms); these are observed samples with a warm filesystem, not an FPS guarantee or new night-performance claim.

### Known Issues

- No blocking acquisition/combat/presentation issue in the new focused tests. Automated fixtures freeze target AI for deterministic hit checks and advance crop/day time; this is not a human campaign playthrough.
- Old legacy input_modes fixture failures, existing medicine-use limitation and absent Electric Ammo remain as previously documented. Basic Rifle continues to provide the existing automatic rifle role; no Shotgun/pellet subsystem was added.
- Matching Windows export executable templates are absent, so no standalone release EXE was generated. Web export and independent native PCK verification pass. Previous browser-control initialization failure prevents claiming a browser playtest.
- Godot's Windows root-certificate warning is environmental; unused original audio imports may emit existing Unicode warnings. Test user data remains isolated under work/godot-data.

### Next Exact Action

- STOP — Prompt 4 acquisition/combat/presentation/export checks are complete. WEAPONS COMPLETED: Knife, Sword, Pistol, SMG, Marksman Rifle. WEAPONS REMAINING: none. RECIPES COMPLETED: five. NEW MATERIALS/COMPONENTS: none. REPURPOSED MATERIALS: existing Iron and Metal Component. TESTS COMPLETED: 18 suites/pack probes, 1,691 PASS assertions; loading comparison recorded above. Continue only for a new issue/request.
- FILES MODIFIED: five item/weapon/recipe resources, five weapon scenes, five SVG icons/import metadata, catalog/recipe book/Player/day definitions, six material descriptions and component recipe description, weapon_data.gd, rifle_pose.gd, inventory_ui.gd, ui_icons.gd, export_presets.cfg, two new arsenal fixtures, phase_4_crafting_test.gd, README.md and PROGRESS.md. Preserve all Prompt 1/2/3 work. No commit, push or real-index staging.
- Deliverables: outputs/arsenal-expansion.patch (Prompt 4 only, against pre-pass tree 67ec9196a9720bd0626c8afd03c960a1e9e76490), outputs/PROGRESS.md and outputs/arsenal-pass/test-results.json with logs/raw samples/screenshots alongside. The patch is generated from source snapshots without modifying Git's real index.

### Main Publication

- On 2026-10-07 the user requested publication directly to origin/main. The publication includes all completed Prompt 1–4 changes: camera/E/N behavior, special ammunition, responsive loading and arsenal expansion, with their checked-in runtime fixtures and resources. The 18-suite final validation remains the acceptance evidence; no gameplay code changed for publication.
- Earlier no-commit/push notes record delivery checkpoints before this publication request. Generated engine caches, exports, logs and workspace scratch files remain outside the commit.
