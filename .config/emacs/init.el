;;; -*- lexical-binding: t -*-

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar


(setq visible-bell       nil
      ring-bell-function #'ignore)

(column-number-mode) ; Show column number

(set-face-attribute 'default nil :font "Iosevka Custom" :height 200)

(setq make-backup-files nil) ; Disable backup files


;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(blink-cursor-mode 0)

(use-package almost-mono-themes
  :config
  ;;  (load-theme 'almost-mono-white t))
  ;; (load-theme 'almost-mono-black t)
  ;; (load-theme 'almost-mono-gray t)
  ;; (load-theme 'almost-mono-cream t)
  (load-theme 'almost-mono-gray t))

(unless (package-installed-p 'org-mode)
  (package-vc-install '(org-mode :url "https://code.tecosaur.net/tec/org-mode" :branch "dev")))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))


;; Minimal UI completion frontend
(use-package vertico
  :init
  (vertico-mode))

;; Adds annotations in the minibuffer (like file sizes, buffer info, etc.)
(use-package marginalia
  :after vertico
  :init
  (marginalia-mode))

;; Flexible fuzzy matching
(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides
        '((file (styles basic partial-completion)))))

;; Consult: provides search/navigation commands
(use-package consult
  :bind (("C-s"     . consult-line)        ;; search in buffer
         ("C-x b"   . consult-buffer)      ;; switch buffer
         ("C-x C-f" . consult-find)        ;; find files
         ("M-g g"   . consult-goto-line)   ;; go to line
         ("M-s r"   . consult-ripgrep)     ;; grep in project
         ("M-s l"   . consult-line-multi)) ;; search across buffers
  :config
  ;; If fd is available, prefer it over find
  (when (executable-find "fd")
    (setq consult-find-command "fd --hidden --exclude .git --color=never --full-path ARG OPTS")))

;; Optional: Embark gives you actions on candidates (like Telescope’s action menu)
(use-package embark
  :bind
  (("C-." . embark-act)         ;; act on thing at point
   ("C-;" . embark-dwim)        ;; do what I mean
   ("C-h B" . embark-bindings)) ;; show keybindings
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; Org-mode
(defvar org-babel-default-header-args '((:results . "output") (:noweb . "yes")))

(defvar org-babel-default-header-args:jupyter '((:results . "output") (:kernel . "python3") (:session . "hello") (:async . "yes")))

(defun org-enter-maybe-execute ()
  (interactive)
  (if (org-in-src-block-p)
      (org-babel-execute-src-block)
    (newline)))

(use-package latex-preview-pane)
(use-package org-fragtog
  :after org 
  :config (setq org-preview-latex-image-directory (concat (getenv "HOME") "/.cache"))
  ;; :custom (org-startup-with-latex-preview t)
  :hook (org-mode . org-fragtog-mode)
  :hook (org-babel-after-execute . org-redisplay-inline-images) ;; render plots automatically
  :custom
  (org-format-latex-options
   (plist-put org-format-latex-options :scale 2)
   (plist-put org-format-latex-options :foreground 'auto)
   (plist-put org-format-latex-options :background 'auto)))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   ;; (C . t)
   (python . t)
   ;; (css . t)
   ;; (jupyter . t)
   (shell . t)))


(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i --simple-prompt")

(require 'org)
;; (use-package org-preview-html)
(setq org-src-preserve-indentation nil
      org-export-wth-toc nil
      org-src-tab-acts-natively t
      org-confirm-babel-evaluate nil
      org-startup-indented t
      org-return-follows-link t
      org-hide-emphasis-markers t)

(add-to-list 'org-babel-after-execute-hook (function org-latex-preview))
(setq org-latex-compiler "lualatex")

(setq org-preview-latex-default-process 'dvisvgm)
(setq org-preview-latex-process-alist
      '((dvisvgm :programs ("lualatex" "dvisvgm")
                 :description "pdf > svg"
                 :message "You need to install lualatex and dvisvgm."
                 :image-input-type "pdf"
                 :image-output-type "svg"
                 :image-size-adjust (1.7 . 1.5)
                 :latex-compiler ("lualatex -interaction=nonstopmode -shell-escape -output-directory=%o %f")
                 :image-converter ("dvisvgm %f -n -b min -c %S -o %O"))))


;; Optional: auto-enable preview on entering org-mode
(add-hook 'org-mode-hook #'org-latex-preview-auto-mode)


(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-f") #'consult-find)
  (define-key evil-normal-state-map (kbd "C-b") #'consult-buffer))

(with-eval-after-load 'vertico
  (define-key vertico-map (kbd "C-j") #'vertico-next)
  (define-key vertico-map (kbd "C-k") #'vertico-previous))

;; Formatter
(use-package apheleia
  :ensure t
  :config
  (setf (alist-get 'python-mode apheleia-mode-alist) '(black))
  (setf (alist-get 'c-mode apheleia-mode-alist) '(clang-format))
  ;; Enable globally
  (apheleia-global-mode +1))
