#!/usr/bin/env bash
set -euo pipefail

source /root/miniconda3/etc/profile.d/conda.sh
conda activate timers1_lxz
source /ddhome/timers1_lxz/Ascend/cann-8.5.0/set_env.sh

export LD_LIBRARY_PATH="/ddhome/timers1_lxz/Ascend/cann-8.5.0/opp/vendors/custom_nn/op_api/lib:${LD_LIBRARY_PATH:-}"

OPS_NN_DIR="${OPS_NN_DIR:-/ddhome/timers1_lxz/ops-nn}"
CANN_HOME="${CANN_HOME:-/ddhome/timers1_lxz/Ascend/cann-8.5.0}"
OP_NAME="${OP_NAME:-add_rms_norm}"
SOC="${SOC:-ascend910b}"

cd "$OPS_NN_DIR"

rm -rf build output build_out
bash build.sh --pkg --soc="$SOC" --ops="$OP_NAME"

cd "$OPS_NN_DIR/build"
make package

PKG="$OPS_NN_DIR/build_out/cann-ops-nn-custom-linux.aarch64.run"

if [ -x "$CANN_HOME/opp/vendors/custom_nn/uninstall.sh" ]; then
  "$CANN_HOME/opp/vendors/custom_nn/uninstall.sh" || true
fi

"$PKG" --quiet --install-path "$CANN_HOME"

echo
echo "Installed $OP_NAME into $CANN_HOME/opp/vendors/custom_nn"
find "$CANN_HOME/opp/vendors/custom_nn" -name 'aclnn_add_rms_norm.h' -o -name 'libcust_opapi.so'
