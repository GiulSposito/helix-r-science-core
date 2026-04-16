# Quarto Skill - Professional R Document Publishing

Expert Quarto document creation and publishing with R - comprehensive skill for creating reports, dashboards, presentations, websites, and books.

## Overview

This skill provides complete support for Quarto with R, including:

- **Reports**: Analytical documents in HTML, PDF, and Word formats
- **Dashboards**: Interactive data dashboards with value boxes and visualizations
- **Presentations**: Professional RevealJS slides
- **Websites & Blogs**: Complete websites with R-powered content
- **Books**: Technical manuscripts and documentation

## Skill Activation

This skill activates automatically when you:

- Work with `.qmd` files
- Mention "quarto report", "quarto dashboard", "quarto presentation"
- Discuss "criar relatório", "renderizar quarto", "publicar quarto"
- Ask about reproducible research, data storytelling, or scientific writing with R

You can also invoke manually:
```bash
/quarto
```

## File Structure

```
.claude/skills/quarto/
├── SKILL.md                      # Main skill logic (416 lines)
├── README.md                     # This file
│
├── templates/                    # Document templates
│   ├── report-template.qmd       # Analytical report
│   ├── dashboard-template.qmd    # Interactive dashboard
│   ├── presentation-template.qmd # RevealJS presentation
│   ├── website-quarto.yml        # Website configuration
│   └── book-quarto.yml           # Book configuration
│
├── examples/                     # Complete working examples
│   ├── complete-report.qmd       # Full report with analysis
│   ├── dashboard-example.qmd     # Interactive dashboard
│   ├── presentation-example.qmd  # Complete presentation
│   └── website-structure.md      # Website setup guide
│
└── references/                   # Detailed documentation
    ├── yaml-options.md           # YAML frontmatter reference
    ├── chunk-options.md          # Code chunk options
    ├── r-integration.md          # R package integration
    ├── dashboards.md             # Comprehensive dashboard patterns
    └── publishing.md             # Publishing workflows
```

**Total**: 14 files, ~7,000 lines of comprehensive documentation and examples

## What This Skill Provides

### 1. Complete Workflow Support

The skill guides you through:
- Requirements gathering (document type, format, R integration)
- Structure selection (templates for each document type)
- Content generation (YAML, code chunks, visualizations)
- Preview and rendering
- Publishing to various platforms

### 2. Document Type Expertise

**Reports**:
- Single and multi-format output (HTML, PDF, Word)
- Code folding and hiding
- Cross-references to figures and tables
- Professional tables with gt and knitr
- Parameterized reports for reproducibility

**Dashboards**:
- Value boxes with metrics
- Row and column layouts
- Interactive visualizations (plotly, DT)
- Optional Shiny integration
- Multiple pages with navigation

**Presentations**:
- RevealJS slides with themes
- Incremental content and fragments
- Code with output in slides
- Speaker notes
- Multiple column layouts

**Websites & Blogs**:
- Complete site structure with navigation
- Blog listings with RSS feeds
- Search functionality
- Responsive design

**Books**:
- Multi-chapter organization
- Part/chapter structure
- Cross-references across chapters
- Multiple output formats

### 3. R Integration Patterns

Complete coverage of:
- **Visualization**: ggplot2, plotly, leaflet
- **Tables**: gt, knitr::kable, DT, reactable
- **Interactive**: Shiny, htmlwidgets
- **Data**: tidyverse integration
- **Statistics**: Model integration and reporting

### 4. Reference Documentation

Comprehensive references for:
- All YAML frontmatter options
- Complete code chunk options
- R package integration patterns
- Publishing workflows for all platforms

## Usage Examples

### Creating a Report

```bash
# Skill activates automatically
"Create a quarto report analyzing sales data"

# Or invoke manually
/quarto
```

The skill will:
1. Ask about report requirements (format, R packages, code visibility)
2. Create .qmd file with appropriate template
3. Set up YAML frontmatter
4. Add code chunks with proper options
5. Guide through rendering and preview

### Creating a Dashboard

```bash
"Build a quarto dashboard showing KPIs and trends"
```

The skill provides:
- Dashboard template with value boxes
- Layout guidance (rows/columns)
- Interactive visualizations
- Data table integration

### Publishing to GitHub Pages

