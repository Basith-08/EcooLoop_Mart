#!/bin/bash

# EcoLoop Mart - Development via Docker
set -e

COMPOSE_FILE="docker/docker-compose.yml"

if command -v docker compose >/dev/null 2>&1; then
  DOCKER_COMPOSE=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  DOCKER_COMPOSE=(docker-compose)
else
  echo "Docker Compose is required but not installed." >&2
  exit 1
fi

"${DOCKER_COMPOSE[@]}" -f "$COMPOSE_FILE" up --build
