#!/bin/bash
set -euo pipefail   # FIX: fail fast

mkdir -p logs       # FIX: ensure logs dir exists

# FIX: load env safely from .env (KEY=VALUE lines)
if [ ! -f .env ]; then
  echo "[ERROR] .env not found. Copy .env_example and set INFURA_URL."
  exit 1
fi
set -a
# shellcheck disable=SC1091
. ./.env
set +a

# FIX: hard-stop if the critical var is missing
if [ -z "${INFURA_URL:-}" ]; then
  echo "[ERROR] INFURA_URL is not set in .env"
  exit 1
fi

# FIX: make sure we can actually run on a fresh machine
if [ -f package-lock.json ]; then
  npm ci --no-audit --no-fund
else
  npm install --no-audit --no-fund
fi

npm run build

# Start both orchestrator and API, and wire up clean shutdown
node dist/app.js >> logs/output.log 2>&1 & APP_PID=$!
node dist/api.js >> logs/output.log 2>&1 & API_PID=$!

echo "app pid: $APP_PID | api pid: $API_PID (logs -> logs/output.log)"

trap 'kill "$APP_PID" "$API_PID" 2>/dev/null || true; wait "$APP_PID" "$API_PID" 2>/dev/null || true' INT TERM
wait "$APP_PID" "$API_PID"

