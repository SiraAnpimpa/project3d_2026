# MAP FINAL CLEANUP & DETAIL FINISHING — Somchai's Last Harvest

2026-10-01. **COMPLETE — STOP FOR MAP REVIEW. Environment finishing only; root agent only.**
This issue list was recorded after running the existing map and before changing production map files. The current dirty source was snapshotted, including all existing assets and core files. Existing zone, plot, bed, workbench, rescue and enemy-entry anchors are preserved; the source audit confirms this.

## 1. Issue list before cleanup

Baseline: 27 walks through production player input, 99 rendered day/night/detail/top images; failures=0. Time and damage are controlled for this geometry survey. This is automated walking and image inspection, not human keyboard playtesting. Evidence: [before images](docs/map_final_cleanup/before), [walk records](docs/map_final_cleanup/survey_before.json).

| ID | Category | Observed issue / evidence | Intended cleanup |
|---|---|---|---|
| D01 | Structural / unfinished | Workshop roof stands above rear wall; thin front posts, no continuous roof framing. `workshop_back_detail`, `player_workbench_0` | Connect roof, beams, wall and grounded corner supports in the same footprint |
| D02 | Structural / disconnected | Depot's tilted roof projects above short, unrelated posts. `depot_structure`, `player_depot_0` | Keep the ruin identity but give the remaining roof a credible supported frame |
| D03 | Workbench / unfinished | Main tabletop is a suspended slab; pan/pot and assorted fantasy props read as scattered kitchen/storage dressing. Lamp pole crosses the bench. `player_workbench_0` | Add visual legs/bracing/shelf/tools inside existing body; curate supplies and move lamp onto shelter support |
| D04 | Cabin / consistency | White fascia, chimney and veranda base dominate the home; front shelter board overlaps veranda furniture. `cabin_front_detail`, `cabin_side_detail`, `cabin_back_detail` | Tone copied exterior materials, remove intrusive board, preserve native roof/entry geometry and continuous earth apron |
| D05 | Strange signs / silhouette | House lamp sits directly between player and door; freestanding farm/landing boards compete with real landmarks; blank landing board dominates reverse approach. `player_cabin_front_0`, `farm_fence_detail`, `rescue_detail` | Remove redundant decorative boards; shift the existing yard lamp out of doorway sightline; retain gameplay prompts |
| D06 | Rescue / artificial | Tiny asphalt square, motorway gantry, tall street lamp and checkpoint barrier make the landing look like a disconnected asset sample. Bright round clearing has a hard visual outline. `rescue`, `top` | Remove forced roadside pieces; keep stopped supply truck, aid cache, sparse markers/light and level clear rotor space |
| D07 | Random / wrong zone | Four rectangular paving modules and tied pipes sit separately in the dry drainage. `drainage_detail`, `rescue` | Remove detached paving/pipe bundle; retain natural ditch terrain and depot material group |
| D08 | Ground contact / spacing | Alternating raised firewood pieces have no clear stack support; clutter and tiny padlock/fantasy scythe crowd the utility wall. `workshop_back_detail`, `player_workshop_stock_180` | Re-stack five logs on three grounded base logs, reduce small unrelated props, group useful tools/stock |
| D09 | Fence connections / grounding | Rail rotation is aimed at un-offset post centres; upper broken rails end away from supports. Western fragments near the boundary rock need an intersection sweep. `farm_fence_detail`, entry views | Connect rail endpoints explicitly, embed post tips, remove fragments intersecting rock/tree bases |
| D10 | Terrain transition | Yard/utility/rescue earth is brighter than surrounding grass; rectangular utility edge and path width step make pasted patches visible. `top`, `farmstead`, `rescue` | Use softer rounded/irregular colour falloffs and continuous path width; retain terrain heights/core layout |

Night baseline confirms warm home/work lights and readable open field; keep five existing lights. No movement blocker was found in the baseline survey. Existing crop labels, character poses and core systems are outside this pass.

