# UI/UX polish report — Somchai’s Last Harvest

Completed 2026-10-02. Status: **COMPLETE — STOP**. Root agent only. Scope: HUD, UI, icons, prompts, menus and presentation feedback.

## 1. Current UI problems

The original HUD repeated mode, input instructions and wave forecasts; the day-one unlock message covered the player. Every plot carried floating EMPTY/stage labels. Inventory repeated item names inside tiny cells, mixed owned weapons with seeds and used iron/copper art for the rifle/basic ammunition. Crafting showed materials and outputs as paragraphs. Pause was wider than its content. Settings was **NOT FOUND**.

Read existing progress, architecture and asset analysis. The supplied FREE version was fully inventoried before edits. Ran normal Play and inspected all 27 baseline states. `UI_CURRENT_STRUCTURE.md` preserves the KEEP / REMOVE / REPLACE / REDESIGN decisions.

## 2. Assets used from FREE version

Audited **540 source files**: 534 PNG, 2 AI, 2 PSD, 1 EPS, 1 SVG. All PNGs decoded; six complete contact sheets inspected, PSD composites decoded, vector headers inventoried. About 89 general symbols are repeated in light/dark variants and three sizes. There are no font files, authored panel/frame kit, crop icons, rifle or cartridge icon. Alarm is a vibrating phone; Apple is a company logo.

Used 14 existing white symbols: Plus (HP/medicine), full Battery (stamina), bone head (night count), Wrench2 (workbench/component), House (rest/menu), Menu (bag), Lock, Cross, Play, Next-Speed Up (wait), Question, Exclamation, Gift, Power. The supplied white `Dark Icons/0.5x/Button  x256.png` is the shared panel/button texture. Its original PNG is unchanged; the importer limits it to32px for a correct eight-pixel nine-slice and predictable memory.

Existing item SVGs remain in use. Added only three missing UI vectors: **clock, rifle, basic cartridges**. Rifle/ammo display overrides live in `UiIcons`; ItemData resources are unchanged. Medicine/component reuse FREE symbols. Menu scenery is an unchanged copy of the existing farmstead capture. Godot’s bundled font is retained.

Full paths/purposes: `UI_ICON_MAPPING.md`. Complete inventory/hashes: `docs/ui_polish/free_asset_inventory.json`.

## 3. HUD redesign

- Top-left: day and clock, with a small N/wait button during Farming daytime.
- Bottom-left: HP/stamina icons, exact value bars and concise numbers; low HP tint.
- Bottom-right: Farming seed image/count/name **or** Combat weapon image/magazine/reserve/slot. Bat uses its own image and a short Swing/LMB hint without ammunition values.
- Center: quiet dot; aiming lines and short gold hit marker. The marker now draws for non-aiming bat hits too.
- Top-center at night: skull and total remaining enemies, including incoming; final-night accent. Removed the persistent daytime forecast and Alive/Incoming breakdown.
- Modal menus hide gameplay HUD behind the shade. Mode changes clear old notices and briefly brighten the mode panel rather than showing a large popup.

All values still come from existing health, stamina, clock, inventory, equipment, weapon and wave signals. No balance or input-action changes.

## 4. Interaction redesign

Compact key + icon + action: E Plant, E Harvest ×quantity, E Craft, E Rest until morning. Growing plots show produce icon and percentage, with no misleading E key. Empty-seed state points to Tab. Rest when unavailable states Clear the night to rest without advertising a usable action. Combat hides farm/workbench/bed prompt information.

HUD presentation hides floating labels on interactables; plot state, visuals, colliders, targeting and E callbacks remain untouched. Actual E plant, harvest, workbench and cabin-rest paths were tested.

## 5. Inventory changes

Reusable icon cells show image, quantity, seed-output badge and selected border. Hover tooltips name items; gold keyboard focus is distinct from green seed selection. Seeds/supplies occupy the grid; owned weapons occupy a separate row; equipped weapon slots and clear actions are separate below.

Inspection displays the name once. Seeds show growth in **game minutes**, produce/yield, empty-plot/Farming condition and no-tool requirement. Material inspection leaves planting selection unchanged. Weapon selection still invokes original equip/unequip APIs; quantities are not consumed or duplicated. Empty bag has an explicit message and disabled cells. Tab/Esc and modal pause ownership are preserved.

## 6. Crafting UI changes

**Materials left → Recipes middle → Result right.** Material rows show art and owned/required counts, with a red shortage. Recipe buttons show output art or lock; selected border replaces the `>` prefix. Result shows large art, quantity, name and a short functional description.

Original unlock checks, batch quantities, atomic exchange, capacity checks and Craft callbacks are preserved. Ready, success, missing materials, locked day and full bag have clear feedback; disabled Craft cannot consume materials. Special ammo/medicine descriptions accurately retain their existing future-use limitations.

## 7. Icon mapping

`UI_ICON_MAPPING.md` includes all distinct FREE symbols, every24 catalog items, placement and fallback rationale. `UiIcons` is a cached presentation adapter; it corrects only displayed artwork. Existing seed SVGs gain an existing harvest-icon badge, allowing shape recognition beyond bag colour. Raw supplied assets and existing item artwork are hash-preserved.

## 8. Removed text

