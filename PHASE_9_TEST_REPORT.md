# Phase 9 - Rescue Ending, Final Presentation & Game Polish

Verified 2026-09-30 with Godot 4.7.2, Compatibility renderer on Windows. Latest **42/42 per-check logs pass**: editor import, 28 headless gameplay checks, main scene boot and 12 rendered checks. This aggregates latest reruns, not a claim that the first batch passed. Machine-readable results and 16 screenshots: [docs/phase9](docs/phase9/).

## 1. Rescue ending

NightWaveManager completes at Day11 06:00 after Night10, through natural dawn or rest. Existing gameplay shutdown cleans enemies and locks movement, firing, interaction, clock and debug progression. GamePresentation additionally gates damage, hides gameplay HUD and guards against duplicate starts. Fade reveals a dedicated camera, Somchai and the existing Helicopter.glb descending into RescueArea; at eight seconds the ending panel offers Play Again/Main Menu. No new Day11 wave starts.

## 2. Final night

Day10 17:00 warning, FINAL NIGHT HUD, distinct plum night sky and stronger wind ambience distinguish the last night. Existing mixed Normal/Runner/Tank final wave and all balance values are preserved.

## 3. Main Menu

MainMenu.tscn is now project entry. Original SVG landscape, title, Play, How To Play and Quit. Play opens a fresh game with development overlays hidden. Guide/Play were exercised using UI clicks; Quit is wired to SceneTree.quit but not clicked in the flow test.

## 4. Pause Menu

Resume, How To Play, Restart, Main Menu and Quit share the theme. Esc closes the guide before resuming. Input, weapons and game clock remain stopped while paused. Restart and menu release the pause state; runtime button checks pass.

## 5. How To Play

Shared guide documents movement, farming, crafting, combat, reload, camera shoulder, bag, rest and ten-night objective. It explicitly discloses craft-only medicine/elemental ammunition. First-day HUD guidance reinforces Plant > Harvest > Workbench > Ammo.

## 6. HUD and modes

Smaller game title, final-night label, mode-change feedback, five-second messages, low-health text and short damage flash. Existing ammo, wave, interaction and stat displays remain. Feedback arriving after scene removal is ignored, fixing a detached Timer error observed during repeated scene changes.

## 7. Inventory UI

Shared theme and nine new original elemental icons distinguish seeds, materials and ammo by shape/color. All 24 slots and inventory pause/selection behavior retain regression coverage. No capacity or item economy changes.

## 8. Crafting UI

Shared compact theme makes all six recipe buttons visible at 1280x720, including Metal Component. Initial larger padding hid the final recipe; fixed and verified by targeted crafting rerun and inspected rendered screenshot. Locked recipes, owned/required materials and success feedback remain readable.

## 9. Map polish

Farm soil edges, clear zone placards, landing H, boundary posts, simple trees outside the playable walls and supported lamp fixtures. Test-station label/interaction follow debug visibility. Existing walls, shelter, paths, plot/workbench locations, collisions and navigation mesh remain unchanged. Existing camera/navigation/zombie route checks pass.

## 10. Lighting

Day lighting retained. Night directional energy increased from 0.12 to 0.22 and ambient energy from 0.32 to 0.5; final-night colors are distinct. Three warm non-shadow local lights use seven-meter ranges. Rendered night combat remains readable. No additional shadow-casting local lights.

## 11. Audio

Nine original procedural PCM WAVs: shot, reload, empty/click, harvest, craft, hurt, unlock, wind and rotor. Reproducible generator and provenance in assets/audio/README.md. Six pooled cue voices plus one ambience loop; ending switches wind to rotor, scene exit releases players. Waveform peaks below 0.63 avoid source clipping. Runtime rendered checks use Dummy audio and validate integration, not a human listening/mix assessment. Headless tests skip WAV playback while recording cue events. No music or downloaded samples.

## 12. VFX

Added brief red damage overlay and low-health indication; existing muzzle flash, hit marker and zombie hit/death feedback retained. Farm/craft completion uses messages and cues. No costly particle system or new damage/effect mechanic.

## 13. Animation improvements

Imported animation libraries are duplicated per instance before loop settings; idle transition blends 0.2 seconds and moving/death blends 0.12. Existing Idle/Walk/Run/Death clips remain authoritative. Matt includes gun stance variants, but these are not integrated in this phase. No dedicated reload, fire, strafe or aim clips were found. The imported helicopter is one mesh without animation, so its rotor remains static.

