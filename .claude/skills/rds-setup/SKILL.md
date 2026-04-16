---
name: rds-setup
description: Install and configure the RDS (R Data Science) module with 4 specialized agents for the complete data science lifecycle
---

# RDS Module Setup

This skill installs the **RDS: R Data Science** module, which provides a comprehensive 10-phase framework for R data science projects from raw data to production deployment.

## What Gets Installed

### 4 Specialized Agents

1. **Ada** 🏗️ - The Project Architect (Phases 1-3: Setup, Import, Clean)
2. **Grace** 🔬 - The Data Scientist (Phases 4-5: EDA, Features)
3. **Alan** 🤖 - The ML Engineer (Phases 6-8: Build, Tune, Evaluate)
4. **Marie** 📊 - The Communicator (Phases 9-10: Report, Deploy)

### 7 Comprehensive Workflows

- **full-lifecycle** - Complete 10-phase workflow (2-4 weeks)
- **quick-eda** - Streamlined exploration (4-8 hours)
- **modeling-pipeline** - Feature engineering through evaluation (1-2 weeks)
- **prototype-to-production** - Modeling to deployment (1-2 weeks)
- **data-quality-check** - Deep data quality analysis (4-8 hours)
- **hyperparameter-optimization** - Advanced tuning (1-3 days)
- **model-interpretation** - Model explainability (1-2 days)

## Installation

When this skill is invoked, it will:

1. Verify the module structure exists in `_bmad/rds/`
2. Merge module configuration into `_bmad/config.yaml`
3. Register in help system via `_bmad/module-help.csv`
4. Create symlinks for all 4 agents in `.claude/skills/`
5. Confirm sidecar memory structure is ready
6. Display quick start guide

## On Activation

When this skill is invoked, execute the following steps:

### Step 1: Validate Module Structure

Check that the RDS module exists and is complete:

```python
import os
project_root = os.getcwd()
rds_path = os.path.join(project_root, "_bmad/rds")

# Required structure
required_paths = [
    os.path.join(rds_path, "config.yaml"),
    os.path.join(rds_path, "agents/ada.md"),
    os.path.join(rds_path, "agents/grace.md"),
    os.path.join(rds_path, "agents/alan.md"),
    os.path.join(rds_path, "agents/marie.md"),
    os.path.join(rds_path, "workflows"),
    os.path.join(project_root, "_bmad/_memory")
]

# Verify all exist
for path in required_paths:
    if not os.path.exists(path):
        print(f"❌ Missing: {path}")
        print("RDS module structure is incomplete. Please ensure _bmad/rds/ is properly set up.")
        exit(1)

print("✅ RDS module structure validated")
```

### Step 2: Merge Module Configuration

Run the configuration merger to add RDS config to the user's `_bmad/config.yaml`:

```bash
cd .claude/skills/rds-setup
python3 scripts/merge-config.py
```

This will:
- Read `assets/module.yaml`
- Prompt for config values (or use defaults)
- Merge into `{project-root}/_bmad/config.yaml`
- Create backup before modifying

### Step 3: Register in Help System

Run the help CSV merger to make RDS discoverable:

```bash
cd .claude/skills/rds-setup
python3 scripts/merge-help-csv.py
```

This will:
- Read `assets/module-help.csv`
- Merge into `{project-root}/_bmad/help.csv`
- Prevent duplicates
- Enable menu code: [SR] Setup RDS

### Step 4: Display Success Message

After successful installation, show the module greeting from `assets/module.yaml`.

### Step 5: Verify Installation

Confirm:
- ✅ Config merged into `_bmad/config.yaml`
- ✅ Help entry added to `_bmad/help.csv`
- ✅ All 4 agents exist in `_bmad/rds/agents/`
- ✅ Sidecar memory structure ready

### Step 6: Register Agent Skills

Create symlinks for the 4 RDS agents in `.claude/skills/` to make them invokable:

```bash
cd {project-root}/.claude/skills
for agent in ada grace alan marie; do
  if [ ! -d "$agent" ]; then
    mkdir -p "$agent"
    ln -sf "../../../_bmad/rds/agents/${agent}.md" "$agent/SKILL.md"
    echo "✅ Registered: /$agent"
  else
    echo "⚠️  Skill already exists: /$agent"
  fi
done
```

This enables users to invoke agents via:
- `/ada` - Project Architect (Phases 1-3)
- `/grace` - Data Scientist (Phases 4-5)
- `/alan` - ML Engineer (Phases 6-8)
- `/marie` - Communicator (Phases 9-10)

## Agent Registration

The RDS module provides 4 specialized agents that users can invoke:

- **Ada (Project Architect)** - `/ada` - Phases 1-3: Setup, Import, Clean
- **Grace (Data Scientist)** - `/grace` - Phases 4-5: EDA, Features
- **Alan (ML Engineer)** - `/alan` - Phases 6-8: Build, Tune, Evaluate
- **Marie (Communicator)** - `/marie` - Phases 9-10: Report, Deploy

**Note:** Agent skills are automatically registered in `.claude/skills/` via symlinks during Step 6 of the setup process.

## Quick Start Guide

After installation, users can:

1. **Start a new project:** Invoke Ada with "I'm starting a new R data science project"
2. **Explore data:** Invoke Grace with "I need to do EDA on my dataset"
3. **Build models:** Invoke Alan with "I need to train and tune models"
4. **Create reports:** Invoke Marie with "I need to create reports and deploy"

## Module Information

**Module Code:** rds  
**Module Type:** Standalone  
**Module Path:** `{project-root}/_bmad/rds/`  
**Config:** `{project-root}/_bmad/rds/config.yaml`

## Success Message

Display this message after successful installation:

```
🎉 RDS Module Installed Successfully!

The R Data Science module is now available with 4 specialized agents:

🏗️  **Ada** (Project Architect) - Setup, Import, Clean
    Invoke: /ada or "Hey Ada, help me setup a project"

🔬 **Grace** (Data Scientist) - EDA, Features  
    Invoke: /grace or "Hey Grace, let's explore this data"

🤖 **Alan** (ML Engineer) - Build, Tune, Evaluate
    Invoke: /alan or "Hey Alan, I need to build models"

📊 **Marie** (Communicator) - Report, Deploy
    Invoke: /marie or "Hey Marie, create a report"

**Quick Start:**
- New project? → Start with Ada
- Have clean data? → Start with Grace  
- Features ready? → Start with Alan
- Model trained? → Start with Marie

**Documentation:** See {project-root}/_bmad/rds/README.md

Happy data sciencing! 🚀
```

## Error Handling

If validation fails during Step 1:
- **Missing _bmad/rds/**: Inform user that the RDS module content must be installed first
- **Missing agents**: Check that `_bmad/rds/agents/` contains ada.md, grace.md, alan.md, marie.md
- **Missing config**: Verify `_bmad/rds/config.yaml` exists

If script execution fails:
- Ensure Python 3 is available
- Check file permissions on scripts
- Verify script paths are correct

## Notes

- This module requires existing R skills in BMAD for full functionality
- Agents will automatically activate relevant R skills contextually
- Sidecar memory persists context across sessions
- Module is standalone and doesn't depend on other custom modules
