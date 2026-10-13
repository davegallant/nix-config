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

  # CotEditor switches a theme `X` to `X (Dark)` in Dark Mode.
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

  # Script menu entry (Shift-Command-I) that formats the saved document by file
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

  gitScript = pkgs.writeShellApplication {
    name = "coteditor-git";
    runtimeInputs = [ pkgs.git ];
    text = ''
      cmd=$1 file=$2 first=''${3:-1} last=''${4:-1}
      cd "$(dirname "$file")"
      name=$(basename "$file")
      case "$cmd" in
        permalink)
          remote=$(git remote get-url origin)
          remote=''${remote%.git}
          case "$remote" in
            *://*) remote=''${remote#*://} remote=''${remote#*@} host=''${remote%%/*} repo=''${remote#*/} ;;
            *) remote=''${remote#*@} host=''${remote%%:*} repo=''${remote#*:} ;;
          esac
          rel=$(git ls-files --full-name -- "$name")
          if [[ -z "$rel" ]]; then
            echo "$name is not tracked by git" >&2
            exit 1
          fi
          lines="L$first"
          if ((last > first)); then lines+="-L$last"; fi
          url="https://''${host%%:*}/$repo/blob/$(git rev-parse HEAD)/$rel#$lines"
          printf %s "$url" | /usr/bin/pbcopy
          ;;
        blame) git blame -L "$first,$last" --date=short -- "$name" ;;
      esac
    '';
  };

  # Script menu entry (Shift-Command-V) that renders the buffer, unsaved edits
  # included, as GitHub-flavoured HTML and opens it in the default browser.
  markdownPreview = pkgs.writeShellApplication {
    name = "coteditor-markdown-preview";
    runtimeInputs = [ pkgs.cmark-gfm ];
    text = ''
      # %%%{CotEditorXInput=AllText}%%%
      file="''${1:-untitled.md}"
      dir=$(dirname "$file")
      out="''${TMPDIR:-/tmp}/coteditor-markdown-preview/$(basename "$file").html"
      mkdir -p "$(dirname "$out")"
      {
        cat <<EOF
      <!doctype html>
      <meta charset="utf-8">
      <meta name="color-scheme" content="light dark">
      <title>$(basename "$file")</title>
      <base href="file://''${dir// /%20}/">
      <style>
        body { max-width: 52rem; margin: 2rem auto; padding: 0 1rem; font: 16px/1.6 -apple-system, sans-serif; }
        pre, code { font-family: "FiraCode Nerd Font Mono", ui-monospace, monospace; font-size: 0.9em; }
        code { background: #8882; padding: 0.15em 0.3em; border-radius: 4px; }
        pre { background: #8882; padding: 1em; border-radius: 6px; overflow-x: auto; }
        pre code { background: none; padding: 0; }
        blockquote { margin: 0; padding-left: 1em; border-left: 4px solid #8886; color: #888; }
        table { border-collapse: collapse; }
        th, td { border: 1px solid #8886; padding: 0.3em 0.7em; }
        img { max-width: 100%; }
        h1, h2 { border-bottom: 1px solid #8884; padding-bottom: 0.3em; }
      </style>
      EOF
        cmark-gfm --unsafe -e table -e strikethrough -e autolink -e tasklist -e footnotes
        cat <<'EOF'
      <script type="module">
        import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.esm.min.mjs";
        for (const code of document.querySelectorAll("code.language-mermaid")) {
          const div = document.createElement("div");
          div.className = "mermaid";
          div.textContent = code.textContent;
          code.parentElement.replaceWith(div);
        }
        const dark = matchMedia("(prefers-color-scheme: dark)").matches;
        mermaid.initialize({ startOnLoad: false, theme: dark ? "dark" : "default" });
        mermaid.run();
      </script>
      EOF
      } >"$out"
      /usr/bin/open "$out"
    '';
  };

  # Script menu entry (Shift-Command-O) that opens a ~/src/<host>/<owner>/<repo>
  # folder. The picker runs in osascript, outside the sandboxed editor.
  openProject = pkgs.writeShellApplication {
    name = "coteditor-open-project";
    runtimeInputs = [ pkgs.fd ];
    text = ''
      src="$HOME/src"
      mapfile -t projects < <(fd --exact-depth 3 --type d --base-directory "$src" --strip-cwd-prefix | sed 's|/$||' | sort)
      choice=$(/usr/bin/osascript \
        -e 'on run argv' \
        -e 'activate' \
        -e 'choose from list argv with prompt "Open project"' \
        -e 'end run' \
        -- "''${projects[@]}")
      if [[ "$choice" != false && -n "$choice" ]]; then
        /usr/bin/open -a CotEditor "$src/$choice"
      fi
    '';
  };

  # Script menu entries under Base64 that replace the selection in place.
  base64Script =
    name: text:
    pkgs.writeShellApplication {
      name = "coteditor-base64-${name}";
      text = ''
        # %%%{CotEditorXInput=Selection}%%%
        # %%%{CotEditorXOutput=ReplaceSelection}%%%
        input=$(cat)
        ${text}
      '';
    };
  base64Encode = base64Script "encode" ''printf %s "$(printf %s "$input" | /usr/bin/base64)"'';
  # `base64 -D` exits 0 on garbage, so hand back non-base64 selections unchanged.
  base64Decode = base64Script "decode" ''
    if [[ "$input" =~ ^[A-Za-z0-9+/=[:space:]]+$ ]]; then
      printf %s "$input" | /usr/bin/base64 -D
    else
      echo "Selection is not base64" >&2
      printf %s "$input"
    fi
  '';

  # JXA scripts are compiled at activation. Standard Additions such as `do shell
  # script` raise a privilege violation here because the current application is
  # the sandboxed editor, so commands run through NSTask in the script process.
  jxaPrelude = ''
    ObjC.import("Foundation");
    const cot = Application("CotEditor");

    function sh(args) {
      const task = $.NSTask.alloc.init;
      task.executableURL = $.NSURL.fileURLWithPath(args[0]);
      task.arguments = $(args.slice(1));
      const stdout = $.NSPipe.pipe;
      const stderr = $.NSPipe.pipe;
      task.standardOutput = stdout;
      task.standardError = stderr;
      if (!task.launchAndReturnError(null)) throw new Error("Could not run " + args[0]);
      const read = (pipe) =>
        $.NSString.alloc.initWithDataEncoding(pipe.fileHandleForReading.readDataToEndOfFile, $.NSUTF8StringEncoding).js;
      const out = read(stdout);
      const err = read(stderr);
      task.waitUntilExit;
      if (task.terminationStatus !== 0) throw new Error(err.trim() || args[0] + " failed");
      return out;
    }

    // A folder window forwards to its current document, but `file` is the folder's.
    function textDocument(doc) {
      try {
        return doc.currentDocument() || doc;
      } catch (e) {
        return doc;
      }
    }
    function frontFile() {
      const doc = textDocument(cot.documents[0]);
      const file = doc.file();
      if (!file) throw new Error("Save the document first");
      return { doc, path: file.toString() };
    }
    function selectedLines(doc) {
      const [first, length] = doc.selection.lineRange();
      return [first, first + Math.max(length, 1) - 1];
    }
    function report(fn) {
      try {
        fn();
      } catch (e) {
        cot.writeToConsole(String(e.message || e));
      }
    }
  '';
  gitCommand = command: ''
    function run() {
      report(() => {
        const { doc, path } = frontFile();
        const [first, last] = selectedLines(doc);
        const out = sh([${builtins.toJSON (lib.getExe gitScript)}, "${command}", path, String(first), String(last)]);
        if (out.trim()) cot.writeToConsole(out);
      });
    }
  '';
  scripts = {
    "Git/Copy Permalink.@Y" = gitCommand "permalink";
    "Git/Blame.@B" = gitCommand "blame";
  };

  defaults = {
    NSQuitAlwaysKeepsWindows = true; # reopen windows from last session
    autoExpandTab = true;
    autoTrimsTrailingWhitespace = true;
    continuousSpellChecking = false;
    defaultTheme = "Ghostty";
    enablesAutosaveInPlace = true;
    fileBrowserShowsHiddenFiles = true;
    findIgnoresCase = true;
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
    windowTabbing = 1; # always open documents in tabs
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

  # VS Code-style menu shortcuts. Only differences from CotEditor's defaults are
  # stored; an entry without `shortcut` clears a default that would collide.
  # Keys are `^~$@` modifiers (control, option, shift, command) plus the key.
  up = builtins.fromJSON ''"\uf700"'';
  down = builtins.fromJSON ''"\uf701"'';
  keyBindings = pkgs.writeText "Shortcuts.json" (
    builtins.toJSON (
      map (b: { tag = 0; } // b) [
        {
          action = "performTextFinderAction:"; # Find All, was ⌘⇧F
          tag = 101;
        }
        {
          action = "showFolderFinder:"; # was ^⌘2
          shortcut = "$@f";
        }
        {
          action = "showQuickActions:";
          shortcut = "$@p";
        }
        { action = "runPageLayout:"; } # was ⌘⇧P
        {
          action = "toggleSidebar:";
          shortcut = "@b";
        }
        {
          action = "gotoLocation:";
          shortcut = "^g";
        }
        {
          action = "moveLineUp:";
          shortcut = "~${up}";
        }
        {
          action = "moveLineDown:";
          shortcut = "~${down}";
        }
        {
          action = "duplicateLine:";
          shortcut = "~$" + down; # "$${" would be an escaped interpolation
        }
        {
          action = "deleteLine:";
          shortcut = "$@k";
        }
      ]
    )
  );

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
      run mkdir -p "${appSupport}/KeyBindings"
      run /usr/bin/plutil -convert xml1 -o "${appSupport}/KeyBindings/Shortcuts.plist" "${keyBindings}"
      # Clear managed scripts first so renamed shortcuts leave no stale copies.
      run rm -rf "${scriptsDir}/Git" "${scriptsDir}/Base64" "${scriptsDir}"/Format.*.sh "${scriptsDir}"/Open\ Project.* "${scriptsDir}"/Markdown\ Preview.*
      run install -m 0755 "${lib.getExe formatScript}" "${scriptsDir}/Format.@I.sh"
      run install -m 0755 "${lib.getExe openProject}" "${scriptsDir}/Open Project.@O.sh"
      run install -m 0755 "${lib.getExe markdownPreview}" "${scriptsDir}/Markdown Preview.@V.sh"
      run mkdir -p "${scriptsDir}/Base64"
      run install -m 0755 "${lib.getExe base64Encode}" "${scriptsDir}/Base64/Encode.sh"
      run install -m 0755 "${lib.getExe base64Decode}" "${scriptsDir}/Base64/Decode.sh"
      ${lib.concatStrings (
        lib.mapAttrsToList (name: body: ''
          run mkdir -p "$(dirname "${scriptsDir}/${name}")"
          run /usr/bin/osacompile -l JavaScript -o "${scriptsDir}/${name}.scpt" "${
            pkgs.writeText "coteditor-script.js" (jxaPrelude + body)
          }"
        '') scripts
      )}
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
