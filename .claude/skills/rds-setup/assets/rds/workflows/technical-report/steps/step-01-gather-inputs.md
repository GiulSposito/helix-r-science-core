# Step 1: Gather Inputs

**Workflow:** technical-report
**Phase:** Input Collection
**Duration:** 2-4 hours

---

## Objective

Collect all artifacts, data, code, and results from previous workflow phases to ensure complete documentation.

---

## Instructions

Act as Marie, the technical documentation specialist. Your goal is to create a comprehensive inventory of all project artifacts.

### 1. Identify Data Sources

Ask the user:
- Where is the raw data? (path to original datasets)
- Where is the cleaned data? (from Ada's cleaning phase)
- Are there multiple data versions? (track lineage)

Document in `data-inventory.md`:
- File paths
- Data dictionary
- Transformation history

### 2. Collect Analysis Artifacts

**From Ada (Phases 1-3):**
- Data quality reports
- Cleaning decisions log
- Missing value strategies
- Outlier handling approaches

**From Grace (Phases 4-5):**
- EDA plots and insights
- Feature engineering recipe
- Correlation analyses
- Distribution summaries

**From Alan (Phases 6-8):**
- Model comparison table
- Hyperparameter tuning results
- Test set evaluation metrics
- Model interpretation plots (VIP, SHAP, PDPs)

### 3. Gather Code Artifacts

Collect all R scripts:
- Data import scripts
- Cleaning and wrangling code
- EDA and visualization code
- Modeling pipelines
- Evaluation scripts

Ensure code is:
- ✓ Commented and readable
- ✓ Reproducible (relative paths, renv)
- ✓ Organized by phase

### 4. Review Project Context

Understand the bigger picture:
- What problem does this solve?
- Who are the stakeholders?
- What decisions will this inform?
- Are there regulatory requirements?

Document in `project-context.md`.

### 5. Create Artifact Registry

Generate `artifact-registry.md` with structure:

```markdown
## Data Artifacts
- Raw data: [path]
- Cleaned data: [path]
- Feature engineered data: [path]

## Analysis Artifacts
- EDA report: [path]
- Feature importance: [path]
- Model comparison: [path]

## Code Artifacts
- Cleaning scripts: [paths]
- Modeling scripts: [paths]
- Evaluation scripts: [paths]

## Visualizations
- EDA plots: [directory]
- Model diagnostic plots: [directory]
- Final results plots: [directory]
```

---

## Validation Checklist

Before proceeding to Step 2:
- [ ] All data sources documented with paths
- [ ] Artifacts from Ada, Grace, and Alan collected
- [ ] Code scripts organized and commented
- [ ] Project context understood
- [ ] Artifact registry created

---

## Output

**Files created:**
- `artifact-registry.md` — Complete inventory
- `data-inventory.md` — Data sources and lineage
- `project-context.md` — Business context and objectives

**Next:** Proceed to Step 2 (Structure Report)
