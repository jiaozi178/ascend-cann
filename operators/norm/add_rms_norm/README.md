# add_rms_norm / aclnnAddRmsNorm

This directory is the local development home for the Timer-S1 `aclnn_add_rms_norm`
operator work.

The upstream reference implementation currently lives on the Ascend server at:

```text
/ddhome/timers1_lxz/ops-nn/norm/add_rms_norm
```

After syncing this repository to the server, run the import helper inside the
`timers1_lxz` container if you want to copy the upstream source into this directory:

```bash
cd /ddhome/timers1_lxz/ascend-cann
bash scripts/import_add_rms_norm_from_ops_nn.sh
```

Then bring those files back to the local machine before editing them locally.

## Target

- Operator directory in `ops-nn`: `norm/add_rms_norm`
- Build option: `--ops=add_rms_norm`
- ACLNN API: `aclnnAddRmsNorm`
- Header after package install:

```text
/ddhome/timers1_lxz/Ascend/cann-8.5.0/opp/vendors/custom_nn/op_api/include/aclnnop/aclnn_add_rms_norm.h
```

## Server Environment

Inside the container:

```bash
source /ddhome/timers1_lxz/ascend-cann/scripts/enter_timers1_lxz_env.sh
```

Build and install the operator package:

```bash
bash /ddhome/timers1_lxz/ascend-cann/scripts/build_add_rms_norm.sh
```
