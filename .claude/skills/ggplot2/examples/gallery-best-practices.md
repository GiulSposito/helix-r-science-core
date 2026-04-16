# Best R Graph Gallery Examples: Advanced ggplot2 Patterns

## Overview
Analysis of 15 curated examples from [R Graph Gallery's Best R Charts](https://r-graph-gallery.com/best-r-chart-examples.html) collection, focusing on advanced techniques, creative solutions, and production-quality patterns.

---

## Key Themes Across Best Examples

### 1. **Sophisticated Composition**
- **Patchwork** for multi-plot layouts with precise positioning
- **inset_element()** for overlaying secondary visualizations
- **plot_grid()** from cowplot for structured arrangements
- Combining different chart types (maps + barplots, ridgelines + legends)

### 2. **Advanced Text & Annotations**
- **ggtext** package for HTML-formatted text (`element_textbox_simple()`)
- **ggrepel** for automatic label positioning without overlaps
- **shadowtext** for readable labels over complex backgrounds
- Inline legends using colored text in subtitles
- Strategic use of `coord_cartesian(clip = "off")` for label overflow

### 3. **Color Psychology & Hierarchy**
- Conditional coloring for highlighting specific elements
- Muted backgrounds (gray) with bold foreground colors
- Color palettes that match narrative (energy types, political parties)
- Quantile-based color scales for equal visual weight
- `na.value` specifications for missing data handling

### 4. **Custom Theme Mastery**
- Starting with `theme_minimal()` or `theme_void()` and building up
- Selective removal/addition of theme elements
- Custom font integration via **showtext** package
- Consistent typography across complex multi-plot compositions
- Strategic whitespace and margin control

### 5. **Data Storytelling Elements**
- Temporal annotations marking key events (vaccine introduction, policy changes)
- Reference lines and shaded regions for statistical context
- Embedded explanatory visualizations (distribution legends)
- Strategic highlighting while maintaining full context

---

## Example 1: Waffle Chart for Energy Mix Evolution
**Creator:** Guillaume Noblet
**URL:** https://r-graph-gallery.com/web-waffle-chart-for-evolution-of-energy-mix.html

### What Makes It Excellent
- Transforms temporal change into intuitive square-grid visualization
- Embedded legend in subtitle using colored HTML text
- Strategic annotation highlighting nuclear expansion in 1970s

### Key Techniques
```r
# Core packages
waffle, ggtext, patchwork, showtext

# Critical functions
geom_waffle(n_rows = 5, flip = TRUE)
facet_wrap(~decade_chr, nrow = 1, strip.position = "bottom")
element_textbox_simple() # HTML formatting in themes
inset_element() # Layering annotations over main plot
geom_curve() # Arrow annotations

# Data preparation
- Integer percentage rounding ensuring each decade = 100%
- make_proportional = FALSE to preserve absolute values

# Design pattern
- Manual color palette mapping energy types to representative colors
- Inline legend using glue::glue() with HTML <span> styling
- Custom font (Roboto Condensed) throughout
```

### Lessons Learned
- Color psychology matters: assign meaningful colors to categories
- Inline legends reduce cognitive load compared to separate legends
- Data integrity (sum to 100%) critical for waffle charts
- Annotations should enhance, not clutter, the narrative

---

## Example 2: Choropleth Map with Barplot
**Creator:** Vinicius Oike Reginatto
**URL:** https://r-graph-gallery.com/web-choropleth-barchart-map.html

### What Makes It Excellent
- Addresses "map area bias" by showing population alongside geography
- Consistent color scheme across both visualizations
- Precise positioning using normalized coordinates

### Key Techniques
```r
# Core packages
sf, ggthemes, patchwork

# Map techniques
geom_sf() # Automatic spatial coordinate handling
scale_fill_fermenter() # Binned continuous data with Brewer palettes
theme_map() # Clean geographic visualization

# Combination approach
inset_element(left = 0.50, bottom = 0.05, right = 1, top = 0.5)

# Data binning
findInterval() # Custom breakpoints for HDI values
seq(0.65, 0.95, 0.05) # Matching intervals across visualizations

# Design choices
- Minimal line width (lwd = 0.05) for borders
- White outlines for geographic clarity
- coord_flip() for readable category labels
- geom_text() for strategic value highlighting
```

### Lessons Learned
- Maps alone can mislead due to area bias—complement with statistical views
- Normalized coordinates (0-1) provide precise overlay positioning
- Consistent binning across multiple views maintains cognitive coherence
- Theme stripping (theme_map) focuses attention on data patterns

---

## Example 3: Ridgeline Plot with Inside Plot
**Creator:** Ansgar Wolsing
**URL:** https://r-graph-gallery.com/web-ridgeline-plot-with-inside-plot-and-annotations.html

### What Makes It Excellent
- Embedded legend explains visualization method without external reference
- Multiple statistical layers (density, intervals, medians) combined
- Strategic annotations with connecting curves

### Key Techniques
```r
# Core packages
ggdist, ggtext, patchwork

# Statistical visualization
stat_halfeye() # Density visualization
stat_interval() # Interval representation
stat_summary(geom = "point", fun = median) # Computed statistics

# Embedded legend technique
p_legend <- [filtered data with same layers]
inset_element(p_legend, l = 0.6, r = 1.0, t = 0.99, b = 0.7, clip = FALSE)

# Annotation methods
annotate() # Static text at fixed positions
stat_summary() # Dynamic computed labels
geom_curve(arrow = arrow()) # Visual pointers

# Text formatting
element_textbox_simple() # Styled text blocks
"richtext" annotations # HTML formatting with <br>
```

### Lessons Learned
- Self-documenting visualizations reduce viewer cognitive load
- Combining multiple statistical representations provides richer context
- Filtered data allows consistent styling between main plot and legend
- Dynamic annotations (computed from data) more robust than hardcoded text

---

## Example 4: Bump Chart with Highlights
**Creator:** Matthias Schnetzer
**URL:** https://r-graph-gallery.com/web-bump-plot-with-highlights.html

### What Makes It Excellent
- Strategic muting rather than hiding maintains full context
- Conditional filtering within geom layers enables selective styling
- Clear visual hierarchy through color, size, and label weight

### Key Techniques
```r
# Core packages
ggbump, MetBrewer

# Highlighting strategy
geom_bump(data = ~filter(geo %in% selected), linewidth = 0.8, smooth = 6)
geom_bump(data = ~filter(!geo %in% selected), color = "gray90")

# Color hierarchy
- Highlighted: met.brewer("Juarez") palette
- Muted: "gray90" for context
- Labels: "black" vs "gray50"

# Layered point rendering
- Background points (size 4, white) for all
- Foreground points (size 2) with conditional coloring

# Label positioning
geom_text(data = ~filter(year == 2021), hjust = 0)
```

### Lessons Learned
- Muting > hiding: keeps context while directing attention
- Conditional filtering within geom layers cleaner than multiple datasets
- Layered points with background halos improve readability
- Consistent filtering logic across geoms maintains visual coherence

---

## Example 5: Sankey Diagram with Highlights
**Creator:** Georgios Karamanis
**URL:** https://r-graph-gallery.com/web-sankey-diagram-with-highlight.html

### What Makes It Excellent
- Beautiful color application with targeted highlighting
- Shadow text for readable labels over complex backgrounds
- Flow thickness automatically communicates magnitude

### Key Techniques
```r
# Core packages
ggsankey, shadowtext, tidyverse

# Flow visualization
geom_sankey_bump() # Proportional flow thickness

# Conditional highlighting
fill = if_else(genres %in% c("Drama", "Comedy", "Romance"), genres, NA)
na.value = na_col # Neutral color for de-emphasized flows

# Label positioning
geom_shadowtext() # Enhanced readability
- Extract coordinates from plot build output
- Apply nudge_x offsets and hjust adjustments
```

### Lessons Learned
- Selective highlighting using NA values and na.value parameter
- Shadow text critical for labels over colored backgrounds
- Flow thickness as implicit magnitude indicator
- Extract plot coordinates programmatically for precise label placement

---

## Example 6: Vaccination Impact Heatmap
**Creator:** Ben Moore
**URL:** https://r-graph-gallery.com/vaccination-heatmap.html

### What Makes It Excellent
- Dramatic visual story: disease-dominated reds → post-vaccine blues
- Dual-gradient palette emphasizes severity progression
- Historical annotation anchors the narrative pivot point

### Key Techniques
```r
# Core heatmap structure
geom_tile(width = .9, height = .9, color = "white")

# Color strategy
- 20 steps: cool-to-warm (blues → yellows) for lower values
- 80 steps: orange → red for higher values (500-4000)
- na.value = rgb(246/255, 246/255, 246/255) # Neutral gray

# Axis customization
- States: fct_reorder for logical ordering
- Years: breaks = seq(1930, 2010, by = 10)
- geom_vline(x = 1963) # Vaccine introduction marker

# Narrative annotation
annotate("text", label = "Vaccine introduced", x = 1963, ...)
```

### Lessons Learned
- Non-uniform color gradients can emphasize critical thresholds
- Historical annotations transform data into stories
- Distinct missing data handling prevents misinterpretation
- White borders between tiles improve cell readability

---

## Example 7: NY Times Diverging Barplot
**Creator:** Spencer Schien
**URL:** https://r-graph-gallery.com/web-diverging-bar-plot-recreated-from-nytimes.html

### What Makes It Excellent
- Faithful recreation of professional publication design
- Strategic color extraction from original source
- Clean axis-free design with centered zero point

### Key Techniques
```r
# Core packages
showtext (Google Fonts), glue

# Diverging bars
fill = ifelse(est_change > 0, chart_cols[2], chart_cols[1])
geom_hline(yintercept = 0) # Replaces x-axis

# Color extraction
- Inspect original page elements for hex values
- Orange (#d35400) and teal (#58a497)

# Text annotation layers
geom_text() # Multiple layers for different positions
- Formatted percentages above/below bars
- Category labels near axis
- vjust and y parameters for precision

# Design stripping
theme_void() + selective element additions
coord_cartesian(clip = "off") # Prevent text clipping
```

### Lessons Learned
- Style replication requires color extraction from source
- Multiple geom_text layers cleaner than complex label functions
- theme_void() + selective additions gives precise control
- Zero-centered axis essential for diverging comparisons

---

## Example 8: Choropleth with Quantile Bins
**Creator:** Benjamin Nowak
**URL:** https://r-graph-gallery.com/web-map-choropleth-quantile.html

### What Makes It Excellent
- Quantile binning ensures equal visual weight across categories
- Custom legend shows both color scale and data distribution
- Dark theme creates dramatic visual impact

### Key Techniques
```r
# Core packages
sf, patchwork

# Quantile binning
quantile() # Equal-frequency classes
- 10 decile bins (0.1 intervals)
- Letter grades (A-J) for categories

# SF operations
read_sf() # Load spatial data
st_drop_geometry() # Remove for non-map operations

# Custom legend creation
geom_rect() # Color gradient display
geom_jitter() # Actual data distribution overlay
patchwork # Assemble map + legend

# Theme approach
theme_void() + dark background
- Separate colors: fills, borders, NA values
```

### Lessons Learned
- Quantile binning prevents color clustering in skewed distributions
- Custom legends can combine multiple information types
- Dark backgrounds effective for maps with light colors
- SF package maintains spatial integrity through transformations

---

## Example 9: Chord Diagrams with Small Multiples
**Creator:** Ansgar Wolsing
**URL:** https://r-graph-gallery.com/character-interaction-analysis.html

### What Makes It Excellent
- Small multiples show individual character networks while maintaining structure
- Differential coloring focuses attention without removing context
- Network data preprocessing ensures complete pair coverage

### Key Techniques
```r
# Core packages
circlize, magick

# Chord diagram creation
chordDiagram() # Matrix or data frame input
par(mfrow = c(3, 3)) # 9-panel grid

# Color strategy
- Base palette for character identity
- Focal character: full saturation
- Others: transparent gray (#EEEEEE33)
- Link transparency (0.3) for layered connections

# Network data structure
- Text tokenization → character extraction
- Filter top-10 characters
- Count occurrences
- complete() ensures all pairs exist

# Design choices
- Consistent margins and font sizing
- Simplified annotation tracks
- White link borders reduce collision
- link.largest.ontop = TRUE
- magick package for final title overlay
```

### Lessons Learned
- Small multiples effective for network comparisons
- Transparency critical for overlapping chord visualizations
- Data completeness (all pairs) prevents missing connections
- Focal coloring + muted context maintains reference frame

---

## Example 10: Clean Vertical Line Chart
**Creator:** Aman Bhargava
**URL:** https://r-graph-gallery.com/web-vertical-line-chart-with-ggplot2.html

### What Makes It Excellent
- Companion label chart eliminates inline clutter
- Baseline reference (zero line) separates opposing values
- Patchwork layout maintains visual dominance of main chart

### Key Techniques
```r
# Core packages
ggplot2, patchwork

# Line styling
geom_line() # Party advantage tracking
geom_hline(yintercept = 0) # Clear baseline separator

# Companion label chart
geom_text(x = (Start_Year + End_Year) / 2, hjust = 0)

# Patchwork composition
left_chart + right_chart + plot_layout(widths = c(8, 1))

# Theme refinement
theme_minimal() base
panel.grid.minor.x = element_blank()
element_text(color = "#7A7A7A") # Axis styling
margin(15, 0, 15, 0) # Precise spacing

# Transformation
coord_flip() # Horizontal → vertical timeline
```

### Lessons Learned
- Separate label charts reduce main plot clutter
- Patchwork widths parameter controls visual hierarchy
- Baseline separators critical for diverging time series
- coord_flip() effective for vertical timeline orientation

---

## Example 11: Waffle for Time Evolution
**Creator:** Muhammad Azhar
**URL:** https://r-graph-gallery.com/web-waffle-for-time-evolution.html

### What Makes It Excellent
- Intuitive square-based representation of counts
- Side-by-side temporal comparison reveals patterns
- Each square represents meaningful unit

### Key Techniques
```r
# Core packages
waffle, MetBrewer

# Implementation
geom_waffle() # Fill mapped to categories, values to counts

# Data transformation
filter() → select() → count() # Aggregate pipeline

# Faceting
facet_wrap(~year, nrow = 1, strip.position = "bottom")

# Color coding
MetBrewer::scale_fill_met_d() # Categorical palette

# Proportion visualization
n_rows = 10 # Controls grid density
```

### Lessons Learned
- Waffle charts excel at showing categorical proportions over time
- Horizontal faceting ideal for temporal progression
- Grid density (n_rows) affects readability vs precision tradeoff
- Count aggregation must happen before visualization

---

## Example 12: Double Ridgeline Plot
**Creator:** Laura Navarro Soler
**URL:** https://r-graph-gallery.com/web-double-ridgeline-plot.html

### What Makes It Excellent
- Side-by-side comparison enables direct pattern identification
- Statistical annotations highlight key peaks
- Consistent styling across paired plots

### Key Techniques
```r
# Core packages
ggridges, cowplot

# Ridgeline creation
geom_ridgeline() # Overlapping density curves

# Separate plots approach
- Female plot: fill = "#05595B"
- Male plot: fill = "#603601"
- plot_grid() for horizontal combination

# Aesthetic mappings
year → x-axis
fct_reorder(name, n) → y-axis
height = n / 50000 # Amplitude control
scale parameter # Ridge spacing

# Statistical annotations
geom_segment() # Connector lines
annotate() # Peak values with context
```

### Lessons Learned
- Separate plots + combination cleaner than faceting for ridgelines
- Height scaling critical for meaningful ridge amplitudes
- Transparency (alpha) essential for overlapping ridges
- Peak annotations add narrative without cluttering

---

## Example 13: Triple Map Composition
**Creator:** Laura Navarro Soler
**URL:** https://r-graph-gallery.com/web-triple-map-into-a-single-chart.html

### What Makes It Excellent
- Visual coherence through consistent styling across three maps
- Unified header/footer frame the composition
- Identical coordinate systems ensure alignment

### Key Techniques
```r
# Core packages
sf, cowplot

# Map overlay
geom_sf() # District boundaries
- Transparent fills, black outlines

# Composition
plot_grid() # Horizontal arrangement
- Header for main title
- Footer for attribution
- Controlled relative heights

# Coordinate handling
- Shared WGS 84 projection
- Longitude/latitude alignment

# Color coherence
- Zone-specific gradient palettes
- Identical hexbin binning (35 bins)
- Shared typography (abril, tawa fonts)
- theme_void() eliminates distractions
```

### Lessons Learned
- Multi-map compositions require strict coordinate system consistency
- Distinct color palettes for different map types prevent confusion
- Unified framing (header/footer) creates professional structure
- theme_void() focuses attention on geographic patterns

---

## Example 14: Circular Barplot
**Creator:** Tobias Stalder
**URL:** https://r-graph-gallery.com/web-circular-barplot-with-R-and-ggplot2.html

### What Makes It Excellent
- Space-efficient comparison of many categories
- Radial label orientation improves readability
- Reference lines provide scale context

### Key Techniques
```r
# Core transformation
coord_polar() # Cartesian → circular

# Axis management
scale_y_continuous(limits = ..., expand = c(0, 0))
- Prevents bars converging at center
- Removes padding

# Label positioning
annotate() # Manual angle adjustments
- Radial orientation calculations

# Color implementation
scale_fill_gradientn() # Sequential palettes
guide_colorsteps() # Discrete legend steps

# Readability
str_wrap() # Break long text
geom_hline() # Reference intervals
Dashed guide segments # Visual hierarchy
```

### Lessons Learned
- coord_polar() simple but requires careful axis setup
- Y-axis limits critical for preventing center convergence
- Manual label positioning necessary for radial layouts
- Discrete color steps clearer than continuous gradients

---

## Example 15: End-of-Line Labels
**Creator:** Cédric Scherer
**URL:** https://r-graph-gallery.com/web-line-chart-with-labels-at-end-of-line.html

### What Makes It Excellent
- ggrepel automates complex label positioning
- Extended axis limits accommodate overflow labels
- Curved connector segments improve clarity

### Key Techniques
```r
# Core packages
ggrepel

# Label positioning
geom_text_repel()
- direction = "y" # Vertical movement only
- xlim = c(2020.8, NA) # Push beyond plot edge
- hjust = 0 # Left alignment

# Overlap avoidance
box.padding = .4 # Space around labels
segment.curvature = -0.1 # Curved connectors
segment.angle = 20 # Angle adjustments

# Line integration
segment.linetype = "dotted" # Visual separation
name_lab = if_else(year == 2020, name, NA) # Conditional display

# Edge handling
limits = c(2000, 2023.5) # Extended x-axis
coord_cartesian(clip = "off") # Visible overflow
```

### Lessons Learned
- ggrepel's automatic positioning saves manual calculation
- Constraining direction prevents horizontal label scatter
- Extended limits + clip="off" necessary for overflow labels
- Curved segments reduce visual collision

---

## Cross-Cutting Advanced Patterns

### Pattern 1: Embedded Visualizations
**Examples:** Energy waffle, Ridgeline with legend, Choropleth + barplot

**Technique:**
```r
patchwork::inset_element(secondary_plot,
                         left = 0.6, right = 1.0,
                         top = 0.99, bottom = 0.7,
                         clip = FALSE)
```

**When to use:** When secondary view explains or complements primary visualization

### Pattern 2: Conditional Highlighting
**Examples:** Bump chart, Sankey diagram, Diverging barplot

**Technique:**
```r
# Within geom layers
geom_*(data = ~filter(condition), color = "highlight")
geom_*(data = ~filter(!condition), color = "gray90")

# Or via aesthetics
fill = if_else(category %in% selected, category, NA)
```

**When to use:** Focus attention while maintaining full context

### Pattern 3: Custom Legends
**Examples:** Energy waffle (inline), Quantile map (distribution), Ridgeline (embedded)

**Technique:**
```r
# Inline legend in subtitle
subtitle = glue::glue("Text with <span style='color:{color}'>colored</span> words")
theme(plot.subtitle = element_textbox_simple())

# Separate legend plot
p_legend <- ggplot(...) + geom_rect() + geom_jitter()
patchwork composition
```

**When to use:** When standard legends don't convey necessary context

### Pattern 4: Multi-Layer Statistical Annotations
**Examples:** Ridgeline (density+intervals+medians), Dumbbell (mean+SD)

**Technique:**
```r
stat_halfeye() +
stat_interval() +
stat_summary(geom = "point", fun = median) +
geom_vline(xintercept = mean_value) +
geom_rect(xmin = mean - sd, xmax = mean + sd, alpha = 0.2)
```

**When to use:** Complex data requiring multiple statistical perspectives

### Pattern 5: Publication-Style Theming
**Examples:** NY Times barplot, Vaccination heatmap, Vertical line chart

**Technique:**
```r
theme_minimal() + # or theme_void()
theme(
  text = element_text(family = "custom_font"),
  plot.title = element_text(size = 18, face = "bold"),
  plot.subtitle = element_textbox_simple(margin = margin(...)),
  panel.grid.minor = element_blank(),
  panel.grid.major.x = element_blank(),
  plot.margin = margin(15, 15, 15, 15)
)
```

**When to use:** Production-ready outputs requiring professional polish

### Pattern 6: Strategic Text Overflow
**Examples:** End-of-line labels, Stacked area inline labels, Bump chart

**Technique:**
```r
scale_x_continuous(limits = c(min, max + buffer)) +
coord_cartesian(clip = "off") +
theme(plot.margin = margin(5, 30, 5, 5)) # Extra right margin
```

**When to use:** When labels need space beyond data boundaries

---

## Package Ecosystem for Advanced Work

### Essential Core
- **ggplot2**: Foundation
- **patchwork**: Multi-plot composition with precise control
- **ggtext**: HTML formatting in plot elements

### Text & Labels
- **ggrepel**: Automatic non-overlapping labels
- **shadowtext**: Readable text over complex backgrounds
- **showtext**: Custom font integration

### Specialized Visualizations
- **ggridges**: Ridgeline/joy plots
- **waffle**: Waffle charts
- **ggsankey**: Sankey/alluvial diagrams
- **ggbump**: Bump charts for ranking over time
- **circlize**: Chord diagrams and circular layouts
- **sf**: Spatial/geographic data

### Statistical Extensions
- **ggdist**: Advanced distribution visualizations
- **ggstatsplot**: Statistical plot enhancements

### Color & Design
- **MetBrewer**: Art museum color palettes
- **RColorBrewer**: Classic color schemes
- **ggthemes**: Pre-built professional themes

### Composition & Layout
- **cowplot**: Plot grid arrangements
- **magick**: Image manipulation and annotation

---

## Design Principles from Best Examples

### 1. **Visual Hierarchy**
- Mute context elements (gray) while highlighting focus (color)
- Size variation: larger for important, smaller for context
- Alpha transparency for layered elements
- Strategic font weights (bold titles, regular body)

### 2. **Cognitive Load Reduction**
- Inline legends eliminate eye travel
- Embedded explanatory plots reduce external documentation needs
- Strategic axis removal when not needed
- White space as intentional design element

### 3. **Data Integrity**
- Quantile binning for skewed distributions
- Zero-centered axes for diverging comparisons
- Missing data explicitly styled
- Data transformations maintain interpretability

### 4. **Narrative Focus**
- Temporal annotations mark key events
- Reference lines provide context
- Color choices support story (political parties, energy types)
- Statistical overlays add interpretive layers

### 5. **Technical Excellence**
- Error handling for edge cases (clip="off", extended limits)
- Consistent coordinate systems across compositions
- Precise positioning using normalized coordinates
- Programmatic label extraction for complex layouts

### 6. **Production Quality**
- Custom fonts matching target publication
- Color extraction from original sources for recreations
- Consistent styling across multi-plot compositions
- Attention to margins, padding, alignment

---

## Common Anti-Patterns to Avoid

### ❌ Overlapping Labels Without Resolution
**Problem:** Default geom_text() creates unreadable overlaps
**Solution:** Use ggrepel or strategic filtering to single points

### ❌ Overly Complex Single Plots
**Problem:** Trying to show everything in one visualization
**Solution:** Use patchwork to separate concerns into multiple views

### ❌ Default Legends for Complex Data
**Problem:** Standard legends don't convey sufficient context
**Solution:** Create custom legends, inline legends, or embedded explanatory plots

### ❌ Ignoring Plot Boundaries
**Problem:** Labels get clipped at edges
**Solution:** coord_cartesian(clip = "off") + extended limits + margin adjustments

### ❌ Uniform Color Scales for Skewed Data
**Problem:** Most data compressed into narrow color range
**Solution:** Quantile binning or dual-gradient scales with emphasis thresholds

### ❌ Cluttered Annotations
**Problem:** Too many labels/lines compete for attention
**Solution:** Selective highlighting, conditional display, strategic muting

### ❌ Inconsistent Styling Across Panels
**Problem:** Multi-plot compositions feel disjointed
**Solution:** Define shared theme, consistent fonts/colors, unified margins

---

## Workflow for Creating "Best" Quality Visualizations

### 1. **Data Understanding**
- Identify distribution characteristics (skewed, bimodal, etc.)
- Determine comparison types (temporal, categorical, geographic)
- Note missing data patterns

### 2. **Chart Selection**
- Choose base chart type appropriate for data structure
- Consider combinations (map + barplot, ridgeline + legend)
- Identify if highlighting or small multiples needed

### 3. **Color Strategy**
- Select meaningful colors (political, categorical, sequential)
- Define highlight vs context color hierarchy
- Specify missing data treatment

### 4. **Text & Annotation Planning**
- Determine label placement strategy (inline, end-of-line, separate panel)
- Identify key events or values needing annotation
- Plan legend approach (standard, inline, custom)

### 5. **Theme Development**
- Start with minimal theme (theme_minimal or theme_void)
- Selectively add/remove elements
- Integrate custom fonts if needed
- Define margins and whitespace

### 6. **Composition Assembly**
- Build individual plots with consistent styling
- Use patchwork/cowplot for multi-plot layouts
- Add insets if secondary views needed
- Ensure alignment and spacing

### 7. **Refinement**
- Test label overlap and adjust
- Verify color accessibility
- Check margin clipping
- Validate statistical accuracy

### 8. **Production Polish**
- Final font adjustments
- Margin fine-tuning
- Export at appropriate resolution
- Verify appearance at target size

---

## Key Takeaways

### What Elevates Examples to "Best" Status

1. **Technical Mastery**: Multiple advanced techniques combined smoothly
2. **Design Excellence**: Professional polish with attention to typography, color, whitespace
3. **Narrative Clarity**: Data story immediately apparent
4. **Creative Solutions**: Novel approaches to common problems
5. **Production Ready**: Could appear in major publications as-is

### Most Impactful Techniques

1. **Patchwork composition** - Enables complex multi-view layouts
2. **ggrepel automatic positioning** - Solves labeling challenges elegantly
3. **ggtext HTML formatting** - Professional typography and inline legends
4. **Conditional highlighting** - Focus without losing context
5. **Custom theme building** - Publication-specific styling
6. **coord_cartesian(clip = "off")** - Critical for label overflow
7. **Strategic muting** - Gray context + colored focus
8. **Quantile binning** - Equal visual weight across distributions

### Universal Design Principles

- **Simplicity > Complexity**: Remove elements until you can't anymore
- **Context > Isolation**: Show comparisons and references
- **Story > Data**: Every element should support the narrative
- **Clarity > Decoration**: Function over form, always
- **Consistency > Variation**: Unified styling across compositions

---

## Resources

- **Main Collection**: https://r-graph-gallery.com/best-r-chart-examples.html
- **Individual Tutorials**: Detailed code walkthroughs for each example
- **Package Documentation**: ggplot2, patchwork, ggtext, ggrepel, sf, ggridges
- **Color Palettes**: MetBrewer, RColorBrewer, viridis
- **Font Resources**: Google Fonts via showtext package

---

*Analysis completed: 2026-03-08*
*Total examples analyzed: 15 curated visualizations*
*Focus: Advanced ggplot2 patterns for production-quality data visualization*