## 2. Structural fixes

**D01/D02/D09 resolved.** The workshop keeps its original footprint and 6° roof pitch. Four grounded corner posts, front/back eaves and three rafters now meet the analytically calculated roof underside. The rear wall reaches the back beam; restrained timber battens finish its face. Posts embed 0.06 m in soil. There are no new roof collision surfaces or overhead navigation blockers.

The depot keeps its raised foundation, containers, vehicles and damaged identity. Four grounded posts, two eaves, three rafters and a connected wall support the surviving right roof; the left bay is deliberately roofless. It reads as a ruin with a remaining structure rather than disconnected floating pieces. Water tower and native Cabin structures stay in place.

Fence rails connect explicit elevated post endpoints. Broken upper rails retain an attached end and a shortened drooping free end. Two western fragments that intersected boundary boulders were removed. Remaining 16 posts and 16 rails pass attachment/contact checks. See [workshop](docs/map_final_cleanup/after/workshop_detail.png), [depot](docs/map_final_cleanup/after/depot_structure.png), [fence](docs/map_final_cleanup/after/farm_fence_detail.png) and [geometry](docs/map_final_cleanup/geometry.json).

## 3. Cabin fixes

**D04/D05 resolved.** Preserve the supplied 9.5 m furnished Cabin at (-12,-10), native roof/porch, wrapper lift -0.276 m, static widened approximately 1.85 m doorway and continuous 0.135 m earth apron. Selected exterior floor, fascia, chimney and roof surfaces use copied muted materials with high roughness. The source GLB and furnished interior remain intact.

Remove the freestanding shelter board and three redundant domestic props (backpack, water bottle, book). Retain one compact chest/radio/aid group in the right room; items sit at the measured chest height. The existing rest anchor and its approach remain accessible. Move the yard lamp to (-17.6,2.2,-4.2), clearing the door sightline. The front, west, back and east actual player viewpoints were inspected at four rotations each, alongside close views. [Front](docs/map_final_cleanup/after/cabin_front_detail.png), [side](docs/map_final_cleanup/after/cabin_side_detail.png), [back](docs/map_final_cleanup/after/cabin_back_detail.png).

## 4. Workbench fixes

**D03/D08 resolved.** The old floating tabletop now has four 0.79 m visual legs meeting its underside, a lower shelf/back brace, a small vise and two stocked metal bars. These twelve added mesh nodes stay in the original body. Script, tabletop dimensions/position, collision shape/layers/mask, interaction height and existing label are unchanged by exact section comparison. No recipe or usable item was added.

Remove pan/pot, fantasy scythe, bag and tiny padlock. Keep a barrel, tool chest, propane and fuel can grouped against the rear wall; put the formerly raised fuel can on the ground. Lean shovel/axe against the wall and calculate their lowest rotated mesh vertices to meet the soil. Behind the shed, five logs form three grounded base pieces plus two supported upper pieces. The upper stock chest now rests on the measured 1.8 m lower-box height instead of clipping halfway inside it. The original warm work light sits on a small bracket on the front right post at (5.75,2.28,-7.6).

The latest visual tool adjustment was followed by another geometry check and a focused five-walk/24-image refresh, replacing affected matched survey images. [Player view](docs/map_final_cleanup/after/player_workbench_0.png), [detail](docs/map_final_cleanup/after/workshop_detail.png), [back](docs/map_final_cleanup/after/workshop_back_detail.png), [refresh records](docs/map_final_cleanup/finish_views.json).

## 5. Rescue area fixes

**D06 resolved.** The southeast rescue anchor remains (29,0.70,43), on the same level 0.65 m clearing. Remove the tiny asphalt module, motorway gantry, tall street light, solid checkpoint barrier and spare approach cone. The landing is now open worn earth reached by the existing curved dirt path. Its irregular blended edge avoids a bright stamped disk.

