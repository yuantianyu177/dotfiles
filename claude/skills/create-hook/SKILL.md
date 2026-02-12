---
name: create-hook
description: Helps users create hook configurations. Use when the user needs to write, add, or configure hooks.
---

## Steps
1. **Analyze the user input and understand the user's requirements**
2. **Confirm event**: List all options and provide suggestion, ask user for acceptance.
3. **Confirm hook type**: List all options and provide suggestion, ask user for acceptance. Give priority to using the command hook.
4. **Confirm matcher pattern**: Provide some suggestions according to event and ask user for acceptance. The user can specify matcher pattern
5. **Write hook handler script** (for command hook):
    1. Read exit code output, JSON output, Decision control, Reference scripts by path
    2. Read https://code.claude.com/docs/en/hooks#hook-events
    3. Choose the simplest scripting language according to the requirements
    4. Write script
    5. Ask user where to save script, user can specify, default to ~/.cladue/hook_scripts/
    6. Save script
    7. Make scripts executable: `chmod +x`
6. **For prompt/agent type**:
   - Use `$ARGUMENTS` placeholder for hook input JSON
   - Return `{"ok": true/false, "reason": "..."}`
   - Agent hooks can use Read/Grep/Glob (up to 50 turns)
   - Default timeout: prompt=30s, agent=60s
7. **Generate config**: Read ~/.claude/interface/interface.yaml to get template file path, then read the template. You need to read hook fields below to complete the template
8. **Confirm hook save location**: Read Hook locations below and Ask user where to save
9. **Update configuration**

## Supported events
- `SessionStart` - when a session begins(can not block)
- `UserPromptSubmit` - before Claude processes a submitted prompt(can block) 
- `PreToolUse` - before a tool call executes(can block)
- `PermissionRequest` - when a permission dialog appears(can block)
- `PostToolUse` - after a tool call succeeds(can not block)
- `PostToolUseFailure` - after a tool call fails(can not block)
- `Notification` - when a notification is sent(can not block)
- `SubagentStart` - when a subagent starts(can not block)
- `SubagentStop` - when a subagent stops(can not block)
- `Stop` - when Claude finishes responding(can block)
- `TeammateIdle` - when a teammate is about to go idle(can block)
- `TaskCompleted` - when a task is marked as completed(can block)
- `PreCompact` - before context compaction(can not block)
- `SessionEnd` - when a session terminates(can not block)

## Hook locations
| Location | Scope | Shareable |
|-----|-----|-----|
| ~/.claude/settings.json | All your projects |No, local to your machine |
| .claude/settings.json | Single project | Yes, can be committed to the repo |
| .claude/settings.local.json | Single project | No, gitignored |
| Plugin hooks/hooks.json | When plugin is enabled | Yes, bundled with the plugin |
| Skill or agent frontmatter | While the component is active | Yes, defined in the component file |

## Matcher pattern
The matcher field is a regex string that filters when hooks fire. Use "*", "", or omit matcher entirely to match all occurrences. Each event type matches on a different field:

| Event | What the matcher filters | Example matcher values |
|------|--------------------------|------------------------|
| PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest | tool name | `Bash`, `Edit`, `Write`, `mcp__.*` |
| SessionStart | how the session started | `startup`, `resume`, `clear`, `compact` |
| SessionEnd | why the session ended | `clear`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| Notification | notification type | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| SubagentStart | agent type | `Bash`, `Explore`, `Plan`, or custom agent names |
| PreCompact | what triggered compaction | `manual`, `auto` |
| SubagentStop | agent type | same values as `SubagentStart` |
| UserPromptSubmit, Stop, TeammateIdle, TaskCompleted | no matcher support | always fires on every occurrence |

The matcher is a regex, so Edit|Write matches either tool and Notebook.* matches any tool starting with Notebook. The matcher runs against a field from the JSON input that Claude Code sends to your hook on stdin. For tool events, that field is tool_name. Each hook event section lists the full set of matcher values and the input schema for that event.

## Hook type 
- Command hooks (type: "command"): run a shell command.
- Prompt hooks (type: "prompt"): send a prompt to a Claude model for single-turn evaluation.
- Agent hooks (type: "agent"): spawn a subagent that can use tools like Read, Grep, and Glob to verify conditions before returning a decision.

