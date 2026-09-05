#!/usr/bin/env bash
# Freedom Lab v0 — backup (section 45/46). Memory > Model weights.
set -euo pipefail
TS=$(date +%Y%m%d-%H%M)
DEST=~/FreedomLab/vault/backups/freedomlab-$TS
mkdir -p "$DEST"

tar czf "$DEST/FreedomLab-config.tar.gz" \
  --exclude='models' --exclude='vault/backups' --exclude='logs' \
  -C ~ FreedomLab 2>/dev/null || true

# ~/.hermes 里 venv/node_modules/.git/缓存都是可重建的，只备份配置/记忆/skills/sessions
# 用 find 显式生成清单，避免 tar exclude 模式在部分版本上的歧义
(cd ~ && find .hermes \
  -type d \( -name venv -o -name node_modules -o -name .git \
             -o -name audio_cache -o -name image_cache \) -prune -o \
  -type f ! -path '.hermes/logs/*' ! -path '.hermes/bin/*' -print \
  | tar czf "$DEST/hermes.tar.gz" -C ~ -T -) 2>/dev/null || true

tar czf "$DEST/hindsight.tar.gz" -C ~ .hindsight \
  --exclude='.hindsight/profiles/*.log' \
  2>/dev/null || true

# Hindsight 嵌入式 PostgreSQL 数据（记忆本体，最重要的备份对象）
tar czf "$DEST/hindsight-pgdata.tar.gz" -C ~ .pg0 2>/dev/null || true

# 模型只记录 checksum / repo / quant，不复制几十 GB 权重
{
  echo "# model manifest $TS"
  echo "ollama: $(ollama list 2>/dev/null || echo 'n/a')"
  [ -f ~/FreedomLab/models/qwen3.8-freedom/SHA256SUMS ] && cat ~/FreedomLab/models/qwen3.8-freedom/SHA256SUMS
} > "$DEST/model-manifest.txt"

echo "backup -> $DEST"
