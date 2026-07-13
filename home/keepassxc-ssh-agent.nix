{ lib, pkgs, ... }:
{
  # KeePassXC on Linux never runs its own agent; it only talks to
  # SSH_AUTH_SOCK. gpg-agent's ssh-agent emulation (home/default.nix) can't
  # add/remove identities on request, which KeePassXC needs, so use a real
  # ssh-agent here instead; SSH_AUTH_SOCK gets exported to fish automatically.
  services.ssh-agent.enable = true;

  # services.ssh-agent only wires SSH_AUTH_SOCK into shell startup files
  # (fish/bash), which KeePassXC never sources when launched from Plasma's
  # app menu rather than a terminal. Plasma sources every *.sh dropped here
  # before starting any session component, so this reaches GUI-launched apps.
  xdg.configFile."plasma-workspace/env/ssh-agent.sh".text = ''
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
  '';

  # This just flips KeePassXC's own "use it" switch, which lives in its
  # self-managed, frequently rewritten ini file, so it's patched in place
  # instead of owned wholesale.
  home.activation.keepassxcSshAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    iniDir="$HOME/.config/keepassxc"
    ini="$iniDir/keepassxc.ini"
    run mkdir -p "$iniDir"
    run touch "$ini"

    tmp=$(mktemp)
    ${lib.getExe pkgs.gawk} '
      /^\[/ {
        if (in_section && !set) { print "Enabled=true"; set = 1 }
        in_section = ($0 == "[SSHAgent]")
        if (in_section) seen = 1
        print
        next
      }
      {
        if (in_section && /^Enabled=/) { print "Enabled=true"; set = 1; next }
        print
      }
      END {
        if (in_section && !set) { print "Enabled=true" }
        if (!seen) { print "\n[SSHAgent]"; print "Enabled=true" }
      }
    ' "$ini" > "$tmp"
    run chmod u+w "$ini" 2>/dev/null || true
    run mv "$tmp" "$ini"
  '';
}
