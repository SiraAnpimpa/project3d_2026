# PHASE_2_TEST_REPORT — Somchai's Last Harvest

วันที่ตรวจ: 2026-09-28. สถานะ: **Phase 2 implemented and runtime verified**.

## 1. Features implemented

- Godot 4.7 project, Compatibility renderer, main scene และ Input Map.
- Greybox 48×48 เมตรพร้อม ground/collision/boundary, spawn, farm/shelter/workbench/spawn-zone/rescue placeholders.
- Reusable CharacterBody3D player ใช้ Matt GLB: เดิน/วิ่ง, gravity, collision, camera-relative movement, Idle/Walk/Run/Death.
- Third-person camera: RMB mouse orbit, keyboard arrows, exported sensitivity/pitch limits, SpringArm collision, Escape/focus-loss release.
- Interaction foundation: sphere query, nearest reachable target, obstruction ray, prompt, E activation, debug response.
- HP clamp/damage/heal/death และ restart; stamina drain/recovery/delay/exhaustion และ sprint integration.
- Clock/day/night/day counter/signals, ปรับเวลาและ scale, แสง/สี environment กลางวัน–กลางคืน.
- HUD: วัน, HH:MM, HP, stamina, prompt, feedback, debug panel และ death/restart panel.
- Central debug controls: ปิดด้วย F1 หรือ Inspector, จำกัดด้วย `OS.is_debug_build()`.

## 2. Environment และวิธีทดสอบ

Godot `4.7.stable.official.5b4e0cb0f`. ทดสอบทั้ง headless และ Windows rendering window ที่รันอัตโนมัติ. Rendered run ใช้ OpenGL 3.3 Compatibility บน NVIDIA GeForce RTX 4060 Laptop GPU. Viewport 1280×720. เป็น automated runtime + การตรวจภาพจริง; ยังไม่ได้ human playtest ระยะยาวหรือ performance benchmark.

คำสั่งทำซ้ำจาก project root:

```powershell
.\tests\run_tests.ps1 -Godot 'C:\Users\ADMIN\Desktop\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64.exe' -WithRendering
```

Runner imports ก่อนทดสอบ, ใช้ `--fixed-fps 60` ใน scene tests, ตรวจทั้ง exit code และข้อความผิดพลาดใน log. โฟลเดอร์ log ปกติคือ `.godot/test-logs/`. รอบนี้เก็บ raw logs ใน Codex workspace `work/phase2_test_logs/` และสำเนาไว้ใน `.godot/test-logs/` ของ project.

## 3. Tests performed / results

| Test run | สิ่งที่ตรวจ | ผลสุดท้าย |
|---|---|---|
| Editor import | project/resources/global classes/parser | exit 0; ไม่มี Script Error |
| `stage_1_test.gd` | spawn/floor, Matt animation, camera, walk/sprint, boundary collision, yaw/pitch clamp | 8 checks ผ่าน |
| `stage_2_interaction_test.gd` | ระยะ, action activation ครั้งเดียว, disabled target, wall occlusion, target ถูกลบ | 7 checks ผ่าน |
| `stage_3_stats_test.gd` | HP clamp/negative input/death ครั้งเดียว, หยุดผู้เล่นเมื่อตาย, sprint drain, recovery delay/recovery, exhaustion, restore, 30/120-step drain | 11 checks ผ่าน |
| `stage_4_clock_test.gd` | 600s→18:00, midnight, dawn/day counter, signals ครั้งเดียว, x20, pause, multi-day skip, rewind clamp, lighting, 72,000 fractional ticks | 13 checks ผ่าน |
| `movement_rate_test.gd` | เดินหนึ่งวินาทีที่ 30/120 physics Hz | 3.7333m / 3.6834m; ต่าง ~0.05m < tolerance 0.15m; ผ่าน |
| Integration headless | Input Map, physical key events, HUD update, debug on/off, interaction, time, death/restore/restart | 24 checks ผ่าน; captured mouse ข้ามเพราะ headless |
| Main scene boot | เปิด main scene โดยใช้ project run path ปกติ 120 frames | exit 0; ไม่มี Script Error |
| Rendered integration | ทั้งระบบร่วมกัน, RMB mouse capture/rotation, Escape, ภาพวัน/คืน, restart | 27 checks ผ่าน รวม captured mouse และ screenshot saves |

