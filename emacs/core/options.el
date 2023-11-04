;;; options.el
;;; code

;; variable
;; 关闭emacs临时文件
(setq-default auto-save-default nil)
;; 关闭备份文件
(setq-default make-backup-files nil)
(setq-default tab-always-indent 'complete)
;; some options
(setq-default inhibit-startup-message -1)
(setq-default display-raw-control-chars t)
(setq-default indent-tabs-mode t)
(setq-default tab-width 4)
(setq-default standard-indent 4)
(setq-default c-basic-offset 4)
(when (display-graphic-p) (toggle-scroll-bar -1))

;; hooks
(add-hook 'prog-mode-hook #'show-paren-mode)

;; minor mode
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(line-number-mode t)
(column-number-mode t)
(global-display-line-numbers-mode t)
(delete-selection-mode t)
(global-hl-line-mode 1)
(electric-pair-mode t)
(global-auto-revert-mode t)
(savehist-mode 1)

(defun my_tabs_makefile_hook ()
  (setq indent-tabs-mode t))

(defun my_tabs_space_hook ()
  (setq indent-tabs-mode t)
  (setq tab-width 2)
  (setq-default standard-indent 2)
  (setq-default c-basic-offset 2))

(add-hook 'makefile-mode-hook 'my_tabs_makefile_hook)
(add-hook 'ELisp-mode-hook 'my_tabs_space_hook)

;;(setq display-line-numbers-type 'relative)
;;(add-to-list 'default-frame-alist '(width . 90))  ; （可选）设定启动图形界面时的初始 Frame 宽度（字符数）
;;(OBadd-to-list 'default-frame-alist '(height . 55)) ; （可选）设定启动图形界面时的初始 Frame 高度（字符数）

(provide 'options)

;;; options.el ends
