# PROJECT_ARCHITECTURE — Somchai's Last Harvest

อัปเดต 2026-09-29 — Phase 7 Night Wave & Survival Loop

## Phase 7 survival architecture (current)

- `GameRoot/NightWaveManager` (`scripts/survival/night_wave_manager.gd`) binds existing GameClock, Player and `MainWorld/WaveSpawnPoints`. DAY/ACTIVE/CLEARED/RESTING/GAME_OVER, one start per survival day; no farming/crafting/weapon dependency. `NightWaveData` + `resources/waves/day_1.tres` configure6Normal/2s/12m; same prototype config reused on later days, no difficulty progression.
- Clock is unchanged and remains source of truth. night_started begins spawning; day_started handles both natural and rest dawn. Clock owns current_day and new_day_started. State changes precede cleanup to prevent false clears/reentry.
- `ZombieSpawnFactory` shares navigation projection, proximity and capsule occupancy validation with debug spawner. Cardinal wave points are (0,-20),(20,0),(0,20),(-20,0) in X/Z. Blocked markers retry; deterministic round-robin. Wave instances and debug instances are separate populations.
- Wave tracking: dictionaries keyed by instance ID, one alive set plus tracked corpses. Remaining = total - spawned + alive. died removes alive immediately; tree exit only cleans corpses. Unexpected living removal returns a pending spawn. No scene-tree polling.
- NormalZombie adds per-instance pursue_target for distant wave attackers and despawn for administrative cleanup without death credit. Existing movement, Health receiver, attack timing and animation remain. All enemies only target Somchai.
- `GameRoot/RestSystem` + `MainWorld/Bed` (`scenes/interactables/Bed.tscn`) use E interaction. CLEARED night accepts rest, locks controls/aim and pauses gameplay for0.35s; then existing HP heal/stamina reset and Clock.skip_to_day. Abort handles death/unload and releases pause. Plants use existing elapsed timestamp notifications during time skip.
- Natural dawn: state DAY, disable/despawn tracked enemies, clear counters, emit morning feedback; no stat restore. GAME_OVER stops spawning/clock and cleans wave, R scene reload restores defaults. This dawn despawn rule is a demo design decision.
- HUD NightLabel shows remaining/alive/incoming, clear/rest state; feedback adds17:00 warning/night/day announcements. Debug bag adds17:50/start-night/kill-active/05:50/dawn; map marker meshes/labels follow debug visibility. Debug kill does not bypass pending spawns.
- Bed is solid World+Interactable at(-10.5,0,-7); nav rebaked to63polygons. Existing collision masks retained. Re-run tools/bake_prototype_navigation.gd after static geometry edits.
- Tests: phase_7_lifecycle_test (headless/rendered edge cases), phase_7_full_day_test (normal production clock/input and resources, two complete Day1 scenarios without cheats). See PHASE_7_TEST_REPORT.md. Next scope awaits Phase8 prompt.

## Phase 6 enemy foundation (historical settings extended above)

