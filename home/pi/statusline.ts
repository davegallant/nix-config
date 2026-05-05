/**
 * Statusline extension for pi
 *
 * Replaces the default footer with a statusline similar to Claude Code's:
 *
 *   ↑123.4k ↓45.6k $0.123   claude-sonnet-4-6 (main)
 *
 * Left side : cumulative token usage and cost for the current session branch.
 * Right side: active model ID and git branch.
 *
 * The footer's render function closes over ctx, so token counts and model info
 * are always read fresh on each TUI redraw. The git branch subscription
 * triggers an explicit requestRender() when the branch changes.
 */

import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

export default function (pi: ExtensionAPI) {
  function installFooter(ctx: Parameters<Parameters<typeof pi.on<"session_start">>[1]>[1]) {
    ctx.ui.setFooter((tui, theme, footerData) => {
      const unsub = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: unsub,
        invalidate() {},
        render(width: number): string[] {
          // Accumulate token usage + cost from all assistant messages on the branch.
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
            n === 0 ? "0" : n < 1000 ? `${n}` : `${(n / 1000).toFixed(1)}k`;

          // Left: token stats + cost
          const tokenStr = `↑${fmt(input)} ↓${fmt(output)}`;
          const costStr = `$${cost.toFixed(3)}`;
          const left = theme.fg("dim", `${tokenStr}  ${costStr}`);

          // Right: repo name + git branch + model
          const modelId = ctx.model?.id ?? "no model";
          const cwd = process.cwd();
          const repoName = cwd.split("/").at(-1) || cwd;
          const branch = footerData.getGitBranch();
          const branchStr = branch ? ` (${branch})` : "";
          const right = theme.fg("dim", `${repoName}${branchStr}  ${modelId}`);

          const gap = Math.max(1, width - visibleWidth(left) - visibleWidth(right));
          return [truncateToWidth(left + " ".repeat(gap) + right, width)];
        },
      };
    });
  }

  // Install on every session start (covers startup, new, resume, fork, reload).
  pi.on("session_start", async (_event, ctx) => {
    installFooter(ctx);
  });
}
