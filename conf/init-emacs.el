(provide 'init-emacs)

(load "dired-x")
(set-language-environment "Japanese")
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(blink-cursor-mode 0)
(which-function-mode 1)
(fset 'yes-or-no-p 'y-or-n-p)
(setq make-backup-files nil)
;(pc-selection-mode)

(defvar dired-mode-p nil)
(add-hook 'dired-mode-hook
(lambda ()
(make-local-variable 'dired-mode-p)
(setq dired-mode-p t)))
(setq frame-title-format-orig frame-title-format)
(setq frame-title-format '((buffer-file-name "%f"
(dired-mode-p default-directory
mode-line-buffer-identification))))

;; (defun reopen-file ()
;;   (interactive)
;;   (let ((file-name (buffer-file-name))
;;         (old-supersession-threat
;;          (symbol-function 'ask-user-about-supersession-threat))
;;         (point (point)))
;;     (when file-name
;;       (fset 'ask-user-about-supersession-threat (lambda (fn)))
;;       (unwind-protect
;;           (progn
;;             (erase-buffer)
;;             (insert-file file-name)
;;             (set-visited-file-modtime)
;;             (goto-char point))
;;         (fset 'ask-user-about-supersession-threat
;;               old-supersession-threat)))))
;; 　
;; ;(define-key ctl-x-map "C-r"  'reopen-file)
;; (global-set-key "\C-c\C-r" 'reopen-file)
