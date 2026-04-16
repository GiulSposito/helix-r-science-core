# RDS: R Data Science Module

**Version:** 1.0.0  
**Status:** Production Ready  
**Module Type:** Standalone

> A comprehensive 10-phase framework for R data science projects, from raw data to production deployment, guided by best practices.

---

## Overview

The RDS module transforms the R data science lifecycle from an ad-hoc process into an executable, guided framework. It provides 4 specialized agents that orchestrate the complete journey from project setup through production deployment, integrating decades of best practices from the tidyverse and tidymodels ecosystems.

### Key Features

- **4 Specialized Agents** - Each agent is an expert in their phase of the lifecycle
- **10-Phase Framework** - Complete coverage from setup to deployment
- **7 Comprehensive Workflows** - From 4-hour quick EDA to 4-week full lifecycle
- **Sidecar Memory** - Agents remember context, decisions, and artifacts across sessions
- **Production-Ready** - Built on reproducibility from day one (renv, Git, Quarto)
- **Pedagogical** - Agents teach while executing, building your understanding

---

## The Four Guardians

### 🏗️ Ada - The Project Architect
**Phases 1-3:** Setup, Import & Inspect, Clean Data

Ada lays the foundation for success. Expert in reproducibility infrastructure (renv, Git), data quality validation, and tidyverse data preparation.

**Catchphrase:** "Structure enables creativity"

**When to invoke:** Starting a new project, importing data, cleaning datasets

### 🔬 Grace - The Data Scientist  
**Phases 4-5:** Exploratory Data Analysis, Feature Engineering

Grace explores data systematically and creates powerful features. Expert in ggplot2 visualization, statistical exploration, and tidymodels recipes framework.

**Catchphrase:** "Let the data speak"

**When to invoke:** Need to explore data, find patterns, engineer features

### 🤖 Alan - The ML Engineer
**Phases 6-8:** Build Models, Tune Hyperparameters, Evaluate

Alan builds high-performance models with rigorous validation. Expert in tidymodels workflows, systematic model comparison, and preventing overfitting.

**Catchphrase:** "Trust metrics, not intuition"

**When to invoke:** Building models, tuning performance, final evaluation

### 📊 Marie - The Communicator
**Phases 9-10:** Communication, Deployment

Marie transforms technical results into business value. Expert in Quarto reporting, Shiny dashboards, and Vetiver API deployment.

**Catchphrase:** "Science without communication is incomplete"

**When to invoke:** Creating reports, building dashboards, deploying to production

---

## Quick Start

### Installation

```
Invoke: /rds-setup
```

This installs all 4 agents and verifies the module structure.

### Your First Project

**1. Starting Fresh?** → **Ada**
```
"Hey Ada, I'm starting a new data science project"
```

**2. Have Clean Data?** → **Grace**
```
"Hey Grace, let's explore this dataset"
```

**3. Features Ready?** → **Alan**
```
"Hey Alan, I need to build and tune models"
```

**4. Model Trained?** → **Marie**
```
"Hey Marie, create an executive report"
```

---

## The 10-Phase Framework

| Phase | Agent | Focus | Duration |
|-------|-------|-------|----------|
| **1. Setup** | Ada | Project structure, renv, Git | 15-30 min |
| **2. Import** | Ada | Load data with quality checks | 30-60 min |
| **3. Clean** | Ada | Systematic data wrangling | 2-4 hours |
| **4. EDA** | Grace | Exploratory analysis, visualization | 4-8 hours |
| **5. Features** | Grace | Feature engineering with recipes | 4-8 hours |
| **6. Build** | Alan | Baseline + model comparison | 2-4 hours |
| **7. Tune** | Alan | Hyperparameter optimization | 4-8 hours |
| **8. Evaluate** | Alan | Test set evaluation, interpretation | 2-4 hours |
| **9. Communicate** | Marie | Reports, dashboards | 4-8 hours |
| **10. Deploy** | Marie | Vetiver API, monitoring | 4-8 hours |

