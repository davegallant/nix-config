;; Enable Mouse
(xterm-mouse-mode)

;; Enable xclip
(require 'xclip)
(define-globalized-minor-mode global-xclip-mode
  xclip-mode xclip-mode)
(global-xclip-mode 1)

;; Set up fonts early.
(set-face-attribute 'default
                     nil
                     :height 120
                     :family "Fira Code Mono")
(set-face-attribute 'variable-pitch
                     nil
                     :family "Fira CodeSans")

;; Fix clipboard
(setq select-enable-clipboard t)

;; Enable Line Numbers
(global-display-line-numbers-mode 1)

;; Disable lock files
(setq create-lockfiles nil)

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
(setq centaur-tabs-style "bar"
      centaur-tabs-height 32
      centaur-tabs-set-icons t
      centaur-tabs-set-modified-marker t
      centaur-tabs-set-bar 'under
      x-underline-at-descent-line t)

;; Trailing white space
(setq-default show-trailing-whitespace t)

;; Prefer UTF-8.
(prefer-coding-system 'utf-8)

;; Disable some GUI distractions.
(tool-bar-mode -1)
(menu-bar-mode -1)
(blink-cursor-mode 0)

;; Enable highlighting of current line.
(global-hl-line-mode 1)

;; Always show line and column number in the mode line.
(line-number-mode)
(column-number-mode)

;; Increment and decrement numbers easily
(global-set-key (kbd "C-c +") 'evil-numbers/inc-at-pt)
(global-set-key (kbd "C-c -") 'evil-numbers/dec-at-pt)

;; Enable Mouse scrolling
(unless (display-graphic-p)
  ;; activate mouse-based scrolling
  (xterm-mouse-mode 1)
  (global-set-key (kbd "<mouse-4>") 'scroll-down-line)
  (global-set-key (kbd "<mouse-5>") 'scroll-up-line)
  )

;; Enable Flycheck
(global-flycheck-mode)
(setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc))

;; An easier way to toggle comments
(evil-commentary-mode)
