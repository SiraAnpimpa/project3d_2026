"""Test-only counters for the exported Godot web sample backend.

Never run on docs/ or a production build. Instrument the isolated probe export.
"""
import argparse
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("directory", type=Path)
    args = parser.parse_args()
    folder = args.directory.resolve()
    root = Path(__file__).resolve().parents[1]
    if not folder.is_relative_to(root / ".godot" / "web-audio-validation"):
        raise SystemExit("Refusing to instrument outside the isolated probe export.")
    file = folder / "index.js"
    text = file.read_text(encoding="utf8")
    if "window.webAudioQA=" in text:
        raise SystemExit("Probe is already instrumented; use a fresh export.")
    changes = {
        "sample_set_pause:function(playbackObjectId,pause){":
            "sample_set_pause:function(playbackObjectId,pause){window.webAudioQA[pause?'pauseTrue':'pauseFalse']++;",
        "_restart(){": "_restart(){window.webAudioQA.restarts++;",
    }
    for old, new in changes.items():
        if text.count(old) != 1:
            raise SystemExit(f"Expected exactly one backend hook: {old}")
        text = text.replace(old, new, 1)
    prefix = """window.webAudioQA={pauseTrue:0,pauseFalse:0,restarts:0};
document.addEventListener('DOMContentLoaded',()=>{
 const panel=document.createElement('pre'); panel.id='web-audio-qa';
 panel.style.cssText='position:fixed;z-index:99999;top:8px;left:8px;background:#142419;color:white;padding:12px;font:16px monospace;pointer-events:none';
 document.body.appendChild(panel);
 setInterval(()=>{panel.textContent=JSON.stringify({seconds:window.webAudioProbeElapsed,paused:window.webAudioProbePaused,...window.webAudioQA},null,2)},200);
});
"""
    file.write_text(prefix + text, encoding="utf8")
    print(f"Instrumented test-only sample counters: {folder.name}")


if __name__ == "__main__":
    main()
