# Somchai's Last Harvest

**v0.1.0-demo** - a third-person farming and survival shooter built with Godot4.7.2 / Compatibility.

Grow supplies during the day, craft ammunition, survive ten nights of zombies and reach the rescue helicopter on the morning of Day11.

## Run the Windows candidate

Open `release/SomchaisLastHarvest_v0.1.0_demo/SomchaisLastHarvest.exe`. Keep the `.pck` beside it. The release folder and ZIP are local build artifacts, excluded from Git. The source repository contains the export preset and reproducible QA tooling.

Main Menu offers Play, How To Play and Quit. Pause provides Resume, guide, Restart and Main Menu. There is no save: restarting or closing loses the current campaign.

## Play

1. Select Lead/Paper/Copper seeds with the mouse wheel and press E at empty plots.
2. Harvest ready crops, go to Workbench, then craft Basic Ammo.
3. Q switches to Combat. R reloads, hold RMB to aim and LMB to fire.
4. Prepare before18:00; move away from attackers while reloading. Clear the wave and use the shelter bed for full recovery, or survive to dawn without healing.
5. Survive Night10 to see rescue, then Play Again or return to Main Menu.

WASD moves, Shift sprints, Tab opens inventory, Esc closes the current panel/pauses, V changes shoulder. See [CONTROLS.md](CONTROLS.md).

Only Basic Rifle/Basic Ammo is usable. Medicine and elemental ammo are craft-only. Crops/recipes unlock on Days3/5/7; daily basic seed supplies grow with the difficulty curve. See [FINAL_BALANCE.md](FINAL_BALANCE.md).

## Source and export

Import `project.godot` into Godot4.7.2, then F5. Install the matching Windows x86_64 export templates. Export the **Windows Desktop** release preset. Runtime needs no Godot editor installation. Tested on Windows with i5-9300H and RTX2060; minimum hardware and other operating systems are not certified.

```powershell
./tests/run_tests.ps1 -Godot 'PATH_TO_GODOT_CONSOLE.exe' -WithRendering
# Optional sustained campaign and profiling:
./tests/run_tests.ps1 -Godot 'PATH_TO_GODOT_CONSOLE.exe' -WithCampaign -WithProfiling
python tools/export_qa.py 'PATH_TO_GODOT_CONSOLE.exe' campaign
```

`export_qa.py` creates an isolated release-template QA entry scene and restores project settings in `finally`. Gameplay resources match the candidate; normal release excludes test scripts and uses Main Menu. QA variants are not the submission build. The release executable does not support the editor's `--script` switch.

## Delivery notes

[FINAL_QA_REPORT.md](FINAL_QA_REPORT.md) records results and test boundaries. [KNOWN_ISSUES.md](KNOWN_ISSUES.md) lists actual limitations. [ASSET_CREDITS.md](ASSET_CREDITS.md) records asset provenance and missing pack licenses. Godot engine license/notices are bundled. Confirm the original GLB pack distribution rights before publishing or submitting where those rights are required. Team member information was not supplied and is not invented.
