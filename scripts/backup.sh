#!/usr/bin/env bash
# Freedom Lab v0 — backup (section 45/46). Memory > Model weights.
set -euo pipefail
TS=$(date +%Y%m%d-%H%M)
DEST=~/FreedomLab/vault/backups/freedomlab-$TS
mkdir -p "$DEST"

tar czf "$DEST/FreedomLab-config.tar.gz" \
  --exclude='models' --exclude='vault/backups' --exclude='logs' \
  -C ~ FreedomLab 2>/dev/null || true

# ~/.hermes 里 venv/缓存是可重建的（torch 等大依赖），只备份配置/记忆/skills/sessions
tar czf "$DEST/hermes.tar.gz" -C ~ .hermes \
  --exclude='.hermes/hermes-agent/venv' \
  --exclude='.hermes/hermes-agent/.git' \
  --exclude='.hermes/audio_cache' \
  --exclude='.hermes/image_cache' \
  --exclude='.hermes/logs' \
  --exclude='.hermes/bin' \
  2>/dev/null || true

tar czf "$DEST/hindsight.tar.gz" -C ~ .hindsight \
  --exclude='.hindsight/profiles/*.log' \
  2>/dev/null || true

# 模型只记录 checksum / repo / quant，不复制几十 GB 权重
{
  echo "# model manifest $TS"
  echo "ollama: $(ollama list 2>/dev/null || echo 'n/a')"
  [ -f ~/FreedomLab/models/qwen3.8-freedom/SHA256SUMS ] && cat ~/FreedomLab/models/qwen3.8-freedom/SHA256SUMS
} > "$DEST/model-manifest.txt"

echo "backup -> $DEST"
