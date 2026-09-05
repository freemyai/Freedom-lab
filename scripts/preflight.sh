#!/usr/bin/env bash
# Freedom Lab v0 — Phase 0 system preflight
set -uo pipefail

echo "===== uname ====="
uname -a
echo "arch: $(uname -m)"

echo
echo "===== OS ====="
cat /etc/os-release 2>/dev/null | head -5

echo
echo "===== GPU ====="
nvidia-smi || { echo "FAIL: nvidia-smi"; exit 1; }

echo
echo "===== CUDA ====="
nvcc --version 2>/dev/null || echo "nvcc not found (non-fatal)"

echo
echo "===== Docker ====="
docker --version || echo "FAIL: docker cli missing"
docker compose version 2>/dev/null || echo "WARN: docker compose missing"
docker info >/dev/null 2>&1 && echo "docker daemon: OK" || echo "WARN: docker daemon not accessible (docker group?)"

echo
echo "===== Memory ====="
free -h

echo
echo "===== Disk ====="
df -h / /home 2>/dev/null | sort -u

echo
echo "===== Preflight done ====="