- `scripts/data/zombie_data.gd` / `resources/enemies/normal_zombie.tres`: immutable identity, tuning, visual scene and animation names. Runtime health and timers are per instance.
- `scenes/enemies/NormalZombie.tscn` / `scripts/enemies/normal_zombie.gd`: CharacterBody3D with Visual, capsule, NavigationAgent3D, existing Health and DebugLabel. Four local states: IDLE, CHASE, ATTACK, DEAD. No general-purpose state framework.
- `MainWorld/NavigationRegion3D`: committed `resources/navigation/prototype_navigation.tres`, 59 polygons baked from World static colliders. `tools/bake_prototype_navigation.gd` reproduces the bake, including the separate TestInteractable prop. Rebuild when static geometry changes. Radius0.5m/height1.8m protects the radius0.38m body; no dynamic rebake/crowd avoidance.
- `MainWorld/ZombieTestSpawner` / `scripts/enemies/zombie_test_spawner.gd`: five Marker3D spawn points, validated navigation and collision clearance, instance limit5. GameRoot injects Player and DebugControls; spawned zombies receive Player directly. Debug bag buttons spawn1/spawn3/clear. No default enemies or clock/wave dependency.
- Detection uses 12m distance; Chase refreshes destination every0.3s and consumes agent path each physics tick. Solid body motion, gravity, smooth facing. Melee stops movement at1.35m, winds up0.3s, rechecks range/World obstruction and deals10 through Player Health; each zombie has1.2s cooldown.
- WeaponController remains generic: collider child `Health` receives damage. Enemy100HP dies after5rifle hits. Flash confirms hit; death disables collision and AI, plays animation, removes after1.2s. Existing player HUD/death/control gates remain.
- Collision bits: World1, Player2, Interactable4 unchanged; Enemy8 added. Player mask9, Enemy mask11, aim/weapon masks13. Melee and navigation mask1. Farm Areas are not solid enemy obstacles; plants are not targets.
- Zombie.glb actual clips: Idle, Walk, Punch, Death. Libraries duplicated per instance before loop changes. Source assets unchanged. Debug state/HP labels hide with debug. No audio/headshot/root-motion/save/variant logic.
- Future Wave caller can use factory and `died`; delayed tree exit is cleanup, not wave-clear notification. Controller stops on invalid/dead target and supports explicit rebind. Wave policy/population limits remain Phase7 work.
- Full verification: 33 runs passed, with focused updated Phase6 reruns. Report: PHASE_6_TEST_REPORT.md. The foundation tree below predates these additional nodes.

## Phase 5 weapon architecture (retained; collision masks extended above)

- `GameRoot` grants canonical starter rifle ItemData, equips slot 0, then binds `Player/WeaponController` to Inventory, EquipmentLoadout, GameplayMode, camera and ItemCatalog. HUD binds weapon state/feedback/hit signals. Default magazine/reserve are zero.
- `scripts/data/weapon_data.gd` / `resources/weapons/basic_rifle.tres`: immutable definition, validated scene/muzzle, ammo and weapon catalog references, damage/rate/magazine/reload/range/auto/spread/recoil. `resources/items/basic_rifle.tres` is the owned WEAPON item.
- `scripts/weapons/weapon_runtime.gd`: mutable magazine/cooldown/reload state per owned ID. `weapon_controller.gd`: selection, visual lifecycle, firing/reload gates, cooldown remainder, reserve consumption and ray damage. Equipment remains 3 configurable slots, one reference per unique ID; unequipping preserves runtime while ownership remains.
- `Player/Visual/WeaponSocket` hosts `scenes/weapons/BasicRifle.tscn`. A runtime BoneAttachment3D follows Middle1.R position at unit scale; +Z model points at existing CameraAimRay. Socket fallback is available. Original GLBs and camera/movement scripts remain unchanged.
- Camera center ray supplies aim point -> safety ray from body to muzzle -> muzzle ray toward aim point up to weapon range. Mask5 excludes player. Collider child `Health` receives existing `take_damage`; `hit_confirmed` flashes the crosshair. No enemy class dependency.
- `MainWorld/TargetDummy` uses `scenes/combat/TargetDummy.tscn` and `scripts/combat/target_dummy.gd`: 100 HP HealthComponent, label, flash, collision disabled/removal on death.
- Ammo flow: farm materials -> existing recipe exchange -> Inventory Basic Ammo -> timed reload completion consumes missing rounds -> runtime magazine -> firing consumes one. Cancel reload on controls/mode/selection/death without consuming reserve. There is no separate reserve counter.
- LMB (`fire`) requires Combat + aim; R (`reload`) requires live Combat and remains restart when dead. Menus use existing camera controls gate. HUD AmmoLabel shows name/slot/magazine/reserve/reload; debug bag can grant a finite 30 rounds only when debug is enabled.
- New scene/resource/script paths are listed above; the foundational tree below omits those additional children for readability. Historical phase sections below describe their original scope; current production includes weapon behavior described here.
- Verification: 31 runs passed; see PHASE_5_TEST_REPORT.md. Next: Phase 6 Zombie AI & Basic Enemy Combat after its prompt. No projectile, special ammo effects, AI, audio, save or dedicated aim/reload animations are implemented.

