---
summary: "CLI reference for `atomicbot config` (get/set/unset config values)"
read_when:
  - You want to read or edit config non-interactively
title: "config"
---

# `atomicbot config`

Config helpers: get/set/unset values by path. Run without a subcommand to open
the configure wizard (same as `atomicbot configure`).

## Examples

```bash
atomicbot config get browser.executablePath
atomicbot config set browser.executablePath "/usr/bin/google-chrome"
atomicbot config set agents.defaults.heartbeat.every "2h"
atomicbot config set agents.list[0].tools.exec.node "node-id-or-name"
atomicbot config unset tools.web.search.apiKey
```

## Paths

Paths use dot or bracket notation:

```bash
atomicbot config get agents.defaults.workspace
atomicbot config get agents.list[0].id
```

Use the agent list index to target a specific agent:

```bash
atomicbot config get agents.list
atomicbot config set agents.list[1].tools.exec.node "node-id-or-name"
```

## Values

Values are parsed as JSON5 when possible; otherwise they are treated as strings.
Use `--strict-json` to require JSON5 parsing. `--json` remains supported as a legacy alias.

```bash
atomicbot config set agents.defaults.heartbeat.every "0m"
atomicbot config set gateway.port 19001 --strict-json
atomicbot config set channels.whatsapp.groups '["*"]' --strict-json
```

Restart the gateway after edits.
