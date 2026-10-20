import assert from "node:assert/strict";
import test from "node:test";
import litellmCompat from "../litellm-compat.ts";

function transform(payload, provider = "litellm") {
  let beforeRequest;
  litellmCompat({
    on(event, handler) {
      if (event === "before_provider_request") beforeRequest = handler;
    },
  });
  return beforeRequest(
    { type: "before_provider_request", payload },
    { model: { provider, id: payload?.model } },
  );
}

for (const model of ["gemini-4-argon", "gemini-4-argon-ent-ai"]) {
  test(`removes the unsupported cache key for LiteLLM ${model}`, () => {
    const payload = {
      model,
      input: "Hello",
      prompt_cache_key: "session-123",
      stream: true,
      tools: [{ type: "function", name: "read" }],
    };
    const result = transform(payload);
    assert.deepEqual(result, {
      model,
      input: "Hello",
      stream: true,
      tools: [{ type: "function", name: "read" }],
    });
    assert.equal(payload.prompt_cache_key, "session-123");
  });
}

test("preserves GPT cache affinity on LiteLLM", () => {
  for (const model of ["gpt-6-sol", "gpt-6.1-sol"]) {
    const payload = { model, prompt_cache_key: "session-123" };
    assert.equal(transform(payload), payload);
  }
});

test("does not modify Gemini requests on other providers", () => {
  const payload = { model: "gemini-4-argon", prompt_cache_key: "session-123" };
  assert.equal(transform(payload, "openrouter"), payload);
});

test("passes through unrelated, malformed, and already compatible payloads", () => {
  for (const payload of [
    null,
    [],
    "payload",
    { model: "gemini-4-argon-other", prompt_cache_key: "session-123" },
    { model: "gemini-4-argon", input: "Hello" },
  ]) {
    assert.equal(transform(payload), payload);
  }
});
