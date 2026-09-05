#!/usr/bin/env bash
# Phase 2/3 — 拉取双模型（网络受限版）
set -euo pipefail
export PATH="$HOME/ollama/bin:$PATH"

# Stock：ollama registry 本机直连且快
ollama pull qwen3.8:27b

# Freedom：HF 被墙，用 hf-mirror + 16 路分片下载 GGUF
GGUF=~/FreedomLab/models/qwen3.8-freedom/Qwen3.8-27B-Uncensored-Q4_K_M.gguf
mkdir -p "$(dirname "$GGUF")"
if [ ! -f "$GGUF" ]; then
  SIZE=$(curl -sI --connect-timeout 10 -L \
    "https://hf-mirror.com/JonathanColetti/Qwen3.8-27B-Uncensored-GGUF/resolve/main/Qwen3.8-27B-Uncensored-Q4_K_M.gguf" \
    -r 0-0 | grep -i content-range | grep -oE '[0-9]+$')
  ~/FreedomLab/scripts/parallel-download.sh \
    "https://hf-mirror.com/JonathanColetti/Qwen3.8-27B-Uncensored-GGUF/resolve/main/Qwen3.8-27B-Uncensored-Q4_K_M.gguf" \
    "$GGUF" "$SIZE" 16
fi
cd "$(dirname "$GGUF")" && sha256sum "$(basename "$GGUF")" > SHA256SUMS && cat SHA256SUMS

# 注册进 ollama
cd ~/FreedomLab
ollama create freedom-qwen3.8:27b -f config/models/freedom-qwen3.8.Modelfile
ollama list
