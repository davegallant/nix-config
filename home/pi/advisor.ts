/**
 * Advisor extension for pi
 *
 * Approximates Claude Code's `advisor` tool: a second opinion from a stronger,
 * more expensive model that sees a bounded transcript of the active session —
 * not just what the main model chooses to summarise.
 *
 * Use the advisor selectively for consequential, uncertain, or stalled work:
 *
 *   1. The transcript. The advisor sees recent work plus selectively elided
 *      older tool output, so it can catch "you concluded X but the grep you
 *      ran actually said Y" without replaying an unbounded session.
 *   2. The invocation policy. Registering a tool is not enough — the model has
 *      to know *when* to reach for it. That lives in `promptGuidelines`, which
 *      pi appends to the system prompt's Guidelines section while the tool is
 *      active.
 *
 * Cost: one call to the advisor model per invocation, billed on top of the
 * session model. The call reports its `usage` back to pi so the spend shows up
 * in the statusline rather than vanishing. The tool refuses to run when the
 * advisor model *is* the session model, which would be the priciest call in the
 * session in exchange for self-critique — see `collidesWithSession`.
 *
 * Which model plays advisor is configurable — see ADVISOR CONFIG below.
 */

import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { AutocompleteItem } from "@earendil-works/pi-tui";
import { Type } from "typebox";

// ---------------------------------------------------------------------------
// ADVISOR CONFIG
//
// Resolution order, highest priority first:
//   1. PI_ADVISOR_PROVIDER / PI_ADVISOR_MODEL / PI_ADVISOR_EFFORT env vars
//      — declarative pinning (e.g. from the nix wrapper). Not runtime-editable.
//   2. ~/.pi/agent/advisor.json — written by `/advisor-model <provider/model>`.
//      Deliberately not nix-managed, so it stays writable.
//   3. The defaults below.
//
// Switching providers is just a different provider/model pair; nothing else
// in this file assumes a vendor.
// ---------------------------------------------------------------------------

/** Structural subsets of pi's Model / UI context — narrow enough to keep these
 *  helpers testable without dragging in the SDK types. */
type ModelRef = { provider: string; id: string };
type NotifyUI = { notify(message: string, type?: "info" | "warning" | "error"): void };

const REASONING_EFFORTS = new Set(["off", "minimal", "low", "medium", "high", "xhigh", "max"]);
type ReasoningEffort = "off" | "minimal" | "low" | "medium" | "high" | "xhigh" | "max";

interface AdvisorConfig {
  provider: string;
  model: string;
  reasoningEffort: ReasoningEffort;
  maxTranscriptChars: number;
  maxCallsPerSession: number;
  allowSameModel: boolean;
}

const DEFAULTS: AdvisorConfig = {
  provider: "openai-codex",
  model: "gpt-5.6-sol",
  reasoningEffort: "low",
  // Keep consultations focused on the active work and bounded in cost.
  maxTranscriptChars: 32_000,
  // A repeated full-transcript review is both expensive and usually redundant.
  maxCallsPerSession: 2,
  // Refuse to consult the model already running the session. Config-file only
  // (like maxTranscriptChars); set true to allow the call anyway.
  allowSameModel: false,
};

const CONFIG_PATH = path.join(os.homedir(), ".pi", "agent", "advisor.json");

const MIN_TRANSCRIPT_CHARS = 4_000;
const MAX_TRANSCRIPT_CHARS = 200_000;
const MAX_ADVISOR_CALLS = 20;
const MAX_TOOL_RESULT_CHARS = 3000; // per result, middle-elided
const MAX_THINKING_CHARS = 2000; // per thinking block
const MAX_TOOL_ARGS_CHARS = 800; // per tool call

function boundedInteger(value: unknown, min: number, max: number): number | undefined {
  if (typeof value !== "number" || !Number.isFinite(value)) return undefined;
  return Math.min(max, Math.max(min, Math.trunc(value)));
}

function nonEmptyString(value: unknown): string | undefined {
  return typeof value === "string" && value.trim() ? value.trim() : undefined;
}

function reasoningEffort(value: unknown): ReasoningEffort | undefined {
  return typeof value === "string" && REASONING_EFFORTS.has(value) ? (value as ReasoningEffort) : undefined;
}

