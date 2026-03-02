---
name: crew
description: Manage your AI team. /crew = roster, /crew add [name] "[domain]" = new member, /crew [name] [task] = assign task.
user-invocable: true
---

# Crew

## Routing — read the arguments first

| Arguments | Action |
|-----------|--------|
| none | Show roster |
| `add [name] "[domain]"` | Scaffold a new crew member |
| `[name]` | Activate member, ask for task |
| `[name] [task]` | Activate member with task |

---

## No arguments — show roster

1. Use Glob to find all `.claude/team/*/SKILL.md` files (skip `.claude/team/SKILL.md` itself)
2. For each, read `name` and `description` from the frontmatter
3. Read the last entry in their `history.md` to show what they last worked on
4. Present a formatted roster
5. Ask which member to work with

---

## `add [name] "[domain]"` — scaffold a new member

If name or domain is missing, ask for them before proceeding.

### 1. Check if member already exists

Use Glob to check if `.claude/team/{name}/` already exists.

If it does, **stop and ask**:
> `{name}` already exists as a crew member. Overwrite? This will replace `SKILL.md`, `context.md`, and `history.md` — all existing context and history will be lost.

Only proceed if the user explicitly confirms. If not, abort and suggest `/crew {name}` to activate the existing member.

### 2. Create `.claude/team/{name}/SKILL.md`

```markdown
---
name: {NAME}
description: Domain expert for {DOMAIN}.
user-invocable: false
---

# {NAME} — {DOMAIN}

## On every task — before writing a single line of code

1. Read `.claude/team/{NAME}/context.md` — understand the current state of the domain
2. Read `.claude/team/{NAME}/history.md` — understand how it got here and why decisions were made
3. Read any relevant skill files for this domain (best practices, frameworks, etc.)
4. Only then proceed with the task

## On every task — after completing the work

1. **Update `context.md`** — reflect any changes to files, patterns, architecture, or configuration
2. **Append to `history.md`** — add a dated entry with:
   - What was done and why
   - Which files changed
   - Run `git log --oneline -1` and record the commit ID and message
   - PR number if one exists
   - Any decisions made and their rationale
   - Any gotchas discovered
```

### 3. Create `.claude/team/{name}/context.md`

```markdown
# {NAME} — Domain Context: {DOMAIN}

Last updated: {TODAY'S DATE}

## What This Domain Does

[Describe what this domain is responsible for — 2-3 sentences]

---

## Key Files

| File | Role |
|------|------|
| `path/to/file` | What it does |

---

## Architecture

[Describe the architecture — how data flows, what calls what]

---

## Key Patterns

[Document the patterns used in this domain]

---

## Important Constraints & Gotchas

[Things that are non-obvious, decisions that look wrong but aren't, things not to change]

---

## Environment Variables

[Any env vars this domain depends on]

---

## Dependencies

[Key packages this domain uses]
```

### 4. Create `.claude/team/{name}/history.md`

```markdown
# {NAME} — Domain History: {DOMAIN}

---

## {TODAY'S DATE} — Initial setup

**Added by:** /crew add

Domain expert created for: {DOMAIN}

Fill in `context.md` with the current state of the domain before assigning the first task.
```

### 5. Update MEMORY.md

Find or create the `## Crew` section and add:
```
- `/crew {name}` — {DOMAIN}. Context + history in `.claude/team/{name}/`.
```

### 6. Confirm

Tell the user:
- What was created
- To fill in `context.md` with the current domain state
- To run `/crew {name} [task]` to activate

---

## `[name]` or `[name] [task]` — activate a member

1. Read `.claude/team/{name}/SKILL.md`
2. Follow its instructions exactly
3. Treat any remaining text as the task description
4. If no task was provided, ask the user what they'd like to work on
