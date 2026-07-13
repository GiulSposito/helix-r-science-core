# Step 3: Containerize

**Workflow:** deploy-model
**Phase:** Docker Packaging
**Duration:** 3-6 hours

---

## Objective

Create optimized Docker image with R environment, dependencies, and model artifacts.

---

## Instructions

Act as Tim. Build a production-ready container that's secure, efficient, and reproducible.

### 1. Create Dockerfile

Generate multi-stage Dockerfile:

```dockerfile
# Stage 1: Build environment with dependencies
FROM rocker/r-ver:4.3.0 AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy renv files
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R

# Restore R packages
RUN R -e "renv::restore()"

# Stage 2: Runtime image (smaller)
FROM rocker/r-ver:4.3.0

# Copy installed packages from builder
COPY --from=builder /usr/local/lib/R/site-library /usr/local/lib/R/site-library

# Copy application code
WORKDIR /app
COPY plumber.R .
COPY vetiver-bundle.rds .
COPY config.yaml .

# Expose API port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8080/ping || exit 1

# Run as non-root user (security)
RUN useradd -m -u 1000 apiuser
USER apiuser

# Start API
CMD ["Rscript", "-e", "pr <- plumber::plumb('plumber.R'); pr$run(host='0.0.0.0', port=8080)"]
```

### 2. Create .dockerignore

Exclude unnecessary files:
```
.git
.Rproj.user
*.Rproj
data/raw/*
notebooks/*
.DS_Store
*.log
```

### 3. Build Docker Image

```bash
# Build image
docker build -t my-model-api:v1.0.0 .

# Tag for registry
docker tag my-model-api:v1.0.0 registry.example.com/my-model-api:v1.0.0
```

### 4. Test Container Locally

```bash
# Run container
docker run -d -p 8080:8080 --name model-api my-model-api:v1.0.0

# Test health
curl http://localhost:8080/ping

# Test prediction
curl -X POST http://localhost:8080/predict \
  -H "Content-Type: application/json" \
  -d '{"feature1": 1.0, "feature2": 2.0}'

# Check logs
docker logs model-api

# Cleanup
docker stop model-api && docker rm model-api
```

### 5. Optimize Image Size

Reduce image size:
- Use multi-stage builds (done above)
- Clean apt cache
- Remove build tools in runtime stage
- Use .dockerignore effectively

Target: < 1GB for final image

### 6. Create Docker Compose (Optional)

For local development:
```yaml
version: '3.8'
services:
  api:
    build: .
    ports:
      - "8080:8080"
    environment:
      - LOG_LEVEL=info
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/ping"]
      interval: 30s
      timeout: 3s
      retries: 3
```

---

## Validation Checklist

Before proceeding to Step 4:
- [ ] Docker image builds successfully
- [ ] Container runs without errors
- [ ] API endpoints accessible from container
- [ ] Health check passes
- [ ] Image size optimized (< 1.5GB)
- [ ] Security best practices followed (non-root user)

---

## Output

**Files created:**
- `Dockerfile` — Container definition
- `.dockerignore` — Build exclusions
- `docker-compose.yml` — Local orchestration
- `build.sh` — Build script with tagging

**Next:** Proceed to Step 4 (Deploy & Verify)
