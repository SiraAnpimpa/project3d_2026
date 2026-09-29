# Input, Inventory Access & Item Selection — Test Report

วันที่ 2026-09-29 · **Complete** · Godot4.7 / Compatibility / RTX4060 Laptop / 1280×720 / physics60Hz

ผลสุดท้าย **27/27 runs ผ่าน, failures=0** รวม input/UI ใน renderer และวงจรฟาร์มเวลาจริง. ไม่มี ScriptError ใหม่. งานนี้เพิ่ม mode/selection/equipment foundation; ไม่มีการยิง กระสุน reload หรือ weapon damage. ไม่ได้ commit/push.

## 1. Input layout และการแก้ conflict

| ปุ่ม / Action | พฤติกรรมปัจจุบัน |
|---|---|
| WASD / move_* | Movement อิง yaw ของกล้อง |
| Shift / sprint | Sprint ตาม stamina เดิม; sprint จริงยกเลิก aim |
| E / interact | Interact; ปลูก/เก็บเกี่ยวเฉพาะ Farming |
| **Tab / toggle_inventory** | เปิด/ปิดกระเป๋า; ใช้ action เดิมและลบ binding I |
| **Q / switch_mode** | Farming↔Combat; ไม่ reset camera/stats/inventory |
| Wheel down / cycle_item_next | รายการถัดไปของ mode ปัจจุบัน |
| Wheel up / cycle_item_previous | รายการก่อนหน้า; wrap รอบรายการ |
| RMB / aim | กดค้างเพื่อเล็งเฉพาะ Combat |
| **V / switch_shoulder** | สลับไหล่; ย้ายจาก Q เพื่อแก้ conflict |
| **Esc / pause** | Gameplayเปิด/ปิด Pause; ถ้า bag เปิดอยู่ให้ปิด bag ครั้งเดียว |
| R / restart | เริ่มใหม่เฉพาะเมื่อตาย; ยังไม่ใช่ reload |
| Mouse / arrow keys | กล้องเดิม; arrows ในกระเป๋าใช้เลือกปุ่ม |
| F1–F12 | Debug เดิมตาม README |

Action `release_mouse` ถูกแทนด้วย `pause`; Camera ไม่รับ Esc ซ้ำ. `capture_mouse`/LMBเดิมคงไว้เป็น fallbackเฉพาะกรณี debugเรียกrelease_mouse()เอง; ไม่เกิด firing. Gameplayปกติ captureอัตโนมัติเมื่อกลับจากหน้าต่าง.

## 2. Gameplay mode และ wheel routing

`Player/GameplayMode` ใช้ `GameplayModeController` เพียงตัวเดียวรับ Q และ wheel ใน `_unhandled_input`. เริ่ม **FARMING**. ตรวจ camera.can_control และไม่รับ key echo; paused/dead/menu/focus loss จึงไม่ทำให้ mode หรือ selectionเปลี่ยนจาก gameplay input.

```text
Wheel → GameplayModeController
       ├ FARMING → Inventory.cycle_seed()
       └ COMBAT  → EquipmentLoadout.cycle_weapon()
```

Inventory และ Equipment ไม่ฟัง wheel เอง. Seed ID กับ selected_weapon_slot อยู่คนละ component จึงจำ selectionแยกกัน. Modeเปลี่ยนเฉพาะ camera combat gate และแจ้ง HUD/interactor; ไม่มีการ reset stamina, velocity, player position, yaw, pitch หรือ shoulder side.

Combat เปิดใช้ RMB/crosshair แม้ยังไม่มีปืน เพื่อคง aim foundationสำหรับ phaseถัดไป. กลับ Farmingยกเลิก aim/heldRMB และซ่อน shooting crosshair. กลับ Combatต้องกด RMB ใหม่. SprintยังยกเลิกaimและถือRMBต่อจะกลับaimเมื่อsprintจบตามกล้องเดิม.

## 3. Dynamic seed selector และ tier

