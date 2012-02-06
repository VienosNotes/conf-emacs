(require 'snippet)


(add-hook 'kag-mode-hook
           '(lambda ()
			  (setq-default abbrev-mode t)
			  (snippet-with-abbrev-table 'local-abbrev-table 
	  ("pn" . "[name s=\"p\"]")
	  ("yn" . "[name s=\"‚â‚æ‚¢\"]")
	  ("p" . "[p][cm]")
	  ("l" . "[l]")
	  ("r" . "[r]")
	  ("lr" . "[l][r]")
	  ("n" . "[name s=\"$${name}\"]")
	  ("img" . "[image layer=$${1} page=$${fore} storage=\"$${filename}\" top=$${100} right=$${340}]")
	  )
))
(provide 'snippet-util)