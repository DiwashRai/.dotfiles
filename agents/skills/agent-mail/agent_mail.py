"""agent-mail: mail between long-term agents (assistant, chief, project leads).

Each message is a file in the recipient's mailbox, `$AGENTS_HOME/mail/<agent>/new/`. The script
pastes it into the recipient's herdr pane and moves it to `done/` once it's dealt with. Agents
only run commands; they never touch the files.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import time
from collections.abc import Iterator
from contextlib import contextmanager
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path

KINDS = ("request", "fyi")
NAME = re.compile(r"[a-z][a-z0-9_-]{0,31}")  # herdr's agent-name rule: a mailbox is an agent name
INLINE_LIMIT = 1500  # longer bodies stay in the file; the pane gets the first line and the path
LOCK_WAIT_S = 5.0  # hang guard: the lock is only held while a message id is claimed


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="agent_mail", description=__doc__)
    parser.add_argument("--home", default=os.environ.get("AGENTS_HOME"), help="$AGENTS_HOME")
    parser.add_argument("--as", dest="me", default=os.environ.get("AGENT_NAME"), help="$AGENT_NAME")
    sub = parser.add_subparsers(dest="command", required=True)

    send = sub.add_parser("send", help="send a message; it's pasted into their pane now")
    send.add_argument("--to", required=True, help="the recipient's mailbox")
    send.add_argument("--kind", choices=KINDS, default="request", help="fyi needs no reply")
    send.add_argument("--later", action="store_true", help="don't ring; they get it next start")
    send.add_argument("body")

    reply = sub.add_parser("reply", help="answer message ID; this closes it")
    reply.add_argument("id", type=int)
    reply.add_argument("body")

    sub.add_parser("inbox", help="show what's waiting in your mailbox")

    add_box = sub.add_parser("add-box", help="give a new long-term agent a mailbox")
    add_box.add_argument("name")
    return parser


# ---- Messages ------------------------------------------------------------------------------


@dataclass(frozen=True)
class Message:
    id: int
    sender: str
    to: str
    kind: str  # request | fyi | reply
    sent: str
    body: str
    re: int | None = None  # the message a reply answers

    @property
    def filename(self) -> str:
        return f"{self.id:06d}-from-{self.sender}.md"

    def to_text(self) -> str:
        re_line = f"re: {self.re}\n" if self.re else ""
        head = f"id: {self.id}\nfrom: {self.sender}\nto: {self.to}\nkind: {self.kind}\n"
        return f"---\n{head}{re_line}sent: {self.sent}\n---\n\n{self.body}\n"

    def prompt(self, path: Path) -> str:
        label = f"reply to #{self.re}" if self.re else self.kind
        head = f"[mail #{self.id} from {self.sender} · {label}]"
        if len(self.body) <= INLINE_LIMIT:
            return f"{head} {self.body}"
        return f"{head} {self.body.splitlines()[0][:200]} … (long message, read {path})"


def read_message(path: Path) -> Message:
    _, header, body = path.read_text(encoding="utf-8").split("---\n", 2)
    fields = dict(line.split(": ", 1) for line in header.splitlines())
    reply_to = int(fields["re"]) if "re" in fields else None
    return Message(
        int(fields["id"]),
        fields["from"],
        fields["to"],
        fields["kind"],
        fields["sent"],
        body.strip("\n"),
        reply_to,
    )


# ---- The mail folder -----------------------------------------------------------------------


@dataclass(frozen=True)
class Mail:
    root: Path

    def box(self, name: str) -> Path:
        path = self.root / name
        if not (path / "new").is_dir():
            boxes = ", ".join(self.boxes()) or "none yet"
            raise SystemExit(f"no mailbox '{name}' (mailboxes: {boxes}); see `add-box`")
        return path

    def boxes(self) -> list[str]:
        return sorted(p.parent.name for p in self.root.glob("*/new"))

    def find(self, name: str, message_id: int) -> Path:
        found = sorted(self.box(name).glob(f"*/{message_id:06d}-*.md"))
        if not found:
            raise SystemExit(f"no message #{message_id} in {name}'s mailbox")
        return found[0]

    def log(self, event: str, message: Message) -> None:
        entry = {"ts": now(), "event": event, "id": message.id, "from": message.sender}
        entry |= {"to": message.to, "kind": message.kind}
        with (self.root / "log.jsonl").open("a", encoding="utf-8", newline="\n") as log:
            log.write(json.dumps(entry) + "\n")

    def next_id(self) -> int:
        with self._locked():
            counter = self.root / ".next-id"
            value = int(counter.read_text(encoding="utf-8")) if counter.exists() else 1
            counter.write_text(str(value + 1), encoding="utf-8")
        return value

    @contextmanager
    def _locked(self) -> Iterator[None]:
        lock = self.root / ".lock"
        deadline = time.monotonic() + LOCK_WAIT_S
        while True:
            try:
                fd = os.open(lock, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
                break
            except FileExistsError as held:
                if time.monotonic() > deadline:
                    message = f"{lock} is held; if no agent_mail is running, delete it"
                    raise SystemExit(message) from held
                time.sleep(0.05)
        try:
            yield
        finally:
            os.close(fd)
            lock.unlink()


def now() -> str:
    return datetime.now(UTC).astimezone().isoformat(timespec="seconds")


def done(path: Path) -> None:
    path.replace(path.parent.parent / "done" / path.name)


# ---- herdr ---------------------------------------------------------------------------------


def herdr(*args: str) -> bool:
    if os.environ.get("HERDR_ENV") != "1" or not shutil.which("herdr"):
        return False
    result = subprocess.run(["herdr", *args], capture_output=True, text=True, check=False)
    return result.returncode == 0


def ring(agent: str, text: str) -> bool:
    """Paste text into the agent's pane. False if it isn't running or sits at a dialog."""
    return herdr("agent", "prompt", agent, text)


def notify(title: str, body: str) -> None:
    herdr("notification", "show", title, "--body", body, "--sound", "request")


# ---- Commands ------------------------------------------------------------------------------


def send(mail: Mail, message: Message, later: bool) -> str:
    path = mail.box(message.to) / "new" / message.filename
    path.write_text(message.to_text(), encoding="utf-8", newline="\n")
    mail.log("sent", message)
    if later:
        return f"#{message.id} queued for {message.to}'s next start"
    if not ring(message.to, message.prompt(path)):
        mail.log("undelivered", message)
        notify(f"Mail #{message.id} for {message.to} not delivered", message.body[:120])
        return f"#{message.id} not delivered ({message.to} isn't running); it waits in new/"
    mail.log("delivered", message)
    if message.kind != "request":
        done(path)
    return f"#{message.id} delivered to {message.to}"


def reply(mail: Mail, me: str, message_id: int, body: str) -> str:
    original_path = mail.find(me, message_id)
    original = read_message(original_path)
    answer = Message(mail.next_id(), me, original.sender, "reply", now(), body, message_id)
    result = send(mail, answer, later=False)
    if original_path.parent.name == "new":
        done(original_path)
    mail.log("replied", original)
    return result


def inbox(mail: Mail, me: str) -> str:
    """Everything in new/: requests stay until answered, the rest is now delivered."""
    paths = sorted((mail.box(me) / "new").glob("*.md"))
    lines: list[str] = []
    for path in paths:
        message = read_message(path)
        lines.append(message.prompt(path))
        mail.log("delivered", message)
        if message.kind != "request":
            done(path)
    return "\n".join(lines) or "inbox empty"


def add_box(mail: Mail, name: str) -> str:
    if not NAME.fullmatch(name):
        raise SystemExit(f"'{name}' isn't a valid herdr agent name ([a-z][a-z0-9_-]{{0,31}})")
    for folder in ("new", "done"):
        (mail.root / name / folder).mkdir(parents=True, exist_ok=True)
    return f"mailbox ready: {mail.root / name}"


def run(args: argparse.Namespace, parser: argparse.ArgumentParser) -> str:
    if not args.home:
        parser.error("set AGENTS_HOME or pass --home")
    mail = Mail(Path(args.home) / "mail")
    if args.command == "add-box":
        return add_box(mail, args.name)
    if not args.me:
        parser.error("set AGENT_NAME (your mailbox) or pass --as")
    mail.box(args.me)  # only long-term agents, the ones with a mailbox, use mail
    if args.command == "send":
        message = Message(mail.next_id(), args.me, args.to, args.kind, now(), args.body)
        return send(mail, message, args.later)
    if args.command == "reply":
        return reply(mail, args.me, args.id, args.body)
    return inbox(mail, args.me)


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    print(run(parser.parse_args(argv), parser))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
