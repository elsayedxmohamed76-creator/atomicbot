import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const projectRoot = path.resolve(__dirname, "..");
const releaseDir = path.join(projectRoot, "release");
const packageJsonPath = path.join(projectRoot, "package.json");

function generate() {
  if (!fs.existsSync(releaseDir)) {
    console.error(`Error: Release directory not found at ${releaseDir}`);
    process.exit(1);
  }

  const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf-8"));
  const version = packageJson.version;

  const files = fs.readdirSync(releaseDir);
  const versionBase = `Atomic-Bot-${version}`;
  const candidates = files
    .filter(f => f.endsWith("-win.exe") && f.includes(version) && !f.startsWith("Uninstall"))
    .map(f => ({
      name: f,
      path: path.join(releaseDir, f),
      mtime: fs.statSync(path.join(releaseDir, f)).mtimeMs
    }))
    .sort((a, b) => b.mtime - a.mtime);

  if (candidates.length === 0) {
    console.error(`Error: No installer found matching pattern "*${version}*-win.exe" in release directory.`);
    process.exit(1);
  }

  const selected = candidates[0];
  if (candidates.length > 1) {
    console.log(`Note: Found ${candidates.length} candidates, selecting newest by mtime: ${selected.name}`);
  }

  const exeFile = selected.name;
  const exePath = selected.path;
  const fileBuffer = fs.readFileSync(exePath);
  const sha512 = crypto.createHash("sha512").update(fileBuffer).digest("base64");
  const size = fs.statSync(exePath).size;
  const releaseDate = new Date().toISOString();

  const yamlContent = `version: ${version}
files:
  - url: ${exeFile}
    sha512: ${sha512}
    size: ${size}
path: ${exeFile}
sha512: ${sha512}
releaseDate: '${releaseDate}'
`;

  const latestYmlPath = path.join(releaseDir, "latest.yml");
  fs.writeFileSync(latestYmlPath, yamlContent);

  console.log(`Generated ${latestYmlPath}:`);
  console.log(yamlContent);
}

generate();
