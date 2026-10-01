# Map Asset Usage — current beautification pass

2026-10-01. **70 unique environment models /11,725 instances:** 69 from the original inspected packs plus supplied Cabin.glb. Ground-cover instances are 11,019; other placed model instances total 706. The existing ending helicopter/player/crops are outside this decorative placement count. All 244 source GLBs remain identical.

Most scenery retains 68 MultiMesh mesh batches. Cabin and water tower retain native scenes; Cabin has 221 mesh parts. 116 playable tree trunks collide, understorey/background do not. Major structures/stock/rocks use static collision; no new lights, particles or rigid bodies. Source grass colours use duplicate instance materials. Existing five lights are repositioned with the composition.

Farmstead/home/workshop/forest/depot/road/landing/boundary relationships guide placement. Open cultivated/yard/combat/landing space is deliberate; clusters serve a place or path. Items remain decorative and introduce no gameplay mechanics.

[Report](MAP_BEAUTIFICATION_REPORT.md), [current counts by zone](docs/map_beautification/asset_usage.json), [original pack inventory plus supplied Cabin note](ENVIRONMENT_ASSET_INVENTORY.md). The previous pass's 69-model/709-instance table is preserved in [prior_MAP_ASSET_USAGE.md](docs/map_beautification/prior_MAP_ASSET_USAGE.md).

## Actual asset → zone → purpose

