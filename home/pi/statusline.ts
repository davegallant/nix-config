/**
 * Statusline extension for pi
 *
 * Replaces the default footer with a coloured statusline that mirrors the
 * Claude Code statusline (see home/claude/statusline-command.sh):
 *
 *   repo (main)  gpt-5.5  [▓▓▓░░░░░░░] 34%/200k
 *
 * Left to right:
 *   - Repo name (accent) and git branch (muted, in parens)
 *   - Model id (dim)
 *   - Context progress bar: green → yellow → red as the window fills up,
 *     with filled (▓) and empty (░) blocks plus a percentage and limit.
 *
 * Context usage is read fresh on every render via ctx.getContextUsage().
 * A turn_end hook triggers an explicit requestRender() so the bar updates
 * immediately after each assistant reply.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";
import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

// Width (in block characters) of the filled+empty portion of the bar.
const BAR_WIDTH = 10;

// OpenRouter credit balance, shown only for OpenRouter models and refreshed
// at most every CREDIT_REFRESH_MS.
const CREDIT_REFRESH_MS = 5 * 60 * 1000;
let credit: number | undefined;
let creditFetchedAt = 0;
let creditInFlight = false;

// OPENROUTER_API_KEY, falling back to the key pi stores from /login.
function openRouterKey(): string | undefined {
  if (process.env.OPENROUTER_API_KEY) return process.env.OPENROUTER_API_KEY;
  try {
    const auth = JSON.parse(readFileSync(join(homedir(), ".pi/agent/auth.json"), "utf8"));
    return auth?.openrouter?.key || undefined;
  } catch {
    return undefined;
  }
}

async function refreshCredit(ctx: { model?: { provider?: string } }): Promise<void> {
  if (ctx.model?.provider !== "openrouter") return;
  if (creditInFlight || Date.now() - creditFetchedAt < CREDIT_REFRESH_MS) return;
  const key = openRouterKey();
  if (!key) return;
  creditInFlight = true;
  creditFetchedAt = Date.now();
  try {
    const res = await fetch("https://openrouter.ai/api/v1/credits", {
      headers: { Authorization: `Bearer ${key}` },
      signal: AbortSignal.timeout(5000),
    });
    if (!res.ok) return;
    const { data } = await res.json();
    const balance = Number(data.total_credits) - Number(data.total_usage);
    if (Number.isFinite(balance)) credit = balance;
    activeTui?.requestRender();
  } catch {
    // Keep the last known balance.
  } finally {
    creditInFlight = false;
  }
}

// Stored so the turn_end hook can trigger a re-render from outside the footer closure.
let activeTui: { requestRender(): void } | undefined;

export default function (pi: ExtensionAPI) {
  // After each assistant turn the context usage changes – refresh the bar.
  pi.on("turn_end", (_event, ctx) => {
    activeTui?.requestRender();
    void refreshCredit(ctx);
  });

  // Switching to an OpenRouter model fetches the balance right away.
  pi.on("model_select", (_event, ctx) => {
    void refreshCredit(ctx);
    activeTui?.requestRender();
  });

  function installFooter(ctx: Parameters<Parameters<typeof pi.on<"session_start">>[1]>[1]) {
    ctx.ui.setFooter((tui, theme, footerData) => {
      activeTui = tui;
      const unsub = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: unsub,
        invalidate() {},
        render(width: number): string[] {
          // --- Context window progress bar ---
          const usage = ctx.getContextUsage();
          const contextWindow = usage?.contextWindow ?? ctx.model?.contextWindow;
          let ctxBar: string;

          if (!usage || usage.percent === null || !contextWindow) {
            ctxBar = theme.fg("dim", "[" + "░".repeat(BAR_WIDTH) + "] ?");
          } else {
            const pct = Math.max(0, Math.min(100, usage.percent));
            const filled = Math.round((pct / 100) * BAR_WIDTH);
            const empty = BAR_WIDTH - filled;
            // Green up to 50 %, yellow 50–75 %, red above 75 %.
            const barColor = pct >= 75 ? "error" : pct >= 50 ? "warning" : "success";
            const filledBlocks = theme.fg(barColor, "▓".repeat(filled));
            const emptyBlocks = theme.fg("dim", "░".repeat(empty));
            const pctLabel = theme.fg(barColor, `${Math.round(pct)}%`);
            const fmtCtx = (n: number) =>
              n >= 1_000_000 ? `${(n / 1_000_000).toFixed(n % 1_000_000 === 0 ? 0 : 1)}M`
                             : `${(n / 1000).toFixed(0)}k`;
            const limitLabel = theme.fg("dim", `/${fmtCtx(contextWindow)}`);
            ctxBar = `[${filledBlocks}${emptyBlocks}] ${pctLabel}${limitLabel}`;
          }

          // --- Left side: repo · branch · model · bar ---
          const modelId = ctx.model?.id ?? "no model";
          const cwd = process.cwd();
          const repoName = cwd.split("/").at(-1) || cwd;
          const branch = footerData.getGitBranch();
          const branchStr = branch
            ? " " + theme.fg("muted", `(${branch})`)
            : "";
          const repoStr = theme.fg("accent", repoName) + branchStr;
          const modelStr = theme.fg("dim", modelId);

          // --- OpenRouter credit balance (hidden until fetched) ---
          let creditStr = "";
          if (ctx.model?.provider === "openrouter" && credit !== undefined) {
            const color = credit < 1 ? "error" : credit < 5 ? "warning" : "success";
            creditStr = `  ${theme.fg(color, `$${credit.toFixed(2)}`)}`;
          }

          const line = ` ${repoStr}  ${modelStr}${creditStr}  ${ctxBar}`;
          return [truncateToWidth(line, width)];
        },
      };
    });
  }

  // Install on every session start (covers startup, new, resume, fork, reload).
  pi.on("session_start", async (_event, ctx) => {
    installFooter(ctx);
    void refreshCredit(ctx);
  });
}
