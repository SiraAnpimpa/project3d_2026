# PROGRESS — Somchai's Last Harvest

## Current: Phase 6 complete, runtime verified (2026-09-29)

- Implemented ZombieData, NormalZombie scene/controller and debug test spawner. IDLE / CHASE / ATTACK / DEAD, 12m detection, navigation every0.3s, 2m/s walk, 10 damage with0.3s windup/1.2s interval, shared Health and1.2s delayed death.
- Added baked prototype NavigationRegion (59 polygons) and reproducible tools/bake_prototype_navigation.gd. Static World geometry and TestInteractable included. Enemy layer8; player mask9, aim/weapon masks13; old layer4 remains Interactable.
- Actual Zombie.glb inspected: Idle, Walk, Punch, Death integrated; hit flash without stun. Original assets unchanged. No wave/night spawn or enemy variants.
- Added tests/phase_6_zombie_test.gd. Focused headless checks pass including obstacle/shelter routing, close gun hits, live reload, 3/5 agents and rifle kills, player death and cancellation. Full suite 33/33 passed (import +23 headless +boot +8 rendered); logs .godot/test-logs/phase6_final/. Focused test expanded with actual sprint and debug UI click, then headless/rendered rerun passed. Natural Lead growth 30.409s.
- Created scripts/data/zombie_data.gd, scripts/enemies/{normal_zombie,zombie_test_spawner}.gd, scenes/enemies/NormalZombie.tscn, resources/enemies/normal_zombie.tres, resources/navigation/prototype_navigation.tres, bake tool and PHASE_6_TEST_REPORT.md.
- Modified Player/MainWorld scene settings, GameRoot wiring, debug controls/bag spawn buttons, layer names, test runner. Core weapon/player/health/farming scripts not rewritten.
- Limits: static nav requires rebake after geometry changes, capsule-only hits, timer melee timing, no crowd avoidance/audio/headshots. Pack fixture heals the player for prolonged observation; player death is tested separately.
- Next exact step: wait for Phase 7 - Night Wave & Survival Loop prompt. No wave system started. Evidence and limits: PHASE_6_TEST_REPORT.md; inspected captures: docs/phase6/.

## Historical Phase 5

## Phase 5 complete, runtime verified (2026-09-29)

- Data-driven WeaponData, separate WeaponRuntime, WeaponController and starter Basic Rifle equipped in slot 1. Existing three configurable slots retain magazines per owned weapon ID.
- Combat + RMB + LMB hitscan from muzzle toward camera aim point, cover and barrel penetration checks. R reload consumes crafted Basic Ammo from Inventory on completion. Initial magazine/reserve are zero.
- Target Dummy at (3, 0, -8), existing HealthComponent, 100 HP, damage flash and death. Rifle: damage20, 5shots/s, mag10, reload1.5s, range60m. Temporary balance.
- HUD name/slot/mag/reserve/reloading, hit marker and muzzle flash. Debug-gated +30 ammo. Menus, mode changes, switching and death cancel reload without consuming ammo.
- Created: scripts/data/weapon_data.gd, scripts/weapons/{weapon_runtime,weapon_controller}.gd, scripts/combat/target_dummy.gd; scenes/weapons/BasicRifle.tscn, scenes/combat/TargetDummy.tscn; resources/items/basic_rifle.tres, resources/weapons/basic_rifle.tres; tests/phase_5_weapon_test.gd; PHASE_5_TEST_REPORT.md; docs/phase5/ captures.
- Modified: input map, catalog, GameRoot/Player/MainWorld/HUD scenes, root wiring, HUD/crosshair/debug UI, runner and startup/catalog expectation tests, project documentation. Camera, PlayerController and Inventory core scripts unchanged.
- Final suite: 31/31 runs passed (import, 22 headless, boot, 7 rendered). Full farming/craft/reload/aim/fire/death loop, obstruction, partial reload, spam, state retention, 30/120Hz rates and regressions pass. Logs .godot/test-logs/phase5_final/. Natural rendered Lead growth: 30.384 seconds.
- No functional bugs reproduced. Debt: idle/walk arms without dedicated aim/reload animation or IK, placeholder icon/dummy/flash, no audio/save/duplicate individual weapon instances. No human long-session/export/performance test.
- Next exact step: wait for Phase 6 - Zombie AI & Basic Enemy Combat prompt. Do not start AI. See PHASE_5_TEST_REPORT.md for architecture, evidence and limitations.

