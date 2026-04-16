# Step 4: Review & Refine

**Workflow:** technical-report
**Phase:** Quality Control
**Duration:** 2-4 hours

---

## Objective

Technical review, reproducibility verification, and formatting polish before final delivery.

---

## Instructions

Act as Marie with a critical eye. Verify the report meets publication quality standards.

### 1. Reproducibility Test

Run complete render from clean session:
```r
# Clean render test
quarto::quarto_render("technical-report.qmd")
```

Verify:
- [ ] All code chunks execute without errors
- [ ] All paths resolve correctly
- [ ] All visualizations render
- [ ] All tables format properly
- [ ] Cross-references work

### 2. Technical Review

Check each section:
- **Methodology** — Are all choices explained and justified?
- **Results** — Are claims supported by evidence?
- **Statistics** — Are tests appropriate and documented?
- **Code** — Is it readable and commented?
- **Limitations** — Are assumptions stated clearly?

### 3. Formatting Polish

- Table of contents complete and accurate
- Section numbering consistent
- Figures and tables numbered sequentially
- Cross-references functional (`@fig-name`, `@tbl-name`)
- Code folding works correctly
- Captions descriptive and informative

### 4. Content Review

- Executive summary reflects full report
- Recommendations are specific and actionable
- No jargon left unexplained
- Statistical terms defined on first use
- Appendix contains all supporting material

### 5. Generate Final Outputs

Render to multiple formats:
```r
# HTML (default)
quarto::quarto_render("technical-report.qmd")

# PDF (optional)
quarto::quarto_render("technical-report.qmd", output_format = "pdf")
```

### 6. Create Supplementary Files

- `README.md` — How to reproduce the report
- `sessionInfo.txt` — R session details
- `renv.lock` — Exact package versions

---

## Quality Checklist

Final validation:
- [ ] Report renders cleanly in < 5 minutes
- [ ] All code is reproducible
- [ ] Visualizations are high quality
- [ ] Tables are formatted properly
- [ ] References and citations complete
- [ ] Executive summary accurate
- [ ] Recommendations clear and actionable
- [ ] Appendix comprehensive
- [ ] File size reasonable (< 50MB)

---

## Output

**Final artifacts:**
- `technical-report.html` — Rendered report
- `technical-report.pdf` — Optional PDF
- `figures/` — Extracted high-res plots
- `README.md` — Reproduction instructions

**Workflow complete!** Return to Marie's menu.
