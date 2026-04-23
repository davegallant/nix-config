{ pkgs, ... }:
let
  opencode-sandbox = pkgs.writeShellScriptBin "opencode" ''
    set -euo pipefail

    VERSION="1.4.17"
    IMAGE="''${OPENCODE_IMAGE:-ghcr.io/anomalyco/opencode:$VERSION}"
    CONTAINER_NAME="opencode-$(basename "$PWD")-$$"

    if ! command -v docker &>/dev/null; then
      echo "error: docker not found in PATH" >&2
      exit 1
    fi

    env_flags=()
    for key in ANTHROPIC_API_KEY OPENAI_API_KEY GOOGLE_API_KEY XAI_API_KEY GROQ_API_KEY; do
      [[ -n "''${!key:-}" ]] && env_flags+=(-e "$key=''${!key}")
    done
    [[ -n "''${GH_TOKEN:-}" ]]     && env_flags+=(-e "GH_TOKEN=''${GH_TOKEN}")
    [[ -n "''${GITHUB_TOKEN:-}" ]] && env_flags+=(-e "GITHUB_TOKEN=''${GITHUB_TOKEN}")

    auth_mounts=()
    config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
    data_dir="''${XDG_DATA_HOME:-$HOME/.local/share}/opencode"
    mkdir -p "$config_dir" "$data_dir"
    auth_mounts+=(
      -v "$config_dir:/root/.config/opencode"
      -v "$data_dir:/root/.local/share/opencode"
    )

    ssh_mounts=()
    for key_name in id_ed25519 id_rsa id_ecdsa; do
      key_path="$HOME/.ssh/$key_name"
      if [[ -f "$key_path" ]]; then
        ssh_mounts+=(-v "$key_path:/root/.ssh/$key_name:ro")
        break
      fi
    done

    git_mounts=()
    [[ -f "$HOME/.gitconfig" ]] && git_mounts+=(-v "$HOME/.gitconfig:/root/.gitconfig:ro")

    extra_args=()
    web_port="''${OPENCODE_WEB_PORT:-4096}"
    port_flags=()
    for arg in "$@"; do
      if [[ "$arg" == "web" ]]; then
        port_flags+=(-p "127.0.0.1:''${web_port}:''${web_port}")
        extra_args+=(--hostname 0.0.0.0 --port "''${web_port}")
        echo "→ web mode: http://localhost:''${web_port}" >&2
        break
      fi
    done

    echo "→ opencode sandbox: $(pwd)" >&2
    echo "→ image: $IMAGE" >&2

    exec ${pkgs.docker}/bin/docker run \
      --rm -it \
      --name "$CONTAINER_NAME" \
      --hostname "opencode-sandbox" \
      --add-host "host.docker.internal:host-gateway" \
      --workdir "/workspace" \
      -e TERM \
      -v "$(pwd)":/workspace \
      -v /nix/store:/nix/store:ro \
      "''${env_flags[@]+"''${env_flags[@]}"}" \
      "''${auth_mounts[@]+"''${auth_mounts[@]}"}" \
      "''${ssh_mounts[@]+"''${ssh_mounts[@]}"}" \
      "''${git_mounts[@]+"''${git_mounts[@]}"}" \
      "''${port_flags[@]+"''${port_flags[@]}"}" \
      "$IMAGE" \
      "''${@:+"$@"}" \
      "''${extra_args[@]+"''${extra_args[@]}"}"
  '';
in
{
  home.packages = [ opencode-sandbox ];

  xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    autoupdate = false;
    disabled_providers = [
      "opencode"
      "github-copilot"
    ];
    provider.litellm = {
      npm = "@ai-sdk/openai-compatible";
      name = "LiteLLM";
      options = {
        baseURL = "http://host.docker.internal:4000/v1";
        apiKey = "sk-noauth";
      };
      models =
        let
          mkModel = id: {
            name = id;
            tool_call = true;
            reasoning = false;
            attachment = true;
            limit = {
              context = 200000;
              output = 8192;
            };
            cost = {
              input = 0;
              output = 0;
            };
          };
        in
        builtins.listToAttrs (
          map (id: {
            name = "copilot-${id}";
            value = mkModel id;
          }) (import ../copilot-models.nix)
        );
    };
  };
}
