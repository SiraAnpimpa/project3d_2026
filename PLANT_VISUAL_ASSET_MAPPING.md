# PLANT VISUAL ASSET MAPPING — 2026-10-02

Actual imported models were instantiated, measured, rendered and visually inspected before plant edits. All 68 Stylized Nature MegaKit GLBs were covered, including vegetation, flowers, mushrooms, grass, trees and rocks; all other supplied model filenames were checked for vegetation candidates. There are no authored crop growth sets or separate seedlings in the supplied pack. Two RPG fantasy accents (Mineral and Snowflake) were also inspected; neither is needed for these crops.

## Active plant mapping

All source files below are unchanged GLBs under `Asset/Stylized Nature MegaKit.undefined-glb`. Eight distinct source models, not eight recolours of one model. Each static wrapper centres the measured native X/Z bounds and grounds the minimum Y, with a bounded uniform scale. Seed stage uses the existing small marker. Stages 1/2/3 use the listed source at 35%/70%/100% of its measured mature size. Native orientation, palette and materials are preserved.

| Plant | Asset | Stage 1 | Stage 2 | Stage 3 | Notes |
|---|---|---|---|---|---|
| lead | Plant Big.glb | Small 0.35 | Growing 0.70 | Mature 1.0 | Low purple mineral rosette, many pointed leaves; mature height 0.205 m, footprint 1.100 m |
| paper | Clover.glb | Small 0.35 | Growing 0.70 | Mature 1.0 | Two broad leaf stems, tall paper-like canopy; mature height 0.680 m, footprint 0.473 m |
| iron | Plant Big-MbhbP7JrTI.glb | Small 0.35 | Growing 0.70 | Mature 1.0 | Tall narrow blade tuft, orange native tips; mature height 0.860 m, footprint 0.716 m |
| copper | Flower Single-GvfHo0roi3.glb | Small 0.35 | Growing 0.70 | Mature 1.0 | Slender stem with hanging yellow pods; mature height 0.800 m, footprint 0.355 m |
| small_herb | Fern.glb | Small 0.35 | Growing 0.70 | Mature 1.0 | Low radial green fern fronds; mature height 0.327 m, footprint 1.100 m |
| fire_pepper | Bush.glb | Small 0.35 | Growing 0.70 | Mature 1.0 | Rounded red native foliage; fantasy pepper analogue; mature height 0.740 m, footprint 0.919 m |
| ice_plant | Mushroom.glb | Small 0.35 | Growing 0.70 | Mature 1.0 | Pale three-umbrella cluster; fantasy ice analogue; mature height 0.565 m, footprint 0.950 m |
| poison_plant | Mushroom Laetiporus.glb | Small 0.35 | Growing 0.70 | Mature 1.0 | Layered shelf fungus with an unusual tiered silhouette; mature height 0.517 m, footprint 0.920 m |

`PlantData.visual_scene` selects each wrapper. Existing `stage_visuals[]` remains available for future authored growth art; no per-ID logic was added to FarmPlot. Stage thresholds, growth durations, yields, seed/produce IDs, recipes and unlock days are unchanged. Mature plants keep the existing Ready interaction/plot label and size change; the old generic floating produce prism is disabled in these eight data resources with `show_produce_marker = false`. Its default remains true for existing custom data.

Water Plant and Electric Plant are **NOT FOUND in the actual plant catalog**. No new seeds, economy, unlocks or invented visuals were added for absent gameplay. Fire Pepper and Ice Plant use theme-compatible fantasy vegetation rather than literal pepper/ice models. Poison uses shelf mushrooms, not an authored poisonous crop.

## Full nature audit and selection

All entries below have actual imported/rendered audit evidence. "Decor only" means excluded from crop art due to large size or ground/rock/tree purpose, not a broken asset. "Alternative" means usable source art that is deliberately unused to preserve eight clear silhouettes. Standalone Flower Petal heads have no stems, so they are unsuitable alone as planted crops.

