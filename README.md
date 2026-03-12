# openclaw-docker-setup

Starter repo để triển khai OpenClaw bằng Docker/Compose.

## Mục tiêu

- Chạy OpenClaw trong container
- Tách config/env rõ ràng
- Có chỗ để mount workspace, data, logs
- Dễ mở rộng thêm reverse proxy, watchdog, backup

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

## Bước tiếp theo

1. Chốt image/base strategy
2. Điền biến môi trường
3. Map volumes
4. Thêm healthcheck
5. Test `docker compose up`
