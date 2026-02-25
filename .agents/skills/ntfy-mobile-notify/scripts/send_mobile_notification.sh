#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  NTFY_TOPIC="your-topic" ~/.agents/skills/ntfy-mobile-notify/scripts/send_mobile_notification.sh --summary "<100-200文字の要約>" [options]

Options:
  --summary <value>       Required. 100-200文字の通知本文
  --title-suffix <value>  Optional. タイトル末尾。既定: スマホ通知
  --agent <value>         Optional. codex or claude を指定
  --title <value>         Optional. 完全なタイトル指定（[$REPO_NAME] プレフィックス必須）
  --repo-name <value>     Optional. REPO_NAME の上書き
  --dry-run               Optional. 送信せずにコマンドだけ表示
  --help                  Show this help
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

char_count() {
  printf '%s' "$1" | wc -m | tr -d '[:space:]'
}

normalize_agent() {
  local value
  value="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  case "$value" in
    codex|claude)
      printf '%s' "$value"
      ;;
    *)
      die "agent は codex または claude を指定してください"
      ;;
  esac
}

detect_agent() {
  if [[ -n "${CLAUDECODE:-}" || -n "${CLAUDE_CODE:-}" || -n "${ANTHROPIC_API_KEY:-}" || -n "${ANTHROPIC_MODEL:-}" ]]; then
    printf 'claude'
    return
  fi
  if [[ -n "${CODEX_HOME:-}" || -n "${CODEX_ENV:-}" || -n "${OPENAI_API_KEY:-}" ]]; then
    printf 'codex'
    return
  fi
  printf 'codex'
}

resolve_agent_label() {
  local agent_kind="$1"
  case "$agent_kind" in
    codex)
      printf 'Codex'
      ;;
    claude)
      printf 'Claude Code'
      ;;
    *)
      die "未知の agent です: ${agent_kind}"
      ;;
  esac
}

summary=""
title=""
title_suffix="スマホ通知"
repo_name=""
agent=""
dry_run="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --summary)
      [[ $# -ge 2 ]] || die "--summary の値が必要です"
      summary="$2"
      shift 2
      ;;
    --title-suffix)
      [[ $# -ge 2 ]] || die "--title-suffix の値が必要です"
      title_suffix="$2"
      shift 2
      ;;
    --agent)
      [[ $# -ge 2 ]] || die "--agent の値が必要です"
      agent="$(normalize_agent "$2")"
      shift 2
      ;;
    --title)
      [[ $# -ge 2 ]] || die "--title の値が必要です"
      title="$2"
      shift 2
      ;;
    --repo-name)
      [[ $# -ge 2 ]] || die "--repo-name の値が必要です"
      repo_name="$2"
      shift 2
      ;;
    --dry-run)
      dry_run="true"
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      die "不明なオプションです: $1"
      ;;
  esac
done

[[ -n "$summary" ]] || die "--summary は必須です"

summary_length="$(char_count "$summary")"
if [[ "$summary_length" -lt 100 || "$summary_length" -gt 200 ]]; then
  die "--summary は 100-200 文字で指定してください（現在: ${summary_length}文字）"
fi

if [[ -z "$repo_name" ]]; then
  repo_name="$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "non-git")"
fi

if [[ -z "$agent" ]]; then
  if [[ -n "${NTFY_NOTIFY_AGENT:-}" ]]; then
    agent="$(normalize_agent "$NTFY_NOTIFY_AGENT")"
  else
    agent="$(detect_agent)"
  fi
fi

agent_label="$(resolve_agent_label "$agent")"

if [[ -z "$title" ]]; then
  title="[${repo_name}] ${agent_label} ${title_suffix}"
fi

[[ "$title" == "[$repo_name]"* ]] || die "--title は [${repo_name}] で始めてください"

[[ -n "${NTFY_TOPIC:-}" ]] || die "NTFY_TOPIC が設定されていません"

if [[ "$dry_run" != "true" ]]; then
  command -v ntfy >/dev/null 2>&1 || die "ntfy コマンドが見つかりません"
fi

if [[ "$dry_run" == "true" ]]; then
  printf 'DRY-RUN: ntfy publish -t %q %q %q\n' "$title" "$NTFY_TOPIC" "$summary"
  exit 0
fi

ntfy publish -t "$title" "$NTFY_TOPIC" "$summary"
