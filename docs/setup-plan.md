# Setup plan

## Phase 1 - Repo skeleton
- tạo cấu trúc repo
- thêm compose file
- thêm scripts cơ bản

## Phase 2 - Real OpenClaw runtime
- dùng official image `ghcr.io/openclaw/openclaw:latest`
- tách `openclaw-gateway` + `openclaw-cli`
- bind mount `OPENCLAW_CONFIG_DIR` -> `/home/node/.openclaw`
- bind mount `OPENCLAW_WORKSPACE_DIR` -> `/home/node/.openclaw/workspace`
- bootstrap bằng `--allow-unconfigured`
- thêm `/healthz` healthcheck

## Phase 3 - First boot flow
- `cp .env.example .env`
- `mkdir -p data/config data/workspace`
- `docker compose up -d openclaw-gateway`
- `docker compose run --rm openclaw-cli onboard`
- `docker compose run --rm openclaw-cli dashboard --no-open`
- approve device nếu bị pairing required

## Phase 4 - Ops hardening
- set token/auth tử tế
- cân nhắc reverse proxy / SSH tunnel / firewall
- thêm backup cho `data/config` và `data/workspace`
- cân nhắc pin version thay vì `latest`
- giữ non-root làm mặc định
- chỉ bật root qua `compose.root.yml` khi thật sự cần
