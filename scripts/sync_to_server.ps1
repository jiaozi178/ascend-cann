param(
    [string]$HostName = "ascend-cann",
    [int]$Port = 17219,
    [string]$User = "lixinze",
    [string]$RemoteDir = "/ddhome/timers1_lxz/ascend-cann",
    [string]$Branch = "HEAD",
    [switch]$CommittedOnly
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Push-Location $repoRoot

try {
    $safeRemotePrefix = "/ddhome/timers1_lxz/ascend-cann"
    if (-not ($RemoteDir -eq $safeRemotePrefix -or $RemoteDir.StartsWith("$safeRemotePrefix/"))) {
        throw "RemoteDir must be under $safeRemotePrefix"
    }

    $stamp = Get-Date -Format "yyyyMMddHHmmss"
    $bundleName = "ascend-cann-sync-$stamp.tar"
    $localTar = Join-Path $env:TEMP $bundleName
    $stageDir = Join-Path $env:TEMP "ascend-cann-sync-$stamp"
    $remoteTar = "/tmp/$bundleName"
    $target = "${User}@${HostName}"

    if ($CommittedOnly) {
        git archive --format=tar --output=$localTar $Branch
    }
    else {
        New-Item -ItemType Directory -Path $stageDir -Force | Out-Null
        $files = git ls-files --cached --others --exclude-standard

        foreach ($file in $files) {
            if ([string]::IsNullOrWhiteSpace($file)) {
                continue
            }

            $source = Join-Path $repoRoot $file
            if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
                continue
            }

            $dest = Join-Path $stageDir $file
            $destParent = Split-Path -Parent $dest
            if ($destParent) {
                New-Item -ItemType Directory -Path $destParent -Force | Out-Null
            }

            Copy-Item -LiteralPath $source -Destination $dest -Force
        }

        tar -cf $localTar -C $stageDir .
    }

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
if [ -d "`$REMOTE_DIR/scripts" ]; then
  find "`$REMOTE_DIR/scripts" -type f -name '*.sh' -exec chmod +x {} +
fi
rm -f "`$REMOTE_TAR"
echo "Synced to `$REMOTE_DIR"
"@

    ssh -p $Port $target $remoteScript
}
finally {
    if (Test-Path $localTar) {
        Remove-Item -LiteralPath $localTar -Force
    }
    if ($stageDir -and (Test-Path $stageDir)) {
        Remove-Item -LiteralPath $stageDir -Recurse -Force
    }
    Pop-Location
}
