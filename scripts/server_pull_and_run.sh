#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/ddhome/lixinze/cann_projects/ascend-cann-dev}"
BRANCH="${BRANCH:-main}"
REPO_URL="${REPO_URL:-}"
RUN_COMMAND="${RUN_COMMAND:-}"

if ! command -v git >/dev/null 2>&1; then
  echo "git is not installed on this server."
  exit 1
fi

mkdir -p "$(dirname "$APP_DIR")"

if [ ! -d "$APP_DIR/.git" ]; then
  if [ -z "$REPO_URL" ]; then
    echo "APP_DIR is not a Git repo yet. Set REPO_URL before first run."
    echo "Example:"
    echo "  REPO_URL=git@github.com:<user>/<repo>.git APP_DIR=$APP_DIR $0"
    exit 2
  fi

  git clone --branch "$BRANCH" "$REPO_URL" "$APP_DIR"
fi

cd "$APP_DIR"

git fetch origin "$BRANCH"
git pull --ff-only origin "$BRANCH"

if [ -n "$RUN_COMMAND" ]; then
  bash -lc "$RUN_COMMAND"
fi
