# Freedom Lab — Experiment Log

## Experiment 2026-09-04 — v0 bring-up

### Question

Can we bring up the full Freedom Lab v0 stack (Ollama + Stock/Freedom Qwen3.8-27B + Hermes + Docker sandbox + Hindsight) on DGX Spark behind a restricted network?

### Configuration

Model: qwen3.8:27b (stock) + freedom-qwen3.8:27b (JonathanColetti Q4_K_M)
Memory: Hermes built-in → Hindsight local_embedded
Context: 65536
Hermes version: (record after install)
Hindsight version: (record after install)

### Environment notes (network workarounds)

- github.com blocked; api.github.com reachable directly (used for release asset download)
- git clone via gh-proxy.com insteadOf (scoped to install commands only)
- huggingface.co blocked; hf-mirror.com works, HF CDN (us.aws.cdn.hf.co) reachable with range support
- ollama.com reachable but /download 307s to github releases (blocked) → user-level install from api.github.com asset
- No passwordless sudo → Ollama runs as user service via scripts/start-ollama.sh (OLLAMA_CONTEXT_LENGTH=65536); Docker group membership pending owner action

### Expected

Freedom Lab v0 seven acceptance criteria (doc §47).

### Result

(in progress)

### Failure

-

### Conclusion

-

### Next Action

-
