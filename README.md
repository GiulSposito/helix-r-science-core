# HelixDS R Science Core

> A comprehensive agentic ecosystem for data science excellence in R for Claude Code.

**Version:** 1.0.0  
**Status:** Production Ready  
**Maintainer:** Giuliano Sposito

---

## Overview

HelixDS Science Core is a production-ready data science framework that combines the power of BMad (Better Model, Advance Development) with specialized R expertise. This repository provides an integrated environment featuring AI-powered agents, structured workflows, and best-practice guidance for the complete data science lifecycle.

![Helix Logo](helix_logo.png)

### What's Inside

- **🏗️ RDS Module** - Complete 10-phase R Data Science framework with 4 specialized agents
- **📊 R Expertise** - Deep integration with tidyverse, tidymodels, ggplot2, Quarto, and more
- **🧠 Intelligent Agents** - Ada, Grace, Alan, and Marie guide you from raw data to production
- **🔄 Structured Workflows** - 13 production-ready workflows covering 4-hour to 4-week projects

---

## Quick Start

### Prerequisites

- Claude Code CLI or Desktop App
- Python 3.x
- R 4.0+ (for RDS module)

### Installation

1. **Clone this repository:**
   ```bash
   git clone <repository-url>
   cd science-core
   ```

2. **Install the RDS module:**
   ```
   /rds-setup
   ```

3. **Start your first project:**
   ```
   /ada
   [GS]  # Get Started
   ```

---

## The RDS Module

The crown jewel of this ecosystem is the **RDS (R Data Science)** module - a complete framework that transforms R data science from ad-hoc scripting into an executable, guided process.

### 🏗️ The Four Guardians

#### Ada - The Project Architect
**Phases 1-3:** Setup, Import & Inspect, Clean Data

Expert in reproducibility infrastructure (renv, Git), data quality validation, and tidyverse data preparation.

```bash
/ada  # Invoke Ada
```

**Best for:** Starting new projects, importing data, cleaning datasets

---

#### Grace - The Data Scientist
**Phases 4-5:** Exploratory Data Analysis, Feature Engineering

Expert in ggplot2 visualization, statistical exploration, and tidymodels recipes framework.

```bash
/grace  # Invoke Grace
```

**Best for:** Understanding data, finding patterns, engineering features

---

#### Alan - The ML Engineer
**Phases 6-8:** Build Models, Tune Hyperparameters, Evaluate

Expert in tidymodels workflows, systematic model comparison, and preventing overfitting.

```bash
/alan  # Invoke Alan
```

**Best for:** Building models, tuning performance, final evaluation

---

#### Marie - The Communicator
**Phases 9-10:** Communication, Deployment

Expert in Quarto reporting, Shiny dashboards, and Vetiver API deployment.

```bash
/marie  # Invoke Marie
```

**Best for:** Creating reports, building dashboards, deploying to production

---

![Helix Agents](helix_agents.png)

---

### 🔄 13 Production-Ready Workflows

| Workflow | Duration | Use Case |
|----------|----------|----------|
| **full-lifecycle** | 2-4 weeks | Complete pipeline from zero to production |
| **quick-eda** | 4-8 hours | Fast exploration and prototyping |
| **modeling-pipeline** | 1-2 weeks | Feature engineering through evaluation |
| **prototype-to-production** | 1-2 weeks | Taking trained models to deployment |
| **data-quality-check** | 4-8 hours | Deep data quality analysis |
| **hyperparameter-optimization** | 1-3 days | Maximum model performance |
| **model-interpretation** | 1-2 days | Model explainability and SHAP |
| **build-dashboard** | 4-8 hours | Interactive Shiny dashboards |
| **deploy-model** | 4-8 hours | Vetiver API deployment |
| **technical-report** | 4-8 hours | 30+ page methodology documentation |
| **executive-report** | 4-6 hours | 2-3 page executive summary |
| **presentation-generation** | 4-8 hours | Reveal.js stakeholder slides |
| **model-monitoring** | 2-4 hours | Production monitoring setup |

---

## BMad Skills

This repository includes 40+ BMad skills across multiple categories:

