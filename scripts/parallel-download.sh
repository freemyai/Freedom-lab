#!/usr/bin/env bash
# 并行分片下载 GitHub release asset（应对 api.github.com 单连接限速）
set -euo pipefail
URL="$1"; OUT="$2"; SIZE="$3"; PARTS="${4:-12}"
TMPD="$(dirname "$OUT")/.parts_$(basename "$OUT")"
mkdir -p "$TMPD"
CHUNK=$(( (SIZE + PARTS - 1) / PARTS ))
pids=()
for i in $(seq 0 $((PARTS-1))); do
  start=$((i * CHUNK))
  end=$(( (i+1) * CHUNK - 1 ))
  [ $end -ge $SIZE ] && end=$((SIZE-1))
  [ $start -gt $end ] && break
  (
    for attempt in 1 2 3 4 5; do
      have=0
      [ -f "$TMPD/part_$i" ] && have=$(stat -c%s "$TMPD/part_$i")
      want=$((end - start + 1))
      if [ "$have" -ge "$want" ]; then break; fi
      curl -sfL --connect-timeout 15 -H "Accept: application/octet-stream" \
        -r $((start+have))-$end -o - "$URL" >> "$TMPD/part_$i" || true
    done
  ) &
  pids+=($!)
done
wait "${pids[@]}"
# 校验并合并
total=0
for i in $(seq 0 $((PARTS-1))); do
  f="$TMPD/part_$i"
  [ -f "$f" ] || { echo "missing part_$i"; exit 1; }
  total=$((total + $(stat -c%s "$f")))
done
echo "downloaded: $total / $SIZE"
[ "$total" -eq "$SIZE" ] || { echo "SIZE MISMATCH"; exit 1; }
: > "$OUT"
for i in $(seq 0 $((PARTS-1))); do cat "$TMPD/part_$i" >> "$OUT"; done
rm -rf "$TMPD"
echo "OK: $OUT"