## Runtime foundation

Godot 4.7, Compatibility renderer, viewport1280×720, physics60 Hz. Main scene `scenes/main/GameRoot.tscn`; desktop prototype, ไม่มี autoload/addon. กล้องและทิศหัน movement รองรับ normal/aim แล้ว; HP/stamina/clock/lighting และ farming/inventory ยังคงใช้ฐาน Phase 2–3. Root ทำ dependency wiring โดยตรง; ยังไม่ต้องเพิ่ม global event bus หรือ manager ที่ไม่มีหน้าที่.

```text
GameRoot (game_root.gd; catalog + starter_loadout + recipe_book Resources)
├── MainWorld
│   ├── Ground / boundaries / shelter / spawn / rescue markers
│   ├── PlayerSpawn
│   ├── FarmArea
│   │   └── FarmPlot ×12 (instances, 3×4)
│   │       ├── Soil / interaction collision / Status label
│   │       └── PlantAnchor → Plant (runtime)
│   │           ├── ModelRoot → NaturePlantVisual → Plant.glb
│   │           └── SeedMarker / Produce
│   ├── Workbench (Interactable; reusable scene)
│   └── WorldEnvironment / Sun / ShelterLight
├── Player (CharacterBody3D)
│   ├── Collision / Visual → Matt
│   ├── CameraPivot (yaw) → Pitch → ShoulderOffset → CameraBoom → Camera3D
│   ├── AimRay (CameraAimRay)
│   ├── Interactor / Health / Stamina
│   ├── Inventory (owned items + dynamic seed selection)
│   ├── EquipmentLoadout (equipped weapon references)
│   └── GameplayMode (Farming/Combat + central wheel router)
├── TestInteractable
├── TimeController (GameClock)
├── DayNightEnvironment
├── HUD → Root/Crosshair + AimDebugLabel
├── DebugControls
├── InventoryUI (Always, layer10; bag + equip controls)
├── PauseMenu (Always, layer20; mutually exclusive with bag/crafting)
├── CraftingSystem (inventory + RecipeBook + clock)
└── CraftingUI (Always, layer15; mutually exclusive with bag/Pause)
```

## File layout

```text
res://
├── Asset/                           # Original 243 GLBs, unchanged
├── assets/ui/items/                 # 10 prototype SVG icons
├── resources/
│   ├── catalog.tres                 # 14 ItemData + 5 PlantData references
│   ├── items/                       # 5 seed + 5 harvest material + 3 crafted item + 1 rifle .tres
│   ├── plants/                      # 5 .tres
│   ├── recipes/                     # RecipeBook + 3 CraftRecipe .tres
│   └── inventory/starter_loadout.tres
├── scenes/
│   ├── main/GameRoot.tscn
│   ├── world/MainWorld.tscn
│   ├── player/Player.tscn
│   ├── interactables/{TestInteractable,Workbench}.tscn
│   ├── farming/{FarmPlot,Plant,NaturePlantVisual}.tscn
│   └── ui/{HUD,InventoryUI,PauseMenu,CraftingUI}.tscn
├── scripts/
│   ├── main/game_root.gd
│   ├── player/{player_controller,camera_rig,player_visual,aim_ray,gameplay_mode_controller}.gd
│   ├── components/{health_component,stamina_component}.gd
│   ├── interaction/{interactable,interactor}.gd
│   ├── time/game_clock.gd
│   ├── world/day_night_environment.gd
│   ├── debug/debug_controls.gd
│   ├── data/{item_data,plant_data,item_catalog,inventory_loadout,recipe_entry,craft_recipe,recipe_book}.gd
│   ├── inventory/{inventory,inventory_slot,equipment_loadout}.gd
│   ├── farming/{farm_plot,plant_visual}.gd
│   ├── crafting/{crafting_system,workbench}.gd
│   └── ui/{prototype_hud,inventory_ui,aim_crosshair,pause_menu,crafting_ui}.gd
├── tests/                           # 21 GDScript tests + runner + fixtures
└── docs/{phase2,phase3,camera,input,phase4}/      # Renderer evidence
```

