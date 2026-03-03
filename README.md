# Crew

![Crew](media/crew.svg)

**Software teams have domain owners. Now your AI team does too.**

---

When I managed software teams, domain ownership was just how things worked. Every developer owned a part of the codebase. Their history with it: the decisions made, the mistakes survived, the patterns that stuck, made them the natural fit for new tasks in that domain. You didn't re-brief them. You just assigned the ticket.

Working with AI, I wanted the same thing. Four goals:

- **Less time, tokens, and effort.** Stop re-explaining context Claude already worked through.
- **Agents that improve after every task.** Each run leaves the next one sharper.
- **No repeated mistakes.** Hard-won lessons stay in the domain, not lost when the session ends.
- **No loops.** Known dead ends are documented, not rediscovered.

Crew is that pattern for Claude. Each domain expert is a set of files: their current knowledge of the domain, a log of every task they've completed, and a permanent record of key decisions and gotchas. Assign them a task, they orient themselves, do the work, and update their own knowledge before they're done.

```
/crew                              → see your full roster + available commands
/crew who                          → see who is currently active
/crew ester                        → activate Ester, she'll ask what the task is
/crew ester add pause/resume       → assign a task directly
/crew add ester "Stagehand replay" → scaffold a new crew member
```

---

## How it works

Each crew member lives in `.claude/team/{name}/`:

```
.claude/team/
├── .current          ← tracks the last activated member (/crew who reads this)
└── ester/
    ├── SKILL.md      ← activates Ester, defines her standards
    ├── context.md    ← current state of the domain (always up to date)
    ├── history.md    ← every task completed, every decision made, PR references
    └── decisions.md  ← permanent record: key decisions, gotchas, things not to undo
```

**The loop: what happens on every `/crew ester [task]`:**

```
1. Read context.md     → understand the current state
2. Read decisions.md   → know what not to undo and why
3. Read history.md     → understand how it got here
4. Do the work
5. Update context.md   → reflect what changed
6. Append to history.md → date, what was done, files changed, PR reference
7. Update decisions.md  → if a key decision was made or a gotcha discovered
```

Context compounds. Ester gets sharper with every task. You never re-brief her.

**history.md is capped at 10 entries.** When trimmed, important signal is extracted to `decisions.md` first, so nothing valuable is lost, just the narrative bulk.

---

## Quick start

### 1. Install the skill

```bash
npx skills add eran-tookii/crew
```

Then reference it from your `CLAUDE.md`:

```markdown
@.claude/skills/crew/SKILL.md
```

### 2. Add your first crew member

```
/crew add ester "Browserbase/Stagehand persona replay"
```

This creates:

```
.claude/team/ester/
├── SKILL.md      ← pre-filled with the two-sided workflow
├── context.md    ← ready for you to fill with current domain state
├── history.md    ← ready for first entry
└── decisions.md  ← ready for key decisions and gotchas
```

### 3. Fill in context.md

Describe the current state of the domain: key files, architecture, patterns, constraints, gotchas. This is Ester's starting knowledge. One focused session to write it, then she maintains it herself.

### 4. Assign your first task

```
/crew ester [your task here]
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/crew` | Show the full roster + available commands |
| `/crew who` | Show the currently active crew member |
| `/crew [name]` | Activate a member, they'll ask for the task |
| `/crew [name] [task]` | Activate a member with a task |
| `/crew add [name] "[domain]"` | Scaffold a new crew member |

---

## The roster

`/crew` with no arguments reads all member folders and presents:
- Who each member is and what domain they own
- What they last worked on (from `history.md`)
- All available commands

As you add members, the roster grows automatically. No configuration needed.

---

## Philosophy

**Context is the asset.** A senior engineer's value isn't just their skills. It's the years of accumulated context about why things are the way they are. Crew externalises that context into files that persist, version, and compound.

**History is the superpower.** `context.md` tells Claude what the domain looks like. `history.md` tells Claude *why*. Without history, Claude might undo a deliberate decision. With it, every task builds on the ones before.

**decisions.md is the permanent record.** History rolls off after 10 entries. The narrative bulk is cheap to lose. The decisions and gotchas are not. `decisions.md` captures that signal permanently, so nothing important is ever trimmed away.

**Living, not static.** The worst outcome is `context.md` drifting from reality. The two-sided workflow (update after every task) is the mechanism that prevents it. Crew members don't just consume context, they maintain it.

**The analogy holds.** When you assign a task to Ester, you don't re-explain the codebase. When Ester finishes, she updates her mental model. That's exactly what this does.

---

## Adding more members

Each domain gets its own crew member. Some examples of how to slice domains:

```
/crew add dana "Authentication and user session management"
/crew add marco "Payment processing and Stripe integration"
/crew add yuki "Data pipeline and analytics"
```

There's no right granularity. The right size is: one person could own this domain end-to-end.

---

## Project structure

```
crew/
├── README.md
└── SKILL.md    ← /crew — roster, routing, scaffolding, and /crew who
```

---

## License

MIT
