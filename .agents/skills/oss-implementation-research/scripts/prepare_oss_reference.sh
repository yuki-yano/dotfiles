#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  prepare_oss_reference.sh <repo-spec> --target-dir <path> [--ref <ref>]

Arguments:
  <repo-spec>   GitHub repo shorthand (owner/repo), HTTPS URL, or SSH URL
  --target-dir  Destination base directory (must be relative to repo root)
  --ref <ref>   Optional branch/tag/commit to checkout (detached)

Output:
  Prints machine-readable lines:
    SELECTION_MODE=explicit
    BASE_DIR=<path>
    CLONE_DIR=<path>
    REPO_URL=<url>
    HEAD_COMMIT=<sha>
    IGNORE_STATUS=<ignored|not_ignored|unknown>

Exit code:
  0  Success
  2  Missing target directory; caller should ask user when unsure
EOF
}

repo_spec=""
ref=""
target_dir=""
ignore_status="unknown"

normalize_remote_identity() {
  local url="$1"
  local host=""
  local path=""

  if [[ "$url" =~ ^git@([^:]+):(.+)$ ]]; then
    host="${BASH_REMATCH[1]}"
    path="${BASH_REMATCH[2]}"
  elif [[ "$url" =~ ^ssh://git@([^/]+)/(.+)$ ]]; then
    host="${BASH_REMATCH[1]}"
    path="${BASH_REMATCH[2]}"
  elif [[ "$url" =~ ^https?://([^/]+)/(.+)$ ]]; then
    host="${BASH_REMATCH[1]}"
    path="${BASH_REMATCH[2]}"
  else
    printf "%s\n" "$url"
    return 0
  fi

  host="${host,,}"
  path="${path#/}"
  path="${path%.git}"
  path="${path%/}"
  printf "%s/%s\n" "$host" "$path"
}

resolve_ref_to_commit() {
  local repo_dir="$1"
  local ref_name="$2"
  local commit=""

  if commit="$(git -C "$repo_dir" rev-parse --verify --quiet "${ref_name}^{commit}" 2>/dev/null)"; then
    printf "%s\n" "$commit"
    return 0
  fi
  if commit="$(git -C "$repo_dir" rev-parse --verify --quiet "refs/remotes/origin/${ref_name}^{commit}" 2>/dev/null)"; then
    printf "%s\n" "$commit"
    return 0
  fi
  if commit="$(git -C "$repo_dir" rev-parse --verify --quiet "refs/tags/${ref_name}^{commit}" 2>/dev/null)"; then
    printf "%s\n" "$commit"
    return 0
  fi
  return 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --ref)
      [[ $# -ge 2 ]] || { echo "error: --ref requires a value" >&2; exit 1; }
      ref="$2"
      shift 2
      ;;
    --target-dir)
      [[ $# -ge 2 ]] || { echo "error: --target-dir requires a value" >&2; exit 1; }
      target_dir="$2"
      shift 2
      ;;
    --*)
      echo "error: unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      if [[ -z "$repo_spec" ]]; then
        repo_spec="$1"
      else
        echo "error: unexpected argument: $1" >&2
        usage
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ -z "$repo_spec" ]]; then
  usage
  exit 1
fi

if [[ -z "$target_dir" ]]; then
  echo "NEEDS_USER_INPUT=1"
  echo "REASON=target_dir_required"
  exit 2
fi

if [[ "$target_dir" = /* ]]; then
  echo "error: --target-dir must be a repository-relative path" >&2
  exit 1
fi

git_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$git_root" ]]; then
  echo "error: run this command inside a git repository" >&2
  exit 1
fi

repo_url=""
repo_slug=""

if [[ "$repo_spec" =~ ^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$ ]]; then
  repo_url="https://github.com/${repo_spec}.git"
  repo_slug="${repo_spec/\//--}"
elif [[ "$repo_spec" =~ ^https?:// ]] || [[ "$repo_spec" =~ ^git@ ]]; then
  repo_url="$repo_spec"
  normalized="$repo_spec"
  normalized="${normalized#git@github.com:}"
  normalized="${normalized#ssh://git@github.com/}"
  normalized="${normalized#https://github.com/}"
  normalized="${normalized#http://github.com/}"
  normalized="${normalized%.git}"
  if [[ "$normalized" =~ ^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$ ]]; then
    repo_slug="${normalized/\//--}"
  else
    repo_slug="$(basename "$normalized")"
    repo_slug="${repo_slug%.git}"
  fi
else
  echo "error: unsupported repo spec: $repo_spec" >&2
  usage
  exit 1
fi

git_root_real="$(cd "$git_root" && pwd -P)"
base_dir_candidate="$git_root/$target_dir"
mkdir -p "$base_dir_candidate"
base_dir="$(cd "$base_dir_candidate" && pwd -P)"

case "$base_dir" in
  "$git_root_real"|"$git_root_real"/*)
    ;;
  *)
    echo "error: --target-dir resolves outside the repository: $target_dir" >&2
    exit 1
    ;;
esac

if [[ "$base_dir" == "$git_root_real" ]]; then
  rel_base="."
else
  rel_base="${base_dir#"$git_root_real"/}"
fi

mkdir -p "$base_dir"
clone_dir="$base_dir/$repo_slug"

if [[ -d "$clone_dir/.git" ]]; then
  current_origin="$(git -C "$clone_dir" remote get-url origin 2>/dev/null || true)"
  if [[ -z "$current_origin" ]]; then
    echo "error: existing clone has no origin remote: $clone_dir" >&2
    exit 1
  fi

  requested_identity="$(normalize_remote_identity "$repo_url")"
  current_identity="$(normalize_remote_identity "$current_origin")"
  if [[ "$requested_identity" != "$current_identity" ]]; then
    echo "error: existing clone origin does not match requested repository" >&2
    echo "requested=$repo_url" >&2
    echo "existing_origin=$current_origin" >&2
    exit 1
  fi

  git -C "$clone_dir" fetch --all --tags --prune
else
  if [[ -e "$clone_dir" ]]; then
    echo "error: destination exists and is not a git repository: $clone_dir" >&2
    exit 1
  fi
  git clone --filter=blob:none "$repo_url" "$clone_dir"
fi

if [[ -n "$ref" ]]; then
  git -C "$clone_dir" fetch --all --tags --prune
  resolved_commit="$(resolve_ref_to_commit "$clone_dir" "$ref" || true)"
  if [[ -z "$resolved_commit" ]]; then
    echo "error: ref not found: $ref" >&2
    exit 1
  fi
  git -C "$clone_dir" checkout --detach "$resolved_commit"
fi

probe="$rel_base/.codex-ignore-probe"
if git -C "$git_root" check-ignore -q "$probe"; then
  ignore_status="ignored"
else
  ignore_status="not_ignored"
fi

head_commit="$(git -C "$clone_dir" rev-parse HEAD)"

printf "SELECTION_MODE=explicit\n"
printf "BASE_DIR=%s\n" "$base_dir"
printf "CLONE_DIR=%s\n" "$clone_dir"
printf "REPO_URL=%s\n" "$repo_url"
printf "HEAD_COMMIT=%s\n" "$head_commit"
printf "IGNORE_STATUS=%s\n" "$ignore_status"
