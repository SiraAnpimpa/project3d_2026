# PHASE_3_TEST_REPORT — Somchai's Last Harvest

วันที่: 2026-09-29 — **Phase 3 implemented and runtime verified**.

## 1. Features implemented

ItemData, stack inventory, prototype inventory UI, seed selection, PlantData, 12 reusable farm plots, planting, game-time growth, four visual stages, harvesting, starter supplies, resource validation และ centralized farming debug tools. Gameplay loop `Seed → Inventory → Select → Plant → Grow → Ready → Harvest → Inventory → Replant` ผ่านทั้ง headless และ renderer จริง.

## 2. Item architecture

- `ItemData` เป็น Resource: `id`, `display_name`, `description`, `icon`, `max_stack`, `item_type`, `plant_id`.
- ใช้ ID เป็น key; display name เปลี่ยนได้. Enum มี SEED/MATERIAL/CONSUMABLE/TOOL/WEAPON แต่สร้างเฉพาะ SEED/MATERIAL behavior.
- `ItemCatalog` ถือ items/plants และตรวจ ID ซ้ำ, seed links, harvest references, stack limits, stage order, duration และ visual root.
- Seed อ้าง `plant_id`; PlantData อ้าง seed/harvest ItemData โดยตรง. วิธีนี้หลีกเลี่ยงวงจรอ้างอิง `.tres` โดยไม่ต้องสร้าง SeedData subclass เพิ่ม. การตัดสินใจนี้อยู่ใน architecture ฉบับอัปเดต.
- 10 ItemData production resources: `seed_lead`, `seed_paper`, `seed_iron`, `seed_copper`, `seed_small_herb`, `lead`, `paper`, `iron`, `copper`, `small_herb`.

## 3. Inventory architecture

- `Inventory` เป็น child ของ Player; `InventorySlot` เป็น runtime RefCounted ที่มี `item` + `quantity`. ไม่เขียนจำนวนกลับเข้า `.tres`.
- API: `add_item(item, amount)`, `remove_item(id, amount)`, `has_item(id, amount)`, `get_item_amount(id)`, `can_add_item`, `get_slots`, `select_seed`, `clear`.
- Add/remove สำเร็จครบจำนวนหรือไม่เปลี่ยน inventory; กระเป๋าเต็มยังรับได้ถ้ามีพื้นที่ใน stack ของชนิดเดียวกัน. จำนวนติดลบ/ศูนย์/definition ผิดถูกปฏิเสธ.
- `get_slots()` คืน snapshot เพื่อป้องกัน caller แก้ quantity โดยข้าม validation. ID เดียวใช้ definition เดียวใน runtime.
- ค่าเริ่มต้น 24 slots ปรับที่ Player/Inventory; max_stack 99 ใน ItemData. `InventoryLoadout` แยก starter items/quantities และ preflight ทั้งชุดก่อนให้ของ.
- UI: I เปิด/ปิด, Esc หรือ Close ปิด, click หรือ arrow keys + Enter เลือกเมล็ด. มี icon/name/quantity/tooltip/selected feedback. ไม่มี drag/drop/sorting/equipment.
- เปิดกระเป๋า pause SceneTree; player, camera, stamina, clock, crop หยุดพร้อมกัน. UI ใช้ Always process. ปิดแล้วคืน pause เดิมและไม่เปลี่ยน `clock.paused` ที่ debug ตั้งไว้.

## 4. Farming architecture

