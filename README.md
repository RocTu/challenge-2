

# Build & run directly
# build
docker build -t orchestrator:dev .
#
docker run --rm -p 8080:3000 --env-file .env orchestrator:dev



# Quick start (docker-compose)
docker compose up --build
