;;; init.el
;;; code

(let ((minver "25.1"))
  (when (version< emacs-version minver)
    (error "Your Emacs is too old -- this config requires v%s or higher" minver)))
(when (version< emacs-version "26.1")
  (message "Your Emacs is old, and some functionality in this config will be disabled. Please upgrade if possible."))

; load path
(add-to-list 'load-path (expand-file-name "core" user-emacs-directory))
(setq custom-file (expand-file-name "~/.emacs.d/core/custom.el"))

(require 'options)
(require 'user)
(require 'pack)

(load custom-file 'no-error 'no-message)
