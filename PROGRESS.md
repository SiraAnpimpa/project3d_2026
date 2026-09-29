# PROGRESS — Somchai's Last Harvest

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

**งานนี้เสร็จแล้ว หยุดรอpromptถัดไป.** เมื่อcontinueอ่านไฟล์นี้กับPHASE_INPUT_SELECTION_TEST_REPORTและตรวจGitก่อน; ไม่มีงานinputที่ค้างและไม่เริ่มGunShootingเอง. Weaponphaseพร้อมใช้current_mode, selected_equippedweapon/equipment_changed และaimray/targetจากCamera. ต้องรอคำขอเพื่อออกแบบWeaponData/instances/model/firing/muzzleblock/ammo/reload/damage.

Suggested commit: `feat: add farming combat modes and dynamic item selection` (ยังไม่ได้commit).
