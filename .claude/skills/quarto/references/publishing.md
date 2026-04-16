# Quarto Publishing Reference

Complete guide to publishing Quarto documents and projects.

## Publishing Platforms Overview

| Platform | Best For | Cost | Custom Domain | Requirements |
|----------|----------|------|---------------|--------------|
| Quarto Pub | Quick sharing, personal projects | Free | Yes (paid) | Quarto account |
| GitHub Pages | Open source, version control | Free | Yes | GitHub account |
| Netlify | Professional sites, CI/CD | Free tier | Yes | Git provider |
| Posit Connect | Enterprise, private sharing | Paid | Yes | Connect server |
| Confluence | Team wikis | Paid | N/A | Confluence space |

## Quarto Pub

### Initial Setup

**Create Account:**
1. Visit [https://quartopub.com](https://quartopub.com)
2. Sign up with email or GitHub
3. Verify email address

**Configure Credentials:**
```bash
# Authorize from command line
quarto publish quarto-pub

# Or specify account
quarto publish quarto-pub --account username
```

### Publishing Documents

**Single Document:**
```bash
# First-time publish
quarto publish quarto-pub document.qmd

# Update existing
quarto publish quarto-pub document.qmd --id existing-doc-id

# With custom slug
quarto publish quarto-pub document.qmd --slug my-document
```

**Website/Book Project:**
```bash
# From project root
quarto publish quarto-pub

# Specify site directory
quarto publish quarto-pub --site-dir _site
```

### Configuration

**Add to _quarto.yml:**
```yaml
project:
  type: website

website:
  title: "My Site"

# Quarto Pub specific settings
publish:
  quarto-pub:
    id: "your-project-id"  # Generated after first publish
    url: "https://username.quarto.pub/project-name"
```

**Document-level:**
```yaml
---
title: "Document Title"
publish:
  quarto-pub:
    slug: custom-name
---
```

### Managing Publications

**List publications:**
```bash
quarto publish list
```

**Remove publication:**
```bash
quarto publish remove quarto-pub --id project-id
```

### Best Practices
- Use descriptive slugs for URLs
- Add README.md for project documentation
- Keep site under 100MB for faster deployment
- Use `freeze: true` for computations to avoid re-running code

### Limitations
- 100MB size limit per project
- Public only (no private documents on free tier)
- Limited custom domain support (paid feature)

## GitHub Pages

### Setup Methods

#### Method 1: GitHub Actions (Recommended)

**1. Create GitHub Actions Workflow:**

`.github/workflows/quarto-publish.yml`:
```yaml
name: Publish Quarto Site

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Quarto
        uses: quarto-dev/quarto-actions/setup@v2
        with:
          version: release

      - name: Setup R
        uses: r-lib/actions/setup-r@v2
        with:
          r-version: '4.3.2'
          use-public-rspm: true

      - name: Install R packages
        uses: r-lib/actions/setup-r-dependencies@v2
        with:
          packages: |
            any::tidyverse
            any::ggplot2
            any::knitr
            any::rmarkdown

      - name: Render Quarto Project
        run: quarto render

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: _site

  deploy:
    needs: build
    runs-on: ubuntu-latest

    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}

    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

**2. Configure GitHub Repository:**
1. Go to Settings → Pages
2. Source: "GitHub Actions"
3. Push to trigger deployment

**3. Add _quarto.yml configuration:**
```yaml
project:
  type: website
  output-dir: _site

website:
  title: "My Website"
  site-url: "https://username.github.io/repo-name"
  repo-url: "https://github.com/username/repo-name"
  repo-actions: [edit, issue]
```

#### Method 2: gh-pages Branch

**1. Configure _quarto.yml:**
```yaml
project:
  type: website
  output-dir: docs  # GitHub Pages can serve from /docs

website:
  title: "My Site"
```

**2. Render and push:**
```bash
quarto render
git add docs/
git commit -m "Update site"
git push
```

**3. Configure GitHub:**
- Settings → Pages → Source: Deploy from a branch
- Branch: main, Folder: /docs

#### Method 3: Quarto Publish Command

**One-time setup:**
```bash
# Initialize gh-pages
quarto publish gh-pages

# Creates gh-pages branch and pushes rendered site
```

**Subsequent updates:**
```bash
quarto publish gh-pages
```

### Custom Domain

**1. Add CNAME file to project root:**
```
www.yourdomain.com
```

**2. Update _quarto.yml:**
```yaml
website:
  site-url: "https://www.yourdomain.com"
```

**3. Configure DNS:**

For `www.yourdomain.com`:
```
CNAME  www  username.github.io
```

For apex domain `yourdomain.com`:
```
A  @  185.199.108.153
A  @  185.199.109.153
A  @  185.199.110.153
A  @  185.199.111.153
```

**4. Enable HTTPS in GitHub Settings**

### Advanced GitHub Actions Examples

**With Python:**
```yaml
- name: Setup Python
  uses: actions/setup-python@v4
  with:
    python-version: '3.11'

- name: Install Python packages
  run: |
    pip install jupyter matplotlib pandas numpy
```

**With caching:**
```yaml
- name: Cache Quarto
  uses: actions/cache@v3
  with:
    path: _freeze
    key: ${{ runner.os }}-quarto-${{ hashFiles('**/*.qmd') }}
    restore-keys: |
      ${{ runner.os }}-quarto-

- name: Render with freeze
  run: quarto render --execute-params freeze=true
```

**With multiple environments:**
```yaml
strategy:
  matrix:
    r-version: ['4.2.3', '4.3.2']

steps:
  - name: Setup R
    uses: r-lib/actions/setup-r@v2
    with:
      r-version: ${{ matrix.r-version }}
```

### Troubleshooting GitHub Pages

**Issue: Pages not updating**
- Check Actions tab for build errors
- Verify output-dir matches deployment source
- Clear browser cache

**Issue: 404 errors**
- Ensure index.html exists in root
- Check paths are relative, not absolute
- Verify site-url in _quarto.yml

**Issue: R packages not found**
- Add all dependencies to workflow
- Use `renv` for reproducible environments
- Check CRAN availability

## Netlify

### Setup

**1. Connect Repository:**
- Sign up at [netlify.com](https://netlify.com)
- "Add new site" → "Import an existing project"
- Connect GitHub/GitLab/Bitbucket
- Select repository

**2. Configure Build Settings:**
```
Build command: quarto render
Publish directory: _site
```

**3. Create netlify.toml:**
```toml
[build]
  command = "quarto render"
  publish = "_site"

[build.environment]
  QUARTO_VERSION = "1.4.550"

[context.production]
  command = "quarto render"

[context.deploy-preview]
  command = "quarto render"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"
    X-Content-Type-Options = "nosniff"
```

**4. Install Quarto in Build:**

Create `package.json`:
```json
{
  "name": "quarto-site",
  "version": "1.0.0",
  "scripts": {
    "build": "quarto render"
  },
  "devDependencies": {
    "@quarto/cli": "^1.4.550"
  }
}
```

Or use netlify.toml:
```toml
[build.environment]
  QUARTO_VERSION = "1.4.550"

[build]
  command = """
    curl -LO https://quarto.org/download/latest/quarto-linux-amd64.deb
    sudo dpkg -i quarto-linux-amd64.deb
    quarto render
  """
```

### Custom Domain

**1. In Netlify Dashboard:**
- Site settings → Domain management → Add custom domain
- Enter your domain

**2. Configure DNS:**
- Add CNAME record pointing to your-site.netlify.app
- Or use Netlify DNS for easier setup

**3. Enable HTTPS:**
- Automatic with Let's Encrypt (free)

### Environment Variables

**Add in Netlify Dashboard:**
- Site settings → Environment variables
- Add key-value pairs

**Use in _quarto.yml:**
```yaml
website:
  site-url: !expr Sys.getenv("SITE_URL")
  google-analytics: !expr Sys.getenv("GA_ID")
```

**Access in R code:**
```r
api_key <- Sys.getenv("API_KEY")
```

### Deploy Previews

Netlify automatically creates preview deployments for pull requests.

**Configure in netlify.toml:**
```toml
[context.deploy-preview]
  command = "quarto render"

[context.branch-deploy]
  command = "quarto render --profile staging"
```

### Netlify Functions (Advanced)

For dynamic content:

`netlify/functions/api.js`:
```javascript
exports.handler = async (event, context) => {
  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Hello from Netlify Functions" })
  };
};
```

Call from Quarto:
```{r}
library(httr)
response <- GET("/.netlify/functions/api")
content(response)
```

## Posit Connect

### Requirements
- Posit Connect server (commercial product)
- rsconnect package
- Server credentials

### Setup

**Install rsconnect:**
```r
install.packages("rsconnect")
```

**Configure server:**
```r
library(rsconnect)