## Historical Phase 4 status

อัปเดต 2026-09-29 — **Phase 4 Crafting & Workbench เสร็จและ runtime verified**

## Current Phase 4 status

- RecipeEntry/CraftRecipe/RecipeBook Resources, category, outputหลายชนิด, `craft_amount`, `unlock_day` และ validation/duplicate ID พร้อมใช้งาน. สูตร Day 1: Basic Ammo (Lead1+Paper1+Copper1→10), Basic Medicine (Small Herb2→1), Metal Component (Iron2+Copper1→1). **TEMPORARY BALANCE**.
- ItemCatalog เพิ่ม crafted ItemData3รายการ; Basic Ammo typeAMMO, Medicine typeCONSUMABLE, Metal Component typeMATERIAL. ใช้ icon เดิมเป็น placeholder. ไม่มี shooting/reload/medicine usage.
- Inventory เพิ่ม `can_exchange_items`/`exchange_items` ที่จำลอง stack หลัง consume และก่อน add; commitครั้งเดียวพร้อม `inventory_changed`. CraftingSystem ตรวจสูตร/วัน/ของ/พื้นที่ใหม่ทุกครั้งและกัน reentrant craft.
- Workbench reusable scene แทน placeholder ใน MainWorld ใกล้ farm; ใช้ PlayerInteractor และ E เดิม. CraftingUI สร้าง recipe list จาก data, แสดงจำนวน/เหตุผล/ผล craft, pauseเวลา, release mouse, cancel aim, Escปิดก่อนPause, ไม่ซ้อน TabBag; กลับ mode เดิม.
- Files created: `scripts/data/{recipe_entry,craft_recipe,recipe_book}.gd`, `scripts/crafting/{crafting_system,workbench}.gd`, `scripts/ui/crafting_ui.gd`, `scenes/interactables/Workbench.tscn`, `scenes/ui/CraftingUI.tscn`, `resources/items/{basic_ammo,basic_medicine,metal_component}.tres`, `resources/recipes/{basic_ammo,basic_medicine,metal_component,book}.tres`, `tests/phase_4_crafting_test.gd`, `PHASE_4_TEST_REPORT.md`, `docs/phase4/` captures.
- Files modified: Inventory, ItemData, catalog, GameRoot/MainWorld, InventoryUI/PauseMenu, test runner, Phase 3 catalog-count tests, PROGRESS/PROJECT_ARCHITECTURE/DEVELOPMENT_PLAN/tests README.
- Tests: final 29-run suite exit0/failures0 (import, 21 headless scripts, boot, 6 rendered); Phase 4 end-to-end E plant/harvest/workbench/craft, full bag, stack reuse, reentry/spam, data-only two-output recipe, Day 2 lock, duplicate/invalid recipe all pass. Rendered Phase 3 growth 30.382s at x1. Details in `PHASE_4_TEST_REPORT.md`.
- Known issues: no failures reproduced in automated runs; human playthrough/export not performed. Technical debt: placeholder art/balance, no save, medicine use and weapon behavior deferred.
- **Next exact step:** stop Phase 4 here. Await a separate Phase 5 request for Weapon & Shooting Foundation; do not start gun behavior from this task.

## Previous input/selection milestone (historical)

อัปเดต 2026-09-29 — **Input / Inventory Access / Item Selection เสร็จแล้ว**

## Current status

