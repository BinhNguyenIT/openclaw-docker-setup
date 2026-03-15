# openclaw-docker-setup

Repo Docker/Compose tối giản nhưng **bám docs chính thức** để chạy OpenClaw thật.

## Mục tiêu

- Dùng **official image**: `ghcr.io/openclaw/openclaw:2026.3.8` (mặc định pin version)
- Tách `openclaw-gateway` và `openclaw-cli` giống flow trong docs
- Có thêm **CLIProxyAPI sidecar** và mặc định pin `eceasy/cli-proxy-api:v6.8.51`
- Persist state bằng bind mounts theo layout dễ nhìn trong repo
- Có healthcheck và flow onboard/pairing rõ ràng

## Cấu trúc

```text
openclaw-docker-setup/
├── README.md
├── .env.example
├── .env.instance-2.example
├── .gitignore
├── compose.yml
├── compose.root.yml
├── docker/
│   └── Dockerfile
├── config/
│   ├── openclaw.example.env
│   └── cli-proxy-api.example.yaml
├── scripts/
│   ├── up.sh
│   ├── down.sh
│   ├── logs.sh
│   ├── onboard.sh
│   ├── dashboard.sh
│   ├── up-instance-2.sh
│   ├── onboard-instance-2.sh
│   ├── dashboard-instance-2.sh
│   └── down-instance-2.sh
└── docs/
    ├── setup-plan.md
    ├── cli-proxy-api.md
    └── multi-instance.md
```

## Runtime mount layout

```text
mounts/
├── openclaw/
│   └── root/
│       └── workspace/
└── cli-proxy-api/
    ├── config/
    │   └── config.yaml
    ├── auths/
    └── logs/
```

- `openclaw-gateway` và `openclaw-cli` cùng mount **một root duy nhất**:
  - `./mounts/openclaw/root -> /home/node/.openclaw`
- `cli-proxy-api` mount riêng config/auth/logs để nhìn service nào dùng gì là rõ ngay khi mở project.

Bên trong `mounts/openclaw/root/` sẽ có luôn `workspace/` và các file state/config khác của OpenClaw.

## Cách dùng nhanh

### 1) Chuẩn bị env

```bash
cp .env.example .env
mkdir -p mounts/openclaw/root/workspace
mkdir -p mounts/cli-proxy-api/config mounts/cli-proxy-api/auths mounts/cli-proxy-api/logs
```

`mounts/` là runtime-local state, đang bị `.gitignore` bỏ qua. Những file như `mounts/cli-proxy-api/config/config.yaml` là file chạy thật trên máy local, không phải file cần commit lên repo.

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

## CLIProxyAPI add-on

Repo này có thể chạy thêm một container **CLIProxyAPI** như sidecar/service phụ để cung cấp endpoint tương thích OpenAI/Gemini/Claude/Codex cho CLI tools.

Quick start:

```bash
mkdir -p mounts/cli-proxy-api/config mounts/cli-proxy-api/auths mounts/cli-proxy-api/logs
cp config/cli-proxy-api.example.yaml mounts/cli-proxy-api/config/config.yaml
docker compose up -d cli-proxy-api
```

Docs chi tiết:

- `docs/cli-proxy-api.md`

Lưu ý: file chạy thật của CLIProxyAPI nên nằm ở `mounts/cli-proxy-api/config/config.yaml` và không cần commit lên repo.

Mặc định các port của CLIProxyAPI trong repo này đều bind vào `127.0.0.1` để tránh expose nhầm ra ngoài.

## Chạy thêm instance thứ 2

Repo này giờ có sẵn mẫu để chạy **instance OpenClaw thứ 2 trên cùng máy** bằng env file riêng.

Quick start:

```bash
cp .env.instance-2.example .env.instance-2
mkdir -p mounts/openclaw2/root/workspace
./scripts/up-instance-2.sh
```

Docs chi tiết:

- `docs/multi-instance.md`

Cách này tách riêng:

- `COMPOSE_PROJECT_NAME`
- container names
- gateway port
- OpenClaw root path

và cho phép **share cùng một CLIProxyAPI** của instance chính, nên 2 OpenClaw gateway có thể sống song song mà không cần nhân đôi proxy sidecar.

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
- Repo này mặc định pin cả hai image chính:
  - `ghcr.io/openclaw/openclaw:2026.3.8`
  - `eceasy/cli-proxy-api:v6.8.51`
- Lý do: setup ổn định hơn, dễ reproduce hơn, và debug dễ hơn khi có issue.
- Nếu bạn thích sống nhanh với feature mới, vẫn có thể đổi `OPENCLAW_IMAGE` hoặc `CLI_PROXY_IMAGE` trong `.env`, nhưng nên coi đó là lựa chọn chủ động.
- Gateway đang bind port theo kiểu an toàn hơn: `127.0.0.1:${OPENCLAW_GATEWAY_PORT}:18789`
- `openclaw-cli` dùng `network_mode: service:openclaw-gateway` để gọi gateway qua loopback trong Docker namespace chung.
- `--allow-unconfigured` chỉ để bootstrap ban đầu; xong rồi vẫn nên cấu hình auth/token tử tế.
- Dữ liệu persistent chính nằm ở:
  - `./mounts/openclaw/root`
  - `./mounts/cli-proxy-api/`

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
