# Huawei Ascend CANN Development

This repository is the local development workspace for Timer-S1 Ascend CANN
operator work.

## Workflow

1. Develop and edit files locally with Codex.
2. Sync the local working tree to the Ascend server with `scripts/sync_to_server.ps1`.
3. Build and run inside the `timers1_lxz` Docker container.
4. Commit and push to GitHub for backup and history.

## Current Notes

- Remote SSH host alias: `ascend-cann`
- Remote user: `lixinze`
- Container: `timers1_lxz`
- Remote workspace root: `/ddhome/timers1_lxz`
- CANN installation: `/ddhome/timers1_lxz/Ascend/cann-8.5.0`
- Target operator: `aclnnAddRmsNorm` from `ops-nn/norm/add_rms_norm`

## Useful Files

- `docs/timers1_lxz_workflow.md`: current local-to-server workflow.
- `docs/session_handoff.md`: concise context for resuming in a new Codex session.
- `scripts/sync_to_server.ps1`: Windows-to-server sync helper.
- `scripts/enter_timers1_lxz_env.sh`: container environment bootstrap.
- `scripts/export_add_rms_norm_to_ops_nn.sh`: copy local operator source into `ops-nn`.
- `scripts/build_add_rms_norm.sh`: build and install `add_rms_norm`.
- `operators/norm/add_rms_norm/`: local development home for the target operator.
- `docs/timer_s1_operator_notes.md`: existing operator development notes.

## Sync to Server

```powershell
.\scripts\sync_to_server.ps1
```

## Basic Local Git Commands

```powershell
git status
git add .
git commit -m "Update CANN operator workspace"
git push origin main
```
