#!/bin/bash
# Auto-approve safe read-only bash commands
# Used by PermissionRequest hook

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Extract the first word (base command), handling leading env vars, sudo, etc.
BASE_CMD=$(echo "$COMMAND" | sed 's/^[A-Z_]*=[^ ]* *//' | awk '{print $1}' | sed 's|.*/||')

# Safe read-only commands whitelist
SAFE_COMMANDS="ls cat head tail grep rg find pwd echo which type file wc diff sort uniq tr cut date whoami hostname uname env printenv id stat du df free ps"

# Safe git subcommands (read-only)
SAFE_GIT_SUBCMDS="status log diff show branch tag remote stash list shortlog describe ls-files ls-tree blame reflog"

for safe in $SAFE_COMMANDS; do
  if [ "$BASE_CMD" = "$safe" ]; then
    jq -n '{
      hookSpecificOutput: {
        hookEventName: "PermissionRequest",
        decision: {
          behavior: "allow"
        }
      }
    }'
    exit 0
  fi
done

# Check git read-only subcommands
if [ "$BASE_CMD" = "git" ]; then
  GIT_SUBCMD=$(echo "$COMMAND" | sed 's/^[A-Z_]*=[^ ]* *//' | awk '{print $2}')
  for safe in $SAFE_GIT_SUBCMDS; do
    if [ "$GIT_SUBCMD" = "$safe" ]; then
      jq -n '{
        hookSpecificOutput: {
          hookEventName: "PermissionRequest",
          decision: {
            behavior: "allow"
          }
        }
      }'
      exit 0
    fi
  done
fi

# Not a safe command, let the permission dialog show
exit 0
