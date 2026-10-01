# Map redesign evidence — 2026-10-01

Current completed report: [MAP_REDESIGN_REPORT.md](../../MAP_REDESIGN_REPORT.md). Actual environment mapping: [MAP_ASSET_USAGE.md](../../MAP_ASSET_USAGE.md).

- `before/`: four pre-pass rendered views of the48 m flat map.
- `terrain_blockout/`: terrain-first stage before new landmark/decoration clusters.
- `matched_after/`: same capture script/cameras/resolution as before.
- `after/`: latest wide/base/ridge/forest/depot/road/night composition,12 actual rifle variant/entry cases,4 ordinary-wave approaches and focused farming/camera screenshots. Fixtures and debug views are disclosed in the report.
- `asset_contact_sheets/`:13 current Godot pages covering197 broad environment/decor candidates; each original model was separately opened/rendered in the audit. The underlying243-file scene/bounds/mesh/collider/triangle inventory is `environment_inventory.json`.
- `asset_usage.json`, `asset_audit.json`: actual69-model mapping/counts and243 original source hash comparison.
- `map_metrics.json`, `routes.json`, `performance.json`, `test_results.json`: exact measured results and method limits.
- `scope_integrity.json`: byte comparison of existing gameplay/player/weapon/UI/time/resource files with the pre-map snapshot.
- `source_hashes.json`: SHA-256 of changed production/test map sources at delivery.
- `logs/`: successful/latest checks and failed earlier attempts. Original regression had37/40; targeted boundary/map-circulation fixes passed. Initial32.59° slope and East visibility failures were repaired. First new-class import/capture attempt produced parser errors before a fresh import; fixed rendered capture succeeded. Extra matched capture first lacked its output directory; corrected capture succeeds. These historical failures are not silently discarded.

Known Windows root-certificate-store diagnostic is excluded explicitly from functional error checks. No claim of human playtesting, new release export or minimum hardware certification. Root agent only; stop for user map review.