Phase 4 เพิ่ม production scripts6ไฟล์, scenes2ไฟล์ และ resources7ไฟล์; test fixture Resources ของ Phase 3 แยกจาก demo catalog.

## Static definitions and runtime state

| Type | Responsibility / fields |
|---|---|
| ItemData Resource | Unique `id`, display name, description, Texture2D icon, max_stack, item_type, seed plant_id/plantable/tier/display_order |
| PlantData Resource | plant_id/name, seed_item, harvest_item/amount, growth_minutes, stage names/thresholds/scales, visual_scene/stage_visuals, produce_color |
| ItemCatalog Resource | Definitions and lookup byID; duplicate/cross-reference/shape validation |
| InventoryLoadout Resource | Starter ItemData array + quantities; validates bundle capacity before giving |
| InventorySlot RefCounted | Runtime ItemData reference + quantity; no node/scene per item |
| Inventory Node | Slots/capacity, quantity APIs, selection, inventory_changed/selection_changed |
| FarmPlot | Runtime planted_time/PlantData/progress/stage/state/visual; EMPTY→PLANTED→READY→EMPTY |
| RecipeEntry / CraftRecipe / RecipeBook | ItemData+quantity; formula/category/outputs/unlock_day; registry validation/duplicate ID |
| CraftingSystem | Revalidate recipe and inventory, execute one guarded inventory exchange |
| Workbench / CraftingUI | Existing E interaction opens paused recipe UI; UI reads data and shows current inventory |

ไม่เขียน quantity, growth, HP หรือเวลาลง static `.tres`. Seed link ใช้ stable `plant_id` แล้วค้นใน catalog; PlantData อ้าง seed/harvest ItemData. เป็นการเลือกวิธี implementation ของแผน Resources เดิมเพื่อหลีกเลี่ยง circular `.tres` references และไม่ต้องเพิ่ม subclass ของ SeedData. ไม่สร้าง script แยกแต่ละพืช.

Catalog validation ทำตอน root พร้อมใช้งานก่อน bind plots. Dataผิดพิมพ์ error พร้อมชื่อID/field และไม่เปิดใช้แปลง. FarmPlot ตรวจ data อีกครั้งก่อน consume เมล็ด; ป้องกัน null errors และของหาย. ห้ามแก้ arrays ของ Resource ที่ shallow-copy มาโดยคิดว่าแยกแล้ว; ใช้ `Array.duplicate()` ก่อนแก้ catalog สำเนา.

## Inventory contract

`add_item(ItemData, amount) -> bool`, `remove_item(id, amount) -> bool`, `has_item(id, amount=1)`, `get_item_amount(id)`, `can_add_item`, `can_exchange_items`, `exchange_items`, `get_slots`, `select_seed`, `get_selected_seed`, `clear`.

Add/remove เป็น all-or-nothing ต่อคำขอหนึ่ง item. วางเข้า stack เดิมก่อนเปิด slotใหม่. คืนfalseเมื่อจำนวนไม่เป็นบวก,ข้อมูลผิด,ของ/พื้นที่ไม่พอ หรือIDนั้นใช้definitionอื่นอยู่แล้ว. Snapshot slots แก้เองแล้วไม่เปลี่ยน live inventory. Phase 4 `exchange_items` จำลองการลบวัตถุดิบทุกชนิดก่อนเพิ่มผลลัพธ์ทุกชนิดในสำเนา; commitได้จึง emit `inventory_changed` ครั้งเดียว. Output จึงใช้ slot ที่วัตถุดิบหมด stack เปิดให้ได้ และ failure ไม่เสีย item.

