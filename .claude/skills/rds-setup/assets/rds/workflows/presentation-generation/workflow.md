---
name: presentation-generation
description: Create Quarto reveal.js slides for stakeholder presentations
installed_path: '{project-root}/_bmad/rds/workflows/presentation-generation'
---

# Presentation Generation Workflow

**Module:** RDS (R Data Science)
**Owner:** Marie (The Reporter)
**Status:** Active
**Duration:** 4-8 hours

---

## Workflow Overview

**Goal:** Transform reports into engaging reveal.js presentations for stakeholder delivery

**Description:** Generate professional slide decks using Quarto reveal.js. Reuses content from technical and executive reports, optimizing for oral presentation format. Emphasizes visual hierarchy, speaker notes, and audience engagement.

**Workflow Type:** Core — Single-step transformation

---

## Activation Sequence

<activation>

### Step 1: Welcome & Context

**Output:**
```
╔══════════════════════════════════════════════════════════════╗
║          PRESENTATION GENERATION WORKFLOW                    ║
║        From Reports to Engaging Slide Decks                  ║
╚══════════════════════════════════════════════════════════════╝

Marie here! Let's transform your insights into a compelling presentation.

This workflow will:
  • Reuse content from existing reports (technical/executive)
  • Optimize visualizations for slide format
  • Create narrative flow for oral delivery
  • Generate reveal.js slides with Quarto
  • Add speaker notes and transitions

Presentation styles available:
  • Executive Pitch (10-15 min, high-level)
  • Technical Deep Dive (30-45 min, methodology)
  • Progress Update (20-30 min, status)
  • Results Showcase (15-20 min, findings)

Duration: 4-8 hours

Let's make your data tell a story!
```

### Step 2: Execute Presentation Generation

**Process:**

1. **Gather Source Material**
   - Load executive-report.qmd (primary source)
   - Load technical-report.qmd (for technical versions)
   - Collect key visualizations from reports
   - Identify narrative arc

2. **Define Presentation Structure**
   - Opening: Hook and context (1-2 slides)
   - Body: Key insights with visuals (8-12 slides)
   - Conclusion: Recommendations and next steps (2-3 slides)
   - Total: 12-18 slides (rule: 1 slide per minute + buffer)

3. **Optimize Content for Slides**
   - Large text (readable from distance)
   - One idea per slide (cognitive load)
   - Minimal bullet points (speaker explains)
   - Visual > text (show don't tell)
   - Progressive reveal for complex content

4. **Generate Quarto Slides**
   - Create presentation.qmd with reveal.js format
   - Add speaker notes (what to say for each slide)
   - Configure transitions and animations
   - Set up custom theme (branding if needed)

5. **Review & Refine**
   - Render slides to HTML
   - Practice delivery timing
   - Verify all visuals are legible
   - Test on presentation hardware

### Step 3: Completion

**Output:**
```
╔══════════════════════════════════════════════════════════════╗
║            PRESENTATION READY!                               ║
╚══════════════════════════════════════════════════════════════╝

Your slide deck is complete!

Generated artifacts:
  • presentation.qmd — Quarto source with speaker notes
  • presentation.html — reveal.js slides (self-contained)
  • figures/ — Optimized slide visualizations
  • presentation.pdf — Optional PDF export (handout)

Presentation structure:
  ✓ Opening (context and hook)
  ✓ Key Insights (visual-first narrative)
  ✓ Supporting Evidence (methodology/data)
  ✓ Recommendations (actionable next steps)
  ✓ Closing (summary and Q&A prompt)

Features:
  • Responsive HTML slides (any device)
  • Speaker view with notes and timer
  • Keyboard/remote navigation
  • PDF export for handouts

Next steps:
  • Practice delivery with timer
  • Prepare Q&A responses
  • Test on presentation setup

Break a leg! 🎤
```

</activation>

---

## Workflow Properties

**Input Requirements:**
- Report content (executive-report.qmd or technical-report.qmd)
- Presentation duration target
- Audience profile (technical/executive/mixed)

**Optional Inputs:**
- Brand guidelines (theme, colors, fonts)
- Company logo and styling
- Presentation deadline

**Outputs:**
- `presentation.qmd` — Quarto source with speaker notes
- `presentation.html` — Self-contained reveal.js slides
- `presentation.pdf` — Optional PDF for handouts
- `figures/` — Slide-optimized visualizations

---

## Agent Integration

**Primary Agent:** Marie (The Reporter)
- Transforms report content into slide format
- Designs narrative flow for oral delivery
- Optimizes visuals for presentation

**Supporting Agents:**
- **Alan** — Provides model performance visuals
- **Grace** — Provides key insight visualizations
- **Tim** — Provides deployment status (if relevant)

---

## Implementation Notes

**Philosophy:**
- Slides support the speaker, not replace them
- Visual hierarchy guides attention
- One idea per slide (no walls of text)
- Narrative arc creates engagement
- Speaker notes capture full context

**Presentation Styles:**

**Executive Pitch (10-15 min):**
- 10-12 slides
- Business impact focus
- Large visuals, minimal text
- Clear recommendations
- Q&A time reserved

**Technical Deep Dive (30-45 min):**
- 25-35 slides
- Methodology details
- Code snippets OK (readable size)
- Statistical rigor shown
- Appendix for extra details

**Progress Update (20-30 min):**
- 15-20 slides
- Status of each phase
- Blockers and solutions
- Next milestones
- Team coordination

**Best For:**
- Conference talks
- Board presentations
- Team updates
- Client deliveries

**Not Ideal For:**
- Detailed documentation (use technical-report)
- Self-service exploration (use dashboard)
- Email updates (use executive-report)

---

## Technical Requirements

**R Packages:**
- Core: tidyverse, here
- Reporting: quarto, rmarkdown
- Visualization: ggplot2 (slide-optimized themes)

**Quarto reveal.js Features:**
- Slide transitions and animations
- Speaker view (notes + timer)
- Keyboard/remote navigation
- Code syntax highlighting
- PDF export via print-to-PDF
- Custom themes and styling

**Presentation Best Practices:**
- Font size: Minimum 24pt for body text
- Contrast: High contrast for readability
- Images: High resolution (retina displays)
- Animations: Subtle, purposeful only
- Backup: PDF version as fallback

**Expected Duration:**
- Content transformation: 2-3 hours
- Visual optimization: 1-2 hours
- Slide generation: 1-2 hours
- Practice & refinement: 1-2 hours

---

_Workflow created on 2026-03-26 for RDS Module v0.2.0_
