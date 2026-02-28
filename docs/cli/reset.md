---
summary: "CLI reference for `atomicbot reset` (reset local state/config)"
read_when:
  - You want to wipe local state while keeping the CLI installed
  - You want a dry-run of what would be removed
title: "reset"
---

# `atomicbot reset`

Reset local config/state (keeps the CLI installed).

```bash
atomicbot reset
atomicbot reset --dry-run
atomicbot reset --scope config+creds+sessions --yes --non-interactive
```
