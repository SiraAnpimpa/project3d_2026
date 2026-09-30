# Somchai's Last Harvest

## Phase 9 demo (Godot 4.7.2 / Compatibility)

Import `project.godot` and press **F5** to open `scenes/main/MainMenu.tscn`. Choose **How To Play** or **Play**. Normal play hides debug UI; F1 toggles it for development.

- WASD move, Shift sprint, mouse look; Q switches Farming/Combat.
- Wheel selects seeds; E plants, harvests, opens the Workbench or rests at the shelter bed after clearing a night.
- Grow Lead, Paper and Copper, then craft Basic Ammo at the Workbench. Q enters Combat, R reloads, RMB aims, LMB fires; V swaps camera shoulder.
- Tab opens inventory; Esc closes the current panel or opens Pause, with controls, restart and Main Menu choices.
- Survive ten nights. Fire/Ice/Poison crops unlock on Days3/5/7. On Day10 the final-night warning appears; surviving to Day11 06:00 starts rescue and the ending screen. Death offers restart/menu.

Medicine and elemental ammunition can be crafted but cannot yet be used. No save system. Helicopter rotor and some world/crop/enemy visuals remain placeholders; original pack distribution rights need verification. Audio is original procedural SFX/ambience, without music.

### Verification

```powershell
./tests/run_tests.ps1 -Godot 'PATH_TO_GODOT_CONSOLE.exe' -WithRendering
```

Latest 42 per-check results pass, including targeted reruns after fixes. See [Phase9 report](PHASE_9_TEST_REPORT.md), [screenshots and results](docs/phase9/) and [current progress](PROGRESS.md). Phase10 final balance, performance and export are pending.

## Earlier gameplay notes (historical)

Godot **4.7.2 / Compatibility**. **Phase 7 Night Wave & Survival Loop เสร็จและทดสอบ runtime แล้ว**. Main scene: `scenes/main/GameRoot.tscn`.

## วิธีเล่นตั้งแต่ปลูกจนยิง

1. Import `project.godot` แล้วกด **F5**. เริ่ม Farming พร้อมเมล็ด 5 ชนิด ชนิดละ 3 และ Basic Rifle ในช่องอาวุธ 1. แม็กกาซีนและกระสุนสำรองเริ่มที่ 0.
2. ใช้ **Wheel** เลือก Lead / Paper / Copper Seed; เดินไปแปลงแล้วกด **E** ปลูกและเก็บเกี่ยวเมื่อโต.
3. ไป Workbench ใกล้ฟาร์ม กด **E**, เลือก Basic Ammo แล้ว Craft. Lead ×1 + Paper ×1 + Copper ×1 ได้กระสุน ×10.
4. ปิดด้วย Esc, กด **Q** เข้า Combat แล้ว **R** รอรีโหลด 1.5 วินาที.
5. **RMB** ค้างเล็ง และ **LMB** ยิง Target Dummy ด้านเหนือฟาร์มที่ (3, 0, -8). ยิงโดน 5 นัดจะทำลายเป้า.

## กลางคืนและการพัก

เวลา **18:00** ซอมบี้ Normal 6 ตัวจะเริ่มบุกจากทิศเหนือ/ตะวันออก/ใต้/ตะวันตก เกิดห่างกัน 2 วินาทีและห่างผู้เล่นอย่างน้อย 12 เมตร. HUD นับทั้งตัวที่ยังมีชีวิตและตัวที่รอเกิด. ผู้เล่นเลือก Farming/Combat ด้วย Q เอง.

เตรียมอย่างน้อย 30 นัดสำหรับยิงโดนครบทุกนัด; ปลูก Lead/Paper/Copper อย่างละ 2 เมล็ดจะมีวัสดุคราฟต์กระสุน 40 นัด. ปลูก Small Herb 2 ต้นเพื่อคราฟต์ Medicine ได้ด้วย แต่ยังไม่มีระบบใช้ยา.

