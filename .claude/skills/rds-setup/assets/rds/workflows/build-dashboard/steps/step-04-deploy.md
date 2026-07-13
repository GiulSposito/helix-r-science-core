# Step 4: Deploy

**Workflow:** build-dashboard
**Phase:** Deployment
**Duration:** 2-4 hours

---

## Objective

Deploy Shiny dashboard to chosen platform (local, shinyapps.io, Posit Connect, or Docker).

---

## Instructions

Act as Marie with deployment knowledge. Get the dashboard accessible to users.

### 1. Choose Deployment Target

**Options:**

**Local (Development):**
```r
shiny::runApp()
```
Best for: Testing, demos, personal use

**shinyapps.io (Cloud):**
```r
rsconnect::deployApp(account = "your-account")
```
Best for: Public dashboards, easy sharing

**Posit Connect (Enterprise):**
```r
rsconnect::deployApp(server = "connect.company.com")
```
Best for: Internal corporate dashboards, SSO

**Docker (Containerized):**
```dockerfile
FROM rocker/shiny-verse:latest
COPY . /srv/shiny-server/dashboard/
EXPOSE 3838
CMD ["/usr/bin/shiny-server"]
```
Best for: Custom infrastructure, Kubernetes

### 2. Pre-Deployment Checklist

Before deploying:
- [ ] Test locally one final time
- [ ] Environment variables configured
- [ ] Data sources accessible from deployment
- [ ] Authentication setup (if needed)
- [ ] Resource limits configured

### 3. Deploy Application

Execute deployment:

**For shinyapps.io:**
```r
rsconnect::setAccountInfo(name = "account",
                          token = "TOKEN",
                          secret = "SECRET")
rsconnect::deployApp(appName = "my-dashboard")
```

**For Docker:**
```bash
docker build -t dashboard:v1.0 .
docker run -p 3838:3838 dashboard:v1.0
```

### 4. Verify Deployment

Post-deployment checks:
- [ ] Dashboard loads without errors
- [ ] All data displays correctly
- [ ] Filters work as expected
- [ ] Performance acceptable
- [ ] URLs/links work

### 5. Document Access

Create `DEPLOYMENT.md`:
```markdown
## Dashboard Access

**URL:** [https://dashboard-url.com]
**Credentials:** [if applicable]

## Maintenance

**Data refresh:** [frequency and method]
**Contact:** [maintainer email]
**Source code:** [repo link]

## Troubleshooting

[Common issues and solutions]
```

### 6. Share with Users

- Send dashboard URL to stakeholders
- Provide brief usage guide if needed
- Set up usage analytics (if available)
- Schedule feedback session

---

## Validation Checklist

Deployment complete when:
- [ ] Dashboard accessible via URL
- [ ] All features functional in deployed environment
- [ ] Performance acceptable
- [ ] Documentation provided
- [ ] Users notified

---

## Output

**Deployment artifacts:**
- Dashboard URL
- Access credentials (if needed)
- `DEPLOYMENT.md` — Access and maintenance guide

**Workflow complete!** Return to Marie's menu.
