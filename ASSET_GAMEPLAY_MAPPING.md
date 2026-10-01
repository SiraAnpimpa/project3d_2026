# ASSET_GAMEPLAY_MAPPING — Somchai's Last Harvest

## Current: Gameplay & Character Refinement

Wooden Bat Barbed.glb → ammo-free Day1 fallback in the existing loadout. Native Matt Slash → bat swing with local weapon/palm adjustment; existing Idle/Walk/Run and gun variants remain locomotion. Plant Big → Lead; Clover → Paper; tall alternate Plant Big → Iron; yellow-pod Flower Single → Copper; Fern → Herb; red Bush → Fire; pale Mushroom → Ice; shelf Mushroom Laetiporus → Poison. Eight separate native silhouettes, selected after inspecting all68 Nature sources. See [PLANT_VISUAL_ASSET_MAPPING.md](PLANT_VISUAL_ASSET_MAPPING.md) for exact filenames, bounds, stages and unused candidates; [GAMEPLAY_REFINEMENT_REPORT.md](GAMEPLAY_REFINEMENT_REPORT.md) for functionality and limits. Existing map asset mapping below remains applicable to scenery; no new Water/Electric crop or Shotgun gameplay was invented.

## Historical: Final environment cleanup

Same anchors and systems: furnished Cabin→home/rest; twelve plots→two accessible farm groups; supported bench/frame/tools/rear logs/stock→workshop; rock/forest clusters→landmarks/entry screening; framed partial ruin→depot; existing dirt path/truck/cache/H/four cones/light→open rescue clearing. Remove decorative boards/gantry/asphalt/loose drainage samples and unrelated home/work props. Supplies/vise/tools remain decorative. 56 sources /11,707 placements; [runtime zone table](MAP_ASSET_USAGE.md), [report](MAP_FINAL_CLEANUP_REPORT.md). All gameplay item data, rules and ending behavior are unchanged.

## Earlier phase records

The following sections preserve earlier versions and their stated counts; current source/evidence is described above.

## Historical map beautification zone mapping

Cabin→furnished home/rest room; plots→two spaced six-plot beds; bench/tools/rear wood/stock→independent workshop; rock groups and dense green understorey→forest/ridge/zone edges; short sparse grass→combat/yard; leveled containers/vehicles/debris→abandoned depot; curved road/truck/checkpoint/aid cache→separate southeast rescue clearing.70 model sources/11,725 placements are listed in MAP_ASSET_USAGE.md. Original gameplay items and rules are unchanged; scenery chests/medical/fuel/tools remain decoration. See MAP_BEAUTIFICATION_REPORT.md. Earlier zone mappings below describe historical versions.

## Historical map zone mapping

A Farmstead→plots/tools/logs/water storage; B House→gable/porch/water tower/domestic supplies; C Workshop→bench/fuel/tools/material groups; D Combat→open meadow/retained crate cover; E Forest→rolling woodland/oak/dead tree/forester camp; F Abandoned→containers/ruins/evacuated vehicles/debris; G Road→truck/gate/sign/dirt rescue connection; H Boundary/background→ridge/rocks/trees/broken fence/blocked road/distant hills. Actual69-asset table with counts/purposes is MAP_ASSET_USAGE.md. All these supplies are decorative; existing gameplay interactions/crops/weapon/ending remain the source of game mechanics.

## Refinement Pass 1 update (2026-10-01)

Reuse existing Chest, Barrel, Pallet, Traffic Barrier, Pine, Rock Medium and Shovel for static farm/base/approach scenery. No new item or storage behavior. Matt has 43 bones / 20 imported clips; dedicated aim/fire/reload/strafe/tool clips are absent. The current procedural rifle pose is documented separately from imported animation. All 243 original GLBs match the pre-pass hashes. See [the refinement report](POST_PRODUCTION_REFINEMENT_1.md) and `docs/refinement1/asset_audit.json`.

## Phase 3 implementation status — 2026-09-29

ใช้ `Asset/Stylized Nature MegaKit.undefined-glb/Plant.glb` จริงผ่าน `NaturePlantVisual.tscn` wrapper scale0.65 สำหรับพืชทั้ง5ชนิด. ตรวจภาพในrendererแล้ว; ใช้seedmarker/scale/produceprismสีต่างกันและป้ายเพื่อสื่อ4growthstages. ไม่มีโมเดลพืชโลหะ/กระดาษ/สมุนไพรเฉพาะ จึงเป็นplaceholder. แปลงดิน/ridgesเป็นprimitive. เพิ่มSVGicons10ไฟล์ใน `assets/ui/items/` สำหรับเมล็ด/วัสดุ. MattและgreyboxจากPhase 2ยังใช้เดิม.

