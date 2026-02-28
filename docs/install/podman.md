---
summary: "Run AtomicBot in a rootless Podman container"
read_when:
  - You want a containerized gateway with Podman instead of Docker
title: "Podman"
---

# Podman

Run the AtomicBot gateway in a **rootless** Podman container. Uses the same image as Docker (build from the repo [Dockerfile](https://github.com/atomicbot/atomicbot/blob/main/Dockerfile)).

## Requirements

- Podman (rootless)
- Sudo for one-time setup (create user, build image)

## Quick start

**1. One-time setup** (from repo root; creates user, builds image, installs launch script):

```bash
./setup-podman.sh
```

This also creates a minimal `~atomicbot/.atomicbot/atomicbot.json` (sets `gateway.mode="local"`) so the gateway can start without running the wizard.

By default the container is **not** installed as a systemd service, you start it manually (see below). For a production-style setup with auto-start and restarts, install it as a systemd Quadlet user service instead:

```bash
./setup-podman.sh --quadlet
```

(Or set `ATOMICBOT_PODMAN_QUADLET=1`; use `--container` to install only the container and launch script.)

**2. Start gateway** (manual, for quick smoke testing):

```bash
./scripts/run-atomicbot-podman.sh launch
```

**3. Onboarding wizard** (e.g. to add channels or providers):

```bash
./scripts/run-atomicbot-podman.sh launch setup
```

Then open `http://127.0.0.1:18789/` and use the token from `~atomicbot/.atomicbot/.env` (or the value printed by setup).

## Systemd (Quadlet, optional)

If you ran `./setup-podman.sh --quadlet` (or `ATOMICBOT_PODMAN_QUADLET=1`), a [Podman Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) unit is installed so the gateway runs as a systemd user service for the atomicbot user. The service is enabled and started at the end of setup.

- **Start:** `sudo systemctl --machine atomicbot@ --user start atomicbot.service`
- **Stop:** `sudo systemctl --machine atomicbot@ --user stop atomicbot.service`
- **Status:** `sudo systemctl --machine atomicbot@ --user status atomicbot.service`
- **Logs:** `sudo journalctl --machine atomicbot@ --user -u atomicbot.service -f`

The quadlet file lives at `~atomicbot/.config/containers/systemd/atomicbot.container`. To change ports or env, edit that file (or the `.env` it sources), then `sudo systemctl --machine atomicbot@ --user daemon-reload` and restart the service. On boot, the service starts automatically if lingering is enabled for atomicbot (setup does this when loginctl is available).

To add quadlet **after** an initial setup that did not use it, re-run: `./setup-podman.sh --quadlet`.

## The atomicbot user (non-login)

`setup-podman.sh` creates a dedicated system user `atomicbot`:

- **Shell:** `nologin` — no interactive login; reduces attack surface.
- **Home:** e.g. `/home/atomicbot` — holds `~/.atomicbot` (config, workspace) and the launch script `run-atomicbot-podman.sh`.
- **Rootless Podman:** The user must have a **subuid** and **subgid** range. Many distros assign these automatically when the user is created. If setup prints a warning, add lines to `/etc/subuid` and `/etc/subgid`:

  ```text
  atomicbot:100000:65536
  ```

  Then start the gateway as that user (e.g. from cron or systemd):

  ```bash
  sudo -u atomicbot /home/atomicbot/run-atomicbot-podman.sh
  sudo -u atomicbot /home/atomicbot/run-atomicbot-podman.sh setup
  ```

- **Config:** Only `atomicbot` and root can access `/home/atomicbot/.atomicbot`. To edit config: use the Control UI once the gateway is running, or `sudo -u atomicbot $EDITOR /home/atomicbot/.atomicbot/atomicbot.json`.

## Environment and config

- **Token:** Stored in `~atomicbot/.atomicbot/.env` as `ATOMICBOT_GATEWAY_TOKEN`. `setup-podman.sh` and `run-atomicbot-podman.sh` generate it if missing (uses `openssl`, `python3`, or `od`).
- **Optional:** In that `.env` you can set provider keys (e.g. `GROQ_API_KEY`, `OLLAMA_API_KEY`) and other AtomicBot env vars.
- **Host ports:** By default the script maps `18789` (gateway) and `18790` (bridge). Override the **host** port mapping with `ATOMICBOT_PODMAN_GATEWAY_HOST_PORT` and `ATOMICBOT_PODMAN_BRIDGE_HOST_PORT` when launching.
- **Paths:** Host config and workspace default to `~atomicbot/.atomicbot` and `~atomicbot/.atomicbot/workspace`. Override the host paths used by the launch script with `ATOMICBOT_CONFIG_DIR` and `ATOMICBOT_WORKSPACE_DIR`.

## Useful commands

- **Logs:** With quadlet: `sudo journalctl --machine atomicbot@ --user -u atomicbot.service -f`. With script: `sudo -u atomicbot podman logs -f atomicbot`
- **Stop:** With quadlet: `sudo systemctl --machine atomicbot@ --user stop atomicbot.service`. With script: `sudo -u atomicbot podman stop atomicbot`
- **Start again:** With quadlet: `sudo systemctl --machine atomicbot@ --user start atomicbot.service`. With script: re-run the launch script or `podman start atomicbot`
- **Remove container:** `sudo -u atomicbot podman rm -f atomicbot` — config and workspace on the host are kept

## Troubleshooting

- **Permission denied (EACCES) on config or auth-profiles:** The container defaults to `--userns=keep-id` and runs as the same uid/gid as the host user running the script. Ensure your host `ATOMICBOT_CONFIG_DIR` and `ATOMICBOT_WORKSPACE_DIR` are owned by that user.
- **Gateway start blocked (missing `gateway.mode=local`):** Ensure `~atomicbot/.atomicbot/atomicbot.json` exists and sets `gateway.mode="local"`. `setup-podman.sh` creates this file if missing.
- **Rootless Podman fails for user atomicbot:** Check `/etc/subuid` and `/etc/subgid` contain a line for `atomicbot` (e.g. `atomicbot:100000:65536`). Add it if missing and restart.
- **Container name in use:** The launch script uses `podman run --replace`, so the existing container is replaced when you start again. To clean up manually: `podman rm -f atomicbot`.
- **Script not found when running as atomicbot:** Ensure `setup-podman.sh` was run so that `run-atomicbot-podman.sh` is copied to atomicbot’s home (e.g. `/home/atomicbot/run-atomicbot-podman.sh`).
- **Quadlet service not found or fails to start:** Run `sudo systemctl --machine atomicbot@ --user daemon-reload` after editing the `.container` file. Quadlet requires cgroups v2: `podman info --format '{{.Host.CgroupsVersion}}'` should show `2`.

## Optional: run as your own user

To run the gateway as your normal user (no dedicated atomicbot user): build the image, create `~/.atomicbot/.env` with `ATOMICBOT_GATEWAY_TOKEN`, and run the container with `--userns=keep-id` and mounts to your `~/.atomicbot`. The launch script is designed for the atomicbot-user flow; for a single-user setup you can instead run the `podman run` command from the script manually, pointing config and workspace to your home. Recommended for most users: use `setup-podman.sh` and run as the atomicbot user so config and process are isolated.
