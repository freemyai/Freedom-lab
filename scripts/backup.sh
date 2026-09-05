#!/usr/bin/env bash
# Freedom Lab v0 — backup (section 45/46). Memory > Model weights.
set -euo pipefail
TS=$(date +%Y%m%d-%H%M)
DEST=~/FreedomLab/vault/backups/freedomlab-$TS
mkdir -p "$DEST"

tar czf "$DEST/FreedomLab-config.tar.gz" \
  --exclude='models' --exclude='vault/backups' --exclude='logs' \
  -C ~ FreedomLab 2>/dev/null || true

tar czf "$DEST/hermes.tar.gz" -C ~ .hermes 2>/dev/null || true
tar czf "$DEST/hindsight.tar.gz" -C ~ .hindsight 2>/dev/null || true

# 模型只记录 checksum / repo / quant，不复制几十 GB 权重
{
  echo "# model manifest $TS"
  echo "ollama: $(ollama list 2>/dev/null || echo 'n/a')"
  [ -f ~/FreedomLab/models/qwen3.8-freedom/SHA256SUMS ] && cat ~/FreedomLab/models/qwen3.8-freedom/SHA256SUMS
} > "$DEST/model-manifest.txt"

echo "backup -> $DEST"