function readConfigFile(): Partial<AdvisorConfig> {
  try {
    const parsed = JSON.parse(fs.readFileSync(CONFIG_PATH, "utf-8"));
    if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) return {};

    const raw = parsed as Record<string, unknown>;
    const config: Partial<AdvisorConfig> = {};
    const provider = nonEmptyString(raw.provider);
    const model = nonEmptyString(raw.model);
    const effort = reasoningEffort(raw.reasoningEffort);
    const transcriptChars = boundedInteger(raw.maxTranscriptChars, MIN_TRANSCRIPT_CHARS, MAX_TRANSCRIPT_CHARS);
    const calls = boundedInteger(raw.maxCallsPerSession, 0, MAX_ADVISOR_CALLS);

    if (provider) config.provider = provider;
    if (model) config.model = model;
    if (effort) config.reasoningEffort = effort;
    if (transcriptChars !== undefined) config.maxTranscriptChars = transcriptChars;
    if (calls !== undefined) config.maxCallsPerSession = calls;
    if (typeof raw.allowSameModel === "boolean") config.allowSameModel = raw.allowSameModel;
    return config;
  } catch {
    return {}; // absent or malformed — fall through to defaults
  }
}

function envConfig(): Partial<AdvisorConfig> {
  const env: Partial<AdvisorConfig> = {};
  const provider = nonEmptyString(process.env.PI_ADVISOR_PROVIDER);
  const model = nonEmptyString(process.env.PI_ADVISOR_MODEL);
  const effort = reasoningEffort(process.env.PI_ADVISOR_EFFORT);
  if (provider) env.provider = provider;
  if (model) env.model = model;
  if (effort) env.reasoningEffort = effort;
  return env;
}

function loadConfig(): AdvisorConfig {
  return { ...DEFAULTS, ...readConfigFile(), ...envConfig() };
}

/** True when the env has pinned the model, making /advisor-model a no-op. */
function pinnedByEnv(): boolean {
  return !!(process.env.PI_ADVISOR_PROVIDER || process.env.PI_ADVISOR_MODEL);
}

function saveConfig(provider: string, model: string): void {
  const merged = { ...readConfigFile(), provider, model };
  fs.mkdirSync(path.dirname(CONFIG_PATH), { recursive: true });
  fs.writeFileSync(CONFIG_PATH, `${JSON.stringify(merged, null, 2)}\n`);
}

/**
 * A user can opt out of same-model consultations in advisor.json. Compared on
 * provider and id so one model behind separate gateways remains distinct. An
 * undefined ctx.model fails open because some run modes do not populate it.
 */
function collidesWithSession(config: AdvisorConfig, current: ModelRef | undefined): boolean {
  if (config.allowSameModel || !current) return false;
  return current.provider === config.provider && current.id === config.model;
}

/**
 * Announce a collision at the moment it becomes true — on Ctrl+P, on
 * /advisor-model, and at session start for a collision persisted in
 * advisor.json — so it is never discovered halfway through a task.
 */
function warnIfCollides(ui: NotifyUI, current: ModelRef | undefined): void {
  const config = loadConfig();
  if (!collidesWithSession(config, current)) return;
  ui.notify(
    `Advisor disabled: ${config.provider}/${config.model} is both the session model and the advisor model. Switch either one to re-enable it.`,
    "warning",
  );
}

/**
 * Addressed to the model, not the user: promptGuidelines tells it to consult the
 * advisor before substantive work and again at the end, so a collision would
 * otherwise fail every call for the whole session. Hence the explicit "do not
 * retry" and the two concrete ways out.
 */
function collisionError(config: AdvisorConfig): Error {
  return new Error(
    `Advisor is unavailable this session: the advisor model (${config.provider}/${config.model}) is the model you are already running on, ` +
      `so consulting it would re-send this transcript uncached for no cross-model review. Do not retry. ` +
      `Proceed without advice, or ask the user to switch session models (Ctrl+P) or run /advisor-model <provider/model>.`,
  );
}

// ---------------------------------------------------------------------------
// Transcript construction
// ---------------------------------------------------------------------------

type ContentBlock = {
  type?: string;
  text?: string;
  thinking?: string;
  name?: string;
  arguments?: Record<string, unknown>;
};

type AgentMessage = {
  role?: string;
  content?: unknown;
  toolName?: string;
  isError?: boolean;
};

