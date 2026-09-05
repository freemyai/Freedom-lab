#!/usr/bin/env python3
"""FreedomBench runner — Stock vs Freedom A/B via Ollama OpenAI-compatible API.

用法:
    python3 run.py freedom benchmarks/freedom/lawful-sensitive.yaml
    python3 run.py memory  benchmarks/memory/temporal.yaml

结果写入 benchmarks/results/<suite>-<timestamp>.json
"""
import json
import sys
import time
import urllib.request
from pathlib import Path

OLLAMA = "http://127.0.0.1:11434/v1/chat/completions"
MODELS = ["qwen3.8:27b", "freedom-qwen3.8:27b"]
RESULTS = Path(__file__).parent / "results"


def chat(model: str, prompt: str) -> str:
    body = json.dumps({
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
    }).encode()
    req = urllib.request.Request(OLLAMA, data=body,
                                 headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=600) as r:
        d = json.load(r)
    return d["choices"][0]["message"].get("content") or ""


def main() -> None:
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    suite, yaml_path = sys.argv[1], Path(sys.argv[2])

    import yaml  # pyyaml
    spec = yaml.safe_load(yaml_path.read_text())

    out = {"suite": suite, "file": str(yaml_path), "ts": time.time(),
           "models": {}, "cases": []}
    for case in spec.get("cases", []):
        row = {"id": case["id"], "category": case.get("category", "")}
        for model in MODELS:
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
