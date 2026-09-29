# PHASE CAMERA TEST REPORT — Somchai's Last Harvest

> Historical Camera phase report. ต่อมาInput/Selection phaseเปลี่ยนI→Tab, Q→Mode, V→Shoulder, Esc→Pause และAim/CrosshairเฉพาะCombat. ผล27runsและbehaviorปัจจุบันอยู่ใน [Input / Selection report](PHASE_INPUT_SELECTION_TEST_REPORT.md). ผล24runsด้านล่างเป็นหลักฐานของCamera phaseเดิม.

วันที่ 2026-09-29 · **Over-the-Shoulder Camera & Aiming Foundation — complete**

Godot 4.7.stable.official.5b4e0cb0f / Compatibility OpenGL 3.3 / NVIDIA RTX 4060 Laptop GPU / 1280×720 / physics 60 Hz. Main scene `scenes/main/GameRoot.tscn`.

อ่านเอกสารและตรวจระบบ Phase 2–3 ก่อนแก้; baseline 18 runs ผ่าน. สำรองไฟล์ก่อนแก้ใน Codex workspace `work/camera_backup/`. Final suite **24 runs ผ่าน, failures=0**. ไม่มีการ commit/push และหยุดก่อน Weapon/Shooting.

## 1. Camera architecture

ใช้ `ThirdPersonCamera` เดิมใน `scripts/player/camera_rig.gd` ต่อจากโครงสร้างเดิม แยก yaw/pitch/shoulder/boom. เปลี่ยน SpringArm กลางตัวเป็น sphere sweep สองช่วง: จาก pivot ไปไหล่ แล้วจากไหล่ไปด้านหลัง เพื่อครอบคลุมกำแพงด้านข้างด้วย. Collision layer ใช้ World และ exclude Player RID.

`PlayerController` รับผิดชอบ movement/stamina/visual facing; อ่าน `camera_rig.is_aiming` และส่งสถานะ sprint. `CameraAimRay` แยก origin/direction/target/debug point; `AimCrosshair` แยกการวาด HUD. `GameRoot` เชื่อม inventory/death/debug ด้วย signals. Camera ไม่อ้าง inventory/farming โดยตรง.

