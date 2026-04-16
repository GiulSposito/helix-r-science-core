# ggplot2 Skill - Expert Data Visualization in R

Comprehensive Claude Code skill for mastering ggplot2 data visualization in R. This skill provides expert guidance on the grammar of graphics, geoms, themes, scales, and best practices for creating publication-ready plots.

## Overview

This skill transforms Claude Code into a ggplot2 expert that can:
- Generate complete, runnable ggplot2 code following best practices
- Provide detailed explanations of the grammar of graphics
- Suggest appropriate plot types for different data and questions
- Create publication-ready, accessible visualizations
- Optimize plots for performance and clarity
- Apply colorblind-safe palettes and proper formatting

## Skill Structure

```
.claude/skills/ggplot2/
├── SKILL.md                              # Main skill (auto-loaded)
├── README.md                             # This file
├── references/
│   ├── geoms-reference.md               # Complete geom documentation (~550 lines)
│   ├── themes-styling.md                # Themes, colors, scales (~700 lines)
│   ├── scales-reference.md              # Detailed scale documentation (~500 lines)
│   └── best-practices.md                # Patterns, anti-patterns, tips (~900 lines)
├── examples/
│   ├── plot-examples.md                  # Working examples for all plot types (~1,100 lines)
│   ├── gallery-distribution-correlation.md # R Graph Gallery: Distribution & Correlation (~1,100 lines)
│   ├── gallery-evolution-ranking.md      # R Graph Gallery: Evolution & Ranking (~1,100 lines)
│   └── gallery-best-practices.md         # R Graph Gallery: 15 Curated Examples (~940 lines)
└── templates/
    └── plot-templates.md                # Reusable templates (~900 lines)
```

**Total: ~9,700 lines of comprehensive ggplot2 knowledge** (nearly doubled with R Graph Gallery integration!)

## Content Sources

This skill is based on authoritative ggplot2 documentation and real-world examples:
- **ggplot2 Reference**: https://ggplot2.tidyverse.org/ - Complete function reference
- **ggplot2 Book** (3rd Edition): https://ggplot2-book.org/ - Grammar of graphics theory and best practices
- **R Graph Gallery**: https://r-graph-gallery.com/ - Real-world examples and advanced techniques

## Features

### Core Capabilities

✅ **Grammar of Graphics** - Deep understanding of ggplot2's layered system
✅ **All Major Geoms** - Point, line, bar, histogram, boxplot, violin, smooth, text, etc.
✅ **Complete Theme System** - 8 built-in themes + full customization
✅ **Color Scales** - Viridis, ColorBrewer, gradients (all colorblind-safe)
✅ **Faceting** - facet_wrap() and facet_grid() strategies
✅ **Statistical Layers** - Smooth, summary, density, contours
✅ **Annotations** - Text, labels, reference lines, highlighting
✅ **Best Practices** - Accessibility, publication standards, performance

### R Graph Gallery Integration (NEW!)

**+4,650 lines** of advanced real-world techniques added from the R Graph Gallery:

**Distribution & Correlation** (~1,100 lines):
- Violin + boxplot combinations (14:1 ratio technique)
- Ridgeline plots with ggridges
- Smart label positioning with ggrepel
- Marginal distributions with ggMarginal
- Hexbin for massive datasets
- Dumbbell charts for comparisons
- GGally ggpairs for comprehensive views

**Evolution & Ranking** (~1,100 lines):
- gghighlight for context highlighting
- End-of-line labels with direction constraints
- Geofaceting with geofacet package
- Lollipop and dumbbell charts
- Circular barplots with coord_polar
- Publication styling (The Economist patterns)
- Interactive with plotly and ggiraph

**Advanced Customization** (~500 lines):
- Multi-layered emphasis strategies
- 2,500+ palettes with paletteer
- Multiple color scales with ggnewscale
- Custom fonts (showtext, ragg)
- HTML/markdown formatting with ggtext
- Mathematical expressions and shadowtext
- Curved annotations with geom_curve()

**Best Practices from Curated Examples** (~940 lines):
- 15 publication-quality examples analyzed
- Sophisticated composition with patchwork
- Conditional highlighting techniques
- Inline HTML legends with ggtext
- coord_cartesian(clip="off") for label overflow
- Quantile binning strategies
- Multi-layer statistical visualization

### Knowledge Depth

