#!/usr/bin/env bash

source /root/miniconda3/etc/profile.d/conda.sh
conda activate timers1_lxz
source /ddhome/timers1_lxz/Ascend/cann-8.5.0/set_env.sh

export LD_LIBRARY_PATH="/ddhome/timers1_lxz/Ascend/cann-8.5.0/opp/vendors/custom_nn/op_api/lib:${LD_LIBRARY_PATH:-}"
cd /ddhome/timers1_lxz
