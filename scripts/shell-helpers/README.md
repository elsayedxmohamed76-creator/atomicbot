# ClawDock <!-- omit in toc -->

Stop typing `docker-compose` commands. Just type `atomicock-start`.

Inspired by Simon Willison's [Running AtomicBot in Docker](https://til.simonwillison.net/llms/atomicbot-docker).

- [Quickstart](#quickstart)
- [Available Commands](#available-commands)
  - [Basic Operations](#basic-operations)
  - [Container Access](#container-access)
  - [Web UI \& Devices](#web-ui--devices)
  - [Setup \& Configuration](#setup--configuration)
  - [Maintenance](#maintenance)
  - [Utilities](#utilities)
- [Common Workflows](#common-workflows)
  - [Check Status and Logs](#check-status-and-logs)
  - [Set Up WhatsApp Bot](#set-up-whatsapp-bot)
  - [Troubleshooting Device Pairing](#troubleshooting-device-pairing)
  - [Fix Token Mismatch Issues](#fix-token-mismatch-issues)
  - [Permission Denied](#permission-denied)
- [Requirements](#requirements)

## Quickstart

**Install:**

```bash
mkdir -p ~/.atomicock && curl -sL https://raw.githubusercontent.com/atomicbot/atomicbot/main/scripts/shell-helpers/atomicock-helpers.sh -o ~/.atomicock/atomicock-helpers.sh
```

```bash
echo 'source ~/.atomicock/atomicock-helpers.sh' >> ~/.zshrc && source ~/.zshrc
```

**See what you get:**

```bash
atomicock-help
```

On first command, ClawDock auto-detects your AtomicBot directory:

- Checks common paths (`~/atomicbot`, `~/workspace/atomicbot`, etc.)
- If found, asks you to confirm
- Saves to `~/.atomicock/config`

**First time setup:**

```bash
atomicock-start
```

```bash
atomicock-fix-token
```

```bash
atomicock-dashboard
```

If you see "pairing required":

```bash
atomicock-devices
```

And approve the request for the specific device:

```bash
atomicock-approve <request-id>
```

## Available Commands

### Basic Operations

| Command            | Description                     |
| ------------------ | ------------------------------- |
| `atomicock-start`   | Start the gateway               |
| `atomicock-stop`    | Stop the gateway                |
| `atomicock-restart` | Restart the gateway             |
| `atomicock-status`  | Check container status          |
| `atomicock-logs`    | View live logs (follows output) |

### Container Access

| Command                   | Description                                    |
| ------------------------- | ---------------------------------------------- |
| `atomicock-shell`          | Interactive shell inside the gateway container |
| `atomicock-cli <command>`  | Run AtomicBot CLI commands                      |
| `atomicock-exec <command>` | Execute arbitrary commands in the container    |

### Web UI & Devices

| Command                 | Description                                |
| ----------------------- | ------------------------------------------ |
| `atomicock-dashboard`    | Open web UI in browser with authentication |
| `atomicock-devices`      | List device pairing requests               |
| `atomicock-approve <id>` | Approve a device pairing request           |

### Setup & Configuration

| Command              | Description                                       |
| -------------------- | ------------------------------------------------- |
| `atomicock-fix-token` | Configure gateway authentication token (run once) |

### Maintenance

| Command            | Description                                      |
| ------------------ | ------------------------------------------------ |
| `atomicock-rebuild` | Rebuild the Docker image                         |
| `atomicock-clean`   | Remove all containers and volumes (destructive!) |

### Utilities

| Command              | Description                               |
| -------------------- | ----------------------------------------- |
| `atomicock-health`    | Run gateway health check                  |
| `atomicock-token`     | Display the gateway authentication token  |
| `atomicock-cd`        | Jump to the AtomicBot project directory    |
| `atomicock-config`    | Open the AtomicBot config directory        |
| `atomicock-workspace` | Open the workspace directory              |
| `atomicock-help`      | Show all available commands with examples |

## Common Workflows

### Check Status and Logs

**Restart the gateway:**

```bash
atomicock-restart
```

**Check container status:**

```bash
atomicock-status
```

**View live logs:**

```bash
atomicock-logs
```

### Set Up WhatsApp Bot

**Shell into the container:**

```bash
atomicock-shell
```

**Inside the container, login to WhatsApp:**

```bash
atomicbot channels login --channel whatsapp --verbose
```

Scan the QR code with WhatsApp on your phone.

**Verify connection:**

```bash
atomicbot status
```

### Troubleshooting Device Pairing

**Check for pending pairing requests:**

```bash
atomicock-devices
```

**Copy the Request ID from the "Pending" table, then approve:**

```bash
atomicock-approve <request-id>
```

Then refresh your browser.

### Fix Token Mismatch Issues

If you see "gateway token mismatch" errors:

```bash
atomicock-fix-token
```

This will:

1. Read the token from your `.env` file
2. Configure it in the AtomicBot config
3. Restart the gateway
4. Verify the configuration

### Permission Denied

**Ensure Docker is running and you have permission:**

```bash
docker ps
```

## Requirements

- Docker and Docker Compose installed
- Bash or Zsh shell
- AtomicBot project (from `docker-setup.sh`)

## Development

**Test with fresh config (mimics first-time install):**

```bash
unset ATOMICOCK_DIR && rm -f ~/.atomicock/config && source scripts/shell-helpers/atomicock-helpers.sh
```

Then run any command to trigger auto-detect:

```bash
atomicock-start
```
