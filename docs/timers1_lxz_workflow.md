# Timer-S1 Local-to-Server Workflow

Use GitHub for backup and history. Use `scp`/`ssh` sync for the Ascend server because
the server cannot currently reach GitHub.

## Local Sync

From Windows PowerShell:

```powershell
cd "C:\Users\DELL\Desktop\ascend-cann-dev"
.\scripts\sync_to_server.ps1
```

This syncs non-ignored repository files to:

```text
/ddhome/timers1_lxz/ascend-cann
```

Ignored local reference files such as PDF, Excel, and `mstt/` are not sent.

## Enter Server Environment

On the server:

```bash
docker exec -it timers1_lxz bash
source /ddhome/timers1_lxz/ascend-cann/scripts/enter_timers1_lxz_env.sh
```

## Build add_rms_norm

Inside the container:

```bash
bash /ddhome/timers1_lxz/ascend-cann/scripts/build_add_rms_norm.sh
```

## Directory Roles

```text
/ddhome/timers1_lxz/Ascend       CANN 8.5.0 installation
/ddhome/timers1_lxz/ops-nn       upstream ops-nn source and build workspace
/ddhome/timers1_lxz/ascend-cann  this synced development repository
```