**Final suite: failures=0; ทั้ง 9 runs exit 0.** Headless mouse skip ถูกตรวจต่อใน rendered run แล้ว. ไม่มี parser error, missing node/resource, signal error หรือ runtime script error จากระบบ Phase 2 ในผลสุดท้าย.

### ตรวจภาพจริง

- Day: Matt แสดง material/texture และท่ายืน, camera เห็นผู้เล่น/สถานี, HUD แสดง Day 1 14:32, HP/stamina และ interaction feedback.
- Night: scene เปลี่ยนเป็นโทนมืด, shelter มีแสงอุ่น, player/ground/HUD ยังมองเห็น.
- ภาพ: [กลางวัน](docs/phase2/day.png), [กลางคืน](docs/phase2/night.png).

## 4. Known bugs / limitations

- **Environment message:** engine พิมพ์ `ERROR: Failed to read the root certificate store.` ใน environment นี้ตั้งแต่ Phase 1. Runner แยกรายงานข้อความนี้และเก็บไว้ใน raw log; ไม่ได้นับเป็น test failure. ไม่มีการใช้ network ในระบบใหม่ และไม่พบ script error ของ Phase 2. ไม่ได้แก้ Windows certificate configuration.
- ยังไม่มีข้อผิดพลาด gameplay ที่พบจากชุดทดสอบสุดท้าย แต่ผลนี้ไม่ครอบคลุม human playtest ระยะยาว, release export หรือ mobile.
- Scene เป็น greybox และไม่มีเสียง. Clock ยังเดินเมื่อตัวละครตายใน prototype; R เริ่มใหม่ และ F12 คืน vitals ใน debug.
- ไม่มีการทดสอบ FPS/VRAM ภายใต้จำนวนศัตรู/พืชจำนวนมาก เพราะระบบเหล่านั้นยังไม่อยู่ใน Phase 2.

## 5. Technical debt

- Hero/environment เป็น placeholder; ควรปรับ collider/model scale ตาม visual ใหม่เมื่อเลือก art สุดท้าย.
- UI เป็น prototype theme; ยังไม่มี menu/settings/rebinding และ static control help ยังใช้ชื่อปุ่มเริ่มต้น.
- Generated GLB import metadata ใช้ shared defaults และ ignore ใน Git. ต้อง track per-asset `.glb.import` เมื่อเริ่มมี custom import settings.
- Source asset license/attribution ยังไม่มีใน project; รอหลักฐานต้นทางก่อนเผยแพร่.
- Resource definitions, full game phase coordinator และ save schema ยังไม่สร้าง เพราะยังไม่จำเป็นต่อ Phase 2.

## 6. Placeholder assets

ใช้ `Asset/Post Apocolypse Pack.undefined-glb/Characters Matt.glb` เป็น Somchai ชั่วคราวที่ scale 1.1; ซ่อน knife prop ที่ติดมา. Ground, shelter, farm plots, workbench, boundaries, spawn markers, rescue area และ test station เป็น primitive. ไม่มีแปลง/พืช/บ้าน/gameplay จริงจาก placeholder เหล่านี้.

## 7. Systems ready for next phase

- `Interactable.interact(actor)` และ prompt/feedback signal สำหรับวัตถุประเภทใหม่.
- Reusable player, health/stamina component และ tuning ใน Inspector.
- `GameClock` time/day/night signals สำหรับ growth/wave/unlock ในภายหลัง.
- HUD binding, main world markers และ automated test runner.

## 8. Systems not yet implemented

Farming, growth, seeds, inventory, crafting, weapons/ammo/projectiles/combat, zombie/navigation AI/waves, loot/unlocks, sleep/rest, final night, rescue ending, save. ไม่มี autoload หรือ singleton ที่เพิ่มใน Phase 2.

## Git / suggested commits

ไม่ได้ commit/push/deploy. GLB เดิมครบ 243 ไฟล์ตรวจ SHA-256 แล้วไม่เปลี่ยน. เอกสาร Phase 1 ที่ untracked อยู่ก่อนเริ่มยังเก็บไว้ทั้งหมด.

Suggested logical commit messages:

1. `Add Godot 4.7 prototype world and third-person player`
2. `Add interaction and player health-stamina foundation`
3. `Add game clock, day-night lighting, HUD and debug controls`
4. `Add Phase 2 runtime tests and update project documentation`

**Phase 2 เสร็จแล้ว หยุดรอ prompt ถัดไปก่อนเริ่มระบบใหม่.**