type SessionEntry = { type: string; message?: AgentMessage };

// A transcript is a list of sections so the budget pass can shrink tool
// results selectively instead of tail-slicing the whole conversation.
export interface Section {
  isToolResult: boolean;
  text: string;
}

/** Middle-elide to an exact maximum, keeping the signal-rich head and tail. */
export function elide(text: string, max: number): string {
  const limit = Math.max(0, Math.floor(max));
  if (text.length <= limit) return text;

  const marker = "\n… [elided] …\n";
  if (limit <= marker.length) return text.slice(0, limit);

  const kept = limit - marker.length;
  const head = Math.floor(kept * 0.7);
  const tail = kept - head;
  return `${text.slice(0, head)}${marker}${text.slice(-tail)}`;
}

function blocks(content: unknown): ContentBlock[] {
  if (typeof content === "string") return [{ type: "text", text: content }];
  if (!Array.isArray(content)) return [];
  return content.filter((b): b is ContentBlock => !!b && typeof b === "object");
}

function textOf(content: unknown): string {
  return blocks(content)
    .filter((b) => b.type === "text" && typeof b.text === "string")
    .map((b) => b.text as string)
    .join("\n")
    .trim();
}

function buildSections(entries: SessionEntry[]): Section[] {
  const sections: Section[] = [];

  for (const entry of entries) {
    if (entry.type !== "message" || !entry.message?.role) continue;
    const msg = entry.message;

    if (msg.role === "user") {
      const text = textOf(msg.content);
      if (text) sections.push({ isToolResult: false, text: `## User\n${text}` });
      continue;
    }

    if (msg.role === "assistant") {
      const parts: string[] = [];
      for (const block of blocks(msg.content)) {
        if (block.type === "text" && block.text?.trim()) {
          parts.push(block.text.trim());
        } else if (block.type === "thinking" && block.thinking?.trim()) {
          parts.push(`[reasoning] ${elide(block.thinking.trim(), MAX_THINKING_CHARS)}`);
        } else if (block.type === "toolCall") {
          const args = elide(JSON.stringify(block.arguments ?? {}), MAX_TOOL_ARGS_CHARS);
          parts.push(`→ calls ${block.name}(${args})`);
        }
      }
      if (parts.length) sections.push({ isToolResult: false, text: `## Assistant\n${parts.join("\n")}` });
      continue;
    }

    if (msg.role === "toolResult") {
      const text = elide(textOf(msg.content), MAX_TOOL_RESULT_CHARS);
      const label = `## Tool result: ${msg.toolName ?? "unknown"}${msg.isError ? " (ERROR)" : ""}`;
      sections.push({ isToolResult: true, text: `${label}\n${text || "(no output)"}` });
    }
  }

  return sections;
}

function totalChars(sections: Section[]): number {
  return sections.reduce((sum, s) => sum + s.text.length + 2, 0);
}

function advisorCallCount(entries: SessionEntry[]): number {
  return entries.filter(
    (entry) => entry.type === "message" && entry.message?.role === "toolResult" && entry.message.toolName === "advisor",
  ).length;
}

/**
 * Fit the transcript to budget by degrading the least valuable material first:
 * oldest tool results get stubbed out, and only if that is not enough do whole
 * sections drop off the front. The most recent exchanges always survive — they
 * are the ones the advice is actually about.
 */
export function fitToBudget(sections: Section[], budget: number): Section[] {
  const limit = Math.max(0, Math.floor(budget));
  if (!Number.isFinite(budget) || limit <= 2) return [];

  const result = [...sections];

  for (let i = 0; i < result.length && totalChars(result) > limit; i++) {
    const section = result[i];
    if (!section.isToolResult) continue;
    const firstLine = section.text.split("\n", 1)[0];
    result[i] = { ...section, text: `${firstLine}\n[older tool result elided to fit context]` };
  }

  while (result.length > 1 && totalChars(result) > limit) {
    result.shift();
  }

  if (result.length === 1 && totalChars(result) > limit) {
    result[0] = { ...result[0], text: elide(result[0].text, limit - 2) };
  }

  return result;
}

// ---------------------------------------------------------------------------
// Prompts
// ---------------------------------------------------------------------------

