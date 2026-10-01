# ASSET_ANALYSIS — Somchai's Last Harvest

## Current: Gameplay & Character Refinement

Actual imported/rendered audit covers138 candidates: all68 Nature sources,59 weapon-related candidates (including two Battery filename false positives),nine actors and two optional fantasy accents. All other supplied GLB names were checked for vegetation candidates. Matt has43 bones/20 usable native clips; no authored crop growth sets or dedicated aim/shoot/reload/strafe/backward/bat clip. Reuse Wooden Bat Barbed.glb and eight distinct vegetation models, preserving native source GLBs/materials. [Full Nature selection table](PLANT_VISUAL_ASSET_MAPPING.md), [animation/bat audit](GAMEPLAY_REFINEMENT_REPORT.md), [rendered evidence](docs/gameplay_refinement/README.md). Prior environment source counts below are historical and are not crop/weapon totals.

## Historical: Final environment cleanup

Use 56 of 244 unchanged source GLBs for 11,707 decorative placements (11,019 grass /688 others), through 54 MultiMesh mesh batches plus native Cabin/tower scenes. Remove 14 unused preloads and 18 misplaced/redundant instances; do not delete sources. Cabin exterior tones use material copies. Ground selected rocks/leaning tools/stacks without changing core systems or vegetation generation. [Current table](MAP_ASSET_USAGE.md), [cleanup report](MAP_FINAL_CLEANUP_REPORT.md), [scope](docs/map_final_cleanup/scope_audit.json). The previously supplied Cabin remains the 244th GLB; the inventory of 243 original pack files remains historical.

## Earlier phase records

The following sections preserve earlier versions and their stated counts; current source/evidence is described above.

## Historical map beautification source update

Asset/Cabin.glb is a separately supplied244th GLB, inspected/rendered as221 meshes and25 materials. Its9.5 m static wrapper now supplies the furnished farmhouse, with a wider accessible entry and floor aligned to terrain. Source GLB is unchanged. Existing nature/prop variants supply11,019 grass tufts and authored clusters through68 MultiMesh mesh batches. Current source has70 environment models/11,725 placed instances. All243 original models and supplied Cabin/audio are hash-preserved. MAP_BEAUTIFICATION_REPORT.md and current MAP_ASSET_USAGE.md contain scope, selection and measured costs. Historical pack analyses below remain applicable to their stated scope.

## Major map coverage audit (2026-10-01)

Opened/rendered all243 original GLBs in current Godot;197 broad environment/decor candidates, including optional RPG/fantasy items. Actual bounds/mesh/collider/triangle inventory and13 current contact pages retained. Selected69 distinct existing models across all five packs with actual zone purposes, instead of using only seven prior dressing assets. No house/barn/hill/cliff meshes exist; authored terrain and simple building shells supply those roles. All original source hashes unchanged. See ENVIRONMENT_ASSET_INVENTORY.md, MAP_ASSET_USAGE.md and docs/map_redesign. No character/weapon artwork or new external assets introduced.

## Refinement Pass 1 update (2026-10-01)

Reuse existing Chest, Barrel, Pallet, Traffic Barrier, Pine, Rock Medium and Shovel for static farm/base/approach scenery. No new item or storage behavior. Matt has 43 bones / 20 imported clips; dedicated aim/fire/reload/strafe/tool clips are absent. The current procedural rifle pose is documented separately from imported animation. All 243 original GLBs match the pre-pass hashes. See [the refinement report](POST_PRODUCTION_REFINEMENT_1.md) and `docs/refinement1/asset_audit.json`.

## Phase 3 implementation status — 2026-09-29

ใช้ `Asset/Stylized Nature MegaKit.undefined-glb/Plant.glb` จริงผ่าน `NaturePlantVisual.tscn` wrapper scale0.65 สำหรับพืชทั้ง5ชนิด. ตรวจภาพในrendererแล้ว; ใช้seedmarker/scale/produceprismสีต่างกันและป้ายเพื่อสื่อ4growthstages. ไม่มีโมเดลพืชโลหะ/กระดาษ/สมุนไพรเฉพาะ จึงเป็นplaceholder. แปลงดิน/ridgesเป็นprimitive. เพิ่มSVGicons10ไฟล์ใน `assets/ui/items/` สำหรับเมล็ด/วัสดุ. MattและgreyboxจากPhase 2ยังใช้เดิม.

OriginalGLBs243ไฟล์SHA256ตรงกับPhase 1ทั้งหมด; ไม่แก้/ลบ/ย้ายต้นฉบับ. Licenseข้อมูลยังเท่าเดิม. Farming/inventoryทำงานแล้วและผ่านfullruntime loop; ไม่ได้เพิ่มcrafting/combat/zombie. รายละเอียดและภาพอยู่PHASE_3_TEST_REPORT.md. เนื้อหาด้านล่างเก็บผลวิเคราะห์/คำแนะนำPhaseก่อนเป็นbaseline; assetอื่นยังเป็นcandidateสำหรับอนาคต.


## สถานะหลัง Phase 2 (2026-09-28)

ตอนนี้มี `project.godot`, Godot 4.7 / Compatibility, MainWorld/Player/HUD และ foundation scripts แล้ว. ใช้ Matt จาก GLB จริงพร้อม Idle/Walk/Run/Death และตรวจภาพใน renderer แล้ว. GLB ต้นฉบับไม่เปลี่ยนทั้ง 243 ไฟล์. รายงานด้านล่างเป็น **ผลสำรวจต้นฉบับเมื่อ Phase 1**; ข้อความว่าไม่มี Godot project เป็นสถานะก่อน Phase 2. สถานะปัจจุบันและผล runtime อยู่ใน `PROGRESS.md` / `PHASE_2_TEST_REPORT.md`.

## ขอบเขตและหลักฐาน (Phase 1)

- ตรวจ repository ที่ระบุจริงเมื่อ 2026-09-28: `README.md` มีเพียงชื่อโครงการ; ยังไม่มี `project.godot`, scene, script, resource, addon, autoload, Input Map หรือ renderer setting ของเกมนี้ จึง **ยังยืนยัน Godot version/renderer ของโครงการไม่ได้**. Godot 4.7 ที่ติดตั้งในเครื่องเป็นเพียงเครื่องมือทดสอบ ไม่ใช่เวอร์ชันที่โครงการกำหนด.
- ตรวจ GLB ทั้ง **243 ไฟล์ / 105,543,837 ไบต์ (ประมาณ 100.65 MiB)** ใน `Asset/` ทั้ง 6 โฟลเดอร์: อ่าน header, glTF JSON, mesh/accessor, material/texture, animation/skin, transform, ชื่อ node และขนาด bounding box; เปิดภาพตัวอย่างเรนเดอร์จาก geometry/material จริงของทุกไฟล์เพื่อแยกประเภทและเปรียบเทียบสไตล์. ภาพนี้เป็นการเรนเดอร์ตรวจสอบแบบง่าย ไม่ใช่ภาพยืนยันคุณภาพ shading ใน Godot.
- ไฟล์ทั้งหมดเป็น **GLB/glTF 2.0** จาก `FBX2glTF v0.9.7`, ไม่มี `extensionsRequired` และโครงสร้าง GLB อ่านได้ครบ 243/243. นำสำเนาไป import ในโครงการทดสอบแยกต่างหากด้วย **Godot 4.7 stable**: ได้ `.scn` 243/243 และ `.glb.import` 243/243; ไม่พบตัวบ่งชี้ import ไม่สำเร็จ. ต้องตรวจภาพ/animation/scale อีกครั้งใน scene เกมจริง.
- ไม่มีไฟล์เสียง, UI sprite/font, VFX particle, material/resource ภายนอก หรือไฟล์ scene ของเกม. Texture อยู่ภายใน GLB; บาง GLB มี material สีล้วน.

