# UI audit before the polish pass

Baseline: commit `4fb3297`, Godot 4.7, normal Play, 1280×720. Inspected all 27 captures before any production UI edits. Full source snapshot and hashes retained for the scope comparison.

| UI | Decision | Existing problem / intended treatment |
|---|---|---|
| Main menu | REDESIGN | Replace placeholder illustration with an existing game capture, quieter title and clear primary Play. |
| Main / pause guide | REDESIGN | One dense paragraph; group controls and day/night tasks into two columns. |
| Day/time | KEEP + REDESIGN | Same clock signals, compact top-left clock and day. |
| Health/stamina | KEEP + REDESIGN | Same exact values; icon + bar, concise numeric HP. |
| Seed / weapon HUD | REPLACE | Long descriptions in two corners; one mode-specific bottom-right display. |
| Crosshair / hit / hurt | KEEP + REDESIGN | Thin reticle; make hit confirmation visible for the bat too. |
| Prompt | REPLACE | Long bottom strip with duplicate floating labels; short key + icon + action. |
| Farm labels | REMOVE from normal display | EMPTY / stage labels clutter every plot; show targeted information in HUD only. |
| Wave counter | REDESIGN | Remove daytime forecast; skull + remaining count during night only. |
| Notifications | REPLACE | Multiline unlock announcement covers the player; compact icon toast and fade. |
| Inventory | REDESIGN | Tiny art, names repeated in every slot; larger icon/quantity, selected border, separate inspection and loadout. |
| Workbench | REDESIGN | Mostly text; materials left, recipes middle, result preview right. |
| Pause | REDESIGN | Excessively wide with blank space; compact actions, expandable guide. |
| Wait confirmation | KEEP + REDESIGN | Preserve Cancel-first and all existing validation; short readable explanation. |
| Game over / ending | KEEP | Retain callbacks and cinematic; inherit shared skin, focus and spacing. |
| Rest fade / rescue caption | KEEP | Existing visual feedback and sequence. |
| Debug panel / aim / bag tools | HIDE in normal and release | Preserve developer tools behind explicit debug visibility. |
| Settings | NOT FOUND | No settings UI/backend exists; not added in a UI-only pass. |

## Boundaries

Only presentation scripts/scenes/assets and tests/docs may change. The map, characters, camera, input actions, item/plant/recipe data, farming, crafting, combat, AI, progression, clock and balance remain byte-identical. Public UI bindings and input/pause ownership remain compatible with GameRoot. No new gameplay actions.

## Asset audit

All 540 files in `Asset/FREE version` were inventoried before edits: 534 PNG, 2 AI, 2 PSD, 1 EPS, 1 SVG. All PNGs decoded successfully and all six contact sheets were inspected. About 89 symbols repeated across light/dark variants and three sizes. PSD composites were decoded; vector headers inspected. No font, real panel/frame kit, crop, rifle or ammunition icon was found. Alarm depicts a vibrating phone; Apple is a company logo and is unsuitable for crop UI.


## Structure after the pass

UI scenes retain the CanvasLayer roots and their process/layer ownership. Shared layouts are now constructed from PresentationStyle helpers during ready, using public bindings rather than prototype unique-name text nodes. Inventory/crafting/pause have a runtime Screen/Panel. The supplied button texture and native selection/focus borders are reused.

- HUD preserves `Root/Crosshair`, `Root/AimDebugLabel`, `Root/DeathPanel/Text` and public bar/label fields used by GameRoot/services. ClockPanel, StatsPanel, EquipmentPanel, PromptPanel, NightPanel and ToastPanel have distinct layout roles. `_wave_label` replaces the historical direct `Root/NightLabel` lookup.
- InventoryUI public slot_buttons retain inventory snapshot indexes even when weapon cells are reparented into their separate row. EquipmentHint/EquipmentSlots/DebugActions remain unique named nodes for developer bindings. Details are UI-only inspection state.
- CraftingUI preserves crafting/inventory/player bindings, selected_recipe, _buttons and craft_button; original failure_reason/craft decide state and outcome.
- PauseMenu retains Screen/Panel/Rows/Resume/Restart/MainMenu/Quit paths and its Esc/pause ownership. Guide uses the shared two-column content.
- SkipNightDialog retains all eligibility/confirm/cancel/input behavior; N is still an existing binding. Only the visible daytime shortcut is limited to Farming.
- MainMenu uses an existing landscape capture; GamePresentation inherits the theme without any cinematic/state-code change.
- UiIcons caches source textures and displays three accurate fallback vectors. UiItemSlot reuses cells and changes art/count/border.

Final normal-Play rendered evidence and test results: docs/ui_polish/README.md. Historical text/path tests from older prototype phases describe their own UI version; only the bat HUD assertion needed by this pass was updated. Current UI test coverage is explicit in UI_POLISH_REPORT.md.
