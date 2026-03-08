# Crew

![Crew](media/crew.svg)

**Software teams have domain owners. Now your AI team does too.**

---

In software teams, domain ownership is how things work. Every developer owns a part of the codebase. Their history with it — the decisions made, the mistakes survived, the patterns that stuck — makes them the natural fit for new tasks in that domain. You don't re-brief them. You just assign the ticket.

Crew brings the same pattern to AI. Four goals:

- **Less time, tokens, and effort.** Stop re-explaining context Claude already worked through.
- **Agents that improve after every task.** Each run leaves the next one sharper.
- **No repeated mistakes.** Hard-won lessons stay in the domain, not lost when the session ends.
- **No loops.** Known dead ends are documented, not rediscovered.

Crew is that pattern for Claude. Each domain expert is a set of files: their current knowledge of the domain, a log of every task they've completed, and a permanent record of key decisions and gotchas. Assign them a task, they orient themselves, do the work, and update their own knowledge before they're done.

---

## Philosophy

**Context is the asset.** A senior engineer's value isn't just their skills. It's the years of accumulated context about why things are the way they are. Crew externalises that context into files that persist, version, and compound.

**History is the superpower.** `context.md` tells Claude what the domain looks like. `history.md` tells Claude *why*. Without history, Claude might undo a deliberate decision. With it, every task builds on the ones before.

**decisions.md is the permanent record.** History rolls off after 10 entries. The narrative bulk is cheap to lose. The decisions and gotchas are not. `decisions.md` captures that signal permanently, so nothing important is ever trimmed away.

**Living, not static.** The worst outcome is `context.md` drifting from reality. The two-sided workflow (update after every task) is the mechanism that prevents it. Crew members don't just consume context, they maintain it.

**The analogy holds.** When you assign a task to Ester, you don't re-explain the codebase. When Ester finishes, she updates her mental model. That's exactly what this does.

**Just markdown.** Crew is a single skill file and a set of plain text files per member. No scripts, no background processes, no build steps, no dependencies. Everything is readable, editable, and version-controlled. You can open any file, see exactly what your crew member knows, and change it by hand. The entire system is transparent by design.

---

## How it works

Each crew member lives in `.claude/crew/{name}/`:

```
.claude/crew/
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

**Via Claude Code plugin marketplace:**

```
/plugin marketplace add eran-tookii/crew
/plugin install crew@crew
```

**Via skills.sh:**

```bash
npx skills add eran-tookii/crew
```

### 2. Add your first crew member

```
/crew add ester "Browserbase/Stagehand persona replay"
```

This creates:

```
.claude/crew/ester/
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
| `/crew add [name] "[domain]"` | Scaffold a new crew member |
| `/crew [name]` | Activate a member, they'll ask for the task |
| `/crew [name] [task]` | Activate a member with a task |
| `/crew 1-on-1 [name]` | Interactive check-in with a member |
| `/crew done [name]` | Close session, update context & history |
| `/crew remove [name]` | Remove a member and all their files |

---

## The roster

`/crew` with no arguments reads all member folders and presents:
- Who each member is and what domain they own
- What they last worked on (from `history.md`)
- All available commands

As you add members, the roster grows automatically. No configuration needed.

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
├── .claude-plugin/
│   ├── marketplace.json   ← Claude Code marketplace catalog
│   └── plugin.json        ← plugin manifest
└── skills/
    └── crew/
        └── SKILL.md       ← /crew skill
```

---

## FAQ

**Won't context.md grow forever and blow up the context window?**
No. Context.md is meant to reflect the *current* state of the domain, not a running log. Each crew member rewrites it after every task, keeping only what's relevant now. Old details are naturally replaced as the domain evolves. If it starts getting long, just trim it yourself — it's plain markdown.

**What happens when history.md fills up?**
History is capped at 10 entries. When it's trimmed, important signal (key decisions, gotchas, patterns) is extracted to `decisions.md` first. The narrative bulk is discarded, but nothing valuable is lost.

**How many crew members should I have?**
As many as you have distinct domains. A good rule of thumb: if you'd assign it to a different person on a real team, it's a different crew member. Most projects land somewhere between 2 and 6.

**Can I edit context.md, history.md, or decisions.md by hand?**
Yes, and you should. These are plain markdown files. If a crew member wrote something wrong, fix it. If context has drifted, update it. The files are the source of truth — there's no hidden state.

**Does this persist across conversations?**
Yes. Crew member files live in `.claude/crew/` inside your project. They survive across conversations, branches, and machines (if you commit them). That's the whole point — context that outlasts a single session.

**Does this use extra tokens?**
A crew member reads their context, history, and decisions files at the start of each task. That's the overhead — typically a few hundred lines of markdown. It's far less than re-explaining the domain from scratch every time, which is what you'd do without it.

**Can two crew members work on the same task?**
They can, but it's not the intended pattern. Each member owns a domain. If a task spans domains, assign the part that fits each member's expertise separately. They don't share context with each other — they share context with *you*.

---

## License

MIT
