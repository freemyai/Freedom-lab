# Freedom Lab v0 — 架构

```text
                        OWNER
                          │
                          ▼
                  ┌───────────────┐
                  │ Hermes Agent  │  v0.21.0 (~/.hermes)
                  │  SOUL.md      │
                  │  USER.md      │
                  │  MEMORY.md    │
                  └───────┬───────┘
             ┌────────────┼─────────────┐
             ▼            ▼             ▼
        Built-in       Hindsight      Agent Tools
        Memory         local_embedded      │
        USER.md        embedded PG      Docker Sandbox
        MEMORY.md      bank=freedom-main   │  (pending: docker group)
                       │                   ▼
                       │              Files / Shell / Git
                       │              network=none
             └─────────┴─────────┐
                                 ▼
                  Ollama (user-level, :11434)
                  OLLAMA_CONTEXT_LENGTH=65536
                       │              │
              qwen3.8:27b      freedom-qwen3.8:27b
              (stock,           (JonathanColetti
               controller)       Uncensored Q4_K_M)
                                 │
                            DGX Spark GB10 128GB
```

## 关键路径

| 内容 | 位置 |
|---|---|
| Hermes 配置 | ~/.hermes/config.yaml |
| 身份 | ~/.hermes/SOUL.md |
| 内置记忆 | ~/.hermes/memories/ |
| Hindsight 配置 | ~/.hermes/hindsight/config.json |
| Hindsight PG 数据（记忆本体） | ~/.pg0/instances/hindsight-embed-hermes |
| Hindsight profile env | ~/.hindsight/profiles/hermes.env |
| Ollama 二进制/模型 | ~/ollama, ~/.ollama |
| 项目 | ~/FreedomLab |
| Agent 工作区（唯一可写） | ~/FreedomLab/workspace |
