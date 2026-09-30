# Phase 10 issue register

Baseline: d727ef3. Rendered Phase9 presentation flow passed before edits. No reproduced gameplay blocker/high defect at baseline. Release gates below are not claims of gameplay defects.

| ID | Severity | Description / reproduction | Expected | Actual | Status / files |
|---|---|---|---|---|---|
| R01 | HIGH release gate | Inspect export templates | Matching Windows template | Only Web templates installed | RESOLVED: installed/exported; export_presets.cfg |
| R02 | HIGH QA gate | Full Day1-10 using farmed ammo, ordinary damage | Successful recorded campaign | Prior legitimate test stops Day2 | RESOLVED: balanced release campaign passed; campaign test |
| R03 | MEDIUM | Visit (3,0,-8) in normal game | No developer target | TargetDummy present | RESOLVED: removed in normal/release; game_root.gd |
| R04 | MEDIUM limitation | Craft medicine/elemental ammo then try using it | Disclosed limited scope | Craft-only, no heal/effects | ACCEPTED existing scope; guide/documents |
| R05 | MEDIUM release gate | Inspect GLB pack licenses | Verified distribution rights | License information not found in project files | AUDIT COMPLETE; rights unverified, see ASSET_CREDITS.md |
| R06 | MEDIUM QA gate | Profile final-night crowd and repeated days | Measured performance/state stability | Prior evidence covers state only | RESOLVED: release profiling/state results recorded; performance test |
| R07 | LOW | Watch rescue/reload | Authored rotor/reload animations | Static rotor/generic handling | ACCEPTED asset limitation |

Fix reproduced blockers/high defects first. Complete campaign/economy and release gates before claiming readiness. DebugControls already gates F1/actions with OS.is_debug_build; actual release verification pending. No balance changes before measured need.

## R08 - Medium balance issue: excess early supply (resolved, verified)

Reproduce: farm all daily Lead/Paper/Copper allotments and craft throughout10days. Baseline legitimate release-template run used780rounds and retained720, over five perfect-hit final waves. Expected: room for missed shots and carryover without giving final-day supplies on Day2. Changed **only daily basic seed supply** to3/4/4/5/5/6/7/8/8 on Days2-10. Growth, yields, recipes, damage, enemy HP/counts unchanged. Theoretical full-farming supply1060rounds vs698perfect hits. Final balanced release-template rerun passed:739shots,321remaining, all10waves cleared and ending reached. Files: resources/progression/day_2..8.tres; campaign fixture reads the production config.

QA harness corrections: stationary strategy failed Night8; overly cautious retreat survived without clearing; straight-line return hit shelter wall. The agent now uses walkable routes, closer retreat threshold and accepts natural dawn survival. These are test behavior changes, not gameplay cheats or production movement changes.

No open reproduced blocker/high gameplay defect. License rights remain an external distribution gate. Full history and scope limitations are in FINAL_QA_REPORT.md.
