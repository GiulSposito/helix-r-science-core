---
name: deploy-model
description: Deploy validated model as Vetiver REST API with Docker
installed_path: '{project-root}/_bmad/rds/workflows/deploy-model'
---

# Deploy Model Workflow

**Module:** RDS (R Data Science)
**Owner:** Tim (The Deployer)
**Status:** Active
**Duration:** 1-2 days

---

## Workflow Overview

**Goal:** Take validated models from Alan to production with proper versioning, containerization, and zero-downtime deployment

**Description:** Deploy tidymodels workflows as production REST APIs using Vetiver framework. Includes Docker containerization, health checks, versioning, rollback plans, and deployment verification. Emphasizes reliability and operational readiness.

**Workflow Type:** Core — Multi-step production deployment

---

## Activation Sequence

<activation>

### Step 1: Welcome & Context

**Output:**
```
╔══════════════════════════════════════════════════════════════╗
║              MODEL DEPLOYMENT WORKFLOW                       ║
║           From Notebook to Production API                    ║
╚══════════════════════════════════════════════════════════════╝

Tim here! Let's get your validated model running reliably in production.

This workflow will guide you through:
  • Step 1: Prepare Artifacts (collect model, recipe, validation)
  • Step 2: Create Vetiver API (REST endpoints, health checks)
  • Step 3: Containerize (Docker with dependencies)
  • Step 4: Deploy & Verify (zero-downtime deployment + smoke tests)

Pre-flight checklist:
  ☐ Model validated by Alan (test set evaluation complete)
  ☐ Feature engineering recipe ready
  ☐ Deployment target identified (local/cloud/on-prem)
  ☐ Monitoring plan in place (coordinate with [MM] Model Monitoring)

Duration: 1-2 days

Remember: We deploy WITH monitoring, not deploy THEN monitor!
```

### Step 2: Execute Workflow Steps

Load and execute each step sequentially:

1. **Step 1 — Prepare Artifacts**
   - File: `{installed_path}/steps/step-01-prepare-artifacts.md`
   - Goal: Collect and validate model files, dependencies, and configuration
   - Action: Load and execute

2. **Step 2 — Create Vetiver API**
   - File: `{installed_path}/steps/step-02-create-api.md`
   - Goal: Build Vetiver REST API with prediction and health endpoints
   - Action: Load and execute

3. **Step 3 — Containerize**
   - File: `{installed_path}/steps/step-03-containerize.md`
   - Goal: Create Docker image with R environment and dependencies
   - Action: Load and execute

4. **Step 4 — Deploy & Verify**
   - File: `{installed_path}/steps/step-04-deploy-verify.md`
   - Goal: Deploy to target environment and run smoke tests
   - Action: Load and execute

### Step 3: Completion

**Output:**
```
╔══════════════════════════════════════════════════════════════╗
║              MODEL DEPLOYED SUCCESSFULLY!                    ║
╚══════════════════════════════════════════════════════════════╝

Your model is live and serving predictions!

Deployment summary:
  • API Endpoint: [https://api.example.com/predict]
  • Health Check: [https://api.example.com/ping] → 🟢 200 OK
  • Model Version: [v1.0.0]
  • Container: [docker-image:tag]
  • Environment: [production/staging]

Generated artifacts:
  • vetiver-api/ — Vetiver API code (plumber)
  • Dockerfile — Container definition
  • docker-compose.yml — Local orchestration
  • deployment-manifest.yaml — K8s manifest (if applicable)
  • rollback.sh — Emergency rollback script

Smoke test results:
  ✓ Health endpoint responding (< 100ms)
  ✓ Prediction endpoint functional
  ✓ Sample predictions validated
  ✓ Error handling verified
  ✓ Logging configured

Rollback plan:
  • Previous version: [v0.9.0] (standby)
  • Rollback time: < 5 minutes
  • Command: ./rollback.sh v0.9.0

Next steps:
  • Monitor API performance (use [MM] Model Monitoring)
  • Set up alerts for error rates > 0.5%
  • Document API for consumers
  • Schedule first model refresh

Model in production! 🚀
```

</activation>

---

## Workflow Properties

**Input Requirements:**
- Validated model from Alan (.rds or vetiver bundle)
- Feature engineering recipe
- Test set validation metrics
- Deployment target (Docker/K8s/cloud)

**Optional Inputs:**
- API specification (custom endpoints)
- Authentication requirements
- Rate limiting configuration
- Blue-green deployment strategy

**Outputs:**
- `vetiver-api/` — Plumber API code
- `Dockerfile` — Container definition
- `docker-compose.yml` — Local development
- `deployment-manifest.yaml` — K8s/cloud config
- `rollback.sh` — Emergency rollback script
- `API-DOCS.md` — Endpoint documentation

---

## Agent Integration

**Primary Agent:** Tim (The Deployer)
- Orchestrates deployment pipeline
- Ensures production readiness
- Configures rollback procedures

**Supporting Agents:**
- **Alan** — Provides validated model artifacts
- **Grace** — Provides feature engineering context
- **Marie** — Documents API for stakeholders

---

## Implementation Notes

**Philosophy:**
- Production readiness checklist before go-live
- Zero-downtime deployments (blue-green/canary)
- Version everything (model + code + dependencies)
- Test in production safely (shadow mode first)
- Rollback plan ready before deployment

**Deployment Strategies:**

**Blue-Green:**
- Deploy to new environment (green)
- Run parallel for validation
- Switch traffic atomically
- Keep blue as instant rollback

**Canary:**
- Deploy to small traffic percentage (5-10%)
- Monitor error rates and latency
- Gradually increase traffic
- Rollback if metrics degrade

**Rolling:**
- Update instances sequentially
- Monitor each instance before next
- Slower but safer for large fleets

**Best For:**
- Production model deployment
- API-first architectures
- Microservices integration
- Continuous deployment pipelines

**Not Ideal For:**
- Batch prediction jobs (use R scripts)
- Prototype/POC models (overkill)
- Models not validated by Alan (unsafe)

---

## Technical Requirements

**R Packages:**
- Core: tidyverse, tidymodels
- Deployment: vetiver, plumber
- Serialization: bundle (for model artifacts)
- Monitoring: pins (for model registry)

**Docker:**
- Base image: rocker/tidyverse or rocker/r-ver
- Multi-stage builds (smaller images)
- Health check endpoints
- Non-root user (security)

**Vetiver Features:**
- Model versioning and pinning
- REST API generation
- OpenAPI documentation
- Health and metadata endpoints

**Deployment Targets:**
- **Local/Dev:** docker-compose
- **Cloud:** AWS ECS, GCP Cloud Run, Azure Container Instances
- **Kubernetes:** Deployment manifests with HPA
- **Posit Connect:** Direct Vetiver integration

**Expected Duration:**
- Step 1 (Prepare Artifacts): 2-4 hours
- Step 2 (Create API): 2-4 hours
- Step 3 (Containerize): 3-6 hours
- Step 4 (Deploy & Verify): 2-4 hours

---

_Workflow created on 2026-03-26 for RDS Module v0.2.0_
