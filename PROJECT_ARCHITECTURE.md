# Project architecture

## Entry points and state

`scenes/main/MainMenu.tscn` is the project entry point. `scenes/main/GameRoot.tscn` and `scripts/main/game_root.gd` assemble the world, player, inventory, equipment, crafting, progression, clock and survival services. Services belong to the game scene; starting a new game creates a new campaign.

## Runtime systems

| Area | Responsibility | Source |
|---|---|---|
| Player | Movement, camera, mode and character presentation | `scripts/player/` |
| Items and equipment | Inventory slots, owned weapons and equipped loadout | `scripts/inventory/`, `resources/items/` |
| Farming | Plot interactions, time-based growth and harvest | `scripts/farming/`, `resources/plants/` |
| Crafting | Ingredient validation and recipe outputs | `scripts/crafting/`, `resources/recipes/` |
| Combat | Rifle hitscan, ammo/reload and bat contact timing | `scripts/weapons/`, `resources/weapons/` |
| Enemies | Shared zombie controller with per-variant data | `scripts/enemies/`, `resources/enemies/` |
| Survival | Night waves, cleared-night rest and terminal campaign state | `scripts/survival/`, `resources/waves/` |
| Progression | Day configuration, seed grants and unlocks | `scripts/progression/`, `resources/progression/` |
| Clock | Game time and day/night events | `scripts/time/game_clock.gd` |
| World | Terrain, scenery placement, grounding and day/night lighting | `scripts/world/`, `scenes/world/` |
| UI | Theme, icons, menus, HUD, inventory and crafting screens | `scripts/ui/`, `scenes/ui/` |
| Presentation | Rest/death/rescue sequence and audio | `scripts/presentation/`, `scripts/audio/` |

## Data and presentation boundaries

Resource classes in `scripts/data/` define items, plants, recipes, weapons, enemies and day/wave data. Runtime quantities, health and timers belong to live instances. `resources/catalog.tres` is the item/plant catalog.

Gameplay services own resource transfers, damage and wave completion. UI observes their state and requests actions. Visual poses, recoil and hit feedback follow gameplay state. `PlayerVisual` handles animation composition; weapon presentation uses the character’s skeleton and weapon grip markers.

`RuralTerrain` supplies terrain geometry and height sampling. `RuralEnvironment` assembles structures and vegetation; `SceneryGrounding` handles source geometry contact with terrain. Static world changes require navigation rebaking with `tools/bake_prototype_navigation.gd`; the navigation resource lives under `resources/navigation/`.

## Supporting folders

- `Asset/`: supplied model library.
- `assets/`: project UI, audio and shaders.
- `tests/`: [runtime checks and capture fixtures](tests/README.md).
- `tools/`: asset authoring, export and world utilities.
- `docs/`: [Web build and hosting instructions](docs/WEB_README.md), engine notices and supporting captures/data.

See the [main README](README.md) for gameplay, crop rewards, crafting, controls and current game limitations.