# Add server
rsconnect::addServer(
  url = "https://connect.example.com",
  name = "company-connect"
)

# Or with API key
rsconnect::addConnectServer(
  url = "https://connect.example.com",
  name = "company-connect",
  apiKey = "your-api-key"
)
```

### Publishing

**Deploy document:**
```r
library(rsconnect)

# First deployment
rsconnect::deployDoc(
  doc = "document.qmd",
  server = "company-connect",
  account = "username"
)

# Update existing
rsconnect::deployDoc(
  doc = "document.qmd",
  server = "company-connect",
  appId = "existing-app-id"
)
```

**Deploy project:**
```r
rsconnect::deploySite(
  siteName = "my-website",
  server = "company-connect",
  account = "username"
)
```

**Command line:**
```bash
quarto publish connect document.qmd --server company-connect
```

### Configuration

**Manifest file (_quarto.yml):**
```yaml
project:
  type: website

website:
  title: "Internal Documentation"

connect:
  server: company-connect
  account: username
  access-type: logged_in  # or 'all', 'acl'
```

### Access Control
- **all**: Public access
- **logged_in**: Any authenticated user
- **acl**: Specific users/groups

**Set via UI or R:**
```r
rsconnect::setContentAccessType(
  appId = "app-id",
  accessType = "logged_in"
)
```

## Confluence

### Setup

**Install quarto-confluence extension:**
```bash
quarto install extension quarto-ext/confluence
```

### Configuration

**In document YAML:**
```yaml
---
title: "My Page"
confluence:
  space: "MYSPACE"
  parent-id: "123456"  # Optional parent page
  server: "https://company.atlassian.net"