Inventoryเก็บselected_seed_idแยกจากbag slot. get_selectable_seedsรวมIDที่เป็นSEED+plantable+quantity>0และเรียงtier/display_order/ID. Mutationซ่อมselectionก่อนinventory_changed; หมดแล้วเลือกตัวถัดไปตามprogressionและwrap, ไม่มีseedแล้วclearID. เพิ่มของไม่รบกวนselectionที่ยังvalid. เริ่มเกมเลือกseedแรกอัตโนมัติ. ไม่จำกัดจำนวนช่องselector; capacityของInventoryยังเป็นคนละกติกา.

InventoryUIเปิดด้วยtoggle_inventory=Tab; click/keyboardเลือกseedหรือownedweapon. SceneTreepauseขณะเปิด, UIเป็นAlways. Tab/Esc/Closeคืนpauseเดิม; opened_changedเชื่อมcamera menu gateเพื่อrelease/capturecursorและclearheldaim. PauseMenuรับEscเมื่อbagปิด; ถ้าbagเปิดจะปล่อยให้InventoryUIปิดbagครั้งเดียว. TabขณะPauseไม่เปิดbagซ้อน. หน้าต่างไม่ใช้pause/cursorlogicซ้ำกับCameraRig.

## Phase 4 crafting contract

`RecipeEntry` อ้าง `ItemData` จริง+quantity; `CraftRecipe` มี ID, category (Ammo/Medicine/Weapon/Utility/Defense/Material), ingredient/output arrays, `craft_amount`, `unlock_day`. `RecipeBook` เป็น registry ของ Resources; GameRootตรวจ empty/duplicateID, item reference ให้ตรง canonical ItemCatalog และ quantity ก่อน bind. สูตรใหม่เพิ่ม data ลง catalog/book โดยไม่แก้ CraftingSystem หรือ CraftingUI. Basic Ammo x10, Basic Medicine x1, Metal Component x1 ทั้งหมดเป็น **TEMPORARY BALANCE** และ unlock Day1. Basic Ammo มี ItemType.AMMO สำหรับ phase ถัดไป; Medicineเป็นCONSUMABLEแต่ยังไม่มี use/heal.

`CraftingSystem.failure_reason` เช็ค data, Day gate, วัตถุดิบจริงและ capacity หลัง consume; `craft` เช็คอีกครั้ง, `_busy` กัน callbackซ้อน, แล้วเรียก Inventory.exchange_items. Craftครั้งละหนึ่ง batch. มีหลาย output ได้และปฏิเสธแบบ atomic หาก outputใดใส่ไม่ครบ. Inventoryเป็นเจ้าของ quantities/stackingและ signalเดียว; CraftingSystemไม่รู้ Player/Camera/FarmPlot.

Workbench scene extends `Interactable`, ใช้ layer3/range/line-of-sight/Eเดิม; GameRootฟัง workbench_requested แล้วเปิด CraftingUI. UI สร้าง list จาก RecipeBook, แสดง owned/required, output, lock/failure/success. CanvasLayer Always pause treeเหมือน bag; camera menu gate จัด cursor/aim. Escปิด craftingก่อนPause; Tabไม่เปิด bag ซ้อน; Q/wheel/clockหยุดขณะ menu เปิด. Mode Farming/Combatไม่เปลี่ยนเมื่อเข้า/ออก.


## Interaction and farming contract

ใช้ `PlayerInteractor` เดิม: sphere query radius2.8m, layer3 (bit4), ตรวจline of sightผ่านworld layer1. เพิ่มที่ `Interactable` เพียง `prompt_changed` กับ `get_interaction_text(actor,key_hint)`; HUDติดตามtargetและsignal เพื่อไม่ต้องเดินออก/เข้าใหม่เมื่อแปลงเปลี่ยนstate. TestInteractableเดิมยังแสดง `[E] Test interaction`.

FarmPlotตรวจFarmingmodeทั้งis_availableและinteract; Combatไม่ปลูกหรือharvest. ตรวจseedtype/plantable/ownership/mapping/empty stateก่อนconsume1seed. `_busy` กันการเรียกซ้อนจากinventory signals. READY→harvestใช้ atomic inventory.add_item; สำเร็จจึงล้างPlant/Plot. กระเป๋าเต็มหรือมีstackspaceไม่ครบyieldจะคงพืชไว้ทั้งหมดพร้อมข้อความ. ไม่spawnpickupในPhase 3.

