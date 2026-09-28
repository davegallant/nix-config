{
  id = "qwen3.8:27b";
  name = "Qwen 3.8 27B (Ollama)";
  reasoning = true;
  input = [
    "text"
    "image"
  ];
  # Keep the local working context below the model's 262144-token maximum.
  contextWindow = 65536;
  maxTokens = 16384;
}
