from __future__ import annotations

import ast
import json
import sys
from datetime import UTC, date, datetime, time
from pathlib import Path
from typing import Any

import pytest

import todoist
from todoist import Task


def task(
    id: str, parent: str | None = None, order: int = 1, priority: int = 1, due: str = ""
) -> Task:
    return Task(id, f"task {id}", parent, order, priority, due)


def test_the_saved_queue_runs_as_its_comma_separated_parts_in_order() -> None:
    parts = todoist.split_query(todoist.FILTERS["queue"])
    assert parts[0] == "!#Backlog & overdue"
    assert parts[-1] == "today &!no time & date after: +0 minutes"
    assert len(parts) == 4


def test_top_level_tasks_are_headings_and_subtasks_nest_as_bullets() -> None:
    parent = task("a", priority=4, due="2026-10-18T14:00:00")
    child, grandchild = task("b", parent="a", order=2), task("c", parent="b")
    first_child = task("d", parent="a", order=1)

    out = todoist.render("Queue", [[parent, child]], [parent, child, grandchild, first_child])

    body = out.split("\n", 2)[2]  # after the title and the "as of" line
    assert body == (
        "\n## task a · Sun 18 Oct 14:00 · p1\n- task d\n- task b\n  - task c\n"
    )  # b is listed by the filter too, but shows once, under its parent


def test_a_task_matched_by_two_parts_shows_once() -> None:
    a, b = task("a", due="2026-10-17"), task("b")

    out = todoist.render("Queue", [[a], [b, a]], [a, b])

    assert out.count("## task a") == 1
    assert out.index("## task a") < out.index("## task b")  # the earlier part's order wins


def test_an_empty_queue_says_so() -> None:
    assert todoist.render("Queue", [[], []], []).endswith("\nNothing.\n")


DAY = date(2026, 10, 26)


def event(summary: str, start: time, end: time) -> dict[str, Any]:
    """A calendar event as the API has it: in UTC."""

    def utc(at: time) -> dict[str, str | None]:
        moment = datetime.combine(DAY, at).astimezone(UTC)
        return {"date": None, "date_time": f"{moment:%Y-%m-%dT%H:%M:%SZ}"}

    return {"summary": summary, "start": utc(start), "end": utc(end)}


def timed(content: str, due: str, minutes: int | None) -> dict[str, Any]:
    duration = {"amount": minutes, "unit": "minute"} if minutes else None
    return {"content": content, "due": {"date": due}, "duration": duration}


def test_a_day_comes_out_as_glances_today_section_or_as_json() -> None:
    all_day = {
        "summary": "Busy",
        "start": {"date": "2026-10-26", "date_time": None},
        "end": {"date": "2026-10-27", "date_time": None},
    }
    raw_tasks = [
        timed("Run", "2026-10-26T23:30:00", 60),
        timed("Deep Work", "2026-10-26T11:30:00", 90),  # starts as Busy ends: no clash
        timed("Mental status check", "2026-10-26", 15),  # no time
        timed("Laundry", "2026-10-26T20:00:00", None),  # no duration
        timed("Yesterday", "2026-10-25T09:00:00", 30),
    ]
    raw_events = [
        event("Dentist", time(17), time(17, 45)),
        event("Busy", time(11), time(11, 30)),
        event("Busy", time(10, 30), time(11, 15)),  # double-booked: merged
        event("Busy", time(10), time(10, 30)),  # touches, so stays apart
        event("Free", time(9), time(10)),
        event("Tentative", time(14), time(15)),
        all_day,
    ]
    blocks = [*map(todoist.task_block, raw_tasks), *map(todoist.event_block, raw_events)]
    day_plan = todoist.plan(DAY, blocks)

    assert todoist.timeline(day_plan, as_json=False) == (
        "# Today 2026-10-26\n"
        "- 10:00-10:30 Busy\n"
        "- 10:30-11:30 Busy x 2\n"
        "- 11:30-13:00 Deep Work\n"
        "- 17:00-17:45 Dentist\n"
        "- 23:30-23:59 Run\n"  # cut at midnight
    )
    assert json.loads(todoist.timeline(day_plan, as_json=True))["blocks"][1:3] == [
        {"start": "10:30", "end": "11:30", "what": "Busy x 2", "kind": "busy"},
        {"start": "11:30", "end": "13:00", "what": "Deep Work", "kind": "task"},
    ]


def test_overlapping_blocks_print_no_plan_but_each_clash() -> None:
    blocks = [
        todoist.event_block(event("Busy", time(11), time(11, 30))),
        todoist.task_block(timed("Deep Work", "2026-10-26T11:00:00", 120)),
        todoist.task_block(timed("Lunch", "2026-10-26T13:00:00", 30)),
    ]

    with pytest.raises(SystemExit) as refused:
        todoist.timeline(todoist.plan(DAY, blocks), as_json=False)

    assert str(refused.value) == (
        "These blocks overlap: fix them in Todoist.\n"
        "11:00-11:30 Busy  overlaps  11:00-13:00 Deep Work"
    )


def test_the_script_uses_only_the_standard_library() -> None:
    source = Path(todoist.__file__).read_text(encoding="utf-8")
    imported: set[str] = set()
    for node in ast.walk(ast.parse(source)):
        if isinstance(node, ast.Import):
            imported |= {alias.name.split(".")[0] for alias in node.names}
        elif isinstance(node, ast.ImportFrom) and node.module:
            imported.add(node.module.split(".")[0])
    assert imported <= sys.stdlib_module_names
