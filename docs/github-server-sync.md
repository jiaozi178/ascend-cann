# GitHub and Ascend Server Sync Guide

This guide sets up a simple pull-based workflow:

```text
local Windows workspace -> GitHub -> Ascend server pulls latest code -> optional build/run command
```

## 1. Create the GitHub Repository

Create an empty GitHub repository in the browser. Do not add a README, `.gitignore`, or license
there, because this local repository already has those files.

Suggested repository name:

```text
ascend-cann-dev
```

After GitHub creates the empty repository, copy its SSH URL:

```text
git@github.com:<your-github-name>/ascend-cann-dev.git
```

or HTTPS URL:

```text
https://github.com/<your-github-name>/ascend-cann-dev.git
```

## 2. Connect This Local Repository to GitHub

Run this in the local Windows workspace:

```powershell
git remote add origin git@github.com:<your-github-name>/ascend-cann-dev.git
git push -u origin main
```

If SSH auth to GitHub is not configured on Windows, use HTTPS instead:

```powershell
git remote add origin https://github.com/<your-github-name>/ascend-cann-dev.git
git push -u origin main
```

## 3. Prepare the Ascend Server Directory

Run this in the VS Code Remote-SSH terminal:

```bash
mkdir -p /ddhome/lixinze/cann_projects
cd /ddhome/lixinze/cann_projects
```

Use `/ddhome`, not `/home/lixinze`, because `/home` has very little free space.

## 4. Let the Server Access GitHub

For a private GitHub repository, the cleanest approach is a GitHub deploy key.

On the server:

```bash
ssh-keygen -t ed25519 -C "ascend-cann-deploy" -f ~/.ssh/ascend_cann_deploy -N ""
cat ~/.ssh/ascend_cann_deploy.pub
```

In GitHub:

```text
Repository -> Settings -> Deploy keys -> Add deploy key
```

Paste the public key. Read-only access is enough for server sync.

Then add this server SSH config:

```bash
cat >> ~/.ssh/config <<'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/ascend_cann_deploy
  IdentitiesOnly yes
EOF

chmod 600 ~/.ssh/config
ssh -T git@github.com
```

GitHub should respond that authentication succeeded.

## 5. First Clone on the Server

Run this on the server:

```bash
cd /ddhome/lixinze/cann_projects
git clone git@github.com:<your-github-name>/ascend-cann-dev.git
cd ascend-cann-dev
```

## 6. Manual Sync Test

Run this on the server:

```bash
cd /ddhome/lixinze/cann_projects/ascend-cann-dev
bash scripts/server_pull_and_run.sh
```

If you want the sync script to run a build command after pulling, pass `RUN_COMMAND`:

```bash
RUN_COMMAND='echo "replace this with your CANN build command"' \
bash scripts/server_pull_and_run.sh
```

## 7. Optional Automatic Sync with Cron

After the manual sync works, add a cron job on the server:

```bash
crontab -e
```

Add this line:

```cron
* * * * APP_DIR=/ddhome/lixinze/cann_projects/ascend-cann-dev BRANCH=main /bin/bash /ddhome/lixinze/cann_projects/ascend-cann-dev/scripts/server_pull_and_run.sh >> /ddhome/lixinze/cann_projects/sync.log 2>&1
```

This checks GitHub once per minute and pulls new commits.

## 8. Daily Development Loop

On Windows:

```powershell
git status
git add .
git commit -m "Update operator code"
git push
```

On the server, the cron job pulls it automatically. For immediate sync:

```bash
cd /ddhome/lixinze/cann_projects/ascend-cann-dev
bash scripts/server_pull_and_run.sh
```
