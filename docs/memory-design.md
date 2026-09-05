# Freedom Lab v0 — Memory 设计

## 双层记忆

```text
Hermes built-in                Hindsight (bank=freedom-main)
─────────────                  ─────────────────────────────
USER.md  稳定画像      ←互补→   knowledge graph / observations
MEMORY.md 长期事实             temporal retrieval / world / experience
sessions/ 完整历史             reflect()
skills/   程序性记忆           retain mission 控制记什么
```

## 数据位置

- 内置：~/.hermes/memories/{USER.md,MEMORY.md}
- Hindsight：~/.pg0/instances/hindsight-embed-hermes（embedded PostgreSQL）
- 配置：~/.hermes/hindsight/config.json（local_embedded + Ollama qwen3.8:27b）

## Recall 策略

recall_budget=mid, recall_max_tokens=2500, recall_types=observation,world,experience
auto_retain（每轮）+ auto_recall（同步）。

## 已验证能力（2026-09-05）

- [x] retain：决定写入 freedom-main，consolidation 生成 observation
- [x] recall：跨 session 召回"为什么不先做硬件"+ 理由
- [x] temporal update：2026Q4 → 2027Q1，当前状态正确且保留历史
- [x] Memory > Model：换 freedom 模型后记忆完整保留

## 待做（v0.2+）

- [ ] Hindsight vs OpenViking A/B
- [ ] M01-M08 全量 benchmark
- [ ] memory provenance UI
- [ ] generalized learning（M06）验证
