# Flutter web on Google Cloud Run

This folder has its **own** `Dockerfile` and `.dockerignore`. The Express API at the repo root is unchanged:

| Component | Docker path | Deploy context |
|-----------|-------------|----------------|
| **API (Node)** | `/Dockerfile` | repo root `.` |
| **Web (Flutter)** | `/mobile_app/Dockerfile` | `mobile_app/` |

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (`gcloud`)
- GCP project with billing enabled
- APIs enabled (once per project):

```bash
gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com
```

- Flutter web assets already in the repo: `web/sqlite3.wasm`, `web/drift_worker.js` (required for Drift on web)

---

## 1. Test locally with Docker

### A. API only (existing backend image)

From the **repo root**:

```bash
docker build -t finance-api:local .
docker run --rm -p 8080:8080 --env-file .env finance-api:local
```

API: `http://localhost:8080`

### B. Web app image

From **`mobile_app/`**:

```bash
cd mobile_app

# Point the built app at your API (local API in another container or on the host)
docker build \
  --build-arg API_BASE_URL=http://host.docker.internal:8080 \
  -t finance-web:local .

docker run --rm -p 8081:8080 finance-web:local
```

Web UI: `http://localhost:8081`

**Linux:** if `host.docker.internal` does not work, use your machine IP or run the API container on the same Docker network and pass `http://finance-api:8080`.

### C. API + web together (example)

Terminal 1 (repo root):

```bash
docker build -t finance-api:local .
docker run --rm -p 8080:8080 --env-file .env \
  -e CORS_ORIGINS=http://localhost:8081 \
  finance-api:local
```

Terminal 2 (`mobile_app/`):

```bash
docker build --build-arg API_BASE_URL=http://host.docker.internal:8080 -t finance-web:local .
docker run --rm -p 8081:8080 finance-web:local
```

Open `http://localhost:8081` and sign in. The API must allow the web origin via `CORS_ORIGINS` (or `CORS_ALLOW_ALL=true` for local dev only).

---

## 2. Deploy API to Cloud Run (unchanged)

From the **repo root** (existing flow):

```bash
gcloud config set project YOUR_GCP_PROJECT_ID

gcloud run deploy finance-api \
  --source . \
  --region YOUR_REGION \
  --allow-unauthenticated \
  --set-secrets DATABASE_URL=neon-database-url:latest,AUTH_SECRET=auth-secret:latest \
  --set-env-vars "APP_BASE_URL=https://finance-api-XXXX.a.run.app,CORS_ALLOW_ALL=false"
```

Note the API URL (e.g. `https://finance-api-xxxxx-ew.a.run.app`). You will need it for the web build and for `CORS_ORIGINS`.

---

## 3. Deploy Flutter web to Cloud Run

### Option A — Build image locally, push to Artifact Registry

```bash
export PROJECT_ID=YOUR_GCP_PROJECT_ID
export REGION=YOUR_REGION          # e.g. europe-west1
export API_URL=https://finance-api-XXXX.a.run.app
export WEB_SERVICE=finance-web

gcloud auth configure-docker ${REGION}-docker.pkg.dev

# Create repo once
gcloud artifacts repositories create finance-apps \
  --repository-format=docker \
  --location=${REGION} \
  || true

cd mobile_app

docker build \
  --build-arg API_BASE_URL=${API_URL} \
  -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/finance-apps/${WEB_SERVICE}:latest .

docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/finance-apps/${WEB_SERVICE}:latest

gcloud run deploy ${WEB_SERVICE} \
  --image ${REGION}-docker.pkg.dev/${PROJECT_ID}/finance-apps/${WEB_SERVICE}:latest \
  --region ${REGION} \
  --allow-unauthenticated \
  --port 8080
```

### Option B — Cloud Build from source (`gcloud run deploy --source`)

```bash
export PROJECT_ID=YOUR_GCP_PROJECT_ID
export REGION=YOUR_REGION
export API_URL=https://finance-api-XXXX.a.run.app

gcloud run deploy finance-web \
  --source mobile_app \
  --region ${REGION} \
  --allow-unauthenticated \
  --port 8080 \
  --set-build-env-vars API_BASE_URL=${API_URL}
```

`API_BASE_URL` is passed into the Docker build as the `ARG` in `mobile_app/Dockerfile`.

After deploy, note the web URL, e.g. `https://finance-web-xxxxx-ew.a.run.app`.

---

## 4. Post-deploy configuration (required)

### API CORS

Update the **API** Cloud Run service so browsers can call it from the web URL:

```bash
gcloud run services update finance-api \
  --region YOUR_REGION \
  --update-env-vars "CORS_ORIGINS=https://finance-web-XXXX.a.run.app"
```

Use your real web URL. Multiple origins: comma-separated, no spaces.

### Google Sign-In (web)

In [Google Cloud Console → APIs & Credentials → OAuth 2.0 Web client](https://console.cloud.google.com/apis/credentials):

1. **Authorized JavaScript origins:** add `https://finance-web-XXXX.a.run.app` (and `http://localhost:8081` for local Docker tests).
2. Keep the same client ID as in `web/index.html` (`google-signin-client_id` meta tag).

### Rebuild web after API URL changes

`API_BASE_URL` is compiled into the Flutter web bundle. If the API URL changes, rebuild and redeploy the web image with the new `--build-arg API_BASE_URL=...`.

---

## 5. Verify production

```bash
# Web app serves HTML
curl -sI "https://finance-web-XXXX.a.run.app" | head -5

# WASM is served with correct type (Drift)
curl -sI "https://finance-web-XXXX.a.run.app/sqlite3.wasm" | grep -i content-type

# API health (adjust path if you have a health route)
curl -sI "https://finance-api-XXXX.a.run.app/api/auth/me" | head -5
```

In the browser: open the web URL, sign in, and confirm network calls go to the API URL you set in `API_BASE_URL`.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|--------|----------------|-----|
| CORS errors in browser | API `CORS_ORIGINS` missing web URL | Update API env vars (section 4) |
| Google Sign-In fails | OAuth origins | Add web URL to JS origins |
| Blank DB / Drift errors | Missing wasm assets in image | Ensure `web/sqlite3.wasm` and `web/drift_worker.js` exist before `docker build` |
| API calls wrong host | Stale build | Rebuild with correct `API_BASE_URL` |
| 404 on refresh deep link | SPA routing | nginx template already uses `try_files … /index.html` |

---

## File layout

```
demo_mcp/
├── Dockerfile              # Node API (unchanged)
├── .dockerignore             # API build ignores mobile_app/ (unchanged)
└── mobile_app/
    ├── Dockerfile            # Flutter web → nginx
    ├── .dockerignore         # Web-only ignore rules
    ├── nginx/
    │   └── default.conf.template
    └── DEPLOY_CLOUD_RUN.md   # This guide
```