**Geoms** (8 major + specialties):
- geom_point(), geom_line(), geom_bar(), geom_col()
- geom_histogram(), geom_density(), geom_freqpoly()
- geom_boxplot(), geom_violin()
- geom_smooth(), geom_text(), geom_label()
- geom_ribbon(), geom_area(), geom_errorbar()
- geom_tile(), geom_hex(), geom_contour()
- Plus reference lines (hline, vline, abline)

**Themes**:
- 8 complete built-in themes
- Full element customization (text, line, rect, blank)
- Theme inheritance system
- Publication-ready configurations

**Color Scales**:
- Viridis family (8 options, all colorblind-safe)
- ColorBrewer (sequential, diverging, qualitative)
- Gradients (2-color, 3-color diverging, n-color custom)
- Manual scales with accessibility guidance

**Advanced Topics**:
- Tidy evaluation for programming with ggplot2
- Patchwork for multi-panel figures
- Position adjustments (dodge, stack, jitter)
- Coordinate systems (cartesian, fixed, flip, polar)
- Statistical transformations
- Out-of-bounds handling

## How It Works

### Auto-Triggering

The skill **automatically activates** when Claude detects:
- User mentions "ggplot", "ggplot2", "geom_*"
- Working with R visualization code
- Questions about plot customization, themes, or styling
- Requests for data visualization in R

**Configuration**: `user-invocable: false` means it works as background knowledge, not a manual command.

### Tool Restrictions

`allowed-tools: Read, Write, Edit, Grep, Glob`

The skill can read/write files and search code, but focuses on providing expert guidance rather than executing R code.

## Usage Examples

### Automatic Activation

The skill automatically provides expert guidance:

```
User: "How do I create a scatter plot with ggplot2?"
→ Skill activates, provides complete example with best practices

User: "Make this plot colorblind-safe"
→ Skill suggests Viridis palette with redundant encoding

User: "How do I customize the theme?"
→ Skill explains theme system with practical examples
```

### What You Get

**Complete Code**: Runnable examples, not just snippets
**Best Practices**: Colorblind-safe, accessible, optimized
**Explanations**: Why choices were made, when to use alternatives
**References**: Links to detailed documentation for deeper dives

## Key Principles Taught

### Grammar of Graphics

Every plot has 5 independent components:
1. **Layers** - Data + geoms + stats
2. **Scales** - Data → aesthetics + guides
3. **Coordinates** - Position transformations
4. **Facets** - Small multiples
5. **Themes** - Non-data appearance

### Best Practices

**Common Mistakes Avoided**:
- ❌ `aes(colour = "blue")` → ✅ `colour = "blue"` (outside aes)
- ❌ `scale limits` → ✅ `coord_cartesian()` (for zoom)
- ❌ Default binwidth → ✅ Explicit `binwidth` parameter
- ❌ Rainbow palette → ✅ Viridis (colorblind-safe)

**Golden Rules**:
1. Inside aes() = variables, outside = fixed values
2. coord_cartesian() for zoom (preserves data)
3. Always set binwidth explicitly
4. Use colorblind-safe palettes (Viridis first choice)
5. Provide redundant encoding (color + shape)
6. Direct labeling > legends
7. Aggregate before plotting large data
8. Vector formats (PDF/SVG) for publication

## File Descriptions

### SKILL.md (Main File)
- Grammar of graphics overview
- Core workflow and common mistakes
- Quick reference for all major components
- Links to detailed references

### references/geoms-reference.md
- Complete documentation of all major geoms
- Required/optional aesthetics for each
- Key parameters and use cases
- Code examples for each geom
- Selection guide by purpose

### references/themes-styling.md
- 8 built-in themes with use cases
- Complete theme customization system
- All element functions (text, line, rect, blank)
- Color scale systems (Viridis, ColorBrewer, gradients)
- Scale customization (breaks, labels, limits)
- Best practices for accessibility

### references/scales-reference.md
- Position scales (continuous, discrete, date/time)
- Transformations (log, sqrt, reverse)
- Color/fill scales (all types)
- Size, shape, alpha, linetype scales
- Guide customization (legends, colorbars, axes)
- Secondary axes and out-of-bounds handling

### references/best-practices.md
- Visualization principles (layer purpose, grammar philosophy)
- Common mistakes explained
- Aesthetic mapping strategies
- Color accessibility guidelines
- Faceting strategy (when to facet vs aesthetic)
- Annotation techniques
- Programming patterns (tidy evaluation)
- Performance optimization
- Publication workflow