Retain the stopped supply truck at (18,42), nearby fuel/chest/radio/aid group, four existing corner cones, H marker and one existing warm lamp. The radio/aid sit at the actual chest top. Rotor space is clear of tall physics and visible decorations; trees still exclude the 13 m rescue radius. Ending logic, camera transforms, helicopter/player targets and timing are byte identical to the pre-cleanup source. The rendered existing rescue completes, with helicopter at (29,0.85,43) and player at (25,0.68,45). [Clearing](docs/map_final_cleanup/after/rescue.png), [approach](docs/map_final_cleanup/after/rescue_detail.png), [ending images](docs/map_final_cleanup/rescue).

The actual controller follows the visible road in 18.267 simulated seconds, approximately 68.09 m of waypoints; house-to-landing separation is 67.01 m. Four representative farm/home eyes hide all five landing samples until the approach reveals it. These are representative views rather than a guarantee from every possible camera. [Distance/reveal records](docs/map_final_cleanup/rescue_distance.json).

## 6. Strange object/sign cleanup

**D05/D07/D08 resolved.** Remove all three decorative freestanding Farm/Shelter/Rescue boards; native interaction labels/prompts remain. Remove four detached paving modules and the separate tied pipe bundle from the dry drainage. Depot pipes and credible depot debris stay in their material group. The home, utility and rescue prop reductions above remove 18 placed model instances in total; 14 unused source preloads are removed. No raw asset is deleted.

Current decorative model usage is 56 unique sources /11,707 placements: 11,019 unchanged grass tufts plus 688 other placements. The prior map used 70 /11,725. Most models use 54 MultiMesh mesh batches rather than 68. These counts exclude procedural framing, gameplay actors/crops and the ending helicopter. [Current asset table](MAP_ASSET_USAGE.md), [runtime usage](docs/map_final_cleanup/usage.json), [prior table](docs/map_final_cleanup/prior_MAP_ASSET_USAGE.md).

## 7. Grounding/clipping fixes

**D08/D09 resolved.** Medium rock groups partially follow the local terrain normal while retaining their original base embed. All 40 inspected rock mesh instances touch/penetrate ground at their lowest point while keeping exposed mass. Sixteen fence posts embed 0.08 m; rail alignment follows their actual heights. Eight main shelter/depot corner supports, four bench legs, three shovel/axe instances, stack/table placements and Cabin floor contact were checked. No visible rotor intrusion remains.

Automated [geometry checks](docs/map_final_cleanup/geometry.json) report failures=0, backed by close/player/top image inspection. Intentionally embedded rock/post tips and overlapping frame joints provide contact; they are not unrelated accidental intersections. No prominent floating/disconnected prop was found in the inspected views. This is targeted contact testing and image review, not an exhaustive engineering mesh intersection solver.

## 8. Terrain transition fixes

**D10 resolved.** Change colour placement only: soften yard/utility/apron shapes with rounded irregular falloffs; mute worn earth; blend dirt into grass; transition road width smoothly from 2.2 to 3.1 m across z=8..20 instead of a hard width step. The landing edge uses an irregular ellipse and broad falloff; truck wear blends with the existing path.

Terrain height function, trail coordinates, constants, render/collision construction and vegetation generation are unchanged. There are still 3,025 sampled points, 6,272 playable triangles, heights -1.729..5.065 m, maximum sampled slope 29.671° /actual triangle slope 30.835°, 116 playable trunk colliders and 11,019 grass tufts. Minimum plot walking gap remains 2.15 m. [Top view](docs/map_final_cleanup/after/top.png), [metrics](docs/map_final_cleanup/metrics.json), [scope verification](docs/map_final_cleanup/scope_audit.json).

## 9. Night readability check

