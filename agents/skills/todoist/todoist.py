"""todoist: print the owner's Todoist tasks for a filter, as Markdown.

Each top-level task is a `##` heading, with its subtasks as bullets under it. The API rejects
a filter with commas, so each comma-separated part runs on its own, in order, and a task shown
by an earlier part isn't repeated.

`--timeblocks [day]` prints that day's time blocks as the `# Today` section of glance's tasks.md
(or JSON with `--json`): tasks with a time and a duration, the work calendar's Busy slots, and
titled calendar events. Blocks that overlap are refused, as glance refuses them.

Reads only; needs TODOIST_TOKEN.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from collections.abc import Iterable
from dataclasses import dataclass
from datetime import UTC, date, datetime, time, timedelta
from itertools import combinations
from typing import Any

FILTERS = {
    "queue": (
        "!#Backlog & overdue, today & !no time & date before: +0 minutes, today & no time, "
        "today &!no time & date after: +0 minutes"
    ),
}
API = "https://api.todoist.com/api/v1"
PRIORITY = {4: "p1", 3: "p2", 2: "p3"}  # the API counts up to 4 = p1; p4 (1) isn't shown
# The work calendar reaches Todoist titled only Busy, Tentative or Free. Only Busy blocks the
# day; the owner plans over the other two. Any other title is an "event".
HIDDEN_EVENTS = {"Tentative", "Free"}
# Google's copy of my Todoist tasks: the tasks themselves are already in. The real one isn't
# flagged `is_task_calendar`, so it's known by name too.
TASK_CALENDAR = "Todoist"


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="todoist", description=__doc__)
    parser.add_argument("filter", nargs="?", default="queue", choices=FILTERS, help="saved filter")
    parser.add_argument("--query", help="an ad-hoc Todoist filter instead of a saved one")
    parser.add_argument(
        "--timeblocks",
        nargs="?",
        const=datetime.now(UTC).astimezone().date(),
        type=date.fromisoformat,
        metavar="YYYY-MM-DD",
        help="a day's time blocks as glance's # Today section (default today)",
    )
    parser.add_argument("--json", action="store_true", help="with --timeblocks: JSON instead")
    return parser


# ---- Tasks ---------------------------------------------------------------------------------


@dataclass(frozen=True)
class Task:
    id: str
    content: str
    parent_id: str | None
    order: int
    priority: int
    due: str  # "2026-10-18", "2026-10-18T14:00:00" (local) or "...Z" (fixed zone); "" if none


def parse_task(raw: dict[str, Any]) -> Task:
    due = raw["due"]["date"] if raw.get("due") else ""
    return Task(
        raw["id"], raw["content"], raw["parent_id"], raw["child_order"], raw["priority"], due
    )


def split_query(query: str) -> list[str]:
    return [part.strip() for part in query.split(",") if part.strip()]


def when(due: str) -> str:
    if "T" not in due:
        return date.fromisoformat(due).strftime("%a %d %b") if due else ""
    moment = datetime.fromisoformat(due)
    return (moment.astimezone() if moment.tzinfo else moment).strftime("%a %d %b %H:%M")


# ---- Markdown ------------------------------------------------------------------------------


def render(title: str, parts: Iterable[list[Task]], everything: list[Task]) -> str:
    by_id = {task.id: task for task in everything}
    children: dict[str, list[Task]] = {}
    for task in sorted(everything, key=lambda t: t.order):
        if task.parent_id:
            children.setdefault(task.parent_id, []).append(task)
    shown = [task for part in parts for task in sorted(part, key=lambda t: (t.due, -t.priority))]
    ids = {task.id for task in shown}
    lines = [f"# {title}", f"as of {datetime.now(UTC).astimezone():%a %d %b %H:%M}"]
    seen: set[str] = set()
    for task in shown:
        if task.id in seen or has_ancestor_in(task, ids, by_id):
            continue
        seen.add(task.id)
        lines += ["", heading(task), *bullets(task.id, children, depth=0)]
    return "\n".join(lines if seen else [*lines, "", "Nothing."]) + "\n"


def has_ancestor_in(task: Task, ids: set[str], by_id: dict[str, Task]) -> bool:
    """A subtask whose parent is also listed shows under its parent, not on its own."""
    parent = by_id.get(task.parent_id or "")
    while parent:
        if parent.id in ids:
            return True
        parent = by_id.get(parent.parent_id or "")
    return False


def heading(task: Task) -> str:
    extras = [part for part in (when(task.due), PRIORITY.get(task.priority, "")) if part]
    return " · ".join([f"## {task.content}", *extras])


def bullets(parent_id: str, children: dict[str, list[Task]], depth: int) -> list[str]:
    lines: list[str] = []
    for child in children.get(parent_id, []):
        lines += [f"{'  ' * depth}- {child.content}", *bullets(child.id, children, depth + 1)]
    return lines


# ---- Time blocks ---------------------------------------------------------------------------


@dataclass(frozen=True)
class TimeBlock:
    start: datetime  # local
    end: datetime
    what: str
    kind: str  # "task", "busy" or "event"


def task_block(raw: dict[str, Any]) -> TimeBlock | None:
    """Only a task with a time of day and a duration in minutes takes up time on the day."""
    due, duration = raw.get("due"), raw.get("duration")
    if not due or "T" not in due["date"] or not duration or duration["unit"] != "minute":
        return None
    start = local(due["date"])
    return TimeBlock(start, start + timedelta(minutes=duration["amount"]), raw["content"], "task")


def event_block(raw: dict[str, Any]) -> TimeBlock | None:
    what, start, end = raw["summary"], raw["start"]["date_time"], raw["end"]["date_time"]
    if what in HIDDEN_EVENTS or not start:  # an all-day event has a date, not a time
        return None
    return TimeBlock(local(start), local(end), what, "busy" if what == "Busy" else "event")


def local(moment: str) -> datetime:
    """Todoist's floating times are already local; the rest carry their zone."""
    return datetime.fromisoformat(moment).astimezone()


