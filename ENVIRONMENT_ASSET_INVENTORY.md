# Environment Asset Inventory — Major Map Redesign

## Current: Final environment cleanup

The complete source inventory remains 244 GLBs: 243 original pack models plus supplied Cabin.glb. All match their pre-cleanup hashes. Current map uses 56 unique decorative sources /11,707 placements; 14 removed preloads stay available in the original inventory. Native Cabin has 221 mesh parts; selected exterior materials are copied at runtime. [Current selection](MAP_ASSET_USAGE.md), [source verification](docs/map_final_cleanup/scope_audit.json), [report](MAP_FINAL_CLEANUP_REPORT.md). Earlier tables are inventories of their original phase, not current placement totals.

## Earlier phase records

The following sections preserve earlier versions and their stated counts; current source/evidence is described above.

## Historical beautification addition — supplied Cabin

The inventory below documents the243 original pack files from the preceding Major Map pass. The user additionally supplied Asset/Cabin.glb before beautification: inspected actual native scene,221 meshes/25 materials/bounds~1.600×1.264×1.870 m. It is now the farm home in a9.5 m wrapper with static open/widened entry and aligned floor. Raw source and all243 original models are unchanged by hash;244 GLBs are present. See MAP_BEAUTIFICATION_REPORT.md, tools/audit_cabin.gd and docs/map_beautification/logs/cabin_audit_fixed.log. Earlier statements about missing house meshes apply to the original packs, not this separately supplied Cabin.

## Historical original pack inventory

2026-10-01. Before design, all 243 original GLBs were instantiated, their real scene bounds/meshes/colliders inspected, and individual views rendered in Godot 4.7. This includes every pack; no asset was rejected solely by filename. JSON retains all files, including weapons/characters outside this map pass. Environment candidate count: 197. Contact sheets and raw Godot results are retained as evidence.

Actual structural candidates include two containers, water tower, street modules, gates/signs and vehicles. Nature provides several tree/dead-tree/pine variants, bushes, ferns, grass, rocks and rock-path modules. Survival provides a tent, wood log, camp/domestic supplies and farm tools. RPG supplies bags/books/scythe candidates but most fantasy equipment does not match the rural setting. There are no actual house/barn/cliff/hill meshes in the current packs; author a simple farmhouse/workshop shell and terrain geometry in the project, retaining existing shelter collision and interactions. Rock-path modules are small groups of rocks, not a replacement for terrain. No rigid-body colliders exist in the imported assets.

Coverage categories: structural, terrain/road, vegetation, farm/survival, abandoned/survival, landmark/background and other inspected props. Landmarks and background roles overlap these categories. Final chosen assets, zones and purposes will be recorded in MAP_ASSET_USAGE.md; diverse use is guided by zone identity rather than filling every slot.

