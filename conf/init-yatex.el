(provide 'init-yatex)

;; YaTeX-mode init
(setq auto-mode-alist
      (cons (cons "\\.tex$" 'yatex-mode) auto-mode-alist))
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)


(setq YaTeX-kanji-code 4)

;(setq tex-command "~/Library/TeXShop/bin/platex2pdf-utf8";"platex"
(setq tex-command "~/bin/scripts/tex2pdf";"platex"
      dvi2-command "open -a Preview"; "dviout -1 -Set=!m"
      dviprint-command-format "/usr/bin/env dvipdfmx %s; open %s"
      YaTeX-kanji-code 4   ; (1 SJIS, 2 JIS, 3 EUC) JIS(junet-unix)だとOS依存せずにコンパイルできる
      section-name "documentclass"
      makeindex-command "mendex"
      YaTeX-use-AMS-LaTeX t   ; AMS-LaTeXを使う
      YaTeX-use-LaTeX2e t     ; LaTeX2eを使う
      YaTeX-use-font-lock t   ; 色付け
      )


(custom-set-faces
   '(YaTeX-font-lock-declaration-face (
    (((class color) (background dark)) (:foreground "chocolate"))
    (((class color) (background light)) (:foreground "black"))
    ))
)

(custom-set-faces
 '(YaTeX-sectioning-2 (
    (((class color) (background dark)) (:foreground "chocolate" :background "navy"))
    (((class color) (background light)) (:foreground "Black"))
    ))
)


(custom-set-faces
 '(YaTeX-sectioning-3 (
    (((class color) (background dark)) (:foreground "chocolate" :background "navy"))
    (((class color) (background light)) (:foreground "Black"))
    ))
)


(custom-set-faces
 '(YaTeX-sectioning-4 (
    (((class color) (background dark)) (:foreground "chocolate" :background "navy"))
    (((class color) (background light)) (:foreground "Black"))
    ))
)

(defun describe-face-at-point ()
  "Return face used at point."
  (interactive)
  (message "%s" (get-char-property (point) 'face)))








