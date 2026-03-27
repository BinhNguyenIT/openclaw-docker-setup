# Optional custom image layer.
# Repo này hiện dùng official image qua compose:
#   ghcr.io/openclaw/openclaw:2026.3.23-2
#
# Nếu sau này cần bake thêm apt packages / browser deps / custom tooling,
# có thể đổi compose sang build image từ file này.
#
# Keep ByteRover CLI (`brv`) here so ClawHub's `byterover` skill actually works
# after container rebuilds/restarts.
# Keep QMD baked in too: memory_search can still have agent qmd configs/cache/state,
# and if the `qmd` binary disappears after a rebuild the runtime falls back awkwardly.

FROM ghcr.io/openclaw/openclaw:2026.3.23-2

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    bash \
    git \
    gh \
    sqlite3 \
    python3 \
    python-is-python3 \
    libnspr4 \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libdbus-1-3 \
    libcups2 \
    libxkbcommon0 \
    libasound2 \
    libgbm1 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libatspi2.0-0 \
    fonts-noto-color-emoji \
    fonts-noto-cjk \
    fonts-freefont-ttf \
  && npm install -g byterover-cli @tobilu/qmd agent-browser \
  && chown -R root:root /app/extensions \
  && rm -rf /var/lib/apt/lists/*

USER node
ENV HOME=/home/node
RUN agent-browser install
