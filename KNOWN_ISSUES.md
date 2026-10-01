# Known issues - v0.1.0-demo

## Current: Gameplay & Character Refinement

Latest focused stamina/animation/aim/bat/farming/live-night checks and ordinary full-day/natural-dawn regression pass. Remaining visual limits: residual foot sliding, coarse palm/finger placement and occasional hand/body clipping, especially at close/extreme aim or bat sweep. Matt has no dedicated Aim/Shoot/Reload/Strafe/Backward/Bat clips or Hand bones; reused gun clips/knuckle anchors and local pose adjustments approximate these actions. Marker alignment is measured, but does not prove perfect skinning.

Eight plants now use distinct native sources. Their growth reuses each mature model at0.35/0.70/1.0 scale; the pack has no authored crop stage sets. Fire/Ice/Poison are thematic analogues; Water/Electric do not exist in the gameplay catalog. Bat swing/hit cues are procedural audio placeholders. Damage10 is the requested starting balance, with automated variant/live-night verification; human difficulty, listening and a fresh ten-day campaign are unmeasured.

Map/rotor/decorative-supply/save/consumable limits below remain. Short RTX4060 Laptop debug profiles show no substantial plant-art regression; they do not certify minimum hardware/release/sustained play. The historical EXE/PCK predates this source pass. Only the pre-existing Windows certificate-store diagnostic is excluded; no unresolved parser/runtime/assertion/navigation failure in latest gates. [Report sections13–15](GAMEPLAY_REFINEMENT_REPORT.md#13-known-issues), [evidence](docs/gameplay_refinement/README.md). **STOP for user review.**

## Historical: Final environment cleanup

D01–D10 cleanup treatments are complete; latest focused assertions/import/runtime/navigation checks pass. Workshop/depot roof support, floating bench, dominant Cabin exterior tones, misplaced signs/asphalt/drainage pieces, stack/tool/fence/rock contact and ground edges are corrected. [Report section 11](MAP_FINAL_CLEANUP_REPORT.md#11-remaining-minor-issues) lists current minor limits.

Remaining: mixed native stylized detail colours/pale Cabin electrical panel; existing crop/bench labels and crop art; earlier character/weapon issues/static rotor; distant horizon openings; decoration-only supplies. Representative reveal/contact samples do not cover every possible view. First after night720 p99 18.506 ms; confirmation 10.997 ms, all confirmation scenarios below16.67 ms. Short RTX4060 Laptop/debug profiling, background Godot and unmeasured low-end/release/sustained play prevent general performance certification. No new export; historical EXE/PCK remains older. Known Windows certificate-store diagnostic is excluded explicitly. Current runner: tests/run_cleanup_tests.ps1; old fixed-coordinate suites remain historical. **STOP for user map review.**

## Earlier phase records

The following sections preserve earlier versions and their stated counts; current source/evidence is described above.

## Historical beautification pass limits

Current source map is complete; latest focused checks pass with no unresolved navigation/parser/runtime/assertion failure. Preserve the known Windows certificate-store diagnostic exclusion. Mixed stylized art/bright Cabin surfaces, simple workshop/ruins, broad open far-horizon gaps and existing plot labels/crop art remain visible. Character/weapon animation and static rescue rotor were outside this map pass. Scenery supplies remain decorative;±56 m safety surrounds the visual-only outer world. Occlusion uses representative sample eyes, not every possible view. Performance is a brief RTX4060 Laptop debug sample and increased with native Cabin/grass; minimum hardware/release/sustained human play is unmeasured. Historical Phase10 EXE/PCK is an older map. The original fixed-coordinate regression runner contains historical map fixtures; use tests/run_beautification_tests.ps1 for the current world. Details/evidence: MAP_BEAUTIFICATION_REPORT.md. STOP for map review.

## Historical map pass limits

The redesigned map is current Godot source; the historical Phase10 EXE/PCK contains the previous map. Landscape/fences/supplies are static; decorative chests/tools do not add storage/tool gameplay. All playable tree trunks collide, while foliage/understorey and background do not. Invisible safety at±56 m supplements natural boundary scenery; the outer240 m world is visual-only. Spawn screening was checked from one farm eye, not every possible elevated camera. Performance passed brief RTX4060 Laptop debug samples; minimum hardware/release/sustained human difficulty remain unmeasured. New map tests use real controller input; focused geometry/combat fixtures disable damage/grant items, and separate ordinary-resource full-day tests pass. No unresolved functional map failure in latest checks; stop for user visual review. See MAP_REDESIGN_REPORT.md.

## Refinement pass1 additions

- Aim/fire/reload/strafe authored clips are absent. New holding, upper-body aim, recoil, reload hand dip and strafe adjustment are procedural approximations over the existing Matt clips; some hand/body clipping and foot sliding remain at extreme angles.
- Scenery chests are decorative; medicine/elemental ammunition still cannot be used. No new handheld seed/medicine models or tool actions were added.
- New source is tested in Godot4.7. The historical Phase10 EXE/PCK has not been rebuilt in this pass.
- Windows test runtime reports an existing certificate-store diagnostic; no online services are used. Functional errors are tracked separately in the refinement report.

| Severity | Issue / reproduction | Workaround / reason |
|---|---|---|
| Medium, distribution gate | Original GLB pack licenses are absent; inspect ASSET_CREDITS.md | Verify original sources/rights before public distribution |
| Medium, scoped limitation | Craft medicine or elemental ammo: these cannot be used | Use Basic Ammo/Rifle and bed healing; no new combat/consumable system in final QA |
| Medium, limitation | Close the game: campaign is not saved | Complete in one sitting; large save system excluded |
| Low | Rescue rotor does not rotate; no boarding/reload clips | Imported asset has no such animation; simplified demo ending |
| Low | Runner/Tank reuse tinted/scaled zombie model; plants reuse mature art for growth | Gameplay stats/animation distinguish enemies; bespoke art deferred |
| QA limitation | Automated aim and movement do not measure human difficulty or enjoyment | Manual presentation playthrough and listening test recommended |

No claim of clean-machine compatibility or minimum hardware certification. Actual tested environment and remaining release gates are recorded in FINAL_QA_REPORT.md.