def plan(day: date, blocks: Iterable[TimeBlock | None]) -> dict[str, Any]:
    """Like glance's Plan: the day's blocks by start, in local `HH:MM`. One from the day before is
    left out and one past midnight ends at 23:59, as glance's do."""
    on_day = [block for block in blocks if block and block.start.date() == day]
    in_order = sorted(merge_busy(on_day), key=lambda block: (block.start, block.end))
    return {"day": day.isoformat(), "blocks": [shape(block, day) for block in in_order]}


def merge_busy(blocks: list[TimeBlock]) -> list[TimeBlock]:
    """The work calendar double-books, and busy is busy: overlapping Busy slots become one,
    `Busy x 2`. Touching ones don't overlap, as glance counts it, so they stay apart."""
    groups: list[list[TimeBlock]] = []
    for block in sorted((block for block in blocks if block.kind == "busy"), key=lambda b: b.start):
        if groups and block.start < max(other.end for other in groups[-1]):
            groups[-1].append(block)
        else:
            groups.append([block])
    busy = [
        TimeBlock(group[0].start, max(b.end for b in group), busy_title(len(group)), "busy")
        for group in groups
    ]
    return [*(block for block in blocks if block.kind != "busy"), *busy]


def busy_title(slots: int) -> str:
    return "Busy" if slots == 1 else f"Busy x {slots}"


def shape(block: TimeBlock, day: date) -> dict[str, str]:
    end = f"{block.end:%H:%M}" if block.end.date() == day else "23:59"
    what = " ".join(block.what.split())  # one line in tasks.md, spaced as glance reads it
    return {"start": f"{block.start:%H:%M}", "end": end, "what": what, "kind": block.kind}


def timeline(day_plan: dict[str, Any], as_json: bool) -> str:
    """glance's `# Today` section, or the plan as JSON. Overlapping blocks print no plan: glance
    would refuse it, so they're fixed in Todoist first."""
    clashing = clashes(day_plan["blocks"])
    if clashing:
        raise SystemExit("\n".join(["These blocks overlap: fix them in Todoist.", *clashing]))
    if as_json:
        return json.dumps(day_plan, ensure_ascii=False, indent=2) + "\n"
    lines = [f"- {line(block)}" for block in day_plan["blocks"]]
    return "\n".join([f"# Today {day_plan['day']}", *lines]) + "\n"