### 🎓 R Expertise Skills

- **r-datascience** - Tidyverse data science
- **r-tidymodels** - Machine learning with tidymodels
- **ggplot2** - Data visualization
- **quarto** - Reproducible reporting
- **r-shiny** - Interactive web apps
- **torch-r** - Deep learning with torch
- **keras3** - Keras3 neural networks
- **r-bioacoustics** - Bioacoustic analysis
- **r-bayes** - Bayesian inference with brms
- **r-performance** - Code optimization

---

## Repository Structure

```
science-core/
├── _bmad/                      # BMad modules and configuration
│   ├── rds/                   # RDS module (4 agents, 13 workflows)
│   │   ├── agents/           # Ada, Grace, Alan, Marie
│   │   ├── workflows/        # 13 production workflows
│   │   ├── data/             # Checklists, decision trees, references
│   │   ├── templates/        # Project templates, Quarto, R scripts
│   │   └── docs/             # Additional documentation
│   ├── core/                  # Core BMad infrastructure
│   ├── bmb/                   # BMad Module Builder config
│   ├── _memory/               # Agent sidecar memory
│   └── _config/               # Module configurations
│
├── _bmad-output/              # Generated artifacts
│   └── bmb-creations/        # Agent plans, validations, reports
│
├── .claude/                   # Claude Code integration
│   └── skills/               # 40+ installed skills
│
└── README.md                  # This file
```

---

## Example Scenarios

### Scenario 1: Quick Prototype (6-8 hours)

Senior Data Scientist receives churn data Monday, needs prototype by Friday.

```bash
/ada
[SP]  # Setup project (15 min)
[II]  # Import data (identifies 15% missings)
[CD]  # Clean data (guided decisions)

/grace
[QE]  # Quick EDA (visual insights)

/alan
[MP]  # Modeling pipeline (tests 3 models)

/marie
[BD]  # Build dashboard (presentation-ready)
```

**Result:** 6.5 hours, 87% accuracy, documented, reproducible

---

### Scenario 2: Full Production Pipeline (2-3 weeks)

ML Engineer needs demand forecasting in production.

- **Week 1:** Ada setup, Grace deep EDA + 47 features
- **Week 2:** Alan tests 4 models, Bayesian tuning (50 iterations)
- **Week 3:** Alan evaluation, Marie report + Vetiver API deployment

**Result:** Production model, monitored, stakeholder-approved

---

### Scenario 3: EDA Exploration (3-4 hours)

Analyst explores sales data (100k transactions, 5 stores).

```bash
/grace
[ED]  # Run EDA
# Discovers: Store 3 has 2x weekend sales

/marie
[ER]  # Executive HTML report
```

**Result:** 3 hours, actionable insights, structured workflow

---

## Sidecar Memory

Each RDS agent maintains persistent memory across sessions:

### Ada's Sidecar
- `project-memory.md` - Structure, setup, renv status
- `cleaning-decisions.md` - Missing values, transformations
- `data-quality-log.md` - Quality issues, validations

### Grace's Sidecar
- `eda-insights.md` - Patterns found, hypotheses
- `feature-registry.md` - Features created, performance
- `visualization-library.md` - Key plots, templates

### Alan's Sidecar
- `models-tested.md` - All models, scores, decisions
- `hyperparameters.md` - Tuning history, best configs
- `test-set-protocol.md` - Data budgeting, no peeking
- `features-used.md` - Final feature set

### Marie's Sidecar
- `communication-artifacts.md` - Reports, presentations
- `deployment-registry.md` - Models deployed, versions
- `dashboard-tracking.md` - Dashboards, KPIs, feedback

---

## Integration with R Skills

The RDS module deeply integrates with existing BMad R skills:

- **r-tidymodels** - Auto-activated during modeling phases
- **ggplot2** - Auto-activated during EDA
- **quarto** - Auto-activated during reporting
- **r-shiny** - Auto-activated during dashboard creation
- **tidyverse-expert** - Auto-activated during data wrangling

Agents mention keywords that trigger contextual skill activation.

---

## Best Practices

### When to Use Which Agent

