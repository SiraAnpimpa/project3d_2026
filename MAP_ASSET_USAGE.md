# Map Asset Usage — Final Environment Cleanup

2026-10-01. **56 unique decorative models /11,707 placements:** 11,019 unchanged grass tufts and 688 other placements. All 244 source GLBs remain hash-identical. Procedural frames/workbench meshes, gameplay actors/crops and the ending helicopter are outside this placement count.

54 MultiMesh mesh batches; Cabin/water tower retain native scenes. Cabin has 221 native mesh parts. 116 playable trunks collide; grass/understorey/background do not. Existing five lights remain. Props are decoration; no new gameplay mechanics.

Remove 18 model placements and 14 unused preloads; curate home/work/rescue caches, ground stacked supplies and lean tools. Major zones and interaction anchors stay fixed. [Report](MAP_FINAL_CLEANUP_REPORT.md), [runtime usage](docs/map_final_cleanup/usage.json), [metrics](docs/map_final_cleanup/metrics.json). The prior 70-model /11,725-placement table is preserved in [prior_MAP_ASSET_USAGE.md](docs/map_final_cleanup/prior_MAP_ASSET_USAGE.md).

## Actual asset → zone → purpose

| Source asset | Zone(s), count | Purpose | Instances |
|---|---|---|---:|
| Asset/Low Poly Military Vehicles-glb/Ambulance Car.glb | Abandoned (1) | Evacuated supply depot masses on a common foundation | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Barrel.glb | Workshop (2) | Grouped utility tools/stock behind or beside the work shelter | 2 |
| Asset/Stylized Nature MegaKit.undefined-glb/Bush.glb | Abandoned (4) | Understorey at tree/rock edges and vegetation reclaiming the depot | 4 |
| Asset/Stylized Nature MegaKit.undefined-glb/Bush with Flowers.glb | Abandoned (4), Boundary (5), Forest (1), Forest edge (113), Ridge (3), Road shoulder (1) | Understorey at tree/rock edges and vegetation reclaiming the depot | 127 |
| Asset/Cabin.glb | House (1) | Furnished main home; copied exterior tones, open entry and rest room | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Chest.glb | House (1), Road (1), Workshop (2) | Grouped domestic/evacuation caches and utility stock; measured stacking | 4 |
| Asset/Post Apocolypse Pack.undefined-glb/Chest-RfSBvgcZUD.glb | Workshop (2) | Workshop tool box /supported upper utility stock | 2 |
| Asset/Post Apocolypse Pack.undefined-glb/Cinder Block.glb | Abandoned (1) | Grouped depot damage, discarded materials and evacuation debris | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Clover.glb | Combat edge (41), Forest floor (554), Meadow (334), Rock edge (39), Wilderness (97), Yard edge (19) | Varied ground-cover patches; paths, working soil and landing kept open | 1,084 |
| Asset/Post Apocolypse Pack.undefined-glb/Container Green.glb | Abandoned (1) | Evacuated supply depot masses on a common foundation | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Container Red.glb | Abandoned (1) | Evacuated supply depot masses on a common foundation | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Damaged Couch.glb | Abandoned (1) | Grouped depot damage, discarded materials and evacuation debris | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Dead Tree.glb | Forest (1) | Canopy clusters, remembered landmarks, route openings and background depth | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Dead Tree-Mcd2zYqyww.glb | Forest (1) | Canopy clusters, remembered landmarks, route openings and background depth | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Fern.glb | Boundary (5), Forest (1), Forest edge (113), Ridge (3), Road shoulder (1) | Understorey at tree/rock edges and vegetation reclaiming the depot | 123 |
| Asset/Post Apocolypse Pack.undefined-glb/Fire Hydrant.glb | Abandoned (1) | Grouped depot damage, discarded materials and evacuation debris | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Flower Group.glb | Forest (4) | Small camp/forest detail attached to an authored place | 4 |
| Asset/Stylized Nature MegaKit.undefined-glb/Grass.glb | Combat edge (211), Forest floor (3522), Meadow (2026), Rock edge (276), Wilderness (596), Yard edge (111) | Varied ground-cover patches; paths, working soil and landing kept open | 6,742 |
| Asset/Stylized Nature MegaKit.undefined-glb/Grass Wispy.glb | Combat edge (37), Forest floor (518), Meadow (351), Rock edge (34), Wilderness (102), Yard edge (21) | Varied ground-cover patches; paths, working soil and landing kept open | 1,063 |
| Asset/Low Poly Military Vehicles-glb/Jeep.glb | Abandoned (1) | Evacuated supply depot masses on a common foundation | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Mushroom.glb | Forest (4) | Small camp/forest detail attached to an authored place | 4 |
| Asset/Post Apocolypse Pack.undefined-glb/Pallet.glb | Workshop (1) | Grouped utility tools/stock behind or beside the work shelter | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Pallet Broken.glb | Abandoned (1) | Grouped depot damage, discarded materials and evacuation debris | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Pebble Round.glb | Boundary (10), Forest (2), Ridge (6), Road (4), Road shoulder (2) | Embedded rock groups, terrain transitions and drainage/roadside detail | 24 |
| Asset/Stylized Nature MegaKit.undefined-glb/Pebble Square.glb | Boundary (15), Forest (3), Ridge (9), Road (4), Road shoulder (3) | Embedded rock groups, terrain transitions and drainage/roadside detail | 34 |
| Asset/Stylized Nature MegaKit.undefined-glb/Pine.glb | Background (48), Forest edge (25) | Canopy clusters, remembered landmarks, route openings and background depth | 73 |
| Asset/Stylized Nature MegaKit.undefined-glb/Pine-699sFuLCN2.glb | Background (40), Forest edge (25) | Canopy clusters, remembered landmarks, route openings and background depth | 65 |
| Asset/Stylized Nature MegaKit.undefined-glb/Pine-79gmlLnweB.glb | Background (38), Forest edge (22) | Canopy clusters, remembered landmarks, route openings and background depth | 60 |
| Asset/Post Apocolypse Pack.undefined-glb/Pipes.glb | Abandoned (1) | Grouped abandoned depot material; detached drainage bundle removed | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Rock Medium.glb | Boundary (5), Forest (2), Ridge (3), Road shoulder (2) | Embedded rock groups, terrain transitions and drainage/roadside detail | 12 |
| Asset/Stylized Nature MegaKit.undefined-glb/Rock Medium-JQxF95498B.glb | Ridge (3) | Embedded rock groups, terrain transitions and drainage/roadside detail | 3 |
| Asset/Stylized Nature MegaKit.undefined-glb/Rock Medium-s1OJ3bBzqc.glb | Boundary (15), Forest (2), Ridge (6), Road shoulder (2) | Embedded rock groups, terrain transitions and drainage/roadside detail | 25 |
| Asset/Survival Pack-glb/Axe.glb | Workshop (1) | Grounded wall-leaning workshop tool | 1 |
| Asset/Survival Pack-glb/Bonfire.glb | Forest (1) | Small camp/forest detail attached to an authored place | 1 |
| Asset/Survival Pack-glb/Can.glb | Forest (1) | Small camp/forest detail attached to an authored place | 1 |
| Asset/Survival Pack-glb/Can Broken.glb | Forest (1) | Small camp/forest detail attached to an authored place | 1 |
| Asset/Survival Pack-glb/First Aid Kit.glb | House (1), Rescue (1) | Home /evacuation aid on measured chest tops | 2 |
| Asset/Survival Pack-glb/Gas Can.glb | Road (1), Workshop (1) | Grounded workshop /truck fuel supply | 2 |
| Asset/Survival Pack-glb/Propane Tank.glb | Workshop (1) | Grouped utility tools/stock behind or beside the work shelter | 1 |
| Asset/Survival Pack-glb/Radio.glb | House (1), Rescue (1) | Home and evacuation radio on measured chest tops | 2 |
| Asset/Survival Pack-glb/Shovel.glb | Farm (1), Workshop (1) | Grounded farming tool and wall-leaning workshop tool | 2 |
| Asset/Survival Pack-glb/Tent.glb | Forest (1) | Forester camp in a separate forest clearing | 1 |
| Asset/Survival Pack-glb/Wood Log.glb | Forest (1), Workshop (5) | Supported workshop stack and sparse forest camp seating | 6 |
| Asset/Stylized Nature MegaKit.undefined-glb/Tall Grass.glb | Combat edge (63), Forest floor (1068), Meadow (695), Rock edge (76), Wilderness (195), Yard edge (33) | Varied ground-cover patches; paths, working soil and landing kept open | 2,130 |
| Asset/Post Apocolypse Pack.undefined-glb/Traffic Barrier.glb | Abandoned (1) | Retained damaged depot material; landing checkpoint removed | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Traffic Cone.glb | Rescue (4) | Four sparse landing-edge markers outside rotor clearance | 4 |
| Asset/Post Apocolypse Pack.undefined-glb/Trash Bag.glb | Abandoned (1) | Grouped depot damage, discarded materials and evacuation debris | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Trash Bags.glb | Abandoned (1) | Grouped depot damage, discarded materials and evacuation debris | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Tree.glb | Background (9), Forest edge (12) | Canopy clusters, remembered landmarks, route openings and background depth | 21 |
| Asset/Stylized Nature MegaKit.undefined-glb/Tree-QVOop92WmG.glb | Background (9), Forest edge (8) | Canopy clusters, remembered landmarks, route openings and background depth | 17 |
| Asset/Stylized Nature MegaKit.undefined-glb/Tree-aVOxaHRPWe.glb | Background (9), Forest edge (11) | Canopy clusters, remembered landmarks, route openings and background depth | 20 |
| Asset/Stylized Nature MegaKit.undefined-glb/Tree-qZtx0AHhcy.glb | Background (9), Forest (1), Forest edge (10) | Canopy clusters, remembered landmarks, route openings and background depth | 20 |
| Asset/Low Poly Military Vehicles-glb/Truck.glb | Road (1) | Stopped evacuation supply vehicle beside open dirt landing clearing | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Water Tower.glb | House (1) | Farm utility landmark on a blended level foundation | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Wheel.glb | Abandoned (1) | Grouped depot damage, discarded materials and evacuation debris | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Wheels Stack.glb | Abandoned (1) | Grouped depot damage, discarded materials and evacuation debris | 1 |

**TOTAL: 56 sources /11,707 placed model instances.**

Terrain/vegetation generation, four existing grass variants, source dimensions and source materials remain unchanged. Only instance material copies and specific placed decoration transforms change. [Scope audit](docs/map_final_cleanup/scope_audit.json) verifies original assets/core files. Earlier inventory/report evidence remains in docs/map_beautification and docs/map_redesign.
