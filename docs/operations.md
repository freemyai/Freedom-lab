# Freedom Lab v0 — 运维手册

## 启动

```bash
~/FreedomLab/scripts/start-ollama.sh   # 用户级 ollama serve，64K context
hermes                                  # 进入 Freedom
```

注意：Hindsight 嵌入模型下载需要 HF 镜像，首次运行用：

```bash
HF_ENDPOINT=https://hf-mirror.com hermes
```

（已写入 ~/.hindsight/profiles/hermes.env 则不需要。）

## 健康检查

```bash
~/FreedomLab/scripts/doctor.sh
```

## 备份（记忆 > 模型权重）

```bash
~/FreedomLab/scripts/backup.sh
```

输出到 ~/FreedomLab/vault/backups/。venv/模型权重不备份（可重建），
~/.pg0（Hindsight PG 数据）、~/.hermes 配置与记忆必备份。

## 版本快照

```bash
~/FreedomLab/scripts/snapshot-versions.sh
```

## 切换模型

```bash
hermes config set model.default freedom-qwen3.8:27b   # Freedom
hermes config set model.default qwen3.8:27b           # Stock (默认 controller)
```

## 升级规则（规格 §28）

先 `backup.sh` + `snapshot-versions.sh`，才允许 `hermes update`。

## 网络受限备忘（本机实测）

- github.com 被墙；api.github.com 直连可用（release 资产走 API asset endpoint）
- git clone 用 `GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=url.https://gh-proxy.com/https://github.com/.insteadOf GIT_CONFIG_VALUE_0=https://github.com/` 作用于单条命令
- huggingface.co 被墙；用 hf-mirror.com（HF_ENDPOINT）+ HF CDN 直连可 range 并行下载
- pypi.org 慢；用 UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple（28MB/s vs 0.5MB/s）
- ollama.com 可达；registry.ollama.ai 可达且快
- 大文件分片并行下载：scripts/parallel-download.sh

## 故障排除：LoRA adapter '27b' 400

**症状**：API 400 "LoRA adapter '27b' was requested"。
**根因**：会话的模型名带冒号（旧时代的 `qwen3.8:27b`），SGLang 把冒号当
`model:adapter` LoRA 语法。`/new` 会继承上一个会话的模型名，所以旧会话
会「传染」新会话。
**修复**：会话内 `/model` 选横杠名（freedom-qwen3.8-27b / qwen3.8-27b），
或退出重开 `hermes`。