### Common fields
| Field | Required | Description |
|-----|-----|-----|
| type | yes | "command", "prompt", or "agent" |
| timeout | no | Seconds before canceling. Defaults: 600 for command, 30 for prompt, 60 for agenta |
| statusMessage | no | Message displayed while the hook runs |
| once | no | If true, runs only once per session then is removed. Skills only |

### Command hook fields
| Field | Required | Description |
|-----|-----|-----|
| command | yes | shell command to execute |
| async | no | If true, runs in the background without blocking |

### Prompt and agent hook fields
| Field | Required | Description |
|-----|-----|-----|
| prompt | yes | Prompt text to send to the model. Use $ARGUMENTS as a placeholder for the hook input JSON |
| model | no | Model to use for evaluation. Defaults to a fast model |

## Reference scripts by path
- $CLAUDE_PROJECT_DIR: the project root. Wrap in quotes to handle paths with spaces.
- ${CLAUDE_PLUGIN_ROOT}: the plugin’s root directory, for scripts bundled with a plugin.

## Common input fields
| Field | Description |
|-----|-----|
|session_id | Current session identifier |
| transcript_path | Path to conversation JSON |
| cwd | Current working directory when the hook is invoked |
| permission_mode	| Current permission mode: "default", "plan", "acceptEdits", "dontAsk", or "bypassPermissions" |
| hook_event_name | Name of the event that fired |

## Exit code output
The exit code from your hook command tells Claude Code whether the action should proceed, be blocked, or be ignored.
Exit 0 means success. Claude Code parses stdout for JSON output fields. JSON output is only processed on exit 0. For most events, stdout is only shown in verbose mode (Ctrl+O). The exceptions are UserPromptSubmit and SessionStart, where stdout is added as context that Claude can see and act on.
Exit 2 means a blocking error. Claude Code ignores stdout and any JSON in it. Instead, stderr text is fed back to Claude as an error message. The effect depends on the event: PreToolUse blocks the tool call, UserPromptSubmit rejects the prompt, and so on. See exit code 2 behavior for the full list.
Any other exit code is a non-blocking error. stderr is shown in verbose mode (Ctrl+O) and execution continues.

## Common JSON output
| Field | Default | Description |
|-----|-----|-----|
| continue | true | If false, Claude stops processing entirely after the hook runs. Takes precedence over any event-specific decision fields |
| stopReason| none | Message shown to the user when continue is false. Not shown to Claude |
| suppressOutput | false | If true, hides stdout from verbose mode output |
| systemMessage | none | Warning message shown to the user | 

## Decision control
Not every event supports blocking or controlling behavior through JSON. The events that do each use a different set of fields to express that decision. Use this table as a quick reference before writing a hook:

| Events | Decision pattern | Key fields |
|------|------------------|------------|
| UserPromptSubmit, PostToolUse, ToolUseFailure, Stop, SubagentStop | Top-level `decision` | `decision: "block"`, `reason` |
| TeammateIdle, TaskCompleted | Exit code only | Exit code 2 blocks the action, stderr is fed back as feedback |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason` |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (allow/deny) |

Here are examples of each pattern in action:
- Top-level decision: Used by UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, and SubagentStop. The only value is "block". To allow the action to proceed, omit decision from your JSON, or exit 0 without any JSON at all:
```json
{
  "decision": "block",
  "reason": "Test suite must pass before proceeding"
}
```
- PreToolUse: Uses hookSpecificOutput for richer control: allow, deny, or escalate to the user. You can also modify tool input before it runs or inject additional context for Claude. See PreToolUse decision control for the full set of options.
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Database writes are not allowed"
  }
}
```
- PermissionRequest: Uses hookSpecificOutput to allow or deny a permission request on behalf of the user. When allowing, you can also modify the tool’s input or apply permission rules so the user isn’t prompted again.
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow",
      "updatedInput": {
        "command": "npm run lint"
      }
    }
  }
}
```

## Tips
- Run step by step
- Use AskUserQuestion tool whenever you need to ask the user to make a choice. Key rules:
    - Set `multiSelect: true` if needed 
    - `header`: short label
    - `options`: each has `label` and `description`

