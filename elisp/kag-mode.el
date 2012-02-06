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
;;== ひとこと紹介
;;KAG のシナリオを扱うための Emacsen 用メジャーモードです。
;;
;;== 目次
;;* ((<動作画面>))
;;* ((<概要>))
;;* ((<ダウンロード>))
;;* ((<ライセンス>))
;;* ((<インストール>))
;;* ((<font-lock による色付け>))
;;* ((<シナリオ実行>))
;;* ((<タグ入力支援>))
;;* ((<タグリファレンス検索>))
;;* ((<引数一覧表示>))
;;* ((<画像などの表示について>))
;;* ((<移動について>))
;;* ((<その他>))
;;* ((<References>))
;;
;;== 動作画面
;;<<< doc/snapshot_includee
;;
;;== 概要
;;KAG のシナリオを扱うための Emacsen 用メジャーモードです。
;;
;;次のような機能があります。
;;
;;* font-lock による色付け
;;* タグの入力支援
;;* ラベルやタグ単位での移動、リンク先への移動など
;;* タグリファレンス検索、引数一覧の表示
;;
;;
;;== ダウンロード
;;* ((<kag-mode.el|URL:kag-mode.el>))
;;
;;
;;== ライセンス
;;このプログラムは ((<MIT ライセンス|URL:http://www.opensource.org/licenses/mit-license.php>))
;;の元で配布されます。
;;
;;
;;== インストール
;;.emacs (あるいは別の初期設定ファイル)に、
;;  (autoload 'kag-mode "kag-mode" "Major mode for editing KAG scripts" t)
;;と書いて下さい。
;;
;;拡張子 .ks のファイルを常に kag-mode で扱いたい場合は、
;;  (setq auto-mode-alist (append '(( "\\.ks$" . kag-mode)) auto-mode-alist))
;;も追加して下さい。
;;
;;((<タグリファレンス検索>))を行いたい場合は、
;;((<texinfo 版 KAG タグリファレンス|URL:http://shakenbu.org/yanagi/kag-texinfo/>))
;;もインストールしてください。
;;
;;
;;== font-lock による色付け
;;タグ・コマンド行・コメント・ラベルのほか、
;;全角スペースと行末のスペースを色付けします。
;;色付けが気にいらないときは、kag-*-face あたりをいじってください。
;;
;;
;;== シナリオ実行
;;現在開いているシナリオ(が含まれるプロジェクト)を吉里吉里で
;;実行することができます。
;;
;;まず、kag-kirikiri-command に、吉里吉里実行ファイルのパスを設定します。
;;  (setq kag-kirikiri-command "c:/foo/bar/krkr.eXe")
;;
;;あとは、C-c C-z e で現在のプロジェクトを実行できます。
;;
;;
;;== タグ入力支援
;;kag-insertion-prefix に続いて1字を入力すると、タグ入力支援となります。
;;kag-insertion-prefix は、デフォルトでは C-c C-t です。
;;
;;例えば、C-c C-t e を入力すると、eval タグを挿入することができます。
;;このとき、kag-use-prompt-when-insertion-p が non-nil ならば、
;;属性の値を尋ねてきます。必須でない属性は、何も入力しない
;;(空のままリターンを押す)ことでスキップできます。
;;
;;コマンドによっては、一つのタグではなく、タグのペアを挿入できます。   
;;例えば C-c C-t i を入力すると、if/endif タグのペアを挿入することができます。
;;このようにペアのタグを入力するコマンドは、C-u C-c C-t i のように
;;前置引数を与えて起動すると、リージョンをタグのペアで囲むことができます。
;;
;;call, jump, link, return タグは、storage 属性と target 属性で、補完がききます。
;;
;;
;;
;;== タグリファレンス検索
;;Emacsen 上から KAG のタグリファレンスを検索することができます。
;;
;;((<texinfo 版 KAG タグリファレンス|URL:http://shakenbu.org/yanagi/kag-texinfo/>))
;;をダウンロードし、インストールしてください。
;;
;;kag-display-tag-reference (M-?)で、タグのリファレンスを見ることができます。
;;ポイントがタグの上にあった場合、デフォルトはそのタグとなります。
;;
;;
;;== 引数一覧表示
;;* C-c C-z h で、タグの引数一覧を見ることができます。
;;* C-c C-z SPC で、現在ポイントがある位置のタグの引数一覧を見ることができます。
;;
;;
;;== 画像などの表示について
;;タグで読み込まれる画像・音声・映像などを表示することができます。
;;c:/foo/bar/viewer.exe で画像を表示したいとすると、.emacs で
;;  (setq kag-external-viewer-list '(("c:/foo/bar/viewer.exe")))
;;と設定しておきます。
;;
;;あとは、タグの属性の値のところで、kag-show-object-at-point (C-c C-z v) 
;;を実行すれば、そのファイルを見ることができます。
;;
;;ビューアは複数設定することができます。
;;複数設定するときは、
;;  (setq kag-external-viewer-list '(("c:/foo/bar/viewer.exe")
;;                                   ("c:/hoge/fuga/viewer2.exe")))
;;のように設定します。
;;kag-show-object-at-point を実行するときに、前置引数として2を与えれば、
;;(C-u 2 を頭につけて実行すれば) 2番目のビューアで見ることができます。
;;(前置引数を与えなかった場合、リストの最初のビューアが使われます。)
;;
;;ビューアにコマンドラインオプションを設定したいときは、
;;("c:/foo/bar/viewer.exe") の部分を ("c:/foo/bar/viewer.exe" "-a" "-b")
;;のように設定します。
;;
;;storage="foo" のように、属性の値に拡張子が指定されていなければ
;;適宜補完しますが、KAG が実際に行う補完とは少し違うので、ご注意ください。
;;(KAG が補完する際には、どのタグであるかなどを考慮して補完しますが、
;;ここではそこまでは考慮していません)
;;
;;
;;== 移動について
;;* M-C-p で前のラベルに移動できます。
;;* M-C-n で次のラベルに移動できます。
;;* M-C-a で前のセーブ可能なラベルに移動できます。
;;* M-C-e で次のセーブ可能なラベルに移動できます。
;;* M-C-b で前のタグに移動できます。
;;* M-C-f で次のタグに移動できます。
;;
;;(ここでの前・次とは、シナリオの流れを解釈したものではありません)
;;
;;ジャンプ可能なタグの上で M-RET でジャンプ先に移動できます。
;;ジャンプしたら、M-* で戻ってこれます。
;;
;;
;;== その他
;;その他のコマンドについては、describe-mode (C-h m) で表示される
;;キーマップ一覧をご覧ください。
;;
;;
;;== References
;;* ((<kikyou.info|URL:http://kikyou.info/>))
;;* ((<吉里吉里／ＫＡＧ推進委員会|URL:http://www.piass.com/kpc/>))
;;* ((<texinfo 版 KAG タグリファレンス|URL:http://shakenbu.org/yanagi/kag-texinfo/>))
;;* ((<outline-minor-mode のすすめ|URL:http://shakenbu.org/yanagi/outline-minor-mode/>))
;;* ((<Emacs Lisp によるプログラミング - 初心者のための入門|URL:http://www.namazu.org/~tsuchiya/doc/emacs-lisp-intro-jp-95.tar.gz>))
;;* ((<GNU Emacs Lisp リファレンス・マニュアル|URL:ftp://ftp.ascii.co.jp/pub/GNU/elisp-manual-20/elisp-manual-20-2.5-jp.tgz>))
;;* ((<Emacs How To - 深緑なコメント|URL:http://www.fides.dti.ne.jp/~oka-t/emacs.html#font-lock>))
;;* ((<mode-info|URL:http://www.namazu.org/~tsuchiya/elisp/mode-info.html>))
;;
;;== 履歴
;;* [2004/02/14] コメントの修正。バージョン番号を付けてなかったので 1.0.0 にする。
;;* [2003/12/17] KAG 3.20 用に kag-tag-arg-doc-alist を更新。
;;* [2002/12/31] 公開
;;
;;<<< doc/footer_includee
;;=end
;;

;;; Code:
(require 'cl)

(defconst kag-mode-version "1.0.0")

(defvar kag-mode-hook nil
  "kag-mode に入ったときに呼ばれる関数のリスト")

(defvar kag-insertion-prefix "\C-c\C-t"
  "タグ挿入のためのコマンド用 prefix")

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
  "kag-mode のコマンド用 prefix")

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
  "kag-mode 用キーマップ")

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
  "KAG のタグの区切りの `[', `]', `@' に使われるフェイスの値。")

(defvar kag-tag-name-face
  font-lock-function-name-face
  "KAG のタグの名前の部分に使われるフェイスの値。")

(defvar kag-tag-attribute-face
  font-lock-variable-name-face
  "KAG のタグの属性の部分に使われるフェイスの値。")

(defvar kag-tag-value-face
  font-lock-string-face
  "KAG のタグの属性の値の部分に使われるフェイスの値。")

(defvar kag-comment-face
  font-lock-comment-face
  "KAG のコメントに使われるフェイスの値。")

(defvar kag-label-face
  font-lock-constant-face
  "KAG のラベルに使われるフェイスの値。")

(defface kag-zenkaku-space-face
  '((t (:background "gray")))
  "全角スペースを表示するのに使われるフェイス。")
(defvar kag-zenkaku-space-face
  'kag-zenkaku-space-face
  "全角スペースを表示するのに使われるフェイスの値。")

(defface kag-excessive-space-face
  '((t (:background "gray")))
  "行末の直前のスペースを表示するのに使われるフェイス。")
(defvar kag-excessive-space-face
  'kag-excessive-space-face
  "行末の直前のスペースを表示するのに使われるフェイスの値。")

(defvar kag-mode-syntax-table nil
  "kag-mode で使われる構文テーブル。")

(defvar kag-kirikiri-command nil
  "吉里吉里の実行ファイルのパス")

(defvar kag-external-viewer-list ()
  "画像ファイルなどを見るときに使う外部アプリケーションのリスト。
リストの各要素は、 (viewer-path opt1 opt2 ...) のようなリスト。")

(defvar kag-relative-path-to-project-dir "../"
  "シナリオのあるディレクトリの中から見た、プロジェクトディレクトリの相対パス。")

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
  "KAG のファイル検索パス。プロジェクトディレクトリからの相対パスで指定する。
リストの最初の方にあるものほど優先される。")

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
  "ファイルを検索する際に補完可能な拡張子。kag-search-file-from-path が使う。
リストの最初の方にあるものほど優先される。")

(defvar kag-tag-name-regexp "\\w+"
  "KAG のタグの名前を表す正規表現。")

(defvar kag-scenario-filename-regexp "\\.ks$"
  "KAG のシナリオファイルの名前を表す正規表現")

(defvar kag-jumpable-tag-alist
  '(("button" . ("target" "storage"))
    ("call" . ("target" "storage"))
    ("jump" . ("target" "storage"))
    ("link" . ("target" "storage"))
    ("rclick" . ("target" "storage"))
    ("return" . ("target" "storage")))
  "ジャンプ可能なタグのリスト。
リストの各要素は、 ( tagname . (target-attr storage-attr) ) 
の要素からなるリスト。")

(defvar kag-use-prompt-when-insertion-p t
  "インサート時にプロンプトを使うかどうか。")

(defvar kag-visit-link-marker-ring-length 16
  "kag-visit-link が呼ばれた時のマーカを記録するためのリングの長さ。")

(defvar kag-visit-link-marker-ring (make-ring kag-visit-link-marker-ring-length)
  "kag-visit-link が呼ばれた時のマーカを記録するためのリング。")

(defvar kag-tag-reference-node-name "(kag-tag)Tag Reference"
  "KAG タグリファレンスの info のノード名")

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
  "KAG のタグの引数一覧の alist")

(if kag-mode-syntax-table
    nil
  (setq kag-mode-syntax-table (make-syntax-table text-mode-syntax-table))
  (modify-syntax-entry ?_ "w   " kag-mode-syntax-table)
  (modify-syntax-entry ?- "w   " kag-mode-syntax-table))


(eval-and-compile
  (autoload 'Info-goto-node "info")
  (autoload 'Info-mode "info"))

(defun kag-display-tag-reference ()
  "タグのリファレンスを表示する。"
  (interactive)
  (kag-display-tag-reference-noselect (completing-read "Tag: "
						       kag-tag-arg-doc-alist
						       nil
						       nil
						       (kag-get-tag-name-at-point))))

(defun kag-display-tag-reference-noselect (tagname)
  "引数で指定されたタグのリファレンスを表示する。"
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
  "KAG のタグの引数一覧をミニバッファに表示する。"
  (interactive "sTag name: ")
  (let ((argstr))
    (setq argstr (cdr (assoc-ignore-case tagname kag-tag-arg-doc-alist)))
    (cond ((null argstr)
	   (setq argstr "Unknown tag."))
	  ((equal argstr "")
	   (setq argstr "No arguments.")))
    (message "[%s]: %s" tagname argstr)))


(defun kag-display-current-tag-arg-list-to-minibuffer ()
  "ポイントの位置にあるタグの引数一覧をミニバッファに表示する。"
  (interactive)
  (let ((tagname (kag-get-tag-name-at-point)))
    (if tagname
	(kag-display-tag-arg-list-to-minibuffer tagname)
      (error "%s" "There is no tag at point."))))


(defun kag-get-project-dir ()
  "現在開いているシナリオのプロジェクトディレクトリのフルパスを返す。
バッファがファイルに関連付けられていないときは nil を返す。"
  (save-match-data
    (if (and (buffer-file-name) (string-match "\\(.*/\\)[^/]*" (buffer-file-name)))
	(expand-file-name (concat (match-string 1 (buffer-file-name))
				  kag-relative-path-to-project-dir))
      nil)))

(defun kag-execute-current-script ()
  "カレントバッファが含まれるプロジェクトを吉里吉里で実行する。"
  (interactive)
  (let ((project-dir (kag-get-project-dir)))
    (if project-dir
	(call-process kag-kirikiri-command nil 0 nil project-dir)
      (error "%s" "This buffer is not bound to file."))))


(defun kag-get-attr-value-at-point ()
  "カーソルがタグの属性の上にあるとき、その値を返す。
タグの属性の上にないときは nil を返す。
もし属性の値が \" か ' で囲んであるときは、 その \" または ' は取り除かれた
文字列が返される。"
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
  "ポイントの位置の画像・音声・映像ファイルなどを表示する。
前置引数によって、どの外部ビューアを使って表示するかを決める。

前置引数なしの場合は`kag-external-viewer-list'の先頭のビューアで、
前置引数が 2 のときは`kag-external-viewer-list'の2番目に指定されている
ビューアで、のようにして表示される。"
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
  "r タグを挿入し、同時に改行する。"
  (interactive "*P")
  (if (< 0 (prefix-numeric-value n))
      (let ((i 0))
	(while (< i (prefix-numeric-value n))
	  (insert "[r]")
	  (newline)
	  (setq i (1+ i))))))



(defun kag-insert-tag-template (begin-tag-name end-tag-name attr-list value-list begin-tag-only)
  "この関数は、与えられたタグの名前と属性からタグを構築し、
カレントバッファにそのタグを挿入する。

例えば if タグと endif タグのように、ペアで使われるタグを
挿入できるように、 タグのペアを指定できるようになっている。

begin-tag-name は、開始タグの名前である。
上の例だと、if タグに相当する。

end-tag-name は、終了タグの名前である。
上の例だと、endif タグに相当する。

attr-list は、begin-tag-name で指定されたタグの属性一覧を
表すリストである。
リストの各要素は、属性の名前と、その属性が必須であるかどうか
の真偽値からなるコンスセルである。
例えば、必須属性 foo と、必須でない属性 bar を入力させたいときは、
 '( (\"foo\" . t) (\"bar\" . nil) ) を与える。
必須でない属性は、ユーザが空文字を入力することによって、
挿入しないようにすることができる。

value-list は、属性の値の一覧を表わすリストである。
 (length attr-list) と (length value-list) の値が等しいときは、
value-list の値を使ってタグが構築される。
そうでないときは、value-list の内容は無視され、属性の値の入力を
ユーザに求める。

begin-tag-only が non-nil ならば、開始タグのみを挿入する。"
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
  "ユーザから、タグの属性の入力を得る。
attrs は ((\"foo\" . t) (\"bar\" . nil))のようなリスト。
各要素は、属性の名前と、その属性が必須であるかどうかの真偽値からなるコンスセル。
戻り値は (cons ((\"foo\" . t) (\"bar\" . nil)) (\"foo_value\" \"bar_value\"))
のようなコンスセル。
kag-insert-tag-template の attr-list に戻り値のコンスセルの car を、
value-list に戻り値のコンスセルの cdr を渡すことを意図している。

必須でないタグの入力が省略されたときは、戻り値からはその属性は省かれている。
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
  "領域を begin-tag-name/end-tag-name タグで囲む。
attr-list および value-list は、begin-tag のために使われる。
詳しい意味は、`kag-insert-tag-template' を参照。"
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
  "hact タグと endhact タグのペアを挿入する。
前置引数を与えて呼び出すと、リージョンを hact/endhact タグで囲む。"
  (interactive "*P")
  (if surround-region-p
      (kag-insert-tag-template-surround-region "hact" "endhact" '(("exp" . t)) (if exp (list exp) nil))
    (kag-insert-tag-template "hact" "endhact" '(("exp" . t)) (if exp (list exp) nil) nil)))

(defun kag-insert-tag-hch (&optional text)
  (interactive "*")
  (kag-insert-tag-template "hch" nil '(("text" . t)) (if text (list text) nil) t))

(defun kag-insert-tag-if (&optional surround-region-p exp)
  "if タグと endif タグのペアを挿入する。
前置引数を与えて呼び出すと、リージョンを if/endif タグで囲む。"
  (interactive "*P")
  (if surround-region-p
      (kag-insert-tag-template-surround-region "if" "endif" '(("exp" . t)) (if exp (list exp) nil))
    (kag-insert-tag-template "if" "endif" '(("exp" . t)) (if exp (list exp) nil) nil)))

(defun kag-insert-tag-ignore (&optional surround-region-p exp)
  "ignore タグと endignore タグのペアを挿入する。
前置引数を与えて呼び出すと、リージョンを ignore/endignore タグで囲む。"
  (interactive "*P")
  (if surround-region-p
      (kag-insert-tag-template-surround-region "ignore" "endignore" '(("exp" . t)) (if exp (list exp) nil))
    (kag-insert-tag-template "ignore" "endignore" '(("exp" . t)) (if exp (list exp) nil) nil)))

(defun kag-insert-tag-indent (&optional surround-region-p)
  "indent タグと endindent タグのペアを挿入する。
前置引数を与えて呼び出すと、リージョンを indent/endindent タグで囲む。"
  (interactive "*P")
  (if surround-region-p
      (kag-insert-tag-template-surround-region "indent" "endindent" nil nil)
    (kag-insert-tag-template "indent" "endindent" nil nil nil)))

(defun kag-insert-tag-macro (&optional surround-region-p name)
  "macro タグと endmacro タグのペアを挿入する。
前置引数を与えて呼び出すと、リージョンを macro/endmacro タグで囲む。"
  (interactive "*P")
  (if surround-region-p
      (kag-insert-tag-template-surround-region "macro" "endmacro" '(("name" . t)) (if name (list name) nil))
    (kag-insert-tag-template "macro" "endmacro" '(("name" . t))  (if name (list name) nil) nil)))

(defun kag-insert-tag-nowait (&optional surround-region-p)
  "nowait タグと endnowait タグのペアを挿入する。
前置引数を与えて呼び出すと、リージョンを nowait/endnowait タグで囲む。"
  (interactive "*P")
  (if surround-region-p
      (kag-insert-tag-template-surround-region "nowait" "endnowait" nil nil)
    (kag-insert-tag-template "nowait" "endnowait" nil nil nil)))

(defun kag-insert-tag-iscript (&optional surround-region-p)
  "iscript タグと endscript タグのペアを挿入する。
前置引数を与えて呼び出すと、リージョンを iscript/endscript タグで囲む。"
  (interactive "*P")
  (if surround-region-p
      (kag-insert-tag-template-surround-region "iscript" "endscript" nil nil)
    (kag-insert-tag-template "iscript" "endscript" nil nil nil)))

(defun kag-insert-tag-jump ()
  "jump タグを挿入する。"
  (interactive "*")
  (kag-insert-tag-template "jump" nil '(("storage" . nil) ("target" . nil)) nil t))

(defun kag-insert-tag-call ()
  "call タグを挿入する。"
  (interactive "*")
  (kag-insert-tag-template "call" nil '(("storage" . nil) ("target" . nil)) nil t))

(defun kag-insert-tag-return ()
  "return タグを挿入する。"
  (interactive "*")
  (kag-insert-tag-template "return" nil '(("storage" . nil) ("target" . nil)) nil t))

(defun kag-read-storage-target-with-completion (tagname)
  "storage 属性と target 属性の入力を補完つきで得る。
戻り値は、(cons '((\"storage\" . nil) (\"target\" . nil)) '(storage-value target-value))
のようなコンスセル。ただし、入力が省略された部分は削られる。
`kag-insert-tag-template' の引数として渡されることを意図している。"
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
  "jump タグを挿入する。
storage と target の入力には補完が使える。"
  (interactive "*")
  (let (attr-value)
    (setq attr-value (kag-read-storage-target-with-completion "jump"))
    (kag-insert-tag-template "jump" nil (car attr-value) (cdr attr-value) t))
  )
(defun kag-insert-tag-call-with-completion ()
  "call タグを挿入する。
storage と target の入力には補完が使える。"
  (interactive "*")
  (let (attr-value)
    (setq attr-value (kag-read-storage-target-with-completion "call"))
    (kag-insert-tag-template "call" nil (car attr-value) (cdr attr-value) t))
  )
(defun kag-insert-tag-return-with-completion ()
  "return タグを挿入する。
storage と target の入力には補完が使える。"
  (interactive "*")
  (let (attr-value)
    (setq attr-value (kag-read-storage-target-with-completion "return"))
    (kag-insert-tag-template "return" nil (car attr-value) (cdr attr-value) t))
  )



(defun kag-insert-tag-link (&optional surround-region-p)
  "link タグと endlink タグのペアを挿入する。
前置引数を与えて呼び出すと、リージョンを link/endlink タグで囲む。"
  (interactive "*P")
  (let (attr-value)
    (setq attr-value (kag-read-storage-target-with-completion "link"))
    (if surround-region-p
	(kag-insert-tag-template-surround-region "link" "endlink" (car attr-value) (cdr attr-value))
      (kag-insert-tag-template "link" "endlink" (car attr-value) (cdr attr-value) nil))))


(defun kag-insert-tag-eval (&optional exp)
  "eval タグを挿入する。"
  (interactive "*")
  (kag-insert-tag-template "eval" nil '(("exp" . t)) (if exp (list exp) nil) t))

(defun kag-insert-tag-quake (&optional surround-region-p time)
  "quake タグと wq タグのペアを挿入する。
前置引数を与えて呼び出すと、リージョンを quake/wq タグで囲む。"
  (interactive "*P")
  (setq time (if time (list time) nil))
  (if surround-region-p
      (kag-insert-tag-template-surround-region "quake" "wq" '(("time" . t)) time)
    (kag-insert-tag-template "quake" "wq" '(("time" . t)) time nil)))

(defun kag-insert-tag-wait (&optional time)
  "wait タグを挿入する。"
  (interactive "*")
  (kag-insert-tag-template "wait" nil '(("time" . t)) (if time (list time) nil) t))

(defun kag-insert-tag-ruby (&optional text)
  "ruby タグを挿入する。"
  (interactive "*")
  (kag-insert-tag-template "ruby" nil '(("text" . t)) (if text (list text) nil) t))

(defun kag-insert-text-with-ruby (&optional text ruby)
  "文字をルビとともに挿入する。
body と ruby はともに、最初の文字はルビの振り方の区切りを
表す区切り文字でないといけない。
例えば、\"/日本/語\" のように指定する。
この区切り文字は、1文字であれば何でもよい。

例:
body に \"/日/本/語\"、ruby に \"/に/ほん/ご\" を指定すると、
  [ruby text=\"に\"]日[ruby text=\"ほん\"]本[ruby text=\"ご\"]語
という文字列が挿入される。"
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
  "バッファ buffer-or-name に含まれるラベルのリストを返す。
buffer-or-name が nil ならば、対象はカレントバッファである。"
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
  "ファイル file-name に含まれるラベルのリストを返す。
file-name が存在しないと nil を返す。"
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
  "n 個だけ先のラベルの位置に移動する。"
  (interactive "p")
  (if (< 0 n)
      (and (progn (end-of-line) t) (re-search-forward "^\\*" nil 1 n) (beginning-of-line))
    (re-search-backward "^\\*" nil 1 (- n))))

(defun kag-backward-label (n)
  "n 個だけ前のラベルの位置に移動する。"
  (interactive "p")
  (kag-forward-label (- n)))

(defun kag-forward-savable-label (n)
  "n 個だけ先のセーブ可能なラベルの位置に移動する。"
  (interactive "p")
  (if (< 0 n)
      (and (progn (end-of-line) t) (re-search-forward "^\\*.*|" nil 1 n) (beginning-of-line))
    (re-search-backward "^\\*.*|" nil 1 (- n))))

(defun kag-backward-savable-label (n)
  "n 個だけ前のセーブ可能なラベルの位置に移動する。"
  (interactive "p")
  (kag-forward-savable-label (- n)))
	  

(defun kag-scan-tag (from count)
  "位置 from から前方に向けて count 個のタグを走査する。
走査を終えた位置を返す。 count が負であると、後方へ向けて
走査する。
走査に失敗した場合、nil を返す。"
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
  "n 個だけ先のタグの位置に移動する。"
  (interactive "P")
  (setq n (prefix-numeric-value n))
  (goto-char (or (kag-scan-tag (point) n) (buffer-end n))))

(defun kag-backward-tag (n)
  "n 個だけ後ろのタグの位置に移動する。"
  (interactive "P")
  (kag-forward-tag (- (prefix-numeric-value n))))

(defun kag-kill-tag (n)
  "カーソルの先にある n 個のタグをキルする。"
  (interactive "p")
  (let ((orig-point (point)))
    (kag-forward-tag n)
    (kill-region orig-point (point))))

(defun kag-backward-kill-tag (n)
  "カーソルの後ろにある n 個のタグをキルする。"
  (interactive "p")
  (kag-kill-tag (- n)))

(defun kag-comment-region (begin end)
  "選択された領域をコメントアウトする。
正確には、領域開始の行から領域終了の次の文字がある行までを
コメントアウトするので、領域よりも１行多くコメントアウトさ
れることがあります。"
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
  "選択された領域がコメントアウトされていたら、コメントをはずす。
領域に対する注意は、 `kag-comment-region' と同じです。"
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
  "storage をパスから検索し、フルパスを返す。
見つからなければ nil を返す。"
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

	  ;; 拡張子補完
	  (while completable-extensions
	    (let* ((ext (car completable-extensions))
		   (file-with-ext (concat file ext)))
	      (if (file-exists-p file-with-ext)
		  (throw 'found (expand-file-name file-with-ext))))
	    (setq completable-extensions (cdr completable-extensions)))

	  (setq storage-load-path (cdr storage-load-path))))
      nil)))


(defun kag-follow-link-at-point ()
  "ポイントの位置にあるタグの移動先に移動する。
有効なタグは `kag-jumpable-tag-alist' によって定義される。"
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
			   ;; 変更無しなのだが、変更前の値はわからない
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
			   ;; 呼び出し元の call に戻るのだが、
			   ;; その場所はわからない。
			   (error "Can't determine the call point."))
		       (kag-visit-link target storage)
		       )
		      (t
		       (kag-visit-link target storage)
		       )))
	    (error "There is no valid link at point")))
      (error "There is no valid link at point."))))


(defun kag-visit-link (&optional label-name storage)
  "storage にある label-name ラベルの場所を開く。
label-name が nil ならば、ファイルの先頭を指定したものとみなす。
storage が nil ならば、カレントファイルを指定したものとみなす。"
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
	;; ラベルがない
	(error "Label %s is not found." label-name)))))
	   

(defun kag-pop-link-mark ()
  "前回、kag-visit-link を呼び出した地点に戻る。"
  (interactive)
  (if (ring-empty-p kag-visit-link-marker-ring)
	(error "kag-visit-link は実行されていません。"))
  (let ((marker (ring-remove kag-visit-link-marker-ring 0)))
    (switch-to-buffer (or (marker-buffer marker)
			  (error "マークされたバッファは既に消去されています。")))
    (goto-char (marker-position marker))
    (set-marker marker nil nil)))

(defun kag-list-tag-pos-at-line ()
  "ポイントのある行のタグの位置のリストを返す。
戻り値は ((beg1 . end1) (beg2 . end2) ...) の形のリスト。
;(equal (char-after beg) ?\\[)
;(equal (char-after (1- end)) ?\\])
である。
タグがなかったときは nil を返す。
タグが閉じられないまま行が終了したときは、
最後のタグの end の値は nil になる。
すなわち、最後の要素が (begn . nil) となる。
タグにはコマンド行を含む。"
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
		   ;; タグの中
		   (if inside-of-quote-p
		       ;; quote の中
		       (if (equal c quote-char)
			   (setq inside-of-quote-p nil))
		     ;; quote の外
		     (cond ((equal c ?\ )
			    (cond (now-reading-name-p
				   ;; 名前を読み終わった
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
			    ;; タグから出る
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
			   (t ;; その他の文字
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
		 ;; タグの外
		 (if (equal c ?\[)
		     (if (equal (char-after (1+ (point))) ?\[)
			 (setq i (1+ i))
		       ;; タグの中に入る
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
  "ポイントがタグかコマンド行の内側にあるならば、そのタグのリージョンを返す。
戻り値は、(beg . end) の形のコンスセル。
ポイントがタグかコマンド行の内側になければ、 nil を返す。"
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
  "ポイントのある場所が含まれるタグもしくはコマンド行を文字列で返す。
ポイントの場所がタグに含まれない場合は nil を返す。"
  (interactive)
  (let ((tagpos (kag-get-tag-region-at-point)))
    (if tagpos
	(buffer-substring-no-properties (car tagpos) (cdr tagpos))
      nil)))
		 
(defun kag-get-tag-name-at-point ()
  "ポイントのある場所が含まれるタグまたはコマンド行の名前を返す。
タグは、タグ終了の ] がなくてもよい。
ポイントがタグまたはコマンド行の内側にないときは nil を返す。"
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
  "与えられたタグを分解する。
tagstr は、 \"[tagname key1=value1 ... ]\" の形か、
\"@tagname key1=val1 ... \" の形の文字列。
戻り値は (tagname (key1 . value1) (key2 . value2) ... ) の形のリスト。"
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
  "ポイントのある場所が、タグの内側であるかどうか。
タグにはコマンド行を含む。"
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
		       ;; タグの中
		       (if inside-of-quote-p
			   ;; quote の中
			   (if (equal c quote-char)
			       (progn
				 (setq inside-of-quote-p nil)
				 ))
			 ;; quote の外
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
				;; タグから出る
				(setq inside-of-tag-p nil)
				(setq inside-of-quote-p nil)
				(setq tag-end (point))
				)
			       (t
				(if between-attr-and-value-p ;; attr= を読んで以降、スペースしか読んでない
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
		     ;; タグの外
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
  "ポイントのある行がコメント行であるかどうか。"
  (save-excursion
    (beginning-of-line)
    (equal (char-after) ?\;)))

(defun kag-command-line-p ()
  "ポイントのある行がコマンド行であるかどうか。"
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
  "ポイントの文字が、タグ先頭であるかどうか。"
  (if (kag-command-line-p)
      (bolp)
    (not (null (member (point) (mapcar 'car (kag-list-tag-pos-at-line)))))))

(defun kag-tag-tail-p ()
  "ポイントの文字が、タグ末尾であるかどうか。"
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
  "コメント行あるいはコマンド行以外の行末のスペースにマッチする。"
  (if (re-search-forward "[ 　]+$" last t 1)
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
		;; コメント
		'("^;.*$" (0 kag-comment-face t t))

		;; ラベル
		'("^\\(\\*[^\r\n|]+\\)\\(|.*\\)?$"
		  (1 kag-label-face nil t))

		;; コマンド行
		(list match-command-line
		      '(1 kag-tag-delimiter-face nil t)
		      '(2 kag-tag-name-face)
		      '("\\(\\w+[ \t]*=\\)[ \t]*\\([^'\" \t\r\n][^ \t\r\n]*\\|\"[^\"\r\n]*\"\\|'[^'\r\n]*'\\)"
			nil nil
			(1 kag-tag-attribute-face nil t)
			(2 kag-tag-value-face nil t)))

		;; タグ	 
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
		      ;; 行末のスペース
		      '(match-excessive-space . (0 kag-excessive-space-face nil t))

		      ;; 全角スペース
		      '("　" . (0 kag-zenkaku-space-face t t))
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
