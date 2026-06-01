# Huawei Ascend CANN Development

This repository is the local development workspace for Ascend CANN operator work.

## Workflow

1. Develop and edit files locally with Codex.
2. Commit changes to this Git repository.
3. Push the `main` branch to GitHub.
4. Let the Ascend server pull the latest code from GitHub into `/ddhome/lixinze/cann_projects`.
5. Build and run on the Ascend server.

## Current Notes

- Remote SSH host alias: `ascend-cann`
- Remote user: `lixinze`
- Recommended remote workspace root: `/ddhome/lixinze/cann_projects`
- Avoid using `/home/lixinze` for project builds because the checked server has very little free space there.

## Useful Files

- `docs/github-server-sync.md`: GitHub repository and server sync setup guide.
- `scripts/server_pull_and_run.sh`: server-side pull-and-run helper for cron or manual sync.
- `Timer-S1 算子开发 分享.md`: existing operator development notes.

## Basic Local Git Commands

```powershell
git status
git add .
git commit -m "Update CANN operator workspace"
git push origin main
```
