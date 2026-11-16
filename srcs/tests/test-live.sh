#!/bin/sh
# Inspect an already running stack without starting, stopping, or changing it.
set -eu
cd "$(dirname "$0")/../.."
running=$(docker compose -f srcs/docker-compose.yml --env-file srcs/.env ps --status running --services)
for service in mariadb redis wordpress nginx; do
    printf '%s\n' "$running" | grep -qx "$service" || {
        printf 'Service is not running: %s\n' "$service" >&2
        exit 1
    }
    container=$(docker compose -f srcs/docker-compose.yml --env-file srcs/.env ps -q "$service")
    health=$(docker inspect --format '{{.State.Health.Status}}' "$container")
    test "$health" = healthy || {
        printf 'Service is not healthy: %s\n' "$service" >&2
        exit 1
    }
done
curl --insecure --fail --silent --show-error --max-time 15 \
    --output /dev/null "${TEST_URL:-https://127.0.0.1}"
printf '%s\n' 'Live container health and HTTPS checks passed'
