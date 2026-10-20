import assert from "node:assert/strict";
import test from "node:test";
import { elide, fitToBudget } from "../advisor-transcript.ts";

test("elide preserves both ends and respects the character budget", () => {
  const text = `HEAD-${"x".repeat(100)}-TAIL`;
  const result = elide(text, 32);

  assert.equal(result.length, 32);
  assert.ok(result.startsWith(text.slice(0, 8)));
  assert.ok(result.endsWith(text.slice(-4)));
  assert.ok(result.includes("[elided]"));
});

test("fitToBudget discards older material before the latest exchange", () => {
  const sections = [
    { isToolResult: true, text: `## Tool result\n${"old output ".repeat(40)}` },
    { isToolResult: false, text: "## User\nKeep this latest request" },
  ];
  const original = structuredClone(sections);
  const latest = sections[1];

  const result = fitToBudget(sections, latest.text.length + 2);

  assert.deepEqual(result, [latest]);
  assert.deepEqual(sections, original);
});
