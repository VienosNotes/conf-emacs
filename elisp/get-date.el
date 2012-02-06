;;; 
;;; get-date.el: Return or insert date string.
;;; 
;;;     [1996/10/18] OSHIRO Naoki. Divide from c-aide.el.
;;;   
;;;     $Log:$
;;;

(defun get-date ()
  (interactive)
  (let ((date (current-time-string)))
    (setq date 
	  (concat "[" (substring date 20 24) "/"
		  (get-date:month-to-strnum (substring date 4 7)) "/"
		  (get-date:num-to-strnum   (substring date 8 10)) "]"
		  ))
    (if (interactive-p) (insert date) date)))

(defun get-dtime ()
  (interactive)
  (let ((date (current-time-string)))
    (setq date 
	   (concat "[" (substring date 20 24) "/"
		   (get-date:month-to-strnum (substring date 4 7)) "/"
		   (get-date:num-to-strnum   (substring date 8 10)) " "
		   (substring date 11 16) "]"))
     (if (interactive-p) (insert date) date)))

(defun get-time ()
  (interactive)
  (let ((date (current-time-string)))
     (setq date (concat "[" (substring date 11 16) "]"))
     (if (interactive-p) (insert date) date)))

(defun search-forward-time-string ()
  (re-search-forward "[0-9][0-9]:[0-9][0-9]"))

(defun get-date:month-to-strnum (str)
  "月を示す文字列から数字文字列に変換(当てはまらない場合は00)"
  (let (mm)
    (if (setq mm (assoc str
			'(("Jan" . "01")("Feb" . "02")("Mar" . "03")("Apr" . "04")
			  ("May" . "05")("Jun" . "06")("Jul" . "07")("Aug" . "08")
			  ("Sep" . "09")("Oct" . "10")("Nov" . "11")("Dec" . "12"))))
	(cdr mm)
      "00")))

(defun get-date:num-to-strnum (str)
  "月を示す文字列から数字文字列に変換(当てはまらない場合はそのまま)"
  (let (mm)
    (if (setq mm (assoc str
	'((" 1" . "01")(" 2" . "02")(" 3" . "03")(" 4" . "04")
	  (" 5" . "05")(" 6" . "06")(" 7" . "07")(" 8" . "08")
	  (" 9" . "09"))))
	(cdr mm)
      str)))

(provide 'get-date)

;;; end of get-date.
