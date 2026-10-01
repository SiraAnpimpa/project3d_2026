# Map Asset Usage — Somchai's Last Harvest

2026-10-01. **69 unique existing GLBs, 709 decorative placements across eight authored zones.** All 243 original GLBs opened/rendered; source hashes unchanged. Coverage is 69/197 = 35.0% of the deliberately broad environment/decor inventory, which also contains many inspected fantasy items and alternative variants. This is not a claim that every candidate fits the rural setting.

## Selection and placement

Farm tools/storage serve the base; trees/rocks shape the forest and ridge; vehicles, containers and debris identify the abandoned depot and road. Seven live tree variants plus two dead-tree models provide silhouettes; bushes/ferns belong to their canopy edges. Grass is sparse at transitions. Repeated stones/logs form authored groups, rather than a uniform grid. Bags/book/scythe/padlock are the few rural-compatible RPG choices. Unused fantasy weapons, coins/crowns/crystals, excess road junctions, redundant tiny variants and military fleet clutter were inspected and omitted after the scene survey.

Most static models batch into 68 MultiMesh nodes. Scale-aware LOD bias prevents small imported models losing visible panels at distance. The one water tower keeps its native imported scene. All 120 playable tree/landmark trunks have simple physical cylinders; canopies, small understorey and visual-only background have no collision. Containers/vehicles/major props use simple static collision. No new rigid bodies, lights or particles.

World shells, gable/porch, workshop, ruined shed, fence fragments, terrain/path color and distant hills are project-authored geometry because the packs have no house/barn/hill/cliff meshes. The twelve plots, bed, bench, retained cover collision and rescue landing keep their gameplay roles. Props in this table are decoration and navigation geometry; supplies/chests/tools do not introduce collecting, storage, healing or tool mechanics.

Inventory: [ENVIRONMENT_ASSET_INVENTORY.md](ENVIRONMENT_ASSET_INVENTORY.md). Machine-readable mapping: [asset_usage.json](docs/map_redesign/asset_usage.json). Audit/contact sheets: [evidence index](docs/map_redesign/README.md).

## Actual asset → zone → purpose

