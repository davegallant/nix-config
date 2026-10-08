{
  config,
  lib,
  pkgs,
  ...
}:
let
  words = map (begin: {
    inherit begin;
  });
  regex = description: begin: {
    inherit begin description;
    regularExpression = true;
  };

  doubleQuoted = {
    begin = ''"'';
    end = ''"'';
    escapeCharacter = "\\";
  };
  hashComment = {
    blocks = [ ];
    inlines = [ { begin = "#"; } ];
  };
  number = regex "int / float" ''(?<![\w'.-])[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?\b'';
  assignment = regex "attribute name" ''(?<![\w'.-])[A-Za-z_][\w'-]*(\.[A-Za-z_][\w'-]*)*(?=\s*=(?!=))'';

  # CotEditor ships no syntax for these; custom ones are regex-based .cotsyntax bundles.
  mkSyntax =
    name:
    {
      fileMap,
      edit,
      highlights,
    }:
    pkgs.linkFarm "${name}.cotsyntax" {
      "Info.json" = pkgs.writeText "Info.json" (
        builtins.toJSON {
          inherit fileMap;
          kind = "code";
          metadata = {
            author = "Dave Gallant";
            version = "1.0.0";
          };
        }
      );
      "Edit.json" = pkgs.writeText "Edit.json" (builtins.toJSON edit);
      "Regex/Highlights.json" = pkgs.writeText "Highlights.json" (builtins.toJSON highlights);
    };

  syntaxes = {
    Nix = mkSyntax "Nix" {
      fileMap.extensions = [ "nix" ];
      edit = {
        comment = {
          blocks = [
            {
              begin = "/*";
              end = "*/";
            }
          ];
          inlines = [ { begin = "#"; } ];
        };
        indentation.blockDelimiters = [
          {
            begin = "{";
            end = "}";
          }
          {
            begin = "[";
            end = "]";
          }
        ];
        stringDelimiters = [
          doubleQuoted
          {
            begin = "''";
            end = "''";
            isMultiline = true;
          }
        ];
      };
      highlights = {
        keywords = words [
          "assert"
          "else"
          "if"
          "in"
          "inherit"
          "let"
          "or"
          "rec"
          "then"
          "with"
        ];
        commands = words [
          "abort"
          "baseNameOf"
          "builtins"
          "derivation"
          "dirOf"
          "fetchGit"
          "fetchTarball"
          "fetchurl"
          "import"
          "isNull"
          "map"
          "removeAttrs"
          "throw"
          "toString"
        ];
        values = words [
          "false"
          "null"
          "true"
        ];
        numbers = [ number ];
        attributes = [ assignment ];
        variables = [ (regex "interpolation" ''\$\{[^}]*\}'') ];
        characters = [
          (regex "path" ''(?<![\w'-])(~|\.{1,2})?(/[\w.+-]+)+/?'')
          (regex "search path" ''<[\w.+-]+(/[\w.+-]+)*>'')
        ];
      };
    };

    HCL = mkSyntax "HCL" {
      fileMap.extensions = [
        "hcl"
        "tf"
        "tfvars"
      ];
      edit = {
        comment = {
          blocks = [
            {
              begin = "/*";
              end = "*/";
            }
          ];
          inlines = [
            { begin = "#"; }
            { begin = "//"; }
          ];
        };
        indentation.blockDelimiters = [
          {
            begin = "{";
            end = "}";
          }
          {
            begin = "[";
            end = "]";
          }
        ];
        stringDelimiters = [ doubleQuoted ];
      };
      highlights = {
        keywords = [
          (regex "block type" ''^\s*(check|data|dynamic|import|locals|module|moved|output|provider|removed|resource|terraform|variable)\b'')
        ]
        ++ words [
          "else"
          "endfor"
          "endif"
          "for"
          "if"
          "in"
        ];
        commands = [ (regex "function call" ''\b[a-z_][a-z0-9_]*(?=\()'') ];
        values = words [
          "false"
          "null"
          "true"
        ];
        numbers = [ number ];
        attributes = [ assignment ];
        variables = [
          (regex "interpolation" ''[$%]\{[^}]*\}'')
          (regex "reference" ''\b(count|data|each|local|module|path|self|var)\.[\w.-]+'')
        ];
      };
    };

    Fish = mkSyntax "Fish" {
      fileMap = {
        extensions = [ "fish" ];
        interpreters = [ "fish" ];
      };
      edit = {
        comment = hashComment;
        stringDelimiters = [
          doubleQuoted
          {
            begin = "'";
            end = "'";
            escapeCharacter = "\\";
          }
        ];
      };
      highlights = {
        keywords = words [
          "and"
          "begin"
          "break"
          "case"
          "continue"
          "else"
          "end"
          "for"
          "function"
          "if"
          "in"
          "not"
          "or"
          "return"
          "switch"
          "while"
        ];
        commands = words [
          "abbr"
          "alias"
          "argparse"
          "builtin"
          "cd"
          "command"
          "complete"
          "contains"
          "echo"
          "emit"
          "eval"
          "exec"
          "exit"
          "functions"
          "math"
          "printf"
          "read"
          "set"
          "set_color"
          "source"
          "status"
          "string"
          "test"
          "type"
        ];
        values = words [
          "false"
          "true"
        ];
        numbers = [ number ];
        attributes = [ (regex "option" ''(?<=\s)--?[A-Za-z][\w-]*'') ];
        variables = [ (regex "variable" ''\$[A-Za-z_][\w]*'') ];
      };
    };

    Just = mkSyntax "Just" {
      fileMap = {
        extensions = [ "just" ];
        filenames = [
          ".justfile"
          "Justfile"
          "justfile"
        ];
      };
      edit = {
        comment = hashComment;
        stringDelimiters = [
          doubleQuoted
          {
            begin = "'";
            end = "'";
          }
          {
            begin = "`";
            end = "`";
          }
        ];
      };
      highlights = {
        keywords = [
          (regex "setting" ''^(alias|export|import|mod|set|unexport)\b'')
        ]
        ++ words [
          "else"
          "if"
        ];
        commands = [ (regex "recipe" ''^@?[A-Za-z_][\w-]*(?=(?:\s+[^\n:]*)?:(?!=))'') ];
        attributes = [ (regex "recipe attribute" ''^\[[^\]\n]+\]'') ];
        values = words [
          "false"
          "true"
        ];
        variables = [
          (regex "assignment" ''^[A-Za-z_][\w-]*(?=\s*:=)'')
          (regex "interpolation" ''\{\{[^}]*\}\}'')
          (regex "variable" ''\$[A-Za-z_][\w]*'')
        ];
      };
    };
  };

  # Lock files have no extension mapping in CotEditor. Shadow the bundled syntax
  # with a copy whose Info.json adds them; the bundled fileMap is kept as-is.
  bundledSyntaxDir = "/Applications/CotEditor.app/Contents/Resources/Syntaxes";
  fileMapOverrides = {
    # flake.lock, composer.lock, Pipfile.lock
    JSON = {
      extensions = [
        "json"
        "jsonl"
        "lock"
      ];
      filenames = [ "Package.resolved" ];
    };
    TOML = {
      extensions = [ "toml" ];
      filenames = [
        "Cargo.lock"
        "poetry.lock"
        "uv.lock"
      ];
    };
  };
  overrideInfo =
    name: fileMap:
    pkgs.writeText "${name}-Info.json" (
      builtins.toJSON {
        inherit fileMap;
        kind = "code";
        metadata.author = "1024jp";
      }
    );

  # CotEditor switches a theme `X` to `X (Dark)` in Dark Mode, matching Ghostty's
  # `theme = light:Tomorrow,dark:...` (see home/ghostty.nix).
  themes = lib.mapAttrs (name: colors: pkgs.writeText "${name}.cottheme" (builtins.toJSON colors)) {
    # Ghostty's default colours (`ghostty +show-config --default`).
    "Ghostty (Dark)" = {
      name = "Ghostty (Dark)";
      metadata.author = "Dave Gallant";
      text.color = "#ffffff";
      background.color = "#282c34";
      invisibles.color = "#4e4e4e";
      insertionPoint.color = "#c5c8c6";
      lineHighlight.color = "#ffffff0f";
      selection.color = "#3e4451";
      highlight.color = "#f0c674";
      keywords.color = "#b294bb";
      commands.color = "#81a2be";
      types.color = "#f0c674";
      attributes.color = "#8abeb7";
      variables.color = "#cc6666";
      values.color = "#d54e53";
      numbers.color = "#e7c547";
      strings.color = "#b5bd68";
      characters.color = "#70c0b1";
      comments.color = "#8a8a8a";
    };
    # Ghostty's bundled Tomorrow theme.
    Ghostty = {
      name = "Ghostty";
      metadata.author = "Dave Gallant";
      text.color = "#4d4d4c";
      background.color = "#ffffff";
      invisibles.color = "#c0c0c0";
      insertionPoint.color = "#4d4d4c";
      lineHighlight.color = "#0000000a";
      selection.color = "#d6d6d6";
      highlight.color = "#eab70066";
      keywords.color = "#8959a8";
      commands.color = "#4271ae";
      types.color = "#c99e00";
      attributes.color = "#3e999f";
      variables.color = "#c82829";
      values.color = "#f5871f";
      numbers.color = "#f5871f";
      strings.color = "#718c00";
      characters.color = "#3e999f";
      comments.color = "#8e908c";
    };
  };

  # Script menu entry (Control-Option-F) that formats the saved document by file
  # extension. Scripts run outside the app sandbox with a minimal PATH.
  formatScript = pkgs.writeShellApplication {
    name = "coteditor-format";
    runtimeInputs = [
      config.programs.go.package
      pkgs.fish
      pkgs.jq
      pkgs.nixfmt
      pkgs.opentofu
      pkgs.prettier
      pkgs.ruff
      pkgs.shfmt
    ];
    text = ''
      # %%%{CotEditorXInput=AllText}%%%
      # %%%{CotEditorXOutput=ReplaceAllText}%%%
      file="''${1:-}"
      input=$(mktemp)
      output=$(mktemp)
      trap 'rm -f "$input" "$output"' EXIT
      cat >"$input"

      case "$file" in
        *.nix) cmd=(nixfmt -) ;;
        *.sh | *.bash | *.zsh) cmd=(shfmt --filename "$file") ;;
        *.fish) cmd=(fish_indent) ;;
        *.json) cmd=(jq .) ;;
        *.go) cmd=(gofmt) ;;
        *.py) cmd=(ruff format --stdin-filename "$file" -) ;;
        *.tf | *.tfvars | *.hcl) cmd=(tofu fmt -) ;;
        *.js | *.jsx | *.ts | *.tsx | *.css | *.scss | *.html | *.md | *.yaml | *.yml)
          cmd=(prettier --stdin-filepath "$file")
          ;;
        *) cmd=() ;;
      esac

      # Run from the document's directory so project formatter configs apply.
      if [[ -n "$file" ]]; then cd "$(dirname "$file")"; fi

      # Hand the original text back on any failure so the buffer is never emptied.
      if ((''${#cmd[@]})) && "''${cmd[@]}" <"$input" >"$output"; then
        cat "$output"
      else
        if ((''${#cmd[@]} == 0)); then echo "No formatter for ''${file:-untitled document}" >&2; fi
        cat "$input"
      fi
    '';
  };

  defaults = {
    autoExpandTab = true;
    autoTrimsTrailingWhitespace = true;
    continuousSpellChecking = false;
    defaultTheme = "Ghostty";
    fileBrowserShowsHiddenFiles = true;
    highlightCurrentLine = true;
    lineHeight = 1.15; # default 1.3 feels stretched with Fira Code's tall metrics
    # Side panels default to the small system size (11pt).
    consoleFontSize = 13.0;
    findResultViewFontSize = 13.0;
    outlineViewFontSize = 13.0;
    monospacedLigature = true;
    noDocumentOnLaunchOption = 2; # none
    overscrollRate = 0.5;
    pageGuideColumn = 100;
    showIndentGuides = true;
    showInvisibleNewLine = false;
    showInvisibles = true;
    showPageGuide = true;
    showStatusBarColumn = true;
    tabWidth = 2;
    trimsWhitespaceOnlyLines = true;
    wrapLines = false;
  };
  defaultsFlag =
    value:
    if builtins.isBool value then
      "-bool ${lib.boolToString value}"
    else if builtins.isInt value then
      "-int ${toString value}"
    else if builtins.isFloat value then
      "-float ${toString value}"
    else
      "-string ${lib.escapeShellArg value}";

  # Fonts are stored as a keyed-archived NSFontDescriptor, which only AppKit can
  # produce, so archive it at activation time. Code syntaxes use the monospaced
  # font and plain text the standard one; the Mono variant is fixed-pitch.
  font = {
    name = "FiraCodeNFM-Reg";
    size = 14;
  };
  fontArchiver = pkgs.writeText "coteditor-font.js" ''
    ObjC.import('AppKit');
    function run(argv) {
      const font = $.NSFont.fontWithNameSize(argv[0], Number(argv[1]));
      if (font.isNil()) throw new Error('font not found: ' + argv[0]);
      const data = $.NSKeyedArchiver.archivedDataWithRootObjectRequiringSecureCodingError(font.fontDescriptor, true, null);
      return data.base64EncodedStringWithOptions(0).js;
    }
  '';

  appSupport = "$HOME/Library/Containers/com.coteditor.CotEditor/Data/Library/Application Support/CotEditor";
  scriptsDir = "$HOME/Library/Application Scripts/com.coteditor.CotEditor";
in
{
  # CotEditor is sandboxed and cannot follow symlinks into /nix/store, so copy.
  # home-manager's targets.darwin.defaults would replace the whole domain, so write
  # each key instead.
  home.activation.coteditor = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p "${appSupport}/Syntaxes" "${appSupport}/Themes" "${scriptsDir}"
      ${lib.concatStrings (
        lib.mapAttrsToList (name: syntax: ''
          run rm -rf "${appSupport}/Syntaxes/${name}.cotsyntax"
          run cp -rL "${syntax}" "${appSupport}/Syntaxes/${name}.cotsyntax"
          run chmod -R u+w "${appSupport}/Syntaxes/${name}.cotsyntax"
        '') syntaxes
      )}
      if [[ -d "${bundledSyntaxDir}" ]]; then
        ${lib.concatStrings (
          lib.mapAttrsToList (name: fileMap: ''
            run rm -rf "${appSupport}/Syntaxes/${name}.cotsyntax"
            run cp -R "${bundledSyntaxDir}/${name}.cotsyntax" "${appSupport}/Syntaxes/${name}.cotsyntax"
            run chmod -R u+w "${appSupport}/Syntaxes/${name}.cotsyntax"
            run install -m 0644 "${overrideInfo name fileMap}" "${appSupport}/Syntaxes/${name}.cotsyntax/Info.json"
          '') fileMapOverrides
        )}
      fi
      ${lib.concatStrings (
        lib.mapAttrsToList (name: theme: ''
          run install -m 0644 "${theme}" "${appSupport}/Themes/${name}.cottheme"
        '') themes
      )}
      run install -m 0755 "${lib.getExe formatScript}" "${scriptsDir}/Format.^~f.sh"
      ${lib.concatStrings (
        lib.mapAttrsToList (key: value: ''
          run /usr/bin/defaults write com.coteditor.CotEditor ${key} ${defaultsFlag value}
        '') defaults
      )}
      if fontData=$(/usr/bin/osascript -l JavaScript ${fontArchiver} ${font.name} ${toString font.size} | /usr/bin/base64 -d | /usr/bin/xxd -p | tr -d '\n') && [[ -n "$fontData" ]]; then
        run /usr/bin/defaults write com.coteditor.CotEditor font -data "$fontData"
        run /usr/bin/defaults write com.coteditor.CotEditor monospacedFont -data "$fontData"
      else
        warnEcho "CotEditor: could not archive font ${font.name}; leaving font unchanged"
      fi
    ''
  );
}
