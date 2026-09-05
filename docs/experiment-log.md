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

- [x] Ollama v0.33.3 用户级运行，OLLAMA_CONTEXT_LENGTH=65536，API 200
- [x] qwen3.8:27b stock：27.3B / Q4_K_M / 262K ctx / tools+thinking+vision；API smoke PASS
- [x] freedom-qwen3.8:27b：JonathanColetti GGUF Q4_K_M 16.8GB，sha256 4c5e2db0… 已记录；tools capability ✓（AGENT_CAPABLE=true）；中文创作质量在线
- [x] Hermes v0.21.0 → custom endpoint 127.0.0.1:11434/v1；oneshot 回答正确
- [x] 内置记忆：写入四原则 → 新 session 全对（4/4）
- [x] Hindsight local_embedded：bank=freedom-main，retain→consolidation→observation 全链路本地（日志证实 RETAIN_BATCH + CONSOLIDATION）
- [x] 跨 session recall：「为什么不先做硬件」→ 决策 + 理由 + 日期正确
- [x] Temporal：2026Q4→2027Q1 计划变更，当前态正确、历史保留
- [x] Memory > Model：切 freedom-qwen3.8:27b 后记忆完整（§39 核心实验 PASS）
- [ ] Docker 沙箱：等 owner sudo 加 docker 组（唯一阻塞项）

### Failure

- ollama.com/install.sh 307 到 github releases（被墙）→ 改 api.github.com asset 直连 + 12 路分片
- PyPI 官方源 ~0.5MB/s → 清华镜像 28MB/s（uv 缓存兼容，换源后分钟级完成）
- tar --exclude 裸目录名不生效 → backup 改 find 清单法
- sudo 无免密 → Ollama 用户级启动脚本替代 systemd；Docker 组待授权

### Conclusion

Freedom Lab v0 的 Continuity / Freedom / Ownership 三支柱已验证；
Agency 的 Docker 沙箱隔离待最后一条 sudo 命令。

### Next Action

1. Owner 执行 docker 组授权 → Phase A01-A07 agent benchmark
2. 重启持久化验证（M08 / Killer Acceptance Test Day2）
3. FreedomBench-Freedom 全量跑批

---

## Experiment 2026-09-05 (晚) — 审查复盘 + FreedomBench 第一轮

### 审查发现（对照两份文档逐项核查）

1. **model.default 曾被留在 freedom-qwen3.8:27b**（违反 §34 gate）→ 已改回 stock。
   疑似某 hermes session 退出时把活动模型写回了 config.yaml，待观察复现。
2. §42 Privacy Gate 首次执行：活跃配置 provider=custom/base_url=127.0.0.1 ✓；
   config.yaml 仅存 stt.openai 等 provider 选项模板，无活跃云端点 ✓
3. §43 Secret Gate 首次执行：git 内无真实凭据 ✓
4. tar --exclude 裸名不生效 → backup.sh 改 find 清单法（已修，备份 3.6G→150M）
5. docker_extra_args 的 --network=none 不被 hermes 消费 → 改用原生键
   terminal.docker_network=false（实测容器 NetworkMode=none ✓）
6. 补齐 §4 缺失脚本：install-ollama.sh / pull-models.sh / install-hermes.sh /
   configure-hermes.sh（记录受限网络下的真实安装路径）
7. 补齐 §30 缺失 benchmark 定义：memory M07/M08、agent shell/coding/tool_calling/recovery、
   freedom creative/controversial/instruction

### FreedomBench-Freedom 第一轮（无 max_tokens，timeout=600s）

- Stock qwen3.8:27b：8/8 完成，**0 误拒**（含暴力小说、历史争议、政治分析、
  医学信息、法律分析全部给出高质量回答），75s-545s/题
- Freedom（JonathanColetti Q4_K_M, temp=1.0）：**6/8 超时**（>600s 未完成），
  仅两个创作类案例完成且质量不错
- 初步结论：stock 在这些合法敏感题上本就不拒答，URR(stock)=0/8；
  freedom 模型的长 thinking 失控风险是真实能力问题（§36 gate 不通过 → 维持
  stock 为 controller 的决策被数据支持）
- 混淆变量：freedom 的 Modelfile 是 temperature=1.0/top_p=0.95（§11 规格值），
  stock 用 ollama 默认采样 —— 不完全公平，记入方法论备注

### 第二轮（复测 freedom，max_tokens=4096, timeout=900s）

（进行中）

### Next Action

- 第二轮结果出来后做 URR/质量对比表
- 若 freedom 仍不可靠 → 尝试 B 候选 OBLITERATUS 或调低 temperature 复测
- M01-M08 全量 memory benchmark
- §54 整机重启验收（需 owner 执行 sudo reboot）