- `FarmPlot.tscn` extends Interactable เดิม. สถานะ EMPTY / PLANTED / READY; เก็บ PlantData, planted_time, progress, stage และ PlantVisual.
- MainWorld ใช้ FarmPlot instance 12 จุดเป็น 3×4; collision layer 3 สำหรับการหาเป้าหมาย ไม่กีดขวางการเดิน.
- ใช้ PlayerInteractor เดิมทั้งระยะ/line of sight/E. เพิ่มเพียง `prompt_changed` และ `get_interaction_text()` ที่ Interactable เพื่อให้ HUD เปลี่ยนข้อความขณะยืนที่แปลงเดิม.
- ตรวจเมล็ด/ข้อมูล/แปลงก่อน consume; transaction guard ป้องกัน interaction ซ้ำจาก synchronous signals. Harvest เพิ่มผลผลิตครบก่อนล้างแปลง. ถ้าเต็ม แปลงคง READY พร้อมผลผลิตทั้งหมด.
- `Plant.tscn` + `PlantVisual` ใช้ร่วมทุกชนิด. NaturePlantVisual wraps `Plant.glb`; ระยะเติบโตแสดงด้วย seed marker, scale และ produce marker. PlantData รองรับ scene แยกแต่ละ stage ในอนาคต.
- ฟัง GameClock.time_changed; คำนวณ `(elapsed_minutes - planted_time) / growth_minutes`. ไม่มี `_process()` ต่อ plot/plant. โตกลางวันและกลางคืน; การเดินออกจากบริเวณไม่ลบ state.
- Clock ส่งหนึ่งครั้งต่อ game minute จึงอาจมีความหน่วงก่อนอัปเดตไม่ถึงหนึ่ง game minute (~0.833sจริงที่ x1). Progress ไม่ลดเมื่อ debug ย้อนเวลา; รอ clock ตามทันก่อนโตต่อ.
- Debug farming 6 actions อยู่ใน DebugControls เดิม: Give seeds, Clear farm, Grow all (+time), +1 game hour, Fill bag, Clear bag. ปิดด้วย F1/ปุ่ม Disable tools/Inspector และมี `OS.is_debug_build()` gate. ปุ่ม advance/grow เป็นคำสั่งข้ามเวลาโดยตั้งใจ แม้กระเป๋า pause อยู่; label ระบุไว้ชัด.

## 5. Plant types implemented

| Plant | Seed ID | Harvest ID | Yield | Game minutes | Real seconds at x1 |
|---|---|---|---:|---:|---:|
| Lead Plant | seed_lead | lead | 2 | 36 | 30 |
| Paper Plant | seed_paper | paper | 3 | 30 | 25 |
| Iron Plant | seed_iron | iron | 2 | 48 | 40 |
| Copper Plant | seed_copper | copper | 2 | 42 | 35 |
| Small Herb | seed_small_herb | small_herb | 1 | 24 | 20 |
| Test Plant — test fixture only | seed_test | test_material | 4 | 18 | 15 |

เพิ่ม Test Plant ด้วย Resource 3 ไฟล์และลงทะเบียนใน catalog สำเนาสำหรับ test. SHA256 ของ `farm_plot.gd` และ `plant_visual.gd` ก่อน/หลังเพิ่มตรงกัน; ไม่เพิ่มเงื่อนไขชนิดพืชใน core script. Test Plant ไม่อยู่ใน starter loadout/demo catalog.

## 6. Tests performed

Godot `4.7.stable.official.5b4e0cb0f`, Compatibility / OpenGL 3.3, NVIDIA GeForce RTX 4060 Laptop GPU, viewport1280×720, physics60 Hz. ตรวจ baseline Phase 2 ก่อนแก้ครบ9 runs. ทดสอบทีละระบบระหว่างพัฒนา แล้วรัน suite รวมหลัง implementation สุดท้าย.

ทำซ้ำจาก project root:

```powershell
.\tests\run_tests.ps1 -Godot 'C:\Users\ADMIN\Desktop\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64.exe' -WithRendering
```

Runner ตรวจ exit code, missing result, parser/runtime errors และ assertion failures; จำกัดเวลารอบละ60s. Rendered Phase 3 ใช้เวลาจริง ไม่มี `--fixed-fps`; ส่วน headless ใช้ fixed delta เพื่อทดสอบ deterministic. Movement ใน full-loop test ใช้ Input actions, ปุ่ม E/I/R/debug และ mouse click ส่งผ่าน viewport. เป็น automated runtime test และตรวจภาพจริง ไม่ใช่ human playtest.

## 7. Test results

| Run | Coverage | Result |
|---|---|---|
| Editor import | scripts/classes/resources/icons | exit0 |
| Phase 2 stage1 | movement, sprint, floor/boundary, camera/model | 8 checks pass |
| Phase 2 interaction | range, E, disabled, obstruction, freed target | 7 pass |
| Phase 2 stats | HP/death/stamina/delay/exhaustion | 11 pass |
| Phase 2 clock | day/night, day counter, signals, fractional steps, lighting | 13 pass |
| Phase 2 movement rate | 30/120 Hz | 3.7333 / 3.6834m; pass |
| Phase 2 integration headless | original systems together | 24 pass; captured mouse verified in renderer |
| Phase 3 inventory | load/add/remove/stack/negative/full/atomic bundle/selection | 20 pass |
| Phase 3 UI | I/Esc/close/selection/icon/count/menu pause/state restore | 11 pass |
| Phase 3 data | 5 types, unique IDs, invalid references/stages/duration | 13 pass |
| Phase 3 farming | planting/spam/reentrancy/growth/full harvest/replant/night/persistence/death | 25 pass |
| Phase 3 debug | all6 actions, pause, disabled/Inspector gate | 12 pass |
| Phase 3 new plant | Resource-only sixth plant, growth/yield/reuse | 7 pass |
| Phase 3 growth rate | 30/120 Hz after20s and ready at30s | both0.6666666667; pass |
| Phase 3 integration headless | complete player farming loop | 18 pass |
| Main scene boot | normal project run,120frames | exit0 |
| Phase 2 rendered integration | actual mouse capture/camera, HUD, restart | 27 pass |
| Phase 3 rendered realtime | full loop, UI click, allstages, screenshots, restart | 24 pass |

