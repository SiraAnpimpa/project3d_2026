# Gameplay tuning

Half a game day takes 600 real seconds; crop growth uses the same clock.

## Player

HP100, stamina100; walk4m/s, sprint7m/s, aim walk2.8m/s. Stamina drains14/s, recovers28/s after0.65s delay; exhausted sprint requires25% stamina to restart. Bed after a cleared night restores HP/stamina; natural dawn does not heal.

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

Medicine and elemental ammunition are craft-only; consumable healing and elemental firing are not implemented.

## Weapon

Basic Rifle:20damage,5shots/s,10round magazine,1.5s reload,60m range,1Basic Ammo/shot, zero configured gameplay spread/recoil; visual recoil is presentation only.

Wooden Bat:10damage,1.6m root-to-target range,0.85s attack interval,0.18s contact delay,0.48s swing. One nearest unblocked target in the forward arc per press; no ammo, reload or stamina cost. Owned/equipped in slot2 from Day1; rifle remains default slot1. Ideal sustained damage before interruptions:11.76/s versus rifle100/s before reloads. Close-range combat still exposes the player to damage.

## Enemies

| Enemy | HP | Speed m/s | Damage | Attack interval s | Rifle hits | Bat hits |
|---|---:|---:|---:|---:|---:|---:|
| Normal | 100 | 2.0 | 10 | 1.2 | 5 | 10 |
| Runner | 60 | 4.5 | 8 | 0.95 | 3 | 6 |
| Tank | 300 | 1.5 | 25 | 1.8 | 15 | 30 |

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

Day1: three each of five basic seeds, empty rifle and owned Wooden Bat. Days2-10: respectively3/4/4/5/5/6/7/8/8 of each of the five basic seeds per reached day; rewards wait if inventory full. Fire/Ice/Poison seeds unlock with three seeds on Days3/5/7, with matching recipes. Twelve farm plots support two batches of24ammo crops.

With an empty magazine/reserve, wheel to the bat in Combat and press LMB to fight at close range, or survive by running to natural dawn, receive daily seed supplies, plant and craft again. This path does not heal, so poor preparation has a health cost. Full bag rewards remain pending until capacity frees. No infinite-ammo or emergency ammo grant was added.
