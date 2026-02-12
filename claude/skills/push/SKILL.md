---
name: push
description: Safely push commits to remote. Use when the user wants to push code, says "push", or wants to publish local commits.
---

When pushing changes, follow these steps:

1. **Confirm branch**: Run `git branch --show-current` and `git log --oneline @{u}..HEAD` to show the current branch and unpushed commits. Ask the user to confirm this is the intended branch.

2. **Check for sensitive content**: Run `git diff @{u}..HEAD` to review all unpushed changes. Scan for:
   - Secrets, tokens, API keys, passwords (e.g., `.env`, `credentials`, hardcoded strings like `sk-`, `token=`, `password=`)
   - Debug code (e.g., `console.log`, `print(`, `debugger`, `TODO`, `FIXME` that look temporary)
   - Config files that should not be committed (e.g., `.vscode/`, `.idea/`, `*.local`)
   - If any issues are found, warn the user and ask whether to proceed

3. **Pull latest and check conflicts**: Run `git pull --rebase` to sync with remote. If conflicts occur:
   - Show the conflicting files with `git diff --name-only --diff-filter=U`
   - Attempt to resolve conflicts automatically where possible
   - For complex conflicts, show the conflict content and ask the user how to resolve
   - After resolving, run `git rebase --continue`

4. **Push**: Run `git push` to push the commits

5. **Verify**: Run `git status` and `git log --oneline -3` to confirm push success

IMPORTANT:
- NEVER force push (`--force` or `-f`) unless the user explicitly asks
- NEVER push to main/master without user confirmation
- If pushing to main/master, always warn the user first
- If pre-push hook fails, show the error and ask the user how to proceed
