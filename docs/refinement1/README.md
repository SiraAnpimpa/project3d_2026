# Refinement Pass 1 evidence — 2026-10-01

- `test_results.json`: latest 52 per-check results and the initial batch/rerun distinction.
- `logs/initial_suite/`: original combined run; includes the headless mouse-capture assertion failure.
- `logs/focused/`: stage gates, corrected rerun, sustained campaign, rig audit, final boot/captures and performance.
- `campaign.json`: normal-play, finite-resource ten-day campaign; 723 shots, 337 rounds remaining, rescue passed.
- `performance.json`: before/final comparison. Selected final log is `final_performance_isolated.log`; `final_performance.log` is supplementary and excluded from the comparison because capture work briefly overlapped that run.
- `asset_audit.json`: all 243 original GLBs unchanged against pre-pass hashes.
- `source_hashes.json`: SHA-256 of source/scene/data/test files and project/export settings at report completion.
- `before/`, `after/`: map comparison, inspected poses, skip modal, guide, gameplay and ending captures. Map comparisons use direct test entry and retain the target dummy; MainMenu Play removes it.

These are automated runtime/input checks plus visual screenshot inspection, not a manual playtest or rebuilt release validation. The known Windows certificate-store diagnostic is retained. See ../../POST_PRODUCTION_REFINEMENT_1.md for scope, resolved failures and limitations.
