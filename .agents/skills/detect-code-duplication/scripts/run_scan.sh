#!/usr/bin/env bash
set -euo pipefail

target_path="${1:-.}"
threshold="${SIMILARITY_THRESHOLD:-0.60}"
min_lines="${SIMILARITY_MIN_LINES:-3}"
extensions="${SIMILARITY_EXTENSIONS:-ts,tsx,js,jsx}"
allow_excluded_target="${SIMILARITY_ALLOW_EXCLUDED_TARGET:-0}"
timestamp="$(date +"%Y%m%d-%H%M%S")"
run_id="${timestamp}-$$"
run_dir="docs/tmp/duplication/runs/${run_id}"
report_path="${run_dir}/similarity-report.txt"
meta_path="${run_dir}/scan-meta.env"
plans_root="docs/plans"
active_dir="${plans_root}/active"
completed_dir="${plans_root}/completed"
cancelled_dir="${plans_root}/cancelled"
plan_path="${active_dir}/refactor-duplications-${run_id}.md"

resolve_abs_path() {
  local path="$1"
  if [ -d "${path}" ]; then
    (cd "${path}" && pwd -P)
  else
    local dir base
    dir="$(dirname "${path}")"
    base="$(basename "${path}")"
    (cd "${dir}" && printf '%s/%s\n' "$(pwd -P)" "${base}")
  fi
}

is_excluded_path() {
  local path="$1"
  case "${path}/" in
    */node_modules/*|*/dist/*|*/build/*|*/coverage/*|*/.git/*|*/docs/tmp/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

if ! command -v similarity-ts >/dev/null 2>&1; then
  {
    echo "ERROR: similarity-ts is not installed."
    if command -v mise >/dev/null 2>&1; then
      echo "Install with: mise use -g cargo:similarity-ts@latest"
    else
      echo "Install with: cargo install similarity-ts"
    fi
  } >&2
  exit 1
fi

if [ ! -e "${target_path}" ]; then
  echo "ERROR: target path does not exist: ${target_path}" >&2
  exit 1
fi

target_abs="$(resolve_abs_path "${target_path}")"
if is_excluded_path "${target_abs}" && [ "${allow_excluded_target}" != "1" ]; then
  {
    echo "ERROR: target path is inside excluded directories: ${target_path}"
    echo "Set SIMILARITY_ALLOW_EXCLUDED_TARGET=1 to override intentionally."
  } >&2
  exit 2
fi

if [ -d "${target_path}" ]; then
  files_scanned="$(rg --files "${target_path}" 2>/dev/null \
    | rg '\.(ts|tsx|js|jsx)$' \
    | rg -v '/(node_modules|dist|build|coverage|\.git|docs/tmp)/' \
    | wc -l \
    | tr -d ' ' || true)"

  total_lines="$(rg -n '.*' "${target_path}" \
    -g '*.ts' -g '*.tsx' -g '*.js' -g '*.jsx' \
    -g '!**/node_modules/**' \
    -g '!**/dist/**' \
    -g '!**/build/**' \
    -g '!**/coverage/**' \
    -g '!**/.git/**' \
    -g '!**/docs/tmp/**' 2>/dev/null \
    | wc -l \
    | tr -d ' ' || true)"
elif [ -f "${target_path}" ]; then
  case "${target_path}" in
    *.ts|*.tsx|*.js|*.jsx)
      files_scanned="1"
      total_lines="$(wc -l < "${target_path}" | tr -d ' ')"
      ;;
    *)
      files_scanned="0"
      total_lines="0"
      ;;
  esac
else
  echo "ERROR: target path is not a regular file or directory: ${target_path}" >&2
  exit 1
fi

if [ "${files_scanned:-0}" -eq 0 ]; then
  echo "ERROR: no TypeScript/JavaScript files found in target path: ${target_path}" >&2
  exit 2
fi

mkdir -p "${run_dir}" "${active_dir}" "${completed_dir}" "${cancelled_dir}"

similarity-ts "${target_path}" \
  --extensions "${extensions}" \
  --threshold "${threshold}" \
  --min-lines "${min_lines}" \
  --exclude node_modules \
  --exclude dist \
  --exclude build \
  --exclude coverage \
  --exclude .git \
  --exclude docs/tmp \
  > "${report_path}"

{
  echo "TIMESTAMP=${timestamp}"
  echo "RUN_ID=${run_id}"
  echo "TARGET_PATH=${target_path}"
  echo "TARGET_PATH_ABS=${target_abs}"
  echo "THRESHOLD=${threshold}"
  echo "MIN_LINES=${min_lines}"
  echo "EXTENSIONS=${extensions}"
  echo "ALLOW_EXCLUDED_TARGET=${allow_excluded_target}"
  echo "RUN_DIR=${run_dir}"
  echo "REPORT_PATH=${report_path}"
  echo "PLANS_ROOT=${plans_root}"
  echo "PLAN_ACTIVE_DIR=${active_dir}"
  echo "PLAN_COMPLETED_DIR=${completed_dir}"
  echo "PLAN_CANCELLED_DIR=${cancelled_dir}"
  echo "PLAN_PATH=${plan_path}"
  echo "FILES_SCANNED=${files_scanned:-0}"
  echo "TOTAL_LINES=${total_lines:-0}"
} > "${meta_path}"

cat <<EOF
RUN_DIR=${run_dir}
REPORT_PATH=${report_path}
PLAN_ACTIVE_DIR=${active_dir}
PLAN_COMPLETED_DIR=${completed_dir}
PLAN_CANCELLED_DIR=${cancelled_dir}
PLAN_PATH=${plan_path}
META_PATH=${meta_path}
FILES_SCANNED=${files_scanned:-0}
TOTAL_LINES=${total_lines:-0}
EOF
