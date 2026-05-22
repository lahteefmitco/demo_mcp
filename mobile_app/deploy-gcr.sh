#!/usr/bin/env bash
# Build mobile_app Docker image, push to Google Artifact Registry, deploy to Cloud Run.
# API URL is baked in via Dockerfile ARG (default: demo-mcp Cloud Run API).
#
# Prerequisites: Docker, gcloud CLI, billing-enabled GCP project.
# Usage:
#   export GCP_PROJECT_ID=your-project-id   # required (not the numeric project number)
#   ./deploy-gcr.sh
#
# Optional env:
#   REGION=europe-west1
#   REPOSITORY=finance-apps
#   IMAGE_NAME=finance-web
#   SERVICE_NAME=finance-web
#   TAG=latest
#   API_BASE_URL=https://demo-mcp-615058378594.europe-west1.run.app
#   DOCKER_PLATFORM=linux/amd64   # required on Apple Silicon Macs

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

REGION="${REGION:-europe-west1}"
REPOSITORY="${REPOSITORY:-finance-apps}"
IMAGE_NAME="${IMAGE_NAME:-finance-web}"
SERVICE_NAME="${SERVICE_NAME:-finance-web}"
TAG="${TAG:-latest}"
API_BASE_URL="${API_BASE_URL:-https://demo-mcp-615058378594.europe-west1.run.app}"
DOCKER_PLATFORM="${DOCKER_PLATFORM:-linux/amd64}"

if [[ -z "${GCP_PROJECT_ID:-}" ]]; then
  echo "ERROR: Set GCP_PROJECT_ID to your Google Cloud project ID (string id, not 615058378594)." >&2
  echo "  gcloud projects list" >&2
  exit 1
fi

if ! command -v gcloud >/dev/null 2>&1; then
  echo "ERROR: gcloud CLI not found. Install: https://cloud.google.com/sdk/docs/install" >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker not found." >&2
  exit 1
fi

IMAGE_URI="${REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}:${TAG}"

echo "==> Project: ${GCP_PROJECT_ID}  Region: ${REGION}"
echo "==> Image:   ${IMAGE_URI}"
echo "==> API:     ${API_BASE_URL}"

gcloud config set project "${GCP_PROJECT_ID}"

echo "==> Enabling APIs (idempotent)..."
gcloud services enable run.googleapis.com artifactregistry.googleapis.com --quiet

echo "==> Docker auth for Artifact Registry..."
gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet

echo "==> Artifact Registry repository (create if missing)..."
if ! gcloud artifacts repositories describe "${REPOSITORY}" --location="${REGION}" >/dev/null 2>&1; then
  gcloud artifacts repositories create "${REPOSITORY}" \
    --repository-format=docker \
    --location="${REGION}" \
    --description="Finance Flutter web images"
fi

echo "==> Building image from mobile_app/ (platform: ${DOCKER_PLATFORM}) ..."
docker build \
  --platform "${DOCKER_PLATFORM}" \
  --build-arg "API_BASE_URL=${API_BASE_URL}" \
  -t "${IMAGE_URI}" \
  .

echo "==> Pushing to Artifact Registry..."
docker push "${IMAGE_URI}"

echo "==> Deploying to Cloud Run..."
gcloud run deploy "${SERVICE_NAME}" \
  --image "${IMAGE_URI}" \
  --region "${REGION}" \
  --platform managed \
  --allow-unauthenticated \
  --port 8080

WEB_URL="$(gcloud run services describe "${SERVICE_NAME}" \
  --region "${REGION}" \
  --format='value(status.url)')"

echo ""
echo "Deployed: ${WEB_URL}"
echo ""
echo "Post-deploy (required):"
echo "  1. API CORS — allow this web origin on the API Cloud Run service:"
echo "     gcloud run services update demo-mcp --region ${REGION} \\"
echo "       --update-env-vars \"CORS_ORIGINS=${WEB_URL}\""
echo "     (Use your real API service name if not demo-mcp.)"
echo ""
echo "  2. Google Sign-In — add ${WEB_URL} to OAuth Web client authorized JavaScript origins."
echo ""
echo "Local test before push:"
echo "  docker build -t finance-web:local ."
echo "  docker run --rm -p 8081:8080 finance-web:local"
echo "  open http://localhost:8081"
