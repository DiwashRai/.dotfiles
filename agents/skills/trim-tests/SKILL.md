---
name: trim-tests
description: Cut a change's tests down to the ones worth keeping, before opening a PR or merging. Use when a feature is done and its tests pass, when asked to "trim", "slim" or "simplify" tests, or before `gh pr create`.
---

# Trim tests

While building, write whatever tests help: they're scaffolding. Once the code is right, most of
them have done their job, and every test left behind is something future changes must keep
passing. This pass keeps the tests that protect behaviour and cuts the rest.

## Keep a test when it protects

- **A rule the user relies on:** what a command does, what a file must look like, what gets
  refused.
- **A decision someone made on purpose,** which a later change could quietly undo.
- **A real bug that was found** and could plausibly come back, such as input that crashed or a
  file that couldn't be read back.
- **A promise about data:** round trips, never overwriting a file it couldn't read, the exact
  format of anything another program or person reads.

## Cut a test when it

- **Tests the language, the standard library, a dependency or the OS** rather than our code.
  For example, path joining, an encoding argument handling a byte-order mark, or the OS
  refusing to replace a read-only file.
- **Is proven by the type checker, linters or quality gates already.**
- **Repeats another test's point** with a different value.
- **Pins an implementation detail** (private helpers, exact intermediate values) that a
  refactor would break without the behaviour changing.
- **Only exists to raise coverage.**

## Merge before cutting

- **Several tests of one rule** become one test with a table of cases.
- **A table keeps one case per distinct rule or message,** not every value that was tried.
- **A small check can ride along in a bigger test** that already sets up the same thing.

## How

1. List every test in the change, with one line on what it protects.
2. Mark each one keep, merge or cut, using the rules above. When unsure whether something is a
   deliberate decision, ask the user rather than cutting it.
3. Make the changes, then run the project's tests and checks (linters, type checker, any
   quality gates). The project's AGENTS.md or CLAUDE.md usually names them.
4. Report the before and after counts (test functions and test runs), and list what was cut,
   with reasons, so the user can bring anything back.
