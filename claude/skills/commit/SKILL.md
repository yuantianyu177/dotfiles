---
name: commit
description: Git commit helper. Use when the user wants to commit changes or say "commit"
---

When committing changes, follow these steps:

1. **Check status**: Run `git status --porcelain` to get all changed files. If nothing is changed, inform the user and exit, else ask user which files needed to be committed
2. **Categorize changes by type**: Run `git diff` and classify the files that need to be committed(According type as below). Divide the modifications into multiple commits by category 
    | Type    | Description                   |
    |---------|-------------------------------|
    | feat    | New feature                   |
    | fix     | Bug fix                       |
    | docs    | Documentation                 |
    | style   | Code formatting               |
    | refactor| Code refactor                 |
    | perf    | Performance improvement       |
    | test    | Add or update tests           |
    | chore   | Build, tooling, or maintenance|
    | ci      | CI/CD configuration           |
3. **Commit one by one**: For each commit:
    1. Stage files belong to this commit
    2. Commit, run:
        ```
        git commmit -m "$cat << 'EOF'
        <type>(<scope>): <subject>
        
        <body>(Optionally, when the modification is complex and requires detailed explanations)
        
        Co-Authored-By: <current model>
        EOF
        )"
        ```
    3. Verify: Run `git status` after commit to confirm success.

## Tips
- Never amend previous commits unless explicitly asked
- Never push unless explicitly asked
- Never use `--no-verify`
- Focus on **why** the change is made, not just what
- Keep each commit isolated by logical type
- Use AskUserQuestion tool whenever you need to ask the user to make a choice. Key rules:
    - Set `multiSelect: true` if needed 
    - `header`: short label
    - `options`: each has `label` and `description`
