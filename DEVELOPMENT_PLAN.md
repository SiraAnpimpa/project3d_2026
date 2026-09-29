# DEVELOPMENT_PLAN — Somchai's Last Harvest

## Input / selection milestone — เสร็จ 2026-09-29

หลังCamera phaseเพิ่มTabinventory, QFarming/Combat, Vshoulder, EscPause, dynamicseedlist+tier/order, centralwheelrouter, configurable3weaponslotsแยกowned/equipped, mode/selectionHUDและCombat-onlyAim. Final27runsผ่าน; ดูPHASE_INPUT_SELECTION_TEST_REPORT.md. Equipmentเป็นfoundation;ยังไม่มีGunShooting/WeaponData/ammo/reload/damage.

## Camera milestone ที่เพิ่มตามคำขอ — เสร็จ 2026-09-29

หลัง Phase 3 เพิ่ม **Over-the-Shoulder Camera & Aiming Foundation**: captured look, normal/aim movement, RMB hold, Q shoulder, smooth framing, camera collision, center ray/crosshair, menu/farming compatibility. Final24runsผ่าน; ดู PHASE_CAMERA_TEST_REPORT.md. งานนี้เป็น foundationก่อนWeapon ไม่ได้เริ่ม CraftingหรือShooting.

## เป้าหมายและขอบเขต

แผนเริ่มจาก repository ที่มี GLB 243 ไฟล์. **Phase 2 ทำ M0–M4 และ Phase 3 ทำ M5–M6 เสร็จแล้ว**. Phase 3 จำกัดเฉพาะเมล็ด/วัสดุ, inventory24 slots, UI, data-driven farming5ชนิด+testplant, 12plots, growth/harvest/debug. ไม่สร้างpickup/ammo/medicinebehavior. Final suite18 runsผ่านรวมภาพและเวลาจริง; ดูPHASE_3_TEST_REPORT.md. หลังจากนั้นทำCamera milestoneตามคำขอแยกด้านบนแล้ว; งานM7และWeaponยังต้องรอpromptถัดไป.

เป้าหมายหลักคือ **Day 1 เล่นครบวงจร** ก่อนขยายเป็น 10 วัน: 06:00 → ปลูก → เก็บเกี่ยว → craft กระสุน → 18:00 → ซอมบี้ → ต่อสู้ → wave หมด → พัก → Day 2. ทดสอบทางเลือกที่ไม่กำจัดซอมบี้จน 06:00 ด้วยเพื่อยืนยันผล no-rest. Day 10 เป็นขั้นถัดไป ไม่ใช่เป้าหมายแรก.

## ลำดับ milestone

