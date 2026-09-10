#!/usr/bin/env bash
# Freedom Lab — SGLang 推理服务（通用版）
# 用法: start-sglang.sh [stock|freedom]   默认 freedom
set -euo pipefail
VARIANT="${1:-freedom}"
PY=~/FreedomLab/.venvs/sglang/bin/python
PIDF=~/.config/freedomlab/sglang.pid
mkdir -p ~/.config/freedomlab
export PATH="$HOME/FreedomLab/.venvs/sglang/bin:$PATH"

case "$VARIANT" in
  stock)
    MODEL=~/FreedomLab/models/qwen3.8-27b-fp8
    NAME=qwen3.8-27b
    ;;
  freedom)
    MODEL=~/FreedomLab/models/qwen3.8-27b-uncensored
    NAME=freedom-qwen3.8-27b
    ;;
  *) echo "usage: $0 [stock|freedom]"; exit 1;;
esac
LOG=~/FreedomLab/logs/sglang-$VARIANT.log

if curl -sf --max-time 3 http://127.0.0.1:30000/v1/models >/dev/null 2>&1; then
  cur=$(curl -s http://127.0.0.1:30000/v1/models | grep -oE '"id":"[^"]+"' | head -1)
  if [ "$cur" = "\"id\":\"$NAME\"" ]; then
    echo "sglang ($VARIANT) already running"; exit 0
  fi
  echo "端口被其他模型占用（$cur），先停掉: kill \$(cat $PIDF)"
  exit 1
fi

nohup "$PY" -m sglang.launch_server \
  --model-path "$MODEL" \
  --served-model-name "$NAME" \
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
echo "sglang ($VARIANT, $NAME) launching, pid $(cat $PIDF)，日志: $LOG"
echo "等待就绪（约 10 分钟）..."
for i in $(seq 1 150); do
  curl -sf --max-time 3 http://127.0.0.1:30000/v1/models >/dev/null 2>&1 && { echo "sglang READY ($NAME)"; exit 0; }
  sleep 5
done
echo "启动超时，看日志: tail -50 $LOG"
exit 1
