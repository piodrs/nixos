(setq inhibit-startup-message t
      initial-scratch-message nil
      use-short-answers t
      ring-bell-function #'ignore
      make-backup-files nil
      auto-save-default nil)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode 1)
(global-display-line-numbers-mode 1)
(global-hl-line-mode 1)
(electric-pair-mode 1)
(delete-selection-mode 1)

(add-to-list 'default-frame-alist '(font . "Iosevka-11"))
(set-face-attribute 'default nil :family "Iosevka" :height 110)
(set-face-attribute 'fixed-pitch nil :family "Iosevka" :height 110)
(set-face-attribute 'variable-pitch nil :family "Iosevka" :height 110)
(require 'gruber-darker-theme)
(load-theme 'gruber-darker t)

(require 'corfu)
(setq corfu-auto t
      corfu-auto-delay 0.15
      corfu-auto-prefix 2
      corfu-cycle t
      corfu-preselect 'prompt)
(global-corfu-mode 1)

(require 'orderless)
(setq completion-styles '(orderless basic)
      completion-category-defaults nil
      completion-category-overrides '((file (styles partial-completion))))

(require 'yasnippet)
(setq yas-snippet-dirs
      (list (expand-file-name "snippets" user-emacs-directory)))
(yas-global-mode 1)

(require 'envrc)
(envrc-global-mode 1)

(require 'eglot)
(require 'flymake-ruff)
(require 'reformatter)

(reformatter-define ruff-format
  :program "ruff"
  :args '("format" "-"))

(defun setup-c-mode ()
  (setq-local c-basic-offset 4
              tab-width 4
              indent-tabs-mode nil)
  (eglot-ensure))

(defun setup-js-mode ()
  (setq-local js-indent-level 2
              tab-width 2
              indent-tabs-mode nil)
  (eglot-ensure))

(defun setup-typescript-mode ()
  (setq-local typescript-indent-level 2
              typescript-ts-mode-indent-offset 2
              tab-width 2
              indent-tabs-mode nil)
  (eglot-ensure))

(defun setup-python-mode ()
  (setq-local python-indent-offset 4
              tab-width 4
              indent-tabs-mode nil)
  (eglot-ensure))

(defun setup-nix-mode ()
  (setq-local tab-width 2
              indent-tabs-mode nil)
  (eglot-ensure))

(add-to-list 'eglot-server-programs
             '((c-mode c-ts-mode)
               . ("clangd" "--background-index" "--clang-tidy")))
(add-to-list 'eglot-server-programs
             '((js-mode js-ts-mode typescript-mode typescript-ts-mode tsx-ts-mode)
               . ("typescript-language-server" "--stdio")))
(add-to-list 'eglot-server-programs
             '((python-mode python-ts-mode)
               . ("basedpyright-langserver" "--stdio")))
(add-to-list 'eglot-server-programs '(nix-mode . ("nil")))

(setq-default eglot-workspace-configuration
              '(:basedpyright (:analysis (:typeCheckingMode "basic"))
                :nil (:formatting (:command ["nixfmt"]))))

(defun setup-python-diagnostics ()
  (when (derived-mode-p 'python-mode 'python-ts-mode)
    (flymake-ruff-load)))

(defun format-code ()
  (interactive)
  (if (derived-mode-p 'python-mode 'python-ts-mode)
      (ruff-format-buffer)
    (eglot-format-buffer)))

(add-hook 'c-mode-hook #'setup-c-mode)
(add-hook 'c-ts-mode-hook #'setup-c-mode)
(add-hook 'js-mode-hook #'setup-js-mode)
(add-hook 'js-ts-mode-hook #'setup-js-mode)
(add-hook 'typescript-mode-hook #'setup-typescript-mode)
(add-hook 'typescript-ts-mode-hook #'setup-typescript-mode)
(add-hook 'tsx-ts-mode-hook #'setup-typescript-mode)
(add-hook 'python-mode-hook #'setup-python-mode)
(add-hook 'python-ts-mode-hook #'setup-python-mode)
(add-hook 'nix-mode-hook #'setup-nix-mode)
(add-hook 'eglot-managed-mode-hook #'setup-python-diagnostics)

(defun select-line ()
  (interactive)
  (let ((start (line-beginning-position))
        (end (line-beginning-position 2)))
    (goto-char start)
    (set-mark start)
    (goto-char end)
    (activate-mark)))

(defun duplicate-line-or-region ()
  (interactive)
  (let* ((region-active (use-region-p))
         (start (if region-active
                    (region-beginning)
                  (line-beginning-position)))
         (end (if region-active
                  (region-end)
                (line-beginning-position 2)))
         (text (buffer-substring start end)))
    (goto-char end)
    (insert text)
    (when region-active
      (set-mark end)
      (goto-char (+ end (length text))))))

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

(global-set-key (kbd "C-c l") #'select-line)
(global-set-key (kbd "C-c d") #'duplicate-line-or-region)
(global-set-key (kbd "M-<up>") #'move-line-up)
(global-set-key (kbd "M-<down>") #'move-line-down)
(global-set-key (kbd "C-c r") #'query-replace-regexp)
(global-set-key (kbd "C-c e r") #'eglot-rename)
(global-set-key (kbd "C-c e a") #'eglot-code-actions)
(global-set-key (kbd "C-c e f") #'format-code)
(global-set-key (kbd "C-c /") #'comment-dwim)
(global-set-key (kbd "C-c g") #'goto-line)
