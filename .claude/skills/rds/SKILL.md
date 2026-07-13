---
name: rds
description: R Data Science module hub. Use when the user invokes '/rds', asks 'what agents are available', 'how to get started with RDS', or passes 'setup'/'configure' to reconfigure module paths.
---

# RDS: R Data Science

## Overview

Entry point for the RDS module — a 10-phase framework for R Data Science with 4 specialized agents. Use this skill to orient new users, show available agents, or reconfigure module paths after installation.

## On Activation

1. Load module configuration from `{project-root}/_bmad/config.yaml` (section `rds`).
2. If the user passed `setup` or `configure` as an argument — or if no `rds` section exists in config — run the **Reconfigure** flow below.
3. Otherwise run the **Get Started** flow.

## Get Started

Display the following welcome message, substituting `{user_name}` from config:

---

Welcome to the RDS Module, {user_name}!

The R Data Science framework covers the full lifecycle in 10 phases, handled by 4 specialized agents:

**🏗️ Ada — The Project Architect** `/ada`
Phases 1-3: Project Setup, Data Import & Inspection, Data Cleaning
Start here for new projects or when you have raw data to process.

**🔬 Grace — The Data Scientist** `/grace`
Phases 4-5: Exploratory Data Analysis, Feature Engineering
Start here when your data is clean and ready to explore.

**🤖 Alan — The ML Engineer** `/alan`
Phases 6-8: Model Building, Hyperparameter Tuning, Evaluation
Start here when features are ready and you need a model.

**📊 Marie — The Communicator** `/marie`
Phases 9-10: Reports, Dashboards, Deployment
Start here when the model is trained and results need to be communicated.

---

Where are you in your project?

1. New project / raw data → `/ada`
2. Clean data, need to explore → `/grace`
3. Features ready, need a model → `/alan`
4. Model trained, need to communicate → `/marie`
5. Reconfigure module paths → `/rds setup`

## Reconfigure

If `{project-root}/_bmad/config.yaml` already has an `rds` section, show the current values as defaults.

Ask the user for:
- **Path for RDS workflows** (default: `{project-root}/_bmad/rds/workflows`)
- **Path for agent sidecar memory** (default: `{project-root}/_bmad/_memory`)

Write the answers to the `rds` section of `{project-root}/_bmad/config.yaml`. Preserve all other sections unchanged. Confirm what was written.
