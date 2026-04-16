# Quarto YAML Options Reference

Complete reference for YAML frontmatter configuration in Quarto documents.

## Document Metadata

### Basic Metadata
```yaml
title: "Document Title"
subtitle: "Optional Subtitle"
author: "Author Name"
date: "2024-03-11"           # or: today, last-modified
abstract: |
  Multi-line abstract text.
  Second paragraph of abstract.
keywords:
  - keyword1
  - keyword2
  - keyword3
```

### Multiple Authors
```yaml
author:
  - name: "First Author"
    email: "first@example.com"
    affiliation: "University Name"
    orcid: "0000-0000-0000-0000"
  - name: "Second Author"
    email: "second@example.com"
    affiliation: "Company Name"
```

### License and Citation
```yaml
license: "CC BY"
copyright: "Copyright 2024 Author Name"
citation:
  type: article-journal
  container-title: "Journal Name"
  doi: "10.xxxx/xxxxx"
  url: "https://example.com"
```

## Format Options

### HTML Output
```yaml
format:
  html:
    toc: true                    # Table of contents
    toc-depth: 3                 # Heading levels in TOC
    toc-location: left           # left, right, body
    toc-title: "Contents"
    number-sections: true        # Number headings
    number-depth: 3              # Levels to number

    # Code display
    code-fold: false             # true, false, show
    code-summary: "Show code"
    code-overflow: wrap          # wrap, scroll
    code-line-numbers: true
    code-copy: true              # Copy button
    code-tools: true             # Source/tools menu
    code-link: true              # Link functions to docs

    # Appearance
    theme: cosmo                 # Bootstrap theme
    css: styles.css              # Custom CSS
    fontsize: 1.1em
    linestretch: 1.7
    mainfont: "Georgia"
    monofont: "Fira Code"

    # Layout
    grid:
      sidebar-width: 300px
      body-width: 900px
      margin-width: 300px
    page-layout: article         # article, full, custom

    # Features
    smooth-scroll: true
    anchor-sections: true
    link-external-icon: true
    link-external-newwindow: true
    citations-hover: true
    footnotes-hover: true
    fig-responsive: true

    # HTML specifics
    self-contained: false        # Single file
    embed-resources: false       # Embed images/CSS
    minimal: false               # Minimal HTML
    html-math-method: mathjax    # katex, mathjax, webtex

    # Table of contents
    toc-expand: 2               # Auto-expand levels

    # Includes
    include-in-header: header.html
    include-before-body: before.html
    include-after-body: after.html
```

### PDF Output
```yaml
format:
  pdf:
    toc: true
    toc-depth: 3
    number-sections: true
    number-depth: 3

    # LaTeX engine
    pdf-engine: pdflatex        # xelatex, lualatex

    # Document class
    documentclass: article       # book, report, scrartcl
    classoption:
      - twocolumn
      - landscape

    # Geometry
    geometry:
      - margin=1in
      - paperwidth=8.5in
      - paperheight=11in

    # Typography
    fontsize: 11pt
    linestretch: 1.5
    mainfont: "Times New Roman"
    sansfont: "Helvetica"
    monofont: "Courier"
    mathfont: "Latin Modern Math"

    # Code
    code-block-bg: true
    code-block-border-left: true
    highlight-style: github

    # Figures
    fig-pos: "H"                # H, t, b, p

    # References
    cite-method: natbib         # biblatex, citeproc
    biblio-style: apa

    # LaTeX includes
    include-in-header: preamble.tex
    include-before-body: before.tex
    include-after-body: after.tex

    # Keep intermediate files
    keep-tex: true
    keep-md: false
```

### Microsoft Word Output
```yaml
format:
  docx:
    toc: true
    toc-depth: 3
    number-sections: true
    number-depth: 3

    # Reference document
    reference-doc: custom-template.docx

    # Highlighting
    highlight-style: github

    # Figures
    fig-width: 7
    fig-height: 5
    fig-dpi: 300
```

