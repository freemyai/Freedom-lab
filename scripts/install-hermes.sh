#!/usr/bin/env bash
# Phase 4 — 安装 Hermes Agent（github.com 被墙，git clone 走 gh-proxy.com）
set -euo pipefail

GIT_CONFIG_COUNT=1 \
GIT_CONFIG_KEY_0="url.https://gh-proxy.com/https://github.com/.insteadOf" \
GIT_CONFIG_VALUE_0="https://github.com/" \
  bash <(curl -fsSL https://hermes-agent.nousresearch.com/install.sh)

export PATH="$HOME/.local/bin:$PATH"
hermes --version
