(global-set-key "\C-c\C-d" 'popup-dict)
(global-set-key "\C-c d" 'popup-dict-search)

(defun popup-dict ()
 (interactive)
  (let ((search (thing-at-point 'word)))
    (popup-tip
     (shell-command-to-string 
      (concat "/Users/vieno/bin/dict-comline/dict " search " Japanese-English")))
    )
  )

(defun popup-dict-search ()
 (interactive)
  (let ((search (read-from-minibuffer "search: " (thing-at-point 'word))))
    (popup-tip
     (shell-command-to-string
      (concat "/Users/vieno/bin/dict-comline/dict " search " Japanese-English")))
    )
  )

(provide 'dict)
