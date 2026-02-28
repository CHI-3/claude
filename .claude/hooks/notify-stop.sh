#!/bin/bash
set -euo pipefail

# hookの入力JSON
META="$(cat)"

# transcript_path を取得
TP="$(printf '%s' "$META" | jq -r '.transcript_path // empty')"

# repo名は cwd から（なければ空）
REPO="$(printf '%s' "$META" | jq -r '.cwd // empty' | awk -F/ '{print $NF}')"

# 最後の user メッセージ（1行だけ拾う：軽量優先）
# ※ jsonlは1行1jsonなので grep で user 行を探す
PROMPT30="Task Completed"
if [ -n "${TP:-}" ] && [ -f "$TP" ]; then
  LAST_USER_LINE="$(grep -F '"type":"user"' "$TP" | tail -n 1 || true)"
  if [ -n "${LAST_USER_LINE:-}" ]; then
    PROMPT30="$(printf '%s' "$LAST_USER_LINE" | jq -r '.message.content // "Task Completed"' | tr '\r\n' ' ' | cut -c1-30)"
  fi
fi

LABEL="完了"
if [ -n "${REPO:-}" ]; then
  BODY="[$REPO] $LABEL $PROMPT30"
else
  BODY="$LABEL $PROMPT30"
fi

/usr/bin/osascript -e "display notification \"${BODY//\"/\\\"}\" with title \"Claude Code\""