### examples/plot-examples.md
- Complete working examples for all major plot types:
  - Scatter plots (basic, grouped, with smooth, bubble, dense)
  - Line plots (time series, multiple series, with ribbons)
  - Bar charts (counts, values, grouped, stacked, horizontal)
  - Distributions (histogram, density, overlapping)
  - Statistical summaries (boxplot, violin, combinations)
  - Faceted plots (wrap, grid, free scales)
  - Heatmaps and 2D density
  - Complex multi-layer plots
  - Publication-ready figures

### templates/plot-templates.md
- Copy-paste templates for 15+ plot types
- Placeholder variables for easy customization
- Quick customization guide
- Save/export templates
- Reusable function templates

## Installation

### Project-Level (Default)

The skill is available in this project automatically when placed in `.claude/skills/ggplot2/`.

### System-Wide Installation

To make the skill available in **all projects**:

```bash
# Copy to global Claude skills directory
cp -r .claude/skills/ggplot2 ~/.claude/skills/
```

Now the skill will be available in any project where you use Claude Code.

## Validation Checklist

✅ Valid YAML frontmatter
✅ Clear, trigger-rich description (7+ trigger phrases)
✅ Appropriate tool restrictions (Read, Write, Edit, Grep, Glob)
✅ All file references exist and are correct
✅ Comprehensive coverage (5,000+ lines)
✅ Examples are complete and runnable
✅ Best practices integrated throughout
✅ Colorblind-safe palettes prioritized
✅ Publication-ready guidance included

## Content Statistics

- **Main SKILL.md**: ~450 lines
- **Geoms Reference**: ~550 lines
- **Themes & Styling**: ~700 lines
- **Scales Reference**: ~500 lines
- **Best Practices**: ~900 lines
- **Plot Examples**: ~1,100 lines
- **Templates**: ~850 lines

**Total: 5,050+ lines of expert ggplot2 knowledge**

## Coverage Summary

### Geoms Documented
✅ Point, line, path, step
✅ Bar, col, histogram, freqpoly
✅ Density, boxplot, violin
✅ Smooth, text, label
✅ Area, ribbon, errorbar, linerange, pointrange
✅ Tile, raster, hex, bin2d
✅ Contour, polygon
✅ Reference lines (hline, vline, abline)

### Scales Documented
✅ Position (continuous, discrete, date/time, transformed)
✅ Color/fill (Viridis, ColorBrewer, gradients, manual)
✅ Size (continuous, binned, discrete, area-based)
✅ Shape, alpha, linetype
✅ Guides (legends, colorbars, axes)
✅ Limits, breaks, labels, expansions
✅ Out-of-bounds handling

### Themes Documented
✅ 8 complete built-in themes
✅ All element types (text, line, rect, blank)
✅ All theme components (plot, panel, axis, legend, facet)
✅ Theme inheritance system
✅ Global theme settings

### Best Practices Covered
✅ Grammar of graphics principles
✅ Common mistakes and fixes
✅ Colorblind accessibility
✅ Faceting strategies
✅ Annotation techniques
✅ Programming patterns
✅ Performance optimization
✅ Publication workflow

## Troubleshooting

### Skill Not Auto-Triggering

Try mentioning these keywords:
- "ggplot2", "ggplot"
- "geom_point", "geom_line", etc.
- "plot customization"
- "data visualization in R"
- "themes and styling"

### Need More Detail

All sections include cross-references to detailed documentation:
- Main SKILL.md → references/ for deep dives
- references/ → examples/ for working code
- examples/ → templates/ for copy-paste starting points

## Version History

### v1.0.0 (2026-03-08)
- Initial release
- Comprehensive coverage of ggplot2.tidyverse.org reference
- Deep integration of ggplot2-book.org best practices
- 5,050+ lines of expert documentation
- Complete examples and templates
- Publication-ready guidance

## Credits

**Content Sources**:
- ggplot2 package: Hadley Wickham et al.
- ggplot2 Book (3rd Edition): Hadley Wickham, Danielle Navarro, Thomas Lin Pedersen
- ggplot2 Reference Documentation: https://ggplot2.tidyverse.org/

**Skill Development**:
- Created with Claude Code skillMaker
- Structured for optimal context efficiency
- Designed for both beginners and experts

## License

This skill documentation follows the same license as ggplot2 (MIT). The skill itself (skill structure and organization) is provided as-is for use with Claude Code.

## Support

For issues or suggestions:
1. Check the comprehensive references/ directory
2. Review examples/ for working code
3. Consult templates/ for starting points
4. Refer to the ggplot2 official documentation for the latest updates

---

**Ready to create beautiful, accessible, publication-ready visualizations with ggplot2!**
