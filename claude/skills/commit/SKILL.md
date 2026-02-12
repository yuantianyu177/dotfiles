---
name: commit
description: Git commit helper. Use when the user wants to commit changes, create a git commit, or says "commit".
---

When committing changes, follow these steps:

1. **Check status**: Run `git status` and `git diff --staged` to review staged changes. If nothing is staged, run `git diff` to show unstaged changes and ask the user what to stage
2. **Stage files**: Stage relevant files using specific file paths (avoid `git add -A` or `git add .`). Never stage files containing secrets (.env, credentials, etc.)
3. **Generate commit message**: Write a concise commit message in conventional commit format (e.g., `feat:`, `fix:`, `docs:`, `refactor:`). Focus on "why" not "what"
4. **Commit**: Create the commit using a HEREDOC format:
   ```
   git commit -m "$(cat <<'EOF'
   <type>: <subject>

   Co-Authored-By: <current model> 
   EOF
   )"
   ```
5. **Verify**: Run `git status` after commit to confirm success.

## Tips
- Never amend previous commits unless explicitly asked
- Never push unless explicitly asked
- Never use --no-verify
- If pre-commit hook fails, fix the issue and create a NEW commit
- Use AskUserQuestion tool whenever you need to ask the user to make a choice. Key rules:
    - Set `multiSelect: true` if needed 
    - `header`: short label
    - `options`: each has `label` and `description`

