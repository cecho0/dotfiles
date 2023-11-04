;;; ui.el
;;; code

(use-package all-the-icons
  :ensure t)

(use-package neotree
  :ensure t
  :config
  (setq neo-theme 'icons))

(use-package highlight-indent-guides
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
  (setq highlight-indent-guides-method 'character)
  (setq highlight-indent-guides-auto-character-face-perc 90)
  (setq highlight-indent-guides-responsive 'top))

; theme
(use-package gruvbox-theme
  :ensure t
  :config
  (load-theme 'gruvbox-dark-soft t))

; status line, doom-modeline
(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode)
  :config
  (setq doom-modeline-lsp t)
  (setq doom-modeline-total-line-number t)
  (setq doom-modeline-buffer-modification-icon t)
  (setq doom-modeline-buffer-name t))

(provide 'ui)

;;; ui.el ends
