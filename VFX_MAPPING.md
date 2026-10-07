# Elemental VFX reference

Paths below are under `scenes/effects/elemental/`.

| Element | Plant VFX | Impact VFX | Status VFX | Gameplay Status | Notes |
|---|---|---|---|---|---|
| Basic | None | basic_impact.tscn | None | None | Actual Basic Rifle ray hits, 20 damage |
| Fire | fire_plant.tscn | fire_impact.tscn | Not integrated | None implemented | Ammo remains craft-only; visual scene only |
| Ice | ice_plant.tscn | ice_impact.tscn | Not integrated | None implemented | Ammo remains craft-only; visual scene only |
| Poison | poison_plant.tscn | poison_impact.tscn | Not integrated | None implemented | Ammo remains craft-only; visual scene only |
| Electric | Absent | Absent | Absent | Absent | No plant/ammo in current catalog |
| Water | Absent | Absent | Absent | Absent | No plant/ammo in current catalog |

`PlantData.ambient_vfx` chooses the emitter; `ambient_vfx_offset` is authored against mature model height and multiplied by growth scale. ItemData's optional `impact_vfx` chooses the ray-hit burst. Zombie AI contains no element branches. Special ItemData mappings are preparation only; the Basic Rifle still consumes only Basic Ammo.
