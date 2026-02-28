import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const rootPath = path.resolve(here, "../node_modules/node-pty");

function patchGypi(filePath) {
  if (!fs.existsSync(filePath)) return;
  let content = fs.readFileSync(filePath, "utf8");
  if (!content.includes('SpectreMitigation')) {
    content = content.replace(
      /'target_defaults': {/,
      `'target_defaults': {
      'msbuild_settings': {
        'ClCompile': { 'SpectreMitigation': 'false' },
        'Link': { 'SpectreMitigation': 'false' }
      },`
    );
    fs.writeFileSync(filePath, content);
    console.log("Patched", filePath, "to disable Spectre Mitigation");
  }
}

function walk(dir) {
  if (!fs.existsSync(dir)) return;
  const list = fs.readdirSync(dir);
  for (const file of list) {
    const full = path.join(dir, file);
    if (fs.statSync(full).isDirectory()) {
      walk(full);
    } else if (file.endsWith(".gyp") || file.endsWith(".gypi")) {
      patchGypi(full);
    }
  }
}

console.log("Patching node-pty to disable MSMSBuild SpectreMitigation requirement...");
walk(rootPath);
