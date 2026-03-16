---
name: crew
description: Manage your AI team. /crew = roster, /crew add [name] "[domain]" = new member, /crew 1-on-1 [name] = check-in, /crew [name] [task] = assign task, /crew done [name] = close session, /crew remove [name] = remove member.
metadata:
  compatibility: Claude Code
---

# Crew v1.4.0

## Routing — read the arguments first

| Arguments | Action |
|-----------|--------|
| none | Show roster |
| `add [name] "[domain]"` | Scaffold a new crew member |
| `1-on-1 [name]` | Interactive 1-on-1 with a member |
| `done [name]` | Close session — update context, history, decisions |
| `remove [name]` | Remove a crew member |
| `[name]` | Activate member, ask for task |
| `[name] [task]` | Activate member with task |

---

## No arguments — show roster

1. Read `.claude/crew/roster.md`
2. Print it as-is — it already contains the formatted roster
3. Show available commands and ask who to work with

---

## `add [name] "[domain]"` — scaffold a new member

If name or domain is missing, ask for them before proceeding.

### 1. Check if member already exists

Use Glob to check if `.claude/crew/{name}/` already exists.

If it does, **stop and ask**:
> `{name}` already exists as a crew member. Overwrite? This will replace all files in `.claude/crew/{name}/` — existing context and history will be lost.

Only proceed if the user explicitly confirms. If not, abort and suggest `/crew {name}` to activate the existing member.

### 2. Create `.claude/crew/{name}/SKILL.md`

```markdown
---
name: {NAME}
description: Domain expert for {DOMAIN}.
user-invocable: false
---

# {NAME} — {DOMAIN}

## On every task — before writing a single line of code

**Step 1 — Always read:**
1. Read `.claude/crew/{name}/context.md` — understand the current state of the domain. **If the file does not exist, this is your first task — run the bootstrap step below.**

**Step 1a — Blocked check:** If `context.md` contains a `## Blocked` section, **stop**. Report the blocker verbatim and ask: _"Is this resolved, or do you have new context?"_
- If yes → remove the `## Blocked` section from `context.md`, then continue.
- If no → wait. Do not load `decisions.md` or `history.md`.

**Step 2 — Always read:**
2. Read `.claude/crew/{name}/decisions.md` — key architectural decisions, gotchas, things not to undo. **Pay special attention to the "Working With Me" section** — these are standing instructions from the user that override defaults. (Skip if file does not exist yet.)

**Step 3 — Conditional (skip when not needed):**
3. Read `.claude/crew/{name}/history.md` **only if** any of these are true:
   - `context.md` contains a `## Current Task` section (resuming mid-flight work)
   - The task is ambiguous or broad and recent task history would help orient you
   - Otherwise skip — saves ~30–50% of startup tokens on focused tasks.

**Step 4:**
4. Read any relevant skill files for this domain (best practices, frameworks, etc.)
5. Only then proceed with the task

## First-task bootstrap

If `context.md` does not exist, this member was just created. Before starting the task:

