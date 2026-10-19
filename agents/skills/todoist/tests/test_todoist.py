from __future__ import annotations

import ast
import sys
from pathlib import Path

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


def test_the_script_uses_only_the_standard_library() -> None:
    source = Path(todoist.__file__).read_text(encoding="utf-8")
    imported: set[str] = set()
    for node in ast.walk(ast.parse(source)):
        if isinstance(node, ast.Import):
            imported |= {alias.name.split(".")[0] for alias in node.names}
        elif isinstance(node, ast.ImportFrom) and node.module:
            imported.add(node.module.split(".")[0])
    assert imported <= sys.stdlib_module_names
