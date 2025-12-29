#!/bin/bash

# EcoLoop Mart - Build Android APK via Docker
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

"${DOCKER_COMPOSE[@]}" -f "$COMPOSE_FILE" build flutter_app
"${DOCKER_COMPOSE[@]}" -f "$COMPOSE_FILE" run --rm flutter_app bash -lc "flutter pub get && flutter build apk --release"

echo "APK generated at build/app/outputs/flutter-apk/app-release.apk"
