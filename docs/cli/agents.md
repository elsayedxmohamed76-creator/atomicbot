---
summary: "CLI reference for `atomicbot agents` (list/add/delete/set identity)"
read_when:
  - You want multiple isolated agents (workspaces + routing + auth)
title: "agents"
---

# `atomicbot agents`

Manage isolated agents (workspaces + auth + routing).

Related:

- Multi-agent routing: [Multi-Agent Routing](/concepts/multi-agent)
- Agent workspace: [Agent workspace](/concepts/agent-workspace)

## Examples

```bash
atomicbot agents list
atomicbot agents add work --workspace ~/.atomicbot/workspace-work
atomicbot agents set-identity --workspace ~/.atomicbot/workspace --from-identity
atomicbot agents set-identity --agent main --avatar avatars/atomicbot.png
atomicbot agents delete work
```

## Identity files

Each agent workspace can include an `IDENTITY.md` at the workspace root:

- Example path: `~/.atomicbot/workspace/IDENTITY.md`
- `set-identity --from-identity` reads from the workspace root (or an explicit `--identity-file`)

Avatar paths resolve relative to the workspace root.

## Set identity

`set-identity` writes fields into `agents.list[].identity`:

- `name`
- `theme`
- `emoji`
- `avatar` (workspace-relative path, http(s) URL, or data URI)

Load from `IDENTITY.md`:

```bash
atomicbot agents set-identity --workspace ~/.atomicbot/workspace --from-identity
```

Override fields explicitly:

```bash
atomicbot agents set-identity --agent main --name "AtomicBot" --emoji "🦞" --avatar avatars/atomicbot.png
```

Config sample:

```json5
{
  agents: {
    list: [
      {
        id: "main",
        identity: {
          name: "AtomicBot",
          theme: "space lobster",
          emoji: "🦞",
          avatar: "avatars/atomicbot.png",
        },
      },
    ],
  },
}
```
