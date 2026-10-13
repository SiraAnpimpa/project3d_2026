# Web audio recovery — 2026-10-14

Added explicit browser audio unlock/recovery and a visible enable-sound button when Chrome suspends its AudioContext. Gameplay pause/resume now tracks each requested transition directly and owns all spatial voices. The Web shell requests a fresh pack after deployment. Actual browser output measurements confirm all 16 tested effects, day/night ambience, pause/resume, mute/unmute and context recovery; the 27 native gameplay assertions also pass. [Measurements and limits](docs/audio_recovery/README.md).

---

# Web audio correction — 2026-10-13 (historical)

The reported deployed audio crackle was reproduced and fixed. Repeated per-frame resume commands recreated Web Sample buffers; commands now run only when a player's pause state changes. Browser regression drops1091 resume/restart requests in23s to3 resume requests across140s, with no browser audio errors. Normal ambience loops remain active. Full27-check audio regression passes; the Web build is refreshed. [Evidence and reproduction](docs/web_audio_fix/README.md).

---

# Supplied audio integration — 2026-10-12

Pulled `origin/main` with a fast-forward from7cf0228 to **1437238** before edits. Local worktree was clean. All12 supplied MP3 recordings are now used by the game. Original source MP3 bytes are preserved.

## Event mapping

- Nature recording: looping daytime ambience. Zombie-arrival recording: looping night ambience, crossfading at dawn/dusk with a stronger final-night level.
- Single-shot recording: one trimmed cue for each actual pistol/rifle/marksman shot. Rapid-fire recording: one short section for each actual fast automatic shot (SMG), without adding shots or looping beyond fire events.
- Vegetable pickup: successful crop harvest through the existing interaction signal. Other-item pickup: successful crafting output.
- Grass/stone recordings: footsteps based on actual grounded distance travelled. A short downward ray at each step distinguishes terrain/farm soil from solid structure surfaces. Idle, airborne, teleport, pause and dead-player movement produce no new steps.
- zombie1/2/3 recordings: Normal/Runner/Tank vocal references in ZombieData. Three positional voices serve active nearby enemies, following their positions and stopping on death/despawn. Voices are staggered4–8s, limited to20m triggering/22m audibility, and use an independent RNG so audio does not consume gameplay randomness.
- UI recording: buttons across Main Menu, Settings, Pause, inventory/crafting and dynamically created dialogs. Two persistent UI voices survive scene changes; duplicate requests within a frame play once.

Ten short mono cues are derived under `assets/audio/supplied/`. Their selected intervals, duration, sample rate, bounded gain and source hashes are in [mapping.json](assets/audio/supplied/mapping.json). The two background files remain compressed MP3s. Reproduce the derivatives with `tools/prepare_supplied_audio.py` (numpy/soundfile are preparation dependencies only).

## Pause, volume and cleanup

Six effects, one footstep player, three spatial zombie voices and two ambience loops are bounded. Gameplay streams suspend while paused, while the separate global UI service remains available. All audio uses the existing Master bus and Settings volume/mute control. Harvest/crafting failures do not play their success cues. Scene teardown stops game voices and clears zombie ownership. Ending stops ambience/footsteps/zombies and retains the existing looping rescue-rotor cue.

Reload, hurt, unlock, melee and helicopter audio retain existing procedural cues because the supplied set contains no matching recordings. No gameplay balance, damage, weapon firing, inventory transaction, zombie AI or map geometry was changed.

## Verification

**27 rendered runtime assertions pass, zero final assertion or script errors**, using Godot4.7.2 Compatibility / RTX2060 and Dummy audio. Actual menu input, grounded movement, E planting/clock growth/E harvesting, successful crafting, pistol and SMG firing, three zombie variants, pause/resume, Master mute/unmute, death cleanup, ending/rescue and game teardown are exercised. Playback stream selection and state are verified; this is not a human listening/mix-quality certification.

The fixture uses a separate `SomchaiAudioQA` application user directory, preserving player saves. Its temporary project file and junctions are under `.godot/audio-test-project`. Run `tests/supplied_audio_test.gd` against that isolated fixture, not against ordinary player saves. The test explicitly refuses a non-isolated user directory. Initial fixture mistakes (platform below terrain and a nonexistent equipment selector) were repaired; final gameplay code was not changed to accommodate those mistakes.

Final editor import and **Web release export pass**. Both export presets list the new audio dependencies. Export logs show the supplied cues, both background recordings, the UI service and their compiled resources included. Updated `docs/index*` files contain the new build; exact hashes and sizes are in [build_manifest.json](docs/audio_integration/build_manifest.json).

Local release smoke in the Codex in-app browser confirms menu, Settings, game scene and Escape→Pause. No Godot script/resource loading errors were observed. The IAB returned a Chromium `UnknownError` and a black capture during pointer lock; Escape restored the rendered Pause screen. This limits browser input/listening certification and is recorded rather than treated as a complete browser playthrough. No new Windows executable was exported; current source and the committed Web build include this pass.

Evidence: [runtime log](docs/audio_integration/runtime_result.txt), [results](docs/audio_integration/results.json), [original source audit](docs/audio_integration/source_audit.json), [export log](docs/audio_integration/web_export_result.txt).

## Provenance

The recordings were supplied under `Asset/game_sounds/`; no creator, source URL or license text accompanies them. They and their derivatives are identified as supplied recordings, distinct from the project-authored procedural cues. See [credits](ASSET_CREDITS.md) and [audio provenance](assets/audio/README.md).
