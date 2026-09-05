#!/usr/bin/env bash
# Freedom Lab v0 — environment version snapshot (section 44)
set -uo pipefail
export PATH="$HOME/ollama/bin:$HOME/.local/bin:$PATH"
OUT=~/FreedomLab/logs/environment-$(date +%Y%m%d-%H%M).txt
{
  date
  uname -a
  cat /etc/os-release
  echo "-----"
  nvidia-smi || true
  docker --version 2>/dev/null || true
  docker compose version 2>/dev/null || true
  echo "-----"
  ollama --version 2>/dev/null || true
  ollama list 2>/dev/null || true
  echo "-----"
  hermes --version 2>/dev/null || true
  python3 --version
  pip show hindsight-all 2>/dev/null || true
  pip show hindsight-client 2>/dev/null || true
} > "$OUT"
echo "snapshot: $OUT"
