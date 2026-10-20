import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("before_provider_request", (event, ctx) => {
    const payload = event.payload;
    if (
      ctx.model?.provider !== "litellm" ||
      typeof payload !== "object" ||
      payload === null ||
      Array.isArray(payload)
    ) {
      return payload;
    }

    const request = payload as Record<string, unknown>;
    if (
      (request.model !== "gemini-4-argon" && request.model !== "gemini-4-argon-ent-ai") ||
      !("prompt_cache_key" in request)
    ) {
      return payload;
    }

    // The gateway's Vertex route rejects OpenAI cache-affinity keys.
    const { prompt_cache_key: _cacheKey, ...compatible } = request;
    return compatible;
  });
}
