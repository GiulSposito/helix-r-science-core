# Step 3: Generate Report

**Workflow:** technical-report
**Phase:** Document Generation
**Duration:** 4-8 hours

---

## Objective

Build complete Quarto document with code chunks, visualizations, tables, and narrative text.

---

## Instructions

Act as Marie. Generate the full technical report following the approved outline.

### 1. Create Quarto Document

Generate `technical-report.qmd` with YAML header:

```yaml
---
title: "[Project Title]"
subtitle: "Technical Report"
author: "[Author Name]"
date: today
format:
  html:
    toc: true
    toc-depth: 3
    code-fold: true
    code-summary: "Show code"
    theme: cosmo
    self-contained: true
---
```

### 2. Write Each Section

For each section from outline:
- **Narrative text:** Explain what, why, how
- **Code chunks:** Reproducible R code with comments
- **Visualizations:** Embed plots with captions
- **Tables:** Use gt or kableExtra for formatting
- **Statistical tests:** Show p-values, confidence intervals

### 3. Code Chunk Standards

- Every chunk has label: `#| label: fig-eda-distribution`
- Show code with `#| code-fold: true`
- Caption plots: `#| fig-cap: "Distribution of target variable"`
- Comment all non-obvious steps
- Use relative paths: `here::here("data/cleaned.rds")`

### 4. Embed Visualizations

- Generate plots inline or load saved figures
- Use consistent ggplot theme
- Add annotations and context
- Caption explains what to notice

### 5. Statistical Rigor

- Report p-values with context (avoid p-hacking discussion)
- Show confidence intervals
- Document all tests performed
- Explain statistical choices

### 6. Reproducibility Checks

- All paths use `here::here()`
- renv lockfile present
- sessionInfo() in appendix
- Data lineage documented

---

## Validation Checklist

Before proceeding to Step 4:
- [ ] All sections completed following outline
- [ ] Code chunks run without errors
- [ ] All visualizations embedded properly
- [ ] Statistical tests documented
- [ ] References and citations included

---

## Output

**Files created:**
- `technical-report.qmd` — Complete Quarto source

**Next:** Proceed to Step 4 (Review & Refine)
