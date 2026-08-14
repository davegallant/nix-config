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
          map
            (name: {
              model_name = name;
              litellm_params = {
                model = "openai/${name}";
                api_key = "os.environ/OPENAI_API_KEY";
              };
            })
            [
              "gpt-5.6-luna"
              "gpt-5.6-terra"
              "gpt-5.6-sol"
            ];
        litellm_settings = {
          drop_params = true;
        };
      };
    };
  };
}
