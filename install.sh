#!/bin/bash
set -euo pipefail  # fail fast on errors/undefined vars/pipe failures

REPO_URL="${REPO_URL:-https://github.com/veltrix-capital/test-devops-orchestrators.git}"
REPO_DIR="${REPO_DIR:-test-devops-orchestrators}"

if [ -d "${REPO_DIR}/.git" ]; then
  echo "[+] Repository exists. Pulling latest changes..."
  cd "$REPO_DIR"
  git pull
else
  echo "[+] Repository not found. Installing git if needed and cloning..."
  if ! command -v git >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
      brew install git
    else
      echo "[WARN] Homebrew not found; please install git manually if this fails."
    fi
  fi
  echo "[+] Cloning repository..."
  git clone "$REPO_URL" "$REPO_DIR"
  cd "$REPO_DIR" || { echo "Failed to enter directory"; exit 1; }
fi

echo "[+] Granting execution permissions..."
chmod +x setup.sh start.sh || true

echo "[+] Running setup.sh..."
./setup.sh

echo "[+] Running start.sh..."
./start.sh

echo "Setup is completed"

