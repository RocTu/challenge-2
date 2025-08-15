# syntax=docker/dockerfile:1.7
FROM python:3.12-slim

# Minimal base tooling for healthcheck and diagnostics
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Keep Python fast & predictable inside containers
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    APP_HOME=/app

WORKDIR $APP_HOME

# (Leverage layer caching) — install deps first
# If you also have requirements-dev.txt, it will be picked up too.
COPY requirements*.txt ./
RUN python -m pip install --upgrade pip && \
    if [ -f requirements.txt ] && [ -s requirements.txt ]; then pip install -r requirements.txt; fi && \
    if [ -f requirements-dev.txt ] && [ -s requirements-dev.txt ]; then pip install -r requirements-dev.txt; fi

# Copy the app
COPY . .

# Drop privileges (best practice)
RUN useradd --uid 10001 --create-home appuser && chown -R appuser:appuser $APP_HOME
USER appuser

# Default port (override via env if needed)
ENV PORT=8000

# Healthcheck (expects your app to serve /health on $PORT)
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -fsS http://127.0.0.1:${PORT}/health || exit 1

# ---- Entry point ----
# Change this if your entry is different, e.g. ["python","-m","orchestrator"]
CMD ["python", "app.py"]

