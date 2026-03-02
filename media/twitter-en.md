Every Claude session starts blank. You re-explain the architecture, the patterns, the decisions. Great output. Nothing sticks. Next session, same thing.

In a real team you don't re-brief everyone. You assign to the person who owns the domain.

I built Crew — domain agents for Claude Code that hold context, learn from every task, and compound over time.

Each member is 3 files in your repo:
- `context.md` — current state of the domain
- `history.md` — every task, every decision, every PR
- `SKILL.md` — what activates them

The loop:
→ before every task: read context + history
→ do the work
→ update both files

```
/crew ester add pause/resume to replay
```

Ester knows the codebase, the decisions, what was done last week. You just assign the task.

Still validating on a real project. Open sourcing soon.

Who's building with Claude Code and wants to try it first?

github.com/eran-tookii/crew
