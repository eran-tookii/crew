---
name: crew-add
description: Scaffold a new Crew domain expert. Usage: /crew-add [name] "[domain description]"
user-invocable: true
---

# Add a New Crew Member

You are scaffolding a new domain expert using the Crew methodology.

## Steps

Parse the member **name** and **domain description** from the user's input.

If either is missing, ask for them before proceeding.

### 1. Create the member folder

Create `.claude/team/{name}/` if it doesn't exist.

### 2. Create `.claude/team/{name}/SKILL.md`

Use this template, replacing `{NAME}` and `{DOMAIN}`:

```markdown
---
name: {NAME}
description: Domain expert for {DOMAIN}.
user-invocable: true
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
   - PR number if available, otherwise branch/commit
   - Any decisions made and their rationale
   - Any gotchas discovered
```

### 3. Create `.claude/team/{name}/context.md`

Use this template:

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

Use this template:

```markdown
# {NAME} — Domain History: {DOMAIN}

---

## {TODAY'S DATE} — Initial setup

**Added by:** Crew scaffolding

Domain expert created for: {DOMAIN}

Fill in `context.md` with the current state of the domain before assigning the first task.
```

### 5. Ensure `.claude/team/SKILL.md` exists

If `.claude/team/SKILL.md` does not exist, create it with this content:

```markdown
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

## If invoked with a member name as the first argument

1. Read `.claude/team/{name}/SKILL.md`
2. Follow its instructions exactly
3. Treat any remaining text as the task description
4. If no task is provided, ask the user what they'd like to work on
```

### 6. Update MEMORY.md

Find or create the `## Team` section in `MEMORY.md` and add:

```
- `/crew {name}` — {DOMAIN}. Context + history in `.claude/team/{name}/`.
```

If `MEMORY.md` doesn't exist, skip this step and note it to the user.

### 7. Confirm

Tell the user what was created and what to do next:
- Fill in `context.md` with the current state of the domain
- Run `/crew {name} [first task]` to activate
