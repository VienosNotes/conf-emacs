
;cc-mode
(require 'cc-mode)

;Perl mode
(require 'init-perl)
(require 'pod-mode)
(add-to-list 'auto-mode-alist
             '("\\.pod$" . pod-mode))
(add-hook 'pod-mode-hook
          '(lambda () (progn
                        (font-lock-mode)
                        (auto-fill-mode 1)
                        (flyspell-mode 1)
                        )))
(require 'set-perl5lib)

(defun cperlm (module)
   "Visit perl module's source file"
   (interactive 
    (list (let* ((default-entry (or (cperl-word-at-point) ""))
		 (input (read-string
			 (format "View perl module's source%s: "
				 (if (string= default-entry "")
				     ""
				   (format " (default %s)" default-entry))))))
	    (if (string= input "")
		(if (string= default-entry "")
		    (error "No Perl module given")
		  default-entry)
	      input))))
   (let ((file (substring (shell-command-to-string
			  (concat "~/perl5/perlbrew/perls/perl-5.14.0/bin/perldoc -ml " module))
			 0 -1)))
     (if (string-match "^No module found for " file)
	 (error file)
       (view-file-other-window file))))

;; (require 'perlbrew-mini)
;; (perlbrew-mini-use-latest)

;kag-mode
(autoload 'kag-mode "kag-mode" "Major mode for editing KAG scripts" t)

;Apatch-mode
(require 'apache-mode)

;trac-wiki-mode
(require 'trac-wiki)
(trac-wiki-define-project "VienosNotes" 
                           "http://127.0.0.1:8080/trac")
;YaTeX-mode
(require 'init-yatex)

;Perl6-mode
(require 'p6-exec)

;AppleScript-mode
(require 'applescript-mode)

;gdb-init
 (setq gdb-many-windows t)
  (setq gdb-use-separate-io-buffer t)

;Haskell-mode
(require 'haskell-mode)

;Pir-mode
(require 'pir-mode)

;RNC-mode
(require 'rnc-mode)

;nxml-mode
(add-hook 'nxml-mode-hook
          (lambda ()
            ;; 更新タイムスタンプの自動挿入
            (setq time-stamp-line-limit 10000)
            (if (not (memq 'time-stamp write-file-hooks))
                (setq write-file-hooks
                      (cons 'time-stamp write-file-hooks)))
            (setq time-stamp-format "%3a %3b %02d %02H:%02M:%02S %:y %Z")
            (setq time-stamp-start "Last modified:[ \t]")
            (setq time-stamp-end "$")
            ;;
            (setq auto-fill-mode -1)
            (setq nxml-slash-auto-complete-flag t)      ; スラッシュの入力で終了タグを自動補完
            (setq nxml-slash-auto-complete-flag t)      ; </の入力で閉じタグを補完する
            (setq nxml-sexp-element-flag t)             ; C-M-kで下位を含む要素全体をkillする
            (setq nxml-char-ref-display-glyph-flag nil) ; グリフは非表示
))

(require 'scheme-exec)


(provide 'init-lang)