Godot4.7 / Compatibility; F5เปิดGameRoot. เริ่มFARMING, dynamicseedselectionและequipment3slotsแยกกัน; QสลับCOMBATเพื่อAim. Final **27/27runs exit0, failures=0** รวมrenderer. หยุดรอpromptถัดไป; ไม่มีGunShooting/ammo/reload/weapon damage. ไม่ได้commit/push.

## งานที่เสร็จ

- อ่านCamera progressและตรวจinput/UI/inventory/farm. Backup `work/input_backup/`; baseline20headlessrunsผ่านก่อนแก้.
- เปลี่ยนtoggle_inventory binding I→Tab; Qเป็นswitch_mode; VแทนQสำหรับswitch_shoulder; Escเป็นpause; wheelup/downเป็นcycle_item_previous/next. ไม่มีactionซ้ำ.
- GameplayModeControllerใหม่ defaultFARMING รับwheelกลางที่เดียว. Modeแต่ละตัวจำseed/weaponของตัวเอง. ไม่มีresetcamera/stats/position/inventoryเมื่อเปลี่ยนmode.
- Dynamicseedlistอยู่ในInventoryเดิม: SEED+plantable+quantity>0, uniqueIDรวมstacks, tier/display_order/IDsorting. เมล็ดหมดเลือกsuccessorและwrap; empty/reacquireปลอดภัย. ไม่มีfixedhotbar; ทดสอบ33seeds.
- ItemDataเพิ่มplantable(defaultfalse), tier1, display_order0. Seed5ชนิดเดิมexplicitplantabletrue/tier1/orders10..50. Testplantfixturetier2; พืชfantasyยังเป็นconceptและยังไม่มีunlocklogic.
- EquipmentLoadoutใหม่ default3slots/configurable, ownedWEAPONreference, equip/unequip/get/cycle APIs, selected_weapon_slot. Skipempty/unequipped, inventoryไม่ถูกconsume, pruneเมื่อownershipหาย/clear/shrink. ทดลอง5→2slotsผ่าน.
- InventoryUIเพิ่มownedweaponselectionและequip/unequipbuttons. Productionเริ่มด้วยemptyweaponslots; อาวุธ5ชนิดในtestเป็นtemporaryItemDataเท่านั้น.
- HUDแสดงmode/seedquantitytierหรือweapon/slot/emptystates. RMBและshootingcrosshairเฉพาะCOMBAT; กลับFarmingcancelAim. Camera mouse look/sprint/staminaเดิมยังทำงาน.
- FarmPlotเพิ่มmode/type/plantableguards; plant/harvestเฉพาะFarmingและผ่านEจริง. Growth/atomictransactions/HP/clockเดิมไม่rewrite.
- PauseMenuใหม่: EscPause/Resume, release/capturecursor. BagกับPauseไม่ซ้อน; pausedblocksQ/wheel/camera/aim/clock. Keyechoไม่toggleซ้ำ.

## Files / architecture

ใหม่3scripts: `scripts/inventory/equipment_loadout.gd`, `scripts/player/gameplay_mode_controller.gd`, `scripts/ui/pause_menu.gd`.

แก้8scripts: `item_data.gd`, `inventory.gd`, `farm_plot.gd`, `game_root.gd`, `camera_rig.gd`, `aim_crosshair.gd`, `inventory_ui.gd`, `prototype_hud.gd`.

เพิ่มPauseMenu.tscn; แก้Player/GameRoot/HUD/InventoryUI scenesและproject.godot. Productionรวม26scripts/10scenes/17Resources. Seed5resourcesเพิ่มmetadata; fixtureseed_testtier2. เพิ่ม2testsและปรับ7testsเดิมเฉพาะcontractใหม่; runnerรวม27runs. Docsรายงานใหม่PHASE_INPUT_SELECTION_TEST_REPORTพร้อม7screenshotsในdocs/input; updateREADME/architecture/roadmap/testsREADMEและhistoricalCamerareportnotice.

