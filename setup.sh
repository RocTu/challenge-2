#!/bin/bash
set -euo pipefail  # FIX: fail fast on errors/undefined vars

echo "[INFO] Installing Node.js dependencies..."
npm install

if [ ! -f .env ]; then
  if [ -f .env_example ]; then
    cp .env_example .env
    echo "[INFO] Copied .env_example to .env"
    echo "[WARN] Update your INFURA_URL in .env before proceeding."
  else
    echo "[ERROR] No .env or .env_example found. Cannot continue."
    exit 1
  fi
fi

# FIX: block starting later without the critical config present
if ! grep -qE '^INFURA_URL=' .env; then
  echo "[ERROR] INFURA_URL missing in .env. Set it before starting."
  exit 1
fi

echo "[Swap Optimizer Setup] Setup complete."  # FIX: do not start the app here

