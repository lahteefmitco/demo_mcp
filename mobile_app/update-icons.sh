#!/usr/bin/env bash
# Regenerate web (and mobile) launcher icons from assets/app_icon.png, then optionally deploy.
#
# 1. Replace the source image (square, at least 1024×1024 PNG recommended):
#      mobile_app/assets/app_icon.png
# 2. Run:
#      ./update-icons.sh
# 3. Deploy:
#      export DOCKERHUB_USER=latheefoxdo
#      ./deploy-dockerhub.sh
#    Then redeploy Cloud Run with the new image tag if needed.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ICON_SRC="assets/app_icon.png"

if [[ ! -f "${ICON_SRC}" ]]; then
  echo "ERROR: Missing ${ICON_SRC}" >&2
  echo "Add your app icon there (1024×1024 PNG), then run this script again." >&2
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: flutter not in PATH. Install Flutter SDK first." >&2
  exit 1
fi

echo "==> Generating icons from ${ICON_SRC} ..."
flutter pub get
dart run flutter_launcher_icons

echo ""
echo "Updated web assets:"
echo "  web/favicon.png"
echo "  web/icons/Icon-192.png"
echo "  web/icons/Icon-512.png"
echo "  web/icons/Icon-maskable-192.png"
echo "  web/icons/Icon-maskable-512.png"
echo ""
echo "Next: rebuild and push the Docker image (Cloud Run needs linux/amd64):"
echo "  export DOCKERHUB_USER=latheefoxdo"
echo "  ./deploy-dockerhub.sh"
