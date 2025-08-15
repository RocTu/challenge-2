1) Local (without Docker)
python3 -m venv .venv
source .venv/bin/activate
python app.py
# open another terminal:
curl -fsS http://127.0.0.1:8000/health

2) With Docker
docker build -t orchestrator:dev .
docker run --rm -it -p 8000:8000 orchestrator:dev
# verify:
curl -fsS http://127.0.0.1:8000/health

3) With docker-compose (recommended for dev)
docker compose up --build
# verify:
curl -fsS http://127.0.0.1:8000/health
