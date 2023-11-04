;;; edit.el
;;; code

; use vim keybind
(use-package evil
  :ensure t
  :config
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (evil-mode)
  (with-eval-after-load 'evil-maps
    (define-key evil-motion-state-map (kbd "RET") nil)))
  (evil-set-leader 'normal (kbd ","))
  (evil-set-leader 'visual (kbd ","))
  (evil-set-leader 'motion (kbd ","))
  (evil-define-key 'normal 'global (kbd "gg") 'beginning-of-buffer)
  (evil-define-key 'normal 'global (kbd "ge") 'end-of-buffer)
  (evil-define-key 'visual 'global (kbd "ge") 'end-of-buffer)
  (evil-define-key 'visual 'global (kbd "ge") 'end-of-buffer)
  (evil-define-key 'normal 'global (kbd "<leader>a") 'beginning-of-line-text)
  (evil-define-key 'normal 'global (kbd "<leader>d") 'end-of-line)
  (evil-define-key 'visual 'global (kbd "<leader>a") 'beginning-of-line-text)
  (evil-define-key 'visual 'global (kbd "<leader>d") 'end-of-line)
  (evil-define-key 'normal 'global (kbd "<leader>o") 'other-window)
  (evil-define-key 'motion 'global (kbd "<leader>o") 'other-window)
  (evil-define-key 'normal 'global (kbd "<leader>fs") 'neotree-toggle)
  (evil-define-key 'normal 'global (kbd "<leader>ff") 'projectile-find-file)
  (evil-define-key 'normal 'global (kbd "<leader>fd") 'projectile-ripgrep)
  (evil-define-key 'normal 'global (kbd "<leader>fb") 'projectile-ibuffer)
  (evil-define-key 'normal 'global (kbd "gc") 'comment-line)
  (evil-define-key 'normal 'global (kbd "<leader> w") 'save-buffer)
  (evil-define-key 'normal 'global (kbd "<leader> q") 'kill-emacs)

; complete word in buffers
(use-package company
  :ensure t
  :config
  (global-company-mode 1)
  (setq-default company-minimum-prefix-length 1)
  (setq-default company-idle-delay 0)
  (define-key company-active-map (kbd "TAB") 'company-select-next)
  (define-key company-active-map (kbd "<backtab>") 'company-select-previous))

; complete minibuffer
(use-package vertico
  :ensure t
  :config
  (vertico-mode t))

(use-package orderless
  :ensure t
  :config
  (setq-default completion-styles '(orderless)))

(use-package marginalia
  :ensure t
  :config
  (marginalia-mode t))

(use-package consult
  :ensure t
  :config
  (global-set-key (kbd "C-s") 'consult-line))

(provide 'edit)

;;; edit.el ends
