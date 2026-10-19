from __future__ import annotations

import ast
import sys
from pathlib import Path

import pytest

import agent_mail


class Panes:
    """Stands in for herdr: records what each agent's pane received."""

    def __init__(self, running: set[str]) -> None:
        self.running = running
        self.received: dict[str, list[str]] = {}
        self.notices: list[str] = []

    def ring(self, agent: str, text: str) -> bool:
        if agent not in self.running:
            return False
        self.received.setdefault(agent, []).append(text)
        return True

    def notify(self, title: str, body: str) -> None:
        self.notices.append(title)


@pytest.fixture
def home(tmp_path: Path) -> Path:
    for name in ("assistant", "chief"):
        agent_mail.main(["--home", str(tmp_path), "add-box", name])
    return tmp_path


def use_panes(monkeypatch: pytest.MonkeyPatch, *running: str) -> Panes:
    panes = Panes(set(running))
    monkeypatch.setattr(agent_mail, "ring", panes.ring)
    monkeypatch.setattr(agent_mail, "notify", panes.notify)
    return panes


def mail(home: Path, me: str, *args: str) -> None:
    agent_mail.main(["--home", str(home), "--as", me, *args])


def files(home: Path, box: str, folder: str) -> list[str]:
    return sorted(p.name for p in (home / "mail" / box / folder).glob("*.md"))


def test_a_request_is_pasted_into_the_pane_and_closed_by_the_reply(
    home: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    panes = use_panes(monkeypatch, "assistant", "chief")

    mail(home, "assistant", "send", "--to", "chief", "Find Italy dates")
    assert panes.received["chief"] == ["[mail #1 from assistant · request] Find Italy dates"]
    assert files(home, "chief", "new") == ["000001-from-assistant.md"]

    mail(home, "chief", "reply", "1", "Late May")
    assert panes.received["assistant"] == ["[mail #2 from chief · reply to #1] Late May"]
    assert files(home, "chief", "new") == []
    assert files(home, "chief", "done") == ["000001-from-assistant.md"]
    assert files(home, "assistant", "done") == ["000002-from-chief.md"]


def test_undelivered_mail_waits_in_new_and_inbox_delivers_it(
    home: Path, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    panes = use_panes(monkeypatch)  # chief isn't running

    mail(home, "assistant", "send", "--to", "chief", "--kind", "fyi", "Owner is on a call")
    mail(home, "assistant", "send", "--to", "chief", "--later", "Plan next week")
    assert panes.notices == ["Mail #1 for chief not delivered"]  # --later doesn't ring or warn
    assert len(files(home, "chief", "new")) == 2
    capsys.readouterr()

    mail(home, "chief", "inbox")
    shown = capsys.readouterr().out
    assert "Owner is on a call" in shown
    assert "Plan next week" in shown
    # The fyi is dealt with once shown; the request waits for a reply.
    assert files(home, "chief", "new") == ["000002-from-assistant.md"]


def test_a_long_body_stays_in_the_file(home: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    panes = use_panes(monkeypatch, "chief")
    body = "Research summary\n" + "x" * agent_mail.INLINE_LIMIT

    mail(home, "assistant", "send", "--to", "chief", body)
    (pasted,) = panes.received["chief"]
    assert "Research summary" in pasted
    assert "000001-from-assistant.md" in pasted
    assert len(pasted) < 400


def test_only_agents_with_a_mailbox_use_mail(home: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    use_panes(monkeypatch, "chief")
    with pytest.raises(SystemExit, match="no mailbox 'reviewer'"):
        mail(home, "chief", "send", "--to", "reviewer", "Review this")
    with pytest.raises(SystemExit, match="no mailbox 'chief-reviewer'"):
        mail(home, "chief-reviewer", "send", "--to", "chief", "Done")


def test_the_script_uses_only_the_standard_library() -> None:
    source = Path(agent_mail.__file__).read_text(encoding="utf-8")
    imported: set[str] = set()
    for node in ast.walk(ast.parse(source)):
        if isinstance(node, ast.Import):
            imported |= {alias.name.split(".")[0] for alias in node.names}
        elif isinstance(node, ast.ImportFrom) and node.module:
            imported.add(node.module.split(".")[0])
    assert imported <= sys.stdlib_module_names
