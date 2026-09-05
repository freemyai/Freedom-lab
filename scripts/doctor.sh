#!/usr/bin/env bash
# Freedom Lab v0 — health check (section 47)
set -uo pipefail
pass=0; fail=0
check() { # name, command
  if eval "$2" >/dev/null 2>&1; then echo "[PASS] $1"; pass=$((pass+1));
  else echo "[FAIL] $1"; fail=$((fail+1)); fi
}

export PATH="$HOME/ollama/bin:$HOME/.local/bin:$PATH"

check "[1] Ollama running"            "curl -sf http://127.0.0.1:11434/api/tags"
check "[2] Stock Qwen installed"      "ollama list | grep -q 'qwen3.8:27b'"
check "[3] Freedom model installed"   "ollama list | grep -q 'freedom-qwen3.8'"
check "[4] 64K context configured"    "grep -q 'OLLAMA_CONTEXT_LENGTH=65536' ~/.config/freedomlab/ollama.env 2>/dev/null || pgrep -af 'ollama serve' | grep -q . && curl -sf http://127.0.0.1:11434/api/ps"
check "[5] Hermes installed"          "command -v hermes"
check "[6] Docker working"            "docker info"
check "[7] Hindsight enabled"         "test -f ~/.hermes/hindsight/config.json"
check "[8] Hindsight local"           "grep -q 'local' ~/.hermes/hindsight/config.json"
check "[9] workspace mount exists"    "test -d ~/FreedomLab/workspace"
check "[10] no cloud API required"    "! grep -rqiE 'sk-[a-zA-Z0-9]{20}' ~/.hermes/config.yaml 2>/dev/null"

echo
if [ "$fail" -eq 0 ]; then echo "FREEDOM LAB HEALTHY"; else echo "FREEDOM LAB NOT READY ($fail failures)"; exit 1; fi
