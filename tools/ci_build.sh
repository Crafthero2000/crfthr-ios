#!/usr/bin/env bash
set -euo pipefail

for dep in gh git; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    echo "Missing dependency: $dep"
    exit 1
  fi
done

if ! gh auth status >/dev/null 2>&1; then
  echo "Not authenticated. Run: gh auth login"
  exit 1
fi

branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$branch" = "HEAD" ]; then
  echo "Detached HEAD; cannot determine branch."
  exit 1
fi

start_epoch=$(date +%s)
gh workflow run "219005466" --ref "$branch"

runid=""
for attempt in 1 2 3; do
  line=$(gh run list --workflow ios-build.yml --branch "$branch" --limit 5 --json databaseId,createdAt,status --jq '.[0] | "\(.databaseId)\t\(.createdAt)"')
  if [ -n "$line" ]; then
    IFS=$'\t' read -r candidate_id created_at <<<"$line"
    if [ -n "${candidate_id:-}" ] && [ -n "${created_at:-}" ]; then
      created_epoch=$(date -d "$created_at" +%s 2>/dev/null || true)
      if [ -n "$created_epoch" ] && [ "$created_epoch" -ge "$start_epoch" ]; then
        runid="$candidate_id"
        break
      fi
    fi
  fi
  sleep 2
done

if [ -z "$runid" ]; then
  echo "Failed to determine run id."
  exit 1
fi

echo "runid=$runid"

while true; do
  line=$(gh run view "$runid" --json status,conclusion,url --jq '"\(.status)\t\(.conclusion // \"\")\t\(.url)"')
  IFS=$'\t' read -r status conclusion run_url <<<"$line"
  echo "status=$status wait=30s"
  if [ "$status" = "completed" ]; then
    break
  fi
  sleep 30
done

if [ "${conclusion:-}" != "success" ]; then
  if [ -n "${run_url:-}" ]; then
    echo "Run failed: $run_url"
  else
    echo "Run failed. Use: gh run view --web $runid"
  fi
  exit 1
fi

tmpdir=$(mktemp -d)
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

dest_dir="$HOME/Downloads/crfthr-builds"
mkdir -p "$dest_dir"
find "$dest_dir" -maxdepth 1 -type f \( -name "*.zip" -o -name "*.ipa" \) -delete

gh run download "$runid" --dir "$tmpdir"

mapfile -t files < <(find "$tmpdir" -type f \( -name "*.zip" -o -name "*.ipa" \))
if [ "${#files[@]}" -eq 0 ]; then
  echo "No artifacts found."
  exit 1
fi

timestamp=$(date +%Y%m%d_%H%M%S)
saved=()
for f in "${files[@]}"; do
  base=$(basename "$f")
  name="${base%.*}"
  ext="${base##*.}"
  out="$dest_dir/${name}_${timestamp}.${ext}"
  cp "$f" "$out"
  saved+=("$out")
done

echo "DONE"
printf '%s\n' "${saved[@]}"
