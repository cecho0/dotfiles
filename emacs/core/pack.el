;;; pack.el, include some packages.
;;; code:

(require 'package)
(setq package-archives '(("gnu"   . "http://mirrors.cloud.tencent.com/elpa/gnu/")
  ("melpa" . "http://mirrors.cloud.tencent.com/elpa/melpa/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;;防止反复调用 package-refresh-contents 会影响加载速度
(when (not package-archive-contents)
  (package-refresh-contents))

(add-to-list 'load-path (expand-file-name "core/plugins" user-emacs-directory))
(require 'edit)
(require 'ui)
(require 'tools)

(provide 'pack)

;;; pack.el ends
