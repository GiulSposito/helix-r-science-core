# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

This is a **BMad agentic ecosystem** for R data science inside Claude Code — not a traditional software project. There is no build step, no test runner, and no deployable application. Instead, this repo provides:

- **Skills** (`.claude/skills/`) — invocable via slash commands (e.g. `/ada`, `/grace`)
- **Agents** (`_bmad/rds/agents/`) — markdown persona files loaded by skills
- **Workflows** (`_bmad/rds/workflows/`) — step-by-step guides orchestrated by agents
- **Sidecar memory** (`_bmad/_memory/`) — persistent markdown logs maintained by agents across sessions

The primary entry point for users is always a slash command like `/rds-setup`, `/ada`, `/grace`, `/alan`, or `/marie`.

## Key Slash Commands

```
/rds-setup     # Install/verify the RDS module and register all 4 agents
/ada           # Ada — Project Architect (Phases 1-3: Setup, Import, Clean)
/grace         # Grace — Data Scientist (Phases 4-5: EDA, Feature Engineering)
/alan          # Alan — ML Engineer (Phases 6-8: Build, Tune, Evaluate)
/marie         # Marie — Communicator (Phases 9-10: Reports, Deployment)
```

Each agent has a `[GS]` (Get Started) menu command that guides the user to the right action.

## Architecture

### BMad Layer

- `_bmad/config.yaml` — global config: output language (English), output folder, RDS module paths
- `_bmad/config.user.yaml` — user overrides: `user_name`, `communication_language` (Portuguese for this user)
- `_bmad/_config/manifest.yaml` — installed BMad modules (core v6.3.0, bmb v1.5.0)
- `_bmad/bmb/` — BMad Module Builder config (used to build new agents/modules via `/bmad-agent-builder`, `/bmad-module-builder`)
- `_bmad-output/` — all generated artifacts land here (reports, agent plans, validation outputs)

### RDS Module (`_bmad/rds/`)

The RDS (R Data Science) module is a 10-phase framework with 4 agents, 13 workflows, and supporting data:

```
_bmad/rds/
├── agents/          # ada.md, grace.md, alan.md, marie.md
├── workflows/       # 13 named workflow directories, each with workflow.md + steps/
├── data/            # checklists/, decision-trees/, references/
├── templates/       # project-structure/, quarto-reports/, r-scripts/
└── docs/
```

### Agent Sidecar Memory (`_bmad/_memory/`)

Each agent reads and writes its own sidecar directory on activation. These files persist decision history across Claude Code sessions:

| Agent | Sidecar path | Key files |
|-------|-------------|-----------|
| Ada | `ada-sidecar/` | `project-memory.md`, `cleaning-decisions.md`, `data-quality-log.md` |
| Grace | `grace-sidecar/` | `eda-insights.md`, `feature-registry.md`, `visualization-library.md` |
| Alan | `alan-sidecar/` | `models-tested.md`, `hyperparameters.md`, `test-set-protocol.md`, `features-used.md` |
| Marie | `marie-sidecar/` | `communication-artifacts.md`, `deployment-registry.md`, `dashboard-tracking.md` |

When editing agent files, be aware agents are instructed to load their full sidecar on activation — the memory files are part of the agent contract.

### Skills (`/.claude/skills/`)

40+ skills are installed, each in its own subdirectory. Skills are markdown files with optional scripts. R-specific skills auto-activate when the right context keywords appear (e.g. `ggplot2` triggers the ggplot2 skill during Grace's EDA phase).

Key skill categories:
- **RDS agents:** `ada/`, `grace/`, `alan/`, `marie/`, `rds-setup/`
- **R expertise:** `r-tidymodels/`, `ggplot2/`, `quarto/`, `r-shiny/`, `r-datascience/`, `tidyverse-expert/`, `torch-r/`, `keras3/`, `r-bayes/`, `r-bioacoustics/`
- **BMad tooling:** `bmad-agent-builder/`, `bmad-module-builder/`, `bmad-workflow-builder/`, `bmad-party-mode/`
- **Google integration:** `r-googleAuthR/`, `r-googledrive/`, `r-googlesheets4/`, `r-gargle/`

## Adding or Modifying Agents

Agent files (`_bmad/rds/agents/*.md`) follow this structure:
1. YAML frontmatter: `name`, `description`, `hasSidecar: true`
2. `## Role` — what the agent does
3. `## Critical Actions on Activation` — sidecar files to load, using `{project-root}` placeholder
4. `## Menu` — `[XX]` commands with trigger patterns and action text

The `{project-root}` placeholder in agent files resolves to the repository root at runtime.

After modifying an agent definition, run `/rds-setup` to re-register it.

## Demo Datasets

`demos/` contains 4 curated datasets for testing workflows:
- `hotels/` — hotel booking data (H1.csv, H2.csv) with `challenge.md`
- `house_mortage/` — mortgage + HPI + recession data
- `income_inequality/` — raw and processed income inequality CSV
- `students_outcome/` — college admissions data

Each dataset has a `description.md` and `challenge.md` that agents use as starting context.

## Configuration Notes

- **Communication language:** Portuguese (user interacts in PT, agents respond in PT)
- **Document output language:** English (reports, Quarto documents are produced in EN)
- **Output folder:** `_bmad-output/` at the project root — do not delete this directory
- **RDS paths in config.yaml** currently point to an old path (`science-core`). The correct path is this repository root. If path resolution errors occur, update `_bmad/config.yaml` to use the current project root.
