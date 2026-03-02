hey — been experimenting with a new workflow for Claude Code and wanted to share before I open source it

**the problem:** every session starts blank. you re-explain the architecture every time. the AI never "owns" anything.

**the idea:** in a real team you assign tasks to the engineer who owns the domain. built something that replicates that.

it's called **Crew** — each domain expert is 3 files in your repo:

```
.claude/team/ester/
├── SKILL.md      ← activates her, defines her standards
├── context.md    ← current state of the domain
└── history.md    ← every task done, every decision, PR references
```

the key is the **two-sided loop** — before every task she reads context + history, after every task she updates both. knowledge compounds instead of drifting.

you use it like:
```
/crew                          → see your full roster
/crew ester                    → activate ester
/crew ester add pause/resume   → assign directly
```

`/crew-add ester "Browserbase replay"` scaffolds the whole thing in one command

still testing on a real project. going open source soon. anyone want early access to try it?
