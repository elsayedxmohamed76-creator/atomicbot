// Cross-platform helpers for fetch / prepare build scripts.
//
// Centralises archive extraction, file permissions, binary naming,
// and common filesystem operations so individual scripts stay lean.

import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import JSZip from "jszip";

// ---------------------------------------------------------------------------
// OS / arch helpers
// ---------------------------------------------------------------------------

/**
 * Target platform for cross-compilation. Override via TARGET_PLATFORM env var
 * (e.g. "win32" when building Windows artifacts on a Linux CI runner).
 * Falls back to `process.platform` when unset.
 */
export function targetPlatform() {
  const env = (process.env.TARGET_PLATFORM || "").trim();
  return env || process.platform;
}

/**
 * Target architecture for cross-compilation. Override via TARGET_ARCH env var.
 * Falls back to `process.arch` when unset.
 */
export function targetArch() {
  const env = (process.env.TARGET_ARCH || "").trim();
  return env || process.arch;
}

/** True when the target platform/arch differs from the host. */
export function isCrossCompiling() {
  return targetPlatform() !== process.platform || targetArch() !== process.arch;
}

/** Map `process.platform` to the OS token used in GitHub release asset names. */
export function resolveOs(platform = targetPlatform()) {
  if (platform === "darwin") return "darwin";
  if (platform === "linux") return "linux";
  if (platform === "win32") return "windows";
  throw new Error(`unsupported platform: ${platform}`);
}

/** Map `process.arch` to the arch token used in most release asset names. */
export function resolveArch(arch = targetArch()) {
  if (arch === "arm64") return "arm64";
  if (arch === "x64") return "amd64";
  throw new Error(`unsupported arch: ${arch}`);
}

// ---------------------------------------------------------------------------
// Filesystem primitives
// ---------------------------------------------------------------------------

export function rmrf(p) {
  try {
    fs.rmSync(p, { recursive: true, force: true });
  } catch {
    // ignore
  }
}

export function ensureDir(p) {
  fs.mkdirSync(p, { recursive: true });
}

export function listDirSafe(p) {
  try {
    return fs.readdirSync(p);
  } catch {
    return [];
  }
}

// fs.renameSync fails with EXDEV when src and dest are on different drives
// (common on Windows CI where temp is on C:\ and workspace on D:\).
export function moveDir(src, dest) {
  try {
    fs.renameSync(src, dest);
  } catch (err) {
    if (err.code === "EXDEV" || err.code === "EPERM" || err.code === "ENOTEMPTY") {
      rmrf(dest);
      fs.cpSync(src, dest, { recursive: true });
      rmrf(src);
    } else {
      throw err;
    }
  }
}

// ---------------------------------------------------------------------------
// Executable helpers
// ---------------------------------------------------------------------------

/** chmod 0o755 on Unix; no-op on Windows. */
export function makeExecutable(filePath) {
  if (process.platform !== "win32") {
    fs.chmodSync(filePath, 0o755);
  }
}

/** Copy a file and ensure it is executable. */
export function copyExecutable(src, dest) {
  ensureDir(path.dirname(dest));
  fs.copyFileSync(src, dest);
  makeExecutable(dest);
}

/** Append `.exe` when targeting Windows, return the name unchanged otherwise. */
export function binName(name, platform) {
  const p = platform ?? targetPlatform();
  return p === "win32" ? `${name}.exe` : name;
}

// ---------------------------------------------------------------------------
// Archive extraction
// ---------------------------------------------------------------------------

/** Extract a .zip archive. Uses JSZip for local extraction without external dependencies. */
export async function extractZip(archivePath, extractDir) {
  rmrf(extractDir);
  ensureDir(extractDir);

  const data = fs.readFileSync(archivePath);
  const zip = await JSZip.loadAsync(data);

  for (const [name, file] of Object.entries(zip.files)) {
    const dest = path.join(extractDir, name);
    if (file.dir) {
      ensureDir(dest);
    } else {
      ensureDir(path.dirname(dest));
      const content = await file.async("nodebuffer");
      fs.writeFileSync(dest, content);
    }
  }
}

/** Extract a .tar.gz / .tgz archive. `tar` is available on Win10+. */
export function extractTarGz(archivePath, extractDir) {
  rmrf(extractDir);
  ensureDir(extractDir);
  // GNU tar (from Git/MSYS2 on Windows) can treat drive-letter colons as
  // remote host specifiers. We pass --force-local on Windows and normalize
  // paths to forward slashes for broad tar compatibility.
  const a = archivePath.replaceAll("\\", "/");
  const d = extractDir.replaceAll("\\", "/");
  const baseArgs = ["-xzf", a, "-C", d];
  const firstArgs = process.platform === "win32" ? ["--force-local", ...baseArgs] : baseArgs;
  let res = spawnSync("tar", firstArgs, { encoding: "utf-8" });

  // Some tar implementations may not support --force-local.
  if (process.platform === "win32" && res.status !== 0) {
    res = spawnSync("tar", baseArgs, { encoding: "utf-8" });
  }

  if (res.status !== 0) {
    const stderr = String(res.stderr || res.stdout || "").trim();
    throw new Error(`failed to extract tar.gz archive: ${stderr || "unknown error"}`);
  }
}

/** Detect archive type by extension and extract accordingly. */
export async function extractArchive(archivePath, extractDir) {
  const lower = archivePath.toLowerCase();
  if (lower.endsWith(".zip")) {
    await extractZip(archivePath, extractDir);
    return;
  }
  if (lower.endsWith(".tar.gz") || lower.endsWith(".tgz")) {
    extractTarGz(archivePath, extractDir);
    return;
  }
  throw new Error(`unsupported archive type: ${archivePath}`);
}

// ---------------------------------------------------------------------------
// Binary search
// ---------------------------------------------------------------------------

/**
 * Recursively search `rootDir` for a file matching `matcher`.
 *
 * `matcher` can be:
 * - a string: exact filename match (also tries with `.exe` on Windows)
 * - a function `(entryName, fullPath) => boolean`
 */
export function findFileRecursive(rootDir, matcher) {
  const matchFn =
    typeof matcher === "function"
      ? matcher
      : (entryName) => {
          if (entryName === matcher) return true;
          if (targetPlatform() === "win32" && entryName === `${matcher}.exe`) return true;
          return false;
        };

  const queue = [rootDir];
  while (queue.length > 0) {
    const dir = queue.shift();
    if (!dir) continue;
    for (const entry of listDirSafe(dir)) {
      const full = path.join(dir, entry);
      let st;
      try {
        st = fs.statSync(full);
      } catch {
        continue;
      }
      if (st.isDirectory()) {
        queue.push(full);
        continue;
      }
      if (st.isFile() && matchFn(entry, full)) {
        return full;
      }
    }
  }
  return null;
}

// ---------------------------------------------------------------------------
// GitHub API helpers
// ---------------------------------------------------------------------------

export function ghHeaders(userAgent) {
  const headers = {
    Accept: "application/vnd.github+json",
    "User-Agent": userAgent,
  };
  const token = (process.env.GITHUB_TOKEN || process.env.GH_TOKEN || "").trim();
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }
  return headers;
}
