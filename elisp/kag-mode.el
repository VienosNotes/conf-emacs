;;; kag-mode.el --- Major mode for editing KAG scripts.

;; [copyright]
;;
;; This program is distributed under the MIT license.
;;
;; Copyright (C) 2002-2005 by Kouhei Yanagita <yanagi at shakenbu.org>
;; 
;; Permission is hereby granted, free of charge, to any person
;; obtaining a copy of this software and associated documentation
;; files, to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject
;; to the following conditions:
;; 
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;; 
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
;; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
;; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
;; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.


;;; Commentary:
;;
;;=begin
;;= kag-mode.el
;;Last modified: Sat Sep 10 23:14:08 2005
;;
;;== �ҤȤ��ȾҲ�
;;KAG �Υ��ʥꥪ�򰷤������ Emacsen �ѥ᥸�㡼�⡼�ɤǤ���
;;
;;== �ܼ�
;;* ((<ư�����>))
;;* ((<����>))
;;* ((<���������>))
;;* ((<�饤����>))
;;* ((<���󥹥ȡ���>))
;;* ((<font-lock �ˤ�뿧�դ�>))
;;* ((<���ʥꥪ�¹�>))
;;* ((<�������ϻٱ�>))
;;* ((<������ե���󥹸���>))
;;* ((<��������ɽ��>))
;;* ((<�����ʤɤ�ɽ���ˤĤ���>))
;;* ((<��ư�ˤĤ���>))
;;* ((<����¾>))
;;* ((<References>))
;;
;;== ư�����
;;<<< doc/snapshot_includee
;;
;;== ����
;;KAG �Υ��ʥꥪ�򰷤������ Emacsen �ѥ᥸�㡼�⡼�ɤǤ���
;;
;;���Τ褦�ʵ�ǽ������ޤ���
;;
;;* font-lock �ˤ�뿧�դ�
;;* ���������ϻٱ�
;;* ��٥�䥿��ñ�̤Ǥΰ�ư�������ؤΰ�ư�ʤ�
;;* ������ե���󥹸���������������ɽ��
;;
;;
;;== ���������
;;* ((<kag-mode.el|URL:kag-mode.el>))
;;
;;
;;== �饤����
;;���Υץ����� ((<MIT �饤����|URL:http://www.opensource.org/licenses/mit-license.php>))
;;�θ������ۤ���ޤ���
;;
;;
;;== ���󥹥ȡ���
;;.emacs (���뤤���̤ν������ե�����)�ˡ�
;;  (autoload 'kag-mode "kag-mode" "Major mode for editing KAG scripts" t)
;;�Ƚ񤤤Ʋ�������
;;
;;��ĥ�� .ks �Υե�������� kag-mode �ǰ����������ϡ�
;;  (setq auto-mode-alist (append '(( "\\.ks$" . kag-mode)) auto-mode-alist))
;;���ɲä��Ʋ�������
;;
;;((<������ե���󥹸���>))��Ԥ��������ϡ�
;;((<texinfo �� KAG ������ե����|URL:http://shakenbu.org/yanagi/kag-texinfo/>))
;;�⥤�󥹥ȡ��뤷�Ƥ���������
;;
;;
;;== font-lock �ˤ�뿧�դ�
;;���������ޥ�ɹԡ������ȡ���٥�Τۤ���
;;���ѥ��ڡ����ȹ����Υ��ڡ������դ����ޤ���
;;���դ������ˤ���ʤ��Ȥ��ϡ�kag-*-face ������򤤤��äƤ���������
;;
;;
;;== ���ʥꥪ�¹�
;;���߳����Ƥ��륷�ʥꥪ(���ޤޤ��ץ�������)���Τ��Τ��
;;�¹Ԥ��뤳�Ȥ��Ǥ��ޤ���
;;
;;�ޤ���kag-kirikiri-command �ˡ���Τ��Τ�¹ԥե�����Υѥ������ꤷ�ޤ���
;;  (setq kag-kirikiri-command "c:/foo/bar/krkr.eXe")
;;
;;���Ȥϡ�C-c C-z e �Ǹ��ߤΥץ������Ȥ�¹ԤǤ��ޤ���
;;
;;
;;== �������ϻٱ�
;;kag-insertion-prefix ��³����1�������Ϥ���ȡ��������ϻٱ�Ȥʤ�ޤ���
;;kag-insertion-prefix �ϡ��ǥե���ȤǤ� C-c C-t �Ǥ���
;;
;;�㤨�С�C-c C-t e �����Ϥ���ȡ�eval �������������뤳�Ȥ��Ǥ��ޤ���
;;���ΤȤ���kag-use-prompt-when-insertion-p �� non-nil �ʤ�С�
;;°�����ͤ�ҤͤƤ��ޤ���ɬ�ܤǤʤ�°���ϡ��������Ϥ��ʤ�
;;(���Τޤޥ꥿����򲡤�)���Ȥǥ����åפǤ��ޤ���
;;
;;���ޥ�ɤˤ�äƤϡ���ĤΥ����ǤϤʤ��������Υڥ��������Ǥ��ޤ���   
;;�㤨�� C-c C-t i �����Ϥ���ȡ�if/endif �����Υڥ����������뤳�Ȥ��Ǥ��ޤ���
;;���Τ褦�˥ڥ��Υ��������Ϥ��륳�ޥ�ɤϡ�C-u C-c C-t i �Τ褦��
;;���ְ�����Ϳ���Ƶ�ư����ȡ��꡼�����򥿥��Υڥ��ǰϤळ�Ȥ��Ǥ��ޤ���
;;
;;call, jump, link, return �����ϡ�storage °���� target °���ǡ��䴰�������ޤ���
;;
;;
;;
;;== ������ե���󥹸���
;;Emacsen �夫�� KAG �Υ�����ե���󥹤򸡺����뤳�Ȥ��Ǥ��ޤ���
;;
;;((<texinfo �� KAG ������ե����|URL:http://shakenbu.org/yanagi/kag-texinfo/>))
;;���������ɤ������󥹥ȡ��뤷�Ƥ���������
;;
;;kag-display-tag-reference (M-?)�ǡ������Υ�ե���󥹤򸫤뤳�Ȥ��Ǥ��ޤ���
;;�ݥ���Ȥ������ξ�ˤ��ä���硢�ǥե���ȤϤ��Υ����Ȥʤ�ޤ���
;;
;;
;;== ��������ɽ��
;;* C-c C-z h �ǡ������ΰ��������򸫤뤳�Ȥ��Ǥ��ޤ���
;;* C-c C-z SPC �ǡ����ߥݥ���Ȥ�������֤Υ����ΰ��������򸫤뤳�Ȥ��Ǥ��ޤ���
;;
;;
;;== �����ʤɤ�ɽ���ˤĤ���
;;�������ɤ߹��ޤ������������������ʤɤ�ɽ�����뤳�Ȥ��Ǥ��ޤ���
;;c:/foo/bar/viewer.exe �ǲ�����ɽ���������Ȥ���ȡ�.emacs ��
;;  (setq kag-external-viewer-list '(("c:/foo/bar/viewer.exe")))
;;�����ꤷ�Ƥ����ޤ���
;;
;;���Ȥϡ�������°�����ͤΤȤ���ǡ�kag-show-object-at-point (C-c C-z v) 
;;��¹Ԥ���С����Υե�����򸫤뤳�Ȥ��Ǥ��ޤ���
;;
;;�ӥ塼����ʣ�����ꤹ�뤳�Ȥ��Ǥ��ޤ���
;;ʣ�����ꤹ��Ȥ��ϡ�
;;  (setq kag-external-viewer-list '(("c:/foo/bar/viewer.exe")
;;                                   ("c:/hoge/fuga/viewer2.exe")))
;;�Τ褦�����ꤷ�ޤ���
;;kag-show-object-at-point ��¹Ԥ���Ȥ��ˡ����ְ����Ȥ���2��Ϳ����С�
;;(C-u 2 ��Ƭ�ˤĤ��Ƽ¹Ԥ����) 2���ܤΥӥ塼���Ǹ��뤳�Ȥ��Ǥ��ޤ���
;;(���ְ�����Ϳ���ʤ��ä���硢�ꥹ�Ȥκǽ�Υӥ塼�����Ȥ��ޤ���)
;;
;;�ӥ塼���˥��ޥ�ɥ饤�󥪥ץ��������ꤷ�����Ȥ��ϡ�
;;("c:/foo/bar/viewer.exe") ����ʬ�� ("c:/foo/bar/viewer.exe" "-a" "-b")
;;�Τ褦�����ꤷ�ޤ���
;;
;;storage="foo" �Τ褦�ˡ�°�����ͤ˳�ĥ�Ҥ����ꤵ��Ƥ��ʤ����
;;Ŭ���䴰���ޤ�����KAG ���ºݤ˹Ԥ��䴰�ȤϾ����㤦�Τǡ�����դ���������
;;(KAG ���䴰����ݤˤϡ��ɤΥ����Ǥ��뤫�ʤɤ��θ�����䴰���ޤ�����
;;�����ǤϤ����ޤǤϹ�θ���Ƥ��ޤ���)
;;
;;
;;== ��ư�ˤĤ���
;;* M-C-p �����Υ�٥�˰�ư�Ǥ��ޤ���
;;* M-C-n �Ǽ��Υ�٥�˰�ư�Ǥ��ޤ���
;;* M-C-a �����Υ����ֲ�ǽ�ʥ�٥�˰�ư�Ǥ��ޤ���
;;* M-C-e �Ǽ��Υ����ֲ�ǽ�ʥ�٥�˰�ư�Ǥ��ޤ���
;;* M-C-b �����Υ����˰�ư�Ǥ��ޤ���
;;* M-C-f �Ǽ��Υ����˰�ư�Ǥ��ޤ���
;;
;;(�����Ǥ��������Ȥϡ����ʥꥪ��ή����ᤷ����ΤǤϤ���ޤ���)
;;
;;�����ײ�ǽ�ʥ����ξ�� M-RET �ǥ�������˰�ư�Ǥ��ޤ���
;;�����פ����顢M-* ����äƤ���ޤ���
;;
;;
;;== ����¾
;;����¾�Υ��ޥ�ɤˤĤ��Ƥϡ�describe-mode (C-h m) ��ɽ�������
;;�����ޥåװ�����������������
;;
;;
;;== References
;;* ((<kikyou.info|URL:http://kikyou.info/>))
;;* ((<��Τ��Τ���ˣ��ǿ�ʰѰ���|URL:http://www.piass.com/kpc/>))
;;* ((<texinfo �� KAG ������ե����|URL:http://shakenbu.org/yanagi/kag-texinfo/>))
;;* ((<outline-minor-mode �Τ�����|URL:http://shakenbu.org/yanagi/outline-minor-mode/>))
;;* ((<Emacs Lisp �ˤ��ץ���ߥ� - �鿴�ԤΤ��������|URL:http://www.namazu.org/~tsuchiya/doc/emacs-lisp-intro-jp-95.tar.gz>))
;;* ((<GNU Emacs Lisp ��ե���󥹡��ޥ˥奢��|URL:ftp://ftp.ascii.co.jp/pub/GNU/elisp-manual-20/elisp-manual-20-2.5-jp.tgz>))
;;* ((<Emacs How To - ���Фʥ�����|URL:http://www.fides.dti.ne.jp/~oka-t/emacs.html#font-lock>))
;;* ((<mode-info|URL:http://www.namazu.org/~tsuchiya/elisp/mode-info.html>))
;;
;;== ����
;;* [2004/02/14] �����Ȥν������С�������ֹ���դ��Ƥʤ��ä��Τ� 1.0.0 �ˤ��롣
;;* [2003/12/17] KAG 3.20 �Ѥ� kag-tag-arg-doc-alist �򹹿���
;;* [2002/12/31] ����
;;
;;<<< doc/footer_includee
;;=end
;;

;;; Code:
(require 'cl)

(defconst kag-mode-version "1.0.0")

(defvar kag-mode-hook nil
  "kag-mode �����ä��Ȥ��˸ƤФ��ؿ��Υꥹ��")

(defvar kag-insertion-prefix "\C-c\C-t"
  "���������Τ���Υ��ޥ���� prefix")

(defvar kag-insertion-map nil
  "")

(if kag-insertion-map
    nil
  (let ((map (make-sparse-keymap)))
    (define-key map "\t" 'kag-insert-tag-indent)
    (define-key map "\C-m" 'kag-insert-tag-return-with-completion)
    (define-key map "a" 'kag-insert-tag-hact)
    (define-key map "c" 'kag-insert-tag-call-with-completion)
    (define-key map "e" 'kag-insert-tag-eval)
    (define-key map "g" 'kag-insert-tag-ignore)
    (define-key map "h" 'kag-insert-tag-hch)
    (define-key map "i" 'kag-insert-tag-if)
    (define-key map "j" 'kag-insert-tag-jump-with-completion)
    (define-key map "l" 'kag-insert-tag-link)
    (define-key map "m" 'kag-insert-tag-macro)
    (define-key map "n" 'kag-insert-tag-nowait)
    (define-key map "q" 'kag-insert-tag-quake)
    (define-key map "r" 'kag-insert-tag-ruby)
    (define-key map "R" 'kag-insert-text-with-ruby)
    (define-key map "s" 'kag-insert-tag-iscript)
    (define-key map "w" 'kag-insert-tag-wait)
    (setq kag-insertion-map map)))

(defvar kag-command-prefix "\C-c\C-z"
  "kag-mode �Υ��ޥ���� prefix")

(defvar kag-command-map nil
  "")

(if kag-command-map
    nil
  (let ((map (make-sparse-keymap)))
    (define-key map "e" 'kag-execute-current-script)
    (define-key map " " 'kag-display-current-tag-arg-list-to-minibuffer)
    (define-key map "h" 'kag-display-tag-arg-list-to-minibuffer)
    (define-key map "v" 'kag-show-object-at-point)
    (define-key map "<" 'kag-comment-region)
    (define-key map ">" 'kag-uncomment-region)    
    (setq kag-command-map map)))


(defvar kag-mode-map nil
  "kag-mode �ѥ����ޥå�")

(if kag-mode-map
    nil
  (let ((map (copy-keymap text-mode-map)))
    (define-key map "\C-j" 'kag-newline-with-tag-r)

    (define-key map "\e\C-p" 'kag-backward-label)  
    (define-key map "\e\C-n" 'kag-forward-label)
    (define-key map "\e\C-a" 'kag-backward-savable-label)  
    (define-key map "\e\C-e" 'kag-forward-savable-label)

    (define-key map "\e\C-b" 'kag-backward-tag)
    (define-key map "\e\C-f" 'kag-forward-tag)
    (define-key map [?\M-\C-\ ] 'kag-mark-tag)
    (define-key map "\e\C-k" 'kag-kill-tag)
    (define-key map [(meta control backspace)] 'kag-backward-kill-tag)

    (define-key map "\e\C-m" 'kag-follow-link-at-point)
    (define-key map "\e*" 'kag-pop-link-mark)

    (define-key map "\e?" 'kag-display-tag-reference)

    (define-key map kag-command-prefix kag-command-map)
    (define-key map kag-insertion-prefix kag-insertion-map)

    (setq kag-mode-map map)))


(defvar kag-tag-delimiter-face
  font-lock-function-name-face
  "KAG �Υ����ζ��ڤ�� `[', `]', `@' �˻Ȥ���ե��������͡�")

(defvar kag-tag-name-face
  font-lock-function-name-face
  "KAG �Υ�����̾������ʬ�˻Ȥ���ե��������͡�")

(defvar kag-tag-attribute-face
  font-lock-variable-name-face
  "KAG �Υ�����°������ʬ�˻Ȥ���ե��������͡�")

(defvar kag-tag-value-face
  font-lock-string-face
  "KAG �Υ�����°�����ͤ���ʬ�˻Ȥ���ե��������͡�")

(defvar kag-comment-face
  font-lock-comment-face
  "KAG �Υ����Ȥ˻Ȥ���ե��������͡�")

(defvar kag-label-face
  font-lock-constant-face
  "KAG �Υ�٥�˻Ȥ���ե��������͡�")

(defface kag-zenkaku-space-face
  '((t (:background "gray")))
  "���ѥ��ڡ�����ɽ������Τ˻Ȥ���ե�������")
(defvar kag-zenkaku-space-face
  'kag-zenkaku-space-face
  "���ѥ��ڡ�����ɽ������Τ˻Ȥ���ե��������͡�")

(defface kag-excessive-space-face
  '((t (:background "gray")))
  "������ľ���Υ��ڡ�����ɽ������Τ˻Ȥ���ե�������")
(defvar kag-excessive-space-face
  'kag-excessive-space-face
  "������ľ���Υ��ڡ�����ɽ������Τ˻Ȥ���ե��������͡�")

(defvar kag-mode-syntax-table nil
  "kag-mode �ǻȤ��빽ʸ�ơ��֥롣")

(defvar kag-kirikiri-command nil
  "��Τ��Τ�μ¹ԥե�����Υѥ�")

(defvar kag-external-viewer-list ()
  "�����ե�����ʤɤ򸫤�Ȥ��˻Ȥ��������ץꥱ�������Υꥹ�ȡ�
�ꥹ�Ȥγ����Ǥϡ� (viewer-path opt1 opt2 ...) �Τ褦�ʥꥹ�ȡ�")

(defvar kag-relative-path-to-project-dir "../"
  "���ʥꥪ�Τ���ǥ��쥯�ȥ���椫�鸫�����ץ������ȥǥ��쥯�ȥ�����Хѥ���")

(defvar kag-storage-load-path
  '(
    "system"
    "image"
    "scenario"
    "bgimage"
    "fgimage"
    "bgm"
    "sound"
    "rule"
    "others"
    "video"
    )
  "KAG �Υե����븡���ѥ����ץ������ȥǥ��쥯�ȥ꤫������Хѥ��ǻ��ꤹ�롣
�ꥹ�Ȥκǽ�����ˤ����Τۤ�ͥ�褵��롣")

(defvar kag-completable-extensions
  '(
    ".tlg"
    ".eri"
    ".png"
    ".jif"
    ".jpg"
    ".jpeg"
    ".dib"
    ".bmp"
    ".mid"
    ".smf"
    ".tcw"
    ".wav"
    ".ogg"
    ".tcw"
    )
  "�ե�����򸡺�����ݤ��䴰��ǽ�ʳ�ĥ�ҡ�kag-search-file-from-path ���Ȥ���
�ꥹ�Ȥκǽ�����ˤ����Τۤ�ͥ�褵��롣")

(defvar kag-tag-name-regexp "\\w+"
  "KAG �Υ�����̾����ɽ������ɽ����")

(defvar kag-scenario-filename-regexp "\\.ks$"
  "KAG �Υ��ʥꥪ�ե������̾����ɽ������ɽ��")

(defvar kag-jumpable-tag-alist
  '(("button" . ("target" "storage"))
    ("call" . ("target" "storage"))
    ("jump" . ("target" "storage"))
    ("link" . ("target" "storage"))
    ("rclick" . ("target" "storage"))
    ("return" . ("target" "storage")))
  "�����ײ�ǽ�ʥ����Υꥹ�ȡ�
�ꥹ�Ȥγ����Ǥϡ� ( tagname . (target-attr storage-attr) ) 
�����Ǥ���ʤ�ꥹ�ȡ�")

(defvar kag-use-prompt-when-insertion-p t
  "���󥵡��Ȼ��˥ץ��ץȤ�Ȥ����ɤ�����")

(defvar kag-visit-link-marker-ring-length 16
  "kag-visit-link ���ƤФ줿���Υޡ�����Ͽ���뤿��Υ�󥰤�Ĺ����")

(defvar kag-visit-link-marker-ring (make-ring kag-visit-link-marker-ring-length)
  "kag-visit-link ���ƤФ줿���Υޡ�����Ͽ���뤿��Υ�󥰡�")

(defvar kag-tag-reference-node-name "(kag-tag)Tag Reference"
  "KAG ������ե���󥹤� info �ΥΡ���̾")

(defvar kag-tag-arg-doc-alist
  '(
    ("animstart" . "*layer, *seg, *target, page")
    ("animstop" . "*layer, *seg, page")
    ("autowc" . "ch, enabled, time")
    ("backlay" . "layer")
    ("bgmopt" . "gvolume, volume")
    ("button" . "*graphic, clickse, clicksebuf, countpage, enterse, entersebuf, exp, graphickey, hint, leavese, leavesebuf, onenter, onleave, recthit, storage, target")
    ("call" . "countpage, storage, target")
    ("cancelautomode" . "")
    ("cancelskip" . "")
    ("ch" . "*text")
    ("checkbox" . "*name, bgcolor, color, opacity")
    ("clearsysvar" . "")
    ("clearvar" . "")
    ("clickskip" . "*enabled")
    ("close" . "")
    ("cm" . "")
    ("commit" . "")
    ("copybookmark" . "*from, *to")
    ("copylay" . "*destlayer, *srclayer, destpage, srcpage")
    ("ct" . "")
    ("current" . "layer, page, withback")
    ("cursor" . "click, default, draggable, pointed")
    ("deffont" . "bold, color, edge, edgecolor, face, rubyoffset, rubysize, shadow, shadowcolor, size")
    ("defstyle" . "linesize, linespacing, pitch")
    ("delay" . "*speed")
    ("disablestore" . "restore, store")
    ("edit" . "*name, bgcolor, color, length, maxchars, opacity")
    ("emb" . "*exp")
    ("endhact" . "")
    ("endif" . "")
    ("endignore" . "")
    ("endindent" . "")
    ("endlink" . "")
    ("endmacro" . "")
    ("endnowait" . "")
    ("endscript" . "")
    ("er" . "")
    ("erasebookmark" . "place")
    ("erasemacro" . "*name")
    ("eval" . "*exp")
    ("fadebgm" . "*time, *volume")
    ("fadeinbgm" . "*storage, *time, loop")
    ("fadeinse" . "*storage, *time, buf, loop")
    ("fadeoutbgm" . "*time")
    ("fadeoutse" . "*time, buf")
    ("fadese" . "*time, *volume, buf")
    ("font" . "bold, color, edge, edgecolor, face, italic, rubyoffset, rubysize, shadow, shadowcolor, size")
    ("freeimage" . "*layer, page")
    ("glyph" . "fix, left, line, linekey, page, pagekey, top")
    ("goback" . "ask")
    ("gotostart" . "ask")
    ("graph" . "*storage, alt, char, key")
    ("hact" . "*exp")
    ("hch" . "*text, expand")
    ("hidemessage" . "")
    ("history" . "enabled, output")
    ("hr" . "repage")
    ("if" . "*exp")
    ("ignore" . "*exp")
    ("image" . "*layer, *storage, bceil, bfloor, bgamma, clipheight, clipleft, cliptop, clipwidth, fliplr, flipud, gceil, gfloor, ggamma, grayscale, index, key, left, mapaction, mapimage, mcolor, mode, mopacity, opacity, page, pos, rceil, rfloor, rgamma, top, visible")
    ("indent" . "")
    ("input" . "*name, prompt, title")
    ("iscript" . "")
    ("jump" . "countpage, storage, target")
    ("l" . "")
    ("laycount" . "layers, messages")
    ("layopt" . "*layer, autohide, index, left, opacity, page, top, visible")
    ("link" . "clickse, clicksebuf, color, countpage, enterse, entersebuf, exp, hint, leavese, leavesebuf, onenter, onleave, storage, target")
    ("load" . "ask, place")
    ("loadplugin" . "*module")
    ("locate" . "x, y")
    ("locklink" . "")
    ("locksnapshot" . "")
    ("macro" . "*name")
    ("mapaction" . "*layer, *storage, page")
    ("mapdisable" . "*layer, page")
    ("mapimage" . "*layer, *storage, page")
    ("mappfont" . "*storage")
    ("move" . "*layer, *path, *time, accel, delay, page, spline")
    ("nextskip" . "*enabled")
    ("nowait" . "")
    ("openvideo" . "*storage")
    ("p" . "")
    ("pausebgm" . "")
    ("pimage" . "*dx, *dy, *layer, *storage, key, mode, opacity, page, sh, sw, sx, sy")
    ("playbgm" . "*storage, loop")
    ("playse" . "*storage, buf, loop")
    ("playvideo" . "storage")
    ("position" . "color, draggable, frame, framekey, height, layer, left, marginb, marginl, marginr, margint, opacity, page, top, vertical, width")
    ("ptext" . "*layer, *text, *x, *y, angle, bold, color, edge, edgecolor, face, italic, page, shadow, shadowcolor, size, vertical")
    ("quake" . "*time, hmax, timemode, vmax")
    ("r" . "")
    ("rclick" . "call, enabled, jump, name, storage, target")
    ("record" . "")
    ("resetfont" . "")
    ("resetstyle" . "")
    ("resetwait" . "")
    ("resumebgm" . "")
    ("return" . "countpage, storage, target")
    ("ruby" . "*text")
    ("s" . "")
    ("save" . "ask, place")
    ("seopt" . "buf, gvolume, pan, volume")
    ("showhistory" . "")
    ("startanchor" . "enabled")
    ("stopbgm" . "")
    ("stopmove" . "")
    ("stopquake" . "")
    ("stopse" . "buf")
    ("stoptrans" . "")
    ("stopvideo" . "")
    ("store" . "*enabled")
    ("style" . "align, autoreturn, linesize, linespacing, pitch")
    ("tempload" . "backlay, bgm, place, se")
    ("tempsave" . "place")
    ("title" . "*name")
    ("trace" . "*exp")
    ("trans" . "*time, children, from, layer, method, rule, stay, vague")
    ("unlocklink" . "")
    ("unlocksnapshot" . "")
    ("video" . "height, left, top, visible, width")
    ("wa" . "*layer, *seg, page")
    ("wait" . "*time, canskip, mode")
    ("waitclick" . "")
    ("waittrig" . "*name, canskip, onskip")
    ("wb" . "canskip")
    ("wc" . "*time")
    ("wf" . "buf, canskip")
    ("wl" . "canskip")
    ("wm" . "canskip")
    ("wq" . "canskip")
    ("ws" . "buf, canskip")
    ("wt" . "canskip")
    ("wv" . "canskip")
    ("xchgbgm" . "*storage, *time, loop, overlap, volume")
    )
  "KAG �Υ����ΰ��������� alist")

(if kag-mode-syntax-table
    nil
  (setq kag-mode-syntax-table (make-syntax-table text-mode-syntax-table))
  (modify-syntax-entry ?_ "w   " kag-mode-syntax-table)
  (modify-syntax-entry ?- "w   " kag-mode-syntax-table))


(eval-and-compile
  (autoload 'Info-goto-node "info")
  (autoload 'Info-mode "info"))

(defun kag-display-tag-reference ()
  "�����Υ�ե���󥹤�ɽ�����롣"
  (interactive)
  (kag-display-tag-reference-noselect (completing-read "Tag: "
						       kag-tag-arg-doc-alist
						       nil
						       nil
						       (kag-get-tag-name-at-point))))

(defun kag-display-tag-reference-noselect (tagname)
  "�����ǻ��ꤵ�줿�����Υ�ե���󥹤�ɽ�����롣"
  (save-excursion
    (save-selected-window
      (let ((buf (get-buffer-create "*info<kag-tag>*"))
	    pos)
	(set-buffer buf)
	(if (not (eq major-mode 'Info-mode))
	    (Info-mode))
	(Info-goto-node kag-tag-reference-node-name)
	(save-match-data
	  (unless (re-search-forward (concat "-- Tag: " tagname "$") nil t 1)
	    (error "Reference for %s is not found." tagname)
	    )
	  (setq pos (point)))
	(let ((win (or (get-buffer-window buf)
		       (if (one-window-p)
			   (split-window)
			 (next-window)))))
	  (select-window win)
	  (set-window-buffer win buf)
	  (goto-char pos)
	  (recenter 1))))))



(defun kag-display-tag-arg-list-to-minibuffer (tagname)
  "KAG �Υ����ΰ���������ߥ˥Хåե���ɽ�����롣"
  (interactive "sTag name: ")
  (let ((argstr))
    (setq argstr (cdr (assoc-ignore-case tagname kag-tag-arg-doc-alist)))
    (cond ((null argstr)
	   (setq argstr "Unknown tag."))
	  ((equal argstr "")
	   (setq argstr "No arguments.")))
    (message "[%s]: %s" tagname argstr)))


(defun kag-display-current-tag-arg-list-to-minibuffer ()
  "�ݥ���Ȥΰ��֤ˤ��륿���ΰ���������ߥ˥Хåե���ɽ�����롣"
  (interactive)
  (let ((tagname (kag-get-tag-name-at-point)))
    (if tagname
	(kag-display-tag-arg-list-to-minibuffer tagname)
      (error "%s" "There is no tag at point."))))


(defun kag-get-project-dir ()
  "���߳����Ƥ��륷�ʥꥪ�Υץ������ȥǥ��쥯�ȥ�Υե�ѥ����֤���
�Хåե����ե�����˴�Ϣ�դ����Ƥ��ʤ��Ȥ��� nil ���֤���"
  (save-match-data
    (if (and (buffer-file-name) (string-match "\\(.*/\\)[^/]*" (buffer-file-name)))
	(expand-file-name (concat (match-string 1 (buffer-file-name))
				  kag-relative-path-to-project-dir))
      nil)))

(defun kag-execute-current-script ()
  "�����ȥХåե����ޤޤ��ץ������Ȥ��Τ��Τ�Ǽ¹Ԥ��롣"
  (interactive)
  (let ((project-dir (kag-get-project-dir)))
    (if project-dir
	(call-process kag-kirikiri-command nil 0 nil project-dir)
      (error "%s" "This buffer is not bound to file."))))


(defun kag-get-attr-value-at-point ()
  "�������뤬������°���ξ�ˤ���Ȥ��������ͤ��֤���
������°���ξ�ˤʤ��Ȥ��� nil ���֤���
�⤷°�����ͤ� \" �� ' �ǰϤ�Ǥ���Ȥ��ϡ� ���� \" �ޤ��� ' �ϼ������줿
ʸ�����֤���롣"
  (interactive)
  (save-excursion
    (save-match-data
      (let* ((search-point (point))
	     (begin (progn (beginning-of-line) (point)))
	     (end (progn (end-of-line) (point)))
	     (command-line-p (progn (beginning-of-line) (equal (char-after) ?@)))
	     )
	(catch 'return
	  (if (not (kag-inside-of-tag-p))
	      (throw 'return nil))
	  (while (< begin (point))
	    (if (not (kag-tag-head-p))
		(backward-char)))
	  (if (not (kag-inside-of-tag-p))
	      (throw 'return nil))
	  (while (and (< (point) search-point)
		      (if command-line-p
			  (re-search-forward "\\w+[ \t]*=[ \t]*\\([^\"' \t\r\n][^ \t\r\n]*\\|\"[^\"\r\n]*\"\\|'[^'\r\n]*'\\)" end t 1)
			(re-search-forward "\\w+[ \t]*=[ \t]*\\([^]\"' \t\r\n][^] \t\r\n]*\\|\"[^\"\r\n]*\"\\|'[^'\r\n]*'\\)" end t 1)))
	    (if (and (<= (match-beginning 0) search-point)
		     (< search-point (match-end 1)))
		(let ((value (match-string-no-properties 1)))
		  (if (and (equal (string-to-char value)
				  (string-to-char (substring value -1 nil)))
			   (or (equal (string-to-char value) ?\')
			       (equal (string-to-char value) ?\")))
		      (progn
			(setq value (substring value 1 -1))
			))
		  (throw 'return value))))
	  nil)))))


(defun kag-show-object-at-point (arg)
  "�ݥ���Ȥΰ��֤β����������������ե�����ʤɤ�ɽ�����롣
���ְ����ˤ�äơ��ɤγ����ӥ塼����Ȥä�ɽ�����뤫����롣

���ְ����ʤ��ξ���`kag-external-viewer-list'����Ƭ�Υӥ塼���ǡ�
���ְ����� 2 �ΤȤ���`kag-external-viewer-list'��2���ܤ˻��ꤵ��Ƥ���
�ӥ塼���ǡ��Τ褦�ˤ���ɽ������롣"
  (interactive "p")
  (let ((viewer (car (nth (1- arg) kag-external-viewer-list)))
	(options (cdr (nth (1- arg) kag-external-viewer-list)))
	image-path arg-list)
    (if (null viewer)
	(error "prefix %d is not available." arg))
    (if (not (file-executable-p viewer))
	(error "%s is not executable." viewer))
    (setq image-path (kag-search-file-from-path (kag-get-attr-value-at-point)))
    (if (file-exists-p image-path)
	(progn
	  (setq arg-list (append options (list image-path)))
	  (apply 'call-process viewer nil 0 nil arg-list))
      (error "%s is not found." image-path))))


(defun kag-newline-with-tag-r (&optional n)
  "r ��������������Ʊ���˲��Ԥ��롣"
  (interactive "*P")
  (if (< 0 (prefix-numeric-value n))
      (let ((i 0))
	(while (< i (prefix-numeric-value n))
	  (insert "[r]")
	  (newline)
	  (setq i (1+ i))))))



(defun kag-insert-tag-template (begin-tag-name end-tag-name attr-list value-list begin-tag-only)
  "���δؿ��ϡ�Ϳ����줿������̾����°�����饿�����ۤ���
�����ȥХåե��ˤ��Υ������������롣

�㤨�� if ������ endif �����Τ褦�ˡ��ڥ��ǻȤ��륿����
�����Ǥ���褦�ˡ� �����Υڥ������Ǥ���褦�ˤʤäƤ��롣

begin-tag-name �ϡ����ϥ�����̾���Ǥ��롣
�������ȡ�if �������������롣

end-tag-name �ϡ���λ������̾���Ǥ��롣
�������ȡ�endif �������������롣

attr-list �ϡ�begin-tag-name �ǻ��ꤵ�줿������°��������
ɽ���ꥹ�ȤǤ��롣
�ꥹ�Ȥγ����Ǥϡ�°����̾���ȡ�����°����ɬ�ܤǤ��뤫�ɤ���
�ο����ͤ���ʤ륳�󥹥���Ǥ��롣
�㤨�С�ɬ��°�� foo �ȡ�ɬ�ܤǤʤ�°�� bar �����Ϥ��������Ȥ��ϡ�
 '( (\"foo\" . t) (\"bar\" . nil) ) ��Ϳ���롣
ɬ�ܤǤʤ�°���ϡ��桼������ʸ�������Ϥ��뤳�Ȥˤ�äơ�
�������ʤ��褦�ˤ��뤳�Ȥ��Ǥ��롣

value-list �ϡ�°�����ͤΰ�����ɽ�魯�ꥹ�ȤǤ��롣
 (length attr-list) �� (length value-list) ���ͤ��������Ȥ��ϡ�
value-list ���ͤ�Ȥäƥ��������ۤ���롣
�����Ǥʤ��Ȥ��ϡ�value-list �����Ƥ�̵�뤵�졢°�����ͤ����Ϥ�
�桼���˵��롣

begin-tag-only �� non-nil �ʤ�С����ϥ����Τߤ��������롣"
  (let (s)
    (if (equal (length attr-list)
	       (length value-list))
	(let (attr value)
	  (setq s (concat "[" begin-tag-name))
	  (while attr-list
	    (setq attr (car (car attr-list)))
	    (setq value (car value-list))
	    (setq s (concat s " " attr "=\"" value "\""))
	    (setq attr-list (cdr attr-list))
	    (setq value-list (cdr value-list)))
	  (setq s (concat s "]"))
	  (unless begin-tag-only
	    (setq s (concat s "[" end-tag-name "]")))
	  (insert s)
	  (unless begin-tag-only
	    (backward-char (length (concat "[" end-tag-name "]")))))
      (if kag-use-prompt-when-insertion-p
	  (let (attr-and-value)
	    (setq attr-and-value (kag-get-attr-input begin-tag-name attr-list))
	    (kag-insert-tag-template begin-tag-name end-tag-name (car attr-and-value) (cdr attr-and-value) begin-tag-only))
	(setq s (concat "[" begin-tag-name))
	(if attr-list
	    (progn
	      (setq s (concat s " "))
	      (setq s (concat s (mapconcat 'car attr-list "=\"\" ") "=\"\""))))
	(setq s (concat s "]"))
	(unless begin-tag-only
	  (setq s (concat s "[" end-tag-name "]")))
	(insert s)
	(if attr-list
	    (backward-char (- (length s) (length (concat "[" begin-tag-name " " (car (car attr-list)) "=\""))))))
      )))



(defun kag-get-attr-input (tagname attrs)
  "�桼�����顢������°�������Ϥ����롣
attrs �� ((\"foo\" . t) (\"bar\" . nil))�Τ褦�ʥꥹ�ȡ�
�����Ǥϡ�°����̾���ȡ�����°����ɬ�ܤǤ��뤫�ɤ����ο����ͤ���ʤ륳�󥹥��롣
����ͤ� (cons ((\"foo\" . t) (\"bar\" . nil)) (\"foo_value\" \"bar_value\"))
�Τ褦�ʥ��󥹥��롣
kag-insert-tag-template �� attr-list ������ͤΥ��󥹥���� car ��
value-list ������ͤΥ��󥹥���� cdr ���Ϥ����Ȥ�տޤ��Ƥ��롣

ɬ�ܤǤʤ����������Ϥ���ά���줿�Ȥ��ϡ�����ͤ���Ϥ���°���Ͼʤ���Ƥ��롣
"
  (let (attr-result value-result)
    (while attrs
      (let ((attr (car (car attrs)))
	    (attr-required-p (cdr (car attrs)))
	    input-value)
	(setq input-value (read-string (concat "[" tagname "] " (if attr-required-p "*") attr ": ")))
	(unless (and (not attr-required-p)
		     (equal input-value ""))
	  (setq attr-result (append attr-result (list (car attrs))))
	  (setq value-result (append value-result (list input-value))))
	)
      (setq attrs (cdr attrs)))
    (cons attr-result value-result)
    ))


(defun kag-insert-tag-template-surround-region (begin-tag-name end-tag-name attr-list value-list)
  "�ΰ�� begin-tag-name/end-tag-name �����ǰϤࡣ
attr-list ����� value-list �ϡ�begin-tag �Τ���˻Ȥ��롣
�ܤ�����̣�ϡ�`kag-insert-tag-template' �򻲾ȡ�"
  (let ((begin (region-beginning))
	(end (region-end))
	attr)
    (setq attr (if (and kag-use-prompt-when-insertion-p
			(not (equal (length attr-list) (length value-list))))
		   (kag-get-attr-input begin-tag-name attr-list)
		 (cons attr-list value-list)))
    (goto-char end)
    (kag-insert-tag-template end-tag-name nil nil nil t)
    (goto-char begin)
    (kag-insert-tag-template begin-tag-name nil (car attr) (cdr attr) t)))

(defun kag-insert-tag-hact (&optional surround-region-p exp)
  "hact ������ endhact �����Υڥ����������롣
���ְ�����Ϳ���ƸƤӽФ��ȡ��꡼������ hact/endhact �����ǰϤࡣ"
  (interactive "*P")
  (if surround-region-p
      (kag-insert-tag-template-surround-region "hact" "endhact" '(("exp" . t)) (if exp (list exp) nil))
    (kag-insert-tag-template "hact" "endhact" '(("exp" . t)) (if exp (list exp) nil) nil)))

(defun kag-insert-tag-hch (&optional text)
  (interactive "*")
  (kag-insert-tag-template "hch" nil '(("text" . t)) (if text (list text) nil) t))

(defun kag-insert-tag-if (&optional surround-region-p exp)
  "if ������ endif �����Υڥ����������롣
���ְ�����Ϳ���ƸƤӽФ��ȡ��꡼������ if/endif �����ǰϤࡣ"
  (interactive "*P")
  (if surround-region-p
      (kag-insert-tag-template-surround-region "if" "endif" '(("exp" . t)) (if exp (list exp) nil))
    (kag-insert-tag-template "if" "endif" '(("exp" . t)) (if exp (list exp) nil) nil)))

(defun kag-insert-tag-ignore (&optional surround-region-p exp)
  "ignore ������ endignore �����Υڥ����������롣
���ְ�����Ϳ���ƸƤӽФ��ȡ��꡼������ ignore/endignore �����ǰϤࡣ"
  (interactive "*P")
  (if surround-region-p
      (kag-insert-tag-template-surround-region "ignore" "endignore" '(("exp" . t)) (if exp (list exp) nil))
    (kag-insert-tag-template "ignore" "endignore" '(("exp" . t)) (if exp (list exp) nil) nil)))

(defun kag-insert-tag-indent (&optional surround-region-p)
  "indent ������ endindent �����Υڥ����������롣
���ְ�����Ϳ���ƸƤӽФ��ȡ��꡼������ indent/endindent �����ǰϤࡣ"
  (interactive "*P")
  (if surround-region-p
      (kag-insert-tag-template-surround-region "indent" "endindent" nil nil)
    (kag-insert-tag-template "indent" "endindent" nil nil nil)))

(defun kag-insert-tag-macro (&optional surround-region-p name)
  "macro ������ endmacro �����Υڥ����������롣
���ְ�����Ϳ���ƸƤӽФ��ȡ��꡼������ macro/endmacro �����ǰϤࡣ"
  (interactive "*P")
  (if surround-region-p
      (kag-insert-tag-template-surround-region "macro" "endmacro" '(("name" . t)) (if name (list name) nil))
    (kag-insert-tag-template "macro" "endmacro" '(("name" . t))  (if name (list name) nil) nil)))

(defun kag-insert-tag-nowait (&optional surround-region-p)
  "nowait ������ endnowait �����Υڥ����������롣
���ְ�����Ϳ���ƸƤӽФ��ȡ��꡼������ nowait/endnowait �����ǰϤࡣ"
  (interactive "*P")
  (if surround-region-p
      (kag-insert-tag-template-surround-region "nowait" "endnowait" nil nil)
    (kag-insert-tag-template "nowait" "endnowait" nil nil nil)))

(defun kag-insert-tag-iscript (&optional surround-region-p)
  "iscript ������ endscript �����Υڥ����������롣
���ְ�����Ϳ���ƸƤӽФ��ȡ��꡼������ iscript/endscript �����ǰϤࡣ"
  (interactive "*P")
  (if surround-region-p
      (kag-insert-tag-template-surround-region "iscript" "endscript" nil nil)
    (kag-insert-tag-template "iscript" "endscript" nil nil nil)))

(defun kag-insert-tag-jump ()
  "jump �������������롣"
  (interactive "*")
  (kag-insert-tag-template "jump" nil '(("storage" . nil) ("target" . nil)) nil t))

(defun kag-insert-tag-call ()
  "call �������������롣"
  (interactive "*")
  (kag-insert-tag-template "call" nil '(("storage" . nil) ("target" . nil)) nil t))

(defun kag-insert-tag-return ()
  "return �������������롣"
  (interactive "*")
  (kag-insert-tag-template "return" nil '(("storage" . nil) ("target" . nil)) nil t))

(defun kag-read-storage-target-with-completion (tagname)
  "storage °���� target °�������Ϥ��䴰�Ĥ������롣
����ͤϡ�(cons '((\"storage\" . nil) (\"target\" . nil)) '(storage-value target-value))
�Τ褦�ʥ��󥹥��롣�����������Ϥ���ά���줿��ʬ�Ϻ���롣
`kag-insert-tag-template' �ΰ����Ȥ����Ϥ���뤳�Ȥ�տޤ��Ƥ��롣"
  (if kag-use-prompt-when-insertion-p
      (let ((storages (delete-if (function (lambda (x) (not (string-match kag-scenario-filename-regexp x))))
				 (directory-files "./")))
	    labels
	    storage label
	    attr-list value-list)
	(setq storage (completing-read (concat "[" tagname "] storage: ") (mapcar 'list storages)))
	(cond ((equal storage "")
	       (setq labels (kag-list-labels-in-buffer))
	       )
	      ((file-exists-p storage)
	       (setq labels (kag-list-labels-in-file storage))
	       (setq attr-list (append attr-list (list (cons "storage" nil))))
	       (setq value-list (append value-list (list storage)))
	       )
	      (t
	       (setq attr-list (append attr-list (list (cons "storage" nil))))
	       (setq value-list (append value-list (list storage)))
	       ))
    
	(setq label (completing-read (concat "[" tagname "] label: ") (mapcar 'list labels) nil nil (if labels "*" "")))
	(if (not (equal label ""))
	    (progn
	      (setq attr-list (append attr-list (list (cons "target" nil))))
	      (setq value-list (append value-list (list label)))))
	(cons attr-list value-list))
    (cons '(("storage" . nil) ("target" . nil)) '("" ""))))


(defun kag-insert-tag-jump-with-completion ()
  "jump �������������롣
storage �� target �����Ϥˤ��䴰���Ȥ��롣"
  (interactive "*")
  (let (attr-value)
    (setq attr-value (kag-read-storage-target-with-completion "jump"))
    (kag-insert-tag-template "jump" nil (car attr-value) (cdr attr-value) t))
  )
(defun kag-insert-tag-call-with-completion ()
  "call �������������롣
storage �� target �����Ϥˤ��䴰���Ȥ��롣"
  (interactive "*")
  (let (attr-value)
    (setq attr-value (kag-read-storage-target-with-completion "call"))
    (kag-insert-tag-template "call" nil (car attr-value) (cdr attr-value) t))
  )
(defun kag-insert-tag-return-with-completion ()
  "return �������������롣
storage �� target �����Ϥˤ��䴰���Ȥ��롣"
  (interactive "*")
  (let (attr-value)
    (setq attr-value (kag-read-storage-target-with-completion "return"))
    (kag-insert-tag-template "return" nil (car attr-value) (cdr attr-value) t))
  )



(defun kag-insert-tag-link (&optional surround-region-p)
  "link ������ endlink �����Υڥ����������롣
���ְ�����Ϳ���ƸƤӽФ��ȡ��꡼������ link/endlink �����ǰϤࡣ"
  (interactive "*P")
  (let (attr-value)
    (setq attr-value (kag-read-storage-target-with-completion "link"))
    (if surround-region-p
	(kag-insert-tag-template-surround-region "link" "endlink" (car attr-value) (cdr attr-value))
      (kag-insert-tag-template "link" "endlink" (car attr-value) (cdr attr-value) nil))))


(defun kag-insert-tag-eval (&optional exp)
  "eval �������������롣"
  (interactive "*")
  (kag-insert-tag-template "eval" nil '(("exp" . t)) (if exp (list exp) nil) t))

(defun kag-insert-tag-quake (&optional surround-region-p time)
  "quake ������ wq �����Υڥ����������롣
���ְ�����Ϳ���ƸƤӽФ��ȡ��꡼������ quake/wq �����ǰϤࡣ"
  (interactive "*P")
  (setq time (if time (list time) nil))
  (if surround-region-p
      (kag-insert-tag-template-surround-region "quake" "wq" '(("time" . t)) time)
    (kag-insert-tag-template "quake" "wq" '(("time" . t)) time nil)))

(defun kag-insert-tag-wait (&optional time)
  "wait �������������롣"
  (interactive "*")
  (kag-insert-tag-template "wait" nil '(("time" . t)) (if time (list time) nil) t))

(defun kag-insert-tag-ruby (&optional text)
  "ruby �������������롣"
  (interactive "*")
  (kag-insert-tag-template "ruby" nil '(("text" . t)) (if text (list text) nil) t))

(defun kag-insert-text-with-ruby (&optional text ruby)
  "ʸ�����ӤȤȤ���������롣
body �� ruby �ϤȤ�ˡ��ǽ��ʸ���ϥ�Ӥο������ζ��ڤ��
ɽ�����ڤ�ʸ���Ǥʤ��Ȥ����ʤ���
�㤨�С�\"/����/��\" �Τ褦�˻��ꤹ�롣
���ζ��ڤ�ʸ���ϡ�1ʸ���Ǥ���в��Ǥ�褤��

��:
body �� \"/��/��/��\"��ruby �� \"/��/�ۤ�/��\" ����ꤹ��ȡ�
  [ruby text=\"��\"]��[ruby text=\"�ۤ�\"]��[ruby text=\"��\"]��
�Ȥ���ʸ������������롣"
  (interactive "*")
  (unless body
    (setq body (read-string "body: ")))
  (unless ruby
    (setq ruby (read-string "ruby: ")))
  (let* ((body-separator (substring body 0 1))
	 (ruby-separator (substring ruby 0 1))
	 (body-list (split-string body body-separator))
	 (ruby-list (split-string ruby ruby-separator)))
    (while body-list
      (if (car ruby-list)
	  (kag-insert-tag-ruby (car ruby-list)))
      (insert (car body-list))
      (setq body-list (cdr body-list))
      (setq ruby-list (cdr ruby-list)))))


(defun kag-list-labels-in-buffer (&optional buffer-or-name)
  "�Хåե� buffer-or-name �˴ޤޤ���٥�Υꥹ�Ȥ��֤���
buffer-or-name �� nil �ʤ�С��оݤϥ����ȥХåե��Ǥ��롣"
  (let (result)
    (save-excursion
      (if buffer-or-name
	  (set-buffer buffer-or-name))
      (save-restriction
	(widen)
	(goto-char (point-min))
	(save-match-data
	  (while (re-search-forward "^\\*[^\r\n|]+" nil t 1)
	    (setq result (append result (list (match-string-no-properties 0))))))))
    result))

(defun kag-list-labels-in-file (file-name)
  "�ե����� file-name �˴ޤޤ���٥�Υꥹ�Ȥ��֤���
file-name ��¸�ߤ��ʤ��� nil ���֤���"
  (let (result)
    (if (file-exists-p file-name)
	(progn
	  (with-temp-buffer
	    (insert-file-contents file-name)
	    (save-match-data
	      (goto-char (point-min))
	      (while (re-search-forward "^\\*[^\r\n|]+" nil t 1)
		(setq result (append result (list (match-string-no-properties 0)))))))))
    result))



(defun kag-forward-label (n)
  "n �Ĥ�����Υ�٥�ΰ��֤˰�ư���롣"
  (interactive "p")
  (if (< 0 n)
      (and (progn (end-of-line) t) (re-search-forward "^\\*" nil 1 n) (beginning-of-line))
    (re-search-backward "^\\*" nil 1 (- n))))

(defun kag-backward-label (n)
  "n �Ĥ������Υ�٥�ΰ��֤˰�ư���롣"
  (interactive "p")
  (kag-forward-label (- n)))

(defun kag-forward-savable-label (n)
  "n �Ĥ�����Υ����ֲ�ǽ�ʥ�٥�ΰ��֤˰�ư���롣"
  (interactive "p")
  (if (< 0 n)
      (and (progn (end-of-line) t) (re-search-forward "^\\*.*|" nil 1 n) (beginning-of-line))
    (re-search-backward "^\\*.*|" nil 1 (- n))))

(defun kag-backward-savable-label (n)
  "n �Ĥ������Υ����ֲ�ǽ�ʥ�٥�ΰ��֤˰�ư���롣"
  (interactive "p")
  (kag-forward-savable-label (- n)))
	  

(defun kag-scan-tag (from count)
  "���� from ���������˸����� count �ĤΥ������������롣
�����򽪤������֤��֤��� count ����Ǥ���ȡ������ظ�����
�������롣
�����˼��Ԥ�����硢nil ���֤���"
  (save-excursion
    (goto-char from)
    (let ((i 0))
      (if (< 0 count)
	  (while (and (< i count) (not (eobp)))
	    (forward-char)
	    (if (kag-tag-tail-p)
		(setq i (1+ i))))
	(while (and (< count i) (not (bobp)))
	  (backward-char)
	  (if (kag-tag-head-p)
	      (setq i (1- i)))))
      (if (and (< 0 count) (not (eobp)))
	  (forward-char))
      (if (equal i count)
	  (point)
	nil))))


(defun kag-mark-tag (n)
  (interactive "p")
  (push-mark
    (save-excursion
      (kag-forward-tag n)
      (point))
    nil t))

(defun kag-forward-tag (n)
  "n �Ĥ�����Υ����ΰ��֤˰�ư���롣"
  (interactive "P")
  (setq n (prefix-numeric-value n))
  (goto-char (or (kag-scan-tag (point) n) (buffer-end n))))

(defun kag-backward-tag (n)
  "n �Ĥ������Υ����ΰ��֤˰�ư���롣"
  (interactive "P")
  (kag-forward-tag (- (prefix-numeric-value n))))

(defun kag-kill-tag (n)
  "�����������ˤ��� n �ĤΥ����򥭥뤹�롣"
  (interactive "p")
  (let ((orig-point (point)))
    (kag-forward-tag n)
    (kill-region orig-point (point))))

(defun kag-backward-kill-tag (n)
  "��������θ��ˤ��� n �ĤΥ����򥭥뤹�롣"
  (interactive "p")
  (kag-kill-tag (- n)))

(defun kag-comment-region (begin end)
  "���򤵤줿�ΰ�򥳥��ȥ����Ȥ��롣
���Τˤϡ��ΰ賫�ϤιԤ����ΰ轪λ�μ���ʸ��������ԤޤǤ�
�����ȥ����Ȥ���Τǡ��ΰ���⣱��¿�������ȥ����Ȥ�
��뤳�Ȥ�����ޤ���"
  (interactive "*r")
  (let ((lines (count-lines begin end))
	i)
    (save-excursion
      (if (progn
	    (goto-char end)
	    (bolp))
	  (setq lines (1+ lines))))
    (setq i 0)
    (save-excursion
      (goto-char begin)
      (while (< i lines)
	(beginning-of-line)
	(insert ";")
	(forward-line)
	(setq i (1+ i))))))


(defun kag-uncomment-region (begin end)
  "���򤵤줿�ΰ褬�����ȥ����Ȥ���Ƥ����顢�����Ȥ�Ϥ�����
�ΰ���Ф�����դϡ� `kag-comment-region' ��Ʊ���Ǥ���"
  (interactive "*r")
  (let ((lines (count-lines begin end)))
    (save-excursion
      (if (progn
	    (goto-char end)
	    (bolp))
	  (setq lines (1+ lines))))
    (setq i 0)
    (save-excursion
      (goto-char begin)
      (while (< i lines)
	(beginning-of-line)
	(while (equal (char-after) ?\;)
	  (delete-char 1))
	(forward-line)
	(setq i (1+ i))))))  


(defun kag-search-file-from-path (storage)
  "storage ��ѥ����鸡�������ե�ѥ����֤���
���Ĥ���ʤ���� nil ���֤���"
  (catch 'found
    (let ((storage-load-path kag-storage-load-path)
	  (project-dir (kag-get-project-dir))
	  dir)
      (while storage-load-path
	(let ((completable-extensions kag-completable-extensions))
	  (setq dir (concat project-dir (car storage-load-path)))
	  (unless (equal (substring dir -1 nil) "/")
	    (setq dir (concat dir "/")))
	  (setq file (concat dir storage))
	  (if (file-exists-p file)
	      (throw 'found (expand-file-name file)))

	  ;; ��ĥ���䴰
	  (while completable-extensions
	    (let* ((ext (car completable-extensions))
		   (file-with-ext (concat file ext)))
	      (if (file-exists-p file-with-ext)
		  (throw 'found (expand-file-name file-with-ext))))
	    (setq completable-extensions (cdr completable-extensions)))

	  (setq storage-load-path (cdr storage-load-path))))
      nil)))


(defun kag-follow-link-at-point ()
  "�ݥ���Ȥΰ��֤ˤ��륿���ΰ�ư��˰�ư���롣
ͭ���ʥ����� `kag-jumpable-tag-alist' �ˤ�ä��������롣"
  (interactive)
  (let ((tagstr (kag-get-tag-at-point))
	parsedtag attr-alist target storage tagname
	target-attr storage-attr
	to-check-attr)
    (if tagstr
	(progn
	  (setq parsedtag (kag-parse-tag tagstr))
	  (setq tagname (car parsedtag))
	  (setq to-check-attr (cdr (assoc-ignore-case tagname kag-jumpable-tag-alist)))
	  (if to-check-attr
	      (progn
		(setq attr-alist (cdr parsedtag))
		(setq target-attr (car to-check-attr))
		(setq storage-attr (car (cdr to-check-attr)))
		(setq target (cdr (assoc-ignore-case target-attr attr-alist)))
		(setq storage (cdr (assoc-ignore-case storage-attr attr-alist)))
		(cond ((equal tagname "rclick")
		       (if (and (null storage) (null target))
			   ;; �ѹ�̵���ʤΤ������ѹ������ͤϤ狼��ʤ�
			   (error "Don't know the value of storage and target.")
			   )
		       (if (string= storage "")
			   (setq storage nil))
		       (if (string= target "")
			   (setq target nil))
		       (kag-visit-link target storage)
		       )
		      ((equal tagname "return")
		       (if (and (null target) (null storage))
			   ;; �ƤӽФ����� call �����Τ�����
			   ;; ���ξ��Ϥ狼��ʤ���
			   (error "Can't determine the call point."))
		       (kag-visit-link target storage)
		       )
		      (t
		       (kag-visit-link target storage)
		       )))
	    (error "There is no valid link at point")))
      (error "There is no valid link at point."))))


(defun kag-visit-link (&optional label-name storage)
  "storage �ˤ��� label-name ��٥�ξ��򳫤���
label-name �� nil �ʤ�С��ե��������Ƭ����ꤷ����ΤȤߤʤ���
storage �� nil �ʤ�С������ȥե��������ꤷ����ΤȤߤʤ���"
  (let ((marker (point-marker)))
    (if storage
	(progn
	  (find-file (kag-search-file-from-path storage))
	  ))
    (let (label-pos)
      (if label-name
	  (save-excursion
	    (goto-char (point-min))
	    (if (re-search-forward (concat "^" label-name) nil t 1)
		(progn
		  (beginning-of-line)
		  (setq label-pos (point)))))
	(setq label-pos (point-min)))
      (if label-pos
	  (progn
	    (ring-insert kag-visit-link-marker-ring marker)
	    (goto-char label-pos))
	;; ��٥뤬�ʤ�
	(error "Label %s is not found." label-name)))))
	   

(defun kag-pop-link-mark ()
  "����kag-visit-link ��ƤӽФ�����������롣"
  (interactive)
  (if (ring-empty-p kag-visit-link-marker-ring)
	(error "kag-visit-link �ϼ¹Ԥ���Ƥ��ޤ���"))
  (let ((marker (ring-remove kag-visit-link-marker-ring 0)))
    (switch-to-buffer (or (marker-buffer marker)
			  (error "�ޡ������줿�Хåե��ϴ��˾õ��Ƥ��ޤ���")))
    (goto-char (marker-position marker))
    (set-marker marker nil nil)))

(defun kag-list-tag-pos-at-line ()
  "�ݥ���ȤΤ���ԤΥ����ΰ��֤Υꥹ�Ȥ��֤���
����ͤ� ((beg1 . end1) (beg2 . end2) ...) �η��Υꥹ�ȡ�
;(equal (char-after beg) ?\\[)
;(equal (char-after (1- end)) ?\\])
�Ǥ��롣
�������ʤ��ä��Ȥ��� nil ���֤���
�������Ĥ����ʤ��ޤ޹Ԥ���λ�����Ȥ��ϡ�
�Ǹ�Υ����� end ���ͤ� nil �ˤʤ롣
���ʤ�����Ǹ�����Ǥ� (begn . nil) �Ȥʤ롣
�����ˤϥ��ޥ�ɹԤ�ޤࡣ"
  (save-excursion
    (let ((begin (progn (beginning-of-line) (point)))
	  (end (progn (end-of-line) (point)))
	  tag-begin tag-end result i c
	  inside-of-tag-p inside-of-quote-p
	  quote-char
	  now-reading-name-p between-name-and-attr-p
	  now-reading-attr-p between-attr-and-value-p
	  now-reading-value-p between-attr-and-value-p
	  )
      (cond ((kag-command-line-p)
	     (list (cons begin end)))
	    ((kag-comment-line-p)
	     nil)
	    (t
	     (beginning-of-line)
	     (setq i (point))
	     (while (<= i end)
	       (goto-char i)
	       (setq c (char-after))
	       (if inside-of-tag-p
		   ;; ��������
		   (if inside-of-quote-p
		       ;; quote ����
		       (if (equal c quote-char)
			   (setq inside-of-quote-p nil))
		     ;; quote �γ�
		     (cond ((equal c ?\ )
			    (cond (now-reading-name-p
				   ;; ̾�����ɤ߽���ä�
				   (setq now-reading-name-p nil)
				   (setq between-name-and-attr-p t)
				   )
				  ;; (now-reading-attr-p
				  ;; (setq now-reading-attr-p nil)
				  ;; (setq between-attr-and-value-p t)
				  ;;  )
				  (now-reading-value-p
				   (setq now-reading-value-p nil)
				   (setq between-name-and-attr-p t)
				   )
				  (t
				   nil))
			    )
			   ((equal c ?=)
			    (when now-reading-attr-p
			      (setq now-reading-attr-p nil)
			      (setq between-attr-and-value-p t))
			    )
			   ((equal c ?\])
			    ;; ��������Ф�
			    (setq inside-of-tag-p nil)
			    (setq inside-of-quote-p nil)
			    (setq now-reading-name-p nil)
			    (setq now-reading-attr-p nil)
			    (setq now-reading-value-p nil)
			    (setq between-name-and-attr-p nil)
			    (setq between-attr-and-value-p nil)
			    (setq tag-end (1+ (point)))
			    (setq result (append result (list (cons tag-begin tag-end))))
			    (setq tag-begin nil)
			    (setq tag-end nil)
			    )
			   (t ;; ����¾��ʸ��
			    (cond (between-name-and-attr-p
				   (setq between-name-and-attr-p nil)
				   (setq now-reading-attr-p t)
				   )
				  (between-attr-and-value-p
				   (setq between-attr-and-value-p nil)
				   (setq now-reading-value-p t)
				   (if (or (equal c ?\")
					   (equal c ?\'))
				       (progn
					 (setq quote-char c)
					 (setq inside-of-quote-p t)))
				   ))))
		     )
		 ;; �����γ�
		 (if (equal c ?\[)
		     (if (equal (char-after (1+ (point))) ?\[)
			 (setq i (1+ i))
		       ;; �������������
		       (setq inside-of-tag-p t)
		       (setq now-reading-name-p t)
		       (setq tag-begin (point))))
		 )
	       (setq i (1+ i)))
	     (if (and tag-begin
		      (null tag-end))
		 (setq result (append result (list (cons tag-begin nil)))))
	     result)))))

  
  
(defun kag-get-tag-region-at-point ()
  "�ݥ���Ȥ����������ޥ�ɹԤ���¦�ˤ���ʤ�С����Υ����Υ꡼�������֤���
����ͤϡ�(beg . end) �η��Υ��󥹥��롣
�ݥ���Ȥ����������ޥ�ɹԤ���¦�ˤʤ���С� nil ���֤���"
  (interactive)
  (catch 'found
    (save-excursion
      (let (begin end)
	(beginning-of-line)
	(setq begin (point))
	(if (equal (char-after) ?@)
	    (progn
	      (end-of-line)
	      (setq end (point))
	      (throw 'found (cons begin end))))))
    (let (tagposlist tagpos result)
      (setq tagposlist (kag-list-tag-pos-at-line))
      (while tagposlist
	(setq tagpos (car tagposlist))
	(if (and (<= (car tagpos) (point))
		 (< (point) (cdr tagpos)))
	    (throw 'found tagpos))
	(setq tagposlist (cdr tagposlist))))))


(defun kag-get-tag-at-point ()
  "�ݥ���ȤΤ����꤬�ޤޤ�륿���⤷���ϥ��ޥ�ɹԤ�ʸ������֤���
�ݥ���Ȥξ�꤬�����˴ޤޤ�ʤ����� nil ���֤���"
  (interactive)
  (let ((tagpos (kag-get-tag-region-at-point)))
    (if tagpos
	(buffer-substring-no-properties (car tagpos) (cdr tagpos))
      nil)))
		 
(defun kag-get-tag-name-at-point ()
  "�ݥ���ȤΤ����꤬�ޤޤ�륿���ޤ��ϥ��ޥ�ɹԤ�̾�����֤���
�����ϡ�������λ�� ] ���ʤ��Ƥ�褤��
�ݥ���Ȥ������ޤ��ϥ��ޥ�ɹԤ���¦�ˤʤ��Ȥ��� nil ���֤���"
  (interactive)
  (if (kag-inside-of-tag-p)
      (save-excursion
	(while (and (not (kag-tag-head-p))
		    (not (bolp)))
	  (backward-char))
	(save-match-data
	  (if (re-search-forward kag-tag-name-regexp nil t 1)
	      (match-string-no-properties 0)
	    "")))
    nil))


(defun kag-parse-tag (tagstr)
  "Ϳ����줿������ʬ�򤹤롣
tagstr �ϡ� \"[tagname key1=value1 ... ]\" �η�����
\"@tagname key1=val1 ... \" �η���ʸ����
����ͤ� (tagname (key1 . value1) (key2 . value2) ... ) �η��Υꥹ�ȡ�"
  (let (result element command-line-flag)
    (cond ((string-match "^@\\(.*\\)" tagstr)
	   (setq command-line-flag t)
	   (setq tagstr (match-string 1 tagstr))
	   )
	  ((string-match "\\[\\(.*\\)]" tagstr)
	   (setq tagstr (match-string 1 tagstr))
	   ))

    (string-match kag-tag-name-regexp tagstr)
    (setq result (list (match-string 0 tagstr)))
    (setq tagstr (substring tagstr (match-end 0)))
    (while (cond ((string-match "^[ \t]*\\(\\w+\\)\\([ \t]*$\\|[ \t]+\\w\\)" tagstr)
		  (setq element (cons (match-string 1 tagstr) nil))
		  t)
		 ((string-match "^[ \t]*\\(\\w+\\)[ \t]*=[ \t]*\"\\([^\r\n\"]*\\)\"" tagstr)
		  (setq element (cons (match-string 1 tagstr) (match-string 2 tagstr)))
		  t)
		 ((string-match "^[ \t]*\\(\\w+\\)[ \t]*=[ \t]*'\\([^\r\n']*\\)'" tagstr)
		  (setq element (cons (match-string 1 tagstr) (match-string 2 tagstr)))
		  t)
		 ((and command-line-flag (string-match "^[ \t]*\\(\\w+\\)[ \t]*=[ \t]*\\([^ \t\r\n]+\\)" tagstr))
		  (setq element (cons (match-string 1 tagstr) (match-string 2 tagstr)))
		  t)
		 ((and (not command-line-flag) (string-match "^[ \t]*\\(\\w+\\)[ \t]*=[ \t]*\\([^] \t\r\n]+\\)" tagstr))
		  (setq element (cons (match-string 1 tagstr) (match-string 2 tagstr)))
		  t)
		 (t nil))
      (setq tagstr (substring tagstr (match-end 0)))
      (setq result (append result (list element)))
      )
    result))

(defun kag-inside-of-tag-p ()
  "�ݥ���ȤΤ����꤬����������¦�Ǥ��뤫�ɤ�����
�����ˤϥ��ޥ�ɹԤ�ޤࡣ"
  (or (kag-command-line-p)
      (and (not (kag-comment-line-p))
	   (progn
	     (save-excursion
	       (let ((check-point (point))
		     c i tag-begin tag-end
		     inside-of-tag-p inside-of-quote-p
		     quote-char between-attr-and-value-p now-reading-value-p)
		 (beginning-of-line)
		 (setq i (point))
		 (while (<= i check-point)
		   (goto-char i)
		   (setq c (char-after))
		   (if inside-of-tag-p
		       ;; ��������
		       (if inside-of-quote-p
			   ;; quote ����
			   (if (equal c quote-char)
			       (progn
				 (setq inside-of-quote-p nil)
				 ))
			 ;; quote �γ�
			 (cond ((equal c ?\ )
				(if now-reading-value-p
				    (progn
				      (setq now-reading-value-p nil)
				      ))
				)
			       ((equal c ?=)
				(if (not now-reading-value-p)
				    (setq between-attr-and-value-p t))
				)
			       ((equal c ?\])
				;; ��������Ф�
				(setq inside-of-tag-p nil)
				(setq inside-of-quote-p nil)
				(setq tag-end (point))
				)
			       (t
				(if between-attr-and-value-p ;; attr= ���ɤ�ǰʹߡ����ڡ��������ɤ�Ǥʤ�
				    (progn
				      (if (or (equal c ?\")
					      (equal c ?\'))
					  (progn
					    (setq quote-char c)
					    (setq inside-of-quote-p t)))
				      (setq between-attr-and-value-p nil)
				      (setq now-reading-value-p t)))
				))
			 )
		     ;; �����γ�
		     (if (equal c ?\[)
			 (if (equal (char-after (1+ (point))) ?\[)
			     (setq i (1+ i))
			   (setq inside-of-tag-p t)
			   (setq tag-begin (point))))
		     )
		   (setq i (1+ i)))
		 (if inside-of-tag-p
		     (if (and (equal tag-begin check-point)
			      (equal (char-after (1+ check-point)) ?\[))
			 nil
		       t)
		   (if (equal tag-end check-point)
		       t
		     nil))))))))


(defun kag-comment-line-p ()
  "�ݥ���ȤΤ���Ԥ������ȹԤǤ��뤫�ɤ�����"
  (save-excursion
    (beginning-of-line)
    (equal (char-after) ?\;)))

(defun kag-command-line-p ()
  "�ݥ���ȤΤ���Ԥ����ޥ�ɹԤǤ��뤫�ɤ�����"
  (save-excursion
    (beginning-of-line)
    (equal (char-after) ?@)))



(defun kag-match-tag-attribute-tag-only (last)
  (if (re-search-forward "\\(\\w+\\)[ \t]*=[ \t]*\\([^]'\" \t\r\n][^] \t\r\n]*\\|\"[^\"\r\n]*\"\\|'[^'\r\n]*'\\)" last t 1)
      (let ((inside-of-tag-p (save-excursion
			       (goto-char (match-beginning 0))
			       (kag-inside-of-tag-p))))
	(if (not inside-of-tag-p)
	    (progn
	      (goto-char (match-beginning 2))
	      (set-match-data nil))
	  )
	t)
    nil))

  
(defun kag-tag-head-p ()
  "�ݥ���Ȥ�ʸ������������Ƭ�Ǥ��뤫�ɤ�����"
  (if (kag-command-line-p)
      (bolp)
    (not (null (member (point) (mapcar 'car (kag-list-tag-pos-at-line)))))))

(defun kag-tag-tail-p ()
  "�ݥ���Ȥ�ʸ���������������Ǥ��뤫�ɤ�����"
  (if (kag-command-line-p)
      (eolp)
    (not (null (member (1+ (point)) (mapcar 'cdr (kag-list-tag-pos-at-line)))))))

  
(defun kag-match-tag (last)
  (if (search-forward "[" last t 1)
      (let (tag-whole-match-data
	    tag-open-match-data
	    tag-name-match-data
	    tag-close-match-data
	    match-data search-ket-p
	    (line-end (save-excursion (progn (end-of-line) (point))))
	    )
	(if (save-excursion
	      (backward-char)
	      (kag-tag-head-p))
	    (progn
	      (setq tag-open-match-data (list (1- (point)) (point)))
	      (if (re-search-forward kag-tag-name-regexp (min line-end last) t 1)
		  (progn
		    (setq tag-name-match-data (list (match-beginning 0) (match-end 0)))
		    (setq search-ket-p t)
		    (while search-ket-p
		      (if (search-forward "]" (min line-end last) t 1)
			  (if (save-excursion
				(backward-char)
				(kag-tag-tail-p))
			      (progn
				(setq search-ket-p nil)
				(setq tag-close-match-data (list (1- (point)) (point)))
				))
			(setq search-ket-p nil)))))))
	(setq tag-whole-match-data (if tag-close-match-data
				       (list (car tag-open-match-data) (car (cdr tag-close-match-data)))
				     (list (car tag-open-match-data) (min line-end last))))
	(set-match-data (append tag-whole-match-data
				tag-name-match-data
				tag-open-match-data
				tag-close-match-data))
	t)
    nil))

(defun match-excessive-space (last)
  "�����ȹԤ��뤤�ϥ��ޥ�ɹ԰ʳ��ι����Υ��ڡ����˥ޥå����롣"
  (if (re-search-forward "[ ��]+$" last t 1)
      (progn
	(if (or (kag-comment-line-p)
		(kag-command-line-p))
	    (set-match-data nil))
	t)
    nil))


(cond ((featurep 'font-lock)

       (defconst kag-font-lock-keywords-1 nil
	 "Subdued level highlighting for KAG modes.")

       (defconst kag-font-lock-keywords-2 nil
	 "Medium level highlighting for KAG modes.")

       (defconst kag-font-lock-keywords-3 nil
	 "Gaudy level highlighting for KAG modes.")


       (let ((match-command-line (concat "^\\(@\\)[ \t]*\\(" kag-tag-name-regexp "\\)")))
	 (setq kag-font-lock-keywords-1
	       (list
		;; ������
		'("^;.*$" (0 kag-comment-face t t))

		;; ��٥�
		'("^\\(\\*[^\r\n|]+\\)\\(|.*\\)?$"
		  (1 kag-label-face nil t))

		;; ���ޥ�ɹ�
		(list match-command-line
		      '(1 kag-tag-delimiter-face nil t)
		      '(2 kag-tag-name-face)
		      '("\\(\\w+[ \t]*=\\)[ \t]*\\([^'\" \t\r\n][^ \t\r\n]*\\|\"[^\"\r\n]*\"\\|'[^'\r\n]*'\\)"
			nil nil
			(1 kag-tag-attribute-face nil t)
			(2 kag-tag-value-face nil t)))

		;; ����	 
		'(kag-match-tag
		  (1 kag-tag-delimiter-face nil t)
		  (2 kag-tag-name-face nil t)
		  (3 kag-tag-delimiter-face nil t))
	  
		'(kag-match-tag-attribute-tag-only
		  (1 kag-tag-attribute-face nil t)
		  (2 kag-tag-value-face nil t))

		)))



       (setq kag-font-lock-keywords-2
	     (append kag-font-lock-keywords-1
		     (list
		      ;; �����Υ��ڡ���
		      '(match-excessive-space . (0 kag-excessive-space-face nil t))

		      ;; ���ѥ��ڡ���
		      '("��" . (0 kag-zenkaku-space-face t t))
		      )))

       (setq kag-font-lock-keywords-3
	     (append kag-font-lock-keywords-2
		     nil))

       (defvar kag-font-lock-keywords kag-font-lock-keywords-1
	 "Default expressions to highlight in KAG mode.")



       (add-hook 'kag-mode-hook
		 '(lambda ()
		    (make-local-variable 'font-lock-defaults)
		    (setq font-lock-defaults '((kag-font-lock-keywords
						kag-font-lock-keywords-1
						kag-font-lock-keywords-2
						kag-font-lock-keywords-3)
					       nil nil))
		    ))
       ))

(defun kag-mode ()
  "Major mode for editing KAG scripts.

\\{kag-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (text-mode)
  (setq major-mode 'kag-mode)
  (setq mode-name "KAG")
  (set-syntax-table kag-mode-syntax-table)

  (use-local-map kag-mode-map)
  (run-hooks 'kag-mode-hook))

	    
(provide 'kag-mode)

;;; kag-mode.el ends here
