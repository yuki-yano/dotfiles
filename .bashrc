# NOTE: Workaround for Homebrew shellenv in sandbox-exec environments
#
# Issue:
# - AI Agents like Claude Code run brew commands in sandbox-exec environments
# - brew internally calls shellenv which tries to detect the shell name
# - shellenv executes /bin/ps to detect the parent shell, but ps is restricted in sandbox
# - This causes brew commands to fail with "Operation not permitted" errors
#
# Solution:
# - When HOMEBREW_PATH is already set, shellenv skips the ps command execution
# - By pre-setting this environment variable, we can avoid the sandbox restriction
# - This allows brew to work without modifying Homebrew's source code
#
# Reference: Library/Homebrew/cmd/shellenv.sh:9-11
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_PATH="/opt/homebrew/bin:/opt/homebrew/sbin"