## ภาพรวมราย pack

| Pack | ไฟล์ | ขนาดต้นฉบับ | Mesh triangles รวม | Material / embedded images | Animation / skeleton | แนวใช้ |
|---|---:|---:|---:|---:|---|---|
| Low Poly Military Vehicles | 9 | 1.27 MiB | 18,886 | 63 / 0 | ไม่มี | พาหนะประกอบฉาก; Helicopter สำหรับ rescue ending |
| Post Apocolypse Pack | 54 | 9.10 MiB | 119,344 | 59 / 54 PNG 512² | 10 ไฟล์มี animation/skin, 184 clips รวม | ตัวละคร, ซอมบี้, อาวุธ, ฉากชานเมือง |
| Stylized Nature MegaKit | 68 | 85.11 MiB | 148,947 | 88 / 108 PNG ราว 1024² | ไม่มี | ธรรมชาติและพืชภาพชั่วคราว |
| Survival Pack | 32 | 0.87 MiB | 14,745 | 93 / 0 | ไม่มี | เครื่องมือ, เวชภัณฑ์, วิทยุ, เต็นท์ |
| Ultimate Guns Pack | 25 | 1.69 MiB | 31,742 | 99 / 0 | ไม่มี | ทางเลือกอาวุธในอนาคต |
| Ultimate RPG Items Bundle | 55 | 2.61 MiB | 48,869 | 143 / 0 | ไม่มี | พร็อพ fantasy ในระยะหลัง |

หมายเหตุ: triangles รวมคือผลบวกทุกไฟล์ รวม variant; ไม่ใช่จำนวนในหนึ่งฉาก. ภาพ PNG ซ้ำกันในแต่ละไฟล์: Post Apocolypse 54 image instances แต่เนื้อภาพไม่ซ้ำมี 2 แบบ; Nature 108 instances แต่เนื้อภาพไม่ซ้ำมี 15 แบบ. การ import อาจสร้าง resource แยกสำหรับแต่ละไฟล์ จึงต้องวัด memory จริงก่อนทำ mobile build.

## สิ่งที่ตรวจพบเชิงเทคนิค

- **Animation:** มีจริงเฉพาะ 10 GLB ใน Post Apocolypse Pack: `Big arm` 14, `Characters Matt/Sam/Shaun/Lis` อย่างละ 20, `Characters Pug` 11, `German Shepard` 22, `Zombie half` 9, `Zombie-VlXjG0N8Eg` 32, `Zombie` 16 clips ตาม glTF. ตัวละคร/ซอมบี้มี skeleton; ในตัวอย่าง Godot import `Characters Matt` และ `Zombie` ได้ `AnimationPlayer` กับ `Skeleton3D`. บางคลิปใน GLB variant เป็นชื่อซ้ำต่าง prefix จึงต้องคัดเลือกหลังตรวจ playback.
- **Material/texture:** Post Apocolypse ใช้ PNG atlas 512×512 ฝังไฟล์; Nature ใช้ PNG ประมาณ 1024×1024 ฝังไฟล์ รวม 38 material แบบ `BLEND` และ 50 `OPAQUE`; อีก 4 pack ใช้ material สีโดยไม่มี embedded texture. พืชโปร่งใสของ Nature อาจมี overdraw กลางคืน/บนมือถือ.
- **Scale/orientation:** ค่าประมาณจาก scene-space bounding box หลังใช้ node transform ไม่ใช่ขนาด gameplay ที่รับรอง: `Characters Matt` ~2.01×1.51×0.97, `Zombie` ~2.35×1.64×0.77, `Pine` ~6.42×8.72×6.22, `Tent` ~14.58×10.32×24.87, Post `Pistol` ~0.14×0.34×0.98, Ultimate Guns `Pistol` ~1.82×1.16×0.32. เต็นท์/ปืนบาง pack มีขนาดและแกนไม่สอดคล้องกัน ต้องกำหนดมาตรฐานเมตรและทำ wrapper scene พร้อมสเกล/จุดจับก่อนใช้งาน.
- **Collision:** ไม่พบ node ชื่อ collision/physics หรือข้อมูล physics ใน GLB ทั้งชุด; ตัวอย่าง 7 โมเดลที่ instantiate ใน Godot ไม่มี `CollisionShape3D`. ต้องสร้าง collider เองใน reusable scene; อย่าใช้ visual mesh collider โดยไม่วัดต้นทุน.
- **LOD:** ไม่พบ LOD node หรือ extension ใน GLB ต้นฉบับ. ตัวนำเข้า Godot มีตัวเลือกสร้าง LOD อัตโนมัติ แต่ต้องตรวจผลและวัดเกมจริง. กลุ่ม `Twisted Tree` หนักสุดประมาณ 9–10k triangles ต่อต้น; ตัวละคร `Characters Shaun` 10,758 triangles; ใช้จำนวน/ระยะมองอย่างจำกัดบน mobile.
- **หลาย mesh:** ส่วนใหญ่ไฟล์ละ 1 mesh; ตัวละคร/ซอมบี้บางไฟล์ 2–3 mesh (รายละเอียดในตาราง). อาวุธ/พร็อพทั่วไปไม่มี skeleton หรือ animation จึงต้องจัดจุดจับ/การเคลื่อนไหวด้วย scene ของเกมภายหลัง.
- **ความซ้ำ:** ไม่มีไฟล์ GLB ที่ hash ตรงกันทั้งไฟล์. ชื่อที่มี suffix เช่น `Pine-...`, `Pistol-...` เป็น variant รูปร่าง/สี/รายละเอียด ไม่ควรลบทิ้งเพียงเพราะชื่อคล้ายกัน.
- **Desktop/mobile:** Desktop เหมาะเป็น platform เป้าหมาย Demo แรกตามขนาดชุด asset นี้. Mobile **ยังยืนยันไม่ได้จากข้อมูลที่มี** จนกว่าจะตรวจ FPS, VRAM, fill rate, แสงกลางคืน, จำนวนซอมบี้ และ import texture บนอุปกรณ์เป้าหมาย. Nature Pack และตัวละครหลายตัวพร้อมกันเป็นจุดเสี่ยงหลัก.

## Art direction ที่อิง asset จริง

แนะนำ **stylized low-poly post-apocalypse**: ใช้คน/ซอมบี้/ปืน/ลังจาก Post Apocolypse เป็นแกนภาพ, ธรรมชาติ polygonal จาก Nature Pack เป็นฉาก, อุปกรณ์ survival แทรกเท่าที่ปรับสเกลแล้ว. สีหลักกลางวันเป็นเขียวหม่น น้ำตาลดิน และสนิม; เน้นสีสดเฉพาะพืชทรัพยากร/สถานะสำคัญ. กลางคืนใช้ฟ้าเทาและแสงอุ่นเฉพาะบริเวณ shelter/farm เพื่อให้อ่านศัตรูได้ชัด. `Twisted Tree` สีแดงสดและของ RPG fantasy ควรสงวนไว้ช่วงหลัง ไม่ปะปนใน Day 1. รูปทรงทุก pack เป็น low-poly แต่ความเข้มสีและวัสดุต่างกัน; ต้องทดสอบ material override/lighting ใน Godot ก่อนล็อก palette.

## ช่องว่างของ asset และความเสี่ยง

