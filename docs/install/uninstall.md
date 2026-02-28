---
summary: "Uninstall AtomicBot completely (CLI, service, state, workspace)"
read_when:
  - You want to remove AtomicBot from a machine
  - The gateway service is still running after uninstall
title: "Uninstall"
---

# Uninstall

Two paths:

- **Easy path** if `atomicbot` is still installed.
- **Manual service removal** if the CLI is gone but the service is still running.

## Easy path (CLI still installed)

Recommended: use the built-in uninstaller:

```bash
atomicbot uninstall
```

Non-interactive (automation / npx):

```bash
atomicbot uninstall --all --yes --non-interactive
npx -y atomicbot uninstall --all --yes --non-interactive
```

Manual steps (same result):

1. Stop the gateway service:

```bash
atomicbot gateway stop
```

2. Uninstall the gateway service (launchd/systemd/schtasks):

```bash
atomicbot gateway uninstall
```

3. Delete state + config:

```bash
rm -rf "${ATOMICBOT_STATE_DIR:-$HOME/.atomicbot}"
```

If you set `ATOMICBOT_CONFIG_PATH` to a custom location outside the state dir, delete that file too.

4. Delete your workspace (optional, removes agent files):

```bash
rm -rf ~/.atomicbot/workspace
```

5. Remove the CLI install (pick the one you used):

```bash
npm rm -g atomicbot
pnpm remove -g atomicbot
bun remove -g atomicbot
```

6. If you installed the macOS app:

```bash
rm -rf /Applications/AtomicBot.app
```

Notes:

- If you used profiles (`--profile` / `ATOMICBOT_PROFILE`), repeat step 3 for each state dir (defaults are `~/.atomicbot-<profile>`).
- In remote mode, the state dir lives on the **gateway host**, so run steps 1-4 there too.

## Manual service removal (CLI not installed)

Use this if the gateway service keeps running but `atomicbot` is missing.

### macOS (launchd)

Default label is `bot.molt.gateway` (or `bot.molt.<profile>`; legacy `com.atomicbot.*` may still exist):

```bash
launchctl bootout gui/$UID/bot.molt.gateway
rm -f ~/Library/LaunchAgents/bot.molt.gateway.plist
```

If you used a profile, replace the label and plist name with `bot.molt.<profile>`. Remove any legacy `com.atomicbot.*` plists if present.

### Linux (systemd user unit)

Default unit name is `atomicbot-gateway.service` (or `atomicbot-gateway-<profile>.service`):

```bash
systemctl --user disable --now atomicbot-gateway.service
rm -f ~/.config/systemd/user/atomicbot-gateway.service
systemctl --user daemon-reload
```

### Windows (Scheduled Task)

Default task name is `AtomicBot Gateway` (or `AtomicBot Gateway (<profile>)`).
The task script lives under your state dir.

```powershell
schtasks /Delete /F /TN "AtomicBot Gateway"
Remove-Item -Force "$env:USERPROFILE\.atomicbot\gateway.cmd"
```

If you used a profile, delete the matching task name and `~\.atomicbot-<profile>\gateway.cmd`.

## Normal install vs source checkout

### Normal install (install.sh / npm / pnpm / bun)

If you used `https://atomicbot.ai/install.sh` or `install.ps1`, the CLI was installed with `npm install -g atomicbot@latest`.
Remove it with `npm rm -g atomicbot` (or `pnpm remove -g` / `bun remove -g` if you installed that way).

### Source checkout (git clone)

If you run from a repo checkout (`git clone` + `atomicbot ...` / `bun run atomicbot ...`):

1. Uninstall the gateway service **before** deleting the repo (use the easy path above or manual service removal).
2. Delete the repo directory.
3. Remove state + workspace as shown above.
