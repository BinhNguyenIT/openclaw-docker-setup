# openclaw-docker-setup

Repo Docker/Compose tối giản nhưng **bám docs chính thức** để chạy OpenClaw thật.

## Mục tiêu

- Dùng **official image**: `ghcr.io/openclaw/openclaw:2026.3.8` (mặc định pin version)
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

## Root override khi cần

Mặc định stack này chạy theo hướng an toàn hơn. Nếu bạn muốn ép container chạy root cho mục đích dev/debug/convenience, dùng file override:

```bash
docker compose -f compose.yml -f compose.root.yml up -d
```

Hoặc chạy lệnh CLI với root override:

```bash
docker compose -f compose.yml -f compose.root.yml run --rm openclaw-cli status
```

`compose.root.yml` chỉ set:

- `user: "0:0"` cho `openclaw-gateway`
- `user: "0:0"` cho `openclaw-cli`

Nên coi đây là **break-glass / convenience mode**, không phải mặc định lâu dài cho production.

## Notes quan trọng

- Theo docs, Docker là **optional** nhưng hợp lý nếu muốn containerized gateway.
- Repo này mặc định **pin `ghcr.io/openclaw/openclaw:2026.3.8`** thay vì dùng `latest`.
- Lý do: setup ổn định hơn, dễ reproduce hơn, và debug dễ hơn khi có issue.
- Nếu bạn thích sống nhanh với feature mới, vẫn có thể đổi `OPENCLAW_IMAGE` trong `.env`, nhưng nên coi đó là lựa chọn chủ động.
- Gateway đang bind port theo kiểu an toàn hơn: `127.0.0.1:${OPENCLAW_GATEWAY_PORT}:18789`
- `openclaw-cli` dùng `network_mode: service:openclaw-gateway` để gọi gateway qua loopback trong Docker namespace chung.
- `--allow-unconfigured` chỉ để bootstrap ban đầu; xong rồi vẫn nên cấu hình auth/token tử tế.
- Dữ liệu persistent nằm ở:
  - `./data/config`
  - `./data/workspace`

## Upgrade version sau này

Khi cần bump khỏi `2026.3.8`, nên làm theo flow này:

1. đổi `OPENCLAW_IMAGE` trong `.env` hoặc fallback trong `compose.yml`
2. pull image mới và restart stack
3. test lại các flow chính (`status`, onboarding/dashboard nếu liên quan, gateway healthcheck)
4. nếu hành vi thay đổi, cập nhật README/docs tương ứng

Khuyến nghị: tránh để `latest` làm mặc định trong repo. Dùng version pin để predictable hơn, rồi nâng version theo đợt khi đã test.

## Tài liệu tham chiếu

- Docker install: `/app/docs/install/docker.md`
- GCP deployment example: `/app/docs/install/gcp.md`
- Hetzner deployment example: `/app/docs/install/hetzner.md`
