;;;-*- Emacs-Lisp -*- 

;;; 
;;; memo.el: ¥á¥â½ñ¤­¥â¡¼¥É (memo mode with autoliner type for Emacs/Mule.)
;;; 
;;;     Jan.28,'96. OSHIRO Naoki.
;;;   
;;;     $Log: memo-mode.el,v $
;;;
;;;     Revision 1.3  1997/12/17 18:56:23  oshiro
;;;     *** empty log message ***
;;;
;;;     Revision 1.1  1996/10/07 18:34:30+09  oshiro
;;;     Initial revision
;;;
;;;
;;;  [1996/04/04] Add indentation function.
;;;  [1996/07/01] Correct TAB regular expression.
;;;  [1996/09/06] memo-new-entry
;;;  [1996/09/20] Add third argument 't' to re-search-*.
;;;  [1996/09/24] Reinforcement indent function with smart previous 
;;;               line observation.
;;;  [1996/10/04] Make thread-indent* (function declaration only :->).
;;;  [1996/10/08] Write actual contents thread-indent*.
;;;  [1996/10/15] add memo-delete-char
;;;  [1996/10/18] fix memo-indent (add save-excursion)
;;;               replace string-width to length (for Emacs compatibility)
;;;  [1996/10/22] change memo-delete-char behavior:
;;;               it don't delete spaces on end of line.
;;;  [1996/10/23] fix indent for empty-line.
;;;               change memo-beginning-of-line more smart.
;;;               change cursor point after memo-indent to fit behavior.
;;;  [1996/10/28] Make memo-kill-entry.
;;;  [1996/10/29] fix memo-indent.
;;;  [1997/01/09] bind auto-fill-mode.
;;;  [1997/08/20] Add memo-skip-header.
;;;  [1997/09/14] new-entry fixed behavior on entry-separated-tag line. 
;;;               Changed behavior kill-entry which start point 
;;;               as next line of entry-separated-tag.
;;;               Add copy-entry-as-kill, and bind to key-map.
;;;  [1997/12/05] Map memo-indet function to indent-line-function.
;;;               Change function name memo-indent to memo-indent-line.
;;;               Comment out setq of auto-fill-hook
;;;               (because obsolete variable?).
;;;  [1997/12/07] Add memo-indent-new-comment-line function
;;;               (take from YaTeX package).
;;;  [1997/12/12] Add memo-{next|previous}-entry.
;;;  [1997/12/18] Change action of memo-previous-line-indent function
;;;               that don't change left-margin variable and return number
;;;               of indent column.
;;;               Add memo-current-line-indent function.
;;;               Add memo-item-line-indent function.
;;;               Add memo-delete-backward-char function.
;;;  [1998/01/18] Change memo-item-line-indent
;;;               (re-search-backward memo-entry-separated-tag).
;;;  [1998/01/23] Add set-window-start to memo-skip-header.
;;;  [1998/01/24] Add memo-description, memo-get-header-description, 
;;;  [1998/04/01] Add memo-entry-move-to-{top|last}.
;;;  [1998/08/28] Add memo-mode-header.
;;;  [1998/12/30] Summary mode created.
;;;  [1999/01/20] Summary header truncate suitable for window width.
;;;  [1999/01/24] Kawamura patch
;;;               outline-mode setting fix.
;;;               case apply hilit19 and font-lock.
;;;               summary-mode fix.
;;;  [1999/01/24] Kawamura patch
;;;               summary buffer read only.
;;;               font-lock.
;;;  [1999/01/25] Add memo-edit-other-file function.
;;;               Add memo-get-file-tag-at-line function.
;;;               Key-bind 'C-c LETTER' changed to suitable one.
;;;  [1999/01/26] Add memo-open-tag function.
;;;               Add memo-send-url-to-browser function.
;;;  [1999/01/27] open-tag: change shell-command to start-process.
;;;  [1999/06/21] memo-delete-backward-char fix.
;;;  [1999/07/02] memo-delete-backward-char/memo-indent-line keep memo-item.
;;;  [1999/07/05] memo-show/hide-thread,show-thread,hide-thread.
;;;  [2000/01/01] add variable for date display control
;;;               (memo-summary-with-date).
;;;  [2000/02/07] Add memo-toggle-summary-display (and 't' keymap).
;;;  [2000/02/12] Fix window split when summary display.
;;;  [2001/05/08] Add 'news:' tag to open-tag related functions.
;;;

