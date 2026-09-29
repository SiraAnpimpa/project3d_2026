# Somchai's Last Harvest

Godot **4.7.2 / Compatibility**. **Phase 5 Weapon & Shooting Foundation เสร็จและทดสอบ runtime แล้ว**. Main scene: `scenes/main/GameRoot.tscn`.

## วิธีเล่นตั้งแต่ปลูกจนยิง

1. Import `project.godot` แล้วกด **F5**. เริ่ม Farming พร้อมเมล็ด 5 ชนิด ชนิดละ 3 และ Basic Rifle ในช่องอาวุธ 1. แม็กกาซีนและกระสุนสำรองเริ่มที่ 0.
2. ใช้ **Wheel** เลือก Lead / Paper / Copper Seed; เดินไปแปลงแล้วกด **E** ปลูกและเก็บเกี่ยวเมื่อโต.
3. ไป Workbench ใกล้ฟาร์ม กด **E**, เลือก Basic Ammo แล้ว Craft. Lead ×1 + Paper ×1 + Copper ×1 ได้กระสุน ×10.
4. ปิดด้วย Esc, กด **Q** เข้า Combat แล้ว **R** รอรีโหลด 1.5 วินาที.
5. **RMB** ค้างเล็ง และ **LMB** ยิง Target Dummy ด้านเหนือฟาร์มที่ (3, 0, -8). ยิงโดน 5 นัดจะทำลายเป้า.

## Controls

| ปุ่ม | การทำงาน |
|---|---|
| WASD / Shift | เดิน / วิ่งตาม stamina |
| Mouse / arrows | หมุนกล้อง |
| Tab | เปิด/ปิดกระเป๋า |
| Q | Farming / Combat |
| Wheel | เลือกเมล็ดใน Farming; สลับปืนที่ equip ใน Combat |
| E | Interact / ปลูก / เก็บเกี่ยว / Workbench |
| RMB ค้าง | Aim ใน Combat |
| LMB ขณะ aim | ยิง; ค้างเพื่อยิงอัตโนมัติ |
| R | Reload ใน Combat; เริ่มใหม่เมื่อ HP หมด |
| V | สลับไหล่กล้อง |
| Esc | ปิด bag/crafting ก่อน; เปิด/ปิด Pause |
| F1 | เปิด/ปิด debug |
| F2/F3, F4/F5 | ลด/ฟื้น HP, ลด/ฟื้น stamina |
| F6/F7, F8/F9 | ย้อน/เพิ่ม 1 game hour, ข้าม day/night |
| F10/F11/F12 | เวลา ×1/×20, pause clock, restore player |

Bag, Crafting และ Pause หยุดเวลา/การเติบโตและบล็อกการยิง. Farming ปลูก/เก็บเกี่ยวได้; Combat ยิงได้เมื่อ aim. Sprint ยกเลิก aim; ค้าง RMB จะกลับ aim เมื่อหยุด sprint.

## Equipment / Ammo

มี 3 ช่องอาวุธ ปรับจำนวนได้ที่ `Player/EquipmentLoadout.weapon_slot_count`. เลือกปืนใน bag แล้วคลิกช่องเพื่อ equip; × ถอดโดยยังเก็บปืนไว้. Wheel ข้ามช่องว่าง. ปืนหนึ่ง ID ลงได้ช่องเดียว; จำนวนในแม็กกาซีนจำไว้เมื่อสลับหรือถอดปืน.

Basic Rifle: damage 20, 5 นัด/วินาที, แม็ก 10, reload 1.5 วินาที, range 60 m. Reserve อ่านจาก Basic Ammo ใน Inventory. Reload ใช้กระสุนเท่าที่ขาดเมื่อครบเวลา; เปลี่ยนปืน/mode/เปิดเมนูยกเลิกโดยไม่เสียกระสุน. HUD แสดงชื่อปืน ช่อง แม็ก กระสุนสำรอง และสถานะ reload. แนวยิงตรวจสิ่งกีดขวางจากปากกระบอก.

## Farming / Crafting

Inventory 24 slots, stack 99. Lead 30s→2, Paper 25s→3, Iron 40s→2, Copper 35s→2, Small Herb 20s→1 ที่เวลา ×1. Day/night ช่วงละ 10 นาทีจริง. Seed selection อ่านจาก Inventory และเรียง tier/display_order/ID; ไม่มี fixed hotbar.

สูตรอื่น: Small Herb ×2 → Basic Medicine ×1; Iron ×2 + Copper ×1 → Metal Component ×1. Medicine ยังใช้ heal ไม่ได้. กระเป๋าเต็มแล้ว harvest/craft ไม่สำเร็จจะไม่เสียของ. สัดส่วนทั้งหมดเป็น **TEMPORARY BALANCE**; ยังไม่มีขาย/ทิ้งของหรือ save.

F1 แล้ว Tab เปิด debug actions: Give seeds, Clear farm, Grow all, +1 hour, Fill/Clear bag และ Give Basic Ammo ×30. เพิ่มกระสุนได้เฉพาะเมื่อ debug เปิด.

## Tests / ข้อจำกัด

```powershell
.\tests\run_tests.ps1 -Godot 'C:\path\to\Godot_v4.7.2-stable_win64_console.exe' -WithRendering
```

Phase 5 final suite **31 runs, failures=0** รวม rendered gameplay และ natural Lead growth 30.384 วินาที. ท่าถือปืนใช้ idle/walk เดิม ยังไม่มี dedicated aim/reload animation, IK หรือเสียงปืน. ยังไม่ได้ human long-session/export/performance benchmark. หยุดที่ Phase 5; รอ Phase 6 — Zombie AI & Basic Enemy Combat.

- [รายงาน Phase 5 และภาพทดสอบ](PHASE_5_TEST_REPORT.md)
- [รายงาน Phase 4](PHASE_4_TEST_REPORT.md)
- [รายงาน Input / Selection](PHASE_INPUT_SELECTION_TEST_REPORT.md)
- [รายงาน Camera](PHASE_CAMERA_TEST_REPORT.md)
- [สถานะงาน](PROGRESS.md)
- [Architecture และการเพิ่มข้อมูล](PROJECT_ARCHITECTURE.md)
- [แผนพัฒนา](DEVELOPMENT_PLAN.md)
- [วิธีรัน tests](tests/README.md)
