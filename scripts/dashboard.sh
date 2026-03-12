#!/usr/bin/env bash
set -euo pipefail

docker compose run --rm openclaw-cli dashboard --no-open
