# Step 4: Deploy & Verify

**Workflow:** deploy-model
**Phase:** Production Deployment
**Duration:** 2-4 hours

---

## Objective

Deploy containerized model to production environment and verify with smoke tests.

---

## Instructions

Act as Tim with production deployment authority. Deploy safely with verification at each step.

### 1. Choose Deployment Platform

**Options:**

**Docker (Local/VM):**
```bash
docker run -d -p 8080:8080 --restart unless-stopped \
  --name model-api-prod \
  my-model-api:v1.0.0
```

**Kubernetes:**
```bash
kubectl apply -f deployment-manifest.yaml
kubectl rollout status deployment/model-api
```

**Cloud Run (GCP):**
```bash
gcloud run deploy model-api \
  --image gcr.io/project/model-api:v1.0.0 \
  --platform managed \
  --region us-central1
```

**AWS ECS/Fargate:**
```bash
aws ecs create-service --cli-input-json file://ecs-service.json
```

### 2. Pre-Deployment Checklist

Verify before deployment:
- [ ] Container tested locally
- [ ] Deployment target configured
- [ ] Environment variables set
- [ ] Secrets configured securely
- [ ] Previous version documented (for rollback)
- [ ] Monitoring configured (from model-monitoring workflow)

### 3. Deploy to Production

Execute deployment:

**Document deployment details:**
- Deployment time: [timestamp]
- Model version: v1.0.0
- Previous version: v0.9.0 (if exists)
- Deployment strategy: [blue-green/canary/rolling]

**For blue-green deployment:**
1. Deploy to green environment
2. Run smoke tests on green
3. Switch traffic from blue to green
4. Keep blue running as instant rollback

### 4. Run Smoke Tests

Verify deployment immediately:

```bash
# Health check
curl -f https://api.example.com/ping || echo "❌ Health check failed"

# Sample prediction
curl -X POST https://api.example.com/predict \
  -H "Content-Type: application/json" \
  -d @test-sample.json

# Metadata verification
curl https://api.example.com/metadata | jq '.version'
```

**Verify:**
- [ ] Health endpoint returns 200 (< 100ms)
- [ ] Prediction endpoint returns valid results
- [ ] Metadata matches deployed version
- [ ] Error handling works (test with invalid input)

### 5. Monitor Initial Traffic

Watch metrics for first 30 minutes:
- Request rate and patterns
- Error rate (should be < 0.1%)
- Latency percentiles (p50, p95, p99)
- Resource usage (CPU, memory)

**Red flags:**
- Error rate > 1%
- P95 latency > 500ms
- Memory leaks (increasing usage)
- Crash loops

If red flags: **ROLLBACK IMMEDIATELY**

### 6. Update Registry

Record deployment in Tim's sidecar memory:

**deployment-registry.md:**
```markdown
## Deployment: 2026-03-26 14:30 UTC

**Model:** my-model
**Version:** v1.0.0
**Environment:** production
**Endpoint:** https://api.example.com/predict
**Strategy:** blue-green

**Pre-flight Checks:**
- ✅ Model validated by Alan
- ✅ Container tested locally
- ✅ Health endpoint verified
- ✅ Rollback plan ready

**Outcome:** ✅ Success
**Initial metrics:** Error rate 0.0%, p95 latency 87ms
```

**model-versions.md:**
```markdown
## Model: my-model v1.0.0

**Deployed:** 2026-03-26 14:30 UTC
**Status:** 🟢 Active in production
**Endpoint:** https://api.example.com/predict
**Performance:** Test RMSE 0.123, Accuracy 0.89
```

### 7. Create Rollback Script

```bash
#!/bin/bash
# rollback.sh - Emergency rollback to previous version

PREVIOUS_VERSION=${1:-v0.9.0}

echo "Rolling back to $PREVIOUS_VERSION"

# For Docker
docker stop model-api-prod
docker rm model-api-prod
docker run -d -p 8080:8080 --restart unless-stopped \
  --name model-api-prod \
  my-model-api:$PREVIOUS_VERSION

# Verify rollback
curl -f http://localhost:8080/ping && echo "✅ Rollback successful"
```

Make executable:
```bash
chmod +x rollback.sh
```

---

## Validation Checklist

Deployment complete when:
- [ ] API accessible at production URL
- [ ] Smoke tests passed
- [ ] Monitoring shows healthy metrics
- [ ] Registry updated
- [ ] Rollback script tested and ready
- [ ] Team notified

---

## Output

**Deployment artifacts:**
- Production API URL
- Deployment timestamp
- Updated registry (Tim's sidecar)
- `rollback.sh` — Emergency rollback script
- `DEPLOYMENT-LOG.md` — Deployment record

**Workflow complete!** Return to Tim's menu or proceed to [MM] Model Monitoring.
