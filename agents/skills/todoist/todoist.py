"""todoist: print the owner's Todoist tasks for a filter, as Markdown.

Each top-level task is a `##` heading, with its subtasks as bullets under it. The API rejects
a filter with commas, so each comma-separated part runs on its own, in order, and a task shown
by an earlier part isn't repeated. Reads only; needs TODOIST_TOKEN.
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
from datetime import UTC, date, datetime
from typing import Any

FILTERS = {
    "queue": (
        "!#Backlog & overdue, today & !no time & date before: +0 minutes, today & no time, "
        "today &!no time & date after: +0 minutes"
    ),
}
API = "https://api.todoist.com/api/v1"
PRIORITY = {4: "p1", 3: "p2", 2: "p3"}  # the API counts up to 4 = p1; p4 (1) isn't shown


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="todoist", description=__doc__)
    parser.add_argument("filter", nargs="?", default="queue", choices=FILTERS, help="saved filter")
    parser.add_argument("--query", help="an ad-hoc Todoist filter instead of a saved one")
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


# ---- The API -------------------------------------------------------------------------------


def fetch(token: str, path: str, params: dict[str, str]) -> list[Task]:
    """Every page of a task listing."""
    tasks: list[Task] = []
    cursor = ""
    while True:
        query = {**params, "limit": "200", **({"cursor": cursor} if cursor else {})}
        page = get(token, f"{API}{path}?{urllib.parse.urlencode(query)}")
        tasks += [parse_task(raw) for raw in page["results"]]
        cursor = page.get("next_cursor") or ""
        if not cursor:
            return tasks


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
    query = args.query or FILTERS[args.filter]
    title = "Tasks" if args.query else args.filter.capitalize()
    parts = [fetch(token, "/tasks/filter", {"query": part}) for part in split_query(query)]
    markdown = render(title, parts, fetch(token, "/tasks", {}))
    sys.stdout.buffer.write(markdown.encode("utf-8"))  # Windows pipes default to cp1252: emoji
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
