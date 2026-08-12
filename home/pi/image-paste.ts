/**
 * Image paste extension for pi
 *
 * Ctrl+V in pi writes the clipboard image to a temp file and inserts its path
 * as plain text (see handleClipboardPaste in pi's bundle). The model only ever
 * sees that path, so it has to spend a `read` tool call to look at the image.
 *
 * This extension closes that gap on submit: any image path in the prompt is
 * read, sniffed by magic bytes, and attached as real image content on the
 * message. Paths to pi's own clipboard temp files are stripped from the text
 * (they're noise); paths you typed yourself are left in place so the agent can
 * still edit/move the underlying file.
 *
 * Deliberately does NOT replace pi's editor component: that's the piece that
 * collides with pi-vimmode and anything else owning the input. The tradeoff is
 * that you see the raw path while typing instead of an [#image 1] placeholder.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFileSync, statSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { isAbsolute, resolve } from "node:path";

// Anything larger is almost certainly not what you meant to paste, and large
// base64 payloads blow through the context window.
const MAX_BYTES = 10 * 1024 * 1024;

// Quoted ("..." / '...') or bare paths, allowing macOS drag-and-drop's
// backslash-escaped spaces.
const IMAGE_PATH_RE =
  /"([^"]+\.(?:png|jpe?g|gif|webp))"|'([^']+\.(?:png|jpe?g|gif|webp))'|((?:[^\s"'\\]|\\.)+\.(?:png|jpe?g|gif|webp))/gi;

// pi names its clipboard scratch files pi-clipboard-<uuid>.<ext> in $TMPDIR.
const CLIPBOARD_TEMP_RE = /(?:^|\/)pi-clipboard-[0-9a-f-]+\.[a-z]+$/i;

type Attachment = { type: "image"; mimeType: string; data: string };

function sniffMimeType(bytes: Buffer): string | undefined {
  if (bytes.length >= 8 && bytes.subarray(0, 8).equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])))
    return "image/png";
  if (bytes.length >= 3 && bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff) return "image/jpeg";
  if (bytes.length >= 4 && bytes.subarray(0, 4).toString("latin1") === "GIF8") return "image/gif";
  if (
    bytes.length >= 12 &&
    bytes.subarray(0, 4).toString("latin1") === "RIFF" &&
    bytes.subarray(8, 12).toString("latin1") === "WEBP"
  )
    return "image/webp";
  return undefined;
}

function resolveCandidate(raw: string, cwd: string): string {
  const unescaped = raw.replace(/\\(.)/g, "$1");
  const expanded = unescaped.startsWith("~/") ? resolve(homedir(), unescaped.slice(2)) : unescaped;
  return isAbsolute(expanded) ? expanded : resolve(cwd, expanded);
}

export default function (pi: ExtensionAPI) {
  pi.on("input", async (event, ctx) => {
    // Messages we injected ourselves must not be reprocessed.
    if (event.source === "extension") return { action: "continue" as const };
    if (!event.text.includes(".")) return { action: "continue" as const };

    const images: Attachment[] = [...((event.images as Attachment[] | undefined) ?? [])];
    const strip: string[] = [];
    const warn = (message: string) => {
      if (ctx.hasUI) ctx.ui.notify(`image-paste: ${message}`, "warning");
    };

    for (const match of event.text.matchAll(IMAGE_PATH_RE)) {
      const raw = match[1] ?? match[2] ?? match[3];
      if (!raw) continue;

      try {
        // Inside the try: a malformed path must never throw out of the handler,
        // which would take the whole input event down with it.
        const path = resolveCandidate(raw, ctx.cwd ?? process.cwd());
        const stat = statSync(path);
        if (!stat.isFile()) continue;
        if (stat.size === 0) continue;
        if (stat.size > MAX_BYTES) {
          warn(`${raw} is ${(stat.size / 1024 / 1024).toFixed(1)}MB, skipping`);
          continue;
        }

        const bytes = readFileSync(path);
        const mimeType = sniffMimeType(bytes);
        if (!mimeType) continue;

        images.push({ type: "image", mimeType, data: bytes.toString("base64") });

        // Clipboard scratch paths are noise to the model; real paths are not.
        if (path.startsWith(tmpdir()) && CLIPBOARD_TEMP_RE.test(path)) strip.push(match[0]);
      } catch {
        // Unreadable or nonexistent: leave the text alone, it may not be a path at all.
      }
    }

    if (images.length === ((event.images as unknown[] | undefined)?.length ?? 0)) {
      return { action: "continue" as const };
    }

    // Warn rather than silently dropping: a text-only model omits images entirely.
    const modelInput = (ctx.model as { input?: string[] } | undefined)?.input;
    if (modelInput && !modelInput.includes("image")) {
      warn(`${ctx.model?.id ?? "current model"} does not accept images`);
    }

    let text = event.text;
    for (const token of strip) text = text.replace(token, "");
    text = text.replace(/[ \t]{2,}/g, " ").trim();

    return { action: "transform" as const, text: text || "(image attached)", images };
  });
}
