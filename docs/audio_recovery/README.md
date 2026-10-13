# Web audio recovery — 2026-10-14

The user reports that all audio is silent in Chrome after the previous deployment. The earlier restart-counter test established that redundant resumes stopped, but did not measure audible output. This pass measures the browser's outgoing audio signal as well as gameplay wiring.

## Changes

- `tools/web_shell.html` is the Web preset's persistent HTML shell. It tracks the engine's own AudioContext before construction and resumes it synchronously on real pointer/keyboard input. A **เปิดเสียง · Enable sound** button appears when the context is suspended and disappears when running. It also retries on returning to the page. It creates no additional audio context and leaves the game's Master volume/mute control intact.
- `GameAudio` tracks the requested pause transition directly. Each pause has an explicit resume, with no per-frame resume calls. Spatial zombie players use `PROCESS_MODE_ALWAYS`, matching the other gameplay players, so GameAudio owns their pause/resume too.
- The shell requests the PCK with a build query while preserving its original filename in Godot's virtual filesystem. This prevents the previous pack from being reused after this deployment. The engine script is versioned as well.

## Verified output

The isolated browser probe uses the actual GameAudio code and shipped recordings. Test-only JS taps each AudioNode connected to the browser destination with an AnalyserNode; it does not replace or disconnect the output. Samples are measured every 20 ms. Pause/mute measurements discard the first 150 ms so the analyser's retained FFT window does not count as current output.

- Cold startup: AudioContext suspended, time 0, signal 0; the enable-sound button is visible. Clicking that HTML button changes the existing context to running and hides the button.
- All 16 tested effect cues have nonzero outgoing peaks: supplied click, pistol/automatic fire, harvest, pickup, grass/stone, three zombie recordings, plus retained reload/craft/hurt/unlock/melee cues.
- Day output returns after pause (peak 0.00896) and after unmute (0.00764). Night output returns after pause (0.05936). The final loop also returns after another pause (0.05936).
- Settled pause and mute windows measure peak 0. The maximum observed fixture peak is 0.34718, below full scale. At 132.15 s the context is running and output RMS is 0.00414. Browser errors/warnings: none.
- A test button explicitly suspends the browser context after the sequence. The production enable-sound button reappears; clicking it restores a running context, advancing audio time, and nonzero output.
- The existing rendered native integration passes all **27** assertions, covering actual input/events, spatial ownership, mute, pause/resume, cleanup and rescue audio. Native testing uses Dummy audio and isolated SomchaiAudioQA saves.

See [browser measurements](browser_result.json), [native log](runtime_result.txt), [export result](export_result.txt), and [artifact hashes](build_manifest.json). The probe and instrumentation are excluded from production. Reproduce with the isolated project and `tools/instrument_web_audio_probe.py` under `.godot/web-audio-validation/`.

## Limits

The browser harness available here is the Chromium based Codex in-app browser, not the user's installed Chrome. The previous pack produced menu sound in this harness, so the user's complete silence was not independently reproduced after canvas interaction. The context-suspension recovery is reproduced and verified. Full-world pointer capture returns a Chromium UnknownError in the harness; the audio probe avoids pointer capture. Measured outgoing signal is not a human listening certification or a test of OS/site mute settings.

The upstream [Web Sample pause/loop issue](https://github.com/godotengine/godot/issues/123964) and [pending driver fixes](https://github.com/godotengine/godot/pull/123996) describe additional limitations in Godot 4.7.2. This deployment retains the Sample backend used for single-threaded web playback; it does not import an unreleased engine patch.
