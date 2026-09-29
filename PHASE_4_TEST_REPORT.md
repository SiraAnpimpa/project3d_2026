# Phase 4 test report — Crafting and workbench

Date: 2026-09-29. Engine: Godot 4.7.2, Compatibility renderer. Scope: Phase 4 only.

## 1. Crafting architecture

`CraftingSystem` validates a selected `CraftRecipe`, checks current inventory and day, then requests one atomic exchange from `Inventory`. `Inventory.can_exchange_items` and `exchange_items` simulate all removals and additions on copied stacks before committing. A failed exchange leaves quantities unchanged; a successful exchange emits one `inventory_changed`. A synchronous callback cannot reenter `CraftingSystem.craft` while its busy guard is set. The system has no player, camera, farming, or weapon dependency.

## 2. Recipe architecture

`RecipeEntry` holds an `ItemData` reference and positive quantity. `CraftRecipe` holds ID, name, description, optional icon, category, ingredient and output arrays, batch multiplier (`craft_amount`), and `unlock_day`. `RecipeBook` validates IDs, entries, duplicate IDs, and canonical item references against `ItemCatalog`. Recipes can have multiple outputs. All three starter recipes unlock on Day 1. A test-only Day 2 recipe verifies the unlock path.

## 3. Workbench implementation

`scenes/interactables/Workbench.tscn` extends the existing `Interactable` and is placed near the farm at (-2, 0, -1). `PlayerInteractor` finds it using the existing range, collision layer and line-of-sight rules. E emits `workbench_requested`; `GameRoot` opens the crafting UI for the player. The old decorative workbench placeholder was replaced.

## 4. Crafting UI

`CraftingUI.tscn` lists recipes from `RecipeBook` by category, shows owned/required ingredient counts, outputs, lock state, failure reason and craft result. The button enables only when `CraftingSystem.failure_reason` is empty. Opening pauses the tree, releases the cursor, cancels aim and leaves Farming/Combat mode unchanged. Esc closes crafting before Pause can open. Tab cannot open the bag over crafting. Closing restores camera control. Rendered examples: [workbench](docs/phase4/phase4_workbench.png), [crafted output](docs/phase4/phase4_crafted.png).

## 5. Recipes implemented

| Recipe | Ingredients | Output | Category |
|---|---|---|---|
| Basic Ammo | Lead ×1, Paper ×1, Copper ×1 | Basic Ammo ×10 | Ammo |
| Basic Medicine | Small Herb ×2 | Basic Medicine ×1 | Medicine |
| Metal Component | Iron ×2, Copper ×1 | Metal Component ×1 | Material |

**TEMPORARY BALANCE:** all quantities and Day 1 availability are prototype values.

## 6. Input and UI behavior

E uses the existing interaction route. Tab remains inventory, Q remains mode switch, Esc closes crafting, RMB aim is canceled when crafting opens, and the gameplay wheel is blocked while paused. Crafting and bag or Pause never overlap in the tested flow.

## 7. Tests performed

- Initial existing headless suite: 22 runs, failures=0.
- Final `tests/run_tests.ps1 -WithRendering`: 29 runs, failures=0. Includes import, 21 headless scripts, main boot, and 6 rendered scripts. Logs: `.godot/test-logs/phase4_final/`.
- Phase 4 headless and rendered game runs: physical E planting of six crops, clock growth, physical E harvest, workbench prompt/E, all three crafts and bag output; rendered UI inspection.
- Transaction checks: full bag rollback, output replacing a fully consumed stack, one committed signal, reentrant callback, repeated presses, existing stack merge, and insufficient material rejection.
- Data checks: resource-only recipe added to the book and shown in UI, two outputs crafted, Day 2 lock, duplicate ID and invalid entry errors.
- Existing Phase 2, Phase 3, camera and input tests passed. Phase 3 rendered test measured Lead growth at 30.382 real seconds at x1.

## 8. Results

The tested Farm → Harvest → Inventory → Workbench → Craft → Inventory loop passes. Basic Ammo, Basic Medicine and Metal Component quantities match their recipes. The UI and existing bag receive the committed inventory signal. No script or runtime errors appeared in final logs.

## 9. Known bugs

None reproduced in the automated runs. A human playthrough and export build were not tested.

## 10. Technical debt

The workbench and output icons are prototype visuals. The crafting UI displays one batch at a time and has no queue or quantity selector. Static Resource definitions should be treated as immutable during gameplay. There is no save/load system.

## 11. Placeholder values

Recipe quantities, stack limits, Day 1 unlocks, workbench position and artwork are temporary balance/presentation choices.

## 12. Future recipe integration

Create or reuse `ItemData`, register it in `resources/catalog.tres`, create `RecipeEntry` data and a `CraftRecipe` resource, then add it to `resources/recipes/book.tres`. No crafting or UI code change is needed. `unlock_day` gates later recipes; progression rules beyond the day gate remain future work.

## 13. Weapon and ammo integration notes

Basic Ammo has `ItemType.AMMO`, stacks in inventory and can be counted by ID. Shooting, reload, ammunition effects and weapon recipes are outside Phase 4. Basic Medicine is `CONSUMABLE`, but using it to heal is deferred.

## 14. Ready for Phase 5

The inventory can hold crafted ammo and future weapon items; crafting accepts any catalog ItemData output type. The next planned milestone is **Weapon & Shooting Foundation**, subject to a separate request. Current tests do not claim a playable combat loop.