- ยังไม่มี **บ้าน/โรงนา, แปลงดิน, โต๊ะ craft จริง, รั้วฟาร์ม, พืชตะกั่ว/กระดาษ/ทองแดง/เหล็กแบบแยกชนิด, เมล็ด, กระสุน, projectile, UI, เสียง, เอฟเฟกต์**. `Plant`/`Plant Big`/เห็ดใช้เป็นภาพชั่วคราวได้ แต่ไม่สื่อผลผลิตแฟนตาซีตาม design โดยตัวมันเอง. ใช้ primitive ที่สร้างภายหลังหรือหา/ทำ asset เพิ่มเมื่อเข้าสู่ขั้น implement.
- `Tent` เป็น shelter ชั่วคราวได้ แต่ขนาด authored ใหญ่มาก; ไม่ใช่บ้าน. `Pallet` เป็นภาพแทน workbench ชั่วคราวได้ แต่ไม่ใช่โมเดล workbench.
- ซอมบี้สามชนิดยังไม่มี visual ที่แยกชัดครบทุกบทบาท: `Zombie.glb` สำหรับ Normal, `Zombie-VlXjG0N8Eg.glb` เป็น Runner candidate, `Big arm.glb` เป็น Tank candidate. ต้องดูขนาด/สี/animation ในเกมและปรับ silhouette ก่อนยืนยัน.
- **ไม่พบข้อมูล License ภายใน Project.** `README.md` มีแค่ชื่อ project; ไม่มี license/attribution/คู่มือของ pack. จึง **ยังยืนยันสิทธิ์การใช้หรือเผยแพร่ไม่ได้จากข้อมูลที่มี**; ขอหลักฐานที่มาหรือเงื่อนไขจากผู้ได้ asset ก่อนแจกจ่าย/เผยแพร่ Demo. ไม่เดาสิทธิ์จากชื่อ pack.

## รายการครบทุกไฟล์

ตารางต่อไปนี้ตรวจ GLB จริงครบทุกไฟล์. `Mat/Tex` = จำนวน material/embedded texture, `Anim/Skin` = จำนวน animation/skin, `BBox` = กว้าง×สูง×ลึกโดยประมาณใน authored scene space; ค่าอนิเมตเป็น bind/rest pose. ทุกแถวเป็น `.glb` (glTF 2.0) และผ่านการ import probe; หมายเหตุด้าน collision/LOD/สิทธิ์ด้านบนใช้กับทุกแถว. `Demo` หมายถึง asset candidate สำหรับ vertical slice ไม่ใช่การตัดสินใจใช้จริงก่อนเปิดใน Godot.

### `Asset/Low Poly Military Vehicles-glb/` (9 ไฟล์)

| Asset | บทบาทที่เป็นไปได้ | Tris | Mat/Tex | Anim/Skin | BBox | ใช้เมื่อ |
|---|---|---:|---:|---:|---|---|
| `Ambulance Car.glb` | ทางเลือกฉากหน่วยช่วยเหลือ | 2,096 | 11/0 | 0/0 | 1.492×2.132×4.237 | ภายหลัง |
| `Bike.glb` | พาหนะประกอบฉาก | 2,320 | 4/0 | 0/0 | 1.678×2.792×4.828 | ภายหลัง |
| `Helicopter.glb` | ฉากหน่วยช่วยเหลือ/ฉากจบ | 1,088 | 7/0 | 0/0 | 41.341×11.415×45.202 | ภายหลัง |
| `Jeep.glb` | ซากพาหนะริมแผนที่ | 1,942 | 8/0 | 0/0 | 2.039×2.33×4.556 | ทางเลือก |
| `Light Tank.glb` | พาหนะประกอบฉาก | 3,088 | 5/0 | 0/0 | 2.056×2.401×4.61 | ภายหลัง |
| `Military Boat.glb` | พาหนะประกอบฉาก | 868 | 9/0 | 0/0 | 10.008×6.289×26.461 | ภายหลัง |
| `Military Motorbike.glb` | พาหนะประกอบฉาก | 2,868 | 5/0 | 0/0 | 2.077×2.206×5.21 | ภายหลัง |
| `Tank.glb` | พาหนะประกอบฉาก | 2,796 | 7/0 | 0/0 | 1.866×1.61×4.563 | ภายหลัง |
| `Truck.glb` | ซากพาหนะริมแผนที่ | 1,820 | 7/0 | 0/0 | 1.936×2.228×4.431 | ทางเลือก |

### `Asset/Post Apocolypse Pack.undefined-glb/` (54 ไฟล์)

