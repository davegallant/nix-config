/**
 * Statusline extension for pi
 *
 * Replaces the default footer with a coloured statusline:
 *
 *   repo (main)  $0.123  [████████░░] 78%/200k
 *
 * Left side:
 *   - Repo name (muted) and git branch (success colour)
 *   - Cost (success colour)
 *   - Context progress bar: green → yellow → red as the window fills up,
 *     with filled (█) and empty (░) blocks plus a numeric percentage.
 *
 * Context usage is read fresh on every render via ctx.getContextUsage().
 * A turn_end hook triggers an explicit requestRender() so the bar updates
 * immediately after each assistant reply.
 *
 * Cost is the client-side token × rate calculation summed over the session
 * branch.
 */

import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { truncateToWidth } from "@mariozechner/pi-tui";

// Width (in block characters) of the filled+empty portion of the bar.
const BAR_WIDTH = 10;

// Stored so the turn_end hook can trigger a re-render from outside the footer closure.
let activeTui: { requestRender(): void } | undefined;

export default function (pi: ExtensionAPI) {
  // After each assistant turn the context usage changes – refresh the bar.
  pi.on("turn_end", () => {
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
          // --- Cost (from session branch) ---
          let input = 0;
          let output = 0;
          let cost = 0;
          for (const entry of ctx.sessionManager.getBranch()) {
            if (entry.type === "message" && entry.message.role === "assistant") {
              const m = entry.message as AssistantMessage;
              input += m.usage.input;
              output += m.usage.output;
              cost += m.usage.cost.total;
            }
          }

          const fmt = (n: number) =>
            n === 0 ? "0" : n < 1000 ? `${n}` : n >= 1_000_000 ? `${(n / 1_000_000).toFixed(1)}M` : `${(n / 1000).toFixed(1)}k`;

          const inputStr = theme.fg("accent", "↑") + theme.fg("muted", fmt(input));
          const outputStr = theme.fg("accent", "↓") + theme.fg("muted", fmt(output));
          const costStr = theme.fg("success", `$${cost.toFixed(3)}`);

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
            const filledBlocks = theme.fg(barColor, "█".repeat(filled));
            const emptyBlocks = theme.fg("dim", "░".repeat(empty));
            const pctLabel = theme.fg(barColor, `${Math.round(pct)}%`);
            const fmtCtx = (n: number) =>
              n >= 1_000_000 ? `${(n / 1_000_000).toFixed(n % 1_000_000 === 0 ? 0 : 1)}M`
                             : `${(n / 1000).toFixed(0)}k`;
            const limitLabel = theme.fg("dim", `/${fmtCtx(contextWindow)}`);
            ctxBar = `[${filledBlocks}${emptyBlocks}] ${pctLabel}${limitLabel}`;
          }

          // --- Left side: repo · branch · model · cost · bar ---
          const modelId = ctx.model?.id ?? "no model";
          const cwd = process.cwd();
          const repoName = cwd.split("/").at(-1) || cwd;
          const branch = footerData.getGitBranch();
          const branchStr = branch
            ? " " + theme.fg("accent", `(${branch})`)
            : "";
          const repoStr = theme.fg("muted", repoName) + branchStr;
          const modelStr = theme.fg("dim", modelId);

          const line = ` ${repoStr}  ${modelStr}  ${inputStr} ${outputStr}  ${costStr}  ${ctxBar}`;
          return [truncateToWidth(line, width)];
        },
      };
    });
  }

  // Install on every session start (covers startup, new, resume, fork, reload).
  pi.on("session_start", async (_event, ctx) => {
    installFooter(ctx);
  });
}
