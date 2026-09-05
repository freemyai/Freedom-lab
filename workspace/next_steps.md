# Next Steps — Freedom Lab

## 已完成

- [x] Docker 沙箱启用 + A01-A07 验收（A06 ~/.ssh 不可达 PASS；A07 无外网 PASS）
- [x] doctor.sh 10/10 PASS（2026-09-05）
- [x] Ollama 重启后记忆持久化验证 PASS

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