---
```

### Publishing

**Publish to Confluence:**
```bash
quarto publish confluence document.qmd
```

**First-time authentication:**
- Enter Confluence URL
- Enter username
- Enter API token (from Atlassian account settings)

### Features
- Converts Quarto → Confluence storage format
- Uploads images automatically
- Creates new page or updates existing
- Preserves Confluence page ID for updates

## CI/CD Best Practices

### Environment Variables

**Never commit secrets:**
```yaml
# .gitignore
.Renviron
.env
secrets/
```

**Use GitHub Secrets:**
- Settings → Secrets and variables → Actions
- Add: NETLIFY_AUTH_TOKEN, CONNECT_API_KEY, etc.

**Access in workflow:**
```yaml
- name: Deploy
  env:
    NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
  run: netlify deploy --prod
```

### Caching Strategies

**Cache Quarto freeze:**
```yaml
- name: Cache freeze
  uses: actions/cache@v3
  with:
    path: _freeze
    key: quarto-${{ hashFiles('**/*.qmd') }}
```

**Cache R packages:**
```yaml
- name: Cache R packages
  uses: actions/cache@v3
  with:
    path: ${{ env.R_LIBS_USER }}
    key: r-packages-${{ hashFiles('**/DESCRIPTION') }}
```

**Cache Python packages:**
```yaml
- name: Cache pip
  uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: pip-${{ hashFiles('requirements.txt') }}
