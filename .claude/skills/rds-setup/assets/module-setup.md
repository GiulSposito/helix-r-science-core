# Module Setup

<!-- This file satisfies the BMad module validator requirement for assets/module-setup.md.
     The authoritative setup instructions live in the parent SKILL.md, which the LLM
     loads when the user invokes /rds-setup. This file mirrors the key steps for
     standalone-module validation contexts. -->

See `../SKILL.md` for the full setup procedure. Summary of steps:

1. Read `./module.yaml` for module metadata and variable definitions
2. Check existing config in `{project-root}/_bmad/config.yaml`
3. Check for legacy per-module config and prepare migration if needed
4. Collect configuration (user_name, communication_language, rds_workflows_path, rds_sidecar_memory)
5. Write config via `scripts/merge-config.py` and help entries via `scripts/merge-help-csv.py`
6. Create output directories
7. Run `scripts/cleanup-legacy.py` to remove installer package directories
8. Copy `assets/rds/workflows/` and `assets/rds/agents/` to project
9. Confirm and display module greeting
