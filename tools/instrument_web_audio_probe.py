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
        "this._source.buffer=this.getSample().getAudioBuffer();":
            "this._source.buffer=this.getSample().getAudioBuffer();window.webAudioQA.lastSample={length:this._source.buffer.length,rate:this.getPlaybackRate(),peak:Math.max(...this._source.buffer.getChannelData(0).subarray(0,8192).map(Math.abs))};",
    }
    for old, new in changes.items():
        if text.count(old) < 1:
            raise SystemExit(f"Missing backend hook: {old}")
        text = text.replace(old, new, 1)
    prefix = """window.webAudioQA={pauseTrue:0,pauseFalse:0,restarts:0};
const qaMeters=[];
let qaStage='',qaStageSince=0;
const qaConnect=AudioNode.prototype.connect;
AudioNode.prototype.connect=function(...args){
 const result=qaConnect.apply(this,args);
 if(args[0] instanceof AudioDestinationNode){
  const meter=this.context.createAnalyser(); meter.fftSize=2048;
  qaConnect.call(this,meter); qaMeters.push({meter,values:new Float32Array(2048)});
 }
 return result;
};
document.addEventListener('DOMContentLoaded',()=>{
 const panel=document.createElement('pre'); panel.id='web-audio-qa';
 panel.style.cssText='position:fixed;z-index:99999;top:8px;left:8px;background:#142419;color:white;padding:12px;font:16px monospace;pointer-events:none';
 document.body.appendChild(panel);
 const suspend=document.createElement('button'); suspend.id='suspend-audio-qa';
 suspend.textContent='Suspend browser audio (QA)';
 suspend.style.cssText='position:fixed;z-index:99999;top:8px;right:8px';
 suspend.onclick=()=>{for(const {meter} of qaMeters) meter.context.suspend();};
 document.body.appendChild(suspend);
 setInterval(()=>{
  const outputs=qaMeters.map(({meter,values})=>{
   meter.getFloatTimeDomainData(values);
   let sum=0,peak=0; for(const v of values){sum+=v*v; peak=Math.max(peak,Math.abs(v));}
   window.webAudioQA.maxPeak=Math.max(window.webAudioQA.maxPeak||0,peak);
   if(peak>0) window.webAudioQA.lastSignal=meter.context.currentTime;
   const stage=window.webAudioProbeStage||'game';
   if(stage!==qaStage){qaStage=stage;qaStageSince=performance.now();}
   const stages=window.webAudioQA.stages||(window.webAudioQA.stages={});
   // The analyser retains its previous FFT window briefly after mute/pause.
   if(!['paused','muted'].includes(stage)||performance.now()-qaStageSince>150){
    stages[stage]=Math.max(stages[stage]||0,peak);
   }
   return {state:meter.context.state,time:meter.context.currentTime,rms:Math.sqrt(sum/values.length),peak};
  });
  panel.textContent=JSON.stringify({seconds:window.webAudioProbeElapsed,stage:window.webAudioProbeStage,paused:window.webAudioProbePaused,outputs,...window.webAudioQA},null,2);
 },20);
});
"""
    file.write_text(prefix + text, encoding="utf8")
    print(f"Instrumented test-only sample counters: {folder.name}")


if __name__ == "__main__":
    main()