**Final suite: all18 runs exit0, failures=0.** No new Script Error/parser/missing resource/node/signal error in final logs. Final real-time Lead growth measured **30.284 seconds**, 1817 physics ticks, including clock publication granularity. Earlier rendered run measured31.016s; both passed the28–36s runtime allowance.

Final logs: `.godot/test-logs/phase3/` in project; original run logs also in Codex workspace `work/phase3_final_logs/`.

Visual review: [farm](docs/phase3/farm.png), [inventory after harvest](docs/phase3/inventory.png), [ready prompt](docs/phase3/ready.png), [night](docs/phase3/night.png), [debug inventory](docs/phase3/debug_inventory.png). Corrected cramped Small Herb icon and dim material text, then verified updated screenshots.

## 8. Known bugs / limitations

- Existing environment message: `ERROR: Failed to read the root certificate store.` Godot prints this on this machine's restricted execution environment, including the Phase 2 baseline. Runner reports and retains it but excludes this exact message from failure count. No gameplay networking or certificate configuration changes.
- No gameplay blocker found in final tests. Coverage does not include a long manual play session, release export, mobile or large-world performance.
- Growth updates at clock-minute precision. Debug rewind does not reverse plant progress. No state survives restart; this is intentional runtime-only persistence.
- Prototype allows walking over soil/crops. The nearest reachable plot is the interaction target; check the prompt before pressing E.

## 9. Technical debt

- UI is English prototype, fixed6-column grid at1280×720 with scrolling for more slots; no localization/rebinding/responsive redesign.
- Final balancing, per-crop artwork, audio/VFX and large plant-count profiling remain future work.
- Resource arrays are shared by shallow duplication; callers extending a catalog at runtime must duplicate its arrays before editing. The extension test demonstrates this.
- Inventory APIs are atomic for one item request; future multi-ingredient crafting will need its own validated transaction. No crafting recipe system was added here.
- No release binary was exported; release gating is present in code, but only debug-build/Inspector behavior was runtime tested.

## 10. Placeholder assets

Reused unmodified `Asset/Stylized Nature MegaKit.undefined-glb/Plant.glb` through a0.65scale wrapper. Same leafy model for all5 crops, four stages via scale/markers, type-specific produce colors and labels. Soil beds/ridges and produce prisms are primitives. Ten small SVG icons are prototype seed/material symbols. Matt and existing greybox remain placeholders. All243 original GLBs have unchanged SHA256 hashes. License evidence is still absent from the supplied asset collection, as recorded in Phase 1.

## 11. Balance values currently used

All values are provisional: 24 inventory slots, stacks99, starter3seeds per type, no auto-selection. Growth/yield table above; thresholds0/25/65/100%, visual scales0.15/0.35/0.7/1. Clock remains600real seconds per half-day (1.2game minutes/second), debug speed20. Interaction radius remains2.8m. Plot spacing2.6m, bed1.65m. Tune Resources/Inspector; no scattered crop-specific code.

## 12. Systems ready for next phase

Stable item IDs/definitions, inventory quantity/capacity APIs and UI signals, seed selection, reusable plots/visuals, material production, clock-driven growth, centralized debug actions and repeatable regression tests. Phase 4 can build on these when the user supplies its scope.

## 13. Systems intentionally not implemented

Crafting/recipes, guns/shooting/ammo consumption, zombie AI/waves/combat, loot/pickups/shop/seed rotation, sleep, unlock progression, fantasy elemental crops, final night/rescue ending, save/load. Enum values are data categories only, not implementations.

## Git and handoff

No commit/push/deploy. Preserved pre-existing uncommitted Phase 1/2 files and unrelated assets. Suggested commits:

1. `feat: add item and inventory foundation`
2. `feat: add data-driven farming and seed selection`
3. `feat: connect plant growth and harvesting to game time`
4. `test: verify farming loop and phase two regressions`
5. `docs: record phase three architecture and runtime results`

**Phase 3 complete. Stop here and wait for the Phase 4 prompt.**
