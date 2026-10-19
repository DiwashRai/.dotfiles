---
name: herdr-cheatsheet
description: The owner's conventions for herdr - long-term agents vs helpers, spaces, naming. Use with `herdr --skill` whenever you'd call herdr.
---

# herdr: our conventions

How to drive herdr: run `herdr --skill` once per session and follow it. On top of that:

- **Long-term agents** (assistant, chief, project leads): message them with agent-mail, never `herdr agent prompt`.
- **Helpers**: only when the owner asks. Open one beside your pane, name it `<you>-<name>`, and stop it when you're done.
- **Spaces**: the chief may create workspaces without being asked each time (this overrides herdr's default). Label = agent name, `--env AGENT_NAME=<name> --env AGENTS_HOME=C:\agents`, then `herdr agent start <name> --kind claude --pane <id> -- --agent <name>`. It needs an agent in `~/.claude/agents/` with that `name:` (or claude exits) and a mailbox (`agent_mail.py add-box <name>`).
- **`lead` tab**: label the tab holding a long-term agent `lead` (`herdr tab rename <tab> lead`); other tabs are for helpers, servers and the owner. A name is lost when an agent restarts outside `agent start`, so find it by workspace + `lead` tab and `herdr agent rename <pane> <name>`.
- **Output**: pipe herdr's JSON through `jq` for the one field you need, e.g. `| jq -r .result.pane.pane_id`.