**Total:** 2-4 weeks for complete production pipeline

---

## Workflows

### Core Workflows

**📋 full-lifecycle** (2-4 weeks)
- Complete 10-phase workflow from zero to production
- Owner: Ada (orchestrates all agents)
- Use when: Starting from scratch, need production-ready pipeline

**⚡ quick-eda** (4-8 hours)
- Streamlined Setup → Import → Clean → EDA
- Owner: Grace
- Use when: Quick data exploration, prototyping

**🤖 modeling-pipeline** (1-2 weeks)
- Feature Engineering → Build → Tune → Evaluate (Phases 5-8)
- Owner: Alan
- Use when: Data is clean, focus on model optimization

**🚀 prototype-to-production** (1-2 weeks)
- Modeling → Communication → Deploy (Phases 6-10)
- Owner: Marie (with Alan handoff)
- Use when: Features ready, need to take to production

### Specialized Workflows

**🔍 data-quality-check** (4-8 hours)
- Deep dive into data quality issues
- Owner: Ada
- Use when: Suspicious data, many quality concerns

**⚙️ hyperparameter-optimization** (1-3 days)
- Advanced Bayesian tuning, racing methods
- Owner: Alan
- Use when: Need maximum model performance

**📊 model-interpretation** (1-2 days)
- VIP, SHAP, PDPs for explainability
- Owner: Alan
- Use when: Model needs to be explainable

---

## Agent Commands

Each agent has specialized menu commands:

### Ada Commands

- `[GS]` Get Started - Friendly navigation
- `[SP]` Setup Project - Structure, renv, Git
- `[II]` Import & Inspect - Load with quality checks
- `[CD]` Clean Data - Systematic wrangling
- `[FL]` Full Lifecycle - Complete 10-phase workflow
- `[DQ]` Data Quality Check - Deep quality analysis
- `[WS]` Workflow Status - Show progress

### Grace Commands

- `[GS]` Get Started - Friendly navigation
- `[ED]` Run EDA - Complete exploratory analysis
- `[FE]` Feature Engineering - Guided feature creation
- `[QE]` Quick EDA - Streamlined setup + EDA
- `[DT]` Decision Trees - Encoding/transformation guidance
- `[WS]` Workflow Status - Show progress

### Alan Commands

- `[GS]` Get Started - Friendly navigation
- `[BM]` Build Model - Baseline + comparison
- `[TM]` Tune Model - Standard tuning
- `[EM]` Evaluate Model - Test set evaluation
- `[MP]` Modeling Pipeline - Phases 5-8
- `[HO]` Hyperparameter Optimization - Max performance
- `[MI]` Model Interpretation - Explainability
- `[MS]` Model Selection Guide - Choose approach
- `[WS]` Workflow Status - Show progress

### Marie Commands

- `[GS]` Get Started - Friendly navigation
- `[TR]` Technical Report - 30+ page methodology
- `[ER]` Executive Report - 2-3 page summary
- `[BD]` Build Dashboard - Shiny with KPIs
- `[DM]` Deploy Model - Vetiver API + monitoring
- `[MM]` Model Monitoring - Configure alerts
- `[PG]` Presentation Generation - Quarto slides
- `[WS]` Workflow Status - Show progress

---

## Example Scenarios

### Scenario 1: Quick Prototype (6-8 hours)

Senior DS receives churn data Monday, needs prototype by Friday.

1. Ada → `[SP]` Setup (15 min)
2. Ada → `[II]` Import (identifies 15% missings)
3. Ada → `[CD]` Clean (guided decisions)
4. Grace → `[QE]` Quick EDA (visual insights)
5. Alan → `[MP]` Modeling Pipeline (tests 3 models, 87% accuracy)
6. Marie → `[BD]` Dashboard (presentation-ready KPIs)

**Result:** 6.5 hours, 87% accuracy, documented, reproducible

