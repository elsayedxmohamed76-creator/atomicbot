#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="${ATOMICBOT_IMAGE:-${ATOMICBOT_IMAGE:-atomicbot:local}}"
CONFIG_DIR="${ATOMICBOT_CONFIG_DIR:-${ATOMICBOT_CONFIG_DIR:-$HOME/.atomicbot}}"
WORKSPACE_DIR="${ATOMICBOT_WORKSPACE_DIR:-${ATOMICBOT_WORKSPACE_DIR:-$HOME/.atomicbot/workspace}}"
PROFILE_FILE="${ATOMICBOT_PROFILE_FILE:-${ATOMICBOT_PROFILE_FILE:-$HOME/.profile}}"

PROFILE_MOUNT=()
if [[ -f "$PROFILE_FILE" ]]; then
  PROFILE_MOUNT=(-v "$PROFILE_FILE":/home/node/.profile:ro)
fi

echo "==> Build image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" -f "$ROOT_DIR/Dockerfile" "$ROOT_DIR"

echo "==> Run live model tests (profile keys)"
docker run --rm -t \
  --entrypoint bash \
  -e COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
  -e HOME=/home/node \
  -e NODE_OPTIONS=--disable-warning=ExperimentalWarning \
  -e ATOMICBOT_LIVE_TEST=1 \
  -e ATOMICBOT_LIVE_MODELS="${ATOMICBOT_LIVE_MODELS:-${ATOMICBOT_LIVE_MODELS:-all}}" \
  -e ATOMICBOT_LIVE_PROVIDERS="${ATOMICBOT_LIVE_PROVIDERS:-${ATOMICBOT_LIVE_PROVIDERS:-}}" \
  -e ATOMICBOT_LIVE_MODEL_TIMEOUT_MS="${ATOMICBOT_LIVE_MODEL_TIMEOUT_MS:-${ATOMICBOT_LIVE_MODEL_TIMEOUT_MS:-}}" \
  -e ATOMICBOT_LIVE_REQUIRE_PROFILE_KEYS="${ATOMICBOT_LIVE_REQUIRE_PROFILE_KEYS:-${ATOMICBOT_LIVE_REQUIRE_PROFILE_KEYS:-}}" \
  -v "$CONFIG_DIR":/home/node/.atomicbot \
  -v "$WORKSPACE_DIR":/home/node/.atomicbot/workspace \
  "${PROFILE_MOUNT[@]}" \
  "$IMAGE_NAME" \
  -lc "set -euo pipefail; [ -f \"$HOME/.profile\" ] && source \"$HOME/.profile\" || true; cd /app && pnpm test:live"
