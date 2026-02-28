#!/usr/bin/env bash
# Levinix: The "No Problem" Universal Packager
set -euo pipefail

# 1. Configuration (The "White Label" variables)
REPO_USER="pipulate"
REPO_NAME="levinix"
BRANCH="main"
APP_NAME="${1:-$REPO_NAME}"
TARGET_DIR="${HOME}/${APP_NAME}"
ZIP_URL="https://github.com/${REPO_USER}/${REPO_NAME}/archive/refs/heads/${BRANCH}.zip"

echo "⚡ INITIALIZING LEVINIX ENVIRONMENT: ${APP_NAME^^} ⚡"

# 2. The Universe Builder (Nix Foundation Check)
if ! command -v nix &> /dev/null; then
    echo "📦 Nix Package Manager not found. Inventing the universe..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    
    echo "=================================================================="
    echo "⚠️  CRITICAL: The universe has been built, but you must enter it."
    echo "Please CLOSE this terminal window, open a NEW one, and re-run:"
    echo "curl -L https://levinix.com/install.sh | bash -s ${APP_NAME}"
    echo "=================================================================="
    exit 0
fi

if [ -d "${TARGET_DIR}" ]; then
    echo "❌ Error: '${TARGET_DIR}' already exists. To run it: cd ${TARGET_DIR} && ./run"
    exit 1
fi

# 3. The Magic Cookie Fetch (Downloading the Shell)
echo "📥 Fetching source DNA from ${REPO_USER}/${REPO_NAME}..."
TMP_ZIP=$(mktemp)
curl -L -sS --fail -o "${TMP_ZIP}" "${ZIP_URL}"
TMP_EXTRACT=$(mktemp -d)
unzip -q "${TMP_ZIP}" -d "${TMP_EXTRACT}"
cp -R "${TMP_EXTRACT}/${REPO_NAME}-${BRANCH}/." "${TARGET_DIR}/"
rm -rf "${TMP_ZIP}" "${TMP_EXTRACT}"

# 4. Create the 'Double-Click' Actuator
cat > "${TARGET_DIR}/run" << 'EOF'
#!/usr/bin/env bash
cd "$(dirname "$0")" 
exec nix develop
EOF
chmod +x "${TARGET_DIR}/run"

echo "$APP_NAME" > "${TARGET_DIR}/.app_identity"

echo "✅ Environment staged. To launch the app, type:"
echo "   cd ${TARGET_DIR} && ./run"
