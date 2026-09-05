#!/usr/bin/env bash
# Freedom Lab v0 — 用户级 Ollama 服务启动（无 systemd/sudo 环境的等价物）
# 等价于规格第 7 节的 OLLAMA_CONTEXT_LENGTH=65536 systemd 配置
set -euo pipefail
export PATH="$HOME/ollama/bin:$PATH"
export OLLAMA_CONTEXT_LENGTH=65536
export OLLAMA_HOST=127.0.0.1:11434
mkdir -p ~/FreedomLab/logs ~/.config/freedomlab
echo "OLLAMA_CONTEXT_LENGTH=65536" > ~/.config/freedomlab/ollama.env

if curl -sf http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
  echo "ollama already running"
  exit 0
fi
nohup ollama serve > ~/FreedomLab/logs/ollama-serve.log 2>&1 &
echo $! > ~/.config/freedomlab/ollama.pid
for i in $(seq 1 30); do
  curl -sf http://127.0.0.1:11434/api/tags >/dev/null 2>&1 && { echo "ollama up (pid $(cat ~/.config/freedomlab/ollama.pid))"; exit 0; }
  sleep 1
done
echo "ollama failed to start; see ~/FreedomLab/logs/ollama-serve.log"
exit 1