PlantVisualใช้Plant sceneกลาง. NaturePlantVisual wraps `Plant.glb` scale0.65. Stage0ใช้seed marker; stage1/2เพิ่มscale; stage3เพิ่มproduce markerสีของชนิดนั้น. `stage_visuals` รองรับเปลี่ยนsceneแต่ละระยะภายหลังโดยไม่แก้core. มีสถานะ/เปอร์เซ็นต์ทั้งworld labelและinteraction prompt.

## Clock, growth and pause decisions

- Day1เริ่ม06:00; วันเพิ่มเมื่อ06:00ถัดไป ไม่ใช่เที่ยงคืน. กลางวัน06–18/กลางคืน18–06.
- 12game hours =600real secondsที่x1. F10ใช้x20. Clockเดิมส่งtime_changedทุกgame minute; no per-plant frame loop.
- Growth = elapsed game minutesจากplanted_timeหารduration. คำนวณได้ข้ามdusk/dawn/หลายวัน. กลางคืนไม่หยุดgrowth.
- Clock-minute precisionทำให้visual/readyอาจช้าไม่ถึง1game minute (~0.833sจริงที่x1). Day/nightไม่เปลี่ยนgrowthrate.
- Debug rewindไม่ลดprogress/ready; growthรอเวลาไล่ทัน timestamp. DebugGrowAllข้ามclockจนทุกต้นพร้อม+boundaryminute;ไม่ปลอมstateแยกจากระบบเวลา.
- Inventorypauseหยุดworld/clock/growth. ปุ่มdebugadvanceในmenuเป็นexplicittimejumpและระบุไว้ในUI. F1ปิดdebugคืนtimescale1/clockunpaused แต่ไม่ยกเลิกSceneTreepauseของmenu.
- HP0ปิดinventoryและหยุดplayerinteraction. Clockยังเดินเมื่อตายตามPhase 2. Rreloadmainจะรีเซ็ตinventory/plots; ไม่มีsave.

## Existing foundation contracts retained

Player4m/s, sprint7m/s, acceleration24, braking30; camera-relative movementและgravity/collision. Capsuleheight1.7/radius0.32. Aim walk2.8m/s, turn12/s; normalหันตาม movement และ aimหันตาม camera yaw. Camera architecture อยู่ด้านล่าง. PlayerVisualเล่นMattIdle/Walk/Run/Death; knifepropซ่อน.

Health100 clamp/damage/heal/deathครั้งเดียว. Stamina100 drain22/s, recovery18/sหลัง1.2s; หมดแล้วต้องฟื้น25%ก่อนวิ่ง. HUDbindstats/clock/interaction/debugเหมือนเดิม. Physicslayers:1World,2Player,3Interactable. Farmplotใช้layer3เท่านั้นจึงเดินผ่านได้; TestInteractableยังชนworld.

`GameClock.advance_game_minutes` ส่งทุกdawn/duskแม้ข้ามหลายวัน; `seek` สำหรับdebugไม่replayprogressionevents. `DayNightEnvironment` เปลี่ยนsun/ambient/backgroundจากclock. ไม่มีการrewriteระบบเหล่านี้ในPhase 3.

## Shoulder camera and aiming contract

`ThirdPersonCamera` รับผิดชอบ captured raw mouse look, yaw/pitch, aim state, shoulder side, framing transitions, collision และ cursor lifecycle. `PlayerController` ส่ง actual sprint status และอ่าน is_aiming; physics root ไม่หมุนตาม Visual. Normal turnตาม movement; aim turnตาม −CameraPivot.global_basis.z. Matt author+Z ยืนยันจาก foot rest ทั้งสองข้างและ source GLB endpoint (+Y local), dotกับVisual+Z0.999993. PlayerVisualยังเล่นIdle/Walk/Run/Deathเดิม.

