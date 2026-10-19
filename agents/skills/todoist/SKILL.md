---
name: todoist
description: Fetch the owner's Todoist tasks for a filter, as Markdown (read-only). Use for today's plan (the queue), planning the day, or prioritising.
---

# todoist

`python "$HOME/.claude/skills/todoist/todoist.py" [filter] [--query "..."]` · needs `TODOIST_TOKEN`

| Filter | What |
|---|---|
| `queue` (default) | Overdue (not Backlog), then today's timed tasks already due, today's untimed, today's still to come |
| `--query "today & p1"` | Any Todoist filter, ad hoc |

Output: `# <filter>`, then one `## task · due · priority` per top-level task, with its subtasks as bullets. In the queue, order matters: earlier means more pressing.

Read-only for now: it can't add, complete or set reminders yet.
