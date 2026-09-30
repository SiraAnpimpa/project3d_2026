"""Reproduce the project's original synthetic demo cues. No sampled recordings/music.
Python standard library only; deterministic seed; 22,050 Hz mono PCM16.
"""
import math
from pathlib import Path
import random
import struct
import wave

OUTPUT = Path(__file__).resolve().parents[1] / "assets" / "audio"
OUTPUT.mkdir(parents=True, exist_ok=True)
RATE = 22050
for name, duration, frequency in [
    ("shot", .16, 90), ("reload", .3, 180), ("click", .07, 600),
    ("harvest", .22, 760), ("craft", .28, 900), ("hurt", .15, 120),
    ("unlock", .42, 620), ("rotor", 4, 42), ("wind", 4, 0),
]:
    rng = random.Random(92)
    samples = []
    low = 0.0
    for index in range(int(RATE * duration)):
        t = index / RATE
        noise = rng.uniform(-1, 1)
        low = low * .96 + noise * .04
        envelope = min(1, t / .005) * (1 - t / duration) ** 2
        if name == "wind":
            value = low * .6
        elif name == "rotor":
            value = (.12 * math.sin(math.tau * frequency * t) + low) * (.5 + .5 * math.sin(math.tau * 12 * t))
        elif name in ["shot", "hurt", "reload"]:
            value = (.35 * noise + .35 * math.sin(math.tau * frequency * t)) * envelope
        else:
            value = .4 * math.sin(math.tau * (frequency * t + 150 * t * t)) * envelope
        # Short fades suppress boundary clicks in repeating ambience.
        value *= min(1, t / .01, (duration - t) / .02)
        samples.append(struct.pack("<h", int(max(-1, min(1, value)) * 32767)))
    with wave.open(str(OUTPUT / (name + ".wav")), "wb") as stream:
        stream.setparams((1, 2, RATE, len(samples), "NONE", "not compressed"))
        stream.writeframes(b"".join(samples))
