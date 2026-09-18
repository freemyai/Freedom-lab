# Freedom Lab

**The AI you own — proven, not promised.**

Freedom Lab is the open technical validation platform for [Freemy AI](https://github.com/freemyai). Before building a personal sovereign AI product, we answer the question first: *what should a local, persistent, owner-controlled AI actually feel like?*

This repository is a **fully working reference system**, running 24/7 on an NVIDIA DGX Spark (128GB unified memory, behind a heavily restricted network). Not a demo. Not a mockup. A dogfooded lab with battle scars documented.

---

## What it proves

| Pillar | Verified |
|---|---|
| **Continuity** | Restarts, model swaps, weeks of history — the AI correctly answers "where did we get to yesterday?", including *why* decisions changed over time |
| **Agency** | Reads/writes files, fixes bugs, runs tests, uses git — inside a locked-down Docker sandbox (no host access, no network) |
| **Freedom** | Uncensored community model serves as the main brain; model is swappable without losing identity or memory |
| **Ownership** | Memory graph, model weights, logs, permissions — 100% local. No cloud API required, ever |

## Architecture

```text
                        OWNER
                          │
                          ▼
              Hermes Agent (personality: SOUL.md)
                          │
        ┌─────────────────┼──────────────────┐
        ▼                 ▼                  ▼
   Hindsight          hermes-lcm         Docker Sandbox
   long-term memory   lossless context   isolated execution
   (knowledge graph   (SQLite + DAG,     (workspace only,
    + temporal)        nothing is lost)   network=none)
        │                 │
        └────────┬────────┘
                 ▼
        SGLang (MTP speculative decoding)
        freedom-qwen3.8-27b (BF16, fully local)
                 │
            DGX Spark GB10
```

## Key findings (the real deliverables)

- **Memory > Model**: swap the LLM mid-project, memory and identity survive intact
- **File-as-interface**: in a 64K-context agent system, subagent results must flow through workspace files, never through parent context (two production incidents proved this)
- **Model freedom ≠ action authority**: discussion is unrestricted; destructive/irreversible actions go through a separate owner permission layer
- **Restricted-network playbook**: full working recipes for GitHub/HuggingFace/PyPI/Docker-Hub blocked environments (see `docs/operations.md`)
- 13 documented real-world pitfalls (GGUF template mismatch, tool-parser format mismatch, compression death spirals…) in `docs/experiment-log.md`

## Performance (measured on DGX Spark GB10)

| Metric | Value |
|---|---|
| Single-stream generation | ~5.3 t/s (BF16 55GB weights, at bandwidth ceiling) |
| 4–5 concurrent subagents | 25–51 t/s aggregate |
| MTP speculative acceptance | ~2.9 tokens/step |
| Long-term memory stack | Hindsight local_embedded (PostgreSQL, knowledge graph, temporal queries) |

## Repo layout

```
docs/            architecture, operations, security model, experiment log, implementation report
scripts/         doctor.sh (health check), backup, SGLang/Ollama launchers, restricted-network downloaders
config/          Hermes config reference, SOUL.md (agent identity), model Modelfiles
benchmarks/      FreedomBench: memory / agent / freedom suites + results
workspace/       the only directory the agent may modify
vault/           backups & exports (memory > model weights)
```

## Quick start (DGX Spark / aarch64)

```bash
./scripts/start-sglang.sh        # serve the model (~10 min first load)
./scripts/doctor.sh              # expect: FREEDOM LAB HEALTHY
hermes                           # talk to Freedom
```

## Status

v0 complete and in daily dogfood. See `docs/实施报告-20260907.md` (implementation report, 中文) and `docs/experiment-log.md` (running experiment log).

Not a product — the lab that tells us what the product must be.

## License

MIT (configuration, scripts, docs). Components keep their own licenses: Hermes Agent, Hindsight, hermes-lcm, SGLang, Qwen models.
