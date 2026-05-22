#!/usr/bin/env bash
# Build and push mobile_app image to Docker Hub.
#
# Usage:
#   export DOCKERHUB_USER=latheefoxdo   # must match `docker login` account
#   ./deploy-dockerhub.sh
# If unset, uses the username stored in ~/.docker/config.json (after docker login).
#
# Optional: TAG=latest  API_BASE_URL=...  DOCKER_PLATFORM=linux/amd64 (required for Cloud Run)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

IMAGE_NAME="${IMAGE_NAME:-finance-web}"
TAG="${TAG:-latest}"
API_BASE_URL="${API_BASE_URL:-https://demo-mcp-615058378594.europe-west1.run.app}"
# Cloud Run requires amd64; Mac builds default to arm64 without this.
DOCKER_PLATFORM="${DOCKER_PLATFORM:-linux/amd64}"

_resolve_dockerhub_user() {
  if [[ -n "${DOCKERHUB_USER:-}" ]]; then
    echo "${DOCKERHUB_USER}"
    return
  fi
  local config="${HOME}/.docker/config.json"
  if [[ -f "${config}" ]] && command -v jq >/dev/null 2>&1; then
    local u
    u="$(jq -r '.auths["https://index.docker.io/v1/"].username // empty' "${config}" 2>/dev/null)"
    if [[ -n "${u}" && "${u}" != "null" ]]; then
      echo "${u}"
      return
    fi
  fi
  echo ""
}

DOCKERHUB_USER="$(_resolve_dockerhub_user)"

if [[ -z "${DOCKERHUB_USER}" ]]; then
  echo "ERROR: Set DOCKERHUB_USER to the same username you use for docker login." >&2
  echo "  Example: export DOCKERHUB_USER=latheefoxdo" >&2
  exit 1
fi

if [[ "${DOCKERHUB_USER}" == "yourusername" || "${DOCKERHUB_USER}" == "YOUR_DOCKERHUB_USER" ]]; then
  echo "ERROR: DOCKERHUB_USER is still the docs placeholder (${DOCKERHUB_USER})." >&2
  echo "  Use your real Docker Hub username (you logged in as latheefoxdo)." >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker not found." >&2
  exit 1
fi

IMAGE_URI="${DOCKERHUB_USER}/${IMAGE_NAME}:${TAG}"

echo "==> Building ${IMAGE_URI}"
echo "    API: ${API_BASE_URL}"
echo "    Platform: ${DOCKER_PLATFORM} (Cloud Run needs linux/amd64)"

docker build \
  --platform "${DOCKER_PLATFORM}" \
  --build-arg "API_BASE_URL=${API_BASE_URL}" \
  -t "${IMAGE_URI}" \
  .

echo "==> Log in if needed: docker login"
docker push "${IMAGE_URI}"

echo ""
echo "Pushed: ${IMAGE_URI}"
echo "Run locally: docker run --rm -p 8081:8080 ${IMAGE_URI}"
