(setq load-path
      (append
       (list (expand-file-name "~/github/conf-emacs/conf")) load-path))

 (setq load-path
       (append
        (list (expand-file-name "~/github/conf-emacs/elisp")) load-path))

(setq load-path
      (append
       (list(expand-file-name "~/github/conf-emacs/yasnippet")) load-path))

(setq load-path (cons "~/github/conf-emacs/yatex" load-path))

(setq load-path
       (append
        (list (expand-file-name "~/github/conf-emacs/elisp/haskell-mode-2.4")) load-path))
(setq load-path
       (append
        (list (expand-file-name "~/github/conf-emacs/elisp/w3m")) load-path))

(add-to-list 'load-path "~/lib/magit/share/emacs/site-lisp/")
(add-to-list 'exec-path "/usr/local/bin")
(add-to-list 'exec-path "~/bin/rakudo")

(setq exec-path (cons "~/bin/rakudo" exec-path))
(setenv "PATH"
	(concat '"/usr/local/bin:" (getenv "PATH")))
(setenv "PATH"
	(concat '"~/bin/rakudo:" (getenv "PATH")))
(setenv "PERL6LIB"
	(concat '"./lib:../lib:" (getenv "PERL6LIB")))
(setenv "PERL5LIB" (getenv "PERL5LIB"))

(setq exec-path (cons "~/perl5/perlbrew/perls/perl-5.14.0/bin" exec-path))


;Emacs initialize
(require 'init-emacs)
(require 'init-modeline)
(require 'init-key)
(require 'snippet-util)


;; (require 'perlbrew)
;; (perlbrew-switch "perl-5.14.0")


;Programming Language

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

(require 'ido)
(ido-mode t)

;kag-mode
(autoload 'kag-mode "kag-mode" "Major mode for editing KAG scripts" t)
(if window-system (require 'change-buffer))

(autoload 'memo-mode "memo-mode" "Memo mode" t)
(require 'apache-mode)

;====================ここより下はテスト領域====================

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

(require 'trac-wiki)
(trac-wiki-define-project "VienosNotes" 
                           "http://127.0.0.1:8080/trac")

;; auto-complete test
(add-to-list 'load-path "~/github/conf-emacs/auto-complete")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/github/conf-emacs/auto-complete/ac-dict")
(ac-config-default)

(require 'init-yatex)

;; face settings
(if window-system
    (progn
	  (require 'init-color)
	  (require 'init-font)))

(require 'p6-exec)

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

(require 'applescript-mode)


(require 'set-perl5lib)

(when (locate-library "flymake")
  (require 'flymake)

  ;;シンタックスチェックは次のコマンドが呼ばれる
  ;;make -s -C . CHK_SOURCES=hoge.cpp SYNTAX_CHECK_MODE=1 check-syntax
  ;;
  ;; Makefile があれば、次のルールを追加
  ;;PHONY: check-syntax
  ;;#check-syntax:
  ;;#	$(CC) -Wall -Wextra -pedantic -fsyntax-only $(CHK_SOURCES)
  ;;
  ;;CHECKSYNTAX.c = $(CC) $(CFLAGS) $(CPPFLAGS) -Wall -Wextra -pedantic -fsyntax-only
  ;;CHECKSYNTAX.cc = $(CXX) $(CXXFLAGS) $(CPPFLAGS) -Wall -Wextra -pedantic -fsyntax-only
  ;;
  ;;check-syntax: $(addsuffix -check-syntax,$(CHK_SOURCES))
  ;;%.c-check-syntax:  ; $(CHECKSYNTAX.c)  $*.c
  ;;%.cc-check-syntax: ; $(CHECKSYNTAX.cc) $*.cc


  ;; GUIの警告は表示しない
  (setq flymake-gui-warnings-enabled nil)

  ;; 全てのファイルで flymakeを有効化
  ;;(add-hook 'find-file-hook 'flymake-find-file-hook)

  ;; flymake を使えない場合をチェック
  (defadvice flymake-can-syntax-check-file
    (after my-flymake-can-syntax-check-file activate)
    (cond
     ((not ad-return-value))
     ;; tramp 経由であれば、無効
     ((and (fboundp 'tramp-list-remote-buffers)
	   (memq (current-buffer) (tramp-list-remote-buffers)))
      (setq ad-return-value nil))
     ;; 書き込み不可ならば、flymakeは無効
     ((not (file-writable-p buffer-file-name))
      (setq ad-return-value nil))
     ;; flymake で使われるコマンドが無ければ無効
     ((let ((cmd (nth 0 (prog1
			    (funcall (flymake-get-init-function buffer-file-name))
			  (funcall (flymake-get-cleanup-function buffer-file-name))))))
	(and cmd (not (executable-find cmd))))
      (setq ad-return-value nil))
     ))

  ;; M-p/M-n で警告/エラー行の移動
  (global-set-key "\M-p" 'flymake-goto-prev-error)
  (global-set-key "\M-n" 'flymake-goto-next-error)

  ;; 警告エラー行の表示
  ;;(global-set-key "\C-cd" 'flymake-display-err-menu-for-current-line)
  (global-set-key "\C-cd"
		  '(lambda ()
		     (interactive)
		     ;;(my-flymake-display-err-minibuf-for-current-line)
		     (my-flymake-display-err-popup.el-for-current-line)
		     ))

  ;; Minibuf に出力
  (defun my-flymake-display-err-minibuf-for-current-line ()
    "Displays the error/warning for the current line in the minibuffer"
    (interactive)
    (let* ((line-no             (flymake-current-line-no))
	   (line-err-info-list  (nth 0 (flymake-find-err-info flymake-err-info line-no)))
	   (count               (length line-err-info-list)))
      (while (> count 0)
	(when line-err-info-list
	  (let* ((text       (flymake-ler-text (nth (1- count) line-err-info-list)))
		 (line       (flymake-ler-line (nth (1- count) line-err-info-list))))
	    (message "[%s] %s" line text)))
	(setq count (1- count)))))

  ;; popup.el を使って tip として表示
  (defun my-flymake-display-err-popup.el-for-current-line ()
    "Display a menu with errors/warnings for current line if it has errors and/or warnings."
    (interactive)
    (let* ((line-no             (flymake-current-line-no))
	   (line-err-info-list  (nth 0 (flymake-find-err-info flymake-err-info line-no)))
	   (menu-data           (flymake-make-err-menu-data line-no line-err-info-list)))
      (if menu-data
	  (popup-tip (mapconcat '(lambda (e) (nth 0 e))
				(nth 1 menu-data)
				"\n")))
      ))

  (defun flymake-simple-generic-init (cmd &optional opts)
    (let* ((temp-file   (flymake-init-create-temp-buffer-copy
			 'flymake-create-temp-inplace))
	   (local-file  (file-relative-name
			 temp-file
			 (file-name-directory buffer-file-name))))
      (list cmd (append opts (list local-file)))))

  ;; Makefile が無くてもC/C++のチェック
  (defun flymake-simple-make-or-generic-init (cmd &optional opts)
    (if (file-exists-p "Makefile")
	(flymake-simple-make-init)
      (flymake-simple-generic-init cmd opts)))

  (defun flymake-c-init ()
    (flymake-simple-make-or-generic-init
     "gcc" '("-Wall" "-Wextra" "-std=c99" "-pedantic" "-fsyntax-only")))

  (defun flymake-cc-init ()
    (flymake-simple-make-or-generic-init
     "g++" '("-Wall" "-Wextra" "-pedantic" "-fsyntax-only")))

  (push '("\\.[cCmM]\\'" flymake-c-init) flymake-allowed-file-name-masks)
  (push '("\\.\\(?:cc\|cpp\|CC\|CPP\\)\\'" flymake-cc-init) flymake-allowed-file-name-masks)

  ;; Invoke ruby with '-c' to get syntax checking
  (when (executable-find "ruby")
    (defun flymake-ruby-init ()
      (flymake-simple-generic-init
       "ruby" '("-c")))

    (push '(".+\\.rb\\'" flymake-ruby-init) flymake-allowed-file-name-masks)
    (push '("Rakefile\\'" flymake-ruby-init) flymake-allowed-file-name-masks)

    (push '("^\\(.*\\):\\([0-9]+\\): \\(.*\\)$" 1 2 nil 3) flymake-err-line-patterns)
    )

  ;; bash チェック
  (defvar flymake-shell-of-choice
    "bash"
    "Path of shell.")

  (defvar flymake-shell-arguments
    (list "-n")
    "Shell arguments to invoke syntax checking.")

  (defun flymake-shell-init ()
    (flymake-simple-generic-init
     flymake-shell-of-choice flymake-shell-arguments))

  (push '(".+\\.sh\\'" flymake-shell-init) flymake-allowed-file-name-masks)
  (push '("^\\(.+\\): line \\([0-9]+\\): \\(.+\\)$" 1 2 nil 3) flymake-err-line-patterns)


(defun flymake-perl-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name
                      temp-file
                      (file-name-directory buffer-file-name))))
    (list "/usr/bin/perl" (list "-MProject::Libs" "-wc" local-file))))


  )
(defun credmp/flymake-display-err-minibuf ()
  "Displays the error/warning for the current line in the minibuffer"
  (interactive)
  (let* ((line-no             (flymake-current-line-no))
         (line-err-info-list  (nth 0 (flymake-find-err-info flymake-err-info line-no)))
         (count               (length line-err-info-list)))
    (while (> count 0)
      (when line-err-info-list
        (let* ((file       (flymake-ler-file (nth (1- count) line-err-info-list)))
               (full-file  (flymake-ler-full-file (nth (1- count) line-err-info-list)))
               (text (flymake-ler-text (nth (1- count) line-err-info-list)))
               (line       (flymake-ler-line (nth (1- count) line-err-info-list))))
          (message "[%s] %s" line text)))
      (setq count (1- count)))))
(global-set-key "\C-ce" 'credmp/flymake-display-err-minibuf)

(push '("\\(.*\\) at \\([^ \n]+\\) line \\([0-9]+\\)[,.\n]" 2 3 nil 1) flymake-err-line-patterns)
(add-hook 'cperl-mode-hook
 '(lambda ()
    (defadvice flymake-post-syntax-check (before flymake-force-check-was-interrupted)
      (setq flymake-check-was-interrupted t))
    (ad-activate 'flymake-post-syntax-check)
    (define-key cperl-mode-map "\C-cd" 'credmp/flymake-display-err-minibuf)
    (set-perl5lib)
    (flymake-mode)))

;; gdb-init
 (setq gdb-many-windows t)
  (setq gdb-use-separate-io-buffer t)


(require 'haskell-mode)


;;実験

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

 (require 'perlbrew-mini)
  (perlbrew-mini-use-latest)

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

(require 'pir-mode)
(require 'rnc-mode)

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

(set-cursor-color "rgb:99/33/33")
(require 'scheme-exec)