Hierarchy ที่แยกหน้าที่: CameraPivot yaw/height → Pitch → ShoulderOffset X → CameraBoom +Z → Camera3D. กล้อง parent ตาม Player โดยตรง. Normal4.2m/70°/+0.70m, aim2.6m/55°/+0.85m; height1.65m; clamp−65..+45°. ค่า exportรวม sensitivity, transition10/s, return8/s, radius0.22m, margin0.04m. ดูตารางครบใน PHASE_CAMERA_TEST_REPORT.

Collision: sphere sweep ด้านข้างก่อนด้านหลัง, maskWorld1, exclude Player RID. intersect_shape ตรวจ overlap ก่อน cast_motion. Pull-inทันทีและ ease-out; refreshพร้อม mouse angle เปลี่ยน (ไม่รอ tickถัดไป) และหลัง physics movement. ไม่มี smoothing บน mouse displacement; FOV/offset/distanceใช้ exponential delta.

Aim signals: `aim_changed(bool)`, `controls_changed(bool)`, `pose_updated`. `GameRoot` เชื่อม inventory opened_changed และ health changed เข้ากล้อง; ไม่เพิ่ม referenceย้อนกลับไป inventory. Sprintจริง clear aim แต่เก็บ heldRMBเพื่อกลับaimเมื่อจบ; menu/focus/pause/death/Esc clear heldRMB. Esc gameplayเปิดPauseและclearheldRMB; Esc/Resumeคืนcapture. Tab/Escปิดbagrecapture. Qเปลี่ยนFarming/Combat; Vเปลี่ยนไหล่. Mode controllerส่งset_combat_enabled; Farmingไม่รับAim. Arrowkeys fallbackปิดตอนmenu/paused.

`CameraAimRay` bindกับ camera/player/debugโดยRoot. ฟัง pose_updated แล้วใช้viewport center project_ray_origin/normal; closest-hit raymask5, excludePlayer, range100m. ข้อมูล public `aim_origin`, `aim_direction`, `aim_point`, `has_hit`, `hit_normal`, `hit_collider`; ส่ง `sample_updated`. Missใช้origin+direction*range. ไม่มี damage หรือ weapon logic.

`AimCrosshair` วาดกลางControlเต็มviewport; จางในCombatnormalและชัดในCombataim; ซ่อนในFarmingหรือเมื่อcontrolปิด. Debug F1 gatedด้วยdebug_enabled/debugbuild แสดงhit pointและทิศcamera/visualเฉพาะตอนaim. Markerไม่มีcolliderและไม่สร้าง nodeใหม่ต่อเฟรม.

Future Weaponอ่านaim state/targetผ่านsignalsนี้. ต้องเพิ่มmuzzle obstruction checkแยกจากcamera rayเพื่อไม่ยิงทะลุcoverที่มุมกล้องมองข้ามได้; ยังไม่ได้ implement. Aim animation/IK/strafe clipsเป็นtechnical debt. **Camera phaseไม่เริ่มระบบยิงหรือคราฟต์.**

## Gameplay modes / equipment / input ownership

`GameplayModeController` enumFARMING/COMBATเริ่มFARMING; `_unhandled_input`รับQและwheelที่เดียว. ถ้าcamera.can_control=false/paused/deadจะไม่route. FARMING→Inventory.cycle_seed; COMBAT→EquipmentLoadout.cycle_weapon. Mode switchclearAimเมื่อออกจากCombatและไม่resetselection/stamina/position/camera. mode_changedแจ้งHUDและInteractorrefreshทันที.

Inventoryรับผิดชอบowneditemsกับseedselectionเดิม. EquipmentLoadoutรับผิดชอบequippedreferences, count(default3), selected_weapon_slot(default−1) และequipment_changed. RootbindInventoryเข้ากับEquipment, แล้วModeเข้ากับInventory/Equipment/Camera. ไม่มีcomponentฟังmousewheelเพิ่ม.

