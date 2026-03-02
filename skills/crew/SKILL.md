---
name: crew
description: View your AI team roster or activate a domain expert. /crew to see all members, /crew [name] [task] to assign a task.
user-invocable: true
---

# Crew

## If invoked with no arguments

1. Use Glob to find all `.claude/team/*/SKILL.md` files (skip `.claude/team/SKILL.md` itself)
2. For each, read the `name` and `description` from the frontmatter
3. Optionally read the last entry in their `history.md` to show what they last worked on
4. Present a formatted roster
5. Ask which member to work with

## If invoked with a member name as the first argument (e.g. `/crew ester` or `/crew ester [task]`)

1. Read `.claude/team/{name}/SKILL.md`
2. Follow its instructions exactly — as if the user had invoked that member directly
3. Treat any remaining text after the name as the task description
4. If no task is provided, ask the user what they'd like to work on