All seven requested areas plus the depot/tower/entry pockets were reviewed by production player views, close/top views and night views. The matched survey covers 19 day destinations ×four rotations, fourteen detail/overview views and nine night views: 99 images /27 actual-input walks. Before and after contacts and raw framebuffers are retained. The after scenery fixture disables pursuit during night viewpoints and controls time/damage; combat is tested separately.

Five existing lights remain. Existing home/work/rescue warmth and energies/ranges/shadows/time response are preserved; only lamp placement/attachments changed. Cabin entry, bench, farm/open field and rescue ground remain legible in inspected night frames. No added light is required. [Night player bench](docs/map_final_cleanup/after/night_player_workbench.png), [night farmstead](docs/map_final_cleanup/after/night_farmstead.png), [night zone sheet](docs/map_final_cleanup/contact/after_night.png).

Separate rendered night checks use real rifle firing against Normal/Runner/Tank from all four approaches (12 kills); all pass. An ordinary six-enemy Day 1 wave uses all four actual entries and starts grounded. Sixteen night combat/wave images are retained. This controlled regression gives ammunition and disables player damage; the ordinary-resource full-day test below supplies the separate natural play loop evidence. [Night log](docs/map_final_cleanup/logs/final_night.log), [combat sheet](docs/map_final_cleanup/contact/after_combat_night.png).

## 10. Navigation/camera regression result

Latest individual process/assertion/log and scope checks pass; [test results](docs/map_final_cleanup/test_results.json) retain exact evidence. Automated production input and rendered image inspection were used; there was no human keyboard playtest or new historical 40/48/52-suite certification.

| Required check | Result / evidence |
|---|---|
| Cabin front / rest and workbench access | Actual movement and interaction succeed; ordinary earned rest reaches healthy Day 2 |
| Farm walking lanes | Actual E plant and E harvest at all twelve plots pass |
| House and farm 360° / all zones / top | Complete matched 99-image survey, failures=0; final affected views refreshed |
| Navigation around buildings | 3,682 baked polygons; exact edge audit zero overlap; no final navigation warning |
| Zombie routes | All 24 Normal/Runner/Tank ×four entries ×field/interior targets reach attack through real controllers |
| Camera | 120 route camera probes plus 176 zone/edge shoulder probes clear solids |
| Bounds / grounding | Actual character reaches all four physical edges and stays grounded/inside terrain |
| Rescue reveal/ending | Road walk, four-eye/five-sample occlusion and existing rendered ending pass |
| Night | Twelve variant/entry rifle cases, grounded six-enemy ordinary wave and sixteen screenshots pass |
| Natural core loop | Ordinary finite-resource planting/growth/harvest, 40 ammo/one medicine craft, six real kills after damage, earned rest; separate damaged natural dawn passes without rest |
| Loading | Final editor import and ordinary rendered main boot pass without current parser/runtime/map errors |

The first combined rendered acceptance exceeded its external 240-second limit after movement/camera coverage. Preserve that attempt; the complete headless acceptance and separate complete rendered night run both pass without weakening assertions or controller timeouts. The first survey also exceeded 240 seconds during live-pursuit night walking; the complete scenery-only survey subsequently passed. An initial rail-endpoint type inference parser error was repaired; final import succeeds. The only excluded engine diagnostic is the pre-existing Windows root certificate-store message. Full logs remain available.

Navigation settings and every zombie controller are unchanged. The existing bake tool regenerated only the resource for finished structure collision. No rebake is needed for the final decorative tool lean.

## 11. Remaining minor issues

- Native low-poly packs retain some differing palettes, coloured shutters/log ends and a pale exterior electrical panel. Selected dominating Cabin surfaces were toned; native details remain visible.
- Existing crop/bench labels, placeholder crop art, character/weapon poses and static rescue rotor remain outside this request.
- Broad far-horizon openings remain visible from outer camera positions. The outer scenery is visual only beyond the existing ±56 m physical safety bounds.
- Environment tools, supplies, caches and the vise remain decoration, with no new inventory/crafting interactions.
- Brief profiling is hardware/debug specific. An initial 720p night p99 of 18.506 ms exceeded the 16.67 ms reference; the subsequent sample was 10.997 ms. Background activity and short sample variation prevent a sustained 60 fps guarantee. No low-end/release/human campaign certification or new export was performed.
- The historical Phase 10 EXE/PCK contains an older map; view this completed pass from current source/F5.

