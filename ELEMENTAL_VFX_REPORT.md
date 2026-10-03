# Elemental VFX pass ? 2026-10-04

**Verified implementation checkpoint; full special-ammo/status target remains unavailable in this checkout.** Based on current `e3007f6`, including gameplay refinement, map and UI work. Existing staged plant changes were continued. No new damage/status/ammo-selection gameplay was invented. The old Windows/web artifacts have not been rebuilt for this pass; run current source.

## 1. Existing special ammo found

| Ammo | Current damage | Current status | Previously existing VFX | Added |
|---|---|---|---|---|
| Basic | 20 via Basic Rifle | None | Muzzle flash / hit HUD / enemy hit flash | Neutral surface impact |
| Fire | Not usable | None | None | Mapped impact preview |
| Ice | Not usable | None | None | Mapped impact preview |
| Poison | Not usable | None | None | Mapped impact preview |

ItemData, recipes and elemental seed unlocks exist. There is no AmmoData or selectable elemental chamber/loadout. Electric and Water are absent. Current gameplay refinement and UI reports explicitly describe special ammo as craft-only.

## 2. Existing status effects

No Burn, Slow, Poison DOT, Shock or Wet runtime exists. Existing transient damage flash/death animation is retained. Status duration, stacking and balance cannot be inferred from the prompt. No persistent particle claims an unimplemented status is active.

## 3. Plant particles implemented

Fire Pepper, Ice Plant and Poison Plant each reference their own GPUParticles3D scene. Basic crops retain no elemental particles. Original low-poly mesh particles need no downloaded art, texture, light or shader assets. StandardMaterial3D is unshaded with alpha/color-ramp fade; each emitter has a ParticleProcessMaterial. Plant source meshes/materials are unchanged.

## 4. Plant growth-stage VFX

Seed and sprout: hidden/non-emitting. Growing: amount_ratio 0.4. Ready: 1.0, at most12 motes. One emitter per plant survives growth changes. Its scale and offset follow PlantData.stage_scales. Mature emitter heights are Fire0.74m, Ice0.62m, Poison0.52m, matching current measured crop wrappers. Existing model stages and interaction readiness remain readable without particles.

## 5. Fire VFX

Small narrow orange embers rise above the red bush; lifetime0.9s. Preview impact uses16 faster orange sparks,0.45s. No large flame, light or environment changes.

## 6. Ice VFX

Pale cyan flat flakes drift slowly, lifetime1.5s. Preview impact uses16 flat fragments,0.45s. No frozen shell or fake slow status.

## 7. Poison VFX

Low-poly rounded green spores drift close to the shelf fungus, lifetime1.8s. Preview impact uses16 rounded droplets,0.45s. No opaque smoke volume or fake poison damage.

## 8. Electric VFX

Not applicable to current catalog; no invented Electric plant/ammunition/status.

## 9. Water VFX

Not applicable to current catalog; no invented Water plant/ammunition/status.

## 10. Impact architecture

ItemData.impact_vfx is an optional PackedScene. WeaponController adds a small generic visual hook after existing damage resolution for an actual ray collision, including cover hits. The burst is parented to the current game scene, positioned at last_shot_end and oriented with the surface normal. Basic ammo uses this in normal play. Elemental resources hold their respective references for later gameplay integration. No zombie-specific element switch and no change to damage, cadence, inventory transactions or melee.

## 11. Status VFX architecture

Deferred pending an actual authoritative status lifecycle. A future status component should own one emitter per active status and stop it on expiry/death/despawn; refreshing gameplay should refresh that same emitter. This is a future integration contract, not implemented or tested status functionality. User clarification about adding new gameplay was requested; no answer authorizing it was received.

## 12. Cleanup behavior

Harvest removes the PlantVisual and its owned emitter. Impact one_shot.finished queues deletion after0.45s; it remains a world-position burst when the target dies. Pause suspends particle lifetime, resuming allows expiry. Current-scene ownership bounds transients to scene teardown/restart. There are no added persistent zombie attachments or global VFX registries.

Rendered tests: all12 planted crops grow through the real clock and harvest correctly; all four burst scenes expire. Actual Basic Rifle hits on Normal/Runner/Tank apply20 damage at the recorded ray hit; pause retains each burst and resume/target death allows cleanup. Assertions passed. Initial impact fixture needed RMB pressed again after pause, consistent with existing control cancellation; production gameplay was not modified to accommodate the test.

Evidence: `docs/elemental_vfx/` contains final logs and ten rendered plant/impact previews. `tests/elemental_vfx_test.gd` and `tests/elemental_impact_test.gd` reproduce them with `--script`, `--fixed-fps 60`, and optional `-- --capture-dir <directory>`. Preview captures are controlled fixture cameras, not human playtesting.

## 13. Performance test

Matched current-code comparison, Godot4.7.2 Compatibility / RTX2060,1920x1080,600 rendered frames per scenario after warm-up. Off duplicates the same PlantData with only ambient_vfx cleared; On enables12 mature magical plants. Night10 holds12 real living enemies; player damage is disabled only in this synthetic performance fixture. Fixed-FPS is NOT used. Same farm camera; this measures ambient overhead, not elemental crowd firing.

| Scenario | Mean off/on ms | p99 off/on ms | Draw calls off/on |
|---|---|---|---|
| Day | 8.752 /8.940 | 13.872 /13.459 | 2295 /2307 |
| Night10,12 alive | 10.920 /11.081 | 17.411 /15.232 | 2407 /2419 |

Night mean increases0.160ms (~1.5%); nodes+12 and static memory about+0.91MiB. Both runs contain frame-time variance; lower p99 is not evidence VFX improves performance. Baseline p99 already exceeds16.67ms. No significant average regression was observed in this short sample; this is not a minimum-FPS guarantee. Raw JSON/logs are retained. Reproduce with tests/elemental_performance_test.gd, comparing the --without-vfx user argument against default.

Budget:12 particles per mature plant (144 across12 plots),16 per short impact. At rifle5Hz, overlapping bursts remain bounded by0.45s lifetime. Visibility range22m with2m margin; no particle shadows or extra lights. Visibility culling does not promise offscreen GPU simulation is stopped.

## 14. Known issues

Full requested special-ammo firing and status-lifetime acceptance cannot pass because those gameplay systems do not exist. No claim of Burn/DOT/Slow, status stacking, elemental crowd combat or status dawn cleanup is made. Short desktop GPU tests do not certify low-end hardware, WebGL, a packaged build or a sustained campaign. Existing EXE/web files are unchanged.

## 15. Remaining placeholder VFX

Particle geometry is intentionally simple boxes and low-poly spheres, with no authored texture/flipbook. Fire/Ice/Poison impacts are runtime-tested previews and data mappings pending usable elemental ammunition. Status assets are deferred rather than displayed without gameplay truth. Next exact task: decide whether to authorize new special-ammo/status gameplay or supply a checkout where it already exists, then bind VFX to its real lifetime.
