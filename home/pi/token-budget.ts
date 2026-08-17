/**
 * Keep unusually large built-in tool results from dominating every later model
 * request. The tool has already completed; this only shortens the text persisted
 * in conversation context. The marker tells the model how to retrieve more.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export const MAX_TOOL_RESULT_CHARS = 20_000;

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

export function codexReasoningEffort(modelId: string): "low" | "medium" | undefined {
  if (modelId === "gpt-5.6-sol") return "low";
  if (modelId === "gpt-5.6-luna" || modelId === "gpt-5.6-terra") return "medium";
  return undefined;
}

/** Match Codex's concise GPT-5.6 response defaults without changing effort. */
export function codexStylePayload(payload: unknown): unknown {
  if (!isRecord(payload) || typeof payload.model !== "string" || !payload.model.startsWith("gpt-5.6-")) {
    return payload;
  }

  const text = isRecord(payload.text) ? payload.text : {};
  const result: Record<string, unknown> = { ...payload, text: { ...text, verbosity: "low" } };

  if (isRecord(payload.reasoning)) {
    const { summary: _summary, ...reasoning } = payload.reasoning;
    result.reasoning = reasoning;
  }

  return result;
}

const HEAD_MARKER =
  "\n\n[Result shortened to limit context growth. Use read with offset/limit or rerun a narrower command if more detail is needed.]";
const TAIL_MARKER =
  "[Earlier output omitted to limit context growth. Rerun a narrower command if more detail is needed.]\n\n";

export function shortenToolResult(toolName: string, text: string, limit = MAX_TOOL_RESULT_CHARS): string {
  const max = Math.max(0, Math.floor(limit));
  if (!Number.isFinite(limit) || max === 0) return "";
  if (text.length <= max) return text;

  const marker = toolName === "bash" ? TAIL_MARKER : HEAD_MARKER;
  if (max <= marker.length) return marker.slice(0, max);

  const available = max - marker.length;
  return toolName === "bash"
    ? `${marker}${text.slice(-available)}`
    : `${text.slice(0, available)}${marker}`;
}

export default function (pi: ExtensionAPI) {
  pi.on("model_select", (event) => {
    const effort = codexReasoningEffort(event.model.id);
    if (effort) pi.setThinkingLevel(effort);
  });

  pi.on("before_provider_request", (event) => codexStylePayload(event.payload));

  pi.on("tool_result", (event) => {
    if (event.toolName !== "read" && event.toolName !== "bash") return;

    const text = event.content
      .filter((block): block is { type: "text"; text: string } => block.type === "text")
      .map((block) => block.text)
      .join("\n");
    if (text.length <= MAX_TOOL_RESULT_CHARS) return;

    return {
      content: [{ type: "text" as const, text: shortenToolResult(event.toolName, text) }],
    };
  });
}
