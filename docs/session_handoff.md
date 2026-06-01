# Session Handoff

Use this file to resume work in a new Codex session.

## Local Workspace

Open this folder in VS Code:

```text
C:\Users\DELL\Desktop\ascend-cann-dev
```

Do not continue development in the old Chinese-named folder. It was copied only to avoid
Windows path-encoding issues.

GitHub backup:

```text
https://github.com/jiaozi178/ascend-cann.git
```

The Ascend server cannot currently reach GitHub reliably, so server sync uses `scp`/`ssh`.

## Remote Server

SSH alias:

```text
ascend-cann
```

Raw SSH info:

```text
HostName 119.36.238.227
Port 17219
User lixinze
```

Server/container layout:

```text
/ddhome/timers1_lxz/Ascend       CANN 8.5.0 installation
/ddhome/timers1_lxz/ascend-cann  synced copy of this local repo
/ddhome/timers1_lxz/ops-nn       upstream ops-nn clone/build workspace
```

Docker container:

```text
timers1_lxz
```

Conda environment:

```text
timers1_lxz
```

NPU hardware verified:

```text
8 x 910B4, npu-smi status OK
```

## Enter Remote Development Environment

On the server host:

```bash
docker exec -it timers1_lxz bash
```

Inside the container:

```bash
source /ddhome/timers1_lxz/ascend-cann/scripts/enter_timers1_lxz_env.sh
```

Equivalent expanded commands:

```bash
source /root/miniconda3/etc/profile.d/conda.sh
conda activate timers1_lxz
source /ddhome/timers1_lxz/Ascend/cann-8.5.0/set_env.sh
export LD_LIBRARY_PATH=/ddhome/timers1_lxz/Ascend/cann-8.5.0/opp/vendors/custom_nn/op_api/lib:${LD_LIBRARY_PATH}
cd /ddhome/timers1_lxz
```

## Target Operator

Current target:

```text
aclnnAddRmsNorm / add_rms_norm
```

Local source copy:

```text
operators/norm/add_rms_norm
```

Upstream reference on server:

```text
/ddhome/timers1_lxz/ops-nn/norm/add_rms_norm
```

Verified installed artifacts:

```text
/ddhome/timers1_lxz/Ascend/cann-8.5.0/opp/vendors/custom_nn/op_api/include/aclnnop/aclnn_add_rms_norm.h
/ddhome/timers1_lxz/Ascend/cann-8.5.0/opp/vendors/custom_nn/op_api/lib/libcust_opapi.so
```

## What Is Already Done

- VS Code Remote-SSH connection works.
- Docker container `timers1_lxz` exists and can see NPU devices.
- Independent conda environment `timers1_lxz` was cloned from `timers1_ljm`.
- Independent CANN 8.5.0 was installed under `/ddhome/timers1_lxz/Ascend`.
- `ops-nn` 8.5.0 was cloned on the server.
- `add_rms_norm` was built with:

```bash
bash build.sh --pkg --soc=ascend910b --ops=add_rms_norm
```

- Custom package was installed into the local CANN path with:

```bash
/ddhome/timers1_lxz/ops-nn/build_out/cann-ops-nn-custom-linux.aarch64.run --quiet --install-path /ddhome/timers1_lxz/Ascend/cann-8.5.0
```

- The upstream `add_rms_norm` source was copied back into this local repo.

## Local-to-Server Sync

From local Windows PowerShell:

```powershell
cd "C:\Users\DELL\Desktop\ascend-cann-dev"
.\scripts\sync_to_server.ps1
```

This syncs non-ignored files to:

```text
/ddhome/timers1_lxz/ascend-cann
```

Ignored local reference files such as PDFs, Excel files, `mstt/`, build outputs, logs, and
temporary bundles are not sent.

If PowerShell blocks scripts, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync_to_server.ps1
```

## Build From Server

Inside the container:

```bash
bash /ddhome/timers1_lxz/ascend-cann/scripts/build_add_rms_norm.sh
```

This first copies local source from:

```text
/ddhome/timers1_lxz/ascend-cann/operators/norm/add_rms_norm
```

into:

```text
/ddhome/timers1_lxz/ops-nn/norm/add_rms_norm
```

Then it rebuilds and reinstalls `add_rms_norm`.

## Next Work

Recommended next task:

1. Create a small Timer-S1-focused test for `aclnnAddRmsNorm`.
2. Compare the ACLNN output against a PyTorch/Numpy reference for representative Timer-S1 tensor shapes.
3. Start tuning or adapting `operators/norm/add_rms_norm` for Timer-S1 once the test is stable.

When starting a new Codex session, say:

```text
Please read docs/session_handoff.md first and continue from there.
```