| Original asset | Used zone(s) | Purpose | Placements |
|---|---|---|---|
| Low Poly Military Vehicles-glb/Ambulance Car.glb | Abandoned | Vehicles left at an evacuated rural supply depot | 1 |
| Post Apocolypse Pack.undefined-glb/Barrel.glb | Workshop, Farm | Farm water/material storage off circulation lanes | 2 |
| Stylized Nature MegaKit.undefined-glb/Bush.glb | Abandoned | Understorey along canopy edges and vegetation reclaiming the depot | 4 |
| Stylized Nature MegaKit.undefined-glb/Bush with Flowers.glb | Forest edge, Abandoned | Understorey along canopy edges and vegetation reclaiming the depot | 121 |
| Post Apocolypse Pack.undefined-glb/Chest.glb | Combat, Workshop, House, Road | Grouped materials/supplies and the retained combat cover body | 4 |
| Post Apocolypse Pack.undefined-glb/Chest-RfSBvgcZUD.glb | Combat, Workshop | Grouped materials/supplies and the retained combat cover body | 2 |
| Post Apocolypse Pack.undefined-glb/Cinder Block.glb | Abandoned | Grouped damage, evacuation debris and disused depot utility | 1 |
| Stylized Nature MegaKit.undefined-glb/Clover.glb | Transition | Sparse ground transitions; keep plot, aim and path lanes open | 22 |
| Post Apocolypse Pack.undefined-glb/Container Green.glb | Abandoned | Abandoned depot mass, supply history and screened eastern approach | 1 |
| Post Apocolypse Pack.undefined-glb/Container Red.glb | Abandoned | Abandoned depot mass, supply history and screened eastern approach | 1 |
| Post Apocolypse Pack.undefined-glb/Damaged Couch.glb | Abandoned | Grouped damage, evacuation debris and disused depot utility | 1 |
| Stylized Nature MegaKit.undefined-glb/Dead Tree.glb | Forest | Western woodland/camp silhouette and outbreak neglect | 1 |
| Stylized Nature MegaKit.undefined-glb/Dead Tree-Mcd2zYqyww.glb | Forest | Western woodland/camp silhouette and outbreak neglect | 1 |
| Stylized Nature MegaKit.undefined-glb/Fern.glb | Forest edge | Understorey along canopy edges and vegetation reclaiming the depot | 117 |
| Post Apocolypse Pack.undefined-glb/Fire Hydrant.glb | Abandoned | Grouped damage, evacuation debris and disused depot utility | 1 |
| Stylized Nature MegaKit.undefined-glb/Flower Group.glb | Forest | Small forest clearing detail | 4 |
| Stylized Nature MegaKit.undefined-glb/Grass.glb | Transition | Sparse ground transitions; keep plot, aim and path lanes open | 28 |
| Stylized Nature MegaKit.undefined-glb/Grass Wispy.glb | Transition | Sparse ground transitions; keep plot, aim and path lanes open | 28 |
| Low Poly Military Vehicles-glb/Jeep.glb | Abandoned | Vehicles left at an evacuated rural supply depot | 1 |
| Stylized Nature MegaKit.undefined-glb/Mushroom.glb | Forest | Small forest clearing detail | 4 |
| Post Apocolypse Pack.undefined-glb/Pallet.glb | Workshop | Workshop materials and discarded depot stock | 1 |
| Post Apocolypse Pack.undefined-glb/Pallet Broken.glb | Abandoned | Workshop materials and discarded depot stock | 1 |
| Stylized Nature MegaKit.undefined-glb/Pebble Round.glb | Road | Small roadside stone clusters | 4 |
| Stylized Nature MegaKit.undefined-glb/Pebble Square.glb | Road | Small roadside stone clusters | 4 |
| Stylized Nature MegaKit.undefined-glb/Pine.glb | Forest edge, Background | Authored forest clusters, approach gaps and layered background canopy | 70 |
| Stylized Nature MegaKit.undefined-glb/Pine-699sFuLCN2.glb | Forest edge, Background | Authored forest clusters, approach gaps and layered background canopy | 67 |
| Stylized Nature MegaKit.undefined-glb/Pine-79gmlLnweB.glb | Forest edge, Background | Authored forest clusters, approach gaps and layered background canopy | 63 |
| Post Apocolypse Pack.undefined-glb/Pipes.glb | Abandoned, Drainage | Depot utility debris and dry drainage culvert hint | 2 |
| Ultimate RPG Items Bundle-glb/Bag.glb | Workshop | Bag/lock detail for workshop storage | 1 |
| Ultimate RPG Items Bundle-glb/Book.glb | House | Domestic/survival supplies in and around the shelter | 1 |
| Ultimate RPG Items Bundle-glb/Padlock.glb | Workshop | Bag/lock detail for workshop storage | 1 |
| Ultimate RPG Items Bundle-glb/Scythe.glb | Workshop | Farm/workshop tools, displayed beside their working area | 1 |
| Stylized Nature MegaKit.undefined-glb/Rock Medium.glb | Forest | Ridge/bank mass, natural boundary and approach screening | 1 |
| Stylized Nature MegaKit.undefined-glb/Rock Medium-JQxF95498B.glb | Ridge | Ridge/bank mass, natural boundary and approach screening | 3 |
| Stylized Nature MegaKit.undefined-glb/Rock Medium-s1OJ3bBzqc.glb | Boundary | Ridge/bank mass, natural boundary and approach screening | 5 |
| Stylized Nature MegaKit.undefined-glb/Rock Path Round Wide.glb | Drainage | Two irregular dry-drainage bank stone groups | 2 |
| Stylized Nature MegaKit.undefined-glb/Rock Path Square Thin.glb | Drainage | Two irregular dry-drainage bank stone groups | 2 |
| Post Apocolypse Pack.undefined-glb/Street Light.glb | Road | Existing roadside utility silhouette; no added real light | 1 |
| Post Apocolypse Pack.undefined-glb/Street Straight Crack.glb | Road | One damaged paved gate threshold; dirt road remains dominant | 1 |
| Survival Pack-glb/Axe.glb | Workshop | Farm/workshop tools, displayed beside their working area | 1 |
| Survival Pack-glb/Backpack.glb | House | Domestic/survival supplies in and around the shelter | 1 |
| Survival Pack-glb/Bonfire.glb | Forest | Abandoned forester camp in a woodland clearing | 1 |
| Survival Pack-glb/Can.glb | Forest | Abandoned forester camp in a woodland clearing | 1 |
| Survival Pack-glb/Can Broken.glb | Forest | Abandoned forester camp in a woodland clearing | 1 |
| Survival Pack-glb/First Aid Kit.glb | House | Domestic/survival supplies in and around the shelter | 1 |
| Survival Pack-glb/Gas Can.glb | Workshop, Road | Grouped workshop/road fuel supplies | 2 |
| Survival Pack-glb/Pan.glb | House | Domestic/survival supplies in and around the shelter | 1 |
| Survival Pack-glb/Pot.glb | House | Domestic/survival supplies in and around the shelter | 1 |
| Survival Pack-glb/Propane Tank.glb | Workshop | Grouped workshop/road fuel supplies | 1 |
| Survival Pack-glb/Radio.glb | House | Domestic/survival supplies in and around the shelter | 1 |
| Survival Pack-glb/Shovel.glb | Workshop, Farm | Farm/workshop tools, displayed beside their working area | 2 |
| Survival Pack-glb/Tent.glb | Forest | Abandoned forester camp in a woodland clearing | 1 |
| Survival Pack-glb/Water Bottle.glb | House | Domestic/survival supplies in and around the shelter | 1 |
| Survival Pack-glb/Wood Log.glb | Farm, Forest | Farm wood pile and abandoned forester camp | 6 |
| Stylized Nature MegaKit.undefined-glb/Tall Grass.glb | Transition | Sparse ground transitions; keep plot, aim and path lanes open | 22 |
| Post Apocolypse Pack.undefined-glb/Town Sign.glb | Road | Road gate silhouette and direction toward the wider world | 1 |
| Post Apocolypse Pack.undefined-glb/Traffic Barrier.glb | Abandoned | Broken depot/road access restriction and directional framing | 1 |
| Post Apocolypse Pack.undefined-glb/Traffic Barrier-nugx3heueH.glb | Road | Broken depot/road access restriction and directional framing | 1 |
| Post Apocolypse Pack.undefined-glb/Traffic Cone.glb | Road | Old roadside interruption near the supply truck | 1 |
| Post Apocolypse Pack.undefined-glb/Trash Bag.glb | Abandoned | Grouped damage, evacuation debris and disused depot utility | 1 |
| Post Apocolypse Pack.undefined-glb/Trash Bags.glb | Abandoned | Grouped damage, evacuation debris and disused depot utility | 1 |
| Stylized Nature MegaKit.undefined-glb/Tree.glb | Forest edge, Background | Authored forest clusters, approach gaps and layered background canopy | 21 |
| Stylized Nature MegaKit.undefined-glb/Tree-QVOop92WmG.glb | Forest edge, Background | Authored forest clusters, approach gaps and layered background canopy | 19 |
| Stylized Nature MegaKit.undefined-glb/Tree-aVOxaHRPWe.glb | Forest edge, Background | Authored forest clusters, approach gaps and layered background canopy | 20 |
| Stylized Nature MegaKit.undefined-glb/Tree-qZtx0AHhcy.glb | Forest, Forest edge, Background | Authored forest clusters, approach gaps and layered background canopy | 19 |
| Low Poly Military Vehicles-glb/Truck.glb | Road | Stopped supply truck on rescue road; southern approach screen | 1 |
| Post Apocolypse Pack.undefined-glb/Water Tower.glb | House | 12.5 m farm skyline landmark and utility history | 1 |
| Post Apocolypse Pack.undefined-glb/Wheel.glb | Abandoned | Grouped damage, evacuation debris and disused depot utility | 1 |
| Post Apocolypse Pack.undefined-glb/Wheels Stack.glb | Abandoned | Grouped damage, evacuation debris and disused depot utility | 1 |

Categories among the selected models: Abandoned / survival: 16, Farm / survival: 15, Landmark / background: 3, Other inspected props: 4, Structural / landmark: 4, Terrain: 7, Terrain / road: 2, Vegetation: 18. Category names describe inventory provenance, while zone/purpose describe actual use. Actor/weapon/crop/ending assets retained by existing gameplay are excluded from this environment coverage count.