```

### Build Performance

**Parallel rendering:**
```yaml
execute:
  daemon: 300  # Keep R session alive for 5 minutes
```

**Selective rendering:**
```yaml
# Only render changed files
project:
  pre-render: |
    git diff --name-only HEAD~1 HEAD | grep '\.qmd$' || echo "*.qmd"
```

**Freeze computations:**
```yaml
execute:
  freeze: auto  # Only re-execute when source changes
```

## Monitoring and Analytics

### Google Analytics

**In _quarto.yml:**
```yaml
website:
  google-analytics: "G-XXXXXXXXXX"
  cookie-consent: true
```

### Plausible Analytics

```yaml
website:
  plausible: "yourdomain.com"
```

### Custom Analytics

**Add to HTML:**
```yaml
format:
  html:
    include-in-header: analytics.html
```

`analytics.html`:
```html
<script>
  // Custom analytics code
</script>
```

## Troubleshooting

### Common Issues

**Build fails on CI but works locally:**
- Check Quarto version matches
- Verify all dependencies listed
- Check working directory assumptions
- Review environment variables

**Images not loading:**
- Use relative paths, not absolute
- Verify images committed to repository
- Check image paths in rendered HTML

**Custom domain not working:**
- Wait for DNS propagation (up to 48 hours)
- Verify DNS records are correct
- Check for CNAME conflicts
- Ensure HTTPS is enabled

**Slow build times:**
- Enable freeze for computation caching
- Use cache-dependencies in CI/CD
- Optimize image sizes
- Consider splitting large projects

**R packages not found:**
- List all dependencies explicitly
- Use renv for reproducibility
- Check CRAN mirror availability
- Verify package versions compatible

### Debug Tips

**Local testing:**
```bash
# Test render
quarto render

# Test with specific profile
quarto render --profile production

# Preview locally
quarto preview

# Check project
quarto check
```

**GitHub Actions debugging:**
```yaml
- name: Debug
  run: |
    quarto check
    R --version
    which quarto
    quarto --version
```

**Check deployed site:**
```bash
# Download built site
wget -r https://your-site.com

# Check for broken links
linkchecker https://your-site.com
```

## Security Considerations

### Sensitive Data

**Never publish:**
- API keys, passwords, tokens
- Database credentials
- Private data
- Personally identifiable information (PII)

**Use environment variables:**
```r
# Good
api_key <- Sys.getenv("API_KEY")

# Bad
api_key <- "secret123"  # Visible in published code
```

**Filter sensitive output:**
```{r}
#| include: false

sensitive_data <- load_private_data()
public_summary <- summarize_safely(sensitive_data)
```

```{r}
#| echo: false

print(public_summary)  # Only show safe summary
```

### Access Control

**Use authentication when needed:**
- Posit Connect for enterprise
- Private GitHub repos (with Actions)
- Password-protected Netlify sites
- Confluence space permissions

## Quick Command Reference

```bash
# Quarto Pub
quarto publish quarto-pub
quarto publish quarto-pub --slug custom-name

# GitHub Pages
quarto publish gh-pages
quarto publish gh-pages --no-browser

# Netlify (via CLI)
netlify deploy --prod

# Posit Connect
quarto publish connect --server company-connect

# Confluence
quarto publish confluence document.qmd

# Preview before publishing
quarto preview

# Render without publishing
quarto render

# Check for issues
quarto check
```

## Resources

- [Quarto Publishing Guide](https://quarto.org/docs/publishing/)
- [GitHub Actions for Quarto](https://github.com/quarto-dev/quarto-actions)
- [Netlify Documentation](https://docs.netlify.com/)
- [Posit Connect User Guide](https://docs.posit.co/connect/)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
