# Asset credits — Somchai’s Last Harvest

## Supplied models and UI

Model packs are supplied under `Asset/`. Their creator, original source URL and license terms are not included in the project files; the filenames below identify local sources only. No public license is inferred for these assets.

| Used asset | Local source | License | Attribution requirement |
|---|---|---|---|
| Somchai / Matt | Asset/Post Apocolypse Pack.undefined-glb/Characters Matt.glb | License information not found in project files. | Unknown |
| Normal/Runner/Tank shared model | Asset/Post Apocolypse Pack.undefined-glb/Zombie.glb | License information not found in project files. | Unknown |
| Rifle | Asset/Post Apocolypse Pack.undefined-glb/Rifle.glb | License information not found in project files. | Unknown |
| Crop base model | Asset/Stylized Nature MegaKit.undefined-glb/Plant.glb | License information not found in project files. | Unknown |
| Rescue helicopter | Asset/Low Poly Military Vehicles-glb/Helicopter.glb | License information not found in project files. | Unknown |
| Menu landscape and item SVGs | assets/ui | Created within this project | No external attribution requirement identified |
| Procedural WAV effects and ambience | assets/audio; tools/generate_demo_audio.py | Generated within this project, no sampled audio | No external attribution requirement identified |
| World primitives / navigation | scenes/world; scripts/world; resources/navigation | Created within this project | No external attribution requirement identified |

Environment scenery also uses the supplied Stylized Nature MegaKit, Post Apocolypse, Survival, military vehicle and RPG item packs. Weapons include `Wooden Bat Barbed.glb`; character animation uses the supplied Matt clips. Source GLBs are retained in `Asset/`.

Shared UI symbols and button imagery come from the supplied `FREE version` icon folders. Creator and license metadata for this pack are also unavailable in the project. Obtain the original license files or source receipts to establish distribution and attribution terms for supplied packs.

## Project-authored work

- Transparent item illustrations: `assets/ui/items/`, generated from editable source in `tools/build_ui_item_icons.py`.
- Clock, selection and slider vectors: `assets/ui/icons/`.
- Menu background: a native game capture of the farm environment; underlying models retain their original provenance.
- Terrain, shaders, structural geometry, navigation, UI and procedural animation/placement code: authored within this project.
- Procedural audio: `assets/audio/`, generated without external samples by `tools/generate_demo_audio.py`. See [audio provenance](assets/audio/README.md).

Project-created work is not assigned a public license by this document.

## Engine

Godot uses the MIT license. Engine and third-party notices are retained in [GODOT_LICENSE.txt](docs/phase10/GODOT_LICENSE.txt) and [GODOT_COPYRIGHT.txt](docs/phase10/GODOT_COPYRIGHT.txt). The UI uses Godot’s bundled font.
