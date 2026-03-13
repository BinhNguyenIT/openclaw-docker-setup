# Running a second OpenClaw instance

This repo can run a second OpenClaw stack on the same machine by using a separate env file.

## Why it works

The second instance uses separate values for:

- `COMPOSE_PROJECT_NAME`
- container names
- gateway port
- config/workspace directories
- CLIProxyAPI ports and data paths

That keeps the two stacks isolated.

## Files added for instance 2

- `.env.instance-2.example`
- `scripts/up-instance-2.sh`
- `scripts/onboard-instance-2.sh`
- `scripts/dashboard-instance-2.sh`
- `scripts/down-instance-2.sh`

## First-time setup

```bash
cp .env.instance-2.example .env.instance-2
mkdir -p data2/config data2/workspace
mkdir -p data2/cli-proxy-api/auths data2/cli-proxy-api/logs
cp config/cli-proxy-api.example.yaml data2/cli-proxy-api/config.yaml
```

## Start the second gateway

```bash
./scripts/up-instance-2.sh
```

## Onboard the second instance

```bash
./scripts/onboard-instance-2.sh
```

## Get the second dashboard URL

```bash
./scripts/dashboard-instance-2.sh
```

The second OpenClaw gateway defaults to `http://127.0.0.1:18790/`.

The second CLIProxyAPI defaults to:

- API: `127.0.0.1:8318`
- management: `127.0.0.1:8086`

## Stop the second stack

```bash
./scripts/down-instance-2.sh
```

## Notes

- Do not reuse `data/` for the second instance; use `data2/` or another separate path.
- If you do not need CLIProxyAPI for instance 2, you can ignore those paths and ports.
- Keep both stacks pinned and upgraded intentionally.
