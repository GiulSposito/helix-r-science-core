---
name: executive-report
description: Generate executive summary with key insights and recommendations
installed_path: '{project-root}/_bmad/rds/workflows/executive-report'
---

# Executive Report Workflow

**Module:** RDS (R Data Science)
**Owner:** Marie (The Reporter)
**Status:** Active
**Duration:** 4-6 hours

---

## Workflow Overview

**Goal:** Create concise executive summary (2-3 pages) with visual-first insights and clear recommendations

**Description:** Generate business-focused report using Quarto. Translates technical findings into executive language with actionable recommendations. Prioritizes visual storytelling and business impact over statistical details. Designed for C-suite, business stakeholders, and decision-makers.

**Workflow Type:** Core — Single-step synthesis

---

## Activation Sequence

<activation>

### Step 1: Welcome & Context

**Output:**
```
╔══════════════════════════════════════════════════════════════╗
║            EXECUTIVE REPORT GENERATION                       ║
║       Transforming Data into Decision Guidance               ║
╚══════════════════════════════════════════════════════════════╝

Marie here! Let's transform your technical results into compelling executive communication.

This workflow will:
  • Synthesize key findings from all project phases
  • Identify top 3 business-critical insights
  • Generate visual-first presentation
  • Draft clear, actionable recommendations
  • Create 2-3 page executive summary

Duration: 4-6 hours

Remember: Executive summary FIRST - respect stakeholder time!
```

### Step 2: Execute Report Generation

**Process:**

1. **Gather Context**
   - Load technical-report.qmd if exists (as source material)
   - Collect key metrics from Alan's model evaluation
   - Review top insights from Grace's EDA
   - Identify business impact points

2. **Extract Top 3 Insights**
   - What are the 3 most important findings?
   - What action should each insight drive?
   - Which visualizations best communicate each insight?

3. **Draft Executive Summary**
   - Opening: Project context in 2-3 sentences
   - Key Findings: Top 3 insights with visuals
   - Business Impact: Quantified value/risk
   - Recommendations: Clear, specific, actionable
   - Next Steps: Timeline and ownership

4. **Generate Quarto Document**
   - Create executive-report.qmd with:
     - No code visible (results only)
     - Large, clear visualizations
     - Business language (minimal jargon)
     - Bullet points over paragraphs
     - Action-oriented framing

5. **Render & Review**
   - Render to HTML/PDF
   - Verify under 3 pages
   - Check: Can a busy executive understand this in 5 minutes?

### Step 3: Completion

**Output:**
```
╔══════════════════════════════════════════════════════════════╗
║           EXECUTIVE REPORT COMPLETE!                         ║
╚══════════════════════════════════════════════════════════════╝

Your executive summary is ready!

Generated artifacts:
  • executive-report.qmd — Source Quarto document
  • executive-report.html — Rendered report (2-3 pages)
  • executive-report.pdf — Optional PDF version
  • figures/ — Key visualizations

Report contents:
  ✓ Executive Summary (project context)
  ✓ Top 3 Key Insights (visual-first)
  ✓ Business Impact Analysis
  ✓ Actionable Recommendations
  ✓ Next Steps & Timeline

Next steps:
  • Review with stakeholders
  • Use /bmad:rds:agents:marie for presentation-generation
  • Refine based on feedback

Ready for the boardroom! 💼
```

</activation>

---

## Workflow Properties

**Input Requirements:**
- Model evaluation metrics
- Key insights from analysis
- Business context and objectives

**Optional Inputs:**
- Existing technical-report.qmd (as source)
- Stakeholder profiles (from Marie's sidecar)
- Presentation deadline

**Outputs:**
- `executive-report.qmd` — Quarto source
- `executive-report.html` — Rendered report
- `executive-report.pdf` — Optional PDF
- `figures/` — Key visualizations only

---

## Agent Integration

**Primary Agent:** Marie (The Reporter)
- Synthesizes technical findings into business language
- Selects most impactful visualizations
- Crafts actionable recommendations

**Supporting Agents:**
- **Alan** — Provides model performance summary
- **Grace** — Provides key data insights
- **Tim** — Provides production impact (if deployed)

---

## Implementation Notes

**Philosophy:**
- Executive summary FIRST - 2-minute read before deep dive
- Visual storytelling over tables - plots first, numbers second
- Business language - translate jargon to value
- Action-oriented - every insight drives a recommendation

**Content Strategy:**
- Opening hook: Why this matters (30 seconds)
- Top 3 insights: Visual + interpretation (2 minutes)
- Business impact: Quantified value/risk (1 minute)
- Recommendations: Clear next steps (1 minute)
- Total read time: < 5 minutes

**Best For:**
- Board presentations
- Executive updates
- Funding requests
- Strategic decision-making

**Not Ideal For:**
- Technical peer review (use technical-report)
- Detailed methodology (use technical-report)
- Code reproducibility (use technical-report)

---

## Technical Requirements

**R Packages:**
- Core: tidyverse, here
- Reporting: quarto, rmarkdown
- Visualization: ggplot2, scales
- Tables: gt (minimal tables only)

**Quarto Features:**
- Clean theme (minimal chrome)
- Large plots (readability)
- Executive-friendly formatting
- PDF export support

**Expected Duration:**
- Synthesis & drafting: 2-3 hours
- Visualization selection: 1-2 hours
- Quarto generation: 1-2 hours
- Review & polish: 30-60 minutes

---

_Workflow created on 2026-03-26 for RDS Module v0.2.0_