| Asset | บทบาทที่เป็นไปได้ | Tris | Mat/Tex | Anim/Skin | BBox | ใช้เมื่อ |
|---|---|---:|---:|---:|---|---|
| `Axe.glb` | เครื่องมือ/อาวุธประชิด | 790 | 1/1 | 0/0 | 0.301×0.088×1.3 | Demo |
| `Barrel.glb` | พร็อพพื้นที่ craft | 882 | 1/1 | 0/0 | 0.704×1.145×0.704 | Demo |
| `Big arm.glb` | Tank zombie ตัวเลือก | 5,670 | 1/1 | 14/1 | 2.984×1.567×0.641 | ภายหลัง |
| `Blood Splat-oQDW3k5As5.glb` | คราบเลือด | 74 | 1/1 | 0/0 | 1.713×0×1.319 | ทางเลือก |
| `Blood Splat.glb` | คราบเลือด | 130 | 1/1 | 0/0 | 3.414×0×3.562 | ทางเลือก |
| `Blood.glb` | คราบเลือด | 82 | 1/1 | 0/0 | 1.719×0×2.142 | ทางเลือก |
| `Characters Matt.glb` | Somchai ชั่วคราว (มีคลิปปืน) | 7,070 | 2/1 | 20/1 | 2.008×1.508×0.965 | Demo |
| `Characters Pug.glb` | สัตว์ประกอบฉาก | 3,603 | 1/1 | 11/3 | 0.436×0.757×1.061 | ทางเลือก |
| `Characters Sam.glb` | ตัวละครผู้เล่นทางเลือก | 9,636 | 2/1 | 20/1 | 2.043×1.53×1.245 | ทางเลือก |
| `Characters Shaun.glb` | ตัวละครผู้เล่นทางเลือก | 10,758 | 2/1 | 20/1 | 2.011×1.534×1.425 | ทางเลือก |
| `Chest-RfSBvgcZUD.glb` | คลังของ | 3,422 | 1/1 | 0/0 | 0.852×0.406×0.483 | Demo |
| `Chest.glb` | คลังของ | 3,190 | 1/1 | 0/0 | 0.64×0.406×0.483 | Demo |
| `Cinder Block.glb` | พร็อพ post-apocalypse | 368 | 1/1 | 0/0 | 0.472×0.227×0.215 | ทางเลือก |
| `Container Green.glb` | ฉากขอบแผนที่ | 1,336 | 1/1 | 0/0 | 5.709×2.603×2.561 | ทางเลือก |
| `Container Red.glb` | ฉากขอบแผนที่ | 1,032 | 1/1 | 0/0 | 5.708×2.603×2.559 | ทางเลือก |
| `Cross walk.glb` | พร็อพ post-apocalypse | 188 | 1/1 | 0/0 | 8×0.1×8 | ทางเลือก |
| `Damaged Couch.glb` | พร็อพ post-apocalypse | 3,078 | 1/1 | 0/0 | 3.013×1.244×1.214 | ทางเลือก |
| `Fire Hydrant.glb` | พร็อพ post-apocalypse | 976 | 1/1 | 0/0 | 0.515×0.772×0.399 | ทางเลือก |
| `German Shepard.glb` | สัตว์ประกอบฉาก | 4,898 | 1/1 | 22/1 | 0.493×0.944×1.52 | ทางเลือก |
| `Guitar.glb` | พร็อพ post-apocalypse | 2,325 | 1/1 | 0/0 | 0.721×0.129×1.797 | ทางเลือก |
| `Knife.glb` | อาวุธประชิด | 860 | 1/1 | 0/0 | 0.151×0.079×0.821 | ทางเลือก |
| `Lis.glb` | ตัวละครผู้เล่นทางเลือก | 7,785 | 2/1 | 20/1 | 2.043×1.744×1.443 | ทางเลือก |
| `Pallet Broken.glb` | พร็อพ | 216 | 1/1 | 0/0 | 0.917×0.164×1.222 | ทางเลือก |
| `Pallet.glb` | โต๊ะชั่วคราว/พร็อพ | 240 | 1/1 | 0/0 | 0.893×0.14×1.217 | Demo |
| `Pipes.glb` | พร็อพ post-apocalypse | 1,496 | 1/1 | 0/0 | 0.748×0.671×3.355 | ทางเลือก |
| `Pistol.glb` | อาวุธเริ่มต้น | 1,446 | 1/1 | 0/0 | 0.141×0.34×0.976 | Demo |
| `Plastic Barrier.glb` | ขอบพื้นที่ | 852 | 1/1 | 0/0 | 1.035×0.6×0.334 | ทางเลือก |
| `Rifle.glb` | อาวุธระยะหลัง | 2,103 | 1/1 | 0/0 | 0.114×0.518×1.636 | ภายหลัง |
| `Shotgun.glb` | อาวุธระยะหลัง | 1,542 | 1/1 | 0/0 | 0.095×0.338×1.113 | ภายหลัง |
| `Smg.glb` | อาวุธระยะหลัง | 2,497 | 1/1 | 0/0 | 0.151×0.472×0.994 | ภายหลัง |
| `Spear.glb` | อาวุธประชิด | 3,200 | 1/1 | 0/0 | 0.137×0.154×2.011 | ทางเลือก |
| `Street Light.glb` | พร็อพ post-apocalypse | 426 | 2/1 | 0/0 | 0.364×6.643×2.925 | ทางเลือก |
| `Street Straight Crack-l7c8pppfFj.glb` | ถนนขอบแผนที่ | 676 | 1/1 | 0/0 | 8×0.58×8 | ทางเลือก |
| `Street Straight Crack.glb` | ถนนขอบแผนที่ | 576 | 1/1 | 0/0 | 8×0.285×8 | ทางเลือก |
| `Street Straight.glb` | ถนนขอบแผนที่ | 228 | 1/1 | 0/0 | 8×0.12×8 | Demo |
| `Street T.glb` | ถนนขอบแผนที่ | 180 | 1/1 | 0/0 | 8×0.1×8 | ทางเลือก |
| `Street Turn.glb` | ถนนขอบแผนที่ | 220 | 1/1 | 0/0 | 8×0.12×8 | ทางเลือก |
| `Town Sign.glb` | พร็อพ post-apocalypse | 1,397 | 1/1 | 0/0 | 5.985×5.352×1.735 | ทางเลือก |
| `Traffic Barrier-nugx3heueH.glb` | ขอบพื้นที่ | 732 | 1/1 | 0/0 | 1.555×1.112×0.881 | Demo |
| `Traffic Barrier.glb` | ขอบพื้นที่ | 364 | 1/1 | 0/0 | 1.555×0.802×0.78 | Demo |
| `Traffic Cone-VGvQupNGtK.glb` | พร็อพ post-apocalypse | 460 | 1/1 | 0/0 | 0.595×0.736×0.595 | ทางเลือก |
| `Traffic Cone.glb` | พร็อพ post-apocalypse | 134 | 1/1 | 0/0 | 0.522×0.673×0.522 | ทางเลือก |
| `Traffic Light-lg9AKWejnF.glb` | พร็อพ post-apocalypse | 1,369 | 1/1 | 0/0 | 5.338×4.664×1.923 | ทางเลือก |
| `Traffic Light.glb` | พร็อพ post-apocalypse | 849 | 1/1 | 0/0 | 1.513×4.664×1.511 | ทางเลือก |
| `Trash Bag.glb` | พร็อพ post-apocalypse | 1,044 | 1/1 | 0/0 | 0.497×0.564×0.503 | ทางเลือก |
| `Trash Bags.glb` | พร็อพ post-apocalypse | 2,088 | 1/1 | 0/0 | 0.906×0.53×0.524 | ทางเลือก |
| `Water Tower.glb` | แลนด์มาร์ก | 1,158 | 1/1 | 0/0 | 2.646×9.38×2.708 | ทางเลือก |
| `Wheel.glb` | พร็อพ post-apocalypse | 608 | 1/1 | 0/0 | 0.573×0.204×0.573 | ทางเลือก |
| `Wheels Stack.glb` | พร็อพ post-apocalypse | 1,824 | 1/1 | 0/0 | 0.658×0.611×0.572 | ทางเลือก |
| `Wooden Bat Barbed.glb` | อาวุธประชิด | 2,188 | 1/1 | 0/0 | 0.185×0.191×1.238 | ทางเลือก |
| `Wooden Bat Saw.glb` | อาวุธประชิด | 2,308 | 1/1 | 0/0 | 0.376×0.206×1.373 | ทางเลือก |
| `Zombie half.glb` | ศัตรูคลานเพิ่มเติม | 4,774 | 1/1 | 9/1 | 0.507×1.063×0.425 | ภายหลัง |
| `Zombie-VlXjG0N8Eg.glb` | Runner zombie ตัวเลือก | 7,822 | 1/1 | 32/2 | 1.888×1.362×0.683 | หลัง Day 1 |
| `Zombie.glb` | Normal zombie | 6,174 | 1/1 | 16/3 | 2.353×1.64×0.774 | Demo |

### `Asset/Stylized Nature MegaKit.undefined-glb/` (68 ไฟล์)