## 14. Camera tuning

Normal distance 4.2 -> 4.5, aim distance 2.6 -> 2.8 and normal FOV70 -> 72. Aim FOV55 and collision/shoulder behavior retained. Camera controls, obstruction rays, walkthrough and 30/120Hz consistency checks pass. Rate fixture now asserts configured aim distance rather than the old hardcoded distance.

## 15. Interaction feedback and transitions

Mode, planting/harvest, workbench/craft, reload and unlock cues are connected to gameplay signals. Rest fades in during the existing transition, fades out on the next morning and announces rested/no-rest outcome. Clock, healing and crop growth remain under the existing rest manager.

## 16. Game Over

Readable death panel with Try Again [R] and Main Menu. Death releases mouse capture; restart resets day and damage gate. Dying on Night10 cannot trigger rescue even after seeking dawn in the test fixture.

## 17. Ending test result

Phase9 headless and rendered checks pass: natural final dawn; protected health; duplicate completion guard; rescue camera/vehicle; ending UI; Main Menu; fresh Play; final-night death exclusion; ending Play Again; pause Restart/Main Menu. Existing Phase8 tests cover both rest and natural final completion. Ending and menu fit 1920x1080; scaled clicks successfully return to gameplay.

## 18. Full presentation and regression

New test follows Main Menu > guide > plant/harvest > craft > inventory/pause > rifle combat > rest > death/menu > Day10 warning > final night > rescue > ending > menu/restart. This is a focused fixture: it teleports for setup, advances crop time, uses debug day selection, and clears waves directly where appropriate. It is not an unaided ten-night playthrough.

The separate full-day regression uses normal game clock/input without teleporting, granting ammo or healing: plants eight crops, crafts40ammo and medicine, kills six zombies with30shots and rests HP90 ->100. No-rest branch preserves damage, and the full run passed in about53 seconds of accelerated headless wall time. Rendered natural crop growth took30.397 seconds. Existing ten-day accelerated state, variant combat, unlock/reward, navigation, weapon, farming and UI regressions pass.

First batch failures involved three outdated fixtures (main scene, night energy and camera distance) and the actual crafting overflow. Fixtures were updated to the intentional presentation contracts; overflow was fixed. Additional focused testing found and fixed scaled click coordinates, layout timing and queued feedback after scene removal. Latest individual logs have no assertion/runtime errors. See test_results.json for exact result lines. Latest three decorative lamp supports do not change collision/navigation or gameplay; final Phase9 rerun checks compilation/integration after that edit.

## 19. Known visual bugs

Static helicopter rotor; simplified landing with no boarding animation; generic weapon handling and no authored reload. Crop/world shapes and enemy scale/tints remain stylized placeholders. No clipping remains in inspected 720p crafting menu or ending/menu at1080p. Other aspect ratios/localizations are not certified.

## 20. Known gameplay bugs and limits

No remaining failing covered runtime case. Medicine/elemental ammo are intentionally craft-only. No save/resume, dynamic navigation/crowd avoidance or complete manual ten-night economy playtest. Full final balance remains pending; automated progression checks cannot establish fun or difficulty.

## 21. Performance concerns

No new per-frame enemy search or expensive particle effects; capped audio voices and three bounded non-shadow lights. Decorative meshes increase node/draw counts. Accelerated progression observed stable daytime node counts across all ten days, with cleanup of wave objects; this is evidence against that specific accumulation, not a memory/FPS benchmark. Target hardware GPU/CPU/memory, overdraw and long-session audio profiling belong to Phase10. No final performance claim or export test.

## 22. Missing assets / animations

No music, bespoke fantasy crops, distinct authored Runner/Tank models, helicopter rotor/boarding clips or dedicated weapon/reload/aim animations. Existing Helicopter.glb is reused without modifying its source. UI SVGs, procedural audio and simple environment primitives were created locally.

## 23. License / attribution

No third-party downloads added. Existing GLB asset pack license/readme files were not found, so author/license/distribution rights remain unverified; no permission is inferred from filenames. New menu/item SVGs and generated audio are original project work, with audio method documented. Confirm original asset licenses before public distribution/export.

## 24. Phase10 readiness

Demo presentation and rescue scope complete, latest regression checks pass and evidence is committed. Next phase needs final balance/full campaign QA, real listening test, target hardware profiling, license verification and export validation. **STOP: wait for Phase10 authorization.** No Phase10 implementation or export performed.