Playerchildren: Visual / CameraPivot→Pitch→ShoulderOffset→CameraBoom→Camera3D / AimRay / Interactor / Health / Stamina / Inventory / EquipmentLoadout / GameplayMode. Rootwireinventory→equipment→mode→camera; mode_changed→HUD/interactor. InventoryUIและPauseMenuส่งopened_changed→camera. ไม่ย้ายselectionlogicไปPlayerController.

## Controls / settings

WASDmovement, ShiftSprint, Einteract, TabBag, QFarming↔Combat, Wheelcurrentmodeitem, RMBCombatAim, VShoulder, EscPause/closebag, Rrestartเฉพาะdead. LMBยังไม่ยิง. DebugF1–F12ตามเดิม.

Demoequipment3slots; inventory24slots; selectorไม่มีlimitเพิ่มเติม. Tier>=1/order>=0. SlotAPIindex0..N−1/HUD1..N/none−1. Seedselectorเก็บstableID; equipmentเก็บItemDatareferencesที่owned.

Cameraเดิม: normal4.2m/FOV70/offset0.70; aim2.6m/FOV55/offset0.85; height1.65, sensitivity0.003, pitch−65..+45; aimrange100m. Modeเปลี่ยนpermissions/aimstate ไม่resettuning.

## Verification

- Final27runs: import1 +20headlesstests+mainboot1+5rendered. Logs `.godot/test-logs/input/`; workspaceต้นฉบับ `work/input_final_logs/`; manifest `work/input_final_manifest.json`.
- Data/selector/equipment29checks; input/modes39headlessและ47renderedchecks(รวม7screenshots/actualcapture). ทุกข้อผ่าน.
- Phase2/3/Camera regressionผ่านครบ รวมcollision/ray/strafe/movement/HP/stamina/night/growth/capacity/reentrancy/restart. Leadgrowth×1จริง30.297sและharvestLead×2.
- ตรวจภาพFarming/Combat/bagequipment/harvest/Pause/emptyloadout/emptyseedsและdebugbag. Automatedinput+rendererinspection;ไม่อ้างhumanplaytest.
- OriginalGLB243hashesunchanged. PlayerController/Visual/stats/clock/daynight/plantvisual/plantdataไม่เปลี่ยน. ไม่มีtestค้างหรือfail.

## Known issues / limitations

- Engineenvironmentยังมี `ERROR: Failed to read the root certificate store.` เดิม. ไม่มีScriptErrorใหม่; runnerยกเว้นเฉพาะข้อความนี้และเก็บlogเต็ม.
- Testpauseเคยถูกsyntheticwheelที่ไม่มีreleaseจับGUIfocusไว้; แก้harnessให้ส่ง2edgesแล้วclickResume/unequipผ่าน. ไม่แก้productionbehaviorเพื่อกลบtest.
- ไม่มีproductionweaponitems/weaponvisual/individualweaponinstances/save. EquipmentItemDataหนึ่งIDลงได้ช่องเดียว; weaponinstance/ammo/durabilityรอphaseอนาคต.
- Tier/orderเป็นdata ไม่ใช่unlocklogic; Resourcedefinitionsควรimmutableระหว่างruntime. Selectorquantityrefreshผ่านinventorysignals.
- AimstrafeWalkplaceholder/nearclipเมื่อชิดwall/nightgreyboxยังเป็นข้อจำกัดเดิม. ยังไม่ได้humanlongsession/export/mobile/performancebenchmark.

## Next exact step

**Historical note:** input milestone เสร็จก่อน Phase 4. สถานะและ next exact step ปัจจุบันอยู่ด้านบน. Weaponphaseพร้อมใช้current_mode, selected_equippedweapon/equipment_changed และaimray/targetจากCamera. ต้องรอคำขอเพื่อออกแบบWeaponData/instances/model/firing/muzzleblock/ammo/reload/damage.

Suggested commit: `feat: add farming combat modes and dynamic item selection` (ยังไม่ได้commit).
