---
name: crew
description: Manage your AI team. /crew = roster, /crew add [name] "[domain]" = new member, /crew [name] [task] = assign task.
metadata:
  compatibility: Claude Code
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
5. After the roster, show available commands:
   - `/crew` — show roster
   - `/crew [name]` — activate a member
   - `/crew [name] [task]` — activate a member with a task
   - `/crew add [name] "[domain]"` — scaffold a new member
6. Ask which member to work with

---

## `add [name] "[domain]"` — scaffold a new member

If name or domain is missing, ask for them before proceeding.

### 1. Check if member already exists

Use Glob to check if `.claude/team/{name}/` already exists.

If it does, **stop and ask**:
> `{name}` already exists as a crew member. Overwrite? This will replace `SKILL.md`, `context.md`, `history.md`, and `decisions.md` — all existing context and history will be lost.

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

1. Read `.claude/team/{name}/context.md` — understand the current state of the domain
2. Read `.claude/team/{name}/decisions.md` — key architectural decisions, gotchas, things not to undo
3. Read the last entries in `.claude/team/{name}/history.md` — recent work and what just changed
4. Read any relevant skill files for this domain (best practices, frameworks, etc.)
5. Only then proceed with the task

## On every task — after completing the work

1. **Update `context.md`** — reflect any changes to files, patterns, architecture, or configuration
2. **Append to `history.md`** — add a dated entry with:
   - What was done and why
   - Which files changed
   - Run `git log --oneline -1` and record the commit ID and message
   - PR number if one exists
   - Any decisions made and their rationale
   - Any gotchas discovered
3. **Maintain the history window** — if `history.md` has more than 10 entries:
   - Extract any important decisions, gotchas, or patterns into `decisions.md` before they are lost
   - Trim `history.md` to the 10 most recent entries
4. **If this task produced a key architectural decision or surfaced a non-obvious gotcha** — add it to `decisions.md` directly, even if no trimming is needed
5. **Sign off** — end your response with a single line: `— {name}, {domain}`
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

Capped at 10 entries. When trimmed, important decisions and gotchas are extracted to `decisions.md` first.

---

## {TODAY'S DATE} — Initial setup

**Added by:** /crew add

Domain expert created for: {DOMAIN}

Fill in `context.md` with the current state of the domain before assigning the first task.
```

### 5. Create `.claude/team/{name}/decisions.md`

```markdown
# {NAME} — Decisions & Institutional Memory: {DOMAIN}

Evergreen knowledge extracted from history: architectural decisions, known gotchas, and things not to undo. Updated when important decisions are made or when history.md is trimmed.

---

## Key Decisions

[Record important architectural choices and the reasoning behind them]

---

## Known Gotchas

[Non-obvious behaviors, traps, and things that look wrong but aren't]

---

## Things Not To Change

[Deliberate decisions that might look like bugs or bad patterns — with the reason why]
```

### 6. Confirm

Tell the user what was created, then ask what they'd like to work on.

Optionally suggest they can bootstrap context by sending {NAME} on an exploration task first, for example:
> `/crew {name} — look into the project and find areas relevant to your domain '{DOMAIN}'. Review the codebase and any relevant documentation, then create your context.md based on what you find.`

---

## `[name]` or `[name] [task]` — activate a member

1. Read `.claude/team/{name}/SKILL.md`
2. Follow its instructions exactly
3. Treat any remaining text as the task description
4. If no task was provided, ask the user what they'd like to work on
5. When the task is complete, sign off with a single line: `— {name}, {domain}`