OriginalGLBs243ไฟล์SHA256ตรงกับPhase 1ทั้งหมด; ไม่แก้/ลบ/ย้ายต้นฉบับ. Licenseข้อมูลยังเท่าเดิม. Farming/inventoryทำงานแล้วและผ่านfullruntime loop; ไม่ได้เพิ่มcrafting/combat/zombie. รายละเอียดและภาพอยู่PHASE_3_TEST_REPORT.md. เนื้อหาด้านล่างเก็บผลวิเคราะห์/คำแนะนำPhaseก่อนเป็นbaseline; assetอื่นยังเป็นcandidateสำหรับอนาคต.


อ้างอิงไฟล์จริงใต้ `Asset/` เท่านั้น. รายการทุก GLB พร้อม mesh/material/animation/ขนาดอยู่ใน `ASSET_ANALYSIS.md`. ข้อเสนอด้านล่างเป็น **candidate สำหรับ Demo**; Phase 2 มี Player/World/HUD foundation แล้ว โดยใช้ Matt จริงและ environment greybox; asset อื่นยังเป็น candidate และไม่มี license ภายใน project ให้ยืนยันสิทธิ์เผยแพร่.

## Asset → gameplay role

| Gameplay role | Asset ที่มีจริง | ข้อเสนอสำหรับ Demo | ข้อจำกัด |
|---|---|---|---|
| Somchai | `Post Apocolypse Pack.undefined-glb/Characters Matt.glb`; ทางเลือก `Characters Sam`, `Characters Shaun`, `Lis` | **Matt เป็น placeholder**: 7,070 triangles, 20 clips, มี skeleton/ท่า gun | ชื่อ/เครื่องแต่งกายยังไม่สื่อ Somchai หรือชาวไร่; ยืนยัน texture/animation ใน Godot Phase 2 แล้ว; hero visual เฉพาะยังเป็นงานภายหลัง |
| Normal zombie | `Post Apocolypse Pack.undefined-glb/Zombie.glb` | ใช้เป็นตัวแรก: 6,174 triangles, 16 clips รวม Idle/Walk/Run/Attack/Death | 3 meshes/3 skins; ต้องทดสอบ animation selection และ performance จำนวนมาก |
| Runner zombie | `Post Apocolypse Pack.undefined-glb/Zombie-VlXjG0N8Eg.glb` | candidate สี/หน้าแยกจาก Normal: 7,822 triangles, 32 clip entries | clip ชื่อซ้ำต่าง prefix; รูปทรงยังต้องปรับ silhouette และความเร็วด้วย scene/data |
| Tank zombie | `Post Apocolypse Pack.undefined-glb/Big arm.glb` | candidate ร่างใหญ่ไหล่กว้าง: 5,670 triangles, 14 clips | ต้องตรวจขนาด/ท่าโจมตีในเกม; ไม่มี visual Tank ที่กำหนดชัดใน pack |
| Enemy ภายหลัง | `Zombie half.glb` | เก็บไว้สำหรับ crawler ในอนาคต | อย่าเพิ่มก่อน Day 1 loop; เกมออกแบบศัตรูหลัก 3 ชนิด |
| ที่พัก | `Survival Pack-glb/Tent.glb` | ใช้ **placeholder shelter** และวาง RestSpot interaction แยก | authored bbox ประมาณ 14.58×10.32×24.87 ใหญ่มากเมื่อเทียบตัวละคร; ไม่ใช่ house และต้อง normalize scale |
| Farm plots / soil | **ไม่มี** | ใช้ primitive/asset ใหม่ใน milestone Farming | GLB พืชไม่ใช่แปลงดิน |
| พืชทรัพยากรพื้นฐาน | `Stylized Nature MegaKit.undefined-glb/Plant.glb`, `Plant Big.glb`, `Mushroom.glb`, `Mushroom Laetiporus.glb` | ภาพ **ชั่วคราว** ระยะ prototype; ใส่ป้าย/สีให้แยกตะกั่ว–กระดาษ–ทองแดง–สมุนไพร | ไม่มีโมเดล crop เหล่านี้จริง และไม่มี growth stages/animation |
| เมล็ด/ผลผลิตตะกั่ว–กระดาษ–ทองแดง–เหล็ก | **ไม่มีแบบเฉพาะ** | ใช้ไอคอน/primitive ชั่วคราวเมื่อเริ่ม implement | ห้ามตีความ `Mineral.glb` ว่าเป็นโลหะทุกชนิดโดยไม่มี visual design |
| พืช fantasy/กระสุนธาตุ | `Ultimate RPG Items Bundle-glb/Mineral.glb`, `Potion Bottle.glb`, `Snowflake.glb`; `Stylized Nature.../Twisted Tree.glb` | เก็บไว้เป็น accent ในช่วงหลัง | RPG style/สีแรงกว่า core; ไม่ใช่โมเดลพืชไฟ/น้ำแข็ง/พิษที่พร้อมใช้ |
| เครื่องมือฟาร์ม | `Survival Pack-glb/Shovel.glb`; Post `Axe.glb` | Shovel เป็นพร็อพเครื่องมือ; Axe เป็น option | ไม่มี animation ขุด/ฟันใน GLB เครื่องมือ; ต้อง bind กับ player animation |
| Workbench | `Post Apocolypse Pack.undefined-glb/Pallet.glb`, `Barrel.glb` | ใช้ Pallet เป็นภาพแทนโต๊ะ craft ชั่วคราว | ไม่มี workbench จริง; collider/interaction ต้องสร้างใน scene |
| Storage | `Post Apocolypse Pack.undefined-glb/Chest.glb`; ทางเลือก RPG `Chest.glb`, Post `Container Green/Red.glb` | Post Chest เข้ากับ core post-apocalypse มากกว่า RPG chest | ไม่มี open/close animation; container ใหญ่เหมาะฉากมากกว่าช่องเก็บของหลัก |
| กระสุน/ยา | `Survival Pack-glb/First Aid Kit.glb`; RPG `Potion Bottle.glb` | First Aid Kit เป็น world prop; กระสุนต้องมี UI/item visual ใหม่ | ไม่มีโมเดล ammo หรือ crop-derived medicine เฉพาะ |
| ปืนเริ่มต้น | `Post Apocolypse Pack.undefined-glb/Pistol.glb`; ทางเลือก `Ultimate Guns Pack-glb/Pistol.glb` | Post Pistol เป็น candidate เพราะ material/style ใกล้ตัวละคร/ซอมบี้ | GLB static ไม่มี fire/reload animation; scale/orientation/pivot ต้องตั้งใน wrapper |
| ปืนภายหลัง | Post `Rifle.glb`, `Shotgun.glb`, `Smg.glb`; Ultimate Guns ทั้ง pack | ใช้เมื่อ Day 1 loop ผ่าน | เพิ่มอาวุธหลายชนิดก่อน core loop เพิ่ม scope; Ultimate Guns มีสเกล/ความมืดต่างจาก Post pack |
| ขอบแผนที่/cover | Nature `Pine`, `Tree`, `Bush`, `Rock Medium`, `Pebble Round/Square`; Post `Traffic Barrier`, `Container Green/Red` | ขอบธรรมชาติรอบ farm, barrier/container จำนวนน้อยเป็น cover | ไม่มี fence farm จริง; ต้นไม้ Nature บาง variant 9–10k triangles |
| ทางเดิน/พื้นที่สู้ | Post `Street Straight`, `Street Straight Crack`, `Street T/Turn`; Nature `Rock Path...` | ใช้ถนนเฉพาะขอบ map หรือ rescue approach; พื้นที่หลักทำ ground ใหม่ | ไม่มี terrain/ground แผ่นใหญ่ใน asset ปัจจุบัน |
| จุดติดต่อ rescue | `Survival Pack-glb/Radio.glb`, `Phone.glb`, `Flare Gun.glb` | Radio เป็น prop เล่าเรื่องและจุดเริ่มภารกิจ | ไม่มีเสียง/GUI ของการติดต่อ |
| Rescue ending | `Low Poly Military Vehicles-glb/Helicopter.glb`; ทางเลือก `Ambulance Car.glb` | Helicopter เหมาะพื้นที่ห่างไกลและ landing clearing | ไม่มี rotor/flight animation; scene/cutscene ต้องทำภายหลัง |
| UI / sound / VFX | Post `Blood`, `Blood Splat` เป็น mesh คราบเลือดเท่านั้น | UI, เสียง, particle VFX ต้องทำ/จัดหาใหม่ | ไม่มีไฟล์ UI/audio ใน repository |

