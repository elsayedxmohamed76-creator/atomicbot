---
title: "Windows"
summary: "Windows Desktop App (Electron) + WSL2 support"
read_when:
  - Installing AtomicBot on Windows
  - Looking for the Windows desktop app
  - Running the Gateway on Windows via WSL2
---

# Windows

AtomicBot on Windows is recommended **via WSL2** (Ubuntu recommended) for the CLI + Gateway, or via the **Native Desktop App**.

## Windows Desktop App

AtomicBot offers a native Windows desktop app built with Electron. It provides the same user interface and powerful features as the macOS version, optimized for the Windows environment.

- **System Requirements**: Windows 10 or higher, x64 architecture.
- **Installation**: Download `Atomic-Bot-<version>-x64-win.exe` from the [GitHub Releases](https://github.com/elsayedxmohamed76-creator/atomicbot/releases) page of the `elsayedxmohamed76-creator/atomicbot` repository. Run the setup (NSIS one-click installer); no complex configuration is required.
- **Auto-Updates**: The app automatically checks for updates every 5 minutes using `electron-updater`. If a new version is found, it is downloaded in the background and installed the next time you restart the app.

### Feature Support (vs. macOS)

| Feature          | Windows            | macOS              |
| ---------------- | ------------------ | ------------------ |
| Built-in Gateway | ✅                 | ✅                 |
| jq runtime       | ✅                 | ✅                 |
| gh (GitHub CLI)  | ✅                 | ✅                 |
| GOG runtime      | ✅ (if configured) | ✅ (if configured) |
| obsidian-cli     | ✅                 | ✅                 |
| whisper-cli      | ✅                 | ✅                 |
| memo             | ❌ macOS only      | ✅                 |
| remindctl        | ❌ macOS only      | ✅                 |

### Local Development Build

Developers can build the app locally using npm from the `apps/electron-desktop` directory:

```bash
npm run dist:local:win:full
```

## Install (WSL2)

- [Getting Started](/start/getting-started) (use inside WSL)
- [Install & updates](/install/updating)
- Official WSL2 guide (Microsoft): [https://learn.microsoft.com/windows/wsl/install](https://learn.microsoft.com/windows/wsl/install)

## Gateway

- [Gateway runbook](/gateway)
- [Configuration](/gateway/configuration)

## Gateway service install (CLI)

Inside WSL2:

```
atomicbot onboard --install-daemon
```

Or:

```
atomicbot gateway install
```

Or:

```
atomicbot configure
```

Select **Gateway service** when prompted.

Repair/migrate:

```
atomicbot doctor
```

## Advanced: expose WSL services over LAN (portproxy)

WSL has its own virtual network. If another machine needs to reach a service
running **inside WSL** (SSH, a local TTS server, or the Gateway), you must
forward a Windows port to the current WSL IP. The WSL IP changes after restarts,
so you may need to refresh the forwarding rule.

Example (PowerShell **as Administrator**):

```powershell
$Distro = "Ubuntu-24.04"
$ListenPort = 2222
$TargetPort = 22

$WslIp = (wsl -d $Distro -- hostname -I).Trim().Split(" ")[0]
if (-not $WslIp) { throw "WSL IP not found." }

netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=$ListenPort `
  connectaddress=$WslIp connectport=$TargetPort
```

Allow the port through Windows Firewall (one-time):

```powershell
New-NetFirewallRule -DisplayName "WSL SSH $ListenPort" -Direction Inbound `
  -Protocol TCP -LocalPort $ListenPort -Action Allow
```

Refresh the portproxy after WSL restarts:

```powershell
netsh interface portproxy delete v4tov4 listenport=$ListenPort listenaddress=0.0.0.0 | Out-Null
netsh interface portproxy add v4tov4 listenport=$ListenPort listenaddress=0.0.0.0 `
  connectaddress=$WslIp connectport=$TargetPort | Out-Null
```

Notes:

- SSH from another machine targets the **Windows host IP** (example: `ssh user@windows-host -p 2222`).
- Remote nodes must point at a **reachable** Gateway URL (not `127.0.0.1`); use
  `atomicbot status --all` to confirm.
- Use `listenaddress=0.0.0.0` for LAN access; `127.0.0.1` keeps it local only.
- If you want this automatic, register a Scheduled Task to run the refresh
  step at login.

## Step-by-step WSL2 install

### 1) Install WSL2 + Ubuntu

Open PowerShell (Admin):

```powershell
wsl --install
# Or pick a distro explicitly:
wsl --list --online
wsl --install -d Ubuntu-24.04
```

Reboot if Windows asks.

### 2) Enable systemd (required for gateway install)

In your WSL terminal:

```bash
sudo tee /etc/wsl.conf >/dev/null <<'EOF'
[boot]
systemd=true
EOF
```

Then from PowerShell:

```powershell
wsl --shutdown
```

Re-open Ubuntu, then verify:

```bash
systemctl --user status
```

### 3) Install AtomicBot (inside WSL)

Follow the Linux Getting Started flow inside WSL:

```bash
git clone https://github.com/atomicbot/atomicbot.git
cd atomicbot
pnpm install
pnpm ui:build # auto-installs UI deps on first run
pnpm build
atomicbot onboard
```

Full guide: [Getting Started](/start/getting-started)

## Windows companion app

The Windows companion app is now available as a full Desktop App. See the [Windows Desktop App](#windows-desktop-app) section above for installation details.