| Source GLB | Disposition | Mesh parts | Native materials |
|---|---|---:|---:|
| Bush with Flowers.glb | Alternative vegetation | 1 | 2 |
| Bush.glb | Used: fire_pepper | 1 | 1 |
| Clover-u5SOgBFiut.glb | Alternative vegetation | 1 | 1 |
| Clover.glb | Used: paper | 1 | 1 |
| Dead Tree-CD4edbPSGm.glb | Decor only | 1 | 1 |
| Dead Tree-Mcd2zYqyww.glb | Decor only | 1 | 1 |
| Dead Tree-MlmK5488ou.glb | Decor only | 1 | 1 |
| Dead Tree-n8FhMgMldD.glb | Decor only | 1 | 1 |
| Dead Tree.glb | Decor only | 1 | 1 |
| Fern.glb | Used: small_herb | 1 | 1 |
| Flower Group-LqTljN6Wg2.glb | Alternative vegetation | 1 | 2 |
| Flower Group.glb | Alternative vegetation | 1 | 2 |
| Flower Petal-LqvxG9OBOU.glb | Detached head, no stem | 1 | 1 |
| Flower Petal-eVE0j49ux9.glb | Detached head, no stem | 1 | 1 |
| Flower Petal-niuBUEJdvM.glb | Detached head, no stem | 1 | 1 |
| Flower Petal-tzG4JcqYWs.glb | Detached head, no stem | 1 | 1 |
| Flower Petal.glb | Detached head, no stem | 1 | 1 |
| Flower Single-GvfHo0roi3.glb | Used: copper | 1 | 2 |
| Flower Single.glb | Alternative vegetation | 1 | 2 |
| Grass Wispy-Msr9zx66VU.glb | Alternative vegetation | 1 | 1 |
| Grass Wispy.glb | Alternative vegetation | 1 | 1 |
| Grass.glb | Alternative vegetation | 1 | 1 |
| Mushroom Laetiporus.glb | Used: poison_plant | 1 | 1 |
| Mushroom.glb | Used: ice_plant | 1 | 1 |
| Pebble Round-KYtJ6JNXh2.glb | Decor only | 1 | 1 |
| Pebble Round-icVsN3lmVy.glb | Decor only | 1 | 1 |
| Pebble Round-kAMfq1uJUY.glb | Decor only | 1 | 1 |
| Pebble Round-nMf8LHOsbM.glb | Decor only | 1 | 1 |
| Pebble Round.glb | Decor only | 1 | 1 |
| Pebble Square-2YtLzwgsWp.glb | Decor only | 1 | 1 |
| Pebble Square-6juX57sLHe.glb | Decor only | 1 | 1 |
| Pebble Square-Mm4RMgwNO8.glb | Decor only | 1 | 1 |
| Pebble Square-l5XiYQj1oD.glb | Decor only | 1 | 1 |
| Pebble Square-s71L3q1nXN.glb | Decor only | 1 | 1 |
| Pebble Square.glb | Decor only | 1 | 1 |
| Pine-699sFuLCN2.glb | Decor only | 1 | 2 |
| Pine-79gmlLnweB.glb | Decor only | 1 | 2 |
| Pine-Zt62gceKXZ.glb | Decor only | 1 | 2 |
| Pine-rfnxJv0Rqa.glb | Decor only | 1 | 2 |
| Pine.glb | Decor only | 1 | 2 |
| Plant Big-MbhbP7JrTI.glb | Used: iron | 1 | 1 |
| Plant Big.glb | Used: lead | 1 | 1 |
| Plant-xH5gNlQxAZ.glb | Alternative vegetation | 1 | 1 |
| Plant.glb | Alternative vegetation | 1 | 1 |
| Rock Medium-JQxF95498B.glb | Decor only | 1 | 1 |
| Rock Medium-s1OJ3bBzqc.glb | Decor only | 1 | 1 |
| Rock Medium.glb | Decor only | 1 | 1 |
| Rock Path Round Small-GMttpOEFKT.glb | Decor only | 1 | 1 |
| Rock Path Round Small-yHEdadj5I0.glb | Decor only | 1 | 1 |
| Rock Path Round Small.glb | Decor only | 1 | 1 |
| Rock Path Round Thin.glb | Decor only | 1 | 1 |
| Rock Path Round Wide.glb | Decor only | 1 | 1 |
| Rock Path Square Smal-cI9XBpVijV.glb | Decor only | 1 | 1 |
| Rock Path Square Smal-w4TKZMjjcw.glb | Decor only | 1 | 1 |
| Rock Path Square Smal.glb | Decor only | 1 | 1 |
| Rock Path Square Thin.glb | Decor only | 1 | 1 |
| Rock Path Square Wide.glb | Decor only | 1 | 1 |
| Tall Grass.glb | Alternative vegetation | 1 | 1 |
| Tree-QVOop92WmG.glb | Decor only | 1 | 2 |
| Tree-aVOxaHRPWe.glb | Decor only | 1 | 2 |
| Tree-qZtx0AHhcy.glb | Decor only | 1 | 2 |
| Tree-t9KbsfYdXz.glb | Decor only | 1 | 2 |
| Tree.glb | Decor only | 1 | 2 |
| Twisted Tree-7PDBpElkQr.glb | Decor only | 1 | 2 |
| Twisted Tree-8oraKn9m0x.glb | Decor only | 1 | 2 |
| Twisted Tree-9aWlx82xUf.glb | Decor only | 1 | 2 |
| Twisted Tree-GVTsMmuzv7.glb | Decor only | 1 | 2 |
| Twisted Tree.glb | Decor only | 1 | 2 |

## Verification status

Complete: all68 Nature assets inspected before plant edits; eight distinct native wrappers verified from the actual player camera. Headless and rendered tests pass actual selection/planting/growth/harvest for all8 seeds,24 stage geometries (grounded within0.001m, bounded footprint/height, one model/no collisions), real-clock readiness, full-inventory atomic retention and a future data-only stage override. Existing FarmPlot/economics/seed data match baseline hashes/field comparisons. No absent Water/Electric gameplay was added.

Matched art-only replay: current night12 mean5.942ms versus legacy5.767ms (+0.175ms/~3.0%), p9910.628 versus10.964ms; draw calls fall40 and node count is unchanged. Short600-frame machine-specific samples; see [report section15](GAMEPLAY_REFINEMENT_REPORT.md#15-performance-impact) for true-source before/after and variance limits. [Logs, geometry, audit and player-camera evidence](docs/gameplay_refinement/README.md).
