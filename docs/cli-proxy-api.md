# CLIProxyAPI add-on

This repo can also run a local CLIProxyAPI container alongside OpenClaw.

This document describes the local runtime setup only. The live config file is expected at `mounts/cli-proxy-api/config/config.yaml`, which is intentionally runtime-local and should usually stay out of git.

## What it does

CLIProxyAPI provides OpenAI/Gemini/Claude/Codex-compatible endpoints for CLI tools and OAuth-backed provider access.

Upstream repo:
- https://github.com/router-for-me/CLIProxyAPI

## Files used in this repo

- Compose service: `compose.yml`
- Default image tag in this repo: `eceasy/cli-proxy-api:v6.8.51`
- Example config: `config/cli-proxy-api.example.yaml`
- Runtime data dir: `./mounts/cli-proxy-api/`

## First-time setup

```bash
mkdir -p mounts/cli-proxy-api/config mounts/cli-proxy-api/auths mounts/cli-proxy-api/logs
cp config/cli-proxy-api.example.yaml mounts/cli-proxy-api/config/config.yaml
```

Then edit `mounts/cli-proxy-api/config/config.yaml`:

- set a strong `remote-management.secret-key`
- replace `api-keys` with your real client key(s)
- add provider credentials or OAuth-backed provider config sections as needed

## Start only CLIProxyAPI

```bash
docker compose up -d cli-proxy-api
```

## Start full stack

```bash
docker compose up -d
```

## Default ports in this repo

All ports are bound to localhost by default:

- API: `127.0.0.1:8317`
- management/web: `127.0.0.1:8085`
- extra upstream/helper ports from CLIProxyAPI:
  - `127.0.0.1:1455`
  - `127.0.0.1:54545`
  - `127.0.0.1:51121`
  - `127.0.0.1:11451`

These extra ports are kept to stay close to the upstream container defaults. If your use case only needs the main API and management UI, you can trim them later.

## Healthcheck

The compose service now includes a basic HTTP healthcheck against `http://127.0.0.1:8317/healthz`.

## Security notes

- Keep management access local unless you really need remote control.
- Set a non-empty management key before using management routes.
- Keep API keys and OAuth auth data under `./mounts/cli-proxy-api/` and back them up carefully.
- If exposing beyond localhost, put it behind a reverse proxy / tunnel / firewall rules first.
