;;; tools.el
;;; code

(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
  ("s-p" . projectile-command-map)
  ("C-c p" . projectile-command-map))
  :config
  (setq projectile-indexing-method 'hybrid)
  (setq projectile-sort-order 'recently-active)
  (setq projectile-file-exists-local-cache-expire (* 10 60))
  (setq projectile-file-exists-remote-cache-expire (* 10 60)))

(use-package projectile-ripgrep
  :ensure t
  :after (projectile))

(provide 'tools)

;;; tools.el ends