| Asset | บทบาทที่เป็นไปได้ | Tris | Mat/Tex | Anim/Skin | BBox | ใช้เมื่อ |
|---|---|---:|---:|---:|---|---|
| `Bush with Flowers.glb` | พืช/หญ้าตกแต่ง | 1,368 | 2/2 | 0/0 | 1.915×1.582×1.965 | ทางเลือก |
| `Bush.glb` | ธรรมชาติ/แนวขอบแผนที่ | 900 | 1/1 | 0/0 | 1.915×1.582×1.965 | Demo |
| `Clover-u5SOgBFiut.glb` | พืช/หญ้าตกแต่ง | 615 | 1/1 | 0/0 | 0.851×1.264×0.837 | ทางเลือก |
| `Clover.glb` | พืช/หญ้าตกแต่ง | 379 | 1/1 | 0/0 | 0.796×1.145×0.764 | ทางเลือก |
| `Dead Tree-CD4edbPSGm.glb` | ต้นไม้ตาย/บรรยากาศกลางคืน | 5,648 | 1/2 | 0/0 | 8.356×16.437×8.413 | ทางเลือก |
| `Dead Tree-Mcd2zYqyww.glb` | ต้นไม้ตาย/บรรยากาศกลางคืน | 6,557 | 1/2 | 0/0 | 6.73×11.488×6.379 | ทางเลือก |
| `Dead Tree-MlmK5488ou.glb` | ต้นไม้ตาย/บรรยากาศกลางคืน | 6,169 | 1/2 | 0/0 | 6.149×9.495×5.749 | ทางเลือก |
| `Dead Tree-n8FhMgMldD.glb` | ต้นไม้ตาย/บรรยากาศกลางคืน | 5,702 | 1/2 | 0/0 | 7.961×12.771×7.732 | ทางเลือก |
| `Dead Tree.glb` | ต้นไม้ตาย/บรรยากาศกลางคืน | 5,802 | 1/2 | 0/0 | 6.388×13.28×6.43 | ทางเลือก |
| `Fern.glb` | พืช/หญ้าตกแต่ง | 288 | 1/1 | 0/0 | 9.046×2.689×8.487 | ทางเลือก |
| `Flower Group-LqTljN6Wg2.glb` | พืช/หญ้าตกแต่ง | 1,690 | 2/2 | 0/0 | 1.781×2.487×1.368 | ทางเลือก |
| `Flower Group.glb` | พืช/หญ้าตกแต่ง | 755 | 2/2 | 0/0 | 1.488×2.055×1.591 | ทางเลือก |
| `Flower Petal-eVE0j49ux9.glb` | พืช/หญ้าตกแต่ง | 15 | 1/1 | 0/0 | 0.619×0.189×0.606 | ทางเลือก |
| `Flower Petal-LqvxG9OBOU.glb` | พืช/หญ้าตกแต่ง | 13 | 1/1 | 0/0 | 0.46×0.244×0.455 | ทางเลือก |
| `Flower Petal-niuBUEJdvM.glb` | พืช/หญ้าตกแต่ง | 30 | 1/1 | 0/0 | 0.329×0.252×0.244 | ทางเลือก |
| `Flower Petal-tzG4JcqYWs.glb` | พืช/หญ้าตกแต่ง | 15 | 1/1 | 0/0 | 0.834×0.289×0.795 | ทางเลือก |
| `Flower Petal.glb` | พืช/หญ้าตกแต่ง | 15 | 1/1 | 0/0 | 0.673×0.236×0.631 | ทางเลือก |
| `Flower Single-GvfHo0roi3.glb` | พืช/หญ้าตกแต่ง | 642 | 2/2 | 0/0 | 1.072×2.419×0.773 | ทางเลือก |
| `Flower Single.glb` | พืช/หญ้าตกแต่ง | 285 | 2/2 | 0/0 | 0.907×2.068×0.878 | ทางเลือก |
| `Grass Wispy-Msr9zx66VU.glb` | พืช/หญ้าตกแต่ง | 494 | 1/1 | 0/0 | 1.322×1.072×1.21 | ทางเลือก |
| `Grass Wispy.glb` | พืช/หญ้าตกแต่ง | 622 | 1/1 | 0/0 | 1.54×1.672×1.594 | ทางเลือก |
| `Grass.glb` | ธรรมชาติ/แนวขอบแผนที่ | 155 | 1/1 | 0/0 | 0.639×1.334×0.737 | Demo |
| `Mushroom Laetiporus.glb` | พืช/สมุนไพรภาพชั่วคราว; ไม่ใช่ crop เฉพาะ | 3,216 | 1/1 | 0/0 | 1.366×0.767×1.103 | ต้นแบบ |
| `Mushroom.glb` | พืช/สมุนไพรภาพชั่วคราว; ไม่ใช่ crop เฉพาะ | 880 | 1/1 | 0/0 | 0.564×0.463×0.779 | ต้นแบบ |
| `Pebble Round-icVsN3lmVy.glb` | ธรรมชาติ/แนวขอบแผนที่ | 136 | 1/1 | 0/0 | 0.5×0.095×0.367 | Demo |
| `Pebble Round-kAMfq1uJUY.glb` | ธรรมชาติ/แนวขอบแผนที่ | 126 | 1/1 | 0/0 | 0.406×0.099×0.452 | Demo |
| `Pebble Round-KYtJ6JNXh2.glb` | ธรรมชาติ/แนวขอบแผนที่ | 114 | 1/1 | 0/0 | 0.449×0.094×0.411 | Demo |
| `Pebble Round-nMf8LHOsbM.glb` | ธรรมชาติ/แนวขอบแผนที่ | 124 | 1/1 | 0/0 | 0.419×0.101×0.346 | Demo |
| `Pebble Round.glb` | ธรรมชาติ/แนวขอบแผนที่ | 128 | 1/1 | 0/0 | 0.45×0.099×0.485 | Demo |
| `Pebble Square-2YtLzwgsWp.glb` | ธรรมชาติ/แนวขอบแผนที่ | 52 | 1/1 | 0/0 | 0.373×0.159×0.319 | Demo |
| `Pebble Square-6juX57sLHe.glb` | ธรรมชาติ/แนวขอบแผนที่ | 104 | 1/1 | 0/0 | 0.435×0.13×0.44 | Demo |
| `Pebble Square-l5XiYQj1oD.glb` | ธรรมชาติ/แนวขอบแผนที่ | 65 | 1/1 | 0/0 | 0.462×0.138×0.263 | Demo |
| `Pebble Square-Mm4RMgwNO8.glb` | ธรรมชาติ/แนวขอบแผนที่ | 78 | 1/1 | 0/0 | 0.391×0.14×0.28 | Demo |
| `Pebble Square-s71L3q1nXN.glb` | ธรรมชาติ/แนวขอบแผนที่ | 72 | 1/1 | 0/0 | 0.352×0.152×0.45 | Demo |
| `Pebble Square.glb` | ธรรมชาติ/แนวขอบแผนที่ | 48 | 1/1 | 0/0 | 0.34×0.168×0.291 | Demo |
| `Pine-699sFuLCN2.glb` | ธรรมชาติ/แนวขอบแผนที่ | 4,964 | 2/3 | 0/0 | 3.611×7.392×3.996 | Demo |
| `Pine-79gmlLnweB.glb` | ธรรมชาติ/แนวขอบแผนที่ | 3,370 | 2/3 | 0/0 | 5.802×10.236×5.371 | Demo |
| `Pine-rfnxJv0Rqa.glb` | ธรรมชาติ/แนวขอบแผนที่ | 3,947 | 2/3 | 0/0 | 4.945×7.317×4.538 | Demo |
| `Pine-Zt62gceKXZ.glb` | ธรรมชาติ/แนวขอบแผนที่ | 3,648 | 2/3 | 0/0 | 5.728×7.376×5.221 | Demo |
| `Pine.glb` | ธรรมชาติ/แนวขอบแผนที่ | 1,646 | 2/3 | 0/0 | 6.42×8.724×6.222 | Demo |
| `Plant Big-MbhbP7JrTI.glb` | พืช/สมุนไพรภาพชั่วคราว; ไม่ใช่ crop เฉพาะ | 360 | 1/1 | 0/0 | 2.89×3.756×3.126 | ต้นแบบ |
| `Plant Big.glb` | พืช/สมุนไพรภาพชั่วคราว; ไม่ใช่ crop เฉพาะ | 112 | 1/1 | 0/0 | 1.311×0.253×1.362 | ต้นแบบ |
| `Plant-xH5gNlQxAZ.glb` | พืช/สมุนไพรภาพชั่วคราว; ไม่ใช่ crop เฉพาะ | 48 | 1/1 | 0/0 | 1.048×0.25×0.962 | ต้นแบบ |
| `Plant.glb` | พืช/สมุนไพรภาพชั่วคราว; ไม่ใช่ crop เฉพาะ | 120 | 1/1 | 0/0 | 1.273×1.014×1.386 | ต้นแบบ |
| `Rock Medium-JQxF95498B.glb` | ธรรมชาติ/แนวขอบแผนที่ | 522 | 1/1 | 0/0 | 3.42×2.316×3.476 | Demo |
| `Rock Medium-s1OJ3bBzqc.glb` | ธรรมชาติ/แนวขอบแผนที่ | 342 | 1/1 | 0/0 | 3.225×2.26×2.989 | Demo |
| `Rock Medium.glb` | ธรรมชาติ/แนวขอบแผนที่ | 244 | 1/1 | 0/0 | 3.049×1.899×2.479 | Demo |
| `Rock Path Round Small-GMttpOEFKT.glb` | เส้นทางหิน | 1,126 | 1/1 | 0/0 | 1.14×0.105×1.354 | ทางเลือก |
| `Rock Path Round Small-yHEdadj5I0.glb` | เส้นทางหิน | 998 | 1/1 | 0/0 | 1.057×0.113×1.476 | ทางเลือก |
| `Rock Path Round Small.glb` | เส้นทางหิน | 1,002 | 1/1 | 0/0 | 1.179×0.109×1.29 | ทางเลือก |
| `Rock Path Round Thin.glb` | เส้นทางหิน | 2,254 | 1/1 | 0/0 | 1.457×0.11×2.089 | ทางเลือก |
| `Rock Path Round Wide.glb` | เส้นทางหิน | 3,500 | 1/1 | 0/0 | 2.111×0.113×2.129 | ทางเลือก |
| `Rock Path Square Smal-cI9XBpVijV.glb` | เส้นทางหิน | 783 | 1/1 | 0/0 | 1.019×0.15×0.974 | ทางเลือก |
| `Rock Path Square Smal-w4TKZMjjcw.glb` | เส้นทางหิน | 559 | 1/1 | 0/0 | 0.993×0.149×0.966 | ทางเลือก |
| `Rock Path Square Smal.glb` | เส้นทางหิน | 568 | 1/1 | 0/0 | 0.836×0.174×1.076 | ทางเลือก |
| `Rock Path Square Thin.glb` | เส้นทางหิน | 1,793 | 1/1 | 0/0 | 1.56×0.176×1.987 | ทางเลือก |
| `Rock Path Square Wide.glb` | เส้นทางหิน | 2,256 | 1/1 | 0/0 | 2.052×0.176×1.987 | ทางเลือก |
| `Tall Grass.glb` | พืช/หญ้าตกแต่ง | 326 | 1/1 | 0/0 | 0.895×1.873×0.993 | ทางเลือก |
| `Tree-aVOxaHRPWe.glb` | ธรรมชาติ/แนวขอบแผนที่ | 5,648 | 2/3 | 0/0 | 4.464×7.643×4.276 | Demo |
| `Tree-QVOop92WmG.glb` | ธรรมชาติ/แนวขอบแผนที่ | 3,505 | 2/3 | 0/0 | 4.063×9.425×4.241 | Demo |
| `Tree-qZtx0AHhcy.glb` | ธรรมชาติ/แนวขอบแผนที่ | 6,265 | 2/3 | 0/0 | 4.311×7.265×4.578 | Demo |
| `Tree-t9KbsfYdXz.glb` | ธรรมชาติ/แนวขอบแผนที่ | 3,182 | 2/3 | 0/0 | 3.671×7.006×4.22 | Demo |
| `Tree.glb` | ธรรมชาติ/แนวขอบแผนที่ | 4,066 | 2/3 | 0/0 | 3.826×9.438×3.755 | Demo |
| `Twisted Tree-7PDBpElkQr.glb` | ต้นไม้ fantasy ขอบแผนที่ | 9,600 | 2/3 | 0/0 | 10.381×18.738×11.293 | ภายหลัง |
| `Twisted Tree-8oraKn9m0x.glb` | ต้นไม้ fantasy ขอบแผนที่ | 10,089 | 2/3 | 0/0 | 11.357×16.073×11.506 | ภายหลัง |
| `Twisted Tree-9aWlx82xUf.glb` | ต้นไม้ fantasy ขอบแผนที่ | 9,564 | 2/3 | 0/0 | 13.516×16.725×11.549 | ภายหลัง |
| `Twisted Tree-GVTsMmuzv7.glb` | ต้นไม้ fantasy ขอบแผนที่ | 9,134 | 2/3 | 0/0 | 10.563×18.949×9.203 | ภายหลัง |
| `Twisted Tree.glb` | ต้นไม้ fantasy ขอบแผนที่ | 10,104 | 2/3 | 0/0 | 9.495×15.662×9.387 | ภายหลัง |