### RevealJS Presentations
```yaml
format:
  revealjs:
    # Structure
    incremental: false          # Bullet animation
    slide-number: true
    show-slide-number: all      # all, print, speaker

    # Theme
    theme: dark                 # dark, light, custom.scss
    logo: images/logo.png
    footer: "Footer text"

    # Transitions
    transition: slide           # none, fade, slide, convex, concave, zoom
    transition-speed: default   # default, fast, slow
    background-transition: fade

    # Code
    code-fold: false
    code-overflow: wrap
    code-line-numbers: false

    # Fragments
    auto-animate: true
    auto-animate-easing: ease
    auto-animate-duration: 1.0

    # Navigation
    controls: true
    controls-layout: bottom-right
    navigation-mode: linear     # linear, grid
    keyboard: true

    # Layout
    width: 1050
    height: 700
    margin: 0.1

    # Features
    preview-links: false
    chalkboard: true           # Drawing tool
    multiplex: false           # Multi-device control

    # Presentation modes
    view-distance: 3           # Slides to preload
    mobile-view-distance: 2

    # Menu
    menu:
      side: left
      width: normal
```

### Dashboard Format
```yaml
format:
  dashboard:
    # Layout
    orientation: columns       # columns, rows
    scrolling: false          # Enable scrolling

    # Navigation
    nav-buttons:
      - icon: github
        href: https://github.com/user/repo
      - icon: twitter
        href: https://twitter.com/user

    # Theme
    theme: cosmo
    logo: images/logo.png

    # Title
    title: "Dashboard Title"
    author: "Author Name"
    date: last-modified
```

## Execution Options

### Global Execution
```yaml
execute:
  echo: true                   # Show code
  eval: true                   # Run code
  warning: true                # Show warnings
  error: false                 # Show errors
  message: true                # Show messages
  include: true                # Include output

  # Caching
  cache: false                 # true, false, refresh
  freeze: false                # true, false, auto

  # Engine
  engine: knitr                # knitr, jupyter

  # Working directory
  daemon: false                # Persistent R session
```

### Language-Specific Execution
```yaml
execute:
  r:
    echo: true
    warning: false
  python:
    echo: false
    warning: true
```

## Figure Options

### Global Figure Settings
```yaml
format:
  html:
    fig-width: 8
    fig-height: 6
    fig-dpi: 300
    fig-format: png            # png, jpg, svg, pdf
    fig-align: center          # left, center, right, default
    fig-cap-location: bottom   # top, bottom, margin
    fig-responsive: true
```

### Figure Layout
```yaml
format:
  html:
    # Subfigures
    layout-ncol: 2             # Columns for multiple figures
    layout-nrow: 2             # Rows for multiple figures

    # Figure panel
    fig-column: page           # body, page, screen, margin
```

## Cross-References

### Cross-Reference Configuration
```yaml
crossref:
  fig-title: "Figure"
  tbl-title: "Table"
  eq-title: "Equation"
  sec-title: "Section"

  fig-prefix: "Figure"
  tbl-prefix: "Table"
  eq-prefix: "Equation"
  sec-prefix: "Section"

  title-delim: ":"
  labels: arabic               # arabic, alpha, Alpha, roman, Roman
  subref-labels: alpha         # For subfigures
```

## Citations and Bibliography

### Bibliography Configuration
```yaml
bibliography: references.bib
csl: apa.csl                   # Citation style
citation-location: document    # document, margin
citeproc: true
link-citations: true
link-bibliography: true

# Suppress bibliography
suppress-bibliography: false

# Citation formatting
nocite: |
  @item1, @item2              # Cite without reference
```

### Multiple Bibliographies
```yaml
bibliography:
  - references.bib
  - packages.bib

# Or with specific CSL per bibliography
bibliography:
  refs: references.bib
  packages: packages.bib
```

## Project-Level Configuration

### _quarto.yml Structure
```yaml
project:
  type: website               # website, book, manuscript
  output-dir: _site
  preview:
    port: 4200
    browser: true

  # Pre/post render scripts
  pre-render: pre-render.R
  post-render: post-render.R

  # Render targets
  render:
    - "*.qmd"
    - "!drafts/"

# Default format for all documents
format:
  html:
    theme: cosmo
    css: styles.css
    toc: true

# Default execution
execute:
  echo: false
  warning: false
  cache: true

# Website-specific
website:
  title: "Site Title"
  description: "Site description"
  site-url: "https://example.com"
  repo-url: "https://github.com/user/repo"
  repo-actions: [edit, issue]

  # Navigation
  navbar:
    title: "Site Title"
    logo: logo.png
    left:
      - text: "Home"
        href: index.qmd
      - text: "About"
        href: about.qmd
    right:
      - icon: github
        href: https://github.com/user/repo

  sidebar:
    style: docked             # docked, floating
    search: true
    collapse-level: 2
    contents:
      - section: "Section 1"
        contents:
          - file1.qmd
          - file2.qmd
      - section: "Section 2"
        contents:
          - file3.qmd

  # Footer
  page-footer:
    left: "© 2024 Author"
    right:
      - icon: github
        href: https://github.com/user/repo

  # Comments
  comments:
    hypothesis: true
    # or utterances, giscus

# Book-specific
book:
  title: "Book Title"
  author: "Author Name"
  date: "2024-03-11"

  chapters:
    - index.qmd
    - part: "Part 1"
      chapters:
        - chapter1.qmd
        - chapter2.qmd
    - part: "Part 2"
      chapters:
        - chapter3.qmd

  appendices:
    - appendix-a.qmd

  # Navigation
  navbar:
    title: "Book Title"
  sidebar:
    style: docked

  # Output
  output-file: "book"
  repo-url: "https://github.com/user/book"
  downloads: [pdf, epub]
```

