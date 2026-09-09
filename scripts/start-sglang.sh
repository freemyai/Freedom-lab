#!/usr/bin/env bash
# Freedom Lab — SGLang 推理服务（Qwen3.8-27B-FP8 + MTP 推测解码）
# 替代 Ollama，目标 2-3x 生成速度；OpenAI 兼容 API :30000
set -euo pipefail
MODEL=~/FreedomLab/models/qwen3.8-27b-fp8
PY=~/FreedomLab/.venvs/sglang/bin/python
LOG=~/FreedomLab/logs/sglang.log
PIDF=~/.config/freedomlab/sglang.pid
mkdir -p ~/.config/freedomlab
# JIT 编译依赖（ninja/gcc）需要从 venv 找到
export PATH="$HOME/FreedomLab/.venvs/sglang/bin:$PATH"

if curl -sf --max-time 3 http://127.0.0.1:30000/health >/dev/null 2>&1; then
  echo "sglang already running"; exit 0
fi

nohup "$PY" -m sglang.launch_server \
  --model-path "$MODEL" \
  --served-model-name qwen3.8-27b \
  --host 127.0.0.1 --port 30000 \
  --context-length 65536 \
  --chat-template "$MODEL/chat_template.jinja" \
  --tool-call-parser qwen3_coder \
  --reasoning-parser qwen3 \
  --speculative-algorithm NEXTN \
  --speculative-num-steps 3 \
  --speculative-eagle-topk 1 \
  --speculative-num-draft-tokens 4 \
  --mem-fraction-static 0.65 \
  --max-running-requests 8 \
  --enable-mixed-chunk \
  --log-level info \
  > "$LOG" 2>&1 &
echo $! > "$PIDF"
echo "sglang launching (pid $(cat $PIDF))，日志: $LOG"
echo "等待就绪（模型加载需几分钟）..."
for i in $(seq 1 120); do
  curl -sf --max-time 3 http://127.0.0.1:30000/health >/dev/null 2>&1 && { echo "sglang READY"; exit 0; }
  sleep 5
done
echo "启动超时，看日志: tail -50 $LOG"
exit 1