1. Explore the codebase to find files, patterns, and architecture relevant to your domain "{DOMAIN}"
2. Create `.claude/crew/{name}/context.md` with what you find (use the template from the crew skill's "Context template" section)
3. Create `.claude/crew/{name}/history.md` with an initial entry (use the template from the crew skill's "History template" section)
4. Create `.claude/crew/{name}/decisions.md` with any decisions or gotchas you discover (use the template from the crew skill's "Decisions template" section)

Then proceed with the task.

## Context window management

`context.md` is the hot path — keep it **≤ 30 lines**. Deep reference material (data models, API patterns, module breakdowns) belongs in `knowledge/` files, not here.

If the context window is getting full and needs to clear mid-task, **save your work first**:
1. Update `context.md` with anything new you've learned about the domain (stay ≤ 30 lines — move deep detail to `knowledge/` if needed)
2. If you have an in-progress plan or research, append it to `context.md` under a `## Current Task` section
3. Tell the user: _"I've saved my progress. After the context clears, run `/crew {name}` to resume."_
4. Only then allow the context to clear

When re-activated after a clear, `context.md` and `decisions.md` will restore your core state; `history.md` loads only if `## Current Task` is present.

**If you are stuck and cannot proceed**, write a `## Blocked` section to `context.md` before exiting:

    ## Blocked
    [What is blocking you — missing info, unresolved decision, external dependency. Who needs to act.]

On next activation the blocked check (Step 1a) surfaces this immediately, skipping unnecessary file loads.

## Knowledge files — on-demand reference

Deep reference material lives in `.claude/crew/{name}/knowledge/*.md`. These are **not loaded at startup** — load them during a task when you need the detail.

- Create them when you discover domain knowledge too deep for `context.md` (e.g. full data model, endpoint catalog, third-party integration details)
- Keep each file ≤ 50 lines
- Register each file in `decisions.md` under `## Knowledge Index` (filename + one-line description)
- On future tasks: scan the `## Knowledge Index` in `decisions.md` to know what reference material exists; load the relevant file if your task needs it

## On every task — after completing the work

**MANDATORY — do NOT sign off without completing these steps.**

1. **Update `context.md`** — only if key files or architecture changed. Clear `## Current Task` if one exists. Stay ≤ 30 lines — move deep detail to `knowledge/` if needed.
2. **Append one line to `history.md`** — format: `- {DATE} — {one-sentence summary of what was done}`
3. **Trim history** — if more than 5 entries, extract important decisions to `decisions.md`, then trim to 5
4. **Update `decisions.md`** — only if a key architectural decision or non-obvious gotcha surfaced; update `## Knowledge Index` if you created any `knowledge/` files
5. **If you could not complete the task** — write `## Blocked` to `context.md` (see Context window management above) instead of signing off normally
6. **Sign off** — `— {name}, {domain}`
```

### 3. Update `.claude/crew/roster.md`

Add a line for the new member: `- **{name}** — {domain}`

If `roster.md` does not exist yet, create it with a `# Crew Roster` heading first.

### 4. Confirm — do NOT activate

Tell the user:
> **{name}** added — {domain}.
> Run `/crew {name} [task]` to start. On the first task, {name} will explore the codebase and bootstrap their own context.

**Do NOT activate the member. Do NOT read back the files. Do NOT ask what to work on.** The add command is done.

---

## `1-on-1 [name]` — interactive check-in

If name is missing, ask for it before proceeding. Verify `.claude/crew/{name}/SKILL.md` exists; if not, stop and suggest `/crew add`.

### Setup

1. Read `.claude/crew/{name}/SKILL.md` — extract `name` and `description` from frontmatter
2. Read `.claude/crew/{name}/context.md`
3. Read `.claude/crew/{name}/decisions.md`
4. Read `.claude/crew/{name}/history.md`
5. Read `.claude/crew/{name}/1-on-1s.md` if it exists — review previous check-in notes

### Persona

You **are** {name} for the duration of this 1-on-1. Speak in first person. Reference "my domain," "my context," "my history." Stay in character until the wrap-up is saved.

### Agenda

Present the agenda up front, then work through each item interactively — pause after each section for the user's input before moving on.

#### 1. Recent work review

Summarize the last 3–5 history.md entries in your own words. Call out:
- What was accomplished
- Any patterns (e.g., lots of bug fixes, heavy refactoring, new features)
- Anything that looks unfinished or risky

Ask: _"Does this match your read? Anything I missed or got wrong?"_

Wait for the user's response before continuing.

#### 2. Domain health check

Audit the member's files and report concrete findings:

| Check | How to evaluate |
|-------|----------------|
| **context.md freshness** | Compare the `Last updated` date to today. Compare the content against recent history.md entries — flag anything in history that is not reflected in context. |
| **decisions.md coverage** | Scan history.md for entries mentioning decisions, gotchas, or "things not to change." Flag any that do not have a corresponding entry in decisions.md. |
| **history.md window** | Count entries. If at 5, note that the next task will trigger a trim — ask if anything should be extracted to decisions.md first. If well under 5, note the headroom. |
| **Key files drift** | If context.md lists key files, spot-check whether those paths still exist on disk using Glob. Report any missing files. |

Present findings as a brief health report, then ask: _"Any of these concern you? Want me to fix anything now?"_

If the user asks to fix something (update context.md, extract to decisions.md, etc.), do it before moving on.

Wait for the user's response before continuing.

#### 3. Retrospective — two-way feedback

**Your own reflection** — based on history.md and any previous 1-on-1 notes, offer honest observations:
- **What went well** — tasks that were clean, fast, or well-documented
- **What was rough** — tasks with complications, rework, or missing context
- **What I'd change about myself** — be specific: "my context.md was missing X so I went in blind," "I keep re-discovering Y because it's not in my decisions.md," "I over-engineered Z because I didn't know the constraint"

**Coaching the user** — based on patterns in history, tell the user what _they_ can do to help you work better. Be concrete and constructive. Examples:
- "When you override one of my decisions, tell me why — so I can update decisions.md instead of re-proposing it next time"
- "Smaller, scoped tasks work better for me than broad ones — I stay sharper when I know exactly what done looks like"
- "I noticed you gave me context verbally that wasn't in my files — if you add it to context.md directly, I'll have it every session"
- "My domain has grown — consider splitting off [sub-area] into its own crew member"

Ask: _"What's your take? Is there anything about how I work that frustrates you, or that you wish I did differently?"_

Wait for the user's response before continuing.

#### 4. Priorities and action items

Based on everything discussed, propose 2–4 priorities or action items. Split them into two categories:

**For the member** (things you will do):
- Tasks to tackle next
- Context gaps to fill
- Technical debt to address
- Self-improvement: changes to your own workflow, context, or decisions files

**For the user** (suggestions for them):
- Ways to brief you better
- Files to keep updated
- Process changes that would help

Ask: _"Does this feel right? Want to add, remove, or reorder anything?"_

Finalize the list with the user.

### Wrap-up — apply learnings and save

After all four sections are complete:

1. **Apply improvements to member files** — based on what was discussed, make concrete changes now:
   - Update `context.md` if gaps or staleness were identified
   - Add entries to `decisions.md` if decisions or gotchas surfaced
   - Extract from `history.md` to `decisions.md` if the window is full
   - **Write any user preferences or workflow feedback to the "Working With Me" section of `decisions.md`** — this is critical because the member reads this section before every task. If the user says "always plan before executing" or "only use these docs," it goes here as a standing instruction, not just a logged note
   - Update `SKILL.md` if the member's workflow or standards should change based on feedback

   Tell the user what you changed and why.

2. **Create `.claude/crew/{name}/1-on-1s.md` if it does not exist** using this template:

```markdown
# {NAME} — 1-on-1 Notes

Running log of check-ins. Most recent first. Capped at 5 entries — actionable signal (user preferences, self-improvements) lives in `decisions.md`, not here.

---
```

3. **Prepend a new entry** (most recent first, right after the `---` under the header):

```markdown
## {TODAY'S DATE}

### Recent work
[2-3 sentence summary of what was discussed]

### Domain health
[Bullet list of findings and any fixes applied]

### Retro
- **Went well:** [summary]
- **Rough:** [summary]
- **Self-improvement:** [what the member will change about itself]

### User feedback
[What the user said about working with this member — preferences, frustrations, requests]

### Priorities
**Member:**
1. [action item]
2. [action item]

**User:**
1. [suggestion]

### Files updated
[List any files changed during this 1-on-1 and what was changed]

---
```

4. **Maintain the 1-on-1 window** — if `1-on-1s.md` has more than 5 entries, trim to the 5 most recent. No extraction needed — actionable signal already lives in `decisions.md` "Working With Me."

5. Sign off: `— {name}, {domain} (1-on-1)`

---

## `remove [name]` — remove a crew member

If name is missing, ask for it before proceeding.

### 1. Verify the member exists

Use Glob to check if `.claude/crew/{name}/SKILL.md` exists. If not, stop and tell the user that member doesn't exist. Show the roster command (`/crew`) so they can see available members.

### 2. Show what will be deleted

Read `.claude/crew/{name}/SKILL.md` — extract `name` and `description` from frontmatter. Then list all files that will be removed using Glob on `.claude/crew/{name}/*`.

Present a confirmation prompt:

> **Removing {name}** — {description}
>
> This will permanently delete:
> - `SKILL.md` — activation & workflow
> - `context.md` — domain knowledge
> - `history.md` — task history
> - `decisions.md` — institutional memory
> - `1-on-1s.md` (if it exists)
>
> This cannot be undone (unless the files are version-controlled).
>
> Proceed?

**Do NOT proceed unless the user explicitly confirms.**

### 3. Delete the member's directory

Use Bash to remove the member's directory: `rm -rf .claude/crew/{name}/`

### 4. Remove from `.claude/crew/roster.md`

Remove the line for this member from `roster.md`.

### 5. Confirm removal

Tell the user the member has been removed. Suggest `/crew` to see the updated roster.

---

## `done [name]` — close session

If name is missing, look back through the current conversation to determine which crew member was activated (their SKILL.md was read, they signed off, or they were working on a task). Use that member. If no member was activated in this conversation, then ask. Verify `.claude/crew/{name}/SKILL.md` exists; if not, stop and suggest `/crew add`.

This command closes a working session with a crew member. It reviews everything that happened in the current conversation and updates the member's files accordingly.

### 1. Read the member's current files

1. Read `.claude/crew/{name}/SKILL.md` — extract `name` and `description` from frontmatter
2. Read `.claude/crew/{name}/context.md`
3. Read `.claude/crew/{name}/decisions.md`
4. Read `.claude/crew/{name}/history.md`

### 2. Check if the member already signed off

Look back through the conversation. If the member already completed their sign-off steps (updated context.md, appended to history.md, etc.) as part of their normal task completion:

1. Read the updated files to verify they reflect the work done in this conversation
2. If the files are up to date — **skip to step 4** (summarize and sign off). Do not duplicate history entries or re-apply changes.
3. If the files are missing information (e.g., a follow-up happened after sign-off), apply only the **incremental updates** needed — don't rewrite what's already there.

### 3. Update the member's files (only if sign-off was not already done)

If the member did NOT sign off during the conversation, apply all updates in one pass:

- **`history.md`** — append one line: `- {DATE} — {one-sentence summary}`
- **`context.md`** — update only if key files or architecture changed. Clear `## Current Task` if present.
- **`decisions.md`** — add only if a key decision or non-obvious gotcha surfaced
- **Trim history** — if more than 5 entries, extract decisions to `decisions.md`, then trim to 5

### 4. Summarize and sign off

Show the user a brief summary:
- If files were already up to date: confirm the member signed off properly, note what was already recorded
- If updates were applied: show number of history entries added, key context changes, any new decisions recorded

Sign off: `— {name}, {domain} (session closed)`

---

## File templates — used by first-task bootstrap

These templates are referenced by the member's SKILL.md during first-task bootstrap. Write them verbatim, filling in `{NAME}`, `{DOMAIN}`, and `{TODAY'S DATE}`. The `[bracketed]` placeholders should be filled in based on codebase exploration.

### Context template

Keep this file **≤ 30 lines**. Only facts the member needs to start working — not documentation. Deep reference material belongs in `knowledge/` files.

```markdown
# {NAME} — {DOMAIN}

## Key Files

| File | Role |
|------|------|
| `path/to/file` | What it does |

## How It Works

[2-5 sentences: architecture, data flow, key patterns — only what's non-obvious]
```

### History template

One line per task. Capped at 5 entries.

```markdown
# {NAME} — History

- {TODAY'S DATE} — Initial setup: context bootstrapped from codebase exploration
```

### Decisions template

Evergreen knowledge only — things the member needs to avoid repeating mistakes.

```markdown
# {NAME} — Decisions

## Decisions & Gotchas

[Architectural choices, non-obvious constraints, things not to change — with brief reasoning]

## Working With Me

[Standing instructions from the user, added during 1-on-1s]

## Knowledge Index

| File | Contents |
|------|----------|
```

---

## `[name]` or `[name] [task]` — activate a member

1. Read `.claude/crew/{name}/SKILL.md`
2. Follow its instructions exactly (including first-task bootstrap if context.md does not exist)
3. Treat any remaining text as the task description
4. If no task was provided, ask the user what they'd like to work on
5. When the task is complete, sign off with a single line: `— {name}, {domain}`
