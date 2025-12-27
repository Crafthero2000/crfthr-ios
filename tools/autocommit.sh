#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "not a git repository"
  exit 1
fi

status="$(git status --porcelain)"
if [ -z "$status" ]; then
  echo "clean"
  exit 0
fi

msg="chore: autosave"
push=false

if [ $# -gt 0 ] && [[ "${1}" != "-"* ]]; then
  msg="$1"
  shift
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --message)
      shift
      if [ $# -eq 0 ]; then
        echo "missing --message value"
        exit 1
      fi
      msg="$1"
      ;;
    --push)
      push=true
      ;;
  esac
  shift
done

git add -A
if ! git commit -m "$msg" --no-verify >/dev/null 2>&1; then
  echo "nothing to commit"
  exit 0
fi

if $push; then
  git push >/dev/null 2>&1 || true
fi

git log -1 --format="%h %s"
