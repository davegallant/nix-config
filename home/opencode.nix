{ pkgs, ... }:
let
  opencode-sandbox = pkgs.writeShellScriptBin "oc" ''
    set -euo pipefail

    VERSION="1.4.3"
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

    echo "→ opencode sandbox: $(pwd)" >&2
    echo "→ image: $IMAGE" >&2

    exec ${pkgs.docker}/bin/docker run \
      --rm -it \
      --name "$CONTAINER_NAME" \
      --hostname "opencode-sandbox" \
      --workdir "/workspace" \
      -e TERM \
      -v "$(pwd)":/workspace \
      "''${env_flags[@]+"''${env_flags[@]}"}" \
      "''${auth_mounts[@]+"''${auth_mounts[@]}"}" \
      "''${ssh_mounts[@]+"''${ssh_mounts[@]}"}" \
      "''${git_mounts[@]+"''${git_mounts[@]}"}" \
      "$IMAGE" \
      "''${@:+"$@"}"

  '';
in
{
  home.packages = [ opencode-sandbox ];
}
