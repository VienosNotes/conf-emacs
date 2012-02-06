(provide 'change-buffer)
(defvar my-ignore-blst            ; 移動の際に無視するバッファのリスト
  '("*Help*" "*Mew completions*" "*Completions*" "*Shell Command Output*"
    "*Buffer List*"))
(defvar my-vblst nil)             ; 移動開始時の buffer list を保存
(defvar my-bslen 15)              ; buffer list 中の buffer name の最長値
(defvar my-blst-display-time 2)   ; buffer list の表示時間
(defface my-cbface                ; buffer list 中の current buffer を示す face
  '((t (:foreground "red" :underline t))) nil)
(defvar my-op-mode) ; 自動設定される変数 (1 前移動 2 次移動 3 ID移動 4 フィルタ)
(defvar my-spliter-alist ; バッファ表示中のバッファ間のスプリッタ
  '((1 . " < ") (2 . " > ") (3 . " ") (4 . " / ")))
(defvar my-prompt-alist ; バッファ表示中のプロンプト
  '((1 . "[<<-] ") (2 . "[->>] ") (3 . "") (4 . "")))

(defun my-visible-buffers (blst &optional reg)
  (if (eq blst nil) '()
    (let ((bufn (buffer-name (car blst))))
      (if (or (= (aref bufn 0) ? )                  ; ミニバッファと
              (not (string-match (or reg "") bufn)) ; reg を含まないバッファと
              (member bufn my-ignore-blst))         ; 無視するバッファには移動しない
          (my-visible-buffers (cdr blst) reg)
        (cons (car blst) (my-visible-buffers (cdr blst) reg))))))

(defun my-buf-id (buf) (format "%s) " (length (memq buf (reverse my-vblst)))))

(defun my-show-buffer-list ()
  (let* ((prompt (cdr (assq my-op-mode my-prompt-alist)))
         (spliter (cdr (assq my-op-mode my-spliter-alist)))
         (len (string-width prompt))
         (str (mapconcat
               (lambda (buf)
                 (let ((bs (copy-sequence (buffer-name buf))))
                   (if (> (string-width bs) my-bslen) ; 切り詰め
                       (setq bs (concat (substring bs 0 (- my-bslen 2)) "..")))
                   (setq len (+ len (string-width (concat bs spliter))))
                   (when (eq buf (current-buffer)) ; 表示中のバッファは強調表示
                     (put-text-property 0 (length bs) 'face 'my-cbface bs))
                   (cond ((> len (frame-width)) ;; frame 幅で適宜改行
                          (setq len (+ (string-width (concat prompt bs spliter))))
                          (concat "\n" (make-string (string-width prompt) ? ) bs))
                         (t (concat (and (= my-op-mode 3) (my-buf-id buf)) bs))))) ; ID
               my-vblst spliter)))
    (cond ((<= my-op-mode 2) ; 単純移動
           (let (message-log-max)
             (message "%s%s" prompt str))
           (if (sit-for my-blst-display-time) (message nil))) ; 表示を消す
          ((= my-op-mode 3) ; バッファの ID を指定して移動
           (let* ((id-str (read-string (concat str "\nSpecify Buffer ID: ")))
                  (id (string-to-number id-str)))
             (if (and (>= id 1) (<= id (length my-vblst))) ;; 移動できる ID なら
                 (switch-to-buffer (nth (1- id) my-vblst)) ;; 移動する
               ;; 空文字列をIDに指定して、さらにIDを指定しようとしていたら終了
               (unless (and (eq my-op-mode 3) (string= id-str "")) ; (*)
                 (my-show-buffer-list))))) ; さもなければ my-op-mode で再処理
          ((= my-op-mode 4) ; バッファ名を正規表現でフィルタ
           (let* ((reg (read-string (concat str "\nBuffer-name regexp: "))))
             ;; フィルタで絞込みをかけて移動候補のバッファを再設定
             (setq my-vblst (or (my-visible-buffers my-vblst reg) my-vblst))
             ;; 空文字列で絞込みしていなければ、更新された移動候補の先頭に移動
             (when (not (string= reg "")) (switch-to-buffer (car my-vblst)))
             ;; 空文字列で絞込みして、さらに絞込みをしようとしていたら終了
             (when (or (not (eq my-op-mode 4)) (not (string= reg ""))) ; (*)
               (my-show-buffer-list)))) ; さもなければ my-op-mode に従い再処理
          )))

(defun my-operate-buffer (mode)
  (setq my-op-mode mode)
  ;; my-show-buffer-list 中の read-string を潰す↓の exit-minibuffer より先に
  ;; ↑で my-op-mode に mode を指定しておく (*) 時に有効
  (when (window-minibuffer-p (selected-window)) (exit-minibuffer))
  (unless (eq last-command 'my-operate-buffer)  ; バッファリスト初期化
    (setq my-vblst (my-visible-buffers (buffer-list))))
  (when (<= my-op-mode 2)
    (let* ((blst (if (= my-op-mode 2) my-vblst (reverse my-vblst))))
      (switch-to-buffer (or (cadr (memq (current-buffer) blst)) (car blst)))))
  (my-show-buffer-list)
  (setq this-command 'my-operate-buffer))

(defun my-sellect-visible-buffers () (interactive) (my-operate-buffer 3))
(defun my-filter-visible-buffers () (interactive) (my-operate-buffer 4))

(global-set-key [?\C-,] (lambda () (interactive) (my-operate-buffer 1)))
(global-set-key [?\C-.] (lambda () (interactive) (my-operate-buffer 2)))
(global-set-key [?\C-@] 'my-sellect-visible-buffers)
(global-set-key [?\C-\;] 'my-filter-visible-buffers)