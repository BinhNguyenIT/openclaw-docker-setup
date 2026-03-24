# Running a second OpenClaw instance

This repo can run a second OpenClaw stack on the same machine by using a separate env file.

Recommended layout for this repo:

- instance 1 runs OpenClaw + the shared CLIProxyAPI sidecar
- instance 2 runs only OpenClaw
- both OpenClaw instances can point to the same CLIProxyAPI endpoint if you want one shared provider/auth layer

## Why it works

The second instance uses separate values for:

- `COMPOSE_PROJECT_NAME`
- container names
- gateway port
- OpenClaw root directory

That keeps the two OpenClaw stacks isolated while avoiding a second proxy container.

## Files added for instance 2

- `.env.instance-2.example`
- `scripts/up-instance-2.sh`
- `scripts/onboard-instance-2.sh`
- `scripts/dashboard-instance-2.sh`
- `scripts/down-instance-2.sh`

## First-time setup

```bash
cp .env.instance-2.example .env.instance-2
mkdir -p mounts/openclaw2/root/workspace
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

The shared CLIProxyAPI remains the one from instance 1, which by default exposes:

- API: `127.0.0.1:8317`
- management: `127.0.0.1:8085`

## Stop the second stack

```bash
./scripts/down-instance-2.sh
```

## Notes

- Do not reuse the same OpenClaw root path for the second instance.
- In the recommended setup, instance 2 does not need its own CLIProxyAPI ports, auth dir, or config dir.
- Sharing one CLIProxyAPI means both OpenClaw instances share the same provider auth/config layer.
- Keep both stacks pinned and upgraded intentionally.
