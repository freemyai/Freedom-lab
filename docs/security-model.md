# Freedom Lab v0 — 安全模型

## 核心哲学

> 自由的是模型，受 Owner 控制的是权限。
> Model Freedom ≠ Computer Permission。

## 分层

1. **模型层**：Stock / Freedom 可互换；Freedom 模型低拒绝，但不自动获得高权限。
2. **Agent 层**（Hermes）：approvals.mode=manual；危险命令 [o]nce/[s]ession/[a]lways/[d]eny。
3. **执行层**（Docker 沙箱）：
   - backend=docker，container_persistent
   - 仅挂载 ~/FreedomLab/workspace → /workspace
   - --network=none（沙箱无外网；Agent 的 Web 能力走 Hermes 自身通道）
   - 不挂 $HOME/.ssh/.aws/凭据
   - 不用 --privileged
4. **记忆层**：Hindsight 本地 embedded PG；不记 secrets（retain mission 明确排除凭据）。
5. **网络层**：Ollama 仅 127.0.0.1:11434；不暴露到 LAN。

## v0 禁止事项

修改全局防火墙 / 暴露 Ollama/Hindsight 到 LAN / 挂整个 $HOME / 读 ~/.ssh /
--privileged / 全局关闭审批 / YOLO 模式 / 换付费云 API。

## 当前已知缺口

- Docker 沙箱待 docker 组授权（owner 执行 sudo usermod）后启用
- Ollama 用户级运行，重启机器后需跑 scripts/start-ollama.sh（无 systemd 用户服务，因无 sudo）
