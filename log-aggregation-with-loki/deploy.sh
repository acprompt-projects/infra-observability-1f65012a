#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOKI_DIR="${SCRIPT_DIR}/loki"

ensure_network() {
  docker network inspect infra-observability_net >/dev/null 2>&1 \
    || docker network create infra-observability_net
}

ensure_log_dirs() {
  sudo mkdir -p /var/log/infra /var/log/app
  sudo chmod 755 /var/log/infra /var/log/app
}

deploy() {
  ensure_network
  ensure_log_dirs
  echo ">>> Deploying Loki + Promtail..."
  docker compose -f "${LOKI_DIR}/docker-compose.yaml" up -d
  echo ">>> Waiting for Loki to become ready..."
  for i in $(seq 1 30); do
    if curl -sf http://localhost:3100/ready >/dev/null 2>&1; then
      echo ">>> Loki is ready at http://localhost:3100"
      return 0
    fi
    sleep 2
  done
  echo "ERROR: Loki did not become ready in time" >&2
  return 1
}

teardown() {
  echo ">>> Stopping Loki + Promtail..."
  docker compose -f "${LOKI_DIR}/docker-compose.yaml" down
}

case "${1:-deploy}" in
  deploy)   deploy   ;;
  teardown) teardown ;;
  *) echo "Usage: $0 {deploy|teardown}" >&2; exit 1 ;;
esac