ขยาย `Inventory` เดิมให้มี `get_selectable_seeds()`, `cycle_seed(direction)` และการซ่อม selectionเมื่อ quantityเปลี่ยน. ไม่เพิ่ม SeedSelector class ที่เก็บ stateซ้ำกับInventory.

รายการเลือกเฉพาะ `item_type == SEED`, `plantable == true`, quantity>0; รวมหลายstackของ IDเดียวเป็นรายการเดียว. เรียง `tier`, `display_order`, แล้ว stableIDเพื่อแก้ค่าซ้ำ. ไม่ใช้ชื่อitemเป็น progression. คืน array snapshotเพื่อไม่ให้ผู้เรียกแก้รายการlive.

`ItemData` เพิ่ม `plantable` (defaultfalse), `tier` (default1), `display_order` (default0). Seed5ชนิดเดิมตั้ง plantable=true / tier1 / order10,20,30,40,50 ตาม Lead,Paper,Iron,Copper,SmallHerb. Tierมาจาก seed Resourceซึ่ง PlantDataอ้างอยู่แล้ว จึงไม่มี tierสองแหล่งที่ต้องsync.

| Tier concept | ข้อมูลปัจจุบัน/แนวทางต่อไป |
|---|---|
| 1 | Lead, Paper, Iron, Copper, Small Herb ในเกมแล้ว |
| 2 | Fire Pepper / Water เป็นแนวคิด; test_plant fixtureใช้tier2 |
| 3 | Ice / Poison เป็นแนวคิด |
| 4+ | Electric / Rare / Special เป็นแนวคิด |

ยังไม่เพิ่มพืชแฟนตาซีหรือระบบปลดล็อก; เพิ่มได้ด้วย ItemData/PlantData/catalog ตามเดิม. Selectorไม่มีจำนวนช่องตายตัว; ทดสอบ33ชนิดแล้ว. Inventory capacity24ของdemoยังเป็นกติกาความจุกระเป๋า ไม่ใช่จำนวนช่องhotbar; ปรับcapacityได้แยกกัน.

เริ่มเกมเลือกseedแรกที่ใช้ได้อัตโนมัติ. เมื่อseedที่เลือกหมด จะเลือกตัวถัดไปตาม progression และwrapไปตัวแรกหากหมดท้ายรายการ. ถ้าไม่มีseedเหลือ IDว่างและ HUDบอกชัด. ได้seedใหม่ขณะไม่มีselectionจะเลือกให้เอง; เพิ่ม/ลดseedอื่นไม่เปลี่ยนselectionที่ยังvalid.

## 4. Inventory และ equipment architecture

Inventory เก็บ **owned items**. `Player/EquipmentLoadout` เก็บ references ของ **equipped weapons**. ค่า `weapon_slot_count=3` ปรับจากInspectorก่อนเริ่มเกม หรือ `configure_slots(count)` ระหว่างruntime. Logicไม่ยึดเลข3; ทดสอบ5slotsและลดเหลือ2แล้ว.

API: `equip_weapon(slot, ItemData) -> bool`, `unequip_weapon(slot) -> bool`, `get_equipped_weapon(slot)`, `get_selected_weapon()`, `cycle_weapon(direction)`, `selected_weapon_slot`, `equipment_changed`. APIใช้indexเริ่ม0; HUDแสดง1..N. ไม่มีอาวุธที่เลือกใช้ค่า−1.

- EquipเฉพาะItemType.WEAPONที่Inventoryเป็นเจ้าของและเป็นdefinitionเดียวกัน. Rejectslotผิด/typeผิด/unownedโดยไม่เปลี่ยนของ.
- Equip/unequipไม่consume item. Replaceยังคงปืนเดิมอยู่ในกระเป๋า.
- ItemDataเดียวลงได้ช่องเดียว; equipซ้ำไปช่องใหม่เป็นการย้าย. Current selectionย้ายตามถ้าจำเป็น.
- Scrollเฉพาะช่องที่มีปืน; skipช่องว่าง ไม่รวมปืนownedที่ยังไม่equip.
- Remove ownership/clear inventory/shrink slots จะ reconcile referencesและเลือกช่องถัดไปที่valid; ถ้าไม่มีให้−1.

