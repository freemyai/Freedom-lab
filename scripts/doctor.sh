#!/usr/bin/env bash
# Freedom Lab v0 — health check (section 47, 2026-09-09 SGLang 版)
set -uo pipefail
pass=0; fail=0; warn=0
check() {
  if eval "$2" >/dev/null 2>&1; then echo "[PASS] $1"; pass=$((pass+1));
  else echo "[FAIL] $1"; fail=$((fail+1)); fi
}
warn_check() {
  if eval "$2" >/dev/null 2>&1; then echo "[PASS] $1"; pass=$((pass+1));
  else echo "[WARN] $1（可选组件）"; warn=$((warn+1)); fi
}

export PATH="$HOME/ollama/bin:$HOME/.local/bin:$PATH"

check "[1] SGLang running (:30000)"      "curl -sf http://127.0.0.1:30000/v1/models"
check "[2] Stock model served"           "curl -s http://127.0.0.1:30000/v1/models | grep -q 'qwen3.8-27b'"
check "[3] SGLang 推理可用"               "curl -sf http://127.0.0.1:30000/v1/chat/completions -H 'Content-Type: application/json' -d '{\"model\":\"qwen3.8-27b\",\"max_tokens\":8,\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}]}' | grep -q choices"
warn_check "[3b] Freedom model (ollama, 可选)" "curl -sf http://127.0.0.1:11434/api/tags >/dev/null && ollama list | grep -q 'freedom-qwen3.8'"
check "[4] 64K context configured"      "curl -s http://127.0.0.1:30000/v1/models | grep -q 65536"
check "[5] Hermes installed"            "command -v hermes"
check "[6] Docker working"              "docker info"
check "[7] Hindsight enabled"           "test -f ~/.hermes/hindsight/config.json"
check "[8] Hindsight local"             "grep -q 'local' ~/.hermes/hindsight/config.json"
check "[9] workspace mount exists"      "test -d ~/FreedomLab/workspace"
check "[10] no cloud API required"      "! grep -rqiE 'sk-[a-zA-Z0-9]{20}' ~/.hermes/config.yaml 2>/dev/null"

echo
if [ "$fail" -eq 0 ]; then echo "FREEDOM LAB HEALTHY ($warn optional warnings)"; else echo "FREEDOM LAB NOT READY ($fail failures)"; exit 1; fi
