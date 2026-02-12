#!/bin/bash
# Auto-approve specific tools via PreToolUse hook
# Reads tool_name from stdin JSON and allows whitelisted tools

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [ -z "$TOOL_NAME" ]; then
  exit 0
fi

# Whitelist of tools to auto-approve (add more as needed)
ALLOWED_TOOLS="WebSearch WebFetch Read"

for tool in $ALLOWED_TOOLS; do
  if [ "$TOOL_NAME" = "$tool" ]; then
    jq -n '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "allow",
        permissionDecisionReason: "Auto-approved by hook"
      }
    }'
    exit 0
  fi
done

# Also auto-approve all MCP tools (mcp__*)
if echo "$TOOL_NAME" | grep -qE '^mcp__'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      permissionDecisionReason: "Auto-approved MCP tool by hook"
    }
  }'
  exit 0
fi

# Not in whitelist, let normal permission flow handle it
exit 0
