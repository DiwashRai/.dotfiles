---
name: agent-mail
description: Mail box for specific agents. Their agent prompt will notify the agents that should use this.
---

# agent-mail

The mailbox is only for long-term agents: assistant, chief, project leads. The main benefits are:
- having a history of what has been discussed
- survives restarts
- mail can be left for consumption later

# Usage
`python "$HOME/.claude/skills/agent-mail/agent_mail.py" <command>` · needs `AGENTS_HOME`, plus `AGENT_NAME` = your mailbox

- Ask for something: `send --to chief "..."`
- Tell (no reply needed): `send --to chief --kind fyi "..."`
- Leave for their next start: `send --to chief --later "..."`
- Answer `[mail #12 ...]`: `reply 12 "..."`
- Check your mail (on start): `inbox`
- Give a new long-term agent (a project lead) a mailbox: `add-box <name>`

- Mail arrives as a prompt: `[mail #12 from chief · request] ...`. Answer every request with `reply`; that closes it.
- Never touch the mail folder's files. The script moves them.
- Short messages. Put long material in a file and send the path.
- Never `herdr agent prompt` another long-term agent: mail it, so it's logged.