;;;
;;; Configuration:
;;;
;;;   Insert follow line in your ~/.emacs file
;;;
;;;     (autoload 'memo-mode "memo-mode" "Memo mode" t)
;;;

;;;

(require 'get-date)

(defvar memo-mode-hook nil "")
(defvar memo-mode-map nil "")
(defvar memo-prefix-map nil "")
(defvar memo-prefix "\C-c" "Memo prefix")
(defvar memo-indent-level 2 "*Indentation of Memo statements.")
(defvar memo-item-default "-->")
(defvar memo-item memo-item-default)
;;[1999/03/11]
(defvar memo-entry-separated-tag "^---+[ \t]*$")
(defvar memo-comment-prefix "#")
(defvar memo-fill-prefix "")
(defvar memo-fill-column 70)
;;[1999/03/11]
(defvar memo-paragraph-start (concat "\\([ \t]*" memo-item "\\)\\|\\(" memo-entry-separated-tag "\\)\\|\\(^\\|^[ \t]*$\\)"))
(defvar memo-paragraph-separate (concat "\\([ \t]*" memo-item "\\)\\|\\(" memo-entry-separated-tag "\\)\\|\\(^\\|^[ \t]*$\\)"))
(defvar Memo-version "$Id: memo-mode.el,v 1.1 1999/02/27 12:36:41 u Exp $")

(if memo-mode-map
    ()
  (setq memo-mode-map   (make-sparse-keymap))
  (setq memo-prefix-map (make-sparse-keymap))
  (define-key memo-mode-map memo-prefix memo-prefix-map)
  (define-key memo-mode-map "a"  'memo-beginning-of-line)
  ;(define-key memo-mode-map "p"  'memo-previous-line)
  ;(define-key memo-mode-map "n"  'memo-next-line)
  (define-key memo-mode-map "p"  'memo-previous-entry)
  (define-key memo-mode-map "n"  'memo-next-entry)
  (define-key memo-mode-map "\C-a" 'memo-beginning-of-line)
  (define-key memo-mode-map "\C-m" 'memo-newline-and-indent)
  (define-key memo-mode-map "\C-d" 'memo-delete-char)
  (define-key memo-mode-map ""   'memo-delete-backward-char)
  (define-key memo-mode-map "\t" 'memo-indent-line)
  (define-key memo-prefix-map "\C-d" 'get-date)
  (define-key memo-prefix-map "\ed" 'get-dtime)
  (define-key memo-prefix-map "\C-t" 'get-time)
  (define-key memo-prefix-map "=" 'memo-summary-this-buffer)
  ;(define-key memo-prefix-map "=" 'diff-date-string-of-two-lines)
  (define-key memo-prefix-map "\C-n" 'memo-new-entry)
  (define-key memo-prefix-map "\C-a" 'memo-add-item-as-previous-line)
  (define-key memo-prefix-map "\C-m" 'memo-save-and-make-command)
  (define-key memo-prefix-map "\C-e" 'memo-edit-other-file)
  ;;changed  [1999/03/11]
  (define-key memo-prefix-map "\C-r" 'memo-indent-reset)
  (define-key memo-prefix-map "\C-i" 'memo-indent-increment)
  (define-key memo-prefix-map "\C-o" 'memo-indent-decrement)
  (define-key memo-prefix-map ">" 'memo-thread-indent-increment)
  (define-key memo-prefix-map "<" 'memo-thread-indent-decrement)
  (define-key memo-prefix-map " " 'memo-show/hide-thread)
  (define-key memo-prefix-map "^" 'memo-move-entry-to-top)
  (define-key memo-prefix-map "_" 'memo-move-entry-to-last)
  (define-key memo-prefix-map "\?" 'memo-newline-and-indent)
  (define-key memo-prefix-map "\C-w" 'memo-kill-entry)
  (define-key memo-prefix-map "\ew" 'memo-copy-entry-as-kill)
  (define-key memo-prefix-map "\eo" 'memo-open-tag)
  (define-key memo-prefix-map "\C-f" 'auto-fill-mode)
  ;;; [1998/02/14]
  (define-key memo-mode-map [down-mouse-3] 
    '(lambda ()
       (interactive)
       (let ((o-list (car (overlays-at (point)))))
	 (if o-list (message "overlay:%s" o-list) (message "not overlay"))
	 (if o-list (message "overlay:%s" (overlay-properties o-list)))
)))
  ;;; [1999/02/11]
  ;;; [1999/03/11]
  (define-key memo-prefix-map "\C-c" 'memo-mode-exit)

)

(defun memo-version ()
  (interactive)
  (message (format "Memo mode: %s" Memo-version)))
(defvar memo-old-major-mode nil
  "")
(defun memo-mode ()
  "This mode enables you can do outline type memo scripting.

Key Binding:
\\[memo-indent-increment]   Insert new item. Indent level down.
\\[memo-indent-decrement]   Insert new item. Indent level up.
\\[memo-add-item-as-previous-line]   Insert new item. Indent level keep.
\\[memo-new-entry]   Add new entry.
\\[memo-kill-entry]   Kill entry.
\\[memo-copy-entry-as-kill] Copy entry.
\\[memo-indent-reset]   Reset current left-margin.
\\[memo-summary-this-buffer]     Invoke memo summary.

\\[get-date]   Insert date string.
\\[get-time]   Insert time string.
\\[get-dtime] Insert date and time string.
\\[auto-fill-mode]   Toggle a mode of auto fill.

\\[memo-thread-indent-increment]     Indent level down of lower threads. 
          If you specified prefix arguments 'C-u', 
          followed same indent level thread do as similary.
\\[memo-thread-indent-decrement]     Indent level up of lower threads. (c.f. [P] >).

\\[memo-open-tag] Open tag (URL) at a line.

\\[memo-move-entry-to-top]     Memo entry move to top.
\\[memo-move-entry-to-last]     Memo entry move to last.

Variables:
Memo-item                \"-->\"   Memo listing item.
memo-entry-separated-tag \"^---$\" Entry separated tag.
memo-indent-level        2         Space counts for each indent.

Functions:
memo-version              Display memo version.
memo-indent-line          Indent according to previous line.
memo-new-entry            Add new memo entry.
memo-kill-entry           Kill memo entry.
memo-copy-entry-as-kill   Copy memo entry.
memo-add-item             Insert memo-item.

memo-newline-and-indent
memo-newline-and-add-item
memo-add-item-as-previous-line
memo-indent-reset
memo-indent-increment
memo-indent-decrement
memo-thread-indent-increment
memo-thread-indent-decrement
"
  (interactive)
  (let ((mm major-mode))
    (kill-all-local-variables)
    (make-local-variable 'memo-old-major-mode)
    (setq memo-old-major-mode mm))
  (use-local-map memo-mode-map)
  (setq mode-name "memo")
  (setq major-mode 'memo-mode)
  (mapcar 'make-local-variable
          '(fill-column fill-prefix fill-paragraph
            paragraph-start paragraph-separate
            indent-line-function
            comment-start comment-start-skip
            memo-item
            ))
  ;; °Ê¹ß¤Î outline-minor ´Ø·¸¤ÎÀßÄê¤òÍ­¸ú¤Ë¤¹¤ë¤ÈÆÉ¤ß¹þ¤ß¤¬
  ;; ´Ø¿ô¤Î¼Â¹Ô¤¬ÅÓÃæ¤Ç½ª¤Ã¤Æ¤·¤Þ¤¦¤é¤·¤¤¡¥¡¥
  (make-local-variable 'outline-regexp)
;  (outline-minor-mode)
  (setq outline-regexp "^[ \t]*--")
;  (setq outline-regexp "[^#\n\^M]")
;  (setq outline-level 'memo-outline-level)
  (setq indent-line-function 'memo-indent-line)
  (auto-fill-mode 1)
;  (setq auto-fill-hook 'memo-indent-line)
;  (message "auto-fill-hook: %s" auto-fill-hook)
  (setq comment-start memo-comment-prefix)
  (setq fill-prefix memo-fill-prefix)
  (setq fill-column memo-fill-column)
  (setq paragraph-start memo-paragraph-start)
  (setq paragraph-separate memo-paragraph-separate)
  (setq hilit-auto-highlight t)
  (setq hilit-auto-rehighlight t)
  (setq selective-display t)
  (setq selective-display-ellipses t)	;Display `...'
  (run-hooks 'memo-mode-hook)
  (memo-skip-header)
 )

(defun memo-indent-to-left-margin ()
  (let* ((prev-bol (save-excursion
                     (forward-line -1) (point-bol)))
         (prev-prefix  (buffer-substring prev-bol (+ prev-bol left-margin)))
         (regexp (concat "^\\(" (regexp-quote comment-start) "+[ \t]*\\)")) 
         col)
    ;(indent-to-left-margin)
    (setq col left-margin)
    (beginning-of-line)
    (if (and (not (looking-at regexp))
             (string-match regexp prev-prefix))
        (let* ((str (match-string 1 prev-prefix))
               (len (length str)))
          (delete-char len)
          (insert str)))
    (move-to-column col)))

(defun memo-outline-level ()
  "¸½ºß¤Î¥¤¥ó¥Ç¥ó¥ÈÎÌ (¥¢¥¦¥È¥é¥¤¥ó¥ì¥Ù¥ë) ¤òÊÖ¤¹"
  (save-excursion
    (skip-chars-forward "\t ")
    (current-column)))

(defun memo-description () ;; [1998/01/24]
  "¥á¥â¤Î¥Ø¥Ã¥À¤«¤éÀâÌÀ½ñ¤­¤òÈ´¤­¤À¤·¥á¥Ã¥»¡¼¥¸É½¼¨¤¹¤ë"
  (interactive)
  (let ((desc (memo-get-header-description)))
    (if (string= desc "") (setq desc "(none)"))
    (if desc (message "MEMO: %s" desc))))

;; [1999/01/25]
(defun memo-get-file-tag-at-line ()
  "¸½ºß¹Ô¤Ë¤¢¤ë¥Õ¥¡¥¤¥ë¥¿¥°¤ò¼èÆÀ"
  (let ((file nil))
    (save-excursion
      (goto-char (point-bol))
      (if (re-search-forward "\\(\\(https?\\|file\\|news\\|ftp\\|gopher\\|wysiwyg\\|img\\):[^ ]+\\)" (point-eol) t)
	  (progn
	    (setq file (buffer-substring (match-beginning 0) (match-end 0)))))
      file)))

;; [1999/01/25]
(defun memo-edit-other-file (&optional file)
  "Â¾¤Î¥á¥â¥Õ¥¡¥¤¥ë¤ÎÊÔ½¸"
  (interactive)
  (let (str)
    (setq file (memo-get-file-tag-at-line))
    (setq str (completing-read "Memo File: "
			       (mapcar (lambda (l) (list l))
				       (file-name-all-completions "" ""))
			       nil nil file))
    (if (not (string= str "")) (setq file str))
    (if (string-match "^file:" file)
	(setq file (substring file (match-end 0))))
    (find-file file)))

;; [1999/01/26]
(defun memo-open-tag (&optional tag)
  "URL ·Á¼°»ØÄê¤Ë¤è¤ë³°Éô¥×¥í¥°¥é¥àµ¯Æ°¡¦¥Õ¥¡¥¤¥ë±ÜÍ÷"
  (interactive)
  (let ((www-browser "netscape")
	(tgif "tgifj3")
	(image-viewer "display")
	(xdvi "xdvi")
	(qtmovie "xanim")
	(newsreader "gnus")
	(realplayer "raplay")
	)
    (if (interactive-p) (setq tag (memo-get-file-tag-at-line)))
    (if (not tag) (message "No tag on this line.")
      (cond
       ((string-match "^\\(file:\\).+\\.mmp$" tag)
	(start-process "tkduke" nil "tkduke"
		       (substring tag (match-end 1))))
       ((string-match "^\\(file:\\).+\\.\\(gif|jpe?g|p[pgbn]m\\)$" tag)
	(start-process "image-viewer" nil image-viewer
		       (substring tag (match-end 1))))
       ((string-match "^\\(ima?ge?:\\)" tag)
	(start-process "image-viewer" nil image-viewer
		       (substring tag (match-end 1))))
       ((string-match "^\\(file:\\).+\\.obj$" tag)
	(start-process "tgif" nil tgif
		       (substring tag (match-end 1))))
       ((string-match "^\\(file:\\).+\\.dvi$" tag)
	(start-process "xdvi" nil xdvi
		       (substring tag (match-end 1))))
       ((string-match "^\\(file:\\).+\\.mov$" tag)
	(start-process "qtmovie" nil qtmovie
		       (substring tag (match-end 1))))
       ((string-match "\\.ra$" tag)
	(start-process "raplayer" nil realplayer tag))
       ((and (string-match "^\\(news:\\)" tag) (string= "gnus" newsreader))
	(gnus-summary-refer-article (substring tag (match-end 1))))
       ((string-match "^\\(file:\\)" tag)
	(find-file (substring tag (match-end 1))))
       ((string-match "^\\(https?\\|ftp\\|gopher\\|wysiwyg\\|img\\):"
		      tag)
	(progn
	  (message "Send URL to %s...: %s" www-browser tag)
	  (memo-send-url-to-browser tag www-browser)
	  (message "Send URL to %s...done." www-browser)))
       (t (message "Cannot find binding program for %s" tag))
       ))))

(defun memo-send-url-to-browser (tag &optional browser)
  "Web ¥Ö¥é¥¦¥¶¤Ø¤Î URL ¤ÎÁ÷¿®"
  (cond
   ((string-match "w3" browser) (w3-fetch tag))
   (t (start-process "www-browser" nil "netscape"
       "-remote" (concat "OpenURL(" tag (if nil ",new-window") ")")))))

(defun memo-get-header-description ()
  "¥á¥â¥Õ¥¡¥¤¥ë¤Î¥Ø¥Ã¥À¤Ë¤¢¤ëÀâÌÀ½ñ¤­¤ò¼èÆÀ"
  (let (p desc (name (buffer-name (current-buffer))))
    (goto-char (point-min))
    (re-search-forward memo-entry-separated-tag nil t)
    (setq p (point))
    (goto-char (point-min))
    (if (re-search-forward "^ *# *.+: *\\(.+\\)" p t)
	(progn
	  (setq desc (buffer-substring (match-beginning 1)
				       (match-end 1)))
	  (if (not (string-match "^ +$" desc))
	      (format "%s (%s)" desc name) name)))))

(defun memo-skip-header ()
  "¥á¥â¥Õ¥¡¥¤¥ë¤Î¥Ø¥Ã¥ÀÉô¤ò¥¹¥­¥Ã¥×¤·¤¿°ÌÃÖ¤«¤éÉ½¼¨"
  (interactive)
  (let ((b (current-buffer)) (min (point-min)) (name "") desc)
    (setq name (buffer-name b))
    (switch-to-buffer name)
    (if (eq (point) min)
	(progn
	  (memo-description)
	  (goto-char min)
	  (re-search-forward memo-entry-separated-tag nil t)
	  (forward-line -1)
	  (let ((w (get-buffer-window b)))
	    (beginning-of-line)
	    (set-window-start  w (point)))
	  (forward-line 2)
	  (beginning-of-line)))
    name))

(defun memo-new-entry ()
  "¿·µ¬¥á¥â¹àÌÜ¤ÎºîÀ®"
  (interactive)
  (if (not (eq (current-column) 0))
      (forward-line 1))
  (move-to-column 0)
  (if (re-search-forward memo-entry-separated-tag (point-eol) t)
      (forward-line 1))
  (insert (concat (get-date) "\n\n" "---\n"))
  (forward-line -2))

(defun memo-add-item ()
  "¥¢¥¤¥Æ¥à¤ÎÁÞÆþ"
  (insert memo-item)
  )

(defun memo-indent-line ()
  "¸½ºß¤Î¥¢¥¦¥È¥é¥¤¥ó¤Ë±þ¤¸¤¿¥¤¥ó¥Ç¥ó¥ÈÎÌ¤Ë¤¹¤ë"
  (interactive)
  (let ((col (current-column)) b-col (shift 0) (m (point-eol)))
    (save-excursion
      (beginning-of-line)
      (setq b-col (current-indentation))
      (if (< col b-col) (setq col b-col))
      (beginning-of-line)
      ;(if (re-search-forward (concat "^[ \t]*" memo-item) m t) ()
      (if (re-search-forward memo-paragraph-start m t) 
	  (if (= col b-col)
	      (setq shift (- (memo-current-line-indent) b-col)))
	(setq left-margin (memo-previous-line-indent))
	(indent-to-left-margin)
	(setq shift (- left-margin b-col))
	)
    )
    (setq col (+ col shift))
    (move-to-column col)
    ))

(if (fboundp 'memo-saved-indent-new-comment-line) nil
  (fset 'memo-saved-indent-new-comment-line
	(symbol-function 'indent-new-comment-line))
  (fset 'indent-new-comment-line 'memo-indent-new-comment-line))

(defun memo-indent-new-comment-line (&optional soft)
  (cond
   ((not (eq major-mode 'memo-mode))
    (apply 'memo-saved-indent-new-comment-line (if soft (list soft))))
   (t (let (fill-prefix)
	(apply 'memo-saved-indent-new-comment-line (if soft (list soft)))))))

(defun memo-newline-and-indent ()
  "¼«Æ°²þ¹Ô»þ¤Î½èÍý¡¥¥¤¥ó¥Ç¥ó¥È½èÍý¤ò´Þ¤à"
  (interactive)
  (if (= (current-column) 0) (newline)
    (newline)
    (setq left-margin (memo-previous-line-indent))
    (indent-to-left-margin)
    ))

(defun memo-newline-and-add-item (shift)
  "²þ¹Ô½èÍý¤ò¹Ô¤Ê¤¤¡¤¥¢¥¤¥Æ¥à¤òÄÉ²Ã"
  (interactive)
  (end-of-line)
  (memo-newline-and-indent)
  (let ((margin left-margin))
    (setq left-margin (+ left-margin shift))
    (if (> left-margin memo-indent-level)
	(setq left-margin (- left-margin (length memo-item))))
    (indent-to-left-margin)
    (memo-add-item)
    (setq left-margin margin)))

(defun memo-item-line-indent ()
  "¸½ºß¹Ô¤Î¥¤¥ó¥Ç¥ó¥ÈÎÌ¤ò¼èÆÀ"
  (let (p)
    (save-excursion
      (save-excursion
	(re-search-backward memo-entry-separated-tag 0 t)
	(setq p (point)))
      (if (not (re-search-backward (concat "^[ \t]*" memo-item) p t)) 0
	(re-search-forward (concat "^[ \t]*" memo-item) (point-eol) t)
	(current-column)))))

(defun memo-previous-line-indent ()
  "Ä¾Á°¤Î¹Ô¤Î¥¤¥ó¥Ç¥ó¥ÈÎÌ¤ò¼èÆÀ"
  (save-excursion
    (forward-line -1)
    (memo-current-line-indent)))

(defun memo-current-line-indent ()
  "¸½ºß¹Ô¤Î¥¤¥ó¥Ç¥ó¥ÈÎÌ¤ò¼èÆÀ"
  (save-excursion
    (beginning-of-line)
    (re-search-forward (concat "^[ \t]*\\(" memo-item "\\)?") (point-eol) t)
    (current-column)))

(defun memo-current-line-item-check ()
  "¸½ºß¹Ô¤¬ memo-item ¤òÍ­¤·¤Æ¤¤¤ë¤«¤ò¥Á¥§¥Ã¥¯"
  (save-excursion
    (beginning-of-line)
    (re-search-forward (concat "^[ \t]*" memo-item) (point-eol) t)))

(defun memo-delete-char ()
  "£±Ê¸»úºï½ü¡¥¥¤¥ó¥Ç¥ó¥È¤òÉ½¸½¤¹¤ë¹ÔÆ¬¶õÇò¤Ï¤Þ¤È¤á¤Æºï½ü¤µ¤ì¤ë"
  (interactive)
  (if (not (eolp)) (delete-char 1)
    (save-excursion
      (forward-char 1)
      (delete-horizontal-space)
      (forward-char -1)
      (delete-char 1))))

(defun memo-delete-backward-char ()
  "¥«¡¼¥½¥ëÄ¾Á°¤ÎÊ¸»ú¤Îºï½ü¡¥¥¤¥ó¥Ç¥ó¥ÈÎÌ¤òÈ¿±Ç¤µ¤»¤ë"
  (interactive)
  (cond
   ((= (current-column) (memo-item-line-indent))
    (if (memo-current-line-item-check)
	(progn
	  (delete-region (save-excursion (beginning-of-line) (point))
			 (point))
	  (setq left-margin (memo-previous-line-indent))
	  (indent-to-left-margin)
	  )
      (delete-region (save-excursion (end-of-line 0) (point)) (point))))
   ((< (current-column) (memo-item-line-indent))
    (memo-thread-indent-decrement))
   (t (delete-backward-char 1))))

(defun memo-previous-entry ()
  "£±¤ÄÁ°¤Î¥á¥â¥¨¥ó¥È¥ê¤Ø°ÜÆ°"
  (interactive)
  ;(forward-line -1)
  (end-of-line)
  (if (and (re-search-backward memo-entry-separated-tag nil t)
	   (re-search-backward memo-entry-separated-tag nil t))
	   (progn (forward-line 1)
		  (beginning-of-line))))

(defun memo-next-entry ()
  "£±¤Ä¸å¤Î¥á¥â¥¨¥ó¥È¥ê¤Ø°ÜÆ°"
  (interactive)
  (forward-line 1)
  (beginning-of-line)
  (if (re-search-forward memo-entry-separated-tag nil t)
      (progn (forward-line 1)
	     (beginning-of-line))))

(defun memo-previous-line ()
  "£±¤ÄÁ°¤Î¹Ô¤Ø°ÜÆ°"
  (interactive)
  (forward-line -1)
  (beginning-of-line)
  (if (re-search-backward "^[ \t]*" nil t)
	(if (search-backward memo-item) 
	    (search-forward memo-item))))

(defun memo-next-line ()
  "£±¤Ä¸å¤Î¹Ô¤Ø°ÜÆ°"
  (interactive)
  (forward-line 1)
  (beginning-of-line)
  (if (re-search-forward "^[ \t]*" nil t)
      (search-forward memo-item)))

(defun memo-indent-reset ()
  "¸½ºß¤Î¥¤¥ó¥Ç¥ó¥ÈÎÌ¤ò¥¼¥í¤Ë¤¹¤ë"
  (interactive)
  (setq left-margin 0)
  )

(defun memo-add-item-as-previous-line (&optional item)
  "Ä¾Á°¹Ô¤¬´Þ¤Þ¤ì¤ë¥¢¥¤¥Æ¥à¤ÈÆ±¤¸¿¼¤µ¤Î¥¢¥¤¥Æ¥à¤òÄÉ²Ã"
  (interactive
   (if current-prefix-arg
       (list (let ((str (read-string
                         (concat "Meme item: (default " memo-item-default ")"))))
               (if (string= str "") memo-item-default str)))))
  (if item (setq memo-item item))
  (memo-newline-and-add-item 0)
  )

(defun memo-indent-increment (arg)
  "¥á¥â¤Î³¬ÁØ¤ò¾å¤²¤ë¡£(\\[universal-argument]¤ò²¡¤·¤¿¿ô + 1)³¬ÁØ¾å¤²¤ë¡£"
  (interactive "p")
  (let ((level (1+ (/ (logb arg) 2))))
    (memo-newline-and-add-item (* level  memo-indent-level))
  ))

(defun memo-indent-decrement (arg)
  "¥á¥â¤Î³¬ÁØ¤ò²¼¤²¤ë¡£(\\[universal-argument]¤ò²¡¤·¤¿¿ô + 1)³¬ÁØ²¼¤²¤ë¡£"
  (interactive "p")
  (let ((level (1+ (/ (logb arg) 2))))
    (memo-newline-and-add-item (* level (- memo-indent-level)))
  ))

(defun memo-thread-indent (indent &optional all-indent)
  "¥¢¥¤¥Æ¥à¥¹¥ì¥Ã¥É¤Î¥¤¥ó¥Ç¥ó¥ÈÎÌ¤òÁý¤ä¤¹¡¥prefix ¤ÇÆ±¤¸¿¼¤µ¤Î¥¢¥¤¥Æ¥à¤â¤Þ¤È¤á¤Æ½èÍý"
  ; ¥«¡¼¥½¥ë¤¬ left-margin ¤è¤ê¤â¾®¤µ¤¤°ÌÃÖ¤Ë¤¢¤ë¾ì¹ç¤ÎÆ°ºî¤¬¤ª¤«¤·¤¤¡©
  ;   [1998/01/17]
  ;   -->save-excursion ¤È indent-to-left-indentation ¤ÎÁêÀ­¤¬°­¤¤¤é¤·¤¤
  ;      ¼«Á°¤Ç point ¤òÊÝÂ¸¡¦Éüµ¢¤·¤Æ¤ß¤ë¡£
  ;     -->¥¤¥ó¥Ç¥ó¥È»þ¤Î¥¿¥Ö¤È¥¹¥Ú¡¼¥¹¤ÎÊÑ´¹¤Î¤¿¤áÊÝÂ¸¤·¤¿ point ¤Ç¤Ï
  ;        ´õË¾°ÌÃÖ¤Ë¥«¡¼¥½¥ë¤òÃÖ¤±¤Ê¤¤¡¥
  ;     -->(current-column) ¤Ç¥«¥é¥à¿ô¤òÊÝÂ¸¤·¤Æ¤ß¤¿¤±¤É¡¥¡¥¤É¤¦¤Ê¤ë¤«¡©
  ;(let ((col (current-column)))
  (save-excursion
    (beginning-of-line)
    (let ((org (current-indentation)) (cur) (tag memo-entry-separated-tag))
      (setq left-margin (+ org indent))
      (indent-to-left-margin)
      (catch 'indented ; ¸½ºß¹Ô°Ê²¼¤Î¥¤¥ó¥Ç¥ó¥È½èÍý
	(while (not (save-excursion (end-of-line) (eobp)))
	  (forward-line 1)
	  (beginning-of-line)
	  (if (re-search-forward tag (save-excursion (end-of-line) (point)) t)
	      (throw 'indented t))
	  (setq cur (current-indentation))
	  (if (or (< cur org) (and (not all-indent) (= cur org)))
	      (throw 'indented t))  ;; [A]
	  (setq left-margin (+ cur indent))
	  (indent-to-left-margin)))
      )
    )
    ;(move-to-column col)
    ;)
  )

(defun memo-thread-indent-increment (&optional arg)
  "¥¢¥¤¥Æ¥à¥¹¥ì¥Ã¥É¤Î¿¼¤µ¤òÁý¤ä¤¹"
  (interactive "P")
  (memo-thread-indent memo-indent-level (not (null arg))))

(defun memo-thread-indent-decrement (&optional arg)
  "¥¢¥¤¥Æ¥à¥¹¥ì¥Ã¥É¤Î¿¼¤µ¤ò¸º¤é¤¹"
  (interactive "P")
  (memo-thread-indent (- memo-indent-level) (not (null arg))))

(defun memo-beginning-of-line ()
  "¹ÔÆ¬¤Ø¤Î°ÜÆ°¡¥¸½ºß°ÌÃÖ¤Ë¤è¤Ã¤Æ¹ÔÆ¬¤Î°ÕÌ£¤¬°Û¤Ê¤ë"
  (interactive)
  (let ((col (current-column)) (m (point-eol)) icol iicol)
    (setq icol (current-indentation))
    (save-excursion
      (move-to-column icol)
      (search-forward memo-item (+ (point) (length memo-item)) t)
      (setq iicol (current-column)))
    (cond
     ((= col 0) ())
     ((> col iicol)  (move-to-column iicol))
     ((> col icol )  (move-to-column icol ))
     (t (beginning-of-line)))
    ))

(defun memo-kill-entry ()
  "¥á¥â¥¨¥ó¥È¥ê¤Î kill"
  (interactive)
  (let (b e)
    (save-excursion
      (if (not (= (current-column) 0))
	  (end-of-line))
      (re-search-backward memo-entry-separated-tag nil t)
      (forward-line 1)
      (beginning-of-line)
      (setq b (point))
      (forward-line 1)
      (re-search-forward memo-entry-separated-tag nil t)
      (forward-line 1)
      (beginning-of-line)
      (setq e (point))
      (kill-region b e)
      )
    (goto-char b)))

(defun memo-copy-entry-as-kill ()
  "¥á¥â¥¨¥ó¥È¥ê¤Î¥³¥Ô¡¼"
  (interactive)
  (let (b e)
    (save-excursion
      (if (not (= (current-column) 0))
	  (end-of-line))
      (re-search-backward memo-entry-separated-tag nil t)
      (forward-line 1)
      (beginning-of-line)
      (setq b (point))
      (forward-line 1)
      (re-search-forward memo-entry-separated-tag nil t)
      (forward-line 1)
      (beginning-of-line)
      (setq e (point))
      (copy-region-as-kill b e)
      )
    ))

(defun memo-show/hide-thread (&optional all-indent)
  "test version"
  (interactive)
  (if (save-excursion
	(search-forward "\^M" (save-excursion (end-of-line) (point)) t))
      (memo-show-thread all-indent)
    (memo-hide-thread all-indent)))

(defun memo-hide-thread (&optional all-indent)
  "test version"
  (interactive)
  (if current-prefix-arg (setq all-indent t))
  (let (p b e (whole 0) col)
    (save-restriction
      (save-excursion
	(re-search-backward memo-entry-separated-tag nil t)
	(beginning-of-line 2)
	(if (re-search-forward "^\\[[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]\\( +[0-9][0-9]:[0-9][0-9]\\)?\\] *$" (save-excursion (end-of-line) (point)) t)
	    (beginning-of-line 2))
	(setq b (point))
	(re-search-forward memo-entry-separated-tag nil t)
	(beginning-of-line 1)
	(setq e (point))
	(narrow-to-region b e)
	)
      (save-excursion
	(end-of-line)
	(if (or (and (re-search-backward "^ *-->" nil t)
		     (or (end-of-line 1) 1))
		(and (goto-char (point-min))
		     (setq whole 1))
		1)
	    (progn
	      (setq p (point))
	      (setq col (current-indentation))
	      (catch 'done
		(if (= whole 1)
		    (progn
		      (goto-char (point-max))
		      (end-of-line 0)
		      (subst-char-in-region p (point) ?\n ?\^M)
		      (throw 'done t)))
		(while t
		  (end-of-line 2)
		  (if (or (> col (current-indentation))
			  (= (point) (point-max))
			  (and (not all-indent)
			       (= col (current-indentation))))
		      (throw 'done t))
		  (if (or (< col (current-indentation))
			  (= (point) (point-max)))
		      (subst-char-in-region p (point) ?\n ?\^M))
		  (setq p (point))
                      ))))))))

(defun memo-show-thread (&optional all-indent)
  "test version"
  (interactive)
  (if current-prefix-arg (setq all-indent t))
  (let (p col)
    (save-excursion
      (beginning-of-line)
      (setq p (point))
      (setq col (current-indentation))
      (catch 'done
	(while t
	  (beginning-of-line 2)
	  (if (or (> col (current-indentation))
		  (and (not all-indent)
		       (= col (current-indentation))))
	      (throw 'done t))
	  ))
      (subst-char-in-region p (point) ?\^M ?\n))))

(defun memo-save-and-make-command ()
  "¥á¥â¥Õ¥¡¥¤¥ë¤òÊÝÂ¸¤· make ¤ò¼Â¹Ô (¼«Æ°ÊÑ´¹¤ò¹Ô¤Ê¤¤¤¿¤¤¤È¤­ÍÑ)"
  (interactive)
  (save-buffer)
  (shell-command "make"))

;;; [1998/02/13] set hilit19-face
(if window-system
    (cond
     ((featurep 'hilit19)
      (hilit-set-mode-patterns
       'memo-mode
       '(("^---+ *$" nil type)
	 (memo-search-item nil decl)
	 ("\\[..../../..\\( +..:..\\)?\\]\\|\\[..:..\\]" nil define)
	 ("^ *#.*" nil comment)
	 ("\\(https?\\|file\\|ftp\\|gopher\\|wysiwyg\\|img\\):[^ \n]+" nil string)
	 )))

     ((featurep 'font-lock)
      (defvar memo-font-lock-keywords
	(list (cons memo-entry-separated-tag
		    'font-lock-type-face)
	      (cons (concat "^[ \t]*" memo-item)
		    'font-lock-function-name-face)
	      '("\\]\n\\(.*\\)$"
		1 font-lock-variable-name-face)
	      '("\\[..../../..\\( +..:..\\)?\\]\\|\\[..:..\\]"
		. font-lock-constant-face)
	      '("^ *#.*"
		. font-lock-comment-face)
	      '("\\(https?\\|file\\|ftp\\|gopher\\|wysiwyg\\|img\\):[^\n]+"
		. font-lock-keyword-face))
	"Defaults for Font Lock mode specified by the memo mode.")
      (if (and (>= (string-to-int emacs-version) 19)
	       (not (featurep 'xemacs)))
	  (add-hook
	   'memo-mode-hook
	   (lambda ()
	     (make-local-variable 'font-lock-defaults)
	     (setq font-lock-defaults
		   '((memo-font-lock-keywords) nil nil ((?\_ . "w"))))))
	(add-hook 'ruby-mode-hook
		  (lambda ()
		    (setq font-lock-keywords memo-font-lock-keywords)))))))

(defun memo-search-item (a)
  "¥¢¥¤¥Æ¥à¤ò¸¡º÷"
  (interactive)
  (let (b e)
    (if (re-search-forward (format "^[ \t]*%s" memo-item) nil t)
	(progn
	  (setq e (point))
	  (re-search-backward memo-item)
	  (setq b (point))
	  (and e (cons b e))))))

(defun memo-move-entry-to-top ()
  "¥á¥â¥¨¥ó¥È¥ê¤òËÁÆ¬¤Ø°ÜÆ°"
  (interactive)
  (save-excursion
    (memo-kill-entry)
    (goto-char (point-min))
    (if (re-search-forward memo-entry-separated-tag nil t)
	(forward-line 1))
    (yank)))

(defun memo-move-entry-to-last ()
  "¥á¥â¥¨¥ó¥È¥ê¤òºÇ¸å¤Ø°ÜÆ°"
  (interactive)
  (save-excursion
    (memo-kill-entry)
    (goto-char (point-max))
    (if (re-search-backward memo-entry-separated-tag nil t)
	(forward-line 1))
    (yank)))

;;; [1998/02/14]
(defun memo-energize-urls ()
  ""
  ;; require vm-5.96beta:vm-page.el:vm-energize-urls (or upper?).
  (interactive)
  (save-excursion
    (save-restriction
      (widen)
      (vm-energize-urls)
      )))

;;; [1998/08/28]
(defun memo-mode-header ()
  "Emacs/Mule ¤Ç¤Î¼«Æ°Ç§¼±ÍÑ¥Ø¥Ã¥À¤ÎÁÞÆþ"
  (interactive)
  (save-excursion
    (save-restriction
      (goto-char (point-min))
      (if (re-search-forward "^#[ ]*-\\*- memo -\\*-" (point-eol) t) ()
	(insert "# -*- memo -*-\n\n")
	(memo-mode))
      )))

;;; [1999/02/11]

(defun memo-mode-exit ()
  "memo-mode ¤«¤éÈ´¤±¤Æ¸µ¤Î major-mode ¤ËÉüµ¢¤¹¤ë¡£"
  (interactive)
  (if (and memo-old-major-mode
           (eq major-mode 'memo-mode))
      (funcall memo-old-major-mode)
    (error "Cannot exit memo-mode")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; memo summary [1998/12/30]
;;;
(defvar memo-summary-buffer nil)
(defvar memo-summary-cur-item-no -1)
(defvar memo-summary-with-date t)
(defvar memo-summary-mode-map nil)

(if memo-summary-mode-map ()
  (setq memo-summary-mode-map   (make-sparse-keymap))
  (define-key memo-summary-mode-map " "  'memo-summary-display)
  (define-key memo-summary-mode-map "<"  'memo-summary-display-top)
  (define-key memo-summary-mode-map ">"  'memo-summary-display-bottom)
  (define-key memo-summary-mode-map "."  'memo-summary-redisplay)
  (define-key memo-summary-mode-map ","  'scroll-other-window-down)
  (define-key memo-summary-mode-map "^"  'memo-summary-enlarge-other-window)
  (define-key memo-summary-mode-map "_"  'memo-summary-shrink-other-window)
  (define-key memo-summary-mode-map "n"  'memo-summary-next)
  (define-key memo-summary-mode-map "p"  'memo-summary-prev)
  (define-key memo-summary-mode-map "q"  'memo-summary-quit)
  (define-key memo-summary-mode-map "e"  'memo-summary-jump)
  (define-key memo-summary-mode-map "R"  'memo-summarize)
  (define-key memo-summary-mode-map "S"  'memo-summarize-with-search)
  (define-key memo-summary-mode-map "\es"  'memo-summary-search)
  (define-key memo-summary-mode-map "s"  'memo-summary-save-item)
  (define-key memo-summary-mode-map "v"  'memo-summary-visit)
  (define-key memo-summary-mode-map "T"  'memo-toggle-summary-display)
  (define-key memo-summary-mode-map "="  'delete-other-windows)
  )

(defun memo-summary-this-buffer ()
  "¥«¥ì¥ó¥È¥Ð¥Ã¥Õ¥¡¤Î¥µ¥Þ¥ê¤òµ¯Æ°¤¹¤ë¡£"
  (interactive)
  (setq memo-summary-buffer (current-buffer))
  (if memo-summary-buffer
      (progn
        (pop-to-buffer memo-summary-buffer)
        (widen)))
  (setq memo-summary-cur-item-no -1)
  (call-interactively 'memo-summarize)
  )

(defun memo-summary-visit (file)
  "¥á¥â¥Õ¥¡¥¤¥ë¤ò³«¤¤¤Æ¥µ¥Þ¥ê¤òµ¯Æ°¤¹¤ë¡£"
  (interactive "fMemo file: ")
  (find-file file)
  (memo-summary-this-buffer))

(defun memo-summary-make ()
  (interactive)
  (let ((buf (current-buffer)) head date b e m ptmp)
    (setq memo-items nil)
    (switch-to-buffer memo-summary-buffer)
    (widen)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward memo-entry-separated-tag nil t)
	(forward-char 1)
	(setq b (point))
	(setq ptmp b)
	(setq head (buffer-substring ptmp (point-eol)))
	(setq date "____/__/__")
	(if (string-match "^\\[\\(..../../..\\( *..:..\\)?\\)] *$" head)
	    (progn
	      (setq date
		    (substring head (match-beginning 1) (match-end 1)))
	      (setq ptmp (+ (point-eol) 1))
	      (goto-char ptmp)
	      (setq head (buffer-substring ptmp (point-eol)))
	      ))
	(if (setq m (string-match "\\[..:..\\] *$" head))
	    (setq head (substring head 0 m)))
	(save-excursion
	  (if (re-search-forward memo-entry-separated-tag nil t)
	      (progn
		(save-excursion
		  (goto-char (- (point-bol) 1))
		  (while (re-search-backward "^#.+:" (point-bol) t)
		    (forward-char -1))
		  (setq e (point-eol))))
	    (setq e nil)))
	(setq memo-items (cons (list b e head date) memo-items)))
      (setq memo-items (reverse (cdr memo-items))))
    (switch-to-buffer buf)))

(defun memo-summary-make-with-search (word)
  (interactive "sSearch word: ")
  (let ((buf (current-buffer)) head date b e m ptmp)
    (setq memo-items nil)
    (setq memo-cur-item-no -1)
    (switch-to-buffer memo-summary-buffer)
    (widen)
    (save-excursion
      (goto-char (point-min))
      (while (and (re-search-forward word nil t)
		  (re-search-backward memo-entry-separated-tag nil t))
	(goto-char (+ (point-eol) 1))
	(setq b (point))
	(setq ptmp b)
	(setq head (buffer-substring ptmp (point-eol)))
	(setq date "____/__/__")
	(if (string-match "^\\[\\(..../../..\\( *..:..\\)?\\)] *$" head)
	    (progn
	      (setq date
	      	    (substring head (match-beginning 1) (match-end 1)))
	      (setq ptmp (+ (point-eol) 1))
	      (goto-char ptmp)
	      (setq head (buffer-substring ptmp (point-eol)))
	      ))
	(if (setq m (string-match "\\[..:..\\] *$" head))
	    (setq head (substring head 0 m)))
	(save-excursion
	  (if (re-search-forward memo-entry-separated-tag nil t)
	      (progn
		(save-excursion
		  (goto-char (- (point-bol) 1))
		  (while (re-search-backward "^#.+:" (point-bol) t)
		    (forward-char -1))
		  (setq e (point-eol))))
	    (setq e nil)))
	(setq memo-items (cons (list b e head date) memo-items))
	(re-search-forward memo-entry-separated-tag nil t)
	(forward-char -1)
	)
      (setq memo-items (reverse memo-items)))
    (switch-to-buffer buf)))
  
(defun memo-summary-display-summary ()
  (interactive)
  (let (no num str w p)
    (save-excursion
      (setq no 1)
      (save-restriction
	(pop-to-buffer "*Memo Summary*")
	(setq buffer-read-only nil)
	(delete-region (point-min) (point-max))
	(setq num (length memo-items))
	(setq w (- (window-width) 3))
	(if memo-summary-with-date
	    (mapcar
	     (lambda (i)
	       (setq str (format " %4d: [%s] %s"
				 (+ num (- no) 1) (nth 3 i) (nth 2 i)))
	       (insert (truncate-string str w) "\n")
	       (setq no (+ no 1)))
	     memo-items)
	  (mapcar
	   (lambda (i)
	     (setq str (format " %4d: %s"
			       (+ num (- no) 1) (nth 2 i)))
	     (insert (truncate-string str w) "\n")
	     (setq no (+ no 1)))
	   memo-items))
	(setq buffer-read-only t)))))

(defun memo-toggle-summary-display ()
  "¥µ¥Þ¥ê¡¼¤Î¥Ø¥Ã¥À¡ÊÆüÉÕ¡ËÉ½¼¨¤òÀÚÂØ¤¨¤ë"
  (interactive)
  (let ((n 0))
    (save-excursion
      (goto-char (point-bol))
      (if (re-search-forward "^ *\\([0-9]+\\)" nil t)
	  (progn
	    (setq n (string-to-int
		     (buffer-substring (match-beginning 1) (match-end 1)))))))
    (setq memo-summary-with-date
	  (if memo-summary-with-date nil t))
    (memo-summary-display-summary)
    (if (re-search-forward (format "^ *%d" n) nil t) (goto-char (point-bol)))
    ))

(defun memo-summarize (&optional word)
  (interactive)
  (if current-prefix-arg
      (setq word (read-string "Search: ")))
  (if (interactive-p) (message "memo summary generating..."))
  (let (exist b)
    (if word
	(memo-summary-make-with-search word)
      (memo-summary-make))
    (setq exist (window-live-p (get-buffer-window "*Memo Summary*")))
    (switch-to-buffer "*Memo Summary*") ;; suitable pop-to-buffer ?
    (setq b (point))
    (memo-summary-display-summary)
    (if (and (null exist)
	     (window-live-p (get-buffer-window memo-summary-buffer))) ()
      (delete-other-windows))
    (goto-char b)
    (if (interactive-p) (message "memo summary generating...done."))
    (memo-summary-mode)))

(defun memo-summarize-with-search (word)
  (interactive "sSearch with summarize: ")
  (memo-summarize word))

(defun memo-summary-enlarge-other-window ()
  (interactive)
  (enlarge-window -1))

(defun memo-summary-shrink-other-window ()
  (interactive)
  (enlarge-window 1))

(defun memo-summary-mode ()
  "\\{memo-summary-mode-map}"
  (interactive)
  (use-local-map memo-summary-mode-map)
  (setq mode-name (format "%s Summary" memo-summary-buffer))
  (setq major-mode 'memo-summary-mode))

(defun memo-summary-quit ()
  (interactive)
  (if (> (count-windows) 1)
      (delete-window)
    (switch-to-buffer memo-summary-buffer)
    )
  (pop-to-buffer memo-summary-buffer)
  (widen)
  (bury-buffer "*Memo Summary*"))

(defun memo-summary-display-top ()
  (interactive)
  (let ((buf (current-buffer)))
    (pop-to-buffer memo-summary-buffer)
    (goto-char (point-min))
    (pop-to-buffer buf)))

(defun memo-summary-display-bottom ()
  (interactive)
  (let ((buf (current-buffer)))
    (pop-to-buffer memo-summary-buffer)
    (goto-char (point-max))
    (pop-to-buffer buf)))

(defun memo-summary-redisplay ()
  (interactive)
  (setq memo-summary-cur-item-no -1)
  (memo-summary-display))

(defun memo-summary-display ()
  (interactive)
  (let ((num (length memo-items))
	(pop-up-windows nil)
	n b e buf)
    (save-excursion
      (goto-char (point-bol))
      (if (re-search-forward "^ *\\([0-9]+\\)" nil t)
	  (progn
	    (setq n (string-to-int (buffer-substring (match-beginning 1) (match-end 1))))
	    (setq b (car (nth (- num n) memo-items)))
	    (setq e (car (cdr (nth (- num n) memo-items))))
	    (setq buf (current-buffer))
	    (if (and (window-live-p (get-buffer-window memo-summary-buffer))
		     (= n memo-summary-cur-item-no))
		(scroll-other-window)
	      (if (window-live-p (get-buffer-window memo-summary-buffer)) ()
		(delete-other-windows)
		(split-window-calculate-height "30")
		)
	      (pop-to-buffer memo-summary-buffer)
	      (widen)
	      (narrow-to-region b e)
	      (goto-char b)
	      (save-restriction
		(and (re-search-forward "^\\[[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]\\]\\( \\[[0-9][0-9]:[0-9][0-9]\\]\\)* *" nil t)
		     (re-search-forward "^" nil t)
		     (setq b (point))
		     ))
	      (set-window-start (get-buffer-window memo-summary-buffer) b)
	      (pop-to-buffer buf))
	    (setq memo-summary-cur-item-no n)
	    )))
    ))

(defun memo-summary-jump ()
  (interactive)
    (save-excursion
      (goto-char (point-bol))
      (pop-to-buffer memo-summary-buffer)
      (widen)))
;    (if (re-search-forward "^ *\\([0-9]+\\)" nil t)
;    	(progn
;	  (setq n (string-to-int (buffer-substring (match-beginning 1) (match-end 1))))
;	  (setq b (car (nth (- num n) memo-items)))
;	  (setq buf (current-buffer))
;	  (pop-to-buffer memo-summary-buffer)
;	  (goto-char b)
;	  (pop-to-buffer buf))))
;	  (pop-to-buffer memo-summary-buffer))

(defun memo-summary-next ()
  (interactive)
  (setq memo-summary-cur-item-no -1)
  (goto-char (+ (point-eol) 1))
  (memo-summary-display))

(defun memo-summary-prev ()
  (interactive)
  (setq memo-summary-cur-item-no -1)
  (goto-char (+ (point-bol) -1))
  (goto-char (point-bol))
  (memo-summary-display))

(defun memo-summary-search (word)
  (interactive "sSearch: ")
  (let ((buf (current-buffer)))
    (pop-to-buffer memo-summary-buffer)
    (if (window-live-p (get-buffer-window memo-summary-buffer))
	(goto-char (point-eol)))
    (if (re-search-forward word nil t)
	(progn
	  (goto-char (point-bol))
	  (set-window-start (get-buffer-window (get-buffer memo-summary-buffer))
			    (point))))
    (pop-to-buffer buf)))

(defun memo-summary-save-item (folder)
  (interactive "FSave folder (test implement): ")
  (let (num n buf-tmp b e)
    (save-excursipon
      (goto-char (point-bol))
      (if (re-search-forward "^ *\\([0-9]+\\)" nil t)
	  (progn
	    (setq num (length memo-items))
	    (setq n (string-to-int
		     (buffer-substring (match-beginning 1) (match-end 1))))
	    (setq buf-tmp (current-buffer))
	    (pop-to-buffer memo-summary-buffer)
	    (widen)
	    (memo-copy-entry-as-kill)
					;(memo-kill-entry)
	    (find-file folder)
	    (pop-to-buffer (get-file-buffer folder))
	    (goto-char (point-min))
	    (if (re-search-forward memo-entry-separated-tag nil t)
		(forward-char 1)
	      (insert (concat "# -*- memo -*-\n---\n")))
	    (yank)
	    (save-buffer)
	    (pop-to-buffer memo-summary-buffer)
	    ;(save-buffer)
	    ;(memo-summary-make)
	    ;(memo-summary-display-summary)
	    ;(setq num (length memo-items))
	    ;(if (> n num) (setq n num))
	    ;(setq b (car (nth (- num n) memo-items)))
	    ;(setq e (car (cdr (nth (- num n) memo-items))))
	    (narrow-to-region b e)
	    (pop-to-buffer buf-tmp)
	    (beginning-of-line)
	    (kill-line)
	    )))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Some Utilities

(defun point-bol () (save-excursion (beginning-of-line) (point)))
(defun point-eol () (save-excursion (end-of-line) (point)))

(defun repeat-char (ch n)
  (let ((i n) (str))
    (while (> i 0)
      (progn
	(setq str (concat str ch))
	(setq i (- i 1))))
    str))

(defun split-window-calculate-height (height) ;; from yatexlib.el
  "Split current window wight specified HEIGHT.
If HEIGHT is number, make a new window that has HEIGHT lines.
If HEIGHT is string, make a new window that occupies HEIGT % of screen height.
Otherwise split window conventionally."
  (if (one-window-p t)
      (split-window
       (selected-window)
       (max
	(min
	 (- (screen-height)
	    (if (numberp height)
		(+ height 2)
	      (/ (* (screen-height)
		    (string-to-int height))
		 100)))
	 (- (screen-height) window-min-height 1))
	window-min-height))))

(provide 'memo-mode)

(defvar memo-mode-load-hook nil)
(run-hooks 'memo-mode-load-hook)

;;; end of memo-mode here.
