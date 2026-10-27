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
| `--timeblocks [YYYY-MM-DD] [--json]` | A day's time blocks for glance (default today): tasks with a time and duration, work-calendar `busy` slots (no titles; Tentative and Free are left out), and titled Google calendar `event`s |

Output: `# <filter>`, then one `## task · due · priority` per top-level task, with its subtasks as bullets. In the queue, order matters: earlier means more pressing. `--timeblocks` prints the `# Today YYYY-MM-DD` section of glance's tasks.md (`- HH:MM-HH:MM what` lines, local, by start), or with `--json` `{"day", "blocks": [{"start", "end", "what", "kind"}]}`. Overlapping Busy slots merge into one (`Busy x 2`); any other overlap prints no plan: the clashes go to stderr (exit 1), to fix in Todoist.

Read-only for now: it can't add, complete or set reminders yet.