Removed title stamp, constant control tutorial, gameplay-mode paragraphs, repeated item names in cells, tier/order debug details in ordinary bag use, daytime wave preview, Alive/Incoming breakdown, duplicate workbench-open notice and floating plot/workbench/rest labels. Unlocks compress to one count summary. Full response text remains in UI tooltip data where applicable. Farming notices clear when switching mode.

Debug HUD, aim diagnostics and bag debug actions require active developer controls **and** a debug build. Normal Play tests verify them hidden. A release executable was not exported in this UI-only source pass.

## 9. Added UI animations and style

Modal content fades in0.14s; craft feedback fades in0.14s; mode panel brightness returns in0.22s; notifications hold2.8s then fade0.3s. Hurt tint lasts0.22s; hit marker0.16s. Tweens are interruptible and run correctly while menus own pause. No continuous decorative UI animations or bouncing/scaling clutter.

Shared natural-dark surfaces, parchment text, sage farming/success, brass Combat/focus and terracotta damage/error. Buttons define normal/hover/pressed/disabled/focus states. Default body18px, smaller17px details,24–30px headings,49px menu title in the logical1280×720 canvas. Existing canvas-items stretch and anchors support the tested sizes.

## 10. Testing result

| Check | Result | Assertions |
|---|---|---|
| ui_import_final | PASS | 0 |
| ui_contracts_final | PASS | 66 |
| ui_visual_final | PASS | 177 |
| ui_stamina | PASS | 3 |
| ui_bat | PASS | 83 |
| ui_night | PASS | 28 |
| ui_plants | PASS | 125 |
| ui_wait | PASS | 36 |
| ui_performance_after | PASS | 0 |

**All final checks pass: 518 assertions across the functional/capture/regression checks; zero script/runtime errors after repairs.** The baseline and final logs both contain the same root-certificate-store environment message; it is recorded separately rather than treated as a game error.

Verified HUD HP/stamina/weapon/ammo/day/time; actual E cabin rest/workbench/plant/harvest; bag open/close/selection/equip/unequip; real shooting/reload/bat/zombie damage; all eight crop growth/harvest cases; wait confirmation Cancel-first, final-night and repeated-input gates; death, menu navigation and existing ending.

Rendered51 final views at **1280×720, 960×540, 1920×1080, 1024×768**, including empty/missing/locked/full/low-HP states. Visible panel bounds pass at the captured sizes. Inspected all baseline and final contact sheets plus full-size representative screens. The pass fixed incorrect texture slicing, bottom-right safe inset, prior-mode notices, the stale swing-state display and a guide panel exceeding its assigned height. Capture-directory/node-lookup errors in intermediate test attempts were also repaired; final logs/captures are authoritative.

### Performance

Same scene, GPU/Compatibility renderer,1280×720,120 warm-up frames then600 timed frames per scenario; clock paused, normal Play, no living enemies. Results are a bounded comparison, not a claim about every machine or combat workload.

| Scenario | Mean before → after (ms) | p99 before → after (ms) | Draw calls before → after |
|---|---|---|---|
| hud_720p | 4.97 → 4.50 | 7.88 → 8.87 | 2136 → 2125 |
| inventory_720p | 4.55 → 4.53 | 8.64 → 8.57 | 2213 → 2188 |
| crafting_720p | 4.60 → 4.50 | 7.87 → 8.79 | 2159 → 2151 |

Scene nodes1133 →1315 (+182), mostly reused cells and grouped guides. Static memory increases approximately1.6–1.7MiB (about2%). Mean frame time stays around4.5ms; p99 varies up to8.87ms and max10.12ms. The observed means are flat/lower; tail timings are mixed by about1ms. All samples stay below a16.67ms frame budget. No optional repeated benchmark was used to select a favourable result. Cached themes/textures, reused slots and bounded fades limit UI cost.

### Scope and files

`docs/ui_polish/scope_audit.json` verifies the original gameplay/data/map/character/animation/camera/audio/time/progression files and all540 FREE sources remain byte-identical. GamePresentation is unchanged; death/ending inherit the shared theme. Only the historical bat test’s HUD-text expectation changed; its combat assertions remain intact.

Changed production: `scenes/ui/{HUD,InventoryUI,CraftingUI,PauseMenu}.tscn`; `scripts/ui/{prototype_hud,inventory_ui,crafting_ui,main_menu,pause_menu,presentation_style,skip_night_dialog,aim_crosshair}.gd`.

New production: `scripts/ui/{ui_icons,ui_item_slot}.gd`; `assets/ui/icons/{clock,rifle,ammo}.svg`; `assets/ui/menu_background.png`; one intentional button import-size setting. Godot also generates asset/script import metadata. Tests: `ui_polish_test`, `ui_polish_capture`, `ui_polish_performance` plus the one historical UI assertion. Documentation: this report, mapping, structure, progress, architecture/asset summaries and evidence directory.

### Remaining / next action

No blocking issue remains in this pass. Settings is absent; unsupported special-ammo/medicine use remains accurately labelled. Resolutions below960×540, controller/touch/screen-reader usage and a newly exported release binary were not verified. Those are outside the tested keyboard/mouse desktop scope. Earlier map/animation/balance issues remain recorded in their existing reports.

**Next action: user review in Godot with Play, Tab, E and Q. UI/UX polish pass complete. STOP.**