Equipment APIs: equip_weapon(slot,ItemData), unequip_weapon(slot), get_equipped_weapon(slot), get_selected_weapon(), cycle_weapon(direction), configure_slots(count). APIindex0..N−1, HUD1..N. Equipต้องownedWEAPONdefinitionตรงInventory;ไม่consumequantity. ย้ายreferenceที่เคยequipแล้วไปช่องใหม่;ไม่ซ้ำหลายช่อง. เมื่อquantity0/clearinventory/shrinkslotsจะpruneและเลือกvalidnextslot. Wheelเฉพาะoccupiedslots. โครงสร้างยังเป็นItemDataต่อID ไม่ใช่weaponinstanceที่มีammo/durabilityเฉพาะชิ้น.

InventoryUIมีownedweaponcandidateแยกจากselectedseed. คลิกweaponแล้วslotเพื่อequip, ×unequip. HUDฟังmode/inventory/equipmentแสดงmode/seedquantitytierหรือweapon/slot. Demoไม่มีproductionweaponitems; testสร้าง5weaponsชั่วคราวเพื่อทดสอบequip3และexclude2ที่เหลือ. ไม่มีfiring/weaponvisual/ammo/reload.

ItemData tier>=1, display_order>=0, plantabledefaultfalse. Seedsเดิมexplicittrue tier1 order10..50. Tier2FirePepper/Water, tier3Ice/Poison, tier4+Electric/Rare/Specialยังเป็นconcept; metadataพร้อมแต่ไม่สร้างunlocksystem. Fixturetestplantใช้tier2และผ่านdataextensionregression.

Input Map: Tab toggle_inventoryแทนI; Q switch_mode; V switch_shoulderแทนQ; wheel4/5 cycle_item_previous/next; Esc pauseแทนrelease_mouse. Rยังrestartเฉพาะdead; LMBไม่ยิง. Camera capture_mousefallbackยังใช้เฉพาะdebug release API; gameplaymodalกลับแล้วcaptureอัตโนมัติ.

## How to add another ordinary plant

1. สร้างmaterial ItemData `.tres` พร้อมIDที่ไม่ซ้ำ/icon/max_stack/typeMATERIAL.
2. สร้างseed ItemData `.tres` typeSEED, plantable=true, plant_id, tierและdisplay_orderที่ต้องการ. Tierเก็บที่seed ItemDataเพียงแหล่งเดียว; PlantDataอ้างseedนั้น.
3. สร้างPlantData `.tres` ผูกseed/harvest, yield/duration/stages/visuals.
4. เพิ่มitemsทั้งสองและplantลง `resources/catalog.tres`. เพิ่มstarterloadoutเฉพาะเมื่ออยากแจกในdemo.
5. รันvalidatorและruntimeปลูก→โต→เก็บ→ปลูกซ้ำ. ไม่แก้FarmPlot/PlantVisual/Inventory.

ตัวอย่างครบอยู่ใน `tests/fixtures/{seed_test,test_material,test_plant}.tres` และ `phase_3_extension_test.gd`. Fixturesนี้ลงทะเบียนในcatalogสำเนาระหว่างทดสอบ; productionยังมี5ชนิด.

## Asset import and next scope

OriginalGLBs243ไฟล์ไม่ถูกย้ายหรือแก้. Shared importer default `gltf/embedded_image_handling=3`; generated `Asset/**/*.glb.import` ignoreไว้. ถ้าปรับper-assetimportอนาคตให้เริ่มtrackmetadataนั้น. SVGiconsใหม่มีimportmetadataตามGodotปกติ. `docs/.gdignore` กันภาพเอกสารจากassetimport.

Resource/sceneอนาคตยังเป็นWeaponData/ZombieData, Chest/ItemPickup/Zombie และ coordinator เมื่อมีหน้าที่จริง. Phase 4 ยังไม่สร้าง Shooting/Wave/Shop/Sleep/Save/Ending. ดูผลจริงและข้อจำกัดใน `PHASE_4_TEST_REPORT.md`.


Current verification: 29 runs, failures=0 รวม Phase 4 rendered test; รายงานปัจจุบัน `PHASE_4_TEST_REPORT.md`. Source GLBs ไม่ถูกแก้ใน Phase 4. Camera/input reportsเป็นผล historical milestone.
