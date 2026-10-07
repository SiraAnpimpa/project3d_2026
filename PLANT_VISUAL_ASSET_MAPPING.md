# Plant visual mapping

Sources are under `Asset/Stylized Nature MegaKit.undefined-glb`. Static wrappers centre the native X/Z bounds, ground the minimum Y and apply uniform scaling. The seed stage uses a small marker; growing stages use 35%, 70% and 100% of mature size.

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

`PlantData.visual_scene` selects a wrapper. `stage_visuals[]` supports separate stage art, while `show_produce_marker` controls the generic produce marker. The eight catalog crops disable that marker and retain their plot readiness prompt.

The supplied pack has no separate authored crop growth sets. Fire, Ice and Poison crops are thematic vegetation representations. Water and Electric crops are absent from the gameplay catalog.

[Asset credits](ASSET_CREDITS.md)