No unresolved current cleanup parser/runtime/navigation/assertion failure remains in the latest checks. All D01–D10 have a completed finishing treatment; there is no pending authorized implementation.

## 12. Final polish notes

The finishing pass connects structures, clears the doorway, makes the bench visually supported, curates believable supplies and turns the forced asphalt landing into an open earth clearing. Major zones, interactions, terrain shapes, plants, combat/AI/progression/balance/UI and animation remain intact.

| Metric | Before cleanup | Final |
|---|---:|---:|
| Unique decorative source models | 70 | 56 |
| Model placements /grass | 11,725 /11,019 | 11,707 /11,019 |
| MultiMesh batches | 68 | 54 |
| MeshInstance nodes | 351 | 377 |
| Day nodes | 1,130 | 1,137 |
| Static bodies /playable trunks /lights | 176 /116 /5 | 178 /116 /5 |
| Navigation polygons | 3,737 | 3,682 |

Same unmodified four-scenario profile: Godot 4.7 Compatibility/debug, RTX 4060 Laptop GPU, 600 frames per scenario after warmup, final night with twelve enemies alive. All QA render runs were completed before final profiling. The first after sample overlapped image review; the confirmation ran after capture/review work stopped. A pre-existing Godot process (PID 37336) remained untouched. OS-wide isolation was not certified; timing changes cannot be attributed solely to this cleanup.

| Scenario | Before mean /p99 ms | First after mean /p99 ms | Confirmation mean /p99 ms |
|---|---:|---:|---:|
| Day 720p | 6.765 /9.598 | 9.863 /16.121 | 8.100 /14.757 |
| Night twelve alive 720p | 7.586 /10.857 | 12.130 /18.506 | 8.169 /10.997 |
| Night twelve alive 1080p | 8.775 /12.654 | 8.099 /11.052 | 8.462 /11.632 |
| Ending 1080p | 4.998 /8.680 | 12.039 /16.121 | 5.008 /6.095 |

All confirmation p99 samples are below the 16.67 ms reference; retain the first spike as a measured limitation. Confirmation day draw calls 2,137→2,141, twelve-alive 1080p draw calls 2,258→2,273; day static memory 88.88→88.47 MB and stress memory 98.46→97.99 MB. Framing costs are small relative to the retained Cabin/grass. [Before](docs/map_final_cleanup/performance_before.json), [first after](docs/map_final_cleanup/performance_after_first.json), [confirmation](docs/map_final_cleanup/performance_after_confirmation.json).

Exactly six pre-existing production files changed: RuralEnvironment, RuralTerrain colours, EnvironmentAssets preloads, WorldPresentation decoration/light placement, Workbench visual scene and the baked navigation resource. Snapshot hashes preserve 197 other script/scene/resource files, all 244 GLBs and all 571 pre-existing asset files, including supplied game sounds. MainWorld, GameRoot, GamePresentation, gameplay/UI/character/weapon systems, project/export settings and the bake tool are unchanged. Workbench physics/interaction sections and terrain/vegetation functions additionally match. Existing unrelated dirty changes were preserved; no commit/push/export was made. [Scope](docs/map_final_cleanup/scope_audit.json), [source hashes](docs/map_final_cleanup/source_hashes.json), [production diffs](docs/map_final_cleanup/diffs).

Documentation and reproducible focused tests are complete. [Evidence index](docs/map_final_cleanup/README.md), [PROGRESS](PROGRESS.md), [test instructions](tests/README.md). **STOP. Await user map review; do not begin another system.**
