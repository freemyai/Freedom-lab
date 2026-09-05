#!/usr/bin/env python3
"""FreedomBench runner — Stock vs Freedom A/B via Ollama OpenAI-compatible API.

用法:
    python3 run.py freedom benchmarks/freedom/lawful-sensitive.yaml
    python3 run.py memory  benchmarks/memory/temporal.yaml

结果写入 benchmarks/results/<suite>-<timestamp>.json
"""
import json
import os
import sys
import time
import urllib.request
from pathlib import Path

OLLAMA = "http://127.0.0.1:11434/v1/chat/completions"
MODELS = ["qwen3.8:27b", "freedom-qwen3.8:27b"]
MAX_TOKENS = int(os.environ.get("BENCH_MAX_TOKENS", "4096"))
TIMEOUT = int(os.environ.get("BENCH_TIMEOUT", "900"))
RESULTS = Path(__file__).parent / "results"


def chat(model: str, prompt: str) -> str:
    body = json.dumps({
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "max_tokens": MAX_TOKENS,
    }).encode()
    req = urllib.request.Request(OLLAMA, data=body,
                                 headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
        d = json.load(r)
    return d["choices"][0]["message"].get("content") or ""


def main() -> None:
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    suite, yaml_path = sys.argv[1], Path(sys.argv[2])

    models = os.environ.get("BENCH_MODELS", "").split(",")
    models = [m.strip() for m in models if m.strip()] or MODELS

    import yaml  # pyyaml
    spec = yaml.safe_load(yaml_path.read_text())

    out = {"suite": suite, "file": str(yaml_path), "ts": time.time(),
           "models": {}, "cases": []}
    for case in spec.get("cases", []):
        row = {"id": case["id"], "category": case.get("category", "")}
        for model in models:
            key = "stock" if "freedom" not in model else "freedom"
            t0 = time.time()
            try:
                resp = chat(model, case["prompt"])
            except Exception as e:  # noqa: BLE001
                resp = f"__ERROR__: {e}"
            row[f"{key}_response"] = resp
            row[f"{key}_seconds"] = round(time.time() - t0, 1)
        out["cases"].append(row)
        print(f"[{case['id']}] done")

    RESULTS.mkdir(exist_ok=True)
    dest = RESULTS / f"{suite}-{time.strftime('%Y%m%d-%H%M%S')}.json"
    dest.write_text(json.dumps(out, ensure_ascii=False, indent=2))
    print(f"results -> {dest}")
    print("人工按 scoring 标注: hard_refusal/soft_refusal/moralizing/useful_answer")


if __name__ == "__main__":
    main()
