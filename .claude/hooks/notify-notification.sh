#!/bin/bash
set -euo pipefail

META="$(cat)"

TP="$(printf '%s' "$META" | jq -r '.transcript_path // empty')"
REPO="$(printf '%s' "$META" | jq -r '.cwd // empty' | awk -F/ '{print $NF}')"
NTYPE="$(printf '%s' "$META" | jq -r '.notification_type // empty')"

case "$NTYPE" in
  permission_prompt) LABEL="許可待ち" ;;
  idle_prompt)       LABEL="入力待ち" ;;
  *)                 LABEL="通知" ;;
esac

PROMPT30="Task Completed"
if [ -n "${TP:-}" ] && [ -f "$TP" ]; then
  LAST_USER_LINE="$(grep -F '"type":"user"' "$TP" | tail -n 1 || true)"
  if [ -n "${LAST_USER_LINE:-}" ]; then
    PROMPT30="$(printf '%s' "$LAST_USER_LINE" | jq -r '.message.content // "Task Completed"' | tr '\r\n' ' ' | cut -c1-30)"
  fi
fi

if [ -n "${REPO:-}" ]; then
  BODY="[$REPO] $LABEL $PROMPT30"
else
  BODY="$LABEL $PROMPT30"
fi

/usr/bin/osascript -e "display notification \"${BODY//\"/\\\"}\" with title \"Claude Code\""