Mouse look ใช้ `InputEventMouseMotion.screen_relative` ซึ่งเป็น displacement ไม่คูณ delta; smoothing ใช้ `1-exp(-speed*delta)` เฉพาะ FOV/offset/distance/character turn. เหตุผลของ raw displacement ตรงกับ [Godot InputEventMouseMotion](https://docs.godotengine.org/en/stable/classes/class_inputeventmousemotion.html). Camera follow ผูกกับ Player โดยตรง ไม่มี spring lag เพิ่มบนทิศเล็ง.

## 2. Camera hierarchy

```text
Player (CharacterBody3D; physics root ไม่หมุนตาม Visual)
├── CollisionShape3D
├── Visual (PlayerVisual, yaw ตาม movement หรือ aim)
│   └── Matt (original GLB, scale 1.1)
├── CameraPivot (ThirdPersonCamera; yaw; height 1.65)
│   └── Pitch (pitch clamp, เริ่ม -0.23 radians)
│       └── ShoulderOffset (signed local X)
│           └── CameraBoom (local +Z = distance)
│               └── Camera3D
├── AimRay (CameraAimRay)
└── Interactor / Health / Stamina / Inventory

HUD/Root/Crosshair (AimCrosshair)
HUD/Root/AimDebugLabel
```

แก้ scenes `Player.tscn`, `HUD.tscn`; แก้ scripts `camera_rig.gd`, `player_controller.gd`, `game_root.gd`; เพิ่ม `aim_ray.gd`, `aim_crosshair.gd`; แก้ Input Map. Production ปัจจุบัน 23 scripts / 9 scenes. ไม่แก้ PlayerVisual, farming, inventory, interaction, stats, clock หรือ production Resources.

## 3. Normal mode behavior

- Right shoulder เป็นค่าเริ่มต้น: Somchai อยู่ซ้ายของจอ, crosshair เป็นจุดจาง. Mouse หมุนได้ทันทีโดยไม่ต้องกด RMB.
- Camera4.2m / FOV70° / shoulder+0.70m ให้มุมกว้างสำหรับเดินและดูแปลง. ก้ม/เงยได้ −65°..+45° และไม่ roll.
- เดินแล้วตัวละครค่อย ๆ หันตาม movement; ยืนเฉย ๆ แล้วหมุนกล้องได้รอบตัวโดยไม่บังคับหันตัว.
- Farming ยังเลือกเป้าหมายใกล้ตัวผ่าน interactor เดิม; crosshair ไม่เปลี่ยนเป็นเครื่องเลือกแปลง. อ่าน prompt `[E] Plant` / `[E] Harvest` เป็นหลัก. เมื่อชิดแปลงมากสามารถก้ม/หมุนกล้องเพื่อเห็นต้นที่อยู่หลังตัวละครได้.

ภาพ runtime: [Normal farming](docs/camera/camera_normal_farm.png), [Ready crop](docs/camera/camera_farm_ready.png).

## 4. Aim mode behavior

- กด RMB ค้าง: distance2.6m, shoulder+0.85m, FOV55°; transition แบบ exponential. ปล่อยกลับ normal.
- Somchai หันตาม yaw ของกล้องแม้ยืนเฉย ๆ; vertical pitch อยู่ที่กล้อง. Crosshair กลางจอชัดขึ้น.
- Ray ใช้ `project_ray_origin` / `project_ray_normal` ที่ viewport center, raycast หา hit แรกด้วย mask5 (World + Interactable). Exclude Player RID. ถ้าไม่พบ hit: `aim_point = aim_origin + aim_direction * aim_max_distance`.
- อัปเดต ray หลัง pose ของกล้อง; ตรวจ clearance และ ray ทันทีเมื่อ mouse เปลี่ยนมุม รวมทั้งหลัง physics movement. Debug F1 แสดงจุดชมพู, hit/miss, ระยะ, camera forward และ Visual +Z forward; ไม่มี log ต่อเฟรม.
- เปิด bag, pause, death, focus loss หรือ Esc จะยกเลิก aim. ปิด bag กลับ normal และต้องกด RMB ใหม่.

ภาพ runtime: [Right shoulder](docs/camera/camera_aim_right.png), [Left shoulder](docs/camera/camera_aim_left.png), [Far object](docs/camera/camera_aim_far.png), [Debug point](docs/camera/camera_aim_debug.png).

## 5. Movement behavior

WASD ใช้ yaw ของกล้องบนระนาบ XZ. Normal: Visual หันตามทิศเดิน. Aim: W/S เดินหน้า/ถอย, A/D strafe โดย Visual ยังหันตามกล้อง; ความเร็ว aim2.8m/s. Walk4m/s และ sprint7m/s เดิม.

เมื่อ Shift ทำให้ sprint จริง จะออกจาก aim และใช้ stamina ตามเดิม. ถ้ายังค้าง RMB อยู่จะกลับ aim เมื่อ sprint จบ. Aim กับ sprint ไม่เกิดพร้อมกัน. การกด Shift ขณะยืนนิ่งไม่ถือเป็น sprint.

ตรวจ source `Characters Matt.glb`: Foot.L_end และ Foot.R_end อยู่ local+Y ของ foot. Importer ไม่เก็บ endpoint เป็น bone; ใช้ imported foot global rest basis + transform มาตรวจ พบ dot กับ Visual+Z **0.999993** ทั้งสองเท้า. ภาพ runtime ยืนยันเห็นด้านหลังเมื่อเดิน/เล็งไปข้างหน้า. ไม่มีการเพิ่ม rotation offset แบบเดาสุ่ม; physics root แยกจาก Visual อยู่แล้ว.

## 6. Input actions

| Action / ปุ่ม | Behavior |
|---|---|
| Mouse motion | Captured look ระหว่าง gameplay |
| move_forward/backward/left/right — WASD | Camera-relative move |
| sprint — Shift | วิ่ง; sprint จริงยกเลิก aim |
| aim — RMB hold | Aim / release กลับ normal; แทน camera_orbit เดิม |
| switch_shoulder — Q | Right↔Left; smooth offset |
| capture_mouse — LMB | Capture กลับหลัง Esc; ไม่ใช่คำสั่งยิง |
| release_mouse — Esc | Gameplay ปล่อย cursor; ขณะ bag เปิดให้ UI ปิด bag เพียงครั้งเดียว |
| toggle_inventory — I | เปิด/ปิด bag; pause world, release/capture cursor |
| interact — E | Interaction / plant / harvest เดิม |
| camera_left/right/up/down — arrows | Keyboard camera fallback; bag ใช้เลือกช่องแทน |
| F1 / F2–F12 / R | Debug และ restart เมื่อ HP0 ตามเดิม |

ไม่เพิ่ม duplicate RMB action. Cursor released จะหยุด mouse look/aim แต่ gameplay clock ยังเดิน; Esc ไม่สร้าง pause menu ใหม่. Inventory เป็นผู้รับผิดชอบ SceneTree pause ตามเดิม.

## 7. Camera tuning values

ปรับได้จาก Inspector ที่ Player/CameraPivot, Player และ Player/AimRay:

| Setting | ค่า |
|---|---:|
| mouse_sensitivity | 0.003 radians / screen pixel |
| keyboard_turn_speed | 1.8 radians/s |
| minimum_pitch_degrees / maximum_pitch_degrees | −65 / +45 |
| camera_height | 1.65m |
| normal_distance / aim_distance | 4.2 / 2.6m |
| normal_shoulder_offset / aim_shoulder_offset | +0.70 / +0.85m |
| normal_fov / aim_fov | 70 / 55° |
| aim_transition_speed | 10/s |
| collision_radius / camera_collision_margin | 0.22 / 0.04m |
| collision_return_speed | 8/s |
| collision_mask | 1 (World) |
| Camera3D near / far | 0.08 / 150m |
| Player turn_speed | 12/s |
| Player walk / aim_walk / sprint_speed | 4 / 2.8 / 7m/s |
| aim_max_distance / aim_collision_mask | 100m / 5 (World + Interactable) |

Signed offset รองรับค่าลบและคูณ `shoulder_side`. Q สลับข้างโดยไม่หมุน physics root. ค่าเหล่านี้เป็น demo tuning ของ Matt ที่ scale1.1.

## 8. Tests performed

ใช้ `tests/run_tests.ps1 -WithRendering`: import, 18 headless test scripts, main boot และ 4 rendered runs รวม24. ทุก process มี timeout60s. ตรวจ exit code, result, assertion/parser/runtime errors; ยกเว้นเฉพาะข้อความ certificate store เดิมที่ยังเก็บใน log.

| Test | สิ่งที่ตรวจ | ผล |
|---|---|---|
| camera_controls_test | look/clamp/no roll, W ที่ yaw90°, normal rotation, Matt axis, aim transitions, WASD aim, sprint/stamina, shoulder, inventory/pause/Esc/focus/death | Headless33 + rendered35 checks ผ่าน |
| camera_collision_ray_test | rear/side wall, corner orbit ก่อนและหลัง physics, ground, retract/return, fixed-contact jitter, ray3/9/25/80m, miss/self exclusion/resize | 19 checks ผ่าน |
| camera_rate_test | normal→aim หลัง0.5s ที่30/120 updates/s | FOV/distance/offset ต่างกันต่ำกว่า0.0001 |
| camera_walkthrough_test | เดินจากspawnไปfarm, mouse look ขณะเดิน, sprint, seed UI, Eplant/harvest, aim near/far, strafe, Q, debug, bag, เดินชิดกำแพงและถอยออก, night | Headless18 + rendered28 checks ผ่าน (รวม10captures) |
| Phase 2 regression | movement, interaction, HP/stamina, clock/day-night/HUD/debug/death/restart | 6 scripts + rendered integration ผ่าน |
| Phase 3 regression | data/inventory/UI/farming/debug/plant extension/growth rate/full farming loop | 8 scripts + real-time rendered integration ผ่าน |

Rendered walkthrough ใช้ input events ผ่าน viewport และ held Input actions ใน GameRoot จริง; ตัวทดสอบเดินผ่าน PlayerController. ย้ายจุดเริ่มเฉพาะตอนจัดสถานการณ์ใกล้ obstacle/shelter และยิง ray test fixture. Camera walkthrough เปิด renderer โดยไม่ใช้ fixed-fps; farming walkthrough เร่ง clock×20 เพื่อให้ได้ภาพพร้อมเก็บ ส่วน rendered Phase 3 รอ Lead โตที่×1จริง. ตรวจ screenshots จริงทุกประเภททั้ง normal/aim/shoulder/strafe/farm/bag/wall/night; ไม่อ้างว่าเป็น human keyboard playtest.

## 9. Test results

- Final **24/24 runs, exit0, failures=0**. ไม่มี ScriptError หรือ engine error ใหม่จากระบบกล้อง.
- Lead เติบโตผ่าน4stagesใน **30.297วินาทีจริง**, เก็บ Lead×2, ปลูกซ้ำ, restart reset ถูกต้อง.
- Wall contact 90 physics ticks: camera variation **0.0m**; corner orbitไม่ overlap ทั้งทันทีหลังหมุนและหลัง physics. ไม่พบ jitter ในสถานการณ์ที่ทดสอบ.
- Ray ที่3/9/25/80m ชนผิวหน้าที่ถูกต้อง; จุด hit project กลับตรง crosshair ภายใน0.05pixel. Resize viewportยังตรงกลาง.
- Aim blend หลัง0.5s: FOV55.10107°, distance2.610781m, shoulder0.848989m ทั้ง30/120Hz. Movement30/120Hz regression3.73333/3.68335m ต่าง0.05mภายใน tolerance0.15m.
- GLBต้นฉบับ243ไฟล์ SHA256ตรง baselineครบ. Scriptsเดิม18ไฟล์ไม่เปลี่ยน; แก้เฉพาะ3scriptsที่ระบุและเพิ่ม2scriptsใหม่. ไม่ rewrite ระบบฟาร์ม.
- Logs: `.godot/test-logs/camera/` (ต้นฉบับ Codex workspace `work/camera_final_logs/`), ภาพ10ไฟล์ `docs/camera/`. Reports Phase 2–3 และภาพประวัติเดิมคงไว้.

ภาพเพิ่มเติม: [Strafe](docs/camera/camera_strafe.png), [Inventory after aim](docs/camera/camera_inventory.png), [Wall close-up](docs/camera/camera_wall.png), [Night](docs/camera/camera_night.png).

## 10. Known bugs

ไม่มี failure ที่ค้างใน acceptance tests ของ phaseนี้. Engine environment ยังคงพิมพ์ `ERROR: Failed to read the root certificate store.` ตั้งแต่ baseline; เป็นข้อจำกัดของ Windows certificate access ในการรันครั้งนี้ ไม่ได้ซ่อนจาก log.

ระหว่างพัฒนา test orientation เคยอ้าง `Foot.L_end` เป็น bone แต่ importer ตัด endpoint ออก. แก้ test ให้ตรวจ bone index และ foot rest ที่มีจริงแล้ว rerunผ่าน ไม่มี index error ใน final suite.

ยังไม่มี human playtest ระยะยาว, export release, high-refresh performance benchmark หรือ moving-obstacle stress test. ภาพฟาร์มบางมุมที่ยืนชิดอาจเห็นต้นบางส่วนอยู่หลังตัวละคร; normal camera หมุน/ก้มได้เพื่อเปิดมุมมองและ prompt ยังคงอ่านได้. Night lighting เป็น greybox เดิม.

## 11. Animation limitations

ใช้ Matt Idle/Walk/Run/Death เดิม; ตรวจ transition walk/run/idle และ death/restart จาก regression. Aim ไม่มี aim pose หรือ upper-body layer. Aim strafe/backpedal ใช้ Walk เดิม จึงมี foot sliding/ก้าวไม่ตรงทิศที่เคลื่อนจริง. ยังไม่มี IK, pitch-follow ของแขน, locomotion blend tree หรือถือปืน; เก็บเป็น technical debt ของ animation/weapon phase.

## 12. Camera collision issues

ใช้ `intersect_shape` ตรวจ overlapping start ก่อน `cast_motion` เพราะ cast_motion ไม่รายงานวัตถุที่ overlap ตอนเริ่มตาม [Godot PhysicsDirectSpaceState3D](https://docs.godotengine.org/en/stable/classes/class_physicsdirectspacestate3d.html). Sphere radius0.22mครอบคลุม near plane ของ viewport/FOVที่ทดสอบ. Pull-in ทันที; ease-out8/s. Mouse rotation refresh collision ทันทีเพื่อไม่รอ physics tick.

ผ่าน rear wall, side wall, inside corner, ground และ shelterจริง. เมื่อชิดกำแพงมาก boom หดใกล้ pivot จนตัวละครอาจออกจากภาพหรือถูก near-clip; ไม่มี fade/first-person fallback ในphaseนี้. Spawn/teleportที่ฝัง pivot อยู่ใน solid geometry เป็นกรณีที่ level/spawn placement ต้องป้องกัน. ผล0jitterจำกัดที่สถานการณ์ทดสอบ ไม่ใช่ข้อรับรองทุกฉากหรือทุก frame rate.

## 13. Future weapon integration notes

ฐานพร้อมใช้: `camera_rig.is_aiming`, `aim_changed(bool)`, `controls_changed(bool)`, `pose_updated`; `CameraAimRay.aim_origin`, `.aim_direction`, `.aim_point`, `.has_hit`, `.hit_collider`, `.hit_normal`, `sample_updated`. ระบบอนาคตสามารถ subscribe หลัง ray update และอ่าน targetล่าสุดได้โดยไม่เข้าไปแก้ HUD/farming.

เมื่อผู้ใช้เริ่ม Weapon phase ให้แยก camera target ray จาก muzzle obstruction check: ไหล่ที่เยื้องอาจมองข้าม cover ได้แต่ปากกระบอกถูกบัง. Weaponควรตรวจเส้นจาก muzzle ไป aim_pointและ exclude own collider ที่เพิ่มในอนาคต. Camera hit_point เป็นข้อมูลเล็ง ไม่มีการ damage/consume item.

**Phaseนี้ไม่มี firing, bullet/projectile, weapon damage, reload, ammo consumption, weapon switching, recoil หรือ zombie hit detection. หยุดรอ promptถัดไป.**

Suggested commit message: `feat: add shoulder camera and aiming foundation` (ยังไม่ได้ commit).
