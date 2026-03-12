# openclaw-docker-setup

Repo Docker/Compose tối giản nhưng **bám docs chính thức** để chạy OpenClaw thật.

## Mục tiêu

- Dùng **official image**: `ghcr.io/openclaw/openclaw`
- Tách `openclaw-gateway` và `openclaw-cli` giống flow trong docs
- Persist config + workspace bằng bind mounts
- Có healthcheck và flow onboard/pairing rõ ràng

## Cấu trúc

```text
openclaw-docker-setup/
├── README.md
├── .env.example
├── .gitignore
├── compose.yml
├── docker/
│   └── Dockerfile
├── config/
│   └── openclaw.example.env
├── scripts/
│   ├── up.sh
│   ├── down.sh
│   └── logs.sh
└── docs/
    └── setup-plan.md
```

## Cách dùng nhanh

### 1) Chuẩn bị env

```bash
cp .env.example .env
mkdir -p data/config data/workspace
```

### 2) Start gateway

```bash
docker compose up -d openclaw-gateway
```

### 3) Onboard / cấu hình ban đầu

```bash
docker compose run --rm openclaw-cli onboard
```

### 4) Lấy dashboard URL

```bash
docker compose run --rm openclaw-cli dashboard --no-open
```

Sau đó mở `http://127.0.0.1:18789/` và paste token vào Control UI nếu cần.

## Lệnh hay dùng

```bash
docker compose logs -f openclaw-gateway
docker compose run --rm openclaw-cli status
docker compose run --rm openclaw-cli devices list
docker compose run --rm openclaw-cli config set gateway.mode local
docker compose run --rm openclaw-cli config set gateway.bind lan
```

## Notes quan trọng

- Theo docs, Docker là **optional** nhưng hợp lý nếu muốn containerized gateway.
- Gateway đang bind port theo kiểu an toàn hơn: `127.0.0.1:${OPENCLAW_GATEWAY_PORT}:18789`
- `openclaw-cli` dùng `network_mode: service:openclaw-gateway` để gọi gateway qua loopback trong Docker namespace chung.
- `--allow-unconfigured` chỉ để bootstrap ban đầu; xong rồi vẫn nên cấu hình auth/token tử tế.
- Dữ liệu persistent nằm ở:
  - `./data/config`
  - `./data/workspace`

## Tài liệu tham chiếu

- Docker install: `/app/docs/install/docker.md`
- GCP deployment example: `/app/docs/install/gcp.md`
- Hetzner deployment example: `/app/docs/install/hetzner.md`
