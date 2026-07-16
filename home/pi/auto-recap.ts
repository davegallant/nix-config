/**
 * Auto-recap extension for pi
 *
 * Approximates Claude Code's automatic "session recap": a one-line summary of
 * where things stand, shown above the input so you can re-orient after stepping
 * away.
 *
 * Claude triggers this when you return to an *unfocused* terminal. pi's
 * extension API does not expose terminal focus events, so this uses an
 * idle-time approximation instead: once the session has been idle long enough
 * (and has enough history), it generates one recap and shows it. The recap is
 * cleared as soon as you start the next turn, and a fresh one can appear after
 * the next idle period — never twice in a row.
 *
 * Generating the recap makes a background model call (using the current model),
 * so it spends tokens. Everything here is best-effort: a failure must never
 * disrupt the session, so all errors are swallowed.
 */

import { complete } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";

// Gate conditions (mirroring Claude's: >=3 min idle, >=3 turns, never twice in a row).
const IDLE_MS = 3 * 60 * 1000;
const MIN_TURNS = 3;
const CHECK_MS = 30 * 1000; // how often the idle timer polls
const WIDGET_ID = "auto-recap";
const MAX_CONTEXT_CHARS = 6000; // cap the transcript slice sent to the model

// Minimal structural view of the session context — just the bits used here.
interface RecapCtx {
  hasUI: boolean;
  model: Parameters<typeof complete>[0] | undefined;
  isIdle?: () => boolean;
  ui: { setWidget: (id: string, content: unknown, opts?: { placement?: string }) => void };
  sessionManager: { getBranch: () => SessionEntry[] };
  modelRegistry: {
    getApiKeyAndHeaders: (
      model: unknown,
    ) => Promise<{ ok: boolean; apiKey?: string; headers?: Record<string, string>; error?: string }>;
  };
}

let ctxRef: RecapCtx | undefined;
let lastTurnEnd = Date.now();
let turnCount = 0;
let recapShown = false; // shown during the current idle period
let generating = false;
let timer: ReturnType<typeof setInterval> | undefined;

type ContentBlock = { type?: string; text?: string; name?: string; arguments?: Record<string, unknown> };
type SessionEntry = { type: string; message?: { role?: string; content?: unknown } };

function extractText(content: unknown): string[] {
  if (typeof content === "string") return [content];
  if (!Array.isArray(content)) return [];
  const out: string[] = [];
  for (const part of content) {
    if (!part || typeof part !== "object") continue;
    const block = part as ContentBlock;
    if (block.type === "text" && typeof block.text === "string") out.push(block.text);
  }
  return out;
}

function buildConversationText(entries: SessionEntry[]): string {
  const sections: string[] = [];
  for (const entry of entries) {
    if (entry.type !== "message" || !entry.message?.role) continue;
    const role = entry.message.role;
    if (role !== "user" && role !== "assistant") continue;
    const text = extractText(entry.message.content).join("\n").trim();
    if (text) sections.push(`${role === "user" ? "User" : "Assistant"}: ${text}`);
  }
  return sections.join("\n\n");
}

const RECAP_PROMPT = (transcript: string): string =>
  [
    "You write a one-line recap of a coding session so the user can re-orient when they return to the terminal.",
    "Read the conversation and output ONE concise line (roughly 16 words or fewer) capturing where things stand and the immediate next step.",
    "No preamble, no markdown, no quotes — just the single line.",
    "",
    "<conversation>",
    transcript,
    "</conversation>",
  ].join("\n");

function clearWidget(): void {
  ctxRef?.ui.setWidget(WIDGET_ID, undefined);
}

async function maybeRecap(): Promise<void> {
  const ctx = ctxRef;
  if (!ctx || generating || recapShown) return;
  if (turnCount < MIN_TURNS) return;
  if (Date.now() - lastTurnEnd < IDLE_MS) return;
  if (typeof ctx.isIdle === "function" && !ctx.isIdle()) return;
  if (!ctx.hasUI) return;

  const model = ctx.model;
  if (!model) return;

  generating = true;
  try {
    const branch = ctx.sessionManager.getBranch() as SessionEntry[];
    let transcript = buildConversationText(branch);
    if (!transcript.trim()) return;
    if (transcript.length > MAX_CONTEXT_CHARS) transcript = transcript.slice(-MAX_CONTEXT_CHARS);

    const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
    if (!auth?.ok || !auth.apiKey) return;

    const response = await complete(
      model,
      {
        messages: [
          { role: "user" as const, content: [{ type: "text" as const, text: RECAP_PROMPT(transcript) }], timestamp: Date.now() },
        ],
      },
      { apiKey: auth.apiKey, headers: auth.headers, reasoningEffort: "low" },
    );

    const recap = response.content
      .filter((c): c is { type: "text"; text: string } => c.type === "text")
      .map((c) => c.text)
      .join(" ")
      .replace(/\s+/g, " ")
      .trim();
    if (!recap) return;

    // Re-check idle: the user may have started typing/working while we waited.
    if (recapShown || (typeof ctx.isIdle === "function" && !ctx.isIdle())) return;

    recapShown = true;
    ctx.ui.setWidget(
      WIDGET_ID,
      (_tui, theme) => new Text(theme.fg("dim", "⟳ ") + theme.fg("muted", recap), 0, 0),
      { placement: "aboveEditor" },
    );
  } catch {
    // Best-effort: never let a recap failure disrupt the session.
  } finally {
    generating = false;
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    ctxRef = ctx as unknown as RecapCtx;
    lastTurnEnd = Date.now();
    turnCount = 0;
    recapShown = false;
    clearWidget();
    if (!timer) timer = setInterval(() => void maybeRecap(), CHECK_MS);
  });

  // User started a new turn — they're back and working, so drop any stale recap.
  pi.on("turn_start", () => {
    clearWidget();
  });

  // A turn finished — reset the idle clock and allow a fresh recap next idle.
  pi.on("turn_end", () => {
    lastTurnEnd = Date.now();
    turnCount += 1;
    recapShown = false;
    clearWidget();
  });
}
