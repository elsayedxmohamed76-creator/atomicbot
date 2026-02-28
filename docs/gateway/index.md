---
summary: "Runbook for the Gateway service, lifecycle, and operations"
read_when:
  - Running or debugging the gateway process
title: "Gateway Runbook"
---

# Gateway runbook

Use this page for day-1 startup and day-2 operations of the Gateway service.

<CardGroup cols={2}>
  <Card title="Deep troubleshooting" icon="siren" href="/gateway/troubleshooting">
    Symptom-first diagnostics with exact command ladders and log signatures.
  </Card>
  <Card title="Configuration" icon="sliders" href="/gateway/configuration">
    Task-oriented setup guide + full configuration reference.
  </Card>
</CardGroup>

## 5-minute local startup

<Steps>
  <Step title="Start the Gateway">

```bash
atomicbot gateway --port 18789
# debug/trace mirrored to stdio
atomicbot gateway --port 18789 --verbose
# force-kill listener on selected port, then start
atomicbot gateway --force
```

  </Step>

  <Step title="Verify service health">

```bash
atomicbot gateway status
atomicbot status
atomicbot logs --follow
```

Healthy baseline: `Runtime: running` and `RPC probe: ok`.

  </Step>

  <Step title="Validate channel readiness">

```bash
atomicbot channels status --probe
```

  </Step>
</Steps>

<Note>
Gateway config reload watches the active config file path (resolved from profile/state defaults, or `ATOMICBOT_CONFIG_PATH` when set).
Default mode is `gateway.reload.mode="hybrid"`.
</Note>

## Runtime model

- One always-on process for routing, control plane, and channel connections.
- Single multiplexed port for:
  - WebSocket control/RPC
  - HTTP APIs (OpenAI-compatible, Responses, tools invoke)
  - Control UI and hooks
- Default bind mode: `loopback`.
- Auth is required by default (`gateway.auth.token` / `gateway.auth.password`, or `ATOMICBOT_GATEWAY_TOKEN` / `ATOMICBOT_GATEWAY_PASSWORD`).

### Port and bind precedence

| Setting      | Resolution order                                              |
| ------------ | ------------------------------------------------------------- |
| Gateway port | `--port` → `ATOMICBOT_GATEWAY_PORT` → `gateway.port` → `18789` |
| Bind mode    | CLI/override → `gateway.bind` → `loopback`                    |

### Hot reload modes

| `gateway.reload.mode` | Behavior                                   |
| --------------------- | ------------------------------------------ |
| `off`                 | No config reload                           |
| `hot`                 | Apply only hot-safe changes                |
| `restart`             | Restart on reload-required changes         |
| `hybrid` (default)    | Hot-apply when safe, restart when required |

## Operator command set

```bash
atomicbot gateway status
atomicbot gateway status --deep
atomicbot gateway status --json
atomicbot gateway install
atomicbot gateway restart
atomicbot gateway stop
atomicbot logs --follow
atomicbot doctor
```

## Remote access

Preferred: Tailscale/VPN.
Fallback: SSH tunnel.

```bash
ssh -N -L 18789:127.0.0.1:18789 user@host
```

Then connect clients to `ws://127.0.0.1:18789` locally.

<Warning>
If gateway auth is configured, clients still must send auth (`token`/`password`) even over SSH tunnels.
</Warning>

See: [Remote Gateway](/gateway/remote), [Authentication](/gateway/authentication), [Tailscale](/gateway/tailscale).

## Supervision and service lifecycle

Use supervised runs for production-like reliability.

<Tabs>
  <Tab title="macOS (launchd)">

```bash
atomicbot gateway install
atomicbot gateway status
atomicbot gateway restart
atomicbot gateway stop
```

LaunchAgent labels are `ai.atomicbot.gateway` (default) or `ai.atomicbot.<profile>` (named profile). `atomicbot doctor` audits and repairs service config drift.

  </Tab>

  <Tab title="Linux (systemd user)">

```bash
atomicbot gateway install
systemctl --user enable --now atomicbot-gateway[-<profile>].service
atomicbot gateway status
```

For persistence after logout, enable lingering:

```bash
sudo loginctl enable-linger <user>
```

  </Tab>

  <Tab title="Linux (system service)">

Use a system unit for multi-user/always-on hosts.

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now atomicbot-gateway[-<profile>].service
```

  </Tab>
</Tabs>

## Multiple gateways on one host

Most setups should run **one** Gateway.
Use multiple only for strict isolation/redundancy (for example a rescue profile).

Checklist per instance:

- Unique `gateway.port`
- Unique `ATOMICBOT_CONFIG_PATH`
- Unique `ATOMICBOT_STATE_DIR`
- Unique `agents.defaults.workspace`

Example:

```bash
ATOMICBOT_CONFIG_PATH=~/.atomicbot/a.json ATOMICBOT_STATE_DIR=~/.atomicbot-a atomicbot gateway --port 19001
ATOMICBOT_CONFIG_PATH=~/.atomicbot/b.json ATOMICBOT_STATE_DIR=~/.atomicbot-b atomicbot gateway --port 19002
```

See: [Multiple gateways](/gateway/multiple-gateways).

### Dev profile quick path

```bash
atomicbot --dev setup
atomicbot --dev gateway --allow-unconfigured
atomicbot --dev status
```

Defaults include isolated state/config and base gateway port `19001`.

## Protocol quick reference (operator view)

- First client frame must be `connect`.
- Gateway returns `hello-ok` snapshot (`presence`, `health`, `stateVersion`, `uptimeMs`, limits/policy).
- Requests: `req(method, params)` → `res(ok/payload|error)`.
- Common events: `connect.challenge`, `agent`, `chat`, `presence`, `tick`, `health`, `heartbeat`, `shutdown`.

Agent runs are two-stage:

1. Immediate accepted ack (`status:"accepted"`)
2. Final completion response (`status:"ok"|"error"`), with streamed `agent` events in between.

See full protocol docs: [Gateway Protocol](/gateway/protocol).

## Operational checks

### Liveness

- Open WS and send `connect`.
- Expect `hello-ok` response with snapshot.

### Readiness

```bash
atomicbot gateway status
atomicbot channels status --probe
atomicbot health
```

### Gap recovery

Events are not replayed. On sequence gaps, refresh state (`health`, `system-presence`) before continuing.

## Common failure signatures

| Signature                                                      | Likely issue                             |
| -------------------------------------------------------------- | ---------------------------------------- |
| `refusing to bind gateway ... without auth`                    | Non-loopback bind without token/password |
| `another gateway instance is already listening` / `EADDRINUSE` | Port conflict                            |
| `Gateway start blocked: set gateway.mode=local`                | Config set to remote mode                |
| `unauthorized` during connect                                  | Auth mismatch between client and gateway |

For full diagnosis ladders, use [Gateway Troubleshooting](/gateway/troubleshooting).

## Safety guarantees

- Gateway protocol clients fail fast when Gateway is unavailable (no implicit direct-channel fallback).
- Invalid/non-connect first frames are rejected and closed.
- Graceful shutdown emits `shutdown` event before socket close.

---

Related:

- [Troubleshooting](/gateway/troubleshooting)
- [Background Process](/gateway/background-process)
- [Configuration](/gateway/configuration)
- [Health](/gateway/health)
- [Doctor](/gateway/doctor)
- [Authentication](/gateway/authentication)
