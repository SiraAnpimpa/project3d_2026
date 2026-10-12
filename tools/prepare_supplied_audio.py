"""Prepare short gameplay cues from supplied recordings; originals stay intact.

Requires numpy and soundfile. Run from the project root with Python 3.
"""
from pathlib import Path
import hashlib
import json

import numpy as np
import soundfile as sf

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "Asset/game_sounds"
OUTPUT = ROOT / "assets/audio/supplied"
# Short selections avoid firing several recorded shots or playing an entire
# walking/vocal sequence after one event. Times refer to the original MP3.
SELECTIONS = {
    "click": ("ui/เสียงกด.mp3", 0.0, 0.18),
    "shot": ("ยิงปืน/ยิงทีละนัด.mp3", 0.45, 1.05),
    "shot_auto": ("ยิงปืน/รัว.mp3", 0.03, 0.19),
    "harvest": ("เก็บของ/เก็บผัก.mp3", 0.04, 0.74),
    "pickup": ("เก็บของ/เก็บไอเทมอื่นๆ.mp3", 0.165, 0.355),
    "step_grass": ("เดิน/เดินเหยียบหญ้า.mp3", 1.35, 1.70),
    "step_stone": ("เดิน/เดินเหยียบพื้นหิน.mp3", 0.06, 0.41),
    "zombie_normal": ("ซอมบี้/zombie1.mp3", 0.04, 1.94),
    "zombie_runner": ("ซอมบี้/zombie2.mp3", 0.0, 2.50),
    "zombie_tank": ("ซอมบี้/zombie3.mp3", 1.27, 1.97),
}


def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    rows = []
    for name, (relative, start, end) in SELECTIONS.items():
        source = SOURCE / relative
        data, rate = sf.read(source, always_2d=True)
        cue = data[round(start * rate):round(end * rate)].mean(axis=1)
        # Bound peaks consistently. Never raise a peak above -3 dBFS.
        cue *= min(12.0, 10 ** (-3 / 20) / max(float(np.abs(cue).max()), 1e-8))
        fade = min(round(rate * 0.006), len(cue) // 4)
        cue[:fade] *= np.linspace(0, 1, fade)
        cue[-fade:] *= np.linspace(1, 0, fade)
        sf.write(OUTPUT / f"{name}.wav", cue, rate, subtype="PCM_16")
        rows.append({"cue": name, "source": source.relative_to(ROOT).as_posix(),
                     "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
                     "selection_seconds": [start, end], "duration": round(len(cue) / rate, 4),
                     "sample_rate": rate, "channels": 1,
                     "peak_dbfs": round(float(20 * np.log10(max(float(np.abs(cue).max()), 1e-8))), 2)})
    (OUTPUT / "mapping.json").write_text(json.dumps(rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Prepared {len(rows)} mono cues; original MP3 files unchanged.")


if __name__ == "__main__":
    main()
