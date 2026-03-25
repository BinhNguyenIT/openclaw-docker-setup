#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

COMPOSE_FILES=(-f compose.yml -f compose.cuda.yml)

cat <<'MSG'
==> Bootstrapping QMD CUDA runtime inside the mounted OpenClaw root
This reinstalls/rebuilds QMD's node-llama-cpp in /home/node/.openclaw/tools/qmd
so the live runtime matches the CUDA-enabled container environment.
MSG

# Ensure the CUDA image exists and the gateway is up so the shared volume layout is initialized.
docker compose "${COMPOSE_FILES[@]}" build openclaw-gateway openclaw-cli
docker compose "${COMPOSE_FILES[@]}" up -d openclaw-gateway

docker compose "${COMPOSE_FILES[@]}" run --rm openclaw-cli bash -lc '
  set -euo pipefail
  export HOME=/home/node
  export NODE_LLAMA_CPP_GPU=${NODE_LLAMA_CPP_GPU:-cuda}
  export NVIDIA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-all}
  export NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES:-all}
  export CUDA_PATH=${CUDA_PATH:-/usr/local/cuda}
  export CUDACXX=${CUDACXX:-/usr/local/cuda/bin/nvcc}
  export PATH=${CUDA_PATH}/bin:${PATH}
  export LD_LIBRARY_PATH=${CUDA_PATH}/lib64:/usr/local/cuda/targets/x86_64-linux/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH:-}

  mkdir -p /home/node/.openclaw/tools/qmd
  cd /home/node/.openclaw/tools/qmd

  if [ ! -f package.json ]; then
    printf "{\n  \"dependencies\": {\n    \"@tobilu/qmd\": \"^2.0.1\"\n  }\n}\n" > package.json
  fi

  rm -rf node_modules
  npm install
  npm rebuild node-llama-cpp || true

  node /home/node/.openclaw/tools/qmd/node_modules/.bin/node-llama-cpp inspect gpu
'
