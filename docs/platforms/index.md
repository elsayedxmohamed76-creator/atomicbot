---
summary: "Platform support overview (Gateway + companion apps)"
read_when:
  - Looking for OS support or install paths
  - Deciding where to run the Gateway
title: "Platforms"
---

# Platforms

AtomicBot core is written in TypeScript. **Node is the recommended runtime**.
Bun is not recommended for the Gateway (WhatsApp/Telegram bugs).

Companion apps exist for macOS (menu bar app) and mobile nodes (iOS/Android). A native Windows Desktop App (Electron) is now available. Linux companion apps are planned. The Gateway is fully supported on all platforms.

## Choose your OS

- macOS: [macOS](/platforms/macos)
- iOS: [iOS](/platforms/ios)
- Android: [Android](/platforms/android)
- Windows: [Windows](/platforms/windows)
- Linux: [Linux](/platforms/linux)

## VPS & hosting

- VPS hub: [VPS hosting](/vps)
- Fly.io: [Fly.io](/install/fly)
- Hetzner (Docker): [Hetzner](/install/hetzner)
- GCP (Compute Engine): [GCP](/install/gcp)
- exe.dev (VM + HTTPS proxy): [exe.dev](/install/exe-dev)

## Common links

- Install guide: [Getting Started](/start/getting-started)
- Gateway runbook: [Gateway](/gateway)
- Gateway configuration: [Configuration](/gateway/configuration)
- Service status: `atomicbot gateway status`

## Gateway service install (CLI)

Use one of these (all supported):

- Wizard (recommended): `atomicbot onboard --install-daemon`
- Direct: `atomicbot gateway install`
- Configure flow: `atomicbot configure` → select **Gateway service**
- Repair/migrate: `atomicbot doctor` (offers to install or fix the service)

The service target depends on OS:

- macOS: LaunchAgent (`bot.molt.gateway` or `bot.molt.<profile>`; legacy `com.atomicbot.*`)
- Linux/WSL2: systemd user service (`atomicbot-gateway[-<profile>].service`)
