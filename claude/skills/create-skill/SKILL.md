---
name: create-skill
description: Create skill automatically. Use when the user says "generate skill" or "create skill"
---

## Steps
1. **Read the template format**: The path of template is queried in ~/.claude/interface/interface.yaml, then read the format
2. **Confirm the name**: Provide suggestions and ask the user for acceptance. The user can specify the name.
3. **Output skill content in format**: Output skill according context, use English. Must add the second tip(Use AskUserQuestion tool) to the skill content
4. **Ask user if accept** Three options: 
    - Accept: Continue
    - Reject: Stop
    - Update: Accept user input and update SKILL.md, then ask again
5. **Ask user the application scope**: Create directory and save SKILL.md to specify location. Three options: 
    - Personal: ~/.claude/skills/<skill-name>/SKILL.md 
    - Project: <project-path>/.claude/skills/<skill-name>/SKILL.md
    - Plugin: <plugin>/skills/<skill-name>/SKILL.md, user specify <plugin>
## Tips
- When create skill, if any error occurs, stop and output the error
- Use AskUserQuestion tool whenever you need to ask the user to make a choice. Key rules:
    - Set `multiSelect: true` if needed 
    - `header`: short label
    - `options`: each has `label` and `description`


