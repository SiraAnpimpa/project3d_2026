# Asset audit - v0.1.0-demo

## Major map pass asset usage

The new environment uses69 models from the existing five packs; exact paths/counts/purposes are in MAP_ASSET_USAGE.md and docs/map_redesign/asset_usage.json. The original243 GLBs remain unchanged. Terrain, shells, fence fragments, path/ground color and background hills are authored within this project; no new downloaded/AI bitmap assets. Existing provenance/license status below is retained.

## Refinement pass1 scenery reuse

Additional existing files used without modification: `Asset/Post Apocolypse Pack.undefined-glb/{Chest,Barrel,Pallet,Traffic Barrier}.glb`; `Asset/Stylized Nature MegaKit.undefined-glb/{Pine,Rock Medium}.glb`; `Asset/Survival Pack-glb/Shovel.glb`. Author/source/license metadata is still unavailable, as for the historical packs below. New ground/fence/porch geometry and pose/UI code are project work. No external art or animation downloads.

Audit of runtime dependencies, 2026-09-30. No new third-party art/audio downloaded during final QA. Original filenames are recorded without inferring creator, source website or license.

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

Only referenced models are selected for export; the full unused asset library is retained in source. Pack license/readme searches found no supplied permission statements. Project-created work is not assigned an invented public license by this audit. Obtain original asset license files/source receipts and confirm distribution terms before public distribution/submission requiring those rights.

Runtime: Godot 4.7.2 official Windows release template, obtained from godotengine/godot-builds GitHub release. Godot is provided separately under its own license; retain engine attribution/license text supplied with the build process where applicable. No code-signing certificate is configured.

Engine license and third-party notices from the matching official 4.7.2-stable source tag are included in docs/phase10/GODOT_LICENSE.txt and GODOT_COPYRIGHT.txt and copied into the candidate folder. Godot uses the MIT license; these files retain the full notices.

## UI/UX polish assets — 2026-10-02

FREE version/Icon set1 is supplied by the user.14 light symbols and its white button graphic are referenced unchanged; source/author/license text is not included in the folder. Exact sources: UI_ICON_MAPPING.md / docs/ui_polish/free_asset_inventory.json. The importer resizes only the button texture to32px. Existing item SVGs are retained. New clock/rifle/basic-cartridge vectors and UI code are project work; no external image generation/download. Menu background is an unchanged copy of the existing project farmstead capture and has the same underlying environment provenance. Godot’s bundled font remains in use. No public license is invented for these additions.