| Source asset | Zone(s) | Purpose | Instances |
|---|---|---|---|
| Asset/Low Poly Military Vehicles-glb/Ambulance Car.glb | Abandoned | Evacuated supply depot masses on a common foundation | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Barrel.glb | Workshop | Grouped utility tools/stock behind or beside the work shelter | 2 |
| Asset/Stylized Nature MegaKit.undefined-glb/Bush.glb | Abandoned | Understorey at tree/rock edges and vegetation reclaiming the depot | 4 |
| Asset/Stylized Nature MegaKit.undefined-glb/Bush with Flowers.glb | Ridge, Forest, Boundary, Forest edge, Abandoned, Road shoulder | Understorey at tree/rock edges and vegetation reclaiming the depot | 127 |
| Asset/Cabin.glb | House | Furnished farm home; static accessible entry and rest room | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Chest.glb | Workshop, House, Road | Grouped utility tools/stock behind or beside the work shelter | 4 |
| Asset/Post Apocolypse Pack.undefined-glb/Chest-RfSBvgcZUD.glb | Workshop | Grouped utility tools/stock behind or beside the work shelter | 2 |
| Asset/Post Apocolypse Pack.undefined-glb/Cinder Block.glb | Abandoned | Grouped depot damage, discarded materials and evacuation debris | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Clover.glb | Rock edge, Forest floor, Meadow, Yard edge, Combat edge, Wilderness | Varied ground-cover patches; paths, working soil and landing kept open | 1,084 |
| Asset/Post Apocolypse Pack.undefined-glb/Container Green.glb | Abandoned | Evacuated supply depot masses on a common foundation | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Container Red.glb | Abandoned | Evacuated supply depot masses on a common foundation | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Damaged Couch.glb | Abandoned | Grouped depot damage, discarded materials and evacuation debris | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Dead Tree.glb | Forest | Canopy clusters, remembered landmarks, route openings and background depth | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Dead Tree-Mcd2zYqyww.glb | Forest | Canopy clusters, remembered landmarks, route openings and background depth | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Fern.glb | Ridge, Forest, Boundary, Forest edge, Road shoulder | Understorey at tree/rock edges and vegetation reclaiming the depot | 123 |
| Asset/Post Apocolypse Pack.undefined-glb/Fire Hydrant.glb | Abandoned | Grouped depot damage, discarded materials and evacuation debris | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Flower Group.glb | Forest | Small camp/forest detail attached to an authored place | 4 |
| Asset/Stylized Nature MegaKit.undefined-glb/Grass.glb | Rock edge, Forest floor, Meadow, Yard edge, Combat edge, Wilderness | Varied ground-cover patches; paths, working soil and landing kept open | 6,742 |
| Asset/Stylized Nature MegaKit.undefined-glb/Grass Wispy.glb | Rock edge, Forest floor, Meadow, Yard edge, Combat edge, Wilderness | Varied ground-cover patches; paths, working soil and landing kept open | 1,063 |
| Asset/Low Poly Military Vehicles-glb/Jeep.glb | Abandoned | Evacuated supply depot masses on a common foundation | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Mushroom.glb | Forest | Small camp/forest detail attached to an authored place | 4 |
| Asset/Post Apocolypse Pack.undefined-glb/Pallet.glb | Workshop | Grouped utility tools/stock behind or beside the work shelter | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Pallet Broken.glb | Abandoned | Grouped depot damage, discarded materials and evacuation debris | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Pebble Round.glb | Ridge, Forest, Boundary, Road, Road shoulder | Embedded rock groups, terrain transitions and drainage/roadside detail | 24 |
| Asset/Stylized Nature MegaKit.undefined-glb/Pebble Square.glb | Ridge, Forest, Boundary, Road, Road shoulder | Embedded rock groups, terrain transitions and drainage/roadside detail | 34 |
| Asset/Stylized Nature MegaKit.undefined-glb/Pine.glb | Forest edge, Background | Canopy clusters, remembered landmarks, route openings and background depth | 73 |
| Asset/Stylized Nature MegaKit.undefined-glb/Pine-699sFuLCN2.glb | Forest edge, Background | Canopy clusters, remembered landmarks, route openings and background depth | 65 |
| Asset/Stylized Nature MegaKit.undefined-glb/Pine-79gmlLnweB.glb | Forest edge, Background | Canopy clusters, remembered landmarks, route openings and background depth | 60 |
| Asset/Post Apocolypse Pack.undefined-glb/Pipes.glb | Abandoned, Drainage | Grouped depot damage, discarded materials and evacuation debris | 2 |
| Asset/Ultimate RPG Items Bundle-glb/Bag.glb | Workshop | Grouped utility tools/stock behind or beside the work shelter | 1 |
| Asset/Ultimate RPG Items Bundle-glb/Book.glb | House | Domestic cache in the furnished home, clear of the rest lane | 1 |
| Asset/Ultimate RPG Items Bundle-glb/Padlock.glb | Workshop | Grouped utility tools/stock behind or beside the work shelter | 1 |
| Asset/Ultimate RPG Items Bundle-glb/Scythe.glb | Workshop | Grouped utility tools/stock behind or beside the work shelter | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Rock Medium.glb | Ridge, Forest, Boundary, Road shoulder | Embedded rock groups, terrain transitions and drainage/roadside detail | 12 |
| Asset/Stylized Nature MegaKit.undefined-glb/Rock Medium-JQxF95498B.glb | Ridge | Embedded rock groups, terrain transitions and drainage/roadside detail | 3 |
| Asset/Stylized Nature MegaKit.undefined-glb/Rock Medium-s1OJ3bBzqc.glb | Ridge, Forest, Boundary, Road shoulder | Embedded rock groups, terrain transitions and drainage/roadside detail | 25 |
| Asset/Stylized Nature MegaKit.undefined-glb/Rock Path Round Wide.glb | Drainage | Embedded rock groups, terrain transitions and drainage/roadside detail | 2 |
| Asset/Stylized Nature MegaKit.undefined-glb/Rock Path Square Thin.glb | Drainage | Embedded rock groups, terrain transitions and drainage/roadside detail | 2 |
| Asset/Post Apocolypse Pack.undefined-glb/Street Light.glb | Road | Checkpoint/road history and readable approach outside landing clearance | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Street Straight Crack.glb | Road | Checkpoint/road history and readable approach outside landing clearance | 1 |
| Asset/Survival Pack-glb/Axe.glb | Workshop | Grouped utility tools/stock behind or beside the work shelter | 1 |
| Asset/Survival Pack-glb/Backpack.glb | House | Domestic cache in the furnished home, clear of the rest lane | 1 |
| Asset/Survival Pack-glb/Bonfire.glb | Forest | Small camp/forest detail attached to an authored place | 1 |
| Asset/Survival Pack-glb/Can.glb | Forest | Small camp/forest detail attached to an authored place | 1 |
| Asset/Survival Pack-glb/Can Broken.glb | Forest | Small camp/forest detail attached to an authored place | 1 |
| Asset/Survival Pack-glb/First Aid Kit.glb | House, Rescue | Domestic cache in the furnished home, clear of the rest lane | 2 |
| Asset/Survival Pack-glb/Gas Can.glb | Workshop, Road | Grouped utility tools/stock behind or beside the work shelter | 2 |
| Asset/Survival Pack-glb/Pan.glb | Workshop | Grouped utility tools/stock behind or beside the work shelter | 1 |
| Asset/Survival Pack-glb/Pot.glb | Workshop | Grouped utility tools/stock behind or beside the work shelter | 1 |
| Asset/Survival Pack-glb/Propane Tank.glb | Workshop | Grouped utility tools/stock behind or beside the work shelter | 1 |
| Asset/Survival Pack-glb/Radio.glb | House, Rescue | Domestic cache in the furnished home, clear of the rest lane | 2 |
| Asset/Survival Pack-glb/Shovel.glb | Workshop, Farm | Grouped utility tools/stock behind or beside the work shelter | 2 |
| Asset/Survival Pack-glb/Tent.glb | Forest | Forester camp in a separate forest clearing | 1 |
| Asset/Survival Pack-glb/Water Bottle.glb | House | Domestic cache in the furnished home, clear of the rest lane | 1 |
| Asset/Survival Pack-glb/Wood Log.glb | Workshop, Forest | Grouped utility tools/stock behind or beside the work shelter | 6 |
| Asset/Stylized Nature MegaKit.undefined-glb/Tall Grass.glb | Rock edge, Forest floor, Meadow, Yard edge, Combat edge, Wilderness | Varied ground-cover patches; paths, working soil and landing kept open | 2,130 |
| Asset/Post Apocolypse Pack.undefined-glb/Town Sign.glb | Road | Checkpoint/road history and readable approach outside landing clearance | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Traffic Barrier.glb | Abandoned | Checkpoint/road history and readable approach outside landing clearance | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Traffic Barrier-nugx3heueH.glb | Road | Checkpoint/road history and readable approach outside landing clearance | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Traffic Cone.glb | Road, Rescue | Checkpoint/road history and readable approach outside landing clearance | 5 |
| Asset/Post Apocolypse Pack.undefined-glb/Trash Bag.glb | Abandoned | Grouped depot damage, discarded materials and evacuation debris | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Trash Bags.glb | Abandoned | Grouped depot damage, discarded materials and evacuation debris | 1 |
| Asset/Stylized Nature MegaKit.undefined-glb/Tree.glb | Forest edge, Background | Canopy clusters, remembered landmarks, route openings and background depth | 21 |
| Asset/Stylized Nature MegaKit.undefined-glb/Tree-QVOop92WmG.glb | Forest edge, Background | Canopy clusters, remembered landmarks, route openings and background depth | 17 |
| Asset/Stylized Nature MegaKit.undefined-glb/Tree-aVOxaHRPWe.glb | Forest edge, Background | Canopy clusters, remembered landmarks, route openings and background depth | 20 |
| Asset/Stylized Nature MegaKit.undefined-glb/Tree-qZtx0AHhcy.glb | Forest, Forest edge, Background | Canopy clusters, remembered landmarks, route openings and background depth | 20 |
| Asset/Low Poly Military Vehicles-glb/Truck.glb | Road | Checkpoint/road history and readable approach outside landing clearance | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Water Tower.glb | House | Farm utility landmark on a blended level foundation | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Wheel.glb | Abandoned | Grouped depot damage, discarded materials and evacuation debris | 1 |
| Asset/Post Apocolypse Pack.undefined-glb/Wheels Stack.glb | Abandoned | Grouped depot damage, discarded materials and evacuation debris | 1 |
