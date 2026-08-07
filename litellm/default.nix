{
  unstable,
  ...
}:
{
  config = {
    system.activationScripts.litellm-secrets.text = ''
      if [ ! -f /var/lib/litellm/secrets.env ]; then
        mkdir -p /var/lib/litellm
        touch /var/lib/litellm/secrets.env
        chmod 600 /var/lib/litellm/secrets.env
      fi
    '';

    services.litellm = {
      enable = true;
      package = unstable.litellm;
      host = "0.0.0.0";
      port = 4000;
      environment = {
        HOME = "/var/lib/litellm";
        XDG_CONFIG_HOME = "/var/lib/litellm/.config";
      };
      environmentFile = "/var/lib/litellm/secrets.env";
      settings = {
        model_list =
          let
            opencodeGoModel = name: {
              model_name = builtins.replaceStrings [ "." ] [ "-" ] name;
              litellm_params = {
                model = "openai/${name}";
                api_base = "https://opencode.ai/zen/go/v1";
                api_key = "os.environ/OPENCODE_API_KEY";
              };
            };
          in
          map opencodeGoModel (import ./models/opencode-go.nix);
        litellm_settings = {
          drop_params = true;
        };
      };
    };
  };
}
