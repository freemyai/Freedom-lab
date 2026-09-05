# Decisions — Freedom Lab

## 2026-09-04/05 v0 技术栈

- Agent: Hermes Agent v0.21.0（不 fork，只作 dependency）
- Memory: Hindsight local_embedded，bank=freedom-main（OpenViking 留 v0.2 A/B）
- 模型: qwen3.8:27b stock = controller；freedom-qwen3.8:27b = conversation/creative
- 推理: Ollama 用户级（v0 不追 SGLang/vLLM）
- 执行: Docker 沙箱（network=none，只挂 workspace）
- 方向: 先做软件 MVP，不做 NAS/硬件 —— 先验证 Memory × Agency × Ownership

## 理由

每一层可换：模型可换、memory 引擎可换、agent 可换。先 dogfood 现成最优组合，
痛点来自真实使用，不来自猜测。
