#!/bin/bash
# check-crew-history.sh
#
# Stop hook: blocks Claude from finishing if a crew member updated context.md
# more recently than history.md (i.e., domain context changed but no history
# entry was appended).
#
# Uses file mtimes — works even when .claude/team/ is untracked by git.
# Threshold: context.md must be newer than history.md by > 60 seconds to flag.

set -euo pipefail

input=$(cat)

# Prevent infinite loop — don't re-trigger if we already blocked once this turn
stop_hook_active=$(python3 -c "
import sys, json
d = json.load(sys.stdin)
print(str(d.get('stop_hook_active', False)).lower())
" <<< "$input" 2>/dev/null || echo "false")

if [ "$stop_hook_active" = "true" ]; then
  exit 0
fi

THRESHOLD=60  # seconds — context.md must be this much newer than history.md to flag

missing_history=""

for context_file in .claude/team/*/context.md; do
  [ -f "$context_file" ] || continue

  member_dir=$(dirname "$context_file")
  member=$(basename "$member_dir")
  history_file="$member_dir/history.md"

  [ -f "$history_file" ] || continue

  # Get mtimes in epoch seconds (works on macOS and Linux)
  context_mtime=$(python3 -c "import os; print(int(os.path.getmtime('$context_file')))")
  history_mtime=$(python3 -c "import os; print(int(os.path.getmtime('$history_file')))")

  diff=$((context_mtime - history_mtime))

  if [ "$diff" -gt "$THRESHOLD" ]; then
    missing_history="$missing_history $member"
  fi
done

if [ -n "$missing_history" ]; then
  members="${missing_history# }"
  python3 -c "
import json, sys
members = sys.argv[1]
paths = ', '.join(f'.claude/team/{m}/history.md' for m in members.split())
print(json.dumps({
  'decision': 'block',
  'reason': f'context.md was updated more recently than history.md for crew member(s) [{members}]. Append a dated entry to {paths} documenting what was done before finishing.'
}))
" "$members"
fi
