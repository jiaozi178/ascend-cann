param(
    [string]$HostName = "119.36.238.227",
    [int]$Port = 17219,
    [string]$User = "lixinze",
    [string]$RemoteDir = "/ddhome/timers1_lxz/ascend-cann",
    [string]$Branch = "HEAD"
)

$ErrorActionPreference = "Stop"

$repoRoot = git rev-parse --show-toplevel
Push-Location $repoRoot

try {
    git diff --quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Working tree has unstaged changes. Commit or stash before syncing."
    }

    git diff --cached --quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Index has staged changes. Commit or unstage before syncing."
    }

    $safeRemotePrefix = "/ddhome/timers1_lxz/ascend-cann"
    if (-not ($RemoteDir -eq $safeRemotePrefix -or $RemoteDir.StartsWith("$safeRemotePrefix/"))) {
        throw "RemoteDir must be under $safeRemotePrefix"
    }

    $stamp = Get-Date -Format "yyyyMMddHHmmss"
    $bundleName = "ascend-cann-sync-$stamp.tar"
    $localTar = Join-Path $env:TEMP $bundleName
    $remoteTar = "/tmp/$bundleName"
    $target = "${User}@${HostName}"

    git archive --format=tar --output=$localTar $Branch

    scp -P $Port $localTar "${target}:$remoteTar"

    $remoteScript = @"
set -e
REMOTE_DIR='$RemoteDir'
REMOTE_TAR='$remoteTar'
case "`$REMOTE_DIR" in
  /ddhome/timers1_lxz/ascend-cann|/ddhome/timers1_lxz/ascend-cann/*) ;;
  *) echo "Refusing unsafe REMOTE_DIR: `$REMOTE_DIR" >&2; exit 2 ;;
esac
mkdir -p "`$REMOTE_DIR"
find "`$REMOTE_DIR" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
tar -xf "`$REMOTE_TAR" -C "`$REMOTE_DIR"
rm -f "`$REMOTE_TAR"
echo "Synced to `$REMOTE_DIR"
"@

    ssh -p $Port $target $remoteScript
}
finally {
    if (Test-Path $localTar) {
        Remove-Item -LiteralPath $localTar -Force
    }
    Pop-Location
}
