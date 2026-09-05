#!/usr/bin/env bash
# Phase 1 — 安装 Ollama（用户级，无 sudo；网络受限版）
# 官方 install.sh 307 到 github releases（本机被墙），改走 api.github.com asset。
set -euo pipefail

mkdir -p ~/ollama
cd ~/ollama

# 1. 取最新版本 tag（api.github.com 本机可直连）
VER=$(curl -s --connect-timeout 10 "https://api.github.com/repos/ollama/ollama/releases/latest" \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['tag_name'])")
echo "latest ollama: $VER"

# 2. 找 linux-arm64 asset id（排除 jetpack/rocm）
ASSET_ID=$(curl -s --connect-timeout 10 "https://api.github.com/repos/ollama/ollama/releases/latest" \
  | python3 -c "
import json,sys
for a in json.load(sys.stdin)['assets']:
    n=a['name']
    if 'linux-arm64' in n and 'jetpack' not in n and 'rocm' not in n:
        print(a['id']); break")
SIZE=$(curl -s --connect-timeout 10 "https://api.github.com/repos/ollama/ollama/releases/latest" \
  | python3 -c "
import json,sys
for a in json.load(sys.stdin)['assets']:
    n=a['name']
    if 'linux-arm64' in n and 'jetpack' not in n and 'rocm' not in n:
        print(a['size']); break")
echo "asset $ASSET_ID ($SIZE bytes)"

# 3. 12 路分片下载 + 解压
~/FreedomLab/scripts/parallel-download.sh \
  "https://api.github.com/repos/ollama/ollama/releases/assets/$ASSET_ID" \
  ollama-linux-arm64.tar.zst "$SIZE" 12
tar --zstd -xf ollama-linux-arm64.tar.zst
~/ollama/bin/ollama --version

# 4. 启动（64K context，用户级，无 systemd）
~/FreedomLab/scripts/start-ollama.sh
curl -s http://127.0.0.1:11434/api/tags
