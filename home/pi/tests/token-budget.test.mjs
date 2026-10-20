import assert from "node:assert/strict";
import test from "node:test";
import { codexStylePayload, shortenToolResult } from "../token-budget.ts";

test("codexStylePayload requests concise text and removes reasoning summaries", () => {
  const payload = {
    model: "gpt-6-luna",
    input: [{ role: "user", content: "hello" }],
    text: { format: { type: "text" } },
    reasoning: { effort: "high", summary: "auto" },
  };

  const result = codexStylePayload(payload);

  assert.deepEqual(result, {
    ...payload,
    text: { format: { type: "text" }, verbosity: "low" },
    reasoning: { effort: "high" },
  });
  assert.equal(payload.reasoning.summary, "auto");
});

test("codexStylePayload leaves unrelated requests untouched", () => {
  for (const payload of [
    null,
    [],
    { model: "gpt-4.1", input: "hello" },
    { model: "gpt-6-luna", messages: [] },
  ]) {
    assert.equal(codexStylePayload(payload), payload);
  }
});

test("shortenToolResult keeps read output head and splits bash output ends", () => {
  const text = `START-${"x".repeat(500)}-END`;
  const limit = 180;
  const read = shortenToolResult("read", text, "/tmp/full-output.txt", limit);
  const bash = shortenToolResult("bash", text, "/tmp/full-output.txt", limit);

  assert.equal(read.length, limit);
  assert.ok(read.startsWith("START-"));
  assert.ok(read.includes("Use read with offset/limit"));
  assert.equal(bash.length, limit);
  assert.ok(bash.startsWith("START-"));
  assert.ok(bash.endsWith("-END"));
});

test("shortenToolResult leaves small results alone and handles a zero limit", () => {
  assert.equal(shortenToolResult("bash", "small", "/tmp/output", 10), "small");
  assert.equal(shortenToolResult("bash", "large", "/tmp/output", 0), "");
});
