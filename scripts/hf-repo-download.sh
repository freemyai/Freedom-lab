#!/usr/bin/env bash
# 并行下载 HF repo 全部文件（hf-mirror + xargs 控制并发 + 大文件内部分片）
# 用法: hf-repo-download.sh <repo_id> <local_dir> [文件并发数]
set -euo pipefail
REPO="$1"; DEST="$2"; CONC="${3:-3}"
mkdir -p "$DEST"

LIST=$(curl -s --connect-timeout 15 "https://hf-mirror.com/api/models/$REPO" \
  | python3 -c "
import json,sys
d=json.load(sys.stdin)
for f in d.get('siblings',[]):
    n=f['rfilename']
    if n.startswith('.') or n=='README.md': continue
    print(n)")
[ -n "$LIST" ] || { echo "FATAL: empty file list for $REPO"; exit 1; }

export REPO DEST
dl_one() {
  f="$1"
  url="https://hf-mirror.com/$REPO/resolve/main/$f"
  out="$DEST/$f"
  mkdir -p "$(dirname "$out")"
  size=$(curl -sIL --connect-timeout 10 --max-time 40 -r 0-0 "$url" 2>/dev/null \
    | grep -i '^content-range' | tail -1 | grep -oE '[0-9]+$' || true)
  if [ -z "${size:-}" ]; then
    curl -sfL --retry 3 -o "$out" "$url"
  else
    if [ -f "$out" ] && [ "$(stat -c%s "$out")" = "$size" ]; then
      echo "SKIP $f"; return 0
    fi
    ~/FreedomLab/scripts/parallel-download.sh "$url" "$out" "$size" 6
  fi
  echo "OK $f"
}
export -f dl_one

printf '%s\n' $LIST | xargs -P "$CONC" -I{} bash -c 'dl_one "$@"' _ {}
echo "ALL DONE -> $DEST"
