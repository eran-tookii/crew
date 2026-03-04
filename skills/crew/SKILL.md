---
name: crew
description: Manage your AI team. /crew = roster, /crew add [name] "[domain]" = new member, /crew 1-on-1 [name] = check-in, /crew [name] [task] = assign task.
metadata:
  compatibility: Claude Code
---

# Crew

## Routing — read the arguments first

| Arguments | Action |
|-----------|--------|
| none | Show roster |
| `add [name] "[domain]"` | Scaffold a new crew member |
| `1-on-1 [name]` | Interactive 1-on-1 with a member |
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
   - `/crew 1-on-1 [name]` — interactive check-in with a member
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
2. Read `.claude/team/{name}/decisions.md` — key architectural decisions, gotchas, things not to undo. **Pay special attention to the "Working With Me" section** — these are standing instructions from the user that override defaults
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

---

## Working With Me

User preferences for how this member should work. These are standing instructions — follow them on every task. Added during 1-on-1s based on direct user feedback.

[e.g., "Always plan before executing", "Only reference docs in /docs, not external sources", "Keep PRs small — one concern per PR"]
```

### 6. Confirm

Tell the user what was created, then ask what they'd like to work on.

Optionally suggest they can bootstrap context by sending {NAME} on an exploration task first, for example:
> `/crew {name} — look into the project and find areas relevant to your domain '{DOMAIN}'. Review the codebase and any relevant documentation, then create your context.md based on what you find.`

---

## `1-on-1 [name]` — interactive check-in

If name is missing, ask for it before proceeding. Verify `.claude/team/{name}/SKILL.md` exists; if not, stop and suggest `/crew add`.

### Setup

1. Read `.claude/team/{name}/SKILL.md` — extract `name` and `description` from frontmatter
2. Read `.claude/team/{name}/context.md`
3. Read `.claude/team/{name}/decisions.md`
4. Read `.claude/team/{name}/history.md`
5. Read `.claude/team/{name}/1-on-1s.md` if it exists — review previous check-in notes

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
| **history.md window** | Count entries. If at 10, note that the next task will trigger a trim — ask if anything should be extracted to decisions.md first. If well under 10, note the headroom. |
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

2. **Create `.claude/team/{name}/1-on-1s.md` if it does not exist** using this template:

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

## `[name]` or `[name] [task]` — activate a member

1. Read `.claude/team/{name}/SKILL.md`
2. Follow its instructions exactly
3. Treat any remaining text as the task description
4. If no task was provided, ask the user what they'd like to work on
5. When the task is complete, sign off with a single line: `— {name}, {domain}`