| M | งาน | Dependency | Definition of Done |
|---:|---|---|---|
| 0 | **Project foundation / asset baseline** | เอกสารรอบนี้ | มี `project.godot` ที่เปิดใน Godot version ที่ตกลงไว้, เลือก renderer/platform, main empty scene, Input Map เบื้องต้น; import GLB candidate และดูจริงใน editor; ตั้งมาตรฐานขนาด/แกน/lighting; ไม่เปลี่ยนต้นฉบับ `Asset/`. บันทึก license source ก่อนเตรียมแจกจ่าย. |
| 1 | Player movement + camera | M0 | Somchai เดิน/วิ่ง/หมุนกล้องใน ground ทดสอบ, collider ไม่ทะลุพื้น/สิ่งกีดขวาง, ทดสอบ input keyboard/mouse และอัตราเฟรมเบื้องต้น. |
| 2 | Interaction contract + prompts | M1 | Player เห็น prompt เฉพาะเป้าหมายในระยะ, interact กับ prop ทดสอบได้หนึ่งอย่าง, ไม่ interact ทะลุวัตถุ/จากไกล. |
| 3 | Clock + phase state | M0–M2 | เวลา 06:00→18:00→06:00 ถูกต้อง, day/night phase เปลี่ยนครั้งเดียว, HUD แสดงเวลา; มี debug speed สำหรับ QA; ยังไม่ spawn enemy. |
| 4 | HP / stamina + lose condition เบื้องต้น | M1, M3 | ลด/ฟื้น/จำกัดค่าได้, UI สอดคล้อง, HP = 0 เข้าสู่ lose state ครั้งเดียว; movement ใช้ stamina ตามขอบเขต Demo. |
| 5 | **ItemData + inventory ขั้นต่ำ — Phase 3 done** | M2 | เก็บ/ใช้เมล็ด/stack item ที่มี id ได้, จำนวนไม่ติดลบ, initial supplies และผลผลิตเข้า inventory, UIแสดงถูกต้อง. Phase 3ทำเฉพาะseed/material; pickup/ammo/medicinebehaviorรอphaseของระบบนั้น. |
| 6 | **Farm plot + plant growth + harvest — Phase 3 done** | M3, M5 | ใช้ seed ลงแปลงได้, stage เติบโตตามเวลา, เก็บเกี่ยวได้ครั้งเดียวแล้วเพิ่มผลผลิตใน inventory. พืชพื้นฐานสำหรับสูตรกระสุนต้องโตทันช่วงกลางวันของ Day 1. |
| 6A | **Shoulder camera + aim foundation — done** | M1–M6 | Normal/aim, movement/strafe, crosshair/ray, collision, inventory/farming regression และ rendered walkthrough ผ่าน; ยังไม่ยิง. |
| 6B | **Input / modes / item selection — done** | M6A | Tab/Q/wheel, seedsdynamic/tier, equipment3slots, mode memory, Combat-onlyaim, runtime/regressionผ่าน |
| 7 | Crafting recipe ขั้นต่ำ | M5–M6 | สูตรตะกั่ว+กระดาษ+ทองแดง → กระสุนพื้นฐานทำงาน, ใช้วัตถุดิบแบบ atomic, ของไม่พอแล้วไม่เสีย item; workbench prototype ใช้งานผ่าน interaction. สูตรสมุนไพร→ยาเพิ่มเมื่อมี crop visual/สมดุลพร้อม. |
| 8 | ปืนเริ่มต้น + damage | M4, M5, M6A, M7 | ปืนหนึ่งชนิดยิงใช้กระสุนจริง, hit/miss ชัด, damage ส่งเข้าศัตรูทดสอบ, ไม่มี ammo แล้วไม่ยิง. ปรับ visual/จุด muzzle ของ GLB wrapper. |
| 9 | Normal zombie + navigation | M1, M4, M8 | Zombie เดินหาผู้เล่นบน map ทดสอบ, โจมตี/รับ damage/ตาย, animation Idle/Walk/Attack/Death ที่มีจริงเล่นถูก; navigation ไม่ติดสิ่งกีดขวางหลัก. |
| 10 | Night wave + rest/no-rest | M3, M4, M9 | 18:00 spawn Normal zombie จาก marker, active count ถูก; ฆ่าหมดก่อน 06:00 แล้วพัก/ฟื้น HP-stamina/ข้ามเช้า; ถ้ายังเหลือที่ 06:00 เข้าทาง no-rest และไม่ฟื้นเต็ม; transition ไม่ซ้ำ. |
| 11 | **Day 1 vertical slice** | M0–M10 | เล่นต่อเนื่องจาก 06:00 ถึง Day 2 ได้ตาม loop โดยไม่ใช้ debug command; plant→harvest→craft→shoot→survive→sleep ครบ. ทดสอบเส้นทาง wave clear, no-rest และ death. UI มีข้อมูลพอเล่นได้. |
| 12 | Day 2–10 data progression + seed unlock | M11 | day counter และ wave parameters เป็น data, Day 3–4 เริ่ม Runner, Day 7–9 เริ่ม Tank, seed ใหม่ปลดล็อกตามวันที่กำหนด; เล่น/เร่ง QA ผ่านหลายวันไม่ reset state ผิด. |
| 13 | Special plants/ammo + enemy variants | M12 | เพิ่ม fantasy crop และผลกระสุนทีละชนิดจาก data; Runner/Tank ใช้ scene/data แยก, silhouette อ่านออก, effect ที่เลือกทดสอบกับศัตรูได้. เพิ่มเท่าที่ asset และเวลาอนุญาต. |
| 14 | Day 10 final night + rescue ending | M12–M13 | Wave สุดท้ายมีหลายชนิด, รอดถึง 06:00 แล้ว trigger rescue ครั้งเดียว, มี win state/ending ที่อ่านรู้เรื่อง; แพ้ก่อนนั้นไม่ trigger rescue. |
| 15 | Polish, performance, audio/VFX, save decision | M11 เป็นต้นไป | วัด FPS/memory บน desktop เป้าหมาย, ลด draw/texture/แสงที่เกินงบ, เพิ่มเสียง/UI feedback/VFX ที่จำเป็น, ตรวจ input/animation/scale. Save system เพิ่มเฉพาะถ้า playtest 10 วันชี้ว่าจำเป็นและเวลาเพียงพอ. |

