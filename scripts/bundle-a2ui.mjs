#!/usr/bin/env node
/**
 * Cross-platform A2UI bundle script (Node-based; works in WSL and Windows).
 */
import { createHash } from "node:crypto";
import { promises as fs } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { createRequire } from "node:module";
import { spawnSync } from "node:child_process";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT_DIR = path.resolve(__dirname, "..");
const require = createRequire(path.join(ROOT_DIR, "package.json"));
const HASH_FILE = path.join(ROOT_DIR, "src/canvas-host/a2ui/.bundle.hash");
const OUTPUT_FILE = path.join(ROOT_DIR, "src/canvas-host/a2ui/a2ui.bundle.js");
const A2UI_RENDERER_DIR = path.join(ROOT_DIR, "vendor/a2ui/renderers/lit");
const A2UI_APP_DIR = path.join(ROOT_DIR, "apps/shared/OpenClawKit/Tools/CanvasA2UI");

async function walk(entryPath, files = []) {
  const st = await fs.stat(entryPath);
  if (st.isDirectory()) {
    const entries = await fs.readdir(entryPath);
    for (const entry of entries) {
      await walk(path.join(entryPath, entry), files);
    }
    return files;
  }
  files.push(entryPath);
  return files;
}

async function computeHash() {
  const inputs = [
    path.join(ROOT_DIR, "package.json"),
    path.join(ROOT_DIR, "pnpm-lock.yaml"),
    A2UI_RENDERER_DIR,
    A2UI_APP_DIR,
  ];
  const files = [];
  for (const input of inputs) {
    try {
      await fs.access(input);
      await walk(input, files);
    } catch {
      // skip missing
    }
  }
  const normalize = (p) => p.split(path.sep).join("/");
  files.sort((a, b) => normalize(path.relative(ROOT_DIR, a)).localeCompare(normalize(path.relative(ROOT_DIR, b))));
  const hash = createHash("sha256");
  for (const filePath of files) {
    const rel = normalize(path.relative(ROOT_DIR, filePath));
    hash.update(rel);
    hash.update("\0");
    hash.update(await fs.readFile(filePath));
    hash.update("\0");
  }
  return hash.digest("hex");
}

async function main() {
  try {
    await fs.access(A2UI_RENDERER_DIR);
    await fs.access(A2UI_APP_DIR);
  } catch {
    if (await fs.access(OUTPUT_FILE).then(() => true).catch(() => false)) {
      console.log("A2UI sources missing; keeping prebuilt bundle.");
      process.exit(0);
    }
    console.error("A2UI sources missing and no prebuilt bundle found at:", OUTPUT_FILE);
    process.exit(1);
  }

  const currentHash = await computeHash();
  let previousHash = null;
  try {
    previousHash = (await fs.readFile(HASH_FILE, "utf8")).trim();
  } catch {
    /* ignore */
  }
  if (previousHash === currentHash) {
    try {
      await fs.access(OUTPUT_FILE);
      console.log("A2UI bundle up to date; skipping.");
      process.exit(0);
    } catch {
      /* rebuild */
    }
  }

  const tscArgs = ["-s", "exec", "tsc", "-p", path.join(A2UI_RENDERER_DIR, "tsconfig.json")];
  const tscResult = spawnSync("pnpm", tscArgs, {
    cwd: ROOT_DIR,
    stdio: "inherit",
  });
  if (tscResult.status !== 0) {
    console.error("A2UI bundling failed at tsc step. Re-run with: pnpm canvas:a2ui:bundle");
    process.exit(1);
  }

  const rolldownArgs = ["-s", "exec", "rolldown", "-c", path.join(A2UI_APP_DIR, "rolldown.config.mjs")];
  const rolldownResult = spawnSync("pnpm", rolldownArgs, {
    cwd: ROOT_DIR,
    stdio: "inherit",
  });
  if (rolldownResult.status !== 0) {
    console.error("A2UI bundling failed at rolldown step. Re-run with: pnpm canvas:a2ui:bundle");
    process.exit(1);
  }

  await fs.mkdir(path.dirname(HASH_FILE), { recursive: true });
  await fs.writeFile(HASH_FILE, currentHash, "utf8");
  console.log("A2UI bundle complete.");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
