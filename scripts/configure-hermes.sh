#!/usr/bin/env bash
# Phase 4/5 — Hermes 配置（规格 §14/§15/§16/§17）
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
H=hermes

# 模型：stock 为默认 controller（规格 §34：Freedom 须过 benchmark gate 才可升级）
$H config set model.default "qwen3.8:27b"
$H config set model.provider "custom"
$H config set model.base_url "http://127.0.0.1:11434/v1"
$H config set model.context_length 65536

# 沙箱：docker，持久容器，只挂 workspace，断网
$H config set terminal.backend "docker"
$H config set terminal.docker_image "nikolaik/python-nodejs:python3.11-nodejs20"
$H config set terminal.docker_mount_cwd_to_workspace false
$H config set terminal.docker_run_as_host_user false
$H config set terminal.container_persistent true
$H config set terminal.container_cpu 8
$H config set terminal.container_memory 16384
$H config set terminal.docker_volumes "[\"$HOME/FreedomLab/workspace:/workspace\"]"
# 注意：断网用专用键 docker_network=false，不要用 docker_extra_args 的 --network=none
#（实测 hermes 创建容器时不消费 extra_args 里的 network 参数）
$H config set terminal.docker_network false

# 审批：全手动，无人场景一律 deny
$H config set approvals.mode "manual"
$H config set approvals.timeout 300
$H config set approvals.cron_mode "deny"
$H config set approvals.single_query_mode "deny"
$H config set approvals.unattended_mode "deny"
$H config set skills.write_approval true

# 身份
cp ~/FreedomLab/config/hermes/SOUL.md ~/.hermes/SOUL.md

# Memory provider：Hindsight local_embedded（配置本体在 ~/.hermes/hindsight/config.json，
# 参考 config/hermes/hindsight.reference.json）
$H config set memory.provider hindsight

echo "done. verify with: hermes memory status && ~/FreedomLab/scripts/doctor.sh"