InventoryUI: คลิกowned weapon แล้วคลิกช่องEquipด้านล่าง; ×unequip. จำนวนseedกับweaponcandidateจำแยกกัน. Prototypeยังไม่เพิ่มปืนในstarterloadout: F5ปกติเริ่มด้วย3ช่องว่าง. Rifle/Shotgun/SMG/Crossbow/Special Gunในภาพเป็น **ข้อมูลทดสอบชั่วคราว** ที่สร้างเฉพาะtest ไม่ได้เป็นระบบปืนจริงหรือเพิ่มในproductioncatalog.

ภาพ: [เลือกและEquipจากกระเป๋า](docs/input/input_equipment_bag.png), [Combat selection](docs/input/input_combat.png), [Empty loadout](docs/input/input_empty_loadout.png).

## 5. HUD, inventory, pause และ farming

HUDสีเขียวแสดง FARMING, Selected Seed, quantity, tier และปุ่มwheel/Tab. Combatสีส้มแสดง COMBAT, weaponชื่อปัจจุบันกับslot เช่น `[3 / 3] Special Gun (test)`. ไม่มีammo UIหลอก. Empty statesแสดง No plantable seeds / No weapon equipped.

TabเปิดInventory → SceneTreepause, cursorvisible, camera/aimหยุด. ปิดด้วยTab/Esc/Close →คืนpauseเดิมและmousecapture. EscจากgameplayเปิดPauseMenuใหม่พร้อมResume/Esc. PauseกับInventoryไม่เปิดซ้อนกัน; TabขณะPauseไม่เปิดกระเป๋าทับ. Pauseหยุดclock/growth/movement; Q/wheel/aimไม่รั่วผ่านUI. ไม่เปลี่ยนระบบdebugclockpause.

FarmPlotเพิ่มmode guardทั้ง `is_available()` และ `interact()` รวมการเรียกตรง. Combatไม่แสดงpromptฟาร์มหรือปลูก/harvest. Farmingยังตรวจselectedseed, type, plantable, quantity, empty state, matchingPlantDataและvalidationก่อนconsume1seed. ระบบgrowth/harvest/atomicinventory/reentrancyเดิมคงไว้. เมล็ดสุดท้ายถูกปลูกแล้วselector/HUDเปลี่ยนทันที.

ภาพ: [Farming HUD](docs/input/input_farming.png), [Harvestและseedถัดไป](docs/input/input_harvest.png), [Pause](docs/input/input_pause.png), [Empty seed list](docs/input/input_empty_seeds.png).

## 6. Files changed

- ใหม่ scripts3: `scripts/inventory/equipment_loadout.gd`, `scripts/player/gameplay_mode_controller.gd`, `scripts/ui/pause_menu.gd`.
- แก้ scripts8: ItemData, Inventory, FarmPlot, GameRoot, CameraRig, AimCrosshair, InventoryUI, PrototypeHUD.
- ใหม่scene `scenes/ui/PauseMenu.tscn`; แก้ GameRoot/Player/HUD/InventoryUI scenesและproject.godot.
- Seed Resources5ไฟล์ตั้งplantable/tier/order; fixtureseed_testเพิ่มtier2. Production Resourcesยัง17ไฟล์เดิม.
- Testsใหม่2; ปรับ7testsเก่าเฉพาะcontractที่เปลี่ยน: Tab/V/Combatก่อนAim/EscPause/หมดseedแล้วclear/auto-selection. Runnerเพิ่มtests; docsอัปเดตREADME/PROGRESS/architecture/plan/testsและบันทึกhistoricalcamera report.
- Productionรวม26scripts/10scenes. PlayerController/PlayerVisual/HP/Stamina/Clock/DayNight/PlantVisual/PlantDataไม่ถูกแก้. GLB243ไฟล์SHA256เหมือนเดิมทั้งหมด.

