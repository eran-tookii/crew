# Crew

**Give Claude permanent domain ownership — like assigning a ticket to the engineer who knows the codebase.**

---

## The problem

Every Claude session starts blank. You re-explain the architecture, the decisions, the gotchas. You get good output, but none of it sticks. Next task, same thing.

## The idea

When you have a task in a domain, you don't brief every engineer. You assign it to the person who owns it. They already know the context, the history, the constraints. They just need the task.

Crew gives you that with Claude.

Each domain expert is a set of three files: their current knowledge of the domain, a log of every task they've completed, and a skill that activates them. Assign them a task, they orient themselves, do the work, and update their own knowledge before they're done. Next time, they're sharper.

```
/crew                              → see your full roster
/crew ester                        → activate Ester, she'll ask what the task is
/crew ester add pause/resume       → assign a task directly
```

---

## How it works

Each crew member lives in `.claude/team/{name}/`:

```
.claude/team/
├── SKILL.md          ← /crew meta-skill (auto-discovers all members)
└── ester/
    ├── SKILL.md      ← activates Ester, defines her standards
    ├── context.md    ← current state of the domain (always up to date)
    └── history.md    ← every task completed, every decision made, PR references
```

**The loop — what happens on every `/crew ester [task]`:**

```
1. Read context.md       → understand the current state
2. Read history.md       → understand why it is this way
3. Do the work
4. Update context.md     → reflect what changed
5. Append to history.md  → date, what was done, files changed, PR reference
```

Context compounds. Ester gets sharper with every task. You never re-brief her.

---

## Quick start

### 1. Install the skills

```
/plugin marketplace add your-handle/crew
/plugin install crew@your-handle
/plugin install crew-add@your-handle
```

Or manually copy `skills/crew/` and `skills/crew-add/` into your project's `.claude/skills/`.

### 2. Add your first crew member

```
/crew-add ester "Browserbase/Stagehand persona replay"
```

This creates:
```
.claude/team/ester/
├── SKILL.md      ← pre-filled with the two-sided workflow
├── context.md    ← ready for you to fill with current domain state
└── history.md    ← ready for first entry
```

### 3. Fill in context.md

Describe the current state of the domain: key files, architecture, patterns, constraints, gotchas. This is Ester's starting knowledge. One focused session to write it, then she maintains it herself.

### 4. Assign your first task

```
/crew ester [your task here]
```

---

## The roster

`/crew` with no arguments reads all member folders and presents:
- Who each member is
- What domain they own
- What they last worked on (from history.md)

As you add members, the roster grows automatically. No configuration needed.

---

## Philosophy

**Context is the asset.** A senior engineer's value isn't just their skills — it's the years of accumulated context about why things are the way they are. Crew externalises that context into files that persist, version, and compound.

**History is the superpower.** `context.md` tells Claude what the domain looks like. `history.md` tells Claude *why*. Without history, Claude might undo a deliberate decision. With it, every task builds on the ones before.

**Living, not static.** The worst outcome is context.md drifting from reality. The two-sided workflow (update after every task) is the mechanism that prevents it. Crew members don't just consume context — they maintain it.

**The analogy holds.** When you assign a task to Ester, you don't re-explain the codebase. When Ester finishes, she updates her mental model. That's exactly what this does.

---

## Adding more members

Each domain gets its own crew member. Some examples of how to slice domains:

```
/crew-add dana "Authentication and user session management"
/crew-add marco "Payment processing and Stripe integration"
/crew-add yuki "Data pipeline and analytics"
```

There's no right granularity. The right size is: one person could own this domain end-to-end.

---

## Project structure

```
crew/
├── README.md
├── .claude-plugin/
│   └── marketplace.json
└── skills/
    ├── crew/
    │   └── SKILL.md       ← /crew — roster + routing
    └── crew-add/
        └── SKILL.md       ← /crew-add — scaffold a new member
```

---

## License

MIT