## Code Options

### Syntax Highlighting
```yaml
highlight-style: github        # pygments, tango, espresso, zenburn, kate, monochrome, breezedark, haddock
# Or path to custom theme
highlight-style: custom.theme
```

### Code Annotation
```yaml
code-annotations: hover       # hover, select, below
```

## Language Options

### R-Specific Options
```yaml
knitr:
  opts_chunk:
    comment: "#>"
    collapse: true
    fig.retina: 2
    fig.showtext: true
    dev: "ragg_png"
  opts_knit:
    root.dir: "."
```

### Jupyter-Specific Options
```yaml
jupyter:
  kernelspec:
    name: python3
    language: python
    display_name: "Python 3"
```

## Metadata Files

### _metadata.yml (Directory-level)
```yaml
# Apply to all files in directory
format:
  html:
    theme: cosmo
execute:
  echo: false
```

## Conditional Content

### Profile-Based Configuration
```yaml
# In _quarto.yml
project:
  type: website

# Profiles
profile:
  group:
    - [production, development]

---
# Default settings
format:
  html:
    toc: true

---
# Production profile
profile: production
format:
  html:
    self-contained: true
    minified: true

---
# Development profile
profile: development
format:
  html:
    self-contained: false
execute:
  cache: false
```

## Environment Variables

### Using Environment Variables in YAML
```yaml
title: "`r Sys.getenv('TITLE', 'Default Title')`"
author: "`r Sys.getenv('AUTHOR', 'Unknown')`"

# Or in project file
website:
  site-url: !expr Sys.getenv("SITE_URL")
```

## Advanced Options

### HTML Dependencies
```yaml
format:
  html:
    html-dependencies:
      - name: "custom-lib"
        version: "1.0"
        scripts:
          - custom.js
        stylesheets:
          - custom.css
```

### Custom Format
```yaml
format:
  custom-html:
    variant: html
    toc: true
    # Additional custom options
```

### Template Partials
```yaml
format:
  html:
    template-partials:
      - title.html
      - toc.html
```

## Common Patterns

### Academic Paper
```yaml
title: "Paper Title"
author:
  - name: "Author Name"
    affiliation: "University"
date: today
abstract: |
  Paper abstract here.
keywords: [keyword1, keyword2]
format:
  pdf:
    documentclass: article
    number-sections: true
    geometry:
      - margin=1in
    cite-method: natbib
    biblio-style: apa
bibliography: references.bib
```

### Blog Post
```yaml
title: "Post Title"
author: "Author Name"
date: "2024-03-11"
categories: [category1, category2]
image: featured.jpg
format:
  html:
    toc: true
    code-fold: true
    code-tools: true
```

### Technical Report
```yaml
title: "Report Title"
subtitle: "Technical Documentation"
author: "Company Name"
date: last-modified
format:
  html:
    theme: cosmo
    toc: true
    toc-depth: 3
    number-sections: true
    code-fold: show
    code-tools: true
  pdf:
    documentclass: report
    toc: true
    number-sections: true
    geometry:
      - margin=1in
```

### Presentation
```yaml
title: "Presentation Title"
author: "Author Name"
date: today
format:
  revealjs:
    theme: dark
    slide-number: true
    chalkboard: true
    transition: slide
    incremental: true
    code-fold: true
```

## Validation

### Check YAML Syntax
```bash
quarto check
```

### Preview with Specific Format
```bash
quarto preview document.qmd --to html
quarto preview document.qmd --to pdf
```

## References

- [Quarto Guide: YAML Options](https://quarto.org/docs/reference/)
- [Quarto Guide: Document Options](https://quarto.org/docs/reference/formats/html.html)
- [Quarto Guide: Project Options](https://quarto.org/docs/reference/projects/)
