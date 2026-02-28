---
summary: "CLI reference for `atomicbot daemon` (legacy alias for gateway service management)"
read_when:
  - You still use `atomicbot daemon ...` in scripts
  - You need service lifecycle commands (install/start/stop/restart/status)
title: "daemon"
---

# `atomicbot daemon`

Legacy alias for Gateway service management commands.

`atomicbot daemon ...` maps to the same service control surface as `atomicbot gateway ...` service commands.

## Usage

```bash
atomicbot daemon status
atomicbot daemon install
atomicbot daemon start
atomicbot daemon stop
atomicbot daemon restart
atomicbot daemon uninstall
```

## Subcommands

- `status`: show service install state and probe Gateway health
- `install`: install service (`launchd`/`systemd`/`schtasks`)
- `uninstall`: remove service
- `start`: start service
- `stop`: stop service
- `restart`: restart service

## Common options

- `status`: `--url`, `--token`, `--password`, `--timeout`, `--no-probe`, `--deep`, `--json`
- `install`: `--port`, `--runtime <node|bun>`, `--token`, `--force`, `--json`
- lifecycle (`uninstall|start|stop|restart`): `--json`

## Prefer

Use [`atomicbot gateway`](/cli/gateway) for current docs and examples.
