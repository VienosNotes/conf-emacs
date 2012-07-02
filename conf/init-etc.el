(require 'ido)
(ido-mode t)
(if window-system (require 'change-buffer))

(autoload 'memo-mode "memo-mode" "Memo mode" t)

(require 'magit)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(show-paren-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(require 'dict)
(require 'popup)


;; auto-complete test
(add-to-list 'load-path "~/github/conf-emacs/auto-complete")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/github/conf-emacs/auto-complete/ac-dict")
(ac-config-default)

;; yasnippet test
(add-hook 'pre-command-hook
          (lambda ()
            (setq abbrev-mode nil)))

(require 'yasnippet)
(yas/initialize)
(yas/load-directory "~/github/conf-emacs/yasnippet/snippets")
(setq yas/trigger-key "TAB")
(setq save-abbrevs nil)

(setq vc-handled-backends nil)

;; evernote
(setq evernote-ruby-command "/usr/bin/ruby")
(require 'evernote-mode)
(setq evernote-username "vieno") ; optional: you can use this username as default.
(setq evernote-enml-formatter-command '("w3m" "-dump" "-I" "UTF8" "-O" "UTF8")) ; optional
(global-set-key "\C-c\C-ec" 'evernote-create-note)
(global-set-key "\C-c\C-eo" 'evernote-open-note)
(global-set-key "\C-c\C-es" 'evernote-search-notes)
(global-set-key "\C-c\C-eS" 'evernote-do-saved-search)
(global-set-key "\C-c\C-ew" 'evernote-write-note)
(global-set-key "\C-c\C-ep" 'evernote-post-region)
(global-set-key "\C-c\C-eb" 'evernote-browser)

(provide 'init-etc)
