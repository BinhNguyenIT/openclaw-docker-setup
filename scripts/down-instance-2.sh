#!/usr/bin/env bash
set -euo pipefail

docker compose --env-file .env.instance-2 down