## 7. Tests และผลจริง

ก่อนแก้ baseline **20 headless runsผ่าน**. หลังแก้ final suite **27/27 runs, exit0, failures=0**: import1,20headlesstests,mainboot1,rendered5runs.

| Test group | ผล |
|---|---|
| input_selection_data_test | 29 checks: sort/type/plantable/quantity, stackaggregate, wrap/depletion/reacquire,33seeds, tier validation, owned/equipped split, invalidslot, move/replace/unequip/lostownership, configurablecount |
| input_modes_integration_test | 39 headless checks / 47 rendered checks (รวม7imagesและactualmousecapture): Tab/Q/V/wheel, mode memory, gating, UIequip3จากowned5, farmfinalseed→fallback→harvest, Pause/Resume, sprint/death/restart |
| Camera regression | Controls33/35checks, collision/ray19, rate30/120, renderedwalkthroughผ่าน; Camera settings/collisionเดิมคงไว้ |
| Phase 2–3 regression | Movement/interaction/HP/stamina/clock/day-night/inventory/data/farming/debug/newplantfixture/growth/restartผ่านทั้งหมด |
| Real-time farming | Lead×1เติบโตผ่าน4stagesใน **30.297sจริง**, harvestLead×2และปลูกซ้ำผ่าน |

Rendered input testกับcamera walkthroughรันโดยไม่ใช้fixed-fps; Phase3renderedรอgrowthเวลาจริง. Testsส่งinputผ่านviewport/heldactionsบนGameRootจริงและตรวจภาพจริง. ไม่อ้างว่าเป็นhuman keyboard playtest. Test pauseเคยค้างจากsyntheticwheelส่งแต่pressedโดยไม่มีrelease; แก้harnessให้ส่งทั้งสองedgeแล้วResume click/sprint/unequipผ่าน โดยไม่แก้productionUIเพื่อหลบปัญหาทดสอบ.

Logs: `.godot/test-logs/input/`; ต้นฉบับในCodexworkspace `work/input_final_logs/`. ภาพ7ไฟล์ใน `docs/input/`; ตรวจdebugbaglayoutร่วมกับequipmentจากregressionด้วย.

## 8. Known issues / limitations

- ไม่มีacceptance failureค้าง. มีengine environmentข้อความเดิม `ERROR: Failed to read the root certificate store.`; runnerแยกเฉพาะข้อความนี้และยังเก็บfull log. ไม่พบScriptErrorใหม่.
- Demoไม่มีproductionweaponitems/weaponvisuals/shooting. Equipmentเป็นreferencesระดับItemData/ID; ยังไม่มีปืนแต่ละชิ้นที่มีdurability/ammoหรือsave stateแยกกัน.
- Tier/orderเป็นmetadata ไม่ใช่ระบบunlock. ข้อมูลResourceควรคงที่ระหว่างเล่น; หากแก้definitionสดโดยไม่ผ่านinventorymutation ยังไม่มีresource-change refreshอัตโนมัติ.
- ข้อจำกัดcamera/animationเดิมยังมี: aimstrafeใช้Walkplaceholder, nearclipตัวละครเมื่อชิดกำแพงมาก, nightgreybox. ไม่มีhumanlongsession/export/mobile/performancebenchmarkในรอบนี้.

## 9. Next phase boundary

พร้อมส่ง `EquipmentLoadout.get_selected_weapon()` และ `equipment_changed` ให้Weapon phase; modeและcamera gatesพร้อม. Weapon phaseยังต้องเพิ่มWeaponData/instancesตามที่ต้องใช้, muzzleobstruction, models/animation, firing/ammo/reloadและdamageตามคำขอใหม่.

**งาน Input / Inventory / Selection เสร็จแล้ว หยุดรอ promptถัดไป. ยังไม่เริ่ม Gun Shooting.**

Suggested commit: `feat: add farming combat modes and dynamic item selection` (ยังไม่ได้commit).
