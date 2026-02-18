#!/usr/bin/env node
/**
 * Quick test: send "hi" to the local model via gateway WebSocket.
 * Run from repo root: node scripts/test-chat-local.mjs
 * Requires: gateway on 18889, Ollama with lume-llama-unbound.
 * First inference can take 30-90 seconds on CPU.
 * Token: OPENCLAW_GATEWAY_TOKEN or read from ~/.antibot/antibot.json
 */
import WebSocket from "ws";
import { randomUUID } from "node:crypto";
import { readFileSync } from "node:fs";
import { join } from "node:path";

const PORT = 18889;
const WS_URL = `ws://127.0.0.1:${PORT}`;

function getToken() {
  const env = process.env.OPENCLAW_GATEWAY_TOKEN || process.env.ANTIBOT_GATEWAY_TOKEN;
  if (env) return env;
  const stateDir = process.env.ANTIBOT_STATE_DIR || join(process.env.HOME || process.env.USERPROFILE || "", ".antibot");
  try {
    const cfg = JSON.parse(readFileSync(join(stateDir, "antibot.json"), "utf8"));
    const t = cfg?.gateway?.auth?.token;
    if (typeof t === "string" && t.trim()) return t.trim();
  } catch {}
  return null;
}

async function connectAndSend() {
  const token = getToken();
  const ws = new WebSocket(WS_URL, { headers: { origin: `http://127.0.0.1:${PORT}` } });
  await new Promise((resolve, reject) => {
    ws.once("open", resolve);
    ws.once("error", reject);
    const t = setTimeout(() => reject(new Error("WebSocket open timeout")), 10000);
    ws.once("open", () => clearTimeout(t));
  });

  const idempotencyKey = randomUUID();
  const connectId = randomUUID();

  const connectParams = {
    client: {
      id: "antibot-test-script",
      version: "1.0.0",
      platform: "node",
      mode: "webchat",
    },
    ...(token ? { auth: { token, password: token } } : {}),
  };

  // Connect frame (required before any RPC)
  ws.send(
    JSON.stringify({
      type: "req",
      id: connectId,
      method: "connect",
      params: connectParams,
    }),
  );

  const connectRes = await new Promise((resolve, reject) => {
    const handler = (data) => {
      try {
        const msg = JSON.parse(data.toString());
        if (msg.id === connectId) {
          ws.off("message", handler);
          resolve(msg);
        }
      } catch {}
    };
    ws.on("message", handler);
    setTimeout(() => {
      ws.off("message", handler);
      reject(new Error("connect response timeout"));
    }, 5000);
  });

  if (!connectRes.ok) {
    console.error("Connect failed:", connectRes.error?.message ?? connectRes);
    ws.close();
    process.exit(1);
  }
  console.log("Connected.");

  // chat.send
  ws.send(
    JSON.stringify({
      type: "req",
      id: "chat-send-1",
      method: "chat.send",
      params: {
        sessionKey: "main",
        message: "hi",
        idempotencyKey,
      },
    }),
  );

  const sendRes = await new Promise((resolve, reject) => {
    const handler = (data) => {
      try {
        const msg = JSON.parse(data.toString());
        if (msg.id === "chat-send-1") {
          ws.off("message", handler);
          resolve(msg);
        }
      } catch {}
    };
    ws.on("message", handler);
    setTimeout(() => {
      ws.off("message", handler);
      reject(new Error("chat.send response timeout"));
    }, 10000);
  });

  if (!sendRes.ok) {
    console.error("chat.send failed:", sendRes.error?.message ?? sendRes);
    ws.close();
    process.exit(1);
  }
  console.log("chat.send acked:", sendRes.payload?.runId ?? sendRes.payload);

  // Wait for chat events (delta/final)
  let gotFinal = false;
  const deadline = Date.now() + 120_000; // 2 min for first inference
  await new Promise((resolve, reject) => {
    const handler = (data) => {
      try {
        const msg = JSON.parse(data.toString());
        if (msg.type === "evt" && msg.channel === "chat") {
          const evt = msg.payload;
          if (evt?.state === "delta" && evt?.message?.content) {
            const text = evt.message.content.find((c) => c.type === "text")?.text;
            if (text) process.stdout.write(text);
          }
          if (evt?.state === "final") {
            gotFinal = true;
            ws.off("message", handler);
            resolve();
          }
          if (evt?.state === "error") {
            ws.off("message", handler);
            reject(new Error(evt.errorMessage ?? "chat error"));
          }
        }
      } catch {}
    };
    ws.on("message", handler);
    const check = () => {
      if (gotFinal) return;
      if (Date.now() > deadline) {
        ws.off("message", handler);
        reject(new Error("Timeout waiting for model reply (first inference can take 60-90s on CPU)"));
      } else {
        setTimeout(check, 1000);
      }
    };
    setTimeout(check, 1000);
  });

  console.log("\nDone.");
  ws.close();
}

connectAndSend().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