### `Asset/Survival Pack-glb/` (32 ไฟล์)

| Asset | บทบาทที่เป็นไปได้ | Tris | Mat/Tex | Anim/Skin | BBox | ใช้เมื่อ |
|---|---|---:|---:|---:|---|---|
| `Axe.glb` | เครื่องมือ/อาวุธ | 236 | 3/0 | 0/0 | 1.262×3.256×0.19 | ทางเลือก |
| `Backpack.glb` | ภาพแทน inventory | 1,748 | 4/0 | 0/0 | 3.343×3.119×1.746 | ทางเลือก |
| `Battery-MYa3uWdwPU.glb` | พร็อพ survival | 132 | 3/0 | 0/0 | 0.184×0.457×0.184 | ทางเลือก |
| `Battery.glb` | พร็อพ survival | 100 | 3/0 | 0/0 | 0.3×0.46×0.3 | ทางเลือก |
| `Bear Trap.glb` | พร็อพ survival | 608 | 1/0 | 0/0 | 2.992×0.675×3.544 | ทางเลือก |
| `Bonfire.glb` | จุดแสง/ที่พัก | 704 | 3/0 | 0/0 | 2.176×2.311×1.984 | ทางเลือก |
| `Can Broken.glb` | พร็อพ survival | 428 | 2/0 | 0/0 | 0.473×0.637×0.473 | ทางเลือก |
| `Can Red.glb` | พร็อพ survival | 332 | 3/0 | 0/0 | 0.473×0.637×0.473 | ทางเลือก |
| `Can.glb` | พร็อพ survival | 428 | 2/0 | 0/0 | 0.473×0.637×0.473 | ทางเลือก |
| `Compass.glb` | พร็อพ survival | 656 | 5/0 | 0/0 | 0.908×0.805×0.703 | ทางเลือก |
| `First Aid Kit-wP00rePSRD.glb` | พร็อพรักษา | 754 | 3/0 | 0/0 | 1.563×1.359×0.733 | ทางเลือก |
| `First Aid Kit.glb` | พร็อพรักษา | 268 | 4/0 | 0/0 | 1.884×1.277×0.677 | Demo |
| `Flare Gun.glb` | ฉากส่งสัญญาณ/อาวุธทางเลือก | 540 | 2/0 | 0/0 | 2.505×1.656×0.603 | ทางเลือก |
| `Gas Can.glb` | พร็อพ survival | 788 | 3/0 | 0/0 | 1.877×2.473×0.615 | ทางเลือก |
| `Knife.glb` | พร็อพ survival | 450 | 4/0 | 0/0 | 0.265×1.563×0.078 | ทางเลือก |
| `Match Burnt.glb` | พร็อพ survival | 76 | 1/0 | 0/0 | 0.057×0.569×0.082 | ทางเลือก |
| `Match.glb` | พร็อพ survival | 28 | 2/0 | 0/0 | 0.041×0.6×0.038 | ทางเลือก |
| `Matchbox.glb` | พร็อพ survival | 396 | 4/0 | 0/0 | 0.54×1.089×0.165 | ทางเลือก |
| `Pan.glb` | พร็อพ survival | 246 | 3/0 | 0/0 | 1.723×0.342×2.825 | ทางเลือก |
| `Phone.glb` | พร็อพ survival | 224 | 3/0 | 0/0 | 0.424×0.908×0.061 | ทางเลือก |
| `Pot-fyweVKYu0K.glb` | พร็อพ survival | 326 | 2/0 | 0/0 | 1.194×0.418×1.407 | ทางเลือก |
| `Pot.glb` | พร็อพ survival | 326 | 2/0 | 0/0 | 1.723×1.04×2.031 | ทางเลือก |
| `Propane Tank.glb` | พร็อพ survival | 516 | 4/0 | 0/0 | 2.155×2.891×2.05 | ทางเลือก |
| `Radio.glb` | พร็อพสื่อสารหน่วยช่วยเหลือ | 481 | 4/0 | 0/0 | 1.686×2.102×0.57 | Demo |
| `Raft Paddle.glb` | พร็อพ survival | 264 | 2/0 | 0/0 | 1.671×0.304×14.852 | ทางเลือก |
| `Raft.glb` | พร็อพ survival | 1,036 | 2/0 | 0/0 | 11.964×4.302×23.645 | ทางเลือก |
| `Shovel.glb` | เครื่องมือฟาร์ม | 322 | 3/0 | 0/0 | 0.805×3.874×0.184 | Demo |
| `Tent.glb` | ที่พักชั่วคราว (ต้องปรับสเกล) | 784 | 4/0 | 0/0 | 14.58×10.324×24.868 | Demo |
| `Torch.glb` | พร็อพ survival | 610 | 4/0 | 0/0 | 0.676×2.512×0.666 | ทางเลือก |
| `Water Bottle.glb` | พร็อพทรัพยากร | 288 | 3/0 | 0/0 | 0.499×1.435×0.499 | ทางเลือก |
| `Wood Log.glb` | ทรัพยากร/พร็อพ | 202 | 2/0 | 0/0 | 4.641×1.094×4.57 | Demo |
| `Wooden Torch.glb` | พร็อพ survival | 448 | 3/0 | 0/0 | 0.457×2.691×0.419 | ทางเลือก |

