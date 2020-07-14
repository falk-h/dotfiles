;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

;; Set windows to be maximized by default
(add-to-list 'default-frame-alist '(fullscreen . maximized))
;; Set default window size (in lines and columns)
(add-to-list 'default-frame-alist '(height . 45))
(add-to-list 'default-frame-alist '(width . 140))

;; use 4 spaces indentation everywhere
(setq-default tab-width 4)

;; Misc. variables
(setq
  ;; Regular font
  doom-font (font-spec :family "Roboto Mono" :size 13)
  ;; Non-monospace font
  doom-variable-pitch-font (font-spec :family "Roboto")
  ;; Monospace serif font (Haven't found any :/)
  doom-serif-font (font-spec :family "Roboto Mono")

  ;; Use Dvorak homerow keys for jumping
  avy-keys '(?a ?o ?e ?u ?i ?d ?h ?t ?n ?s)
  aw-keys '(?a ?o ?e ?u ?i ?d ?h ?t ?n ?s)

  ;; Allow alphabetical ordered lists in org-mode
  org-list-allow-alphabetical t

  ;; Hotkey completion popup delay (Default 1.0)
  which-key-idle-delay 0.3

  ;; Theme
  doom-vibrant-brighter-comments t
  doom-vibrant-comment-bg nil
  doom-theme 'doom-vibrant

  ;; Set the logo on the dashboard to ~/.doom.d/logo.png
  +doom-dashboard-banner-dir doom-private-dir
  +doom-dashboard-banner-file "logo.png"

  ;; Remove load time and GitHub link from dashboard
  +doom-dashboard-functions
  (delete 'doom-dashboard-widget-loaded (delete 'doom-dashboard-widget-footer +doom-dashboard-functions))

  ;; Don't show lsp code action suggestions
  lsp-ui-sideline-show-code-actions nil

;; Buffers are old if they're older than an hour, or if older than 15 minutes
;; and a special buffer.
  clean-buffer-list-delay-general (/ 1.0 24)
  clean-buffer-list-delay-special (* 60 15))
;; When a client closes its window, kill all old buffers.
(add-hook 'delete-frame-hook (lambda (_) (kill-buffer nil) (clean-buffer-list)))

;; Make s/S work like in Vim
(after! evil-snipe (evil-snipe-mode -1))

;; Make Javadoc style /** @foo */ comments the default for doc comments in C
(setq-default c-doc-comment-style 'javadoc)
(add-hook 'c-mode-common-hook 'c-setup-doc-comment-style)

;; Make // comments the default for C
(add-hook 'c-mode-common-hook (lambda () (c-toggle-comment-style -1)))

;; Make ex commands sorta case insensitive
(evil-ex-define-cmd "W"  'evil-write)
(evil-ex-define-cmd "Q"  'evil-quit)
(evil-ex-define-cmd "S"  'evil-ex-substitute)
(evil-ex-define-cmd "WA" 'evil-write-all)
(evil-ex-define-cmd "wA" 'evil-write-all)
(evil-ex-define-cmd "Wa" 'evil-write-all)
(evil-ex-define-cmd "WQ" 'evil-save-and-close)
(evil-ex-define-cmd "wQ" 'evil-save-and-close)
(evil-ex-define-cmd "Wq" 'evil-save-and-close)
(evil-ex-define-cmd "QA" 'evil-quit-all)
(evil-ex-define-cmd "qA" 'evil-quit-all)
(evil-ex-define-cmd "Qa" 'evil-quit-all)

;; Ex command to connect to a USB TTY
(evil-define-command tty ()
  "Start a serial terminal on /dev/ttyUSB0 with baud rate 115200"
  (serial-term "/dev/ttyUSB0" 115200))

;; Misc evil remappings
(map!
      ;; Increment/decrement and rotate text with C-a/C-S-a
      :n    "C-a"   #'rotate-text
      :n    "C-S-a" #'rotate-text-backward
      ;; Incremental increment/decrement in visual mode like in Vim
      :v    "C-a"   #'evil-numbers/inc-at-pt-incremental
      :v    "C-S-a" #'evil-numbers/dec-at-pt-incremental
      ;; Switch betweeen beginning of indent and beginning of line with ^
      :nvom "^"     #'doom/backward-to-bol-or-indent)
