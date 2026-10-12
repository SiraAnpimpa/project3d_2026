# Supplied sound cues

Derived from the supplied MP3 recordings under `Asset/game_sounds/`. The originals remain unchanged. `mapping.json` records each source, SHA256, selected interval, output duration/rate/channels and peak level.

| Output | Original category | Runtime use |
|---|---|---|
| click.wav | ui / เสียงกด | Menu and gameplay UI buttons |
| shot.wav | ยิงปืน / ยิงทีละนัด | One sound per actual pistol/rifle shot |
| shot_auto.wav | ยิงปืน / รัว | Short section per actual fast automatic shot |
| harvest.wav | เก็บของ / เก็บผัก | Successful crop harvest |
| pickup.wav | เก็บของ / เก็บไอเทมอื่นๆ | Successful crafting result |
| step_grass.wav | เดิน / เดินเหยียบหญ้า | Actual distance travelled on earth/farm terrain |
| step_stone.wav | เดิน / เดินเหยียบพื้นหิน | Actual distance travelled on solid structure surfaces |
| zombie_normal.wav | ซอมบี้ / zombie1 | Positional Normal vocal |
| zombie_runner.wav | ซอมบี้ / zombie2 | Positional Runner vocal |
| zombie_tank.wav | ซอมบี้ / zombie3 | Positional Tank vocal |

The two background MP3s are loaded directly as compressed loops: เสียงธรรมชาติ by day and เสียงตอนซอมบี้มา by night. Normalized short cues are mono PCM16 source WAVs; the Godot importer compresses them. Short crop windows prevent one event from playing an entire recording of several shots, footsteps or vocals. Edge fades are6ms; peak gain is bounded to -3dBFS, with maximum gain12x.

Reproduce with `python tools/prepare_supplied_audio.py` after installing `numpy` and `soundfile`. This is an asset preparation tool; the game does not depend on Python.

The recordings were supplied with the project. No creator, source URL or license text is present, so they are not described as project-authored or assigned an inferred public license.
