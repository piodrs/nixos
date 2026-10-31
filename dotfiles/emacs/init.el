;;; init.el -*- lexical-binding: t; -*-

(setopt inhibit-startup-message t
        initial-scratch-message nil
        use-short-answers t
        ring-bell-function #'ignore
        make-backup-files nil
        auto-save-default nil)

(setq-default indent-tabs-mode nil
              display-line-numbers-type 'relative
              tab-width 4
              c-ts-mode-indent-offset 4
              python-indent-offset 4
              python-indent-guess-indent-offset nil
              js-indent-level 2
              typescript-indent-level 2
              typescript-ts-mode-indent-offset 2)

(add-hook 'c-mode-common-hook (lambda () (setq-local c-basic-offset 4)))
(add-hook 'go-mode-hook (lambda () (setq-local indent-tabs-mode t)))
(add-hook 'nix-mode-hook (lambda () (setq-local tab-width 2)))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode 1)
(global-display-line-numbers-mode 1)
(global-hl-line-mode 1)
(electric-pair-mode 1)
(delete-selection-mode 1)

(dolist (face '(default fixed-pitch variable-pitch))
  (set-face-attribute face nil :family "Iosevka" :height 110))

(defun select-line ()
  (interactive)
  (beginning-of-line)
  (set-mark (point))
  (forward-line))

(defun move-line-up ()
  (interactive)
  (when (= (line-beginning-position) (point-min))
    (user-error "Already at the first line"))
  (transpose-lines 1)
  (forward-line -2))

(defun move-line-down ()
  (interactive)
  (when (= (line-end-position) (point-max))
    (user-error "Already at the last line"))
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1))

(defun format-code ()
  (interactive)
  (if (derived-mode-p 'python-base-mode)
      (ruff-format-buffer)
    (eglot-format-buffer)))

(defun setup-python-diagnostics ()
  (when (derived-mode-p 'python-base-mode)
    (flymake-ruff-load)))

(use-package emacs
  :bind (("C-c l" . select-line)
         ("C-c d" . duplicate-dwim)
         ("M-<up>" . move-line-up)
         ("M-<down>" . move-line-down)
         ("C-c r" . query-replace-regexp)
         ("C-c e f" . format-code)
         ("C-c /" . comment-dwim)
         ("C-c f" . dired-jump)
         ("C-c g" . goto-line)
         ("<f5>" . shell-command)
         ("<f6>" . compile)))

(use-package gruber-darker-theme
  :config (load-theme 'gruber-darker t))

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.15)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :config (global-corfu-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package yasnippet
  :custom (yas-snippet-dirs (list (expand-file-name "snippets" user-emacs-directory)))
  :config (yas-global-mode))

(use-package envrc
  :hook (after-init . envrc-global-mode))

(use-package multiple-cursors
  :bind ("C-c m" . mc/mark-all-dwim))

(use-package reformatter
  :config
  (reformatter-define ruff-format
    :program "ruff"
    :args '("format" "-")))

(use-package flymake-ruff
  :commands flymake-ruff-load)

(use-package eglot
  :hook ((c-mode c-ts-mode
          js-mode js-ts-mode
          typescript-mode typescript-ts-mode tsx-ts-mode
          go-mode
          python-base-mode
          nix-mode)
         . eglot-ensure)
  :bind (("C-c e r" . eglot-rename)
         ("C-c e a" . eglot-code-actions))
  :config
  (add-to-list 'eglot-server-programs
               '((c-mode c-ts-mode)
                 . ("clangd" "--background-index" "--clang-tidy")))
  (add-to-list 'eglot-server-programs
               '((js-mode js-ts-mode
                  typescript-mode typescript-ts-mode tsx-ts-mode)
                 . ("typescript-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode)
                 . ("basedpyright-langserver" "--stdio")))
  (setq-default eglot-workspace-configuration
                '(:basedpyright (:analysis (:typeCheckingMode "basic"))
                  :nil (:formatting (:command ["nixfmt"])))))

(add-hook 'python-base-mode-hook #'ruff-format-on-save-mode)
(add-hook 'eglot-managed-mode-hook #'setup-python-diagnostics)
