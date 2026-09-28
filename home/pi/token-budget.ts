/**
 * Keep unusually large built-in tool results from dominating every later model
 * request. The tool has already completed; this only shortens the text persisted
 * in conversation context. The marker tells the model how to retrieve more.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { mkdtemp, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

export const MAX_TOOL_RESULT_CHARS = 20_000;

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/** Request concise Responses output without changing reasoning effort. */
export function codexStylePayload(payload: unknown): unknown {
  if (
    !isRecord(payload) ||
    typeof payload.model !== "string" ||
    !/^gpt-(?:5\.6|6)-/.test(payload.model) ||
    !(Array.isArray(payload.input) || typeof payload.input === "string")
  ) {
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

export function shortenToolResult(
  toolName: string,
  text: string,
  fullOutputPath: string,
  limit = MAX_TOOL_RESULT_CHARS,
): string {
  const max = Math.max(0, Math.floor(limit));
  if (!Number.isFinite(limit) || max === 0) return "";
  if (text.length <= max) return text;

  const marker =
    `\n\n[Output shortened. Full tool output: ${JSON.stringify(fullOutputPath)}. ` +
    "Use read with offset/limit to retrieve more.]\n\n";
  if (max <= marker.length) return marker.slice(0, max);

  const available = max - marker.length;
  const headLength = toolName === "bash" ? Math.floor(available / 2) : available;
  const tailLength = toolName === "bash" ? available - headLength : 0;
  // Avoid cutting a UTF-16 surrogate pair at either boundary.
  const head = text.slice(0, headLength).replace(/[\uD800-\uDBFF]$/, "");
  const tail = tailLength ? text.slice(-tailLength).replace(/^[\uDC00-\uDFFF]/, "") : "";
  return `${head}${marker}${tail}`;
}

async function saveToolOutput(toolName: string, text: string): Promise<string> {
  const directory = await mkdtemp(join(tmpdir(), "pi-tool-output-"));
  const fullOutputPath = join(directory, `${toolName}.txt`);
  await writeFile(fullOutputPath, text, { encoding: "utf8", mode: 0o600, flag: "wx" });
  return fullOutputPath;
}

export default function (pi: ExtensionAPI) {
  pi.on("before_provider_request", (event) => codexStylePayload(event.payload));

  pi.on("tool_result", async (event, ctx) => {
    if (event.toolName !== "read" && event.toolName !== "bash") return;

    const text = event.content
      .filter((block): block is { type: "text"; text: string } => block.type === "text")
      .map((block) => block.text)
      .join("\n");
    if (text.length <= MAX_TOOL_RESULT_CHARS) return;

    const details = isRecord(event.details) ? event.details : {};
    let fullOutputPath = typeof details.fullOutputPath === "string" ? details.fullOutputPath : undefined;
    if (!fullOutputPath) {
      try {
        fullOutputPath = await saveToolOutput(event.toolName, text);
      } catch {
        if (ctx.hasUI) ctx.ui.notify("Could not save tool output; keeping the complete result.", "warning");
        return;
      }
    }

    const shortened = shortenToolResult(event.toolName, text, fullOutputPath);
    const content: typeof event.content = [];
    let replacedText = false;
    for (const block of event.content) {
      if (block.type !== "text") {
        content.push(block);
      } else if (!replacedText) {
        content.push({ ...block, text: shortened });
        replacedText = true;
      }
    }

    return { content, details: { ...details, fullOutputPath } };
  });
}
