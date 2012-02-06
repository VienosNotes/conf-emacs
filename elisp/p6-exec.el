(global-set-key [?\C-c ?\C-6] 'p6-exec)

(defun p6-exec ()
 (interactive)  
    (popup-tip (concat "[Perl6 Execution]\n==============================\n"
     (shell-command-to-string 
;      (concat "/Users/vieno/bin/star/rakudo-star-2011.04 " (buffer-file-name)))))
      (concat "/Users/vieno/bin/rakudo/perl6 " (buffer-file-name)))))
  )

(provide 'p6-exec)
