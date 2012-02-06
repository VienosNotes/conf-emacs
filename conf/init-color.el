(provide 'init-color)

(setq transient-mark-mode t)
(global-font-lock-mode t) 
(global-hl-line-mode t)
(setq font-lock-maximum-decoration t)
(setq show-paren-mode t)

(if window-system 
    (progn

;      (set-face-background 'region "rgb:69/69/69")
      (set-face-background 'region "rgb:33/22/11")

      (add-to-list 'default-frame-alist '(background-color . "rgb:00/00/00"))
;     (add-to-list 'default-frame-alist '(background-color . "rgb:B4/AB/84"))
;      (add-to-list 'default-frame-alist '(foreground-color . "rgb:cc/cc/ff"))
      (add-to-list 'default-frame-alist '(foreground-color . "rgb:99/99/99"))
;     (set-face-foreground 'font-lock-comment-face "rgb:55/6b/2f")
      (set-face-foreground 'font-lock-comment-face "rgb:44/99/44")
;      (set-face-foreground 'font-lock-string-face  "rgb:ee/99/99")
      (set-face-foreground 'font-lock-string-face  "rgb:ee/66/ee")
      (set-face-foreground 'font-lock-keyword-face "rgb:66/66/ff")
;      (set-face-foreground 'font-lock-function-name-face "rgb:cd/b7/9e")
      (set-face-foreground 'font-lock-function-name-face "PaleGreen1")
;      (set-face-bold-p 'font-lock-function-name-face nil)
;      (set-face-foreground 'font-lock-variable-name-face "rgb:ca/ff/70")
      (set-face-foreground 'font-lock-variable-name-face "chocolate")
      (set-face-foreground 'font-lock-type-face "rgb:48/76/ff")
;      (set-face-foreground 'font-lock-builtin-face "rgb:cd/10/76")
      (set-face-foreground 'font-lock-builtin-face "rgb:chocolate")
;      (set-face-foreground 'font-lock-constant-face "rgb:2f/4f/4f")
      (set-face-foreground 'font-lock-constant-face "rgb:00/ee/76")
      (set-face-foreground 'font-lock-warning-face "rgb:cd/10/76")
      (set-face-bold-p 'font-lock-warning-face t)


      (modify-all-frames-parameters
       (list (cons 'alpha  '(70 50 50 15))))

      )

)


;(defface my-hl-line-face
;((((class color)(background light))
;(:background "dark khaki"))
;(t (:background "gray")))
; "my hl-line mode")
;(setq hi-line-face 'my-hl-line-face)

(defface hlline-face
  '((((class color)
      (background dark))
     (:background "rgb:08/08/08"))
    (((class color)
      (background light))
     (:background "rgb:08/08/08"))
    (t
     ()))
  "*Face used by hl-line.")
(setq hl-line-face 'hlline-face)

(set-face-foreground 'ac-completion-face "tan1")
(set-face-background 'ac-selection-face "chocolate")
(set-face-foreground 'ac-selection-face "blue4")
(set-face-foreground 'ac-candidate-face "OrangeRed4")
(set-face-background 'ac-candidate-face "LightGoldenrod1")




