def clashes(blocks: list[dict[str, str]]) -> list[str]:
    """As glance counts it: one ending as the next starts doesn't overlap. `HH:MM` sorts as text."""
    pairs = combinations(blocks, 2)
    return [
        f"{line(one)}  overlaps  {line(other)}"
        for one, other in pairs
        if one["start"] < other["end"] and other["start"] < one["end"]
    ]


def line(block: dict[str, str]) -> str:
    """`14:00-15:30 PR reviews`, as tasks.md has it."""
    return f"{block['start']}-{block['end']} {block['what']}"


# ---- The API -------------------------------------------------------------------------------


def fetch(token: str, path: str, params: dict[str, str]) -> list[Task]:
    return [parse_task(raw) for raw in pages(token, path, params)]


def pages(token: str, path: str, params: dict[str, str], key: str = "results") -> list[Any]:
    """Every page of a listing."""
    found: list[Any] = []
    cursor = ""
    while True:
        query = {**params, "limit": "200"}
        if cursor:
            query["cursor"] = cursor
        page = get(token, f"{API}{path}?{urllib.parse.urlencode(query)}")
        found += page[key]
        cursor = page.get("next_cursor") or ""
        if not cursor:
            return found


def day_blocks(token: str, day: date) -> list[TimeBlock | None]:
    """The calendar endpoints aren't in Todoist's API docs: they're what its own apps use. If
    they break, read Google Calendar directly: Todoist gets them from there, Outlook's feed too."""
    tasks = pages(token, "/tasks/filter", {"query": day.isoformat()})
    span = {"start_datetime": midnight(day), "end_datetime": midnight(day + timedelta(days=1))}
    events = [
        event
        for calendar in calendar_ids(token)
        for event in pages(token, "/calendar/events", {**span, "calendar_id": calendar}, "events")
    ]
    return [*map(task_block, tasks), *map(event_block, events)]


def calendar_ids(token: str) -> list[str]:
    ids: list[str] = []
    for account in get(token, f"{API}/calendar/accounts")["accounts"]:
        path = f"{API}/calendar/accounts/{account['id']}/calendars"
        ids += [calendar["id"] for calendar in get(token, path)["calendars"] if shown(calendar)]
    return ids


def shown(calendar: dict[str, Any]) -> bool:
    tasks = calendar["is_task_calendar"] or calendar["summary"] == TASK_CALENDAR
    return bool(calendar["is_visible"]) and not tasks


def midnight(day: date) -> str:
    """The start of a local day, in UTC, as the calendar endpoint wants it."""
    return f"{datetime.combine(day, time()).astimezone(UTC):%Y-%m-%dT%H:%M:%SZ}"


def get(token: str, url: str) -> dict[str, Any]:
    request = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            page: dict[str, Any] = json.load(response)
    except urllib.error.HTTPError as error:
        detail = error.read().decode("utf-8", errors="replace")[:200]
        raise SystemExit(f"Todoist said {error.code}: {detail}") from error
    return page


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    token = os.environ.get("TODOIST_TOKEN")
    if not token:
        raise SystemExit("set TODOIST_TOKEN to your Todoist API token")
    if args.timeblocks:
        text = timeline(plan(args.timeblocks, day_blocks(token, args.timeblocks)), args.json)
    else:  # --json has no Markdown counterpart here, so it's ignored
        text = markdown(token, args.filter, args.query)
    sys.stdout.buffer.write(text.encode("utf-8"))  # Windows pipes default to cp1252: emoji
    return 0


def markdown(token: str, saved: str, query: str | None) -> str:
    title = "Tasks" if query else saved.capitalize()
    parts = [
        fetch(token, "/tasks/filter", {"query": part})
        for part in split_query(query or FILTERS[saved])
    ]
    return render(title, parts, fetch(token, "/tasks", {}))


if __name__ == "__main__":
    raise SystemExit(main())
