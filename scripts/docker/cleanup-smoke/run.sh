#!/usr/bin/env bash
set -euo pipefail

cd /repo

export ATOMICBOT_STATE_DIR="/tmp/atomicbot-test"
export ATOMICBOT_CONFIG_PATH="${ATOMICBOT_STATE_DIR}/atomicbot.json"

echo "==> Build"
pnpm build

echo "==> Seed state"
mkdir -p "${ATOMICBOT_STATE_DIR}/credentials"
mkdir -p "${ATOMICBOT_STATE_DIR}/agents/main/sessions"
echo '{}' >"${ATOMICBOT_CONFIG_PATH}"
echo 'creds' >"${ATOMICBOT_STATE_DIR}/credentials/marker.txt"
echo 'session' >"${ATOMICBOT_STATE_DIR}/agents/main/sessions/sessions.json"

echo "==> Reset (config+creds+sessions)"
pnpm atomicbot reset --scope config+creds+sessions --yes --non-interactive

test ! -f "${ATOMICBOT_CONFIG_PATH}"
test ! -d "${ATOMICBOT_STATE_DIR}/credentials"
test ! -d "${ATOMICBOT_STATE_DIR}/agents/main/sessions"

echo "==> Recreate minimal config"
mkdir -p "${ATOMICBOT_STATE_DIR}/credentials"
echo '{}' >"${ATOMICBOT_CONFIG_PATH}"

echo "==> Uninstall (state only)"
pnpm atomicbot uninstall --state --yes --non-interactive

test ! -d "${ATOMICBOT_STATE_DIR}"

echo "OK"
