#!/usr/bin/env node

import module from "node:module";
import { spawn } from "node:child_process";
import path from "node:path";
import fs from "node:fs";
import process from "node:process";

// https://nodejs.org/api/module.html#module-compile-cache
if (module.enableCompileCache && !process.env.NODE_DISABLE_COMPILE_CACHE) {
  try {
    module.enableCompileCache();
  } catch {
    // Ignore errors
  }
}

const isModuleNotFoundError = (err) =>
  err && typeof err === "object" && "code" in err && err.code === "ERR_MODULE_NOT_FOUND";

const installProcessWarningFilter = async () => {
  for (const specifier of ["./dist/warning-filter.js", "./dist/warning-filter.mjs"]) {
    try {
      const mod = await import(specifier);
      if (typeof mod.installProcessWarningFilter === "function") {
        mod.installProcessWarningFilter();
        return;
      }
    } catch (err) {
      if (isModuleNotFoundError(err)) continue;
      throw err;
    }
  }
};

await installProcessWarningFilter();

// ClawdBot verbatim: run dist/entry.js in a subprocess (no tsx, no in-process bundle load).
const cwd = process.cwd();
const distEntryJs = path.join(cwd, "dist", "entry.js");
const distEntryMjs = path.join(cwd, "dist", "entry.mjs");
const entryPath = fs.existsSync(distEntryJs) ? distEntryJs : fs.existsSync(distEntryMjs) ? distEntryMjs : null;
if (!entryPath) {
  throw new Error("openclaw: missing dist/entry.(m)js (run pnpm build).");
}

const child = spawn(process.execPath, [entryPath, ...process.argv.slice(2)], {
  stdio: "inherit",
  env: process.env,
  cwd,
});

child.on("exit", (code, signal) => {
  if (signal) process.exit(1);
  process.exit(code ?? 1);
});

child.on("error", (err) => {
  console.error("[openclaw] Failed to run entry:", err?.message ?? err);
  process.exit(1);
});
