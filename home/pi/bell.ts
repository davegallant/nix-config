/**
 * Ring the terminal bell when the agent finishes, so Ghostty flags the tab
 * (bell-features). Complements agent-stuff's notify.ts, which only sends a
 * desktop notification (OSC 777) and never rings the bell.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("agent_end", async () => {
    process.stdout.write("\x07");
  });
}