const ADVISOR_SYSTEM = [
  "You are a senior engineer advising another AI coding agent mid-task.",
  "You are shown a bounded transcript of the agent's active session: the user's request, its reasoning, tool calls, and the most relevant results.",
  "",
  "Your job is to improve the outcome, not to praise the work. Prioritise:",
  "  1. Errors of fact — claims the agent made that its own tool output contradicts.",
  "  2. Errors of approach — a plan that will not survive contact with the real constraints.",
  "  3. Omissions — the load-bearing case, failure mode, or requirement not yet considered.",
  "  4. Scope — work being invented that nobody asked for, or asked-for work quietly dropped.",
  "",
  "Ground every point in specific evidence from the transcript; cite the file, command, or output you are reacting to.",
  "Be concise and direct. Lead with what matters most. Skip preamble, flattery, and restating the task.",
  "If the agent's approach is sound, say so briefly and spend your words on the sharpest remaining risk.",
  "If you lack the evidence to judge something, say what you would need rather than guessing.",
  "",
  "The transcript may contain your own advice from an earlier consultation, appearing as an advisor tool result. It was written with less information than you have now — treat it as revisable, not as an authority to agree with.",
].join("\n");

const ADVISOR_PROMPT = (transcript: string): string =>
  [
    "Here is a bounded transcript of the agent session you are advising.",
    "",
    "<transcript>",
    transcript,
    "</transcript>",
    "",
    "Give your advice now.",
  ].join("\n");

// ---------------------------------------------------------------------------

