# Step 1: Design Dashboard

**Workflow:** build-dashboard
**Phase:** UX Design & Architecture
**Duration:** 4-8 hours

---

## Objective

Define dashboard purpose, KPIs, layout, user interactions, and information architecture.

---

## Instructions

Act as Marie with UX design focus. Design a dashboard users will actually enjoy using.

### 1. Define Dashboard Purpose

Clarify with user:
- **Primary use case** — Exploration? Reporting? Monitoring?
- **Target users** — Analysts? Executives? Operations team?
- **Update frequency** — Real-time? Daily? On-demand?
- **Access pattern** — Self-service? Scheduled sharing?

### 2. Identify KPIs

What metrics matter most?
- **Core KPIs** (3-5 max) — Top-level metrics displayed prominently
- **Supporting metrics** — Drill-down details
- **Contextual info** — Comparison periods, targets, thresholds

Create visual hierarchy: KPI cards → trend charts → detail tables

### 3. Design Layout

Sketch dashboard structure:

**Header:**
- Dashboard title
- Last updated timestamp
- Filters (date range, categories, etc.)

**Body (Tab-based or Single-page):**
- Tab 1: Overview (KPI cards + trends)
- Tab 2: Deep Dive (interactive plots)
- Tab 3: Data Explorer (filterable table)
- Tab 4: About (methodology, contacts)

**Sidebar (Optional):**
- Global filters
- Data refresh button
- Export controls

### 4. Define Interactivity

Map user interactions:
- **Filters** — What dimensions can users slice by?
- **Drill-downs** — Click KPI → see detail view
- **Hover tooltips** — Additional context on plots
- **Downloads** — Export plots/data as CSV/PNG

### 5. Create Wireframe

Document in `dashboard-design.md`:
- ASCII or markdown wireframe
- Component placement
- Color scheme (match branding)
- Responsive breakpoints (mobile/tablet/desktop)

---

## Validation Checklist

Before proceeding to Step 2:
- [ ] Dashboard purpose clear
- [ ] KPIs identified (3-5 core metrics)
- [ ] Layout designed with wireframe
- [ ] Interactivity mapped
- [ ] User approved design

---

## Output

**Files created:**
- `dashboard-design.md` — Complete design specification

**Next:** Proceed to Step 2 (Build Application)