### Scenario 2: Full Production Pipeline (2-3 weeks)

ML Engineer needs demand forecasting in production.

- **Week 1:** Ada setup, Grace deep EDA + 47 features
- **Week 2:** Alan tests 4 models, Bayesian tuning (50 iterations)
- **Week 3:** Alan walk-forward validation, Marie technical report + executive summary + Vetiver API deployment

**Result:** Production model, documented, monitored, stakeholder-approved

### Scenario 3: EDA Exploration (3-4 hours)

Analyst explores sales data (100k transactions, 5 stores).

1. Grace coordinates with Ada for quick setup (5 min)
2. Grace → `[ED]` Run EDA
3. Discovers: Store 3 has 2x weekend sales, Electronics 3x ticket
4. Marie → `[ER]` HTML report with insights

**Result:** 3 hours, actionable insights, learned structured workflow

---

## Sidecar Memory

Each agent maintains persistent memory across sessions:

**Ada's Sidecar:**
- `project-memory.md` - Structure, setup, renv status
- `cleaning-decisions.md` - Missing values, transformations
- `data-quality-log.md` - Quality issues, validations

**Grace's Sidecar:**
- `eda-insights.md` - Patterns found, hypotheses
- `feature-registry.md` - Features created, performance
- `visualization-library.md` - Key plots, templates

**Alan's Sidecar:**
- `models-tested.md` - All models, scores, decisions
- `hyperparameters.md` - Tuning history, best configs
- `test-set-protocol.md` - Data budgeting, no peeking
- `features-used.md` - Final feature set

**Marie's Sidecar:**
- `communication-artifacts.md` - Reports, presentations created
- `deployment-registry.md` - Models deployed, versions
- `dashboard-tracking.md` - Dashboards, KPIs, feedback

---

## Integration with R Skills

The RDS module deeply integrates with existing BMAD R skills:

- **r-tidymodels** - Auto-activated during modeling phases
- **ggplot2** - Auto-activated during EDA
- **quarto** - Auto-activated during reporting
- **r-shiny** - Auto-activated during dashboard creation
- **tidyverse-expert** - Auto-activated during data wrangling

Agents mention keywords that trigger contextual skill activation.

---

## Module Structure

```
_bmad/rds/
├── config.yaml              # Module configuration
├── README.md               # This file
├── agents/
│   ├── ada.md             # Project Architect agent
│   ├── grace.md           # Data Scientist agent
│   ├── alan.md            # ML Engineer agent
│   └── marie.md           # Communicator agent
├── workflows/
│   ├── full-lifecycle/
│   ├── quick-eda/
│   ├── modeling-pipeline/
│   ├── prototype-to-production/
│   ├── data-quality-check/
│   ├── hyperparameter-optimization/
│   └── model-interpretation/
├── data/
│   ├── checklists/
│   ├── decision-trees/
│   └── references/
├── templates/
│   ├── project-structure/
│   ├── quarto-reports/
│   └── r-scripts/
├── docs/
│   └── (additional documentation)
└── _module-installer/
    └── (installation resources)
```

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

## Version History

**v1.0.0** (2026-04-16)
- Initial production release
- 4 agents: Ada, Grace, Alan, Marie
- 7 workflows covering complete lifecycle
- Sidecar memory implementation
- Full integration with R skills

---

## Credits

**Created by:** Gsposito  
**Built with:** BMad Module Builder  
**Inspired by:** Computing pioneers Ada Lovelace, Grace Hopper, Alan Turing, Marie Curie

**Based on wisdom from:**
- Max Kuhn & Julia Silge (Tidymodels)
- Hadley Wickham (Tidyverse)
- John Tukey (Exploratory Data Analysis)
- Andrew Ng (Machine Learning best practices)

---

## License

Part of the BMAD ecosystem. See project root for license information.

---

**Questions or Issues?**

Invoke any agent with `[GS]` Get Started for friendly guidance, or check the documentation in `_bmad/rds/docs/`.
