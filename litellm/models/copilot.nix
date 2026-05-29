# GitHub Copilot models exposed via LiteLLM.
# Refreshed via:
#   TOKEN=$(sudo cat /var/lib/litellm/.config/litellm/github_copilot/access-token)
#   curl -s https://api.githubcopilot.com/models \
#     -H "Authorization: Bearer $TOKEN" \
#     -H "Editor-Version: vscode/1.95.0" \
#     -H "Copilot-Integration-Id: vscode-chat" | jq '.data[].id'
[
  "claude-haiku-4.5"
  "claude-opus-4.6"
  "claude-sonnet-4.6"
]
