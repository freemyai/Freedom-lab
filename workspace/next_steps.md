# Next Steps — Freedom Lab

## 阻塞中（等 owner）

- [ ] `sudo usermod -aG docker nvidia` → 启用 Docker 沙箱 → A01-A07

## 下一步

1. Docker 沙箱验收（A06/A07 安全项是 PASS 条件）
2. 重启持久化测试（重启 ollama + hermes，问"昨天做到哪里"）
3. FreedomBench-Freedom 全量（`python3 benchmarks/run.py freedom benchmarks/freedom/lawful-sensitive.yaml`）
4. 连续两周 dogfood：每天真实工作 + 每日结束整理记忆/skill

## 两周研究问题（规格 §58）

- Q1 去拒绝后 tool/memory 能力损失多少
- Q2 两周后 memory 是否产生依赖
- Q3 哪类记忆最有价值
- Q4 现有 Hindsight/Hermes 哪里不满足真正的 Personal AI
- Q5 最值得自研重写哪一层
