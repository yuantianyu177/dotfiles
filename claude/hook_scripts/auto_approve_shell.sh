#!/bin/bash
# Auto-approve safe read-only bash commands
# Used by PermissionRequest hook

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Safe read-only commands whitelist
SAFE_COMMANDS="ls cat head tail grep rg find pwd echo which type file wc diff sort uniq tr cut date whoami hostname uname env printenv id stat du df free ps"

# Safe git subcommands (read-only)
SAFE_GIT_SUBCMDS="status log diff show branch tag remote stash list shortlog describe ls-files ls-tree blame reflog"

# Check if a single command is safe
is_safe_command() {
  local cmd="$1"
  # Strip leading env vars (e.g. FOO=bar command)
  cmd=$(echo "$cmd" | sed 's/^[[:space:]]*//' | sed 's/^[A-Z_]*=[^ ]* *//')
  local base=$(echo "$cmd" | awk '{print $1}' | sed 's|.*/||')

  [ -z "$base" ] && return 0

  for safe in $SAFE_COMMANDS; do
    [ "$base" = "$safe" ] && return 0
  done

  if [ "$base" = "git" ]; then
    local subcmd=$(echo "$cmd" | awk '{print $2}')
    for safe in $SAFE_GIT_SUBCMDS; do
      [ "$subcmd" = "$safe" ] && return 0
    done
  fi

  return 1
}

# Split on &&, ||, ;, | and check every sub-command
# Replace operators with newline, then check each part
ALL_SAFE=true
while IFS= read -r subcmd; do
  if ! is_safe_command "$subcmd"; then
    ALL_SAFE=false
    break
  fi
done <<< "$(echo "$COMMAND" | sed 's/&&/\n/g; s/||/\n/g; s/|/\n/g; s/;/\n/g')"

if [ "$ALL_SAFE" = true ]; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PermissionRequest",
      decision: {
        behavior: "allow"
      }
    }
  }'
fi

# Not all safe, let the permission dialog show
exit 0
