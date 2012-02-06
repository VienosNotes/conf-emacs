(provide 'init-perl)



(autoload 'cperl-mode
  "cperl-mode"
  "alternate mode for editing Perl programs" t)
(setq cperl-indent-level 4
      cperl-continued-statement-offset 4
      cperl-close-paren-offset -4
      cperl-comment-column 40
      cperl-highlight-variables-indiscriminately t
      cperl-indent-parens-as-block t
      cperl-label-offset -4
      cperl-tab-always-indent nil
      cperl-font-lock t)
(add-hook 'cperl-mode-hook
          '(lambda ()
             (progn
               (setq indent-tabs-mode nil)
               (setq tab-width nil)
	       (set-face-bold-p 'cperl-array-face nil)
	       (set-face-background 'cperl-array-face "black")
	       (set-face-foreground 'cperl-array-face "peru")
	       (set-face-bold-p 'cperl-hash-face nil)
	       (set-face-italic-p 'cperl-hash-face nil)
	       (set-face-background 'cperl-hash-face "black")
	       (set-face-foreground 'cperl-hash-face "Chocolate")
               )))
(setq auto-mode-alist
      (append (list (cons "\\.\\(pl\\|pm\\)$" 'cperl-mode))
              auto-mode-alist))
