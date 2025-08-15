# Orchestrator

A tiny, zero-dependency Python HTTP service containerized with Docker, optionally orchestrated via docker-compose, and built automatically by GitHub Actions on every push to `main` (tagged with the commit SHA).

## Overview

- **Language:** Python 3.12 (slim base image)
- **Entrypoint:** `app.py` (standard-library HTTP server)
- **Endpoints:**
  - `GET /health` → returns `ok` (health probe)
  - `GET /` or `/ping` → returns `orchestrator up`

## Project Layout

```
.
├── app.py
├── Dockerfile
├── docker-compose.yml          # optional for local dev
├── .dockerignore               # recommended
└── .github
    └── workflows
        └── build-and-push.yml  # GitHub Actions (GHCR)
```

Suggested `.dockerignore`:

```
.venv/
__pycache__/
*.pyc
.git/
.DS_Store
.env
.env.*
```

## Run Locally

### Without Docker
```bash
python3 -m venv .venv
source .venv/bin/activate
python app.py
# verify
curl -fsS http://127.0.0.1:8000/health
```

### With Docker
```bash
docker build -t orchestrator:dev .
docker run --rm -p 8000:8000 orchestrator:dev
# verify
curl -fsS http://127.0.0.1:8000/health
```

### With docker-compose (recommended for dev)
```bash
docker compose up --build
# verify
curl -fsS http://127.0.0.1:8000/health
```

## Configuration

Environment variables:

| Name        | Default | Description                             |
| ----------- | ------- | --------------------------------------- |
| `PORT`      | `8000`  | Port the app listens on                 |
| `LOG_LEVEL` | `INFO`  | `DEBUG`, `INFO`, `WARNING`, `ERROR`     |

Examples:
```bash
docker run --rm -p 8080:8080 -e PORT=8080 orchestrator:dev
docker compose run --rm -e LOG_LEVEL=DEBUG orchestrator
```

## CI/CD (GitHub Actions → GHCR)

A workflow at `.github/workflows/build-and-push.yml` builds and pushes an image on every push to `main`. It tags images with **`latest`** and the **commit SHA**.

Resulting image names:
```
ghcr.io/<owner>/<repo>:latest
ghcr.io/<owner>/<repo>:<commit-sha>
```

> If this repo is **public** and you want the container to be publicly pullable, open GitHub → **Packages** → the image page → **Package settings** → set **Visibility** to **Public**.

### Pull & run (from any machine)
```bash
docker pull ghcr.io/<owner>/<repo>:latest
docker run --rm -p 8000:8000 ghcr.io/<owner>/<repo>:latest
```

If your package is private, log in first:
```bash
echo $GHCR_PAT | docker login ghcr.io -u <your-gh-username> --password-stdin
```

> PAT requires scope `read:packages` (and `write:packages` if pushing locally).

## Create & Push a New Public Repository

1. On GitHub, create a **public** repo (e.g., `orchestrator`).
2. Locally:
   ```bash
   git init
   git add .
   git commit -m "chore: containerize orchestrator + CI"
   git branch -M main
   git remote add origin git@github.com:<owner>/<repo>.git
   git push -u origin main
   ```
3. Check the **Actions** tab to see the build run and the **Packages** section for your image.

## Troubleshooting

- **`python: can't open file '/app/app.py'`**  
  Ensure `app.py` exists at the repo root (same level as `Dockerfile`) or change `CMD`/compose `command` to your actual script path.

- **Port conflicts**  
  Change host mapping, e.g. `-p 8080:8000`.

- **Buildkit / macOS Keychain quirks**  
  If you hit credential-helper issues on macOS, you can temporarily build with the classic builder:  
  `DOCKER_BUILDKIT=0 docker build -t orchestrator:dev .`

## License

MIT (or your preferred license).
