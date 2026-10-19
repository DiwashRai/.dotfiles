"""Gates: measured limits that keep agent-mail small and readable. Run `just gates`.

A failing gate means simplify: pull a decision into its own function, or drop a case that
can't happen. Never split code just to dodge a number. Raising a limit needs a reason in a
comment beside it.
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

import complexipy

ROOT = Path(__file__).resolve().parent
FILES = ("agent_mail.py", "gates.py")
LIMITS = {
    "cognitive": 15,  # complexipy, per function
    "cyclomatic": 10,  # ruff C901, per function
    "code_lines": 400,  # per file: past this, rethink the design before adding more
}
TOO_COMPLEX = re.compile(r"`(?P<name>[^`]+)` is too complex \((?P<score>\d+) >")


def code_lines(source: str) -> int:
    stripped = (line.strip() for line in source.splitlines())
    return sum(1 for line in stripped if line and not line.startswith("#"))


def cognitive(sources: dict[str, str]) -> tuple[list[str], int]:
    limit, over, worst = LIMITS["cognitive"], [], 0
    for path, source in sources.items():
        for fn in complexipy.code_complexity(source).functions:
            worst = max(worst, fn.complexity)
            if fn.complexity > limit:
                over.append(f"{path}::{fn.name}  {fn.complexity} > {limit}")
    return over, worst


def cyclomatic() -> list[str]:
    command = [sys.executable, "-m", "ruff", "check", "--select", "C901", "--quiet"]
    command += ["--no-cache", "--output-format", "json", *FILES]
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True, check=False)
    if result.returncode not in (0, 1):
        return [f"ruff failed: {(result.stderr or result.stdout).strip()}"]
    over: list[str] = []
    for item in json.loads(result.stdout or "[]"):
        found = TOO_COMPLEX.search(str(item["message"]))
        if found:
            where = f"{Path(item['filename']).name}:{item['location']['row']}"
            over.append(f"{where} {found['name']}  {found['score']} > {LIMITS['cyclomatic']}")
    return over


def sizes(sources: dict[str, str]) -> tuple[list[str], int]:
    counts = {path: code_lines(source) for path, source in sources.items()}
    limit = LIMITS["code_lines"]
    over = [f"{path}  {n} > {limit} code lines" for path, n in counts.items() if n > limit]
    return over, max(counts.values())


def main() -> int:
    sources = {path: (ROOT / path).read_text(encoding="utf-8") for path in FILES}
    cognitive_over, worst_cognitive = cognitive(sources)
    size_over, biggest = sizes(sources)
    gates = [
        ("cognitive", cognitive_over, f"<= {LIMITS['cognitive']}, worst {worst_cognitive}"),
        ("cyclomatic", cyclomatic(), f"<= {LIMITS['cyclomatic']} (ruff C901)"),
        ("file size", size_over, f"<= {LIMITS['code_lines']} code lines, biggest {biggest}"),
    ]
    for name, over, summary in gates:
        print(f"  {'FAIL' if over else 'ok  '} {name:<11} {summary}")
        for line in over:
            print(f"         {line}")
    failed = any(over for _, over, _ in gates)
    print("FAIL: simplify, don't split or disguise" if failed else "PASS")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
