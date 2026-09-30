# Final balance - v0.1.0-demo

Final pass changes only daily basic seed supplies, based on the measured surplus. All growth, yield, recipes, weapon and enemy values are retained from Phase8/9. Production half-day is600 seconds: ten real minutes, with crop growth tied to the same clock. Fixed-FPS headless QA runs simulation faster than wall time without changing these values.

## Player

HP100, stamina100; walk4m/s, sprint7m/s, aim walk2.8m/s. Stamina drains22/s, recovers18/s after1.2s delay; exhausted sprint requires25% stamina to restart. Bed after a cleared night restores HP/stamina; natural dawn does not heal.

## Plants

| Plant | Growth (game min / real sec) | Yield |
|---|---|---|
| Copper Plant | 42 / 35 | 2 |
| Fire Pepper | 54 / 45 | 2 |
| Ice Plant | 54 / 45 | 2 |
| Iron Plant | 48 / 40 | 2 |
| Lead Plant | 36 / 30 | 2 |
| Paper Plant | 30 / 25 | 3 |
| Poison Plant | 54 / 45 | 2 |
| Small Herb | 24 / 20 | 1 |

## Recipes

| Recipe | Ingredients per batch | Output | Unlock day |
|---|---|---|---|
| Basic Ammo | Lead1 + Paper1 + Copper1 | Basic Ammo10 | 1 |
| Basic Medicine | Small Herb2 | Basic Medicine1 | 1 |
| Metal Component | Iron2 + Copper1 | Metal Component1 | 1 |
| Fire Ammo | Fire Essence1 + Paper1 + Copper1 | Fire Ammo10 | 3 |
| Ice Ammo | Ice Crystal1 + Paper1 + Copper1 | Ice Ammo10 | 5 |
| Poison Ammo | Poison Extract1 + Paper1 + Copper1 | Poison Ammo10 | 7 |

Medicine has no heal amount because use is not implemented. Elemental ammunition is also craft-only. These are optional content demonstrations, not increased combat power; the entire campaign must be survivable with the Basic Rifle. No fictitious multi-weapon balance is claimed.

## Weapon

Basic Rifle:20damage,5shots/s,10round magazine,1.5s reload,60m range,1Basic Ammo/shot, zero configured spread/recoil. Only one usable weapon; three equipment slots do not currently create a multi-weapon choice.

## Enemies

| Enemy | HP | Speed m/s | Damage | Attack interval s | Rifle hits |
|---|---:|---:|---:|---:|
| Normal | 100 | 2.0 | 10 | 1.2 | 5 |
| Runner | 60 | 4.5 | 8 | 0.95 | 3 |
| Tank | 300 | 1.5 | 25 | 1.8 | 15 |

## Ten-day curve

| Day | Normal / Runner / Tank | Perfect-hit ammo |
|---|---|---:|
| 1 | 6 / 0 / 0 | 30 |
| 2 | 7 / 0 / 0 | 35 |
| 3 | 7 / 2 / 0 | 41 |
| 4 | 8 / 3 / 0 | 49 |
| 5 | 9 / 4 / 0 | 57 |
| 6 | 10 / 5 / 0 | 65 |
| 7 | 10 / 4 / 1 | 77 |
| 8 | 11 / 5 / 2 | 100 |
| 9 | 12 / 6 / 2 | 108 |
| 10 | 14 / 7 / 3 | 136 |

Spawn interval2.0s on Day1, decreasing0.1/day to1.1s on Day10. Living cap12; spawn at least12m from player. Runner introduced Day3, Tank Day7. No HP inflation.

## Supply and recovery

Day1: three each of five basic seeds and empty rifle. Days2-10: respectively3/4/4/5/5/6/7/8/8 of each of the five basic seeds per reached day; rewards wait if inventory full. Fire/Ice/Poison seeds unlock with three seeds on Days3/5/7, with matching recipes. Twelve farm plots support two batches of24ammo crops.

Three Lead/Paper/Copper crops each yield up to60ammo on Day1, compared with30perfect hits. Eight each yield160ammo/day, compared with136perfect hits on Night10. Full campaign farming now produces1060rounds, reduced from1500; perfect-hit requirement totals698. Carryover rewards preparation; the stationary test died on Night8 despite hundreds of rounds. Resource abundance alone does not guarantee survival.

An empty magazine/reserve does not block movement: survive by running to natural dawn, receive daily seed supplies, plant and craft again. This path does not heal, so poor preparation has a health cost. Full bag rewards remain pending until capacity frees. No infinite-ammo or emergency grant was added.

See FINAL_QA_REPORT.md and docs/phase10 for observed ammo consumption, health, remaining resources and the limitations of automated aiming.