```bash
"Help me publish this quarto website to GitHub Pages"
```

The skill covers:
- `_quarto.yml` configuration
- GitHub Actions setup
- Custom domain configuration
- Troubleshooting deployment issues

## Key Features

### ✅ Comprehensive Coverage

- All document types (reports, dashboards, presentations, websites, books)
- All output formats (HTML, PDF, Word, RevealJS)
- Complete R integration (tidyverse, ggplot2, shiny, tables)

### ✅ Production-Ready Templates

- Working templates for each document type
- Proper YAML configuration
- Best practices built-in
- Ready to customize

### ✅ Complete Examples

- Full working examples (not just snippets)
- Real R code with actual datasets
- Multiple visualization types
- Professional formatting

### ✅ Detailed References

- Searchable documentation
- Organized by category
- Code examples for each feature
- Troubleshooting guides

### ✅ Publishing Support

- Multiple platforms (Quarto Pub, GitHub Pages, Netlify, Posit Connect)
- GitHub Actions workflows
- CI/CD best practices
- Deployment troubleshooting

## Technical Details

**Allowed Tools**:
- `Read`, `Write`, `Edit` - File operations
- `Bash(quarto *)` - Quarto CLI commands
- `Bash(Rscript *)` - R script execution

**Invocation**:
- Auto-invokes when working with Quarto
- User-invocable via `/quarto`
- Triggers on PT-BR and EN keywords

**Integration**:
- Works alongside other R skills (ggplot2, tidyverse-expert, r-datascience)
- Complements r-shiny for interactive documents
- Compatible with r-package-development for vignettes

## Quick Start

1. **Create a simple report**:
   ```bash
   "Create a quarto report with mtcars analysis"
   ```

2. **Build a dashboard**:
   ```bash
   "Build a dashboard showing sales metrics"
   ```

3. **Make a presentation**:
   ```bash
   "Create a quarto presentation about data analysis"
   ```

4. **Set up a website**:
   ```bash
   "Help me create a data science blog with quarto"
   ```

## Tips for Best Results

### Be Specific About Requirements

✅ Good: "Create a quarto report in HTML format with code hidden, using ggplot2 for visualizations"

❌ Vague: "Make a report"

### Mention Your R Packages

The skill optimizes for packages you mention:
- "using tidyverse and gt tables"
- "with plotly interactive plots"
- "integrate shiny for interactivity"

### Specify Output Format

- "HTML with code folding"
- "PDF for print"
- "Word for editing"
- "RevealJS presentation"

## Troubleshooting

### Skill Doesn't Activate

Try these trigger phrases:
- "quarto report"
- "criar relatório quarto"
- "quarto dashboard"
- "renderizar documento quarto"

### Need Specific Reference

Access references directly:
- YAML options: See `references/yaml-options.md`
- Chunk options: See `references/chunk-options.md`
- R integration: See `references/r-integration.md`
- Publishing: See `references/publishing.md`

### Want a Template

Request by type:
- "show me the report template"
- "use the dashboard template"
- "start from the presentation template"

## Version History

### v1.0.0 (2024-03-11)
- Initial comprehensive release
- Complete coverage of Quarto features for R
- All document types supported
- Templates, examples, and references included
- Publishing workflows documented

## Related Skills

This skill works well with:

- **r-datascience**: Data analysis workflows
- **ggplot2**: Advanced visualization
- **tidyverse-expert**: Data manipulation
- **r-shiny**: Interactive applications
- **r-package-development**: Package vignettes
- **r-style-guide**: Code formatting

## Resources

**Skill Files**:
- Main logic: `SKILL.md`
- Templates: `templates/`
- Examples: `examples/`
- References: `references/`

**External**:
- Official Quarto: https://quarto.org
- R with Quarto: https://quarto.org/docs/computations/r.html
- Gallery: https://quarto.org/docs/gallery/

## Support

For issues or improvements:
1. Check the reference documentation first
2. Review examples for similar use cases
3. Consult Quarto official documentation
4. Ask Claude for specific help with this skill

---

**Created**: 2024-03-11
**Version**: 1.0.0
**Scope**: Quarto with R (excludes Python/Julia)
**Lines**: ~7,000 across 14 files
**Status**: Production-ready ✅
