#!/usr/bin/env bash
set -euo pipefail

REPO_OP_DIR="${REPO_OP_DIR:-/ddhome/timers1_lxz/ascend-cann/operators/norm/add_rms_norm}"
OPS_NN_OP_DIR="${OPS_NN_OP_DIR:-/ddhome/timers1_lxz/ops-nn/norm/add_rms_norm}"

if [ ! -f "$REPO_OP_DIR/CMakeLists.txt" ]; then
  echo "Cannot find local operator source: $REPO_OP_DIR" >&2
  exit 1
fi

if [ ! -d "$(dirname "$OPS_NN_OP_DIR")" ]; then
  echo "Cannot find ops-nn norm directory: $(dirname "$OPS_NN_OP_DIR")" >&2
  exit 1
fi

rm -rf "$OPS_NN_OP_DIR"
cp -a "$REPO_OP_DIR" "$OPS_NN_OP_DIR"

echo "Exported add_rms_norm to $OPS_NN_OP_DIR"
