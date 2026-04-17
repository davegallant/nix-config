{
  home.file.".wakeup" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      sleep 3
      launchctl kickstart -k "gui/$(id -u)/com.github.karinushka.paneru"
    '';
  };
}
