{
  unstable,
  ...
}:
{
  programs.k9s = {
    enable = true;
    package = unstable.k9s;
    skins = {
      ghostty = {
        k9s = {
          body = {
            fgColor = "#ffffff";
            bgColor = "#292c33";
            logoColor = "#88a1bb";
          };
          prompt = {
            fgColor = "#ffffff";
            bgColor = "#292c33";
            suggestColor = "#e9c880";
          };
          info = {
            fgColor = "#ad95b8";
            sectionColor = "#ffffff";
          };
          help = {
            fgColor = "#ffffff";
            bgColor = "#292c33";
            keyColor = "#ad95b8";
            numKeyColor = "#88a1bb";
            sectionColor = "#b7bd73";
          };
          dialog = {
            fgColor = "#ffffff";
            bgColor = "#292c33";
            buttonFgColor = "#ffffff";
            buttonBgColor = "#ad95b8";
            buttonFocusFgColor = "white";
            buttonFocusBgColor = "#95bdb7";
            labelFgColor = "#e9c880";
            fieldFgColor = "#ffffff";
          };
          frame = {
            border = {
              fgColor = "#666666";
              focusColor = "#3a3d45";
            };
            menu = {
              fgColor = "#ffffff";
              keyColor = "#ad95b8";
              numKeyColor = "#ad95b8";
            };
            crumbs = {
              fgColor = "#ffffff";
              bgColor = "#666666";
              activeColor = "#88a1bb";
            };
            status = {
              newColor = "#95bdb7";
              modifyColor = "#88a1bb";
              addColor = "#b7bd73";
              errorColor = "#bf6b69";
              highlightColor = "#e9c880";
              killColor = "#666666";
              completedColor = "#666666";
            };
            title = {
              fgColor = "#ffffff";
              bgColor = "#292c33";
              highlightColor = "#e9c880";
              counterColor = "#88a1bb";
              filterColor = "#ad95b8";
            };
          };
          views = {
            charts = {
              bgColor = "default";
              defaultDialColors = [
                "#88a1bb"
                "#bf6b69"
              ];
              defaultChartColors = [
                "#88a1bb"
                "#bf6b69"
              ];
            };
            table = {
              fgColor = "#ffffff";
              bgColor = "#292c33";
              cursorFgColor = "#ffffff";
              cursorBgColor = "#3a3d45";
              header = {
                fgColor = "#ffffff";
                bgColor = "#292c33";
                sorterColor = "#666666";
              };
            };
            xray = {
              fgColor = "#ffffff";
              bgColor = "#292c33";
              cursorColor = "#3a3d45";
              graphicColor = "#88a1bb";
              showIcons = false;
            };
            yaml = {
              keyColor = "#ad95b8";
              colonColor = "#88a1bb";
              valueColor = "#ffffff";
            };
            logs = {
              fgColor = "#ffffff";
              bgColor = "#292c33";
              indicator = {
                fgColor = "#ffffff";
                bgColor = "#292c33";
              };
            };
          };
        };
      };
    };
    settings = {
      k9s = {
        ui = {
          skin = "ghostty";
        };
      };
    };
  };
}
