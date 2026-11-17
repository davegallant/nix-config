_:

{
  programs.gh-dash = {
    enable = true;
    settings = {
      prSections = [
        {
          # review-requested is team-inclusive: direct requests plus any team I'm in.
          title = "Needs My Review";
          filters = "is:open archived:false draft:false -org:NixOS review-requested:@me";
        }
        {
          title = "My Pull Requests";
          filters = "is:open archived:false -org:NixOS author:@me";
        }
      ];
      # Otherwise launching inside a git repo scopes every section to that repo.
      smartFilteringAtLaunch = false;
    };
  };

  # Replace the config gh-dash writes on first run.
  xdg.configFile."gh-dash/config.yml".force = true;
}