### `Asset/Ultimate Guns Pack-glb/` (25 ไฟล์)

| Asset | บทบาทที่เป็นไปได้ | Tris | Mat/Tex | Anim/Skin | BBox | ใช้เมื่อ |
|---|---|---:|---:|---:|---|---|
| `Assault Rifle-Bgvuu4CUMV.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 1,930 | 3/0 | 0/0 | 5.169×1.79×0.346 | ภายหลัง |
| `Assault Rifle-fpLucho45C.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 1,388 | 5/0 | 0/0 | 5.494×1.601×0.196 | ภายหลัง |
| `Assault Rifle.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 1,304 | 5/0 | 0/0 | 5.422×1.601×0.196 | ภายหลัง |
| `Bayonet.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 240 | 4/0 | 0/0 | 1.167×0.234×0.132 | ภายหลัง |
| `Bipod.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 476 | 2/0 | 0/0 | 0.145×1.331×1.216 | ภายหลัง |
| `Bullpup.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 2,778 | 3/0 | 0/0 | 5.248×1.541×0.31 | ภายหลัง |
| `Pistol-52kQzphmeF.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 1,878 | 3/0 | 0/0 | 2.447×1.162×0.309 | ภายหลัง |
| `Pistol-J3i9KDQ3kt.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 968 | 3/0 | 0/0 | 1.819×1.199×0.274 | ภายหลัง |
| `Pistol-Z7aOjJu583.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 1,442 | 4/0 | 0/0 | 1.845×1.293×0.329 | ภายหลัง |
| `Pistol.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 1,040 | 5/0 | 0/0 | 1.819×1.162×0.323 | ภายหลัง |
| `Revolver-9C26wSpMS0.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 1,434 | 4/0 | 0/0 | 1.985×0.982×0.294 | ภายหลัง |
| `Revolver-XrnLUz6kQj.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 1,334 | 3/0 | 0/0 | 1.901×0.963×0.294 | ภายหลัง |
| `Revolver.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 1,046 | 3/0 | 0/0 | 1.982×0.89×0.294 | ภายหลัง |
| `Scope.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 468 | 3/0 | 0/0 | 2.079×0.398×0.361 | ภายหลัง |
| `Shotgun Sawed Off.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 956 | 5/0 | 0/0 | 3.688×1.02×0.422 | ภายหลัง |
| `Shotgun Short Stock.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 1,612 | 4/0 | 0/0 | 4.471×0.967×0.247 | ภายหลัง |
| `Shotgun-ZmPTnh7njL.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 978 | 4/0 | 0/0 | 5.785×0.943×0.247 | ภายหลัง |
| `Shotgun.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 746 | 5/0 | 0/0 | 5.785×0.949×0.247 | ภายหลัง |
| `Sniper Rifle-ASOMZIErq3.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 1,382 | 5/0 | 0/0 | 7.295×1.484×0.459 | ภายหลัง |
| `Sniper Rifle-i65hEldsw6.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 1,688 | 6/0 | 0/0 | 6.336×1.899×1.248 | ภายหลัง |
| `Sniper Rifle-TKaBjAEofL.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 1,722 | 5/0 | 0/0 | 7.245×1.201×0.446 | ภายหลัง |
| `Sniper Rifle.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 1,344 | 5/0 | 0/0 | 6.336×1.348×0.459 | ภายหลัง |
| `Submachine Gun-nsP3JukU73.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 1,566 | 4/0 | 0/0 | 3.998×1.523×0.319 | ภายหลัง |
| `Submachine Gun.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 1,374 | 4/0 | 0/0 | 4.044×1.847×0.319 | ภายหลัง |
| `Tripod.glb` | ทางเลือกอาวุธ/อุปกรณ์ปืน | 648 | 2/0 | 0/0 | 1.311×1.181×1.216 | ภายหลัง |

### `Asset/Ultimate RPG Items Bundle-glb/` (55 ไฟล์)