**Ada** - Foundation work, data quality issues, reproducibility concerns  
**Grace** - Understanding data, finding insights, creating features  
**Alan** - Model performance, hyperparameter tuning, evaluation rigor  
**Marie** - Stakeholder communication, production deployment, monitoring

### Agent Coordination

Agents can hand off to each other:
- Ada → Grace: "Data is clean, ready for EDA"
- Grace → Alan: "Features created, recipe ready"
- Alan → Marie: "Model evaluated, ready for deployment"

### Workflow Selection Guide

| Your Situation | Recommended Workflow | Duration |
|----------------|---------------------|----------|
| Starting from scratch | full-lifecycle | 2-4 weeks |
| Quick exploration needed | quick-eda | 4-8 hours |
| Data clean, need model | modeling-pipeline | 1-2 weeks |
| Features ready, need deploy | prototype-to-production | 1-2 weeks |
| Data quality concerns | data-quality-check | 4-8 hours |
| Need max performance | hyperparameter-optimization | 1-3 days |
| Need explainability | model-interpretation | 1-2 days |

---

## Common Commands

### RDS Module Commands

```bash
/rds-setup              # Install RDS module
/ada                    # Invoke Ada (Project Architect)
/grace                  # Invoke Grace (Data Scientist)
/alan                   # Invoke Alan (ML Engineer)
/marie                  # Invoke Marie (Communicator)
```

### BMad Skills

```bash
/bmad-agent-builder     # Build custom agents
/bmad-workflow-builder  # Design workflows
/bmad-module-builder    # Package modules
/bmad-brainstorming     # Ideation sessions
/bmad-party-mode        # Multi-agent discussions
```

### R Expertise

```bash
/r-datascience         # Tidyverse guidance
/r-tidymodels          # Modeling guidance
/ggplot2               # Visualization help
/quarto                # Reporting help
/r-shiny               # Dashboard help
```

---

## Configuration

### Global Configuration

BMad configuration is stored in `_bmad/config.yaml`:

```yaml
user_name: gsposito@ciandt.com
communication_language: Portuguese
document_output_language: English
output_folder: "{project-root}/_bmad-output"
```

### RDS Module Configuration

RDS-specific paths in `_bmad/rds/config.yaml`:

```yaml
rds_workflows_path: "{project-root}/_bmad/rds/workflows"
rds_data_path: "{project-root}/_bmad/rds/data"
rds_templates_path: "{project-root}/_bmad/rds/templates"
rds_sidecar_memory: "{project-root}/_bmad/_memory"
```

---

## Troubleshooting

### Agent not responding?

Check that the agent file exists:
```bash
ls _bmad/rds/agents/
```

### Sidecar memory errors?

Verify sidecar directories:
```bash
ls _bmad/_memory/*-sidecar/
```

### Workflow not found?

Check workflow structure:
```bash
ls _bmad/rds/workflows/
```

---

## Credits

**Created by:** Giuliano Sposito (gsposito@ciandt.com)  
**Built with:** BMad Module Builder  
**Powered by:** Claude Code

**RDS Agents inspired by:**
- Ada Lovelace (First computer programmer)
- Grace Hopper (COBOL pioneer)
- Alan Turing (Father of computer science)
- Marie Curie (Nobel Prize winner)

**Based on wisdom from:**
- Max Kuhn & Julia Silge (Tidymodels)
- Hadley Wickham (Tidyverse)
- John Tukey (Exploratory Data Analysis)
- Andrew Ng (Machine Learning best practices)

---

## Version History

**v1.0.0** (2026-04-16)
- Initial production release
- RDS module with 4 agents and 13 workflows
- 40+ BMad skills integrated
- Sidecar memory implementation
- Full R ecosystem integration

---

## License

Part of the BMad ecosystem. See project root for license information.

---

## Support

**Questions or Issues?**

Invoke any agent with `[GS]` Get Started for friendly guidance:

```bash
/ada
[GS]
```

Or explore the documentation:
- RDS Module: `_bmad/rds/README.md`
- Workflows: `_bmad/rds/workflows/`
- BMad Help: `/bmad-help`

---

**Happy data sciencing!** 🚀
