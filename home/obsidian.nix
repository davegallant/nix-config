{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  inherit (pkgs) stdenv;
in
{
  config =
    lib.mkIf (config.features.desktop.enable && stdenv.isLinux && stdenv.hostPlatform.isx86_64)
      {
        home.file."Documents/notes-vault-personal/.obsidian/daily-notes.json".text = builtins.toJSON {
          folder = "Journal";
        };
        programs.obsidian = {
          enable = true;
          package = unstable.obsidian;
          vaults = {
            "notes-vault-personal" = {
              target = "Documents/notes-vault-personal";
              settings = {
                app = {
                  safeMode = false;
                  vimMode = true;
                  showLineNumber = true;
                };
                corePlugins = [
                  "backlink"
                  "bookmarks"
                  "canvas"
                  "command-palette"
                  "daily-notes"
                  "file-explorer"
                  "file-recovery"
                  "global-search"
                  "graph"
                  "outline"
                  "page-preview"
                  "switcher"
                  "tag-pane"
                  "templates"
                  "word-count"
                ];
                communityPlugins = [
                  {
                    pkg = pkgs.fetchzip {
                      url = "https://github.com/Vinzent03/obsidian-git/releases/download/2.38.2/obsidian-git-2.38.2.zip";
                      name = "obsidian-git";
                      stripRoot = true;
                      hash = "sha256-M9DaGqa2ILEJ0GMJGSqry0VXDn5HYRkl1sfxpsUh9bQ=";
                    };
                    settings = {
                      commitMessage = "vault backup: {{date}}";
                      autoCommitMessage = "vault backup: {{date}}";
                      commitMessageScript = "";
                      commitDateFormat = "YYYY-MM-DD HH:mm:ss";
                      autoSaveInterval = 5;
                      autoPushInterval = 5;
                      autoPullInterval = 5;
                      autoPullOnBoot = false;
                      autoCommitOnlyStaged = false;
                      disablePush = false;
                      pullBeforePush = true;
                      disablePopups = false;
                      showErrorNotices = true;
                      disablePopupsForNoChanges = false;
                      listChangedFilesInMessageBody = false;
                      showStatusBar = true;
                      updateSubmodules = false;
                      syncMethod = "merge";
                      mergeStrategy = "none";
                      customMessageOnAutoBackup = false;
                      autoBackupAfterFileChange = true;
                      treeStructure = false;
                      refreshSourceControl = true;
                      basePath = "";
                      differentIntervalCommitAndPush = false;
                      changedFilesInStatusBar = false;
                      showedMobileNotice = true;
                      refreshSourceControlTimer = 7000;
                      showBranchStatusBar = true;
                      setLastSaveToLastCommit = true;
                      submoduleRecurseCheckout = false;
                      gitDir = "";
                      showFileMenu = true;
                      authorInHistoryView = "hide";
                      dateInHistoryView = false;
                      diffStyle = "split";
                      hunks = {
                        showSigns = false;
                        hunkCommands = false;
                        statusBar = "disabled";
                      };
                      lineAuthor = {
                        show = false;
                        followMovement = "inactive";
                        authorDisplay = "initials";
                        showCommitHash = false;
                        dateTimeFormatOptions = "date";
                        dateTimeFormatCustomString = "YYYY-MM-DD HH:mm";
                        dateTimeTimezone = "viewer-local";
                        coloringMaxAge = "1y";
                        colorNew = {
                          r = 255;
                          g = 150;
                          b = 150;
                        };
                        colorOld = {
                          r = 120;
                          g = 160;
                          b = 255;
                        };
                        textColorCss = "var(--text-muted)";
                        ignoreWhitespace = false;
                        gutterSpacingFallbackLength = 5;
                        lastShownAuthorDisplay = "initials";
                        lastShownDateTimeFormatOptions = "date";
                      };
                    };
                  }
                ];
              };
            };
          };
        };
      };
}