## เปรียบเทียบตัวเลือกที่ซ้ำบทบาท

| บทบาท | ทางเลือก A | ทางเลือก B | แนะนำ |
|---|---|---|---|
| Somchai | Matt: 7,070 tris/20 clips, lighter; แจ็กเก็ตสีส้ม (ตรวจใน Godot Phase 2 แล้ว) | Sam 9,636 หรือ Shaun 10,758 tris/20 clips; รายละเอียดเครื่องแต่งกายมากกว่า | Matt ชั่วคราวเพื่อลดต้นทุน; playtest visual แล้วเลือก/ปรับ hero อีกครั้ง |
| Zombie ปกติ | `Zombie.glb`: 6,174 tris/16 clips, สีหม่น | `Zombie-VlXjG0N8Eg.glb`: 7,822 tris/32 entries, สีเขียว/ส้มชัด | ตัวแรกเป็น Normal; ตัวหลังเก็บเป็น Runner หลัง Day 1 |
| ปืนพก | Post Pistol: texture atlas, รูปทรงเข้ากับ pack ตัวละคร, bbox ~0.14×0.34×0.98 | Ultimate Guns Pistol: สี material ล้วน, 1,040 tris (ตัวพื้นฐาน), bbox ~1.82×1.16×0.32 | Post Pistol สำหรับ core style; สเกล/แกนต้องทดลองก่อน |
| Storage | Post Chest: กล่องไม้ post-apocalypse | RPG Chest: fantasy chest เปิดฝา | Post Chest สำหรับ Day 1; RPG chest ใช้เมื่อมี fantasy art direction ชัด |
| Shelter | Survival Tent: ใช้ได้ทันทีหลัง normalize scale | ไม่มี house model | Tent ชั่วคราว; ต่อไปต้องทำ/หา house หาก narrative ต้องการ |
| Rescue | Helicopter: สื่อการมาถึงจากพื้นที่ห่างไกล | Ambulance: เข้ากับถนนแต่ต้องมีทางรถ | Helicopter; ใช้ Ambulance ถ้าไม่ทำฉากบิน/landing |
| ธรรมชาติ | `Pine/Tree/Rock Medium`: รูปทรง low-poly และสีคุมง่าย | `Twisted Tree`: สีแดงสดและ 9–10k tris ต่อต้น | แบบแรกสำหรับ Day 1; แบบหลังใช้เฉพาะช่วง fantasy/ขอบพิเศษ |

