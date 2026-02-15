#!/usr/bin/env node
/**
 * AntiBot launcher — Lume Unbound / Clawd Unbound
 * Uses ~/.antibot/antibot.json for config (separate from ClawdBot/OpenClaw).
 */
import { homedir } from "node:os";
import { join } from "node:path";

process.env.ANTIBOT_STATE_DIR = process.env.ANTIBOT_STATE_DIR || join(homedir(), ".antibot");

await import("./openclaw.mjs");