## Gate สำคัญหลัง M0 และ M11

**หลัง M0:** ตรวจสาย asset ใน editor จริง: `Characters Matt`, `Zombie`, `Big arm`, `Pine`, `Plant`, `Tent`, `Pallet`, `Chest`, Post `Pistol`, `Helicopter`. ยืนยัน import material/animation, bounding box, orientation, character height, pivot, collision wrapper และ license. หากสเกลหรือ animation ผิด ให้แก้ wrapper/import setting ก่อนเริ่ม gameplay.

**หลัง M11:** หยุดเพิ่ม feature แล้วเล่น Day 1 ซ้ำหลายรอบเพื่อวัด loop จริง. ความยาวกลางวัน 10 นาทีต้องเพียงพอสำหรับปลูก/เก็บเกี่ยว/คราฟต์; อัตราเติบโต crop, จำนวนกระสุนและจำนวนซอมบี้ต้องสมดุล. Debug time acceleration มีเพื่อ QA เท่านั้น; DoD ต้องผ่านที่ความเร็วจริงด้วย.

## ตัวอย่าง scope ของ Day 1 ที่เล็กพอทำได้

- Map เดียว: ground ง่าย, farm plots จำนวนน้อย, shelter แบบเต็นท์ชั่วคราว, pallet เป็น workbench, chest เป็น storage.
- Somchai หนึ่งตัว, ปืนหนึ่งชนิด, Normal zombie หนึ่งชนิด, wave กลางคืนหนึ่งชุด.
- Resource crop ขั้นต่ำที่ทำให้ hook เด่น: ตะกั่ว, กระดาษ, ทองแดง (ภาพชั่วคราวที่แยกสี/ป้ายให้อ่านออก), สูตรกระสุนพื้นฐานหนึ่งสูตร. สมุนไพร/ยาเพิ่มเมื่อระบบนี้เสถียร. Phase 3เพิ่มIronและSmall Herbไว้แล้วตามprompt; กระสุนธาตุยังเป็นระยะถัดไป.
- UI ขั้นต่ำ: เวลา/วัน/phase, HP/stamina, inventory จำนวนที่จำเป็น, ammo, interact prompt, wave เหลือกี่ตัว, ข้อความพัก/ไม่พัก.
- ปรับ collision ให้ใช้งานได้ แต่เก็บกราฟิกชั่วคราวไว้จนกว่า loop ผ่าน. ไม่มีเหตุผลให้ตกแต่งทั้ง map หรือเพิ่ม enemy 3 ชนิดก่อน M11.

## สิ่งที่ต้องตัดสินใจ/ตรวจเมื่อถึง milestone

| เมื่อไร | ประเด็น | เหตุผล |
|---|---|---|
| M0 | Godot version, renderer, target desktop spec และที่มาของ license asset | Repository ยังไม่มี config; สิทธิ์แจกจ่ายยังไม่ยืนยัน |
| M6–M7 | ภาพ crop แต่ละชนิด, เวลาปลูก, yield และ starter seed | Asset ปัจจุบันไม่มีพืชทรัพยากรเฉพาะ; ต้องทำ Day 1 loop ให้ทัน 18:00 |
| M10 | ซอมบี้ที่ยังเหลือเมื่อ 06:00 จะ despawn หรือคงอยู่/หนี | Brief ระบุเพียง no-rest และฟื้นไม่เต็ม; ต้องเลือกกติกาที่ชัดในเกม |
| M12–M13 | วันปลดล็อกเมล็ด, จำนวน wave, special ammo ใดอยู่ใน Demo | ป้องกัน scope บานก่อน Day 1 ผ่าน |
| M15 | Save system และ mobile target | ทดสอบ duration/performance ก่อนเพิ่มภาระระบบ |

## ลำดับงาน Prompt ถัดไป

Input/Inventory/Selectionเสร็จแล้ว. อ่านPROGRESS.mdและPHASE_INPUT_SELECTION_TEST_REPORT.mdและตรวจGitก่อนงานต่อ. รอผู้ใช้ระบุphaseถัดไป; ยังไม่เริ่มGunShooting/Craftingเอง. Weaponphaseมีmodegate/selectedweapon/aimrayพร้อม แต่ต้องออกแบบWeaponData/instancesและระบบยิงตามคำขอใหม่.