## ใช้ตอนใด

**Day 1 candidate set:** Matt, Zombie, Post Pistol, Chest/Pallet/Barrel/Traffic Barrier, Nature Pine/Tree/Rock/Bush/Plant/Plant Big, Survival Tent/Shovel/First Aid Kit/Radio. ยังไม่มีแปลงดินและ crop ประเภทต่าง ๆ; ต้องสร้างภาพชั่วคราวที่อ่านออกเมื่อเริ่ม gameplay.

**หลัง Day 1:** Zombie variant, Big arm, Post Rifle/Shotgun, fantasy item/plant accents, รถ/Helicopter, ต้นไม้ variant จำนวนมาก. Ultimate Guns และ RPG bundle เป็นคลังทางเลือก ไม่จำเป็นต่อ vertical slice.

**ไม่ใช้ใน Demo แรก:** พาหนะ/อุปกรณ์หลายชนิดที่ไม่รองรับ loop, animal companion, raft/boat, อาวุธ RPG, street prop ทั้ง pack, ซอมบี้คลาน. เก็บไฟล์ไว้ ไม่ลบ.

## แผนที่จาก asset จริง

แผนที่เดียว: shelter (Tent) ข้าง Farm → Pallet/Chest/Radio เป็นจุด craft/storage/story → combat clearing รอบนอก → Pine/Tree/Rock/Bush เป็นขอบ → Post barrier/container เป็น cover บางจุด → spawn N/E/S/W หลังแนวขอบ → clearing หนึ่งจุดสำหรับ Helicopter Day 10. ไม่มีการสร้าง map ในรอบนี้. การจัดวางและระยะจริงต้องผ่าน navigation/line-of-sight playtest ภายหลัง.