| Asset | บทบาทที่เป็นไปได้ | Tris | Mat/Tex | Anim/Skin | BBox | ใช้เมื่อ |
|---|---|---:|---:|---:|---|---|
| `Armor Golden.glb` | พร็อพแฟนตาซี | 1,040 | 1/0 | 0/0 | 1.54×1.202×0.76 | ภายหลัง |
| `Armor Leather.glb` | พร็อพแฟนตาซี | 288 | 1/0 | 0/0 | 0.975×0.822×0.67 | ภายหลัง |
| `Armor Metal.glb` | พร็อพแฟนตาซี | 704 | 1/0 | 0/0 | 1.54×1.1×0.76 | ภายหลัง |
| `Arrow.glb` | พร็อพแฟนตาซี | 224 | 4/0 | 0/0 | 0.127×1.456×0.146 | ภายหลัง |
| `Axe Double.glb` | พร็อพแฟนตาซี | 1,556 | 4/0 | 0/0 | 0.871×2.151×0.135 | ภายหลัง |
| `Axe Small.glb` | พร็อพแฟนตาซี | 966 | 4/0 | 0/0 | 0.624×1.575×0.132 | ภายหลัง |
| `Backpack.glb` | ทางเลือกคลังของ | 3,960 | 3/0 | 0/0 | 1.067×0.951×0.804 | ภายหลัง |
| `Bag.glb` | ทางเลือกคลังของ | 1,232 | 3/0 | 0/0 | 0.802×0.627×0.487 | ภายหลัง |
| `Bone.glb` | พร็อพแฟนตาซี | 304 | 1/0 | 0/0 | 1.018×0.344×0.177 | ภายหลัง |
| `Book Open.glb` | พร็อพแฟนตาซี | 520 | 3/0 | 0/0 | 0.877×0.195×0.752 | ภายหลัง |
| `Book-h3Wh4fxSQX.glb` | พร็อพแฟนตาซี | 1,060 | 4/0 | 0/0 | 0.313×0.807×0.671 | ภายหลัง |
| `Book-LC0w7VI75u.glb` | พร็อพแฟนตาซี | 332 | 3/0 | 0/0 | 0.186×0.802×0.599 | ภายหลัง |
| `Book.glb` | พร็อพแฟนตาซี | 668 | 4/0 | 0/0 | 0.207×0.807×0.603 | ภายหลัง |
| `Chalice.glb` | พร็อพแฟนตาซี | 380 | 1/0 | 0/0 | 0.486×0.747×0.486 | ภายหลัง |
| `Chest.glb` | ทางเลือกคลังของ | 1,696 | 3/0 | 0/0 | 0.95×1.147×0.996 | ภายหลัง |
| `Claymore.glb` | พร็อพแฟนตาซี | 1,031 | 5/0 | 0/0 | 0.978×6.595×0.271 | ภายหลัง |
| `Coin Pouch.glb` | พร็อพแฟนตาซี | 414 | 2/0 | 0/0 | 0.47×0.548×0.47 | ภายหลัง |
| `Coin.glb` | พร็อพแฟนตาซี | 396 | 1/0 | 0/0 | 0.737×0.738×0.181 | ภายหลัง |
| `Crown.glb` | พร็อพแฟนตาซี | 840 | 2/0 | 0/0 | 0.886×0.585×0.886 | ภายหลัง |
| `Dagger.glb` | พร็อพแฟนตาซี | 726 | 5/0 | 0/0 | 0.297×1.389×0.111 | ภายหลัง |
| `Doublesided Hammer.glb` | พร็อพแฟนตาซี | 1,918 | 4/0 | 0/0 | 1.181×2.527×0.429 | ภายหลัง |
| `Fish Bone.glb` | พร็อพแฟนตาซี | 588 | 1/0 | 0/0 | 0.922×0.157×0.391 | ภายหลัง |
| `Glove.glb` | พร็อพแฟนตาซี | 456 | 1/0 | 0/0 | 0.598×0.268×0.956 | ภายหลัง |
| `Gold Ingots.glb` | พร็อพแฟนตาซี | 648 | 1/0 | 0/0 | 0.72×0.452×0.607 | ภายหลัง |
| `Key-bg6e1lfNsO.glb` | พร็อพแฟนตาซี | 688 | 1/0 | 0/0 | 0.428×0.095×1.012 | ภายหลัง |
| `Key-h5nke04hRD.glb` | พร็อพแฟนตาซี | 744 | 1/0 | 0/0 | 0.459×0.086×1.09 | ภายหลัง |
| `Key-MUl40QpEvv.glb` | พร็อพแฟนตาซี | 512 | 1/0 | 0/0 | 0.401×0.086×0.993 | ภายหลัง |
| `Key.glb` | พร็อพแฟนตาซี | 284 | 1/0 | 0/0 | 0.292×0.095×0.867 | ภายหลัง |
| `Knife.glb` | พร็อพแฟนตาซี | 736 | 5/0 | 0/0 | 0.644×3.106×0.256 | ภายหลัง |
| `Mineral.glb` | ภาพแทนแร่แฟนตาซี | 896 | 2/0 | 0/0 | 0.588×0.437×0.564 | ภายหลัง |
| `Necklace-Jvhs8DCNDZ.glb` | พร็อพแฟนตาซี | 824 | 3/0 | 0/0 | 0.854×1.014×0.999 | ภายหลัง |
| `Necklace.glb` | พร็อพแฟนตาซี | 792 | 3/0 | 0/0 | 0.873×0.877×0.963 | ภายหลัง |
| `Open Book-1A07aI9j2d.glb` | พร็อพแฟนตาซี | 472 | 3/0 | 0/0 | 0.918×0.176×0.752 | ภายหลัง |
| `Open Book-JEDMpG0UIR.glb` | พร็อพแฟนตาซี | 464 | 2/0 | 0/0 | 0.873×0.126×0.74 | ภายหลัง |
| `Open Book.glb` | พร็อพแฟนตาซี | 592 | 3/0 | 0/0 | 0.929×0.166×0.71 | ภายหลัง |
| `Padlock.glb` | พร็อพแฟนตาซี | 584 | 2/0 | 0/0 | 0.615×0.969×0.312 | ภายหลัง |
| `Parchment.glb` | พร็อพแฟนตาซี | 592 | 1/0 | 0/0 | 0.922×0.9×0.379 | ภายหลัง |
| `Potion Bottle-WJxYta4Z96.glb` | ภาพแทนยา/ของแฟนตาซี | 1,328 | 2/0 | 0/0 | 0.668×0.963×0.668 | ภายหลัง |
| `Potion Bottle.glb` | ภาพแทนยา/ของแฟนตาซี | 1,584 | 2/0 | 0/0 | 0.719×1.237×0.719 | ภายหลัง |
| `Scroll.glb` | พร็อพแฟนตาซี | 956 | 2/0 | 0/0 | 1.478×0.238×0.251 | ภายหลัง |
| `Scythe.glb` | พร็อพแฟนตาซี | 1,310 | 4/0 | 0/0 | 3.029×5.582×0.277 | ภายหลัง |
| `Shield Celtic Golden.glb` | พร็อพแฟนตาซี | 832 | 4/0 | 0/0 | 2.099×4.28×1.413 | ภายหลัง |
| `Shield Heater-xoHSnOjsBG.glb` | พร็อพแฟนตาซี | 1,948 | 4/0 | 0/0 | 2.005×2.564×0.597 | ภายหลัง |
| `Shield Heater.glb` | พร็อพแฟนตาซี | 1,272 | 4/0 | 0/0 | 2.005×2.564×0.599 | ภายหลัง |
| `Shield Round-lWajrVXcnA.glb` | พร็อพแฟนตาซี | 1,056 | 4/0 | 0/0 | 2×2×0.604 | ภายหลัง |
| `Shield Round.glb` | พร็อพแฟนตาซี | 1,204 | 5/0 | 0/0 | 2×2×0.604 | ภายหลัง |
| `Skull Coin.glb` | พร็อพแฟนตาซี | 568 | 1/0 | 0/0 | 0.737×0.738×0.181 | ภายหลัง |
| `Skull-ExZmhOIjka.glb` | พร็อพแฟนตาซี | 1,664 | 1/0 | 0/0 | 0.858×0.927×0.471 | ภายหลัง |
| `Skull.glb` | พร็อพแฟนตาซี | 336 | 1/0 | 0/0 | 0.583×0.76×0.58 | ภายหลัง |
| `Snowflake.glb` | พร็อพแฟนตาซี | 668 | 1/0 | 0/0 | 0.896×0.896×0.101 | ภายหลัง |
| `Spear.glb` | พร็อพแฟนตาซี | 1,202 | 4/0 | 0/0 | 0.53×9.717×0.325 | ภายหลัง |
| `Star Coin.glb` | พร็อพแฟนตาซี | 452 | 1/0 | 0/0 | 0.737×0.738×0.201 | ภายหลัง |
| `Sword-9lLmH8Et4K.glb` | พร็อพแฟนตาซี | 872 | 5/0 | 0/0 | 0.534×2.302×0.122 | ภายหลัง |
| `Sword.glb` | พร็อพแฟนตาซี | 830 | 5/0 | 0/0 | 0.433×2.735×0.101 | ภายหลัง |
| `Wooden Bow.glb` | พร็อพแฟนตาซี | 660 | 3/0 | 0/0 | 0.533×1.974×0.088 | ภายหลัง |
