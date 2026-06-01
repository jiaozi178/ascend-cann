#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-/ddhome/timers1_lxz/ascend-cann}"
OPS_NN_OP_DIR="${OPS_NN_OP_DIR:-/ddhome/timers1_lxz/ops-nn/norm/add_rms_norm}"
TARGET_DIR="$REPO_DIR/operators/norm/add_rms_norm"

if [ ! -d "$OPS_NN_OP_DIR" ]; then
  echo "Cannot find upstream operator directory: $OPS_NN_OP_DIR" >&2
  exit 1
fi

mkdir -p "$(dirname "$TARGET_DIR")"
rm -rf "$TARGET_DIR"
cp -a "$OPS_NN_OP_DIR" "$TARGET_DIR"

echo "Imported add_rms_norm into $TARGET_DIR"
