# Somchai's Last Harvest

Godot **4.7 / Compatibility**. **Input, Inventory Access & Item Selection เสร็จแล้ว**: Farming/Combat mode, dynamic seed selector, equipment3slots และ shoulder camera. ยังไม่มีระบบยิง. Main scene `scenes/main/GameRoot.tscn`.

## เปิดเกมและทดลองปลูก

Import `project.godot` แล้วกด **F5**. เริ่มใน **FARMING** พร้อม Lead Seedที่เลือกไว้และเมล็ด5ชนิด ชนิดละ3.

1. ใช้ **Mouse Wheel** เปลี่ยนเมล็ด หรือกด **Tab** เปิดกระเป๋าแล้วคลิกเมล็ด/ใช้arrows+Enter.
2. Tab/Escปิดกระเป๋าแล้วเมาส์จะcaptureกลับ. เดินไปแปลงจนเห็น `[E] Plant ...` และกด E.
3. รอLeadโตประมาณ30วินาที แล้วกด Eเก็บLead×2. เมล็ดที่ใช้หมดจะหายจากรายการwheelและเลือกตัวถัดไปให้อัตโนมัติ.
4. กด **Q** เข้าCOMBAT แล้วกดRMBค้างเพื่อเล็ง; กลับQเป็นFarmingก่อนปลูก/เก็บเกี่ยว.

กระเป๋าและPauseหยุดเวลา/การเติบโต. กระเป๋าเต็มแล้วharvestไม่สำเร็จจะคงพืชพร้อมเก็บไว้. ยังไม่มีขาย/ทิ้งวัสดุหรือsave.

## Controls

| ปุ่ม | การทำงาน |
|---|---|
| WASD / Shift | เดิน / วิ่งตามstamina |
| Mouse / arrows | หมุนกล้อง; captureอัตโนมัติระหว่างเล่น |
| **Tab** | เปิด/ปิดกระเป๋า; เลิกใช้I |
| **Q** | Farming↔Combat |
| **Wheel up/down** | Seedก่อนหน้า/ถัดไปในFarming; เฉพาะequippedweaponในCombat |
| E | Interact; ปลูก/harvestได้เฉพาะFarming |
| RMBค้าง | AimเฉพาะCombat; ปล่อยกลับnormalcamera |
| **V** | สลับไหล่ซ้าย/ขวา (ย้ายจากQ) |
| **Esc** | เปิด/ปิดPause; ถ้าbagเปิดอยู่ให้ปิดbag |
| Rเมื่อHPหมด | เริ่มใหม่; ยังไม่ใช่Reload |
| F1 | เปิด/ปิดdebug |
| F2/F3, F4/F5 | ลด/ฟื้นHP, ลด/ฟื้นstamina |
| F6/F7, F8/F9 | ย้อน/เพิ่ม1gamehour, ข้ามday/night |
| F10/F11/F12 | เวลา×1↔×20, pauseclock, restoreplayer |

Normalcameraหันตัวตามทิศเดิน; CombatAimเดินข้าง/ถอยโดยยังหันตามกล้อง. Sprintจริงยกเลิกaim; ค้างRMBจะกลับaimเมื่อหยุดsprint. Mode switchไม่resetstats/inventory/camera และจำseed/weaponแยกกัน. Farmingซ่อนshootingcrosshair. LMBยังไม่ยิง.

## Equipment foundation

มี **3 equippedweapon slots** แยกจากowneditemsในbag. เมื่อมีownedweapon ให้คลิกitemแล้วคลิกslotด้านล่าง; ×ถอดออกโดยยังเก็บในbag. WheelCombatข้ามช่องว่างและไม่วนผ่านปืนที่ยังไม่equip. ปรับจำนวนช่องที่ `Player/EquipmentLoadout.weapon_slot_count`.

F5ปกติยังไม่มีproductionweaponitems จึงแสดง `No weapon equipped`. ชุดทดสอบใช้Rifle/Shotgun/SMG/Crossbow/Special Gunชั่วคราวเพื่อทดสอบowned5/equipped3; ไม่มีmodelปืน/ammo/reload/firing.

## Seed ordering / เพิ่มพืช

SeedSelectorอ่านitemชนิดSEEDที่`plantable=true`และquantity>0 จากInventory; ไม่มีfixedhotbar. เรียง`ItemData.tier`แล้ว`display_order` (IDเป็นtie-break). Production5ชนิดเป็นtier1 orders10..50. Seedหลายstackมีหนึ่งรายการและแสดงquantityรวม.

เพิ่มseedด้วยItemData/PlantData/catalogตาม [Architecture](PROJECT_ARCHITECTURE.md). ตั้งplantable/tier/orderด้วย; พืชTier2+ยังเป็นแนวคิด ไม่มีunlocklogicในphaseนี้.

## ค่ากล้อง / ฟาร์ม

CameraPivot: normal4.2m/FOV70/offset0.70m; aim2.6m/FOV55/offset0.85m; height1.65m; sensitivity0.003; pitch−65..+45°. Playerturn12/s, aimwalk2.8m/s; AimRay100m. Collisionและmovementใช้ฐานCamera phaseเดิม.

Inventory24slots, stack99, seedsเริ่มต้น3/type. Lead30s→2, Paper25s→3, Iron40s→2, Copper35s→2, SmallHerb20s→1ที่×1. กลางวัน/กลางคืนช่วงละ10นาทีจริง. F1เปิดdebugแล้วTabใช้Give seeds/Clear farm/Grow all/+1hour/Fill bag/Clear bag; debugtimejumpsเปลี่ยนเวลาแม้bagเปิด.

## เอกสาร / Tests

- [รายงานInput / Selection พร้อมภาพ](PHASE_INPUT_SELECTION_TEST_REPORT.md)
- [สถานะงาน](PROGRESS.md)
- [Architecture](PROJECT_ARCHITECTURE.md)
- [วิธีรันtests](tests/README.md)
- [รายงานCameraเดิม](PHASE_CAMERA_TEST_REPORT.md)

```powershell
.\tests\run_tests.ps1 -Godot 'C:\Users\ADMIN\Desktop\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64.exe' -WithRendering
```

Final27runsผ่าน รวมrendererและLeadgrowth30.297วินาทีจริง. ไม่มีScriptErrorใหม่; engineมีข้อความcertificate storeเดิมของเครื่อง. Aimstrafeใช้Walkplaceholder; ไม่มีhumanlongsession/export/performancebenchmark. **หยุดรอpromptถัดไป; ยังไม่ทำGun Shooting และไม่ได้commit/push.**
