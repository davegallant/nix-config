# Ollama runs on kratos; other hosts reach it over the tailnet.
hostname: rec {
  port = 11434;
  baseUrl = "http://${if hostname == "kratos" then "127.0.0.1" else "kratos"}:${toString port}/v1";
}