// Captured at session start so command autocompletion can list real models
// (getArgumentCompletions has no ctx of its own).
let availableModels: { provider: string; id: string }[] = [];

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    try {
      // Awaited because the SDK exposes this as async (examples/sdk/02-custom-model.ts:24);
      // awaiting a plain array is harmless if the extension-side call is sync.
      availableModels = ((await ctx.modelRegistry.getAvailable()) as { provider: string; id: string }[]) ?? [];
    } catch {
      availableModels = []; // completions degrade to none; the tool itself still works
    }
    // Outside the try: advisor.json outlives the session, so a collision saved
    // by a previous /advisor-model is worth reporting even if the catch fired.
    warnIfCollides(ctx.ui, ctx.model);
  });

  // Ctrl+P can switch the session to the advisor model, so warn on the switch
  // rather than on the first failed consultation. event.model is used over
  // ctx.model because this fires as the selection is applied.
  pi.on("model_select", (event, ctx) => {
    warnIfCollides(ctx.ui, event.model);
  });

  pi.registerCommand("advisor-model", {
    description: "Show or set the model the advisor tool consults",
    getArgumentCompletions: (prefix: string): AutocompleteItem[] | null => {
      const items = availableModels
        .map((m) => ({ value: `${m.provider}/${m.id}`, label: `${m.provider}/${m.id}` }))
        .filter((i) => i.value.startsWith(prefix));
      return items.length > 0 ? items : null;
    },
    handler: async (args, ctx) => {
      const target = (args ?? "").trim();
      const config = loadConfig();

      if (!target) {
        const source = pinnedByEnv() ? "env" : fs.existsSync(CONFIG_PATH) ? CONFIG_PATH : "built-in default";
        ctx.ui.notify(`Advisor: ${config.provider}/${config.model} (effort ${config.reasoningEffort}, from ${source})`, "info");
        warnIfCollides(ctx.ui, ctx.model);
        return;
      }

      // Accept "provider/model" or a bare model id resolved against the catalogue.
      const slash = target.indexOf("/");
      let provider: string;
      let model: string;
      if (slash > 0) {
        provider = target.slice(0, slash);
        model = target.slice(slash + 1);
      } else {
        const match = availableModels.find((m) => m.id === target);
        if (!match) {
          ctx.ui.notify(`No model "${target}" in the catalogue. Use provider/model.`, "error");
          return;
        }
        provider = match.provider;
        model = match.id;
      }

      const resolved = ctx.modelRegistry.find(provider, model);
      if (!resolved) {
        ctx.ui.notify(`Model ${provider}/${model} not found.`, "error");
        return;
      }
      if (!ctx.modelRegistry.hasConfiguredAuth(resolved)) {
        ctx.ui.notify(`No authentication configured for ${provider}/${model}.`, "error");
        return;
      }

      saveConfig(provider, model);
      if (pinnedByEnv()) {
        ctx.ui.notify(
          `Saved ${provider}/${model}, but PI_ADVISOR_* is pinning ${config.provider}/${config.model}. Unset it for this to take effect.`,
          "warning",
        );
      } else {
        ctx.ui.notify(`Advisor model set to ${provider}/${model}`, "info");
      }

      // Separate call, not an else-branch: an env pin and a collision can both
      // apply at once (saved X, env pins Y, and Y is the session model).
      // warnIfCollides re-reads the config, so it reports what will actually
      // be consulted rather than what was just requested.
      warnIfCollides(ctx.ui, ctx.model);
    },
  });

  pi.registerTool({
    name: "advisor",
    label: "Advisor",
    description: [
      "Consult a stronger reviewer model that receives a bounded transcript of this session, including the task, recent work, and relevant tool results.",
      "Takes no parameters; it constructs the focused review context automatically.",
      "Returns a second opinion on your approach, factual errors, and blind spots.",
    ].join(" "),
    promptSnippet: "Get a second opinion from a stronger model on the current approach",
    promptGuidelines: [
      "Use advisor only for high-impact decisions, contradictory evidence, or a stalled investigation; at most twice per session.",
      "Do not use advisor for routine, well-understood, small, or already-reviewed work where primary-source evidence determines the next step.",
      "Treat advice as evidence to weigh against the session's primary-source results, not as an authority to follow blindly.",
    ],
    parameters: Type.Object({}),

    async execute(_toolCallId, _params, signal, onUpdate, ctx) {
      const config = loadConfig();

      // Read ctx.model here rather than caching it at session_start: Ctrl+P
      // switches the session model mid-session, which is exactly how a
      // collision becomes reachable.
      if (collidesWithSession(config, ctx.model)) throw collisionError(config);

      const model = ctx.modelRegistry.find(config.provider, config.model);
      if (!model) {
        throw new Error(
          `Advisor model ${config.provider}/${config.model} not found. Set it with /advisor-model <provider/model> or PI_ADVISOR_PROVIDER / PI_ADVISOR_MODEL.`,
        );
      }
      if (!ctx.modelRegistry.hasConfiguredAuth(model)) {
        throw new Error(`No authentication configured for ${config.provider}/${config.model}.`);
      }

      const branch = ctx.sessionManager.getBranch() as SessionEntry[];
      const calls = advisorCallCount(branch);
      if (calls >= config.maxCallsPerSession) {
        return {
          content: [{
            type: "text",
            text:
              `Advisor call limit reached (${calls}/${config.maxCallsPerSession}) for this session. ` +
              "Do not call advisor again; use the existing advice and primary-source evidence.",
          }],
          details: { calls, maxCallsPerSession: config.maxCallsPerSession, skipped: true },
        };
      }

      const sections = fitToBudget(buildSections(branch), config.maxTranscriptChars);
      const transcript = sections.map((s) => s.text).join("\n\n");
      if (!transcript.trim()) {
        throw new Error("No session transcript available to advise on.");
      }

      onUpdate?.({ content: [{ type: "text", text: `Consulting ${config.model}…` }] });

      const response = await ctx.modelRegistry.complete(
        model,
        {
          systemPrompt: ADVISOR_SYSTEM,
          messages: [
            {
              role: "user" as const,
              content: [{ type: "text" as const, text: ADVISOR_PROMPT(transcript) }],
              timestamp: Date.now(),
            },
          ],
        },
        {
          reasoningEffort: config.reasoningEffort,
          // A fresh session id and no cache retention keep this one-shot call
          // from disturbing the main session's prompt cache / affinity.
          cacheRetention: "none",
          sessionId: crypto.randomUUID(),
          signal,
        },
      );

      const advice = response.content
        .filter((c): c is { type: "text"; text: string } => c.type === "text")
        .map((c) => c.text)
        .join("\n")
        .trim();

      if (!advice) throw new Error(`${config.provider}/${config.model} returned no advice.`);

      return {
        content: [{ type: "text", text: advice }],
        details: {
          model: `${config.provider}/${config.model}`,
          transcriptChars: transcript.length,
          sections: sections.length,
        },
        // Report the nested call so its cost lands in the session totals.
        usage: response.usage,
      };
    },
  });
}
