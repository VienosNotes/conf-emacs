(provide 'change-buffer)
(defvar my-ignore-blst            ; ��ư�κݤ�̵�뤹��Хåե��Υꥹ��
  '("*Help*" "*Mew completions*" "*Completions*" "*Shell Command Output*"
    "*Buffer List*"))
(defvar my-vblst nil)             ; ��ư���ϻ��� buffer list ����¸
(defvar my-bslen 15)              ; buffer list ��� buffer name �κ�Ĺ��
(defvar my-blst-display-time 2)   ; buffer list ��ɽ������
(defface my-cbface                ; buffer list ��� current buffer �򼨤� face
  '((t (:foreground "red" :underline t))) nil)
(defvar my-op-mode) ; ��ư���ꤵ����ѿ� (1 ����ư 2 ����ư 3 ID��ư 4 �ե��륿)
(defvar my-spliter-alist ; �Хåե�ɽ����ΥХåե��֤Υ��ץ�å�
  '((1 . " < ") (2 . " > ") (3 . " ") (4 . " / ")))
(defvar my-prompt-alist ; �Хåե�ɽ����Υץ��ץ�
  '((1 . "[<<-] ") (2 . "[->>] ") (3 . "") (4 . "")))

(defun my-visible-buffers (blst &optional reg)
  (if (eq blst nil) '()
    (let ((bufn (buffer-name (car blst))))
      (if (or (= (aref bufn 0) ? )                  ; �ߥ˥Хåե���
              (not (string-match (or reg "") bufn)) ; reg ��ޤޤʤ��Хåե���
              (member bufn my-ignore-blst))         ; ̵�뤹��Хåե��ˤϰ�ư���ʤ�
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
                   (if (> (string-width bs) my-bslen) ; �ڤ�ͤ�
                       (setq bs (concat (substring bs 0 (- my-bslen 2)) "..")))
                   (setq len (+ len (string-width (concat bs spliter))))
                   (when (eq buf (current-buffer)) ; ɽ����ΥХåե��϶�Ĵɽ��
                     (put-text-property 0 (length bs) 'face 'my-cbface bs))
                   (cond ((> len (frame-width)) ;; frame ����Ŭ������
                          (setq len (+ (string-width (concat prompt bs spliter))))
                          (concat "\n" (make-string (string-width prompt) ? ) bs))
                         (t (concat (and (= my-op-mode 3) (my-buf-id buf)) bs))))) ; ID
               my-vblst spliter)))
    (cond ((<= my-op-mode 2) ; ñ���ư
           (let (message-log-max)
             (message "%s%s" prompt str))
           (if (sit-for my-blst-display-time) (message nil))) ; ɽ����ä�
          ((= my-op-mode 3) ; �Хåե��� ID ����ꤷ�ư�ư
           (let* ((id-str (read-string (concat str "\nSpecify Buffer ID: ")))
                  (id (string-to-number id-str)))
             (if (and (>= id 1) (<= id (length my-vblst))) ;; ��ư�Ǥ��� ID �ʤ�
                 (switch-to-buffer (nth (1- id) my-vblst)) ;; ��ư����
               ;; ��ʸ�����ID�˻��ꤷ�ơ������ID����ꤷ�褦�Ȥ��Ƥ����齪λ
               (unless (and (eq my-op-mode 3) (string= id-str "")) ; (*)
                 (my-show-buffer-list))))) ; ����ʤ���� my-op-mode �Ǻƽ���
          ((= my-op-mode 4) ; �Хåե�̾������ɽ���ǥե��륿
           (let* ((reg (read-string (concat str "\nBuffer-name regexp: "))))
             ;; �ե��륿�ǹʹ��ߤ򤫤��ư�ư����ΥХåե��������
             (setq my-vblst (or (my-visible-buffers my-vblst reg) my-vblst))
             ;; ��ʸ����ǹʹ��ߤ��Ƥ��ʤ���С��������줿��ư�������Ƭ�˰�ư
             (when (not (string= reg "")) (switch-to-buffer (car my-vblst)))
             ;; ��ʸ����ǹʹ��ߤ��ơ�����˹ʹ��ߤ򤷤褦�Ȥ��Ƥ����齪λ
             (when (or (not (eq my-op-mode 4)) (not (string= reg ""))) ; (*)
               (my-show-buffer-list)))) ; ����ʤ���� my-op-mode �˽����ƽ���
          )))

(defun my-operate-buffer (mode)
  (setq my-op-mode mode)
  ;; my-show-buffer-list ��� read-string ���٤����� exit-minibuffer ������
  ;; ���� my-op-mode �� mode ����ꤷ�Ƥ��� (*) ����ͭ��
  (when (window-minibuffer-p (selected-window)) (exit-minibuffer))
  (unless (eq last-command 'my-operate-buffer)  ; �Хåե��ꥹ�Ƚ����
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