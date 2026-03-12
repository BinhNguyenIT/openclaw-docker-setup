# Optional custom image layer.
# Repo này hiện dùng official image qua compose:
#   ghcr.io/openclaw/openclaw:latest
#
# Nếu sau này cần bake thêm apt packages / browser deps / custom tooling,
# có thể đổi compose sang build image từ file này.

FROM ghcr.io/openclaw/openclaw:latest

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    bash \
  && rm -rf /var/lib/apt/lists/*
USER node
