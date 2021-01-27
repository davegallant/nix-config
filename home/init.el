;; Enable Mouse
(xterm-mouse-mode 1)

;; Enable Line Numbers
(global-display-line-numbers-mode 1)

;; Enable Evil
(require 'evil)
(evil-mode 1)

;; Set Theme
(load-theme 'doom-gruvbox t)

;; Disable startup message.
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message (user-login-name))

;; Accept 'y' and 'n' rather than 'yes' and 'no'.
(defalias 'yes-or-no-p 'y-or-n-p)

;; Centaur Tabs
(require 'centaur-tabs)
(centaur-tabs-mode t)
(global-set-key (kbd "C-<prior>")  'centaur-tabs-backward)
(global-set-key (kbd "C-<next>") 'centaur-tabs-forward)

;; Trailing white space
(setq-default show-trailing-whitespace t)

;; Prefer UTF-8.
(prefer-coding-system 'utf-8)

;; Improved handling of clipboard in GNU/Linux and otherwise.
(setq select-enable-clipboard t
      select-enable-primary t
      save-interprogram-paste-before-kill t)

;; Disable some GUI distractions.
(tool-bar-mode -1)
(menu-bar-mode -1)
(blink-cursor-mode 0)

;; Enable highlighting of current line.
(global-hl-line-mode 1)

;; Always show line and column number in the mode line.
(line-number-mode)
(column-number-mode)
