#!/usr/bin/env bash
set -euo pipefail

docker compose --env-file .env.instance-2 run --rm openclaw-cli dashboard --no-open
