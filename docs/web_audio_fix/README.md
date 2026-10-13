# Web audio crackle fix — 2026-10-13

The original integration assigned `stream_paused=false` to every active gameplay voice on every frame. Godot's Web Sample backend treats that assignment as an unpause request and recreates its AudioBufferSourceNode; it does not discard redundant resume requests. Its sample buffer copy therefore repeated at frame cadence, disrupting audio and eventually failing allocations.

`GameAudio._pause_if_changed` now forwards only a changed pause state. Checking each player also covers the three spatial voices that receive native tree-pause notifications, and newly active voices. Default Sample playback, no-thread Web export, volumes, audio recordings and gameplay remain as configured.

## Actual browser regression

The isolated `tests/web_audio_probe.tscn` fixture runs the actual GameAudio processing method with two background tracks and a one-shot. It pauses once at4s and resumes at5s. It omits world preparation/rendering so backend behavior is measured directly. `tools/instrument_web_audio_probe.py` adds counters only to temporary exported JS under `.godot/web-audio-validation/`; it refuses production directories and duplicate instrumentation. The production JS/template was not modified.

| Observation | Before | After |
|---|---:|---:|
| Observed fixture runtime seconds | 23.079 | 140.669 |
| Sample pause requests | 177 | 3 |
| Sample resume requests | 1091 | 3 |
| Backend sample restarts (including normal loops) | 1091 | 13 |
| Browser audio errors | createBuffer allocation failure | None |

Before/after use the same Godot4.7.2 Compatibility single-thread export and browser backend. Original failure was reproduced on2026-10-12, final resumed verification on2026-10-13. The after fixture received a real canvas click to enable playback. Natural looping accounts for later restarts; the resume count does not increase with frames. This is backend regression evidence, not certification of every browser/device or human listening quality.

The full rendered game integration test also passes all27 existing audio assertions after the fix (actual pistol/SMG, grass/stone, E harvest, craft, three zombie variants, volume/mute, pause/resume, death, ending and teardown). It runs in the isolated SomchaiAudioQA user directory. The interrupted attempt is not counted as passing; the final log is included.

Production Web export succeeds with zero script errors and includes the new compiled GameAudio. The fixture and instrumentation are excluded from the production pack. `docs/index.html` and `docs/index.pck` are refreshed; exact exported artifact hashes/sizes are in build_manifest.json. The previous live deployment served the old86,976,908-byte PCK; the fixed PCK is86,977,340 bytes.

## Reproduction

Use an isolated project copy with junctions to the source directories, a separate application name/user directory, and main scene `res://tests/web_audio_probe.tscn`. Select that fixture/script in a temporary Web preset and remove the tests exclusion only in the temporary copy. Export into `.godot/web-audio-validation/<case>/index.html`, instrument with `python tools/instrument_web_audio_probe.py <export-directory>`, serve the parent directory over local HTTP and open the case in a browser. Read the visible `web-audio-qa` panel and browser console. Never instrument the published `docs/` build.

Engine references corroborating the locally inspected generated JS: [AudioStreamPlayerInternal pause forwarding](https://github.com/godotengine/godot/blob/master/scene/audio/audio_stream_player_internal.cpp), [Web sample backend pause/unpause](https://github.com/godotengine/godot/blob/master/platform/web/js/libs/library_godot_audio.js). The measured counters come from this project's exported backend, not an assumption about upstream master.