| Asset | Category | Actual scene bounds (m before wrapper) | Triangles |
|---|---|---|---|
| Low Poly Military Vehicles-glb/Ambulance Car.glb | Landmark / background | 1.49 × 2.13 × 4.24 | 2096 |
| Low Poly Military Vehicles-glb/Bike.glb | Landmark / background | 1.68 × 2.79 × 4.83 | 2320 |
| Low Poly Military Vehicles-glb/Helicopter.glb | Landmark / background | 41.34 × 11.41 × 45.20 | 1088 |
| Low Poly Military Vehicles-glb/Jeep.glb | Landmark / background | 2.04 × 2.33 × 4.56 | 1942 |
| Low Poly Military Vehicles-glb/Light Tank.glb | Landmark / background | 2.06 × 2.40 × 4.61 | 3088 |
| Low Poly Military Vehicles-glb/Military Boat.glb | Landmark / background | 10.01 × 6.29 × 26.46 | 868 |
| Low Poly Military Vehicles-glb/Military Motorbike.glb | Landmark / background | 2.08 × 2.21 × 5.21 | 2868 |
| Low Poly Military Vehicles-glb/Tank.glb | Landmark / background | 1.87 × 1.61 × 4.56 | 2796 |
| Low Poly Military Vehicles-glb/Truck.glb | Landmark / background | 1.94 × 2.23 × 4.43 | 1820 |
| Post Apocolypse Pack.undefined-glb/Axe.glb | Abandoned / survival | 0.30 × 0.09 × 1.30 | 790 |
| Post Apocolypse Pack.undefined-glb/Barrel.glb | Abandoned / survival | 0.70 × 1.14 × 0.70 | 882 |
| Post Apocolypse Pack.undefined-glb/Blood Splat-oQDW3k5As5.glb | Abandoned / survival | 1.71 × 0.00 × 1.32 | 74 |
| Post Apocolypse Pack.undefined-glb/Blood Splat.glb | Abandoned / survival | 3.41 × 0.00 × 3.56 | 130 |
| Post Apocolypse Pack.undefined-glb/Blood.glb | Abandoned / survival | 1.72 × 0.00 × 2.14 | 82 |
| Post Apocolypse Pack.undefined-glb/Chest-RfSBvgcZUD.glb | Abandoned / survival | 0.85 × 0.41 × 0.48 | 3422 |
| Post Apocolypse Pack.undefined-glb/Chest.glb | Abandoned / survival | 0.64 × 0.41 × 0.48 | 3190 |
| Post Apocolypse Pack.undefined-glb/Cinder Block.glb | Abandoned / survival | 0.47 × 0.23 × 0.21 | 368 |
| Post Apocolypse Pack.undefined-glb/Container Green.glb | Structural / landmark | 5.71 × 2.60 × 2.56 | 1336 |
| Post Apocolypse Pack.undefined-glb/Container Red.glb | Structural / landmark | 5.71 × 2.60 × 2.56 | 1032 |
| Post Apocolypse Pack.undefined-glb/Cross walk.glb | Terrain / road | 8.00 × 0.10 × 8.00 | 188 |
| Post Apocolypse Pack.undefined-glb/Damaged Couch.glb | Abandoned / survival | 3.01 × 1.24 × 1.21 | 3078 |
| Post Apocolypse Pack.undefined-glb/Fire Hydrant.glb | Abandoned / survival | 0.52 × 0.77 × 0.40 | 976 |
| Post Apocolypse Pack.undefined-glb/Guitar.glb | Abandoned / survival | 0.72 × 0.13 × 1.80 | 2325 |
| Post Apocolypse Pack.undefined-glb/Pallet Broken.glb | Abandoned / survival | 0.92 × 0.16 × 1.22 | 216 |
| Post Apocolypse Pack.undefined-glb/Pallet.glb | Abandoned / survival | 0.89 × 0.14 × 1.22 | 240 |
| Post Apocolypse Pack.undefined-glb/Pipes.glb | Abandoned / survival | 0.75 × 0.67 × 3.36 | 1496 |
| Post Apocolypse Pack.undefined-glb/Plastic Barrier.glb | Abandoned / survival | 1.04 × 0.60 × 0.33 | 852 |
| Post Apocolypse Pack.undefined-glb/Street Light.glb | Terrain / road | 0.36 × 6.64 × 2.93 | 426 |
| Post Apocolypse Pack.undefined-glb/Street Straight Crack-l7c8pppfFj.glb | Terrain / road | 8.00 × 0.58 × 8.00 | 676 |
| Post Apocolypse Pack.undefined-glb/Street Straight Crack.glb | Terrain / road | 8.00 × 0.29 × 8.00 | 576 |
| Post Apocolypse Pack.undefined-glb/Street Straight.glb | Terrain / road | 8.00 × 0.12 × 8.00 | 228 |
| Post Apocolypse Pack.undefined-glb/Street T.glb | Terrain / road | 8.00 × 0.10 × 8.00 | 180 |
| Post Apocolypse Pack.undefined-glb/Street Turn.glb | Terrain / road | 8.00 × 0.12 × 8.00 | 220 |
| Post Apocolypse Pack.undefined-glb/Town Sign.glb | Structural / landmark | 5.98 × 5.35 × 1.74 | 1397 |
| Post Apocolypse Pack.undefined-glb/Traffic Barrier-nugx3heueH.glb | Abandoned / survival | 1.56 × 1.11 × 0.88 | 732 |
| Post Apocolypse Pack.undefined-glb/Traffic Barrier.glb | Abandoned / survival | 1.56 × 0.80 × 0.78 | 364 |
| Post Apocolypse Pack.undefined-glb/Traffic Cone-VGvQupNGtK.glb | Abandoned / survival | 0.60 × 0.74 × 0.60 | 460 |
| Post Apocolypse Pack.undefined-glb/Traffic Cone.glb | Abandoned / survival | 0.52 × 0.67 × 0.52 | 134 |
| Post Apocolypse Pack.undefined-glb/Traffic Light-lg9AKWejnF.glb | Abandoned / survival | 5.34 × 4.66 × 1.92 | 1369 |
| Post Apocolypse Pack.undefined-glb/Traffic Light.glb | Abandoned / survival | 1.51 × 4.66 × 1.51 | 849 |
| Post Apocolypse Pack.undefined-glb/Trash Bag.glb | Abandoned / survival | 0.50 × 0.56 × 0.50 | 1044 |
| Post Apocolypse Pack.undefined-glb/Trash Bags.glb | Abandoned / survival | 0.91 × 0.53 × 0.52 | 2088 |
| Post Apocolypse Pack.undefined-glb/Water Tower.glb | Structural / landmark | 2.65 × 9.38 × 2.71 | 1158 |
| Post Apocolypse Pack.undefined-glb/Wheel.glb | Abandoned / survival | 0.57 × 0.20 × 0.57 | 608 |
| Post Apocolypse Pack.undefined-glb/Wheels Stack.glb | Abandoned / survival | 0.66 × 0.61 × 0.57 | 1824 |
| Stylized Nature MegaKit.undefined-glb/Bush with Flowers.glb | Vegetation | 1.91 × 1.58 × 1.97 | 1368 |
| Stylized Nature MegaKit.undefined-glb/Bush.glb | Vegetation | 1.91 × 1.58 × 1.97 | 900 |
| Stylized Nature MegaKit.undefined-glb/Clover-u5SOgBFiut.glb | Vegetation | 0.85 × 1.26 × 0.84 | 615 |
| Stylized Nature MegaKit.undefined-glb/Clover.glb | Vegetation | 0.80 × 1.14 × 0.76 | 379 |
| Stylized Nature MegaKit.undefined-glb/Dead Tree-CD4edbPSGm.glb | Vegetation | 8.36 × 16.44 × 8.41 | 5648 |
| Stylized Nature MegaKit.undefined-glb/Dead Tree-Mcd2zYqyww.glb | Vegetation | 6.73 × 11.49 × 6.38 | 6557 |
| Stylized Nature MegaKit.undefined-glb/Dead Tree-MlmK5488ou.glb | Vegetation | 6.15 × 9.50 × 5.75 | 6169 |
| Stylized Nature MegaKit.undefined-glb/Dead Tree-n8FhMgMldD.glb | Vegetation | 7.96 × 12.77 × 7.73 | 5702 |
| Stylized Nature MegaKit.undefined-glb/Dead Tree.glb | Vegetation | 6.39 × 13.28 × 6.43 | 5802 |
| Stylized Nature MegaKit.undefined-glb/Fern.glb | Vegetation | 9.05 × 2.69 × 8.49 | 288 |
| Stylized Nature MegaKit.undefined-glb/Flower Group-LqTljN6Wg2.glb | Vegetation | 1.78 × 2.49 × 1.37 | 1690 |
| Stylized Nature MegaKit.undefined-glb/Flower Group.glb | Vegetation | 1.49 × 2.05 × 1.59 | 755 |
| Stylized Nature MegaKit.undefined-glb/Flower Petal-LqvxG9OBOU.glb | Vegetation | 0.46 × 0.24 × 0.45 | 13 |
| Stylized Nature MegaKit.undefined-glb/Flower Petal-eVE0j49ux9.glb | Vegetation | 0.62 × 0.19 × 0.61 | 15 |
| Stylized Nature MegaKit.undefined-glb/Flower Petal-niuBUEJdvM.glb | Vegetation | 0.33 × 0.25 × 0.24 | 30 |
| Stylized Nature MegaKit.undefined-glb/Flower Petal-tzG4JcqYWs.glb | Vegetation | 0.83 × 0.29 × 0.80 | 15 |
| Stylized Nature MegaKit.undefined-glb/Flower Petal.glb | Vegetation | 0.67 × 0.24 × 0.63 | 15 |
| Stylized Nature MegaKit.undefined-glb/Flower Single-GvfHo0roi3.glb | Vegetation | 1.07 × 2.42 × 0.77 | 642 |
| Stylized Nature MegaKit.undefined-glb/Flower Single.glb | Vegetation | 0.91 × 2.07 × 0.88 | 285 |
| Stylized Nature MegaKit.undefined-glb/Grass Wispy-Msr9zx66VU.glb | Vegetation | 1.32 × 1.07 × 1.21 | 494 |
| Stylized Nature MegaKit.undefined-glb/Grass Wispy.glb | Vegetation | 1.54 × 1.67 × 1.59 | 622 |
| Stylized Nature MegaKit.undefined-glb/Grass.glb | Vegetation | 0.64 × 1.33 × 0.74 | 155 |
| Stylized Nature MegaKit.undefined-glb/Mushroom Laetiporus.glb | Vegetation | 1.37 × 0.77 × 1.10 | 3216 |
| Stylized Nature MegaKit.undefined-glb/Mushroom.glb | Vegetation | 0.56 × 0.46 × 0.78 | 880 |
| Stylized Nature MegaKit.undefined-glb/Pebble Round-KYtJ6JNXh2.glb | Terrain | 0.45 × 0.09 × 0.41 | 114 |
| Stylized Nature MegaKit.undefined-glb/Pebble Round-icVsN3lmVy.glb | Terrain | 0.50 × 0.10 × 0.37 | 136 |
| Stylized Nature MegaKit.undefined-glb/Pebble Round-kAMfq1uJUY.glb | Terrain | 0.41 × 0.10 × 0.45 | 126 |
| Stylized Nature MegaKit.undefined-glb/Pebble Round-nMf8LHOsbM.glb | Terrain | 0.42 × 0.10 × 0.35 | 124 |
| Stylized Nature MegaKit.undefined-glb/Pebble Round.glb | Terrain | 0.45 × 0.10 × 0.48 | 128 |
| Stylized Nature MegaKit.undefined-glb/Pebble Square-2YtLzwgsWp.glb | Terrain | 0.37 × 0.16 × 0.32 | 52 |
| Stylized Nature MegaKit.undefined-glb/Pebble Square-6juX57sLHe.glb | Terrain | 0.43 × 0.13 × 0.44 | 104 |
| Stylized Nature MegaKit.undefined-glb/Pebble Square-Mm4RMgwNO8.glb | Terrain | 0.39 × 0.14 × 0.28 | 78 |
| Stylized Nature MegaKit.undefined-glb/Pebble Square-l5XiYQj1oD.glb | Terrain | 0.46 × 0.14 × 0.26 | 65 |
| Stylized Nature MegaKit.undefined-glb/Pebble Square-s71L3q1nXN.glb | Terrain | 0.35 × 0.15 × 0.45 | 72 |
| Stylized Nature MegaKit.undefined-glb/Pebble Square.glb | Terrain | 0.34 × 0.17 × 0.29 | 48 |
| Stylized Nature MegaKit.undefined-glb/Pine-699sFuLCN2.glb | Vegetation | 3.61 × 7.39 × 4.00 | 4964 |
| Stylized Nature MegaKit.undefined-glb/Pine-79gmlLnweB.glb | Vegetation | 5.80 × 10.24 × 5.37 | 3370 |
| Stylized Nature MegaKit.undefined-glb/Pine-Zt62gceKXZ.glb | Vegetation | 5.73 × 7.38 × 5.22 | 3648 |
| Stylized Nature MegaKit.undefined-glb/Pine-rfnxJv0Rqa.glb | Vegetation | 4.94 × 7.32 × 4.54 | 3947 |
| Stylized Nature MegaKit.undefined-glb/Pine.glb | Vegetation | 6.42 × 8.72 × 6.22 | 1646 |
| Stylized Nature MegaKit.undefined-glb/Plant Big-MbhbP7JrTI.glb | Vegetation | 2.89 × 3.76 × 3.13 | 360 |
| Stylized Nature MegaKit.undefined-glb/Plant Big.glb | Vegetation | 1.31 × 0.25 × 1.36 | 112 |
| Stylized Nature MegaKit.undefined-glb/Plant-xH5gNlQxAZ.glb | Vegetation | 1.05 × 0.25 × 0.96 | 48 |
| Stylized Nature MegaKit.undefined-glb/Plant.glb | Vegetation | 1.27 × 1.01 × 1.39 | 120 |
| Stylized Nature MegaKit.undefined-glb/Rock Medium-JQxF95498B.glb | Terrain | 3.42 × 2.32 × 3.48 | 522 |
| Stylized Nature MegaKit.undefined-glb/Rock Medium-s1OJ3bBzqc.glb | Terrain | 3.23 × 2.26 × 2.99 | 342 |
| Stylized Nature MegaKit.undefined-glb/Rock Medium.glb | Terrain | 3.05 × 1.90 × 2.48 | 244 |
| Stylized Nature MegaKit.undefined-glb/Rock Path Round Small-GMttpOEFKT.glb | Terrain | 1.14 × 0.10 × 1.35 | 1126 |
| Stylized Nature MegaKit.undefined-glb/Rock Path Round Small-yHEdadj5I0.glb | Terrain | 1.06 × 0.11 × 1.48 | 998 |
| Stylized Nature MegaKit.undefined-glb/Rock Path Round Small.glb | Terrain | 1.18 × 0.11 × 1.29 | 1002 |
| Stylized Nature MegaKit.undefined-glb/Rock Path Round Thin.glb | Terrain | 1.46 × 0.11 × 2.09 | 2254 |
| Stylized Nature MegaKit.undefined-glb/Rock Path Round Wide.glb | Terrain | 2.11 × 0.11 × 2.13 | 3500 |
| Stylized Nature MegaKit.undefined-glb/Rock Path Square Smal-cI9XBpVijV.glb | Terrain | 1.02 × 0.15 × 0.97 | 783 |
| Stylized Nature MegaKit.undefined-glb/Rock Path Square Smal-w4TKZMjjcw.glb | Terrain | 0.99 × 0.15 × 0.97 | 559 |
| Stylized Nature MegaKit.undefined-glb/Rock Path Square Smal.glb | Terrain | 0.84 × 0.17 × 1.08 | 568 |
| Stylized Nature MegaKit.undefined-glb/Rock Path Square Thin.glb | Terrain | 1.56 × 0.18 × 1.99 | 1793 |
| Stylized Nature MegaKit.undefined-glb/Rock Path Square Wide.glb | Terrain | 2.05 × 0.18 × 1.99 | 2256 |
| Stylized Nature MegaKit.undefined-glb/Tall Grass.glb | Vegetation | 0.90 × 1.87 × 0.99 | 326 |
| Stylized Nature MegaKit.undefined-glb/Tree-QVOop92WmG.glb | Vegetation | 4.06 × 9.43 × 4.24 | 3505 |
| Stylized Nature MegaKit.undefined-glb/Tree-aVOxaHRPWe.glb | Vegetation | 4.46 × 7.64 × 4.28 | 5648 |
| Stylized Nature MegaKit.undefined-glb/Tree-qZtx0AHhcy.glb | Vegetation | 4.31 × 7.26 × 4.58 | 6265 |
| Stylized Nature MegaKit.undefined-glb/Tree-t9KbsfYdXz.glb | Vegetation | 3.67 × 7.01 × 4.22 | 3182 |
| Stylized Nature MegaKit.undefined-glb/Tree.glb | Vegetation | 3.83 × 9.44 × 3.76 | 4066 |
| Stylized Nature MegaKit.undefined-glb/Twisted Tree-7PDBpElkQr.glb | Vegetation | 10.38 × 18.74 × 11.29 | 9600 |
| Stylized Nature MegaKit.undefined-glb/Twisted Tree-8oraKn9m0x.glb | Vegetation | 11.36 × 16.07 × 11.51 | 10089 |
| Stylized Nature MegaKit.undefined-glb/Twisted Tree-9aWlx82xUf.glb | Vegetation | 13.52 × 16.73 × 11.55 | 9564 |
| Stylized Nature MegaKit.undefined-glb/Twisted Tree-GVTsMmuzv7.glb | Vegetation | 10.56 × 18.95 × 9.20 | 9134 |
| Stylized Nature MegaKit.undefined-glb/Twisted Tree.glb | Vegetation | 9.49 × 15.66 × 9.39 | 10104 |
| Survival Pack-glb/Axe.glb | Farm / survival | 1.26 × 3.26 × 0.19 | 236 |
| Survival Pack-glb/Backpack.glb | Farm / survival | 3.34 × 3.12 × 1.75 | 1748 |
| Survival Pack-glb/Battery-MYa3uWdwPU.glb | Farm / survival | 0.18 × 0.46 × 0.18 | 132 |
| Survival Pack-glb/Battery.glb | Farm / survival | 0.30 × 0.46 × 0.30 | 100 |
| Survival Pack-glb/Bear Trap.glb | Farm / survival | 2.99 × 0.68 × 3.54 | 608 |
| Survival Pack-glb/Bonfire.glb | Farm / survival | 2.18 × 2.31 × 1.98 | 704 |
| Survival Pack-glb/Can Broken.glb | Farm / survival | 0.47 × 0.64 × 0.47 | 428 |
| Survival Pack-glb/Can Red.glb | Farm / survival | 0.47 × 0.64 × 0.47 | 332 |
| Survival Pack-glb/Can.glb | Farm / survival | 0.47 × 0.64 × 0.47 | 428 |
| Survival Pack-glb/Compass.glb | Farm / survival | 0.91 × 0.81 × 0.70 | 656 |
| Survival Pack-glb/First Aid Kit-wP00rePSRD.glb | Farm / survival | 1.56 × 1.36 × 0.73 | 754 |
| Survival Pack-glb/First Aid Kit.glb | Farm / survival | 1.88 × 1.28 × 0.68 | 268 |
| Survival Pack-glb/Flare Gun.glb | Farm / survival | 2.51 × 1.66 × 0.60 | 540 |
| Survival Pack-glb/Gas Can.glb | Farm / survival | 1.88 × 2.47 × 0.62 | 788 |
| Survival Pack-glb/Match Burnt.glb | Farm / survival | 0.06 × 0.57 × 0.08 | 76 |
| Survival Pack-glb/Match.glb | Farm / survival | 0.04 × 0.60 × 0.04 | 28 |
| Survival Pack-glb/Matchbox.glb | Farm / survival | 0.54 × 1.09 × 0.17 | 396 |
| Survival Pack-glb/Pan.glb | Farm / survival | 1.72 × 0.34 × 2.82 | 246 |
| Survival Pack-glb/Phone.glb | Farm / survival | 0.42 × 0.91 × 0.06 | 224 |
| Survival Pack-glb/Pot-fyweVKYu0K.glb | Farm / survival | 1.19 × 0.42 × 1.41 | 326 |
| Survival Pack-glb/Pot.glb | Farm / survival | 1.72 × 1.04 × 2.03 | 326 |
| Survival Pack-glb/Propane Tank.glb | Farm / survival | 2.16 × 2.89 × 2.05 | 516 |
| Survival Pack-glb/Radio.glb | Farm / survival | 1.69 × 2.10 × 0.57 | 481 |
| Survival Pack-glb/Raft Paddle.glb | Farm / survival | 1.67 × 0.30 × 14.85 | 264 |
| Survival Pack-glb/Raft.glb | Farm / survival | 11.96 × 4.30 × 23.65 | 1036 |
| Survival Pack-glb/Shovel.glb | Farm / survival | 0.80 × 3.87 × 0.18 | 322 |
| Survival Pack-glb/Tent.glb | Farm / survival | 14.58 × 10.32 × 24.87 | 784 |
| Survival Pack-glb/Torch.glb | Farm / survival | 0.68 × 2.51 × 0.67 | 610 |
| Survival Pack-glb/Water Bottle.glb | Farm / survival | 0.50 × 1.44 × 0.50 | 288 |
| Survival Pack-glb/Wood Log.glb | Farm / survival | 4.64 × 1.09 × 4.57 | 202 |
| Survival Pack-glb/Wooden Torch.glb | Farm / survival | 0.46 × 2.69 × 0.42 | 448 |
| Ultimate RPG Items Bundle-glb/Armor Golden.glb | Other inspected props | 1.54 × 1.20 × 0.76 | 1040 |
| Ultimate RPG Items Bundle-glb/Armor Leather.glb | Other inspected props | 0.98 × 0.82 × 0.67 | 288 |
| Ultimate RPG Items Bundle-glb/Armor Metal.glb | Other inspected props | 1.54 × 1.10 × 0.76 | 704 |
| Ultimate RPG Items Bundle-glb/Arrow.glb | Other inspected props | 0.13 × 1.46 × 0.15 | 224 |
| Ultimate RPG Items Bundle-glb/Axe Double.glb | Other inspected props | 0.87 × 2.15 × 0.14 | 1556 |
| Ultimate RPG Items Bundle-glb/Axe Small.glb | Other inspected props | 0.62 × 1.57 × 0.13 | 966 |
| Ultimate RPG Items Bundle-glb/Backpack.glb | Other inspected props | 1.07 × 0.95 × 0.80 | 3960 |
| Ultimate RPG Items Bundle-glb/Bag.glb | Other inspected props | 0.80 × 0.63 × 0.49 | 1232 |
| Ultimate RPG Items Bundle-glb/Bone.glb | Other inspected props | 1.02 × 0.34 × 0.18 | 304 |
| Ultimate RPG Items Bundle-glb/Book Open.glb | Other inspected props | 0.88 × 0.19 × 0.75 | 520 |
| Ultimate RPG Items Bundle-glb/Book-LC0w7VI75u.glb | Other inspected props | 0.19 × 0.80 × 0.60 | 332 |
| Ultimate RPG Items Bundle-glb/Book-h3Wh4fxSQX.glb | Other inspected props | 0.31 × 0.81 × 0.67 | 1060 |
| Ultimate RPG Items Bundle-glb/Book.glb | Other inspected props | 0.21 × 0.81 × 0.60 | 668 |
| Ultimate RPG Items Bundle-glb/Chalice.glb | Other inspected props | 0.49 × 0.75 × 0.49 | 380 |
| Ultimate RPG Items Bundle-glb/Chest.glb | Other inspected props | 0.95 × 1.15 × 1.00 | 1696 |
| Ultimate RPG Items Bundle-glb/Claymore.glb | Other inspected props | 0.98 × 6.59 × 0.27 | 1031 |
| Ultimate RPG Items Bundle-glb/Coin Pouch.glb | Other inspected props | 0.47 × 0.55 × 0.47 | 414 |
| Ultimate RPG Items Bundle-glb/Coin.glb | Other inspected props | 0.74 × 0.74 × 0.18 | 396 |
| Ultimate RPG Items Bundle-glb/Crown.glb | Other inspected props | 0.89 × 0.58 × 0.89 | 840 |
| Ultimate RPG Items Bundle-glb/Dagger.glb | Other inspected props | 0.30 × 1.39 × 0.11 | 726 |
| Ultimate RPG Items Bundle-glb/Doublesided Hammer.glb | Other inspected props | 1.18 × 2.53 × 0.43 | 1918 |
| Ultimate RPG Items Bundle-glb/Fish Bone.glb | Other inspected props | 0.92 × 0.16 × 0.39 | 588 |
| Ultimate RPG Items Bundle-glb/Glove.glb | Other inspected props | 0.60 × 0.27 × 0.96 | 456 |
| Ultimate RPG Items Bundle-glb/Gold Ingots.glb | Other inspected props | 0.72 × 0.45 × 0.61 | 648 |
| Ultimate RPG Items Bundle-glb/Key-MUl40QpEvv.glb | Other inspected props | 0.40 × 0.09 × 0.99 | 512 |
| Ultimate RPG Items Bundle-glb/Key-bg6e1lfNsO.glb | Other inspected props | 0.43 × 0.09 × 1.01 | 688 |
| Ultimate RPG Items Bundle-glb/Key-h5nke04hRD.glb | Other inspected props | 0.46 × 0.09 × 1.09 | 744 |
| Ultimate RPG Items Bundle-glb/Key.glb | Other inspected props | 0.29 × 0.10 × 0.87 | 284 |
| Ultimate RPG Items Bundle-glb/Mineral.glb | Other inspected props | 0.59 × 0.44 × 0.56 | 896 |
| Ultimate RPG Items Bundle-glb/Necklace-Jvhs8DCNDZ.glb | Other inspected props | 0.85 × 1.01 × 1.00 | 824 |
| Ultimate RPG Items Bundle-glb/Necklace.glb | Other inspected props | 0.87 × 0.88 × 0.96 | 792 |
| Ultimate RPG Items Bundle-glb/Open Book-1A07aI9j2d.glb | Other inspected props | 0.92 × 0.18 × 0.75 | 472 |
| Ultimate RPG Items Bundle-glb/Open Book-JEDMpG0UIR.glb | Other inspected props | 0.87 × 0.13 × 0.74 | 464 |
| Ultimate RPG Items Bundle-glb/Open Book.glb | Other inspected props | 0.93 × 0.17 × 0.71 | 592 |
| Ultimate RPG Items Bundle-glb/Padlock.glb | Other inspected props | 0.62 × 0.97 × 0.31 | 584 |
| Ultimate RPG Items Bundle-glb/Parchment.glb | Other inspected props | 0.92 × 0.90 × 0.38 | 592 |
| Ultimate RPG Items Bundle-glb/Potion Bottle-WJxYta4Z96.glb | Other inspected props | 0.67 × 0.96 × 0.67 | 1328 |
| Ultimate RPG Items Bundle-glb/Potion Bottle.glb | Other inspected props | 0.72 × 1.24 × 0.72 | 1584 |
| Ultimate RPG Items Bundle-glb/Scroll.glb | Other inspected props | 1.48 × 0.24 × 0.25 | 956 |
| Ultimate RPG Items Bundle-glb/Scythe.glb | Other inspected props | 3.03 × 5.58 × 0.28 | 1310 |
| Ultimate RPG Items Bundle-glb/Shield Celtic Golden.glb | Other inspected props | 2.10 × 4.28 × 1.41 | 832 |
| Ultimate RPG Items Bundle-glb/Shield Heater-xoHSnOjsBG.glb | Other inspected props | 2.01 × 2.56 × 0.60 | 1948 |
| Ultimate RPG Items Bundle-glb/Shield Heater.glb | Other inspected props | 2.01 × 2.56 × 0.60 | 1272 |
| Ultimate RPG Items Bundle-glb/Shield Round-lWajrVXcnA.glb | Other inspected props | 2.00 × 2.00 × 0.60 | 1056 |
| Ultimate RPG Items Bundle-glb/Shield Round.glb | Other inspected props | 2.00 × 2.00 × 0.60 | 1204 |
| Ultimate RPG Items Bundle-glb/Skull Coin.glb | Other inspected props | 0.74 × 0.74 × 0.18 | 568 |
| Ultimate RPG Items Bundle-glb/Skull-ExZmhOIjka.glb | Other inspected props | 0.86 × 0.93 × 0.47 | 1664 |
| Ultimate RPG Items Bundle-glb/Skull.glb | Other inspected props | 0.58 × 0.76 × 0.58 | 336 |
| Ultimate RPG Items Bundle-glb/Snowflake.glb | Other inspected props | 0.90 × 0.90 × 0.10 | 668 |
| Ultimate RPG Items Bundle-glb/Star Coin.glb | Other inspected props | 0.74 × 0.74 × 0.20 | 452 |
| Ultimate RPG Items Bundle-glb/Sword-9lLmH8Et4K.glb | Other inspected props | 0.53 × 2.30 × 0.12 | 872 |
| Ultimate RPG Items Bundle-glb/Sword.glb | Other inspected props | 0.43 × 2.73 × 0.10 | 830 |
| Ultimate RPG Items Bundle-glb/Wooden Bow.glb | Other inspected props | 0.53 × 1.97 × 0.09 | 660 |