เมื่อฆ่าครบก่อนเช้า จะขึ้น **NIGHT CLEARED**. ไปเตียงสีน้ำเงินใน Shelter แล้วกด **E** เพื่อพัก: HP/stamina เต็ม ข้ามเป็น **06:00 ของวันถัดไป** และพืชโตตามเวลาที่ข้าม. ต้องพักก่อนรุ่งเช้าเพื่อรับการฟื้นตัว.

ถ้าถึง **06:00** โดยไม่ได้พัก ซอมบี้ของคลื่นที่เหลือจะถูกนำออก แต่ HP/stamina ไม่ได้รับโบนัสฟื้นเต็ม. การฟื้น stamina ตามปกติยังทำงาน. ตายแล้วกด R เริ่ม Day 1 ใหม่. ช่วงกลางวัน/กลางคืนใช้เวลาอย่างละ 10 นาทีจริงที่ ×1.

## ทดลองต่อสู้กับซอมบี้ผ่าน debug

เปิด Tab แล้วใช้ **Spawn zombie / Spawn 3 zombies** ในส่วน debug (F1 เปิด/ปิด debug). ปิดกระเป๋าแล้วเดินเข้าระยะ 12 เมตรของจุด spawn: ด้านเหนือ (6, -14), ตะวันออก (16, 6), ใต้ (4, 18), ตะวันตก (-18, 5) และตะวันออกเฉียงเหนือ (15, -12). พิกัดเป็น X/Z; จำนวนรวมไม่เกิน 5 ตัว. **Clear zombies** ล้างชุดทดสอบ.

ซอมบี้จะเดินอ้อมสิ่งกีดขวาง เข้าระยะ 1.35 เมตรแล้วโจมตี 10 HP ทุกประมาณ 1.2 วินาที มีช่วงเตรียม 0.3 วินาทีให้หนี. ใช้ RMB + LMB ยิง; 5 นัดฆ่าได้ มีท่าล้มก่อนหาย. ซอมบี้ debug แยกจากคลื่นกลางคืนและไม่นับใน HUD ของคลื่น.

ปุ่ม debug เพิ่มเติม: **17:50 / Start night / Kill active wave / 05:50 / Dawn**. Kill active wave ไม่ลบตัวที่ยังรอเกิด จึงไม่ข้ามเงื่อนไขเคลียร์ก่อนเกิดครบ. ถ้าต้องการทดสอบคืนเดิมซ้ำให้ Restart; การย้อนเวลาจะไม่เริ่มคืนที่เคยเริ่มแล้วซ้ำ.

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

ชุดทดสอบ Phase 7 มี **36 runs** รวมสองเส้นทาง Day 1 แบบ simulation ผ่าน input จริง ไม่แจกของ/ฟื้น HP/ข้ามเวลาผ่าน debug และทดสอบ lifecycle แบบเรนเดอร์. ดูผลล่าสุดในรายงานด้านล่าง. ยังไม่ได้ human long-session/export/performance benchmark.

Navigation ต้อง bake ใหม่หากย้ายสิ่งกีดขวาง; ยังไม่มี crowd avoidance/headshot/เสียง/ท่านอน. เตียงเป็น placeholder. ท่าถือปืนยังใช้ idle/walk เดิม ไม่มี dedicated aim/reload animation หรือ IK. Wave ใช้ค่าเดิมทุกวัน ยังไม่เพิ่ม progression. หยุดที่ Phase 7; รอ Phase 8.

- [รายงาน Phase 7 และภาพทดสอบ](PHASE_7_TEST_REPORT.md)
- [รายงาน Phase 6 และภาพทดสอบ](PHASE_6_TEST_REPORT.md)
- [รายงาน Phase 5 และภาพทดสอบ](PHASE_5_TEST_REPORT.md)
- [รายงาน Phase 4](PHASE_4_TEST_REPORT.md)
- [รายงาน Input / Selection](PHASE_INPUT_SELECTION_TEST_REPORT.md)
- [รายงาน Camera](PHASE_CAMERA_TEST_REPORT.md)
- [สถานะงาน](PROGRESS.md)
- [Architecture และการเพิ่มข้อมูล](PROJECT_ARCHITECTURE.md)
- [แผนพัฒนา](DEVELOPMENT_PLAN.md)
- [วิธีรัน tests](tests/README.md)
