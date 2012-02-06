;;; jdunnet.el --- Text adventure for Emacs(Japanese version)
;; Modified by HAKASE <hakase2772@yahoo.co.jp>, Since 9/30, 2006
;; Version: 2.01jp-0.04a

;; このプログラムはRon Schnell氏の作成したテキストアドベンチャーゲーム
;; dunnet Ver 2.01 のメッセージを日本語化したうえで一部拡張したものです。
;; このゲームはemacs系のエディタ上で動作します。
;; 注：日本語版はまだα版です。翻訳していないメッセージが残っています。
;;     このプログラムや翻訳に関する質問をRon Schnell氏には送らない
;;     でください。

;; jdunnet の 著作権等は オリジナルの dunnet と同様 GPL に準拠します。
;; 以下にオリジナルのプログラムのヘッダを示します。
;; --------------------------------------------------------------------------
;;; dunnet.el --- Text adventure for Emacs

;; Copyright (C) 1992, 1993 Free Software Foundation, Inc.

;; Author: Ron Schnell <ronnie@driver-aces.com>
;; Created: 25 Jul 1992
;; Version: 2.01
;; Keywords: games

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This game can be run in batch mode.  To do this, use:
;;    emacs -batch -l dunnet
;; --------------------------------------------------------------------------

;;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
;;;  The log file should be set for your system, and it must
;;;  be writable by all.
;;   必要なら、スコアのログファイル名をあなたのシステムの状況に応じて
;;   書き換えて、全てのユーザが書き換え可能にしてください。

(defgroup dunnet nil
  "Text adventure for Emacs."
  :prefix "dun-"
  :group 'games)

(defcustom dun-log-file "/usr/local/dunnet.score"
  "Name of file to store score information for dunnet."
  :type 'file
  :group 'dunnet)

(if nil
    (eval-and-compile (setq byte-compile-warnings nil)))

(eval-when-compile
 (require 'cl))

;;;; Mode definitions for interactive mode

(defun dun-mode ()
  "Major mode for running dunnet."
  (interactive)
  (text-mode)
  (make-local-variable 'scroll-step)
  (setq scroll-step 2)
  (use-local-map dungeon-mode-map)
  (setq major-mode 'dungeon-mode)
  (setq mode-name "Dungeon"))

(defun dun-parse (arg)
  "Function called when return is pressed in interactive mode to parse line."
  (interactive "*p")
  (beginning-of-line)
  (setq beg (+ (point) 1))
  (end-of-line)
  (if (and (not (= beg (point))) (not (< (point) beg))
	   (string= ">" (buffer-substring (- beg 1) beg)))
      (progn
	(setq line (downcase (buffer-substring beg (point))))
	(princ line)
	(if (eq (dun-vparse dun-ignore dun-verblist line) -1)
	    (dun-mprinc "それは理解できません。\n")))
    (goto-char (point-max))
    (dun-mprinc "\n"))
    (dun-messages))
    
(defun dun-messages ()
  (if dun-dead
      (text-mode)
    (if (eq dungeon-mode 'dungeon)
	(progn
	  (if (not (= room dun-current-room))
	      (progn
		(dun-describe-room dun-current-room)
		(setq room dun-current-room)))
	  (dun-fix-screen)
	  (dun-mprinc ">")))))


;;;###autoload
(defun jdunnet ()
  "Switch to *dungeon* buffer and start game."
  (interactive)
  (switch-to-buffer "*dungeon*")
  (dun-mode)
  (setq dun-dead nil)
  (setq room 0)
  (dun-messages))

;;;;
;;;; This section contains all of the verbs and commands.
;;;;

;;; Give long description of room if haven't been there yet.  Otherwise
;;; short.  Also give long if we were called with negative room number.

(defun dun-describe-room (room)
  (if (and (not (member (abs room) dun-light-rooms)) 
	   (not (member obj-lamp dun-inventory)))
      (dun-mprincl "ここは真っ暗です。このままではグールに食われる可能性が高いです。")
;    (dun-mprincl (cadr (nth (abs room) dun-rooms)))
    (dun-mprinc "■場所： ")
    (dun-mprinc (caddr (nth (abs room) dun-rooms)))
    (dun-mprincl (format " <%s>" (cadr (nth (abs room) dun-rooms))))
    (if (and (and (or (member room dun-visited) 
		      (string= dun-mode "dun-superb")) (> room 0))
	     (not (string= dun-mode "long")))
	nil
      (dun-mprinc (car (nth (abs room) dun-rooms)))
    (dun-mprinc "\n"))
    (if (not (string= dun-mode "long"))
	(if (not (member (abs room) dun-visited))
	    (setq dun-visited (append (list (abs room)) dun-visited))))
    (dolist (xobjs (nth dun-current-room dun-room-objects))
      (if (= xobjs obj-special)
	  (dun-special-object)
	(if (>= xobjs 0)
	    (dun-mprincl (car (nth xobjs dun-objects)))
	  (if (not (and (= xobjs obj-bus) dun-inbus))
	      (progn
		(dun-mprincl (car (nth (abs xobjs) dun-perm-objects)))))))
      (if (and (= xobjs obj-jar) dun-jar)
	  (progn
	    (dun-mprincl "びんの中身：")
	    (dolist (x dun-jar)
	      (dun-mprinc "     ")
	      (dun-mprincl (car (nth x dun-objects)))))))
    (if (and (member obj-bus (nth dun-current-room dun-room-objects)) dun-inbus)
	(dun-mprincl "あなたはバス(bus)に乗っています。"))))

;;; There is a special object in the room.  This object's description,
;;; or lack thereof, depends on certain conditions.

(defun dun-special-object ()
  (if (= dun-current-room computer-room)
      (if dun-computer
	  (dun-mprincl 
"パネルのライトは組織化されたパターンを描くかのように点滅しています。")
	(dun-mprincl "パネルのライトは変わらず停止しています。")))

  (if (and (= dun-current-room red-room) 
	   (not (member obj-towel (nth red-room dun-room-objects))))
      (dun-mprincl "ここの床には穴(hole)があいています。"))

  (if (and (= dun-current-room marine-life-area) dun-black)
      (dun-mprincl 
"部屋はブラックライトで照らされています。魚と、そしてあなたの持ち物は
その光によって不気味に輝いています。"))
  (if (and (= dun-current-room fourth-vermont-intersection) dun-hole)
      (progn
	(if (not dun-inbus)
	    (progn
	      (dun-mprincl"あなたは地面の穴へと落ちました。")
	      (setq dun-current-room vermont-station)
	      (dun-describe-room vermont-station))
	  (progn
	    (dun-mprincl 
"バスは地面に開いた穴へと落ち、そして爆発しました。")
	    (dun-die "burning")))))

  (if (> dun-current-room endgame-computer-room)
      (progn
	(if (not dun-correct-answer)
	    (dun-endgame-question)
    (dun-mprincl "あなたへの質問は次の通りです：")
    (dun-mprincl (cdr (assoc dun-question-message dun-endgame-questions-msg)))
;	  (dun-mprincl "Your question is:")
;	  (dun-mprincl dun-endgame-question)
)))

  (if (= dun-current-room sauna)
      (progn
	(dun-mprincl (nth dun-sauna-level '(
"今の室内温度は普通です。"
"ここはなま暖かいです。"
"ここは快適な暑さです。"
"ここは今まで感じたことのない暑さです。"
"あなたは今死んでいます。")))
	(if (= dun-sauna-level 3) 
	    (progn
	      (if (or (member obj-rms dun-inventory)
		      (member obj-rms (nth dun-current-room dun-room-objects)))
		  (progn
		    (dun-mprincl 
"あなたはあなたの持っている人形がとけはじめて、そして完全にとけきって
しまったのに気がつきました。そして、そのあとには、美しいダイアモンド
(diamond)が残されました！")
		    (if (member obj-rms dun-inventory)
			(progn
			  (dun-remove-obj-from-inven obj-rms)
			  (setq dun-inventory (append dun-inventory 
						      (list obj-diamond))))
		      (dun-remove-obj-from-room dun-current-room obj-rms)
		      (dun-replace dun-room-objects dun-current-room
				   (append (nth dun-current-room dun-room-objects)
					   (list obj-diamond))))))
	      (if (or (member obj-floppy dun-inventory)
		      (member obj-floppy (nth dun-current-room dun-room-objects)))
		  (progn
		    (dun-mprincl
"あなたはあなたの持っているフロッピーディスクが溶けはじめているのに
気がつきました。あなたがそれを手にとると、炎をあげて燃え出し、消滅して
しまいました。")
		    (dun-remove-obj-from-inven obj-floppy)
		    (dun-remove-obj-from-room dun-current-room obj-floppy))))))))


(defun dun-die (murderer)
  (dun-mprinc "\n")
  (if murderer
      (dun-mprincl "あなたは死んでしまいました。\n■ＧＡＭＥ ＯＶＥＲ"))
  (dun-do-logfile 'dun-die murderer)
  (dun-score nil)
  (setq dun-dead t))

(defun dun-quit (args)
  (dun-die nil))

;;; Print every object in player's inventory.  Special case for the jar,
;;; as we must also print what is in it.

(defun dun-inven (args)
  (dun-mprinc "あなたは次のものを持っています:")
  (dun-mprinc "\n")
  (dolist (curobj dun-inventory)
    (if curobj
	(progn
	  (dun-mprincl (cadr (nth curobj dun-objects)))
	  (if (and (= curobj obj-jar) dun-jar)
	      (progn
		(dun-mprincl "ガラスびん(jar)に含まれるもの:")
		(dolist (x dun-jar)
		  (dun-mprinc "     ")
		  (dun-mprincl (cadr (nth x dun-objects))))))))))

(defun dun-shake (obj)
  (let (objnum)
    (when (setq objnum (dun-objnum-from-args-std obj))
      (if (member objnum dun-inventory)
	  (progn
;;;	If shaking anything will do anything, put here.
;	    (dun-mprinc "Shaking ")
;	    (dun-mprinc (downcase (cadr (nth objnum dun-objects))))
;	    (dun-mprinc " seems to have no effect.")
;	    (dun-mprinc "\n")
	    (dun-mprinc (format "あなたは %s をふりました。\nしかし何も起きなったようにみえます。\n"
              (downcase (cadr (nth objnum dun-objects)))))
	    )
	(if (and (not (member objnum (nth dun-current-room dun-room-silents)))
		 (not (member objnum (nth dun-current-room dun-room-objects))))
	    (dun-mprincl "それはここには見あたりません。")
;;;     Shaking trees can be deadly
	  (if (= objnum obj-tree)
	      (progn
		(dun-mprinc
 "あなたが木を振ると、空からヤシの実が落ち始めるのに気がつきました。
あなたはそれを避けるために手を上に上げようとしましたが、その前にあなたは
それが頭の上に落ちる衝撃を感じました。")
		(dun-die "a coconut"))
	    (if (= objnum obj-bear)
		(progn
		  (dun-mprinc
"あなたは熊のところに近づくと、熊はあなたの頭を取り去さって、
あなたの頭は地上に落ちました。")
		  (dun-die "a bear"))
	      (if (< objnum 0)
		  (dun-mprincl "それをふることはできません。")
		(dun-mprincl "あなたはそれを持っていません。")))))))))


(defun dun-drop (obj)
  (if dun-inbus
      (dun-mprincl "バスの中では何も置くことはできません。")
  (let (objnum ptr)
    (when (setq objnum (dun-objnum-from-args-std obj))
      (if (not (setq ptr (member objnum dun-inventory)))
	  (dun-mprincl "あなたはそれを持っていません。")
	(progn
	  (dun-remove-obj-from-inven objnum)
	  (dun-replace dun-room-objects dun-current-room
		   (append (nth dun-current-room dun-room-objects)
			   (list objnum)))
	  (dun-mprincl "置きました。")
	  (if (member objnum (list obj-food obj-weight obj-jar))
	      (dun-drop-check objnum))))))))

;;; Dropping certain things causes things to happen.

(defun dun-drop-check (objnum)
  (if (and (= objnum obj-food) (= room bear-hangout)
	   (member obj-bear (nth bear-hangout dun-room-objects)))
      (progn
	(dun-mprincl
"熊は食べ物をひろって、それを持ち逃げしました。彼は何かを落として
いったようです。")
	(dun-remove-obj-from-room dun-current-room obj-bear)
	(dun-remove-obj-from-room dun-current-room obj-food)
	(dun-replace dun-room-objects dun-current-room
		 (append (nth dun-current-room dun-room-objects)
			 (list obj-key)))))

  (if (and (= objnum obj-jar) (member obj-nitric dun-jar) 
	   (member obj-glycerine dun-jar))
      (progn
	(dun-mprincl 
	 "びんが地面にぶつかると、それは粉々に砕けました。")
	(setq dun-jar nil)
	(dun-remove-obj-from-room dun-current-room obj-jar)
	(if (= dun-current-room fourth-vermont-intersection)
	    (progn
	      (setq dun-hole t)
	      (setq dun-current-room vermont-station)
	      (dun-mprincl 
"■■■■■■■■■■■■■■■■■■■■■■■■■■■■
爆発が起こり、地面に穴があきました。あなたはその穴に落ちました。")))))

  (if (and (= objnum obj-weight) (= dun-current-room maze-button-room))
      (dun-mprincl "通路が開きました。")))

;;; Give long description of current room, or an object.
      
(defun dun-examine (obj)
  (let (objnum)
    (setq objnum (dun-objnum-from-args obj))
    (if (eq objnum obj-special)
	(dun-describe-room (* dun-current-room -1))
      (if (and (eq objnum obj-computer)
	       (member obj-pc (nth dun-current-room dun-room-silents)))
	  (dun-examine '("pc"))
	(if (eq objnum nil)
	    (dun-mprincl "それが何かわかりません。")
	  (if (and (not (member objnum 
				(nth dun-current-room dun-room-objects)))
		   (not (and (member obj-jar dun-inventory)
			     (member objnum dun-jar)))
		   (not (member objnum 
				(nth dun-current-room dun-room-silents)))
		   (not (member objnum dun-inventory)))
	      (dun-mprincl "それはここには見当たりません。")
	    (if (>= objnum 0)
		(if (and (= objnum obj-bone) 
			 (= dun-current-room marine-life-area) dun-black)
		    (dun-mprincl 
"この光によって、あなたは骨の上に書かれた文字を読むことができます。
そこには次のように書いてありました。
  「爆発させる時には、第４通りとバーモント通りの交差点へ行け。」")
		  (if (nth objnum dun-physobj-desc)
		      (dun-mprincl (nth objnum dun-physobj-desc))
		    (dun-mprincl "特に見るべきものはありません。")))
	      (if (nth (abs objnum) dun-permobj-desc)
		  (progn
		    (dun-mprincl (nth (abs objnum) dun-permobj-desc)))
		(dun-mprincl "特に見るべきものはありません。")))))))))

(defun dun-take (obj)
    (setq obj (dun-firstword obj))
    (if (not obj)
	(dun-mprincl "何を取るかを動詞 take の後ろに指定してください。")
      (if (string= obj "all")
	  (let (gotsome)
	    (if dun-inbus
		(dun-mprincl "バス(bus)に乗っている間は何も取れません。")
	      (setq gotsome nil)
	      (dolist (x (nth dun-current-room dun-room-objects))
		(if (and (>= x 0) (not (= x obj-special)))
		    (progn
		      (setq gotsome t)
		      (dun-mprinc (cadr (nth x dun-objects)))
		      (dun-mprinc ": ")
		      (dun-take-object x))))
	      (if (not gotsome)
		  (dun-mprincl "取るべきものはありません。"))))
	(let (objnum)
	  (setq objnum (cdr (assq (intern obj) dun-objnames)))
	  (if (eq objnum nil)
	      (progn
		(dun-mprinc "それが何かわかりません。")
		(dun-mprinc "\n"))
	    (if (and dun-inbus (not (and (member objnum dun-jar)
					 (member obj-jar dun-inventory))))
		(dun-mprincl "バス(bus)に乗っている間は何も取れません。")
	      (dun-take-object objnum)))))))

(defun dun-take-object (objnum)
  (if (and (member objnum dun-jar) (member obj-jar dun-inventory))
      (let (newjar)
	(dun-mprincl "あなたはびんからそれを取り除きました。")
	(setq newjar nil)
	(dolist (x dun-jar)
	  (if (not (= x objnum))
	      (setq newjar (append newjar (list x)))))
	(setq dun-jar newjar)
	(setq dun-inventory (append dun-inventory (list objnum))))
    (if (not (member objnum (nth dun-current-room dun-room-objects)))
	(if (not (member objnum (nth dun-current-room dun-room-silents)))
	    (dun-mprinc "それはここには見あたりません。")
	  (dun-try-take objnum))
      (if (>= objnum 0)
	  (progn
	    (if (and (car dun-inventory) 
		     (> (+ (dun-inven-weight) (nth objnum dun-object-lbs)) 11))
		(dun-mprinc "あなたの荷物は重すぎます。")
	      (setq dun-inventory (append dun-inventory (list objnum)))
	      (dun-remove-obj-from-room dun-current-room objnum)
	      (dun-mprinc "取りました。 ")
	      (if (and (= objnum obj-towel) (= dun-current-room red-room))
		  (dun-mprinc 
		   "タオルを取ると、床に穴があいていることがわかりました。"))))
	(dun-try-take objnum)))
    (dun-mprinc "\n")))

(defun dun-inven-weight ()
  (let (total)
    (setq total 0)
    (dolist (x dun-jar)
      (setq total (+ total (nth x dun-object-lbs))))
    (dolist (x dun-inventory)
      (setq total (+ total (nth x dun-object-lbs)))) total))

;;; We try to take an object that is untakable.  Print a message
;;; depending on what it is.

(defun dun-try-take (obj)
  (dun-mprinc "それを取ることはできません。"))

(defun dun-dig (args)
  (if dun-inbus
      (dun-mprincl "ここで穴を掘っても何もみつかりません。")
  (if (not (member 0 dun-inventory))
      (dun-mprincl "あなたは掘るための道具を持っていません。")
    (if (not (nth dun-current-room dun-diggables))
	(dun-mprincl "ここで穴を掘っても何もみつかりません。")
      (dun-mprincl "穴を掘ると何かが出てきました。")
      (dun-replace dun-room-objects dun-current-room
	       (append (nth dun-current-room dun-room-objects)
		       (nth dun-current-room dun-diggables)))
      (dun-replace dun-diggables dun-current-room nil)))))

(defun dun-climb (obj)
  (let (objnum)
    (setq objnum (dun-objnum-from-args obj))
    (cond ((not objnum)
	   (dun-mprincl "それが何かわかりません。"))
	  ((and (not (eq objnum obj-special))
		(not (member objnum (nth dun-current-room dun-room-objects)))
		(not (member objnum (nth dun-current-room dun-room-silents)))
		(not (and (member objnum dun-jar) (member obj-jar dun-inventory)))
		(not (member objnum dun-inventory)))
	   (dun-mprincl "これはここには見あたりません。"))
	  ((and (eq objnum obj-special)
		(not (member obj-tree (nth dun-current-room dun-room-silents))))
	   (dun-mprincl "ここには登れるものは何もありません。"))
	  ((and (not (eq objnum obj-tree)) (not (eq objnum obj-special)))
	   (dun-mprincl "あなたはそれに登ることはできません。"))
	  (t
	   (dun-mprincl
	    "あなたは２フィートほど木を登り、そして降りました。
あなたは木がとてもぐらぐらしていることに気づきました。")))))

(defun dun-eat (obj)
  (let (objnum)
    (when (setq objnum (dun-objnum-from-args-std obj))
      (if (not (member objnum dun-inventory))
	  (dun-mprincl "それを持っていません。")
	(if (not (= objnum obj-food))
	    (progn
	      (dun-mprinc "あなたが ")
	      (dun-mprinc (downcase (cadr (nth objnum dun-objects))))
	      (dun-mprincl " を喉につめこむと、あなたは窒息しはじめました。")
	      (dun-die "choking"))
	  (dun-mprincl "それは恐ろしい味がしました。")
	  (dun-remove-obj-from-inven obj-food))))))

(defun dun-put (args)
    (let (newargs objnum objnum2 obj)
      (setq newargs (dun-firstwordl args))
      (if (not newargs)
	  (dun-mprincl "目的語を指定してください。")
	(setq obj (intern (car newargs)))
	(setq objnum (cdr (assq obj dun-objnames)))
	(if (not objnum)
	    (dun-mprincl "それが何かわかりません。")
	  (if (not (member objnum dun-inventory))
	      (dun-mprincl "あなたはそれを持っていません。")
	    (setq newargs (dun-firstwordl (cdr newargs)))
	    (setq newargs (dun-firstwordl (cdr newargs)))
	    (if (not newargs)
		(dun-mprincl "対象を指定してください（put A in B など）。")
	      (setq objnum2 (cdr (assq (intern (car newargs)) dun-objnames)))
	      (if (and (eq objnum2 obj-computer) (= dun-current-room pc-area))
		  (setq objnum2 obj-pc))
	      (if (not objnum2)
		  (dun-mprincl "指定された対象が何かわかりません。")
		(if (and (not (member objnum2 
				      (nth dun-current-room dun-room-objects)))
			 (not (member objnum2 
				      (nth dun-current-room dun-room-silents)))
			 (not (member objnum2 dun-inventory)))
		    (dun-mprincl "指定された対象はここにはありません。")
		  (dun-put-objs objnum objnum2)))))))))

(defun dun-put-objs (obj1 obj2)
  (if (and (= obj2 obj-drop) (not dun-nomail))
      (setq obj2 obj-chute))

  (if (= obj2 obj-disposal) (setq obj2 obj-chute))

  (if (and (= obj1 obj-cpu) (= obj2 obj-computer))
      (progn
	(dun-remove-obj-from-inven obj-cpu)
	(setq dun-computer t)
	(dun-mprincl
"あなたがコンピュータにCPUボードを入れると、それはすぐに稼動しました。
光が点滅しはじめ、ファンが回りはじめました。"))
    (if (and (= obj1 obj-weight) (= obj2 obj-button))
	(dun-drop '("weight"))
      (if (= obj2 obj-jar)                 ;; Put something in jar
	  (if (not (member obj1 (list obj-paper obj-diamond obj-emerald
				      obj-license obj-coins obj-egg
				      obj-nitric obj-glycerine)))
	      (dun-mprincl "それはびんに入れるには適しません。")
	    (dun-remove-obj-from-inven obj1)
	    (setq dun-jar (append dun-jar (list obj1)))
	    (dun-mprincl "入れました"))
	(if (= obj2 obj-chute)                 ;; Put something in chute
	    (progn
	      (dun-remove-obj-from-inven obj1)
	      (dun-mprincl 
"あなたがそれを中にすべり入れると、それが遠くへいく音を聞きました。")
	      (dun-put-objs-in-treas (list obj1)))
	  (if (= obj2 obj-box)              ;; Put key in key box
	      (if (= obj1 obj-key)
		  (progn
		    (dun-mprincl
"あなたが鍵を入れると、箱は振動をしはじめます。そして最後には爆発して
しまいました。鍵はなくなってしまったように見えます！")
		    (dun-remove-obj-from-inven obj1)
		    (dun-replace dun-room-objects computer-room (append
							(nth computer-room
							     dun-room-objects)
							(list obj1)))
		    (dun-remove-obj-from-room dun-current-room obj-box)
		    (setq dun-key-level (1+ dun-key-level)))
		(dun-mprincl "キーボックスにはそれを入れることはできません！"))

	    (if (and (= obj1 obj-floppy) (= obj2 obj-pc))
		(progn
		  (setq dun-floppy t)
		  (dun-remove-obj-from-inven obj1)
		  (dun-mprincl "入れました。"))

	      (if (= obj2 obj-urinal)                   ;; Put object in urinal
		  (progn
		    (dun-remove-obj-from-inven obj1)
		    (dun-replace dun-room-objects urinal (append 
						  (nth urinal dun-room-objects)
						   (list obj1)))
		    (dun-mprincl
		     "あなたはそれが下にある水の中に落ちる音を聞きました。"))
		(if (= obj2 obj-mail)
		    (dun-mprincl "郵便受けには鍵がかかっています。")
		  (if (member obj1 dun-inventory)
		      (dun-mprincl 
"それらをどう組み合わせればいいのかわかりません。
それを単に落とす(drop)することを試してみてください。")
		    (dun-mprincl"あなたはそれをそこに入れることはできません。")))))))))))

(defun dun-type (args)
  (if (not (= dun-current-room computer-room))
      (dun-mprincl "あなたがタイプできるものはここにはありません。")
    (if (not dun-computer)
	(dun-mprincl 
"あなたはキーボードをタイプしました。しかし、あなたのタイプした文字は
表示すらされませんでした。")
      (dun-unix-interface))))

;;; Various movement directions

(defun dun-n (args)
  (dun-move north))

(defun dun-s (args)
  (dun-move south))

(defun dun-e (args)
  (dun-move east))

(defun dun-w (args)
  (dun-move west))

(defun dun-ne (args)
  (dun-move northeast))

(defun dun-se (args)
  (dun-move southeast))

(defun dun-nw (args)
  (dun-move northwest))

(defun dun-sw (args)
  (dun-move southwest))

(defun dun-up (args)
  (dun-move up))

(defun dun-down (args)
  (dun-move down))

(defun dun-in (args)
  (dun-move in))

(defun dun-out (args)
  (dun-move out))

(defun dun-go (args)
  (if (or (not (car args)) 
	  (eq (dun-doverb dun-ignore dun-verblist (car args) 
			  (cdr (cdr args))) -1))
      (dun-mprinc "どこへ行けばいいのかわかりません。\n")))

;;; Uses the dungeon-map to figure out where we are going.  If the
;;; requested direction yields 255, we know something special is
;;; supposed to happen, or perhaps you can't go that way unless
;;; certain conditions are met.

(defun dun-move (dir)
  (if (and (not (member dun-current-room dun-light-rooms)) 
	   (not (member obj-lamp dun-inventory)))
      (progn
	(dun-mprinc 
"あなたはグールにつまづいて穴に落ち、そしてあなたの体の全ての骨は
グールに砕かれてしまいました。")
	(dun-die "a grue"))
    (let (newroom)
      (setq newroom (nth dir (nth dun-current-room dungeon-map)))
      (if (eq newroom -1)
	  (dun-mprinc "あなたはその方向へ行くことはできません。\n")
	(if (eq newroom 255)
	    (dun-special-move dir)
	  (setq room -1)
	  (setq dun-lastdir dir)
	  (if dun-inbus
	      (progn
		(if (or (< newroom 58) (> newroom 83))
		    (dun-mprincl "バスはそこへは行けません。")
		  (dun-mprincl 
		   "バスは急に前方に傾き、そして急停止しました。")
		  (dun-remove-obj-from-room dun-current-room obj-bus)
		  (setq dun-current-room newroom)
		  (dun-replace dun-room-objects newroom
			   (append (nth newroom dun-room-objects)
				   (list obj-bus)))))
	    (setq dun-current-room newroom)))))))

;;; Movement in this direction causes something special to happen if the
;;; right conditions exist.  It may be that you can't go this way unless
;;; you have a key, or a passage has been opened.

;;; coding note: Each check of the current room is on the same 'if' level,
;;; i.e. there aren't else's.  If two rooms next to each other have
;;; specials, and they are connected by specials, this could cause
;;; a problem.  Be careful when adding them to consider this, and
;;; perhaps use else's.

(defun dun-special-move (dir)
  (if (= dun-current-room building-front)
      (if (not (member obj-key dun-inventory))
	  (dun-mprincl "あなたはドアを開けるための鍵を持っていません。")
	(setq dun-current-room old-building-hallway))
    (if (= dun-current-room north-end-of-cave-passage)
	(let (combo)
	  (dun-mprincl 
"あなたがこの部屋に入るには３桁の数字をタイプしなければなりません。")
	  (dun-mprinc " ３桁の数字は？ : ")
	  (setq combo (dun-read-line))
	  (if (not dun-batch-mode)
	      (dun-mprinc "\n"))
	  (if (string= combo dun-combination)
	      (setq dun-current-room gamma-computing-center)
	    (dun-mprincl "その数字の組み合わせは不正です。"))))

    (if (= dun-current-room bear-hangout)
	(if (member obj-bear (nth bear-hangout dun-room-objects))
	    (progn
	      (dun-mprinc 
"あなたが熊のすぐそばを遠慮なしに歩いて通り過ぎようとしたことに、
熊はとても苛立ったようです。彼は、あなたの頭を食いちぎることで
それをあたなに教えました。")
	      (dun-die "a bear"))
	  (dun-mprincl "あなたはその方向へは行けません。")))

    (if (= dun-current-room vermont-station)
	(progn
	  (dun-mprincl
"■■■■■■■■■■■■■■■■■■■■■■■■■■■■
★あなたが列車に乗り込むと、それはすぐに駅を出ました。列車は上下左右に
激しく揺れ、乗り心地は最悪です。あなたは少しでも苦痛を軽くするために
椅子のひとつに座りました。")
	  (dun-mprincl
"\n最後には列車は突然停止し、ドアが開き、その衝撃であなたは外へと
投げ出されました。そして、列車は走り去りました。\n")
	  (setq dun-current-room museum-station)))

    (if (= dun-current-room old-building-hallway)
	(if (and (member obj-key dun-inventory)
		 (> dun-key-level 0))
	    (setq dun-current-room meadow)
	  (dun-mprincl "あなたはドアを開けるための鍵を持っていません。")))

    (if (and (= dun-current-room maze-button-room) (= dir northwest))
	(if (member obj-weight (nth maze-button-room dun-room-objects))
	    (setq dun-current-room 18)
	  (dun-mprincl "あなたはそこへ行くことは出来ません。")))

    (if (and (= dun-current-room maze-button-room) (= dir up))
	(if (member obj-weight (nth maze-button-room dun-room-objects))
	    (dun-mprincl "あなたはそこへ行くことは出来ません。")
	  (setq dun-current-room weight-room)))

    (if (= dun-current-room classroom)
	(dun-mprincl "ドアはロックされています。"))

    (if (or (= dun-current-room lakefront-north) 
	    (= dun-current-room lakefront-south))
	(dun-swim nil))

    (if (= dun-current-room reception-area)
	(if (not (= dun-sauna-level 3))
	    (setq dun-current-room health-club-front)
	  (dun-mprincl
"あなたが建物から出ようとしたとき、窓のひとつから炎が出てくるのに
気が付きました。突然、建物は巨大な火の玉となって爆発しました。
炎があなたの体をのみ込み、あなたは焼け死んでしまいました。")
	  (dun-die "burning")))

    (if (= dun-current-room red-room)
	(if (not (member obj-towel (nth red-room dun-room-objects)))
	    (setq dun-current-room long-n-s-hallway)
	  (dun-mprincl "あなたはそこへ行くことは出来ません。")))

    (if (and (> dir down) (> dun-current-room gamma-computing-center) 
	     (< dun-current-room museum-lobby))
	(if (not (member obj-bus (nth dun-current-room dun-room-objects)))
	    (dun-mprincl "あなたはそこへ行くことは出来ません。")
	  (if (= dir in)
	      (if dun-inbus
		  (dun-mprincl
		   "あなたは既にバスの中にいます！")
		(if (member obj-license dun-inventory)
		    (progn
		      (dun-mprincl 
		       "あなたはバスに乗り込み、運転席に入りました。")
		      (setq dun-nomail t)
		      (setq dun-inbus t))
		  (dun-mprincl "あなたはこの種の乗り物を運転するための免許証を持っていません。")))
	    (if (not dun-inbus)
		(dun-mprincl "あなたは既にバスから降りています！")
	      (dun-mprincl "あなたはバスから飛び降りました。")
	      (setq dun-inbus nil))))
      (if (= dun-current-room fifth-oaktree-intersection)
	  (if (not dun-inbus)
	      (progn
		(dun-mprincl "あなたは崖の下にさかさまに落下し、頭を地面にぶつけました。")
		(dun-die "a cliff"))
	    (dun-mprincl
"バスは崖へと飛び出し、崖の底へと突っ込み、そして爆発しました。")
	    (dun-die "a bus accident")))
      (if (= dun-current-room main-maple-intersection)
	  (progn
	    (if (not dun-inbus)
		(dun-mprincl "門は開かないでしょう。")
	      (dun-mprincl
"■■■■■■■■■■■■■■■■■■■■■■■■■■■■
★バスが近づくと門が開き、あなたはそこを通過しました。")
	      (dun-remove-obj-from-room main-maple-intersection obj-bus)
	      (dun-replace dun-room-objects museum-entrance 
		       (append (nth museum-entrance dun-room-objects)
			       (list obj-bus)))
	      (setq dun-current-room museum-entrance)))))
    (if (= dun-current-room cave-entrance)
	(progn
	  (dun-mprincl
"■■■■■■■■■■■■■■■■■■■■■■■■■■■■
★あなたが部屋に入ると、けたたましい音が鳴りひびきました。
あなたがふりかえると、天井から巨大な岩が滑り落ち、あなたが来た道を
ふさぐのが見えました。\n")
	  (setq dun-current-room misty-room)))))

(defun dun-long (args)
  (setq dun-mode "long"))

(defun dun-turn (obj)
  (let (objnum direction)
    (when (setq objnum (dun-objnum-from-args-std obj))
      (if (not (or (member objnum (nth dun-current-room dun-room-objects))
		   (member objnum (nth dun-current-room dun-room-silents))))
	  (dun-mprincl "それはここには見あたりません。")
	(if (not (= objnum obj-dial))
	    (dun-mprincl "それは回転できません。")
	  (setq direction (dun-firstword (cdr obj)))
	  (if (or (not direction) 
		  (not (or (string= direction "clockwise")
			   (string= direction "counterclockwise"))))
	      (dun-mprincl "命令に続けて時計周り(clockwise)か反時計周り(counterclockwise)かを
指定してください。（例 turn A clockwise）")
	    (if (string= direction "clockwise")
		(setq dun-sauna-level (+ dun-sauna-level 1))
	      (setq dun-sauna-level (- dun-sauna-level 1)))
	    
	    (if (< dun-sauna-level 0)
		(progn
		  (dun-mprincl 
		   "ダイアルはこれ以上そちらの方向へ回すことはできないでしょう。")
		  (setq dun-sauna-level 0))
	      (dun-sauna-heat))))))))

(defun dun-sauna-heat ()
  (if (= dun-sauna-level 0)
      (dun-mprincl 
       "温度は標準的な室内温度に戻りました。"))
  (if (= dun-sauna-level 1)
      (dun-mprincl "空気がなま暖くなりました。あなたは汗をかいています。"))
  (if (= dun-sauna-level 2)
      (dun-mprincl "ここは今かなり暑いです。まだとても快適です。"))
  (if (= dun-sauna-level 3)
      (progn
	(dun-mprincl 
"ここは今とてつもなく暑いです。この温度には生まれ変わるような何かがあります。")
	(if (or (member obj-rms dun-inventory) 
		(member obj-rms (nth dun-current-room dun-room-objects)))
	    (progn
	      (dun-mprincl 
"あなたはあなたの持っている人形がとけはじめて、そして完全にとけきって
しまったのに気がつきました。そして、そのあとには、美しいダイアモンド
(diamond)が残されました！")
	      (if (member obj-rms dun-inventory)
		  (progn
		    (dun-remove-obj-from-inven obj-rms)
		    (setq dun-inventory (append dun-inventory 
						(list obj-diamond))))
		(dun-remove-obj-from-room dun-current-room obj-rms)
		(dun-replace dun-room-objects dun-current-room
			 (append (nth dun-current-room dun-room-objects)
				 (list obj-diamond))))))
	(if (or (member obj-floppy dun-inventory)
		(member obj-floppy (nth dun-current-room dun-room-objects)))
	    (progn
	      (dun-mprincl
"あなたはあなたの持っているフロッピーディスクが溶けはじめているのに
気がつきました。あなたがそれを手にとると、炎をあげて燃え出し、消滅して
しまいました。")
	      (if (member obj-floppy dun-inventory)
		  (dun-remove-obj-from-inven obj-floppy)
		(dun-remove-obj-from-room dun-current-room obj-floppy))))))

  (if (= dun-sauna-level 4)
      (progn
	(dun-mprincl 
"ダイアルがその場所をさすと、あなたの体は突然炎で燃え上がりました。")
	(dun-die "burning"))))

(defun dun-press (obj)
  (let (objnum)
    (when (setq objnum (dun-objnum-from-args-std obj))
      (if (not (or (member objnum (nth dun-current-room dun-room-objects))
		   (member objnum (nth dun-current-room dun-room-silents))))
	  (dun-mprincl "それはここには見あたりません。")
	(if (not (member objnum (list obj-button obj-switch)))
	    (progn
	      (dun-mprinc "You can't ")
	      (dun-mprinc (car line-list))
	      (dun-mprincl " that."))
	  (if (= objnum obj-button)
	      (dun-mprincl
"あなたがボタンを押すと、通路が開くのに気がつきました。しかしボタンを
離すと、その通路は閉じてしまいました。"))
	  (if (= objnum obj-switch)
	      (if dun-black
		  (progn
		    (dun-mprincl "ボタンは今オフの状態になっています。")
		    (setq dun-black nil))
		(dun-mprincl "ボタンは今オンの状態になっています。")
		(setq dun-black t))))))))

(defun dun-swim (args)
  (if (not (member dun-current-room (list lakefront-north lakefront-south)))
      (dun-mprincl "泳げるような水は見あたりません！")
    (if (not (member obj-life dun-inventory))
	(progn
	  (dun-mprincl 
"あなたは湖に飛び込み、そこではじめて水が非常に冷たいことに気づきました。
そして、あなたが、実はまともには泳ぎを学んでいなかったんだと悟るにつれて
あなたはその氷のような冷たさに慣れはじめていました。")
	  (dun-die "drowning"))
      (if (= dun-current-room lakefront-north)
	  (setq dun-current-room lakefront-south)
	(setq dun-current-room lakefront-north)))))


(defun dun-score (args)
  (if (not dun-endgame)
      (let (total)
	(setq total (dun-reg-score))
	(dun-mprinc "あなたの合計得点は")
	(dun-mprinc total)
	(dun-mprincl "点です（取得可能な得点は90点です）。") total)
    (dun-mprinc "あなたの合計得点は")
    (dun-mprinc (dun-endgame-score))
    (dun-mprincl " 点です（ゲームクリア時の最高得点は110点です）。")
    (if (= (dun-endgame-score) 110)
;    (if (= (dun-endgame-score) 90)
	(dun-mprincl 
"\n\n★★★おめでとう。あなたは勝利しました。★★★
The wizard password is 'moby'\n"))))

(defun dun-helpeng (args)
  (dun-mprincl
"Welcome to dunnet (2.01), by Ron Schnell (ronnie@driver-aces.com).
Here is some useful information (read carefully because there are one
or more clues in here):
- If you have a key that can open a door, you do not need to explicitly
  open it.  You may just use 'in' or walk in the direction of the door.

- If you have a lamp, it is always lit.

- You will not get any points until you manage to get treasures to a certain
  place.  Simply finding the treasures is not good enough.  There is more
  than one way to get a treasure to the special place.  It is also
  important that the objects get to the special place *unharmed* and
  *untarnished*.  You can tell if you have successfully transported the
  object by looking at your score, as it changes immediately.  Note that
  an object can become harmed even after you have received points for it.
  If this happens, your score will decrease, and in many cases you can never
  get credit for it again.

- You can save your game with the 'save' command, and use restore it
  with the 'restore' command.

- There are no limits on lengths of object names.

- Directions are: north,south,east,west,northeast,southeast,northwest,
                  southwest,up,down,in,out.

- These can be abbreviated: n,s,e,w,ne,se,nw,sw,u,d,in,out.

- If you go down a hole in the floor without an aid such as a ladder,
  you probably won't be able to get back up the way you came, if at all.

- To run this game in batch mode (no emacs window), use:
     emacs -batch -l dunnet
NOTE: This game *should* be run in batch mode!

If you have questions or comments, please contact ronnie@driver-aces.com
My home page is http://www.driver-aces.com/ronnie.html
"))

(defun dun-help (args)
  (dun-mprincl
"ようこそjdunnetへ。これはRon Schnell氏のdunnet(2.01)を日本語化した
ものです。ここでは有益な情報を提供します（ここには多くの手がかりが
書かれているので、注意して読んでください。）

●もし、ドアを開けることができるキー(key)を持っていれば、あなたは
  ドアを開ける動作を入力する必要はありません。あなたは単に「in」を
  使うか、ドアのある方向へ歩くだけでドアに入ることができます。
●もしあなたがランプを持っていれば、いつでも点火(lit)できます。

●あなたが宝をある場所に持っていくことに成功するまでは、あなたは
  得点を得ることができません。単に宝を見つけるだけでは不十分です。
  宝を特別な場所へ持っていく方法はひとつではありません。
  そのモノを「壊さずに」「汚さずに」もっていくことも重要です。
  得点はすぐに変化するので、命令 score で得点を見ればあなたがモノの
  移動に成功したかどうか判ります。
  得点を得た後も、そのモノが壊れたりしないように注意してください。
  もしそれが起きれば得点が減り、決して元の得点に戻ることはないでしょう。

●あなたは、コマンド「save」でゲームを一時保存することができます。
  そして、コマンド「restore」によって、そこから再開することができます。
●オブジェクト名の長さには制限がありません。

●移動は：北 north, 南 south, 東 east, 西 west,北東 northeast , 
          南東 southeast , 北西 northwest, 北東 southwest ,
          上 up, 下 down, 入る in , 出る out ,が使えます。
●これらは 次の短縮形でも入力できます。 n,s,e,w,ne,se,nw,sw,u,d,in,out 

●もしあなたがハシゴのような支援なしで床にあいた穴に下りたならば、
  おそらくあなたは上に登ることはできなくなるでしょう。

●このゲームを（emacsのウインドウではなく）バッチモードで動かすには、
  UNIXのShell上で下記のコマンドを実行してください。
     emacs -batch -l dunnet
注意：このゲームはバッチモードで動かすべきです！

英語のオリジナルの説明を読むには コマンド helpeng を実行してください。
※以下は日本語版のオマケ
  「UNIXの簡易説明」を読むには コマンド helpunix を実行してください。
  「Dos PC の簡易説明」を読むには コマンド helpdos を実行してください。
  「動詞リスト」を見るにはコマンドhelpverbを実行してください。
"))
(defun dun-helpunix (args)
  (dun-mprincl
"「UNIXの簡易説明」
・利用の開始と終了：  Login  利用を開始する手続き。
    ユーザ名とパスワードが必要。ユーザ名には一般に人の名前を用いる。
・コマンド
   exit 《利用を終了する》
   ls  《現在いるディレクトリの中にあるファイルの名前を表示》
     ファイルには[ディレクトリ]と[文書ファイル]と[２進ファイル]がある。
     右端に書かれた文字列がファイル名。
     左端の記号が d ならディレクトリ。 - なら文書または２進ファイル。
   pwd 《現在のディレクトリを表示する》
   cd <ディレクトリ名>  《別のディレクトリへ移動》
     例： cd ..    ／ひとつ上のディレクトリへ移動。
          cd user  ／userという名前のディレクトリへ移動。
   cat <文書ファイル名> 《文書ファイルの記録内容を出力》
   uncompress <圧縮ファイル名> 《圧縮されたファイルを元に戻す》
     圧縮ファイルにはファイル名の後ろに .Z という記号をつける。
   rlogin <ホストコンピュータ名> 《ネットワークを介して別のホストにログイン》
     ユーザ名とパスワードが必要。
     遠隔地にあるコンピュータにログインして使用する。
     （その間、現在使用中のコンピュータは使用できなくなる）
   ftp <ホストコンピュータ名>
     ユーザ名とパスワードが必要。匿名でのログインにはユーザ名 anonymous を利用。
"))
(defun dun-helpdos (args)
  (dun-mprincl
"「Dos-PCの簡易説明」
・利用の開始と終了：
    フロッピーディスクをセットして電源を入れなおす（reset）すると起動する。
    起動用のシステムや情報は全てフロッピーディスクの中に入っている。
    起動時に時刻を入力するよう促されるが、何も入力せずにEnterを押して良い。

・コマンド
   exit 《利用を終了する》
   dir  《現在いるディレクトリの中にあるファイルの名前を表示》
     COMMAND  COM     47845 05-01-04   2:00
     AUTOEXEC BAT        24 05-27-04   1:01
     SAMPLE   TXT       102 06-12-08   0:00
        3 file(s)     47971 bytes
     上記の表示では、command.com, autoexec.bat, sample.txt という
     名前の３つのファイルが存在することを意味する。

   type <文書ファイル名> 《文書ファイルの記録内容を出力》
     例： type sample.txt  
          （sample.txt という名前のファイルの中身を表示する）
"))
(defun dun-helpverb (args)
  (dun-mprincl
"動詞のリスト（一部抜粋）
  answer（答える）,board/on（乗る）,break（壊す）,chop/cut（切る）,
  climb（登る）,drop（置く）, dig（掘る）,drive（運転する）,
  enter/in（入る）,exit/out（出る）,eat（食べる）,flush（荒い流す）,
  get/take（取る）,go（行く）,look/examine/read（見る）,
  press/push（押す）,put/insert（入れる put A in B）,reset（電源を入れなおす）,
  shake/wave（振る）,sleep/lie（寝る）,swin（泳ぐ）,
  throw（投げる）,turn（まわす）,type（入力する）, urinate/piss（小便をする）,
特殊
  score スコアを見る（ゲームをクリアすると賞賛のメッセージが表示される）
  inventory/i （持ち物を見る）
  save ファイル名    （指定した名前のファイルを作成してゲームを保存する）
  restore ファイル名 （指定したファイルを読み込んでゲームを再開する）
移動
  east/e（東）,west/w（西）,south/s（南）,north/n（北）,southeast/se（南東）,
  southwest/sw（南西）,northeast/ne（北東）,northwest/nw（北西）,
  up/u（上）,down/d（下）
  
"
))

(defun dun-flush (args)
  (if (not (= dun-current-room bathroom))
      (dun-mprincl "洗い流すものはありません。")
    (dun-mprincl "Whoooosh!!（ジャァァァー－－－－ッ！！）")
    (dun-put-objs-in-treas (nth urinal dun-room-objects))
    (dun-replace dun-room-objects urinal nil)))

(defun dun-piss (args)
  (if (not (= dun-current-room bathroom))
      (dun-mprincl "ここではそれはできませんし、あなたはそれをしようとすらしません。")
    (if (not dun-gottago)
	(dun-mprincl "あなたが今それをすべきではないでしょう。")
      (dun-mprincl "気持ちよかったです。")
      (setq dun-gottago nil)
      (dun-replace dun-room-objects urinal (append 
					    (nth urinal dun-room-objects)
					    (list obj-URINE))))))


(defun dun-sleep (args)
  (if (not (= dun-current-room bedroom))
      (dun-mprincl
"あなたは立ったままここで寝ようとしましたが、それはできないようです。")
    (setq dun-gottago t)
    (dun-mprincl
"あなたは、眠りにつくとすぐに夢を見ました。湿気と熱の中で奴隷のように
洞窟を掘って働いている労働者の姿が見えます。あなたはその労働者のひとり
が自分である事に気づきます。誰も見ていない間に、あなたはグループを去って
部屋へと歩いていきます。その部屋はていてつに似た形をした大きな石以外には
何もありません。あなたはあなた自身が地面に穴を掘り、その中に何かの
宝物を入れ、その後で再び穴に土をかけて埋めているのを見ます。
その直後に、あなたは目を覚ましました。")))

(defun dun-break (obj)
  (let (objnum)
    (if (not (member obj-axe dun-inventory))
	(dun-mprincl "あなたは何かを壊すための道具を何ももっていません。")
      (when (setq objnum (dun-objnum-from-args-std obj))
	(if (member objnum dun-inventory)
	    (progn
	      (dun-mprincl
"あなたはそのものを手にとり、斧をふりました。しかし不幸にもあなたは
斧をモノに当てるのに失敗し、手を切ってしまいました。
あなたは出血多量で死亡します。")
	      (dun-die "an axe"))
	  (if (not (or (member objnum (nth dun-current-room dun-room-objects))
		       (member objnum 
			       (nth dun-current-room dun-room-silents))))
	      (dun-mprincl "それはここには見あたりません。")
	    (if (= objnum obj-cable)
		(progn
		  (dun-mprincl 
"あなたがイーサネットのケーブルを切断すると、すべてがぼんやりと
かすみはじめました。あなたは一瞬気を失い、少しして意識を取り戻しました。")
		  (dun-replace dun-room-objects gamma-computing-center
			   (append 
			    (nth gamma-computing-center dun-room-objects)
			    dun-inventory))
		  (if (member obj-key dun-inventory)
		      (progn
			(setq dun-inventory (list obj-key))
			(dun-remove-obj-from-room 
			 gamma-computing-center obj-key))
		    (setq dun-inventory nil))
		  (setq dun-current-room computer-room)
		  (setq dun-ethernet nil)
		  (dun-mprincl "Connection closed.（接続終了）")
		  (dun-unix-interface))
	      (if (< objnum 0)
		  (progn
		    (dun-mprincl "斧はこなごなに砕け散ってしまいました。")
		    (dun-remove-obj-from-inven obj-axe))
		(dun-mprincl "斧はそれをこなごなに壊しました。")
		(dun-remove-obj-from-room dun-current-room objnum)))))))))

(defun dun-drive (args)
  (if (not dun-inbus)
      (dun-mprincl "乗り物がなければ、あなたは運転することができません。")
    (dun-mprincl "バスに乗っている間は、方角を入力するだけで運転できます。")))

(defun dun-superb (args)
  (setq dun-mode 'dun-superb))

(defun dun-reg-score ()
  (let (total)
    (setq total 0)
    (dolist (x (nth treasure-room dun-room-objects))
      (setq total (+ total (nth x dun-object-pts))))
    (if (member obj-URINE (nth treasure-room dun-room-objects))
	(setq total 0)) total))

(defun dun-endgame-score ()
  (let (total)
    (setq total 0)
    (dolist (x (nth endgame-treasure-room dun-room-objects))
      (setq total (+ total (nth x dun-object-pts)))) total))

(defun dun-answer (args)
  (if (not dun-correct-answer)
      (dun-mprincl "誰もあなたに答えを求めていないはずです。")
    (setq args (car args))
    (if (not args)
	(dun-mprincl "命令 answer の後ろに答えを記述してください。")
      (if (dun-members args dun-correct-answer)
	  (progn
	    (dun-mprincl "正解。")
	    (if (= dun-lastdir 0)
		(setq dun-current-room (1+ dun-current-room))
	      (setq dun-current-room (- dun-current-room 1)))
	    (setq dun-correct-answer nil))
	(dun-mprincl "その回答は間違っています。")))))

(defun dun-endgame-question ()
(if (not dun-endgame-questions)
    (progn
      (dun-mprincl "あなたへの質問は次の通りです：")
      (dun-mprincl " もう質問はありません。'answer foo' と入力してください。.")
      (setq dun-correct-answer '("foo"))
      (setq dun-question-message "-1"))
  (let (which i newques)
    (setq i 0)
    (setq newques nil)
    (setq which (random (length dun-endgame-questions)))
    (dun-mprincl "あなたへの質問は次の通りです：")
    (setq dun-question-message
        (setq dun-endgame-question (car (nth which 
					  dun-endgame-questions))))
    (dun-mprincl (cdr (assoc dun-question-message dun-endgame-questions-msg)))
    (setq dun-correct-answer (cdr (nth which dun-endgame-questions)))
    (while (< i which)
      (setq newques (append newques (list (nth i dun-endgame-questions))))
      (setq i (1+ i)))
    (setq i (1+ which))
    (while (< i (length dun-endgame-questions))
      (setq newques (append newques (list (nth i dun-endgame-questions))))
      (setq i (1+ i)))
    (setq dun-endgame-questions newques))))

(defun dun-power (args)
  (if (not (= dun-current-room pc-area))
      (dun-mprincl "その操作はここでは出来ません。")
    (if (not dun-floppy)
	(dun-dos-no-disk)
      (dun-dos-interface))))

(defun dun-feed (args)
  (let (objnum)
    (when (setq objnum (dun-objnum-from-args-std args))
      (if (and (= objnum obj-bear) 
	       (member obj-bear (nth dun-current-room dun-room-objects)))
	  (progn
	    (if (not (member obj-food dun-inventory))
		(dun-mprincl "あなたはそれに食べさせるものを何も持っていません。")
	      (dun-drop '("food"))))
	(if (not (or (member objnum (nth dun-current-room dun-room-objects))
		     (member objnum dun-inventory)
		     (member objnum (nth dun-current-room dun-room-silents))))
	    (dun-mprincl "それはここには見あたりません。")
	  (dun-mprincl "あなたはそれに食べさせる(feed)ことはできません。
（名詞には食べさせる相手を指定してください）"))))))


;;;;
;;;;  This section defines various utility functions used
;;;;  by dunnet.
;;;;


;;; Function which takes a verb and a list of other words.  Calls proper
;;; function associated with the verb, and passes along the other words.

(defun dun-doverb (dun-ignore dun-verblist verb rest)
  (if (not verb)
      nil
    (if (member (intern verb) dun-ignore)
	(if (not (car rest)) -1
	  (dun-doverb dun-ignore dun-verblist (car rest) (cdr rest)))
      (if (not (cdr (assq (intern verb) dun-verblist))) -1
	(setq dun-numcmds (1+ dun-numcmds))
	(eval (list (cdr (assq (intern verb) dun-verblist)) (quote rest)))))))


;;; Function to take a string and change it into a list of lowercase words.

(defun dun-listify-string (strin)
  (let (pos ret-list end-pos)
    (setq pos 0)
    (setq ret-list nil)
    (while (setq end-pos (string-match "[ ,:;]" (substring strin pos)))
      (setq end-pos (+ end-pos pos))
      (if (not (= end-pos pos))
	  (setq ret-list (append ret-list (list 
					   (downcase
					    (substring strin pos end-pos))))))
      (setq pos (+ end-pos 1))) ret-list))

(defun dun-listify-string2 (strin)
  (let (pos ret-list end-pos)
    (setq pos 0)
    (setq ret-list nil)
    (while (setq end-pos (string-match " " (substring strin pos)))
      (setq end-pos (+ end-pos pos))
      (if (not (= end-pos pos))
	  (setq ret-list (append ret-list (list 
					   (downcase
					    (substring strin pos end-pos))))))
      (setq pos (+ end-pos 1))) ret-list))

(defun dun-replace (list n number)
  (rplaca (nthcdr n list) number))


;;; Get the first non-ignored word from a list.

(defun dun-firstword (list)
  (if (not (car list))
      nil
    (while (and list (member (intern (car list)) dun-ignore))
      (setq list (cdr list)))
    (car list)))

(defun dun-firstwordl (list)
  (if (not (car list))
      nil
    (while (and list (member (intern (car list)) dun-ignore))
      (setq list (cdr list)))
    list))

;;; parse a line passed in as a string  Call the proper verb with the
;;; rest of the line passed in as a list.

(defun dun-vparse (dun-ignore dun-verblist line)
  (dun-mprinc "\n")
  (setq line-list (dun-listify-string (concat line " ")))
  (dun-doverb dun-ignore dun-verblist (car line-list) (cdr line-list)))

(defun dun-parse2 (dun-ignore dun-verblist line)
  (dun-mprinc "\n")
  (setq line-list (dun-listify-string2 (concat line " ")))
  (dun-doverb dun-ignore dun-verblist (car line-list) (cdr line-list)))

;;; Read a line, in window mode

(defun dun-read-line ()
  (let (line)
    (setq line (read-string ""))
    (dun-mprinc line) line))

;;; Insert something into the window buffer

(defun dun-minsert (string)
  (if (stringp string)
      (insert string)
    (insert (prin1-to-string string))))

;;; Print something out, in window mode

(defun dun-mprinc (string)
  (if (stringp string)
      (insert string)
    (insert (prin1-to-string string))))

;;; In window mode, keep screen from jumping by keeping last line at
;;; the bottom of the screen.

(defun dun-fix-screen ()
  (interactive)
  (forward-line (- 0 (- (window-height) 2 )))
  (set-window-start (selected-window) (point))
  (end-of-buffer))

;;; Insert something into the buffer, followed by newline.

(defun dun-minsertl (string)
  (dun-minsert string)
  (dun-minsert "\n"))

;;; Print something, followed by a newline.

(defun dun-mprincl (string)
  (dun-mprinc string)
  (dun-mprinc "\n"))

;;; Function which will get an object number given the list of
;;; words in the command, except for the verb.

(defun dun-objnum-from-args (obj)
  (let (objnum)
    (setq obj (dun-firstword obj))
    (if (not obj)
	obj-special
      (setq objnum (cdr (assq (intern obj) dun-objnames))))))

(defun dun-objnum-from-args-std (obj)
  (let (result)
  (if (eq (setq result (dun-objnum-from-args obj)) obj-special)
      (dun-mprincl "目的語を与える必要があります。"))
  (if (eq result nil)
      (dun-mprincl "それが何かわかりません。"))
  (if (eq result obj-special)
      nil
    result)))

;;; Take a short room description, and change spaces and slashes to dashes.

(defun dun-space-to-hyphen (string)
  (let (space)
    (if (setq space (string-match "[ /]" string))
	(progn
	  (setq string (concat (substring string 0 space) "-"
			       (substring string (1+ space))))
	  (dun-space-to-hyphen string))
      string)))

;;; Given a unix style pathname, build a list of path components (recursive)

(defun dun-get-path (dirstring startlist)
  (let (slash pos)
    (if (= (length dirstring) 0)
	startlist
      (if (string= (substring dirstring 0 1) "/")
	  (dun-get-path (substring dirstring 1) (append startlist (list "/")))
	(if (not (setq slash (string-match "/" dirstring)))
	    (append startlist (list dirstring))
	  (dun-get-path (substring dirstring (1+ slash))
		    (append startlist
			    (list (substring dirstring 0 slash)))))))))


;;; Is a string a member of a string list?

(defun dun-members (string string-list)
  (let (found)
    (setq found nil)
    (dolist (x string-list)
      (if (string= x string)
	  (setq found t))) found))

;;; Function to put objects in the treasure room.  Also prints current
;;; score to let user know he has scored.

(defun dun-put-objs-in-treas (objlist)
  (let (oscore newscore)
    (setq oscore (dun-reg-score))
    (dun-replace dun-room-objects 0 (append (nth 0 dun-room-objects) objlist))
    (setq newscore (dun-reg-score))
    (if (not (= oscore newscore))
	(dun-score nil))))

;;; Load an encrypted file, and eval it.

(defun dun-load-d (filename)
  (let (old-buffer result)
    (setq result t)
    (setq old-buffer (current-buffer))
    (switch-to-buffer (get-buffer-create "*loadc*"))
    (erase-buffer)
    (condition-case nil
	(insert-file-contents filename)
      (error (setq result nil)))
    (unless (not result)
      (condition-case nil
	  (dun-rot13)
	(error (yank)))
      (eval-current-buffer)
      (kill-buffer (current-buffer)))
      (switch-to-buffer old-buffer)
    result))

;;; Functions to remove an object either from a room, or from inventory.

(defun dun-remove-obj-from-room (room objnum)
  (let (newroom)
    (setq newroom nil)
    (dolist (x (nth room dun-room-objects))
      (if (not (= x objnum))
	  (setq newroom (append newroom (list x)))))
    (rplaca (nthcdr room dun-room-objects) newroom)))

(defun dun-remove-obj-from-inven (objnum)
  (let (new-inven)
    (setq new-inven nil)
    (dolist (x dun-inventory)
      (if (not (= x objnum))
	  (setq new-inven (append new-inven (list x)))))
    (setq dun-inventory new-inven)))


(let ((i 0) (lower "abcdefghijklmnopqrstuvwxyz") upper)
  (setq dun-translate-table (make-vector 256 0))
  (while (< i 256)
    (aset dun-translate-table i i)
    (setq i (1+ i)))
  (setq lower (concat lower lower))
  (setq upper (upcase lower))
  (setq i 0)
  (while (< i 26)
    (aset dun-translate-table (+ ?a i) (aref lower (+ i 13)))
    (aset dun-translate-table (+ ?A i) (aref upper (+ i 13)))
      (setq i (1+ i))))
  
(defun dun-rot13 ()
  (let (str len (i 0))
    (setq str (buffer-substring (point-min) (point-max)))
    (setq len (length str))
    (while (< i len)
      (aset str i (aref dun-translate-table (aref str i)))
      (setq i (1+ i)))
    (erase-buffer)
    (insert str)))

;;;;
;;;; This section defines the globals that are used in dunnet.
;;;;
;;;; IMPORTANT
;;;; All globals which can change must be saved from 'save-game.  Add
;;;; all new globals to bottom of file.

(setq dun-visited '(27))
(setq dun-current-room 1)
(setq dun-exitf nil)
(setq dun-badcd nil)
(defvar dungeon-mode-map nil)
(setq dungeon-mode-map (make-sparse-keymap))
(define-key dungeon-mode-map "\r" 'dun-parse)
(setq dun-question-message nil)
;;---------------XEmacs とそれ以外で処理を変更
(if (boundp 'xemacsp)
; XEmacsの場合
 (defvar dungeon-batch-map
  (let ((map (make-keymap))
        (n 32))
    (while (< 0 (setq n (- n 1)))
      (define-key map (make-string 1 n) 'dungeon-nil))
    (define-key map "\r" 'exit-minibuffer)
    (define-key map "\n" 'exit-minibuffer)
    map)) 
 (progn
; それ以外
 (defvar dungeon-batch-map (make-keymap))
 (if (string= (substring emacs-version 0 2) "18")
    (let (n)
      (setq n 32)
      (while (< 0 (setq n (- n 1)))
	(aset dungeon-batch-map n 'dungeon-nil)))
  (let (n)
    (setq n 32)
    (while (< 0 (setq n (- n 1)))
      (aset (car (cdr dungeon-batch-map)) n 'dungeon-nil))))
 (define-key dungeon-batch-map "\r" 'exit-minibuffer)
 (define-key dungeon-batch-map "\n" 'exit-minibuffer)
 ))
;;-------------------------------
(setq dun-computer nil)
(setq dun-floppy nil)
(setq dun-key-level 0)
(setq dun-hole nil)
(setq dun-correct-answer nil)
(setq dun-lastdir 0)
(setq dun-numsaves 0)
(setq dun-jar nil)
(setq dun-dead nil)
(setq room 0)
(setq dun-numcmds 0)
(setq dun-wizard nil)
(setq dun-endgame-question nil)
(setq dun-logged-in nil)
(setq dungeon-mode 'dungeon)
(setq dun-unix-verbs '((ls . dun-ls) (ftp . dun-ftp) (echo . dun-echo) 
		       (exit . dun-uexit) (cd . dun-cd) (pwd . dun-pwd)
		       (rlogin . dun-rlogin) (uncompress . dun-uncompress)
		       (cat . dun-cat) (zippy . dun-zippy)))

(setq dun-dos-verbs '((dir . dun-dos-dir) (type . dun-dos-type)
		      (exit . dun-dos-exit) (command . dun-dos-spawn)
		      (b: . dun-dos-invd) (c: . dun-dos-invd)
		      (a: . dun-dos-nil)))


(setq dun-batch-mode nil)

(setq dun-cdpath "/usr/toukmond")
(setq dun-cdroom -10)
(setq dun-uncompressed nil)
(setq dun-ethernet t)
(setq dun-restricted 
      '(dun-room-objects dungeon-map dun-rooms 
			 dun-room-silents dun-combination))
(setq dun-ftptype 'ascii)
(setq dun-endgame nil)
(setq dun-gottago t)
(setq dun-black nil)

(setq dun-rooms '(
	      (
"あなたは宝物庫にいます。北(north)にはドアがあります。"
               "Treasure room" "宝物庫"
	       )
	      (
"あなたは舗装されていない道の行き止まりにいます．道は東(east,E)へと続いて
います．その道が遠くの方で２手に分かれているのが見えます．
ここにはとても背の高いヤシの木(palm)が生えており，それらは互いに等間隔で
ならんでいます．"
	       "Dead end" "行き止まり"
	       )
	      (
"あなたは舗装されていない道の途中にいます．あなたの左右には多く木々が
生えています．道は東(east,E)と西(west,E)に続いています．"
               "E/W Dirt road" "東西に続く道"
	       )
	      (
"あなたは２手に分かれた道の分岐点にいます．一方の道は北東(northeast,NE)，
もう一方の道は南東(southeast,SE）へと続いています．ここの地面はとても
やわらかいようです．あなたは西(west,W)へと戻ることもできます．"
               "Fork" "道の分岐点"
	       )
	      (
"あなたは，北東(NE)と南西(SW）へと続く道の途中にいます．"
               "NE/SW road" "北東-南西をつなぐ道"
	       )
	      (
"あなたは道のはずれにいます．あなたの目の前，北東(NE)の方角に建物が
あります．後方の道は南西(SW)へと続いています．"
               "Building front" "建物の前"
	       )
	      (
"あなたは，南東(SE)と北西(NW）へと続く道の途中にいます．"
               "SE/NW road" "南東-北西をつなぐ道"
	       )
	      (
"あなたは道の行き止まりに立っています．戻る道は北西(NW)にあります．"
               "Bear hangout" "熊の住みか"
	       )
	      (
"あなたは古い建物の廊下にいます．東(E)と西(W)に部屋があり，
北(N)と南(S)に外へ通じるドアがあります．"
               "Old Building hallway" "古い建物の廊下"
	       )
	      (
"あなたは郵便物の部屋の中にいます。郵便物(mail)を入れておくための数多くの
大箱(bin)があります。部屋の出口は西(W)です。"
               "Mailroom" "郵便物の部屋"
	       )
	      (
"あなたは計算機室の中にいます。装置の大部分は取り除かれているようです。
あなたの目の前には、VAX 11/780 のコンピュータ(computer)があります。
しかし、コンピュータのキャビネットのひとつが広く開いています。
機械の前面の上には次のように書かれています。
              「この VAX の名前は 'pokey'。」
コンソールを用いて入力するには、動詞 'type' を使ってください。
出口は東(E)にあります。"
               "Computer room" "計算機室"
	       )
	      (
"あなたは古い建物の後にある牧草地にいます。小さな小道が西(W)へと続いて
います。南(S)にはドアがあります。"
               "Meadow" "牧草地"
	       )
	      (
"あなたは東(E)にドアがある、石でできた丸い部屋の中にいます。
壁には「receiving room」と読める文字が書かれている。"
               "Receiving room" "受信ルーム"
	       )
	      (
"あなたは北(N)へと続く廊下の南(S)の端にいます。
東(E)と西(W)に部屋があります。"
               "Northbound Hallway" "北へ続く廊下"
	       )
	      (
"あなたはサウナにいます。壁にあるダイアル(dial)以外には部屋に何も
ありません。ドアは西(W)の外へと導きます。"
               "Sauna" "サウナ"
               )
	      (
"あなたは南(S)と北(N)に続く廊下の北の端にいます。あなたは南(S)に戻ることも、
東(E)にある部屋へと出ることもできます。"
               "End of N/S Hallway" "北-南をつなぐ廊下の端"
	       )
	      (
"あなたは古いウエイトルームにいます。全てのトレーニング機器は故障して
いるか、あるいは完全に壊れています。西(W)に外へ出るドアがあり、
床に開いた穴(hole)へ降りる(down,D)ためのハシゴ(ladder)があります。"
               "Weight room" "ウエイトルーム"                ;16
	       )
	      (
"あなたは、全てが似通った、曲がりくねった細い道の迷路にいます。
ここの地面の上にはボタン(button)があります。"
               "Maze button room" "迷路：ボタンルーム"
	       )
	      (
"あなたは、全てが似通った、曲がりくねった細い道の迷路にいます。"
               "Maze" "迷路"
	       )
	      (
"あなたは、全てが似通った、曲がりくねった道の迷路にいます。"
               "Maze" "迷路"    ;19
	       )
	      (
"あなたは、全てが類似した、曲がりくねった細い道の迷路にいます。"
               "Maze" "迷路"
	       )
	      (
"あなたは、全てが似通った、細くて曲がりくねった迷路にいます。"
               "Maze" "迷路"   ;21
	       )
	      (
"あなたは、全てが似通った、曲がりくねった細い路の迷路にいます。"
               "Maze" "迷路"   ;22
	       )
	      (
"あなたは健康フィットネスセンターの受付ルームにいます。
この場所は最近略奪されたようで、何も残っていません。
南(S)に外へ出るドア、南東(SE)に迷路への入口があります。"
               "Reception area" "受付ルーム"
	       )
	      (
"あなたは北(N)にある健康フィットネスセンターだったであろう大きな建物の
外にいます。道は南(S)へ続いています。"
               "Health Club front" "ヘルスクラブの前"
	       )
	      (
"あなたは湖(lake)の北側(N)にいます。湖の向こう岸には、洞窟へと続く道が
あるのが見えます。水はとても深いようです。"
               "Lakefront North" "湖の北側の岸"
	       )
	      (
"あなたは湖(lake)の南側(S)にいます。道は南(S)に続いています。"
               "Lakefront South" "湖の南側の岸"
	       )
	      (
"あなたは道から少し離れた、隠されたエリアにいます。
北東(NE)にある雑木林の向こうに、熊の住みかが見えます。"
               "Hidden area" "隠されたエリア"
	       )
	      (
"洞窟の入り口は南(S)にあります。北(N)は、深い湖へ向かう道です。
すぐそばの地面にはシュート(chute)があり、そこに看板があります。
そこには「得点を得るには宝物をここへ入れよ(put)。」と書かれています。"
               "Cave Entrance" "洞窟の入り口"                     ;28
	       )
	      (
"あなたは山の中につくられた、霧の立ちこめるしめっぽい部屋にいます。
北(N)には岩崩れの後があります。東(E)に暗闇へと続く通路があります。"              ;29
               "Misty Room" "霧が立ちこめた部屋"
	       )
	      (
"あなたは東(E),西(W)に続く通路にいます。ここの壁は様々な色の岩で
できていて、とても綺麗です。"
               "Cave E/W passage" "東-西へ続く洞窟の通路"                  ;30
	       )
	      (
"あなたは洞窟の分かれ道にいます。北(N)、南(S)の他に、西(W)へも
行けます。"
               "N/S/W Junction" "北・南・西の分かれ道"                    ;31
	       )
	      (
"あなたは南-北(S/N)にのびる通路の北の端にいます。ここから下(D)へと
降りるための階段があります。西(W)に行くためのドアがあります。"
               "North end of cave passage" "洞窟の通路の北端"        ;32
	       )
	      (
"あなたは南-北(S/N)にのびる通路の南の端にいます。ここの床には穴(hole)が
あいています。ちょうどあなたが入るのにあう大きさの穴です。"
               "South end of cave passage" "洞窟の通路の南端"        ;33
	       )
	      (
"あなた労働者のベッドルームのような場所にいます。部屋の中央には
クイーンサイズのベッド(bed)があり、壁には絵(painting)がかけられています。
南(S)には別の部屋へのドアがあり、上(U)と下(D)へ行くための階段が
あります。"
               "Bedroom" "ベッドルーム"                         ;34
	       )
	      (
"あなたは洞窟の中にある労働者のためのバスルームにいます。
小便器(urinal)が壁についています。そして、反対側の壁では
シンクで使うためのパイプ(pipe)が剥き出しになっています。
北(N)にはベッドルームがあります。"
               "Bathroom" "バスルーム"       ;35
	       )
	      (
"これは小便器のためのマーカーです。 ゲームのプレイヤーは見ることができま
せんが、ここにはモノがたまります。"
               "Urinal" "小便器"         ;36
	       )
	      (
"あなたは北東-南西(NE/SW)の通路の北東(NE)の端にいます。
階段はよく見えない上(U)の階へとつづいています。"
               "NE end of NE/SW cave passage" "北東-南西の坑道の北東の端"      ;37
	       )
	      (
"あなたは北東-南西(NE/SW)の通路と東西(E/W)の通路が交わる場所にいます。"
               "NE/SW-E/W junction" "坑道の交差点"                     ;38
	       )
	      (
"あなたは北東-南西(NE/SW)の通路の南西(SW)の端にいます。"
               "SW end of NE/SW cave passage" "北東-南西の坑道の南西の端"       ;39
	       )
	      (
"あなたは東-西(E/W)の通路の東(E)の端にいます。階段は上(U)にある部屋へと
つづいています。"
               "East end of E/W cave passage" "東-西の坑道の東の端"       ;40
	       )
	      (
"あなたは東-西(E/W)の通路の西(W)の端にいます。ここの地面には穴があいて
おり、下(D)にある見えない場所へとつづいています。"
               "West end of E/W cave passage" "東-西の坑道の西の端"      ;41
	       )
	      (
"あなたは、中央にていてつの形をした大きな石（boulder）があるだけの
がらんとした部屋にいます。ここから下(D)へ行く階段があります。"     ;42
               "Horseshoe boulder room" "ていてつ状の石のある部屋"
	       )
	      (
"あなたはまったく何もない部屋の中にいます。北(N)へのドアがあります。"
               "Empty room" "何もない部屋"                     ;43
	       )
	      (
"あなたは何もない部屋にいます。この部屋の石(stone)は青色で塗られています。
ドアの奥は東(E)と南(S)へとつづきます。"  ;44
               "Blue room" "青い部屋"
	       )
	      (
"
あなたは何もない部屋にいます。この部屋の石(stone)は黄色で塗られています。
ドアの奥は南(S)と西(W)へとつづきます。"    ;45
               "Yellow room" "黄色い部屋"
	       )
	      (
"あなたは何もない部屋にいます。この部屋の石(stone)は赤色で塗られています。
ドアの奥は西(W)と北(N)へとつづきます。"
               "Red room" "赤い部屋"                                ;46
	       )
	      (
"あなたは、北-南(N/S)をつなぐ長い廊下の中間地点にいます。"     ;47
               "Long n/s hallway" "北-南の長い廊下の中央"
	       )
	      (
"あなたは、北-南(N/S)をつなぐ長い廊下の、北端へ向かって3/4ほど進んだ
位置にいます。"
               "3/4 north" "3/4北へ進んだ地点"                               ;48
	       )
	      (
"あなたは、北-南(N/S)をつなぐ長い廊下の北の端にいます。
階段が上(U)へつづいています。"
               "North end of long hallway" "長い廊下の北の端"                ;49
	       )
	      (
"あなたは、北-南(N/S)をつなぐ長い廊下の、南端へ向かって3/4ほど進んだ
位置にいます。"
               "3/4 south" "3/4南へいった地点"                                ;50
	       )
	      (
"あなたは、北-南(N/S)をつなぐ長い廊下の南の端にいます。
南(S)に穴があります。"
               "South end of long hallway" "長い廊下の南の端"                ;51
	       )
	      (
"あなたは上-下(U/D)につづく吹き抜けの階段の踊り場にいます。"
               "Stair landing" "階段の踊り場"                            ;52
	       )
	      (
"あなたは上下(U/D)につづく階段の途中にいます。"
               "Up/down staircase" "上下へつづく階段"                        ;53
	       )
	      (
"あなたは下(D)へとつづく階段の一番上にいます。
作業路(crawlway)が北東(NE)へつづいています。"
               "Top of staircase." "階段の頂上"                       ;54
	       )
	      (
"あなたは、作業路にいます。ここから北東(NE)または南西(SW)に行けます。"
               "NE crawlway" "作業路の北東"                             ;55
	       )
	      (
"あなたは小さな作業スペースの中にいます。ここの地面には大きな穴が
あいています。そして、小さな通路が南西(SW)に続いています。"
               "Small crawlspace" "作業スペース"                        ;56
	       )
	      (
"あなたは Gamma コンピュータセンターにいます。
ここでは IBM 3090/600s という機種のコンピュータ(computer)がファンの音を
ブンブン鳴らしながら稼動しています。ユニットのひとつからイーサネットの
ケーブル(cable)が出ており、それが天井へとのびています。
あなたがコマンドをタイプできるような操作機器はここにはありません。"
               "Gamma computing center" "Gamma コンピュータセンター"                  ;57
	       )
	      (
"あなたは郵便局の跡にいます。建物の正面に郵便受け(mail)がありますが、
しかしあなたはそれがどこへ届くか見ることはできません。
東(E)へと戻る通路と、北(N)へつづく道があります。"
               "Post office" "郵便局"                            ;58
	       )
	      (
"あなたはメイン通り(Main Street)とカエデ通り(Maple Ave)の交差点にいます。
メイン通りは北(N)から南(S)へとはしっており、カエデ通りは東(E)の遠くへ
向かってはしっています。あなたが北や南に目をやるとたくさんの交差点が
見えます。しかし、過去にあったであろうすべての建物はなくなっています。
道路標識(sign)以外、何も残っていません。
北西(NW)には、建物を守るかのような門(gate)があります。"
               "Main-Maple intersection" "メイン-カエデ交差点"                      ;59
	       )
	      (
"あなたは、メイン通り(Main Street)とオークの木通り(Oaktree Ave)の西の端との
交差点にいます。"
               "Main-Oaktree intersection" "メイン-オークの木交差点"  ;60
	       )
	      (
"あなたは、メイン通り(Main Street)とバーモント通り(Vermont Ave)の西の端との
交差点にいます。"
               "Main-Vermont intersection" "メイン-バーモント交差点" ;61
	       )
	      (
"あなたは、メイン通り(Main Street)の北の端とイチジク通り(Sycamore Ave)の
西の端とをつなぐ地点にいます。" ;62
               "Main-Sycamore intersection" "メイン-イチジク交差点"
	       )
	      (
"あなたは第１通り(First Street)の南の端とカエデ通り(Maple Ave)の交差点
にいます。" ;63
               "First-Maple intersection" "第１-カエデ交差点"
	       )
	      (
"あなたは第１通り(First Street)とオークの木通り(Oaktree Ave)の交差点にいます。"  ;64
               "First-Oaktree intersection" "第１-オークの木交差点"
	       )
	      (
"あなたは第１通り(First Street)とバーモント通り(Vermont Ave)の交差点
にいます。"  ;65
               "First-Vermont intersection" "第１-バーモント交差点"
	       )
	      (
"あなたは第１通り(First Street)の北の端とイチジク通り(Sycamore Ave)の
交差点にいます。"  ;66
               "First-Sycamore intersection" "第１-イチジク交差点"
	       )
	      (
"あなたは第２通り(Second Street)の南の端とカエデ通り(Maple Ave)の交差点に
います。" ;67
               "Second-Maple intersection" "第２-カエデ交差点"
	       )
	      (
"あなたは第２通り(Second Street)とオークの木通り(Oaktree Ave)の交差点にいます。"  ;68
               "Second-Oaktree intersection" "第２-オークの木交差点"
	       )
	      (
"あなたは第２通り(Second Street)とバーモント通り(Vermont Ave)の交差点
にいます。"  ;69
               "Second-Vermont intersection" "第２-バーモント交差点"
	       )
	      (
"あなたは第２通り(Second Street)と北の端とイチジク通り(Sycamore Ave)の
交差点にいます。"  ;70
               "Second-Sycamore intersection" "第２-イチジク交差点"
	       )
	      (
"あなたは、第３通り(Third Street)の南の端とカエデ通り(Maple Ave)の交差点
にいます。"  ;71
               "Third-Maple intersection" "第３-カエデ交差点"
	       )
	      (
"あなたは第３通り(Third Street)とオークの木通り(Oaktree Ave)の交差点にいます。"  ;72
               "Third-Oaktree intersection" "第３-オークの木交差点"
	       )
	      (
"あなたは第３通り(Third Street)とバーモント通り(Vermont Ave)の交差点
にいます。"  ;73
               "Third-Vermont intersection" "第３-バーモント交差点"
	       )
	      (
"あなたは第３通り(Third Street)と北の端とイチジク通り(Sycamore Ave)の
交差点にいます。"  ;74
               "Third-Sycamore intersection" "第３-イチジク交差点"
	       )
	      (
"あなたは第４通り(Fourth Street)と南の端とカエデ通り(Maple Ave)の交差点
にいます。"  ;75
               "Fourth-Maple intersection" "第４-カエデ交差点"
	       )
	      (
"あなたは第４通り(Fourth Street)とオークの木通り(Oaktree Ave)の交差点にいます。"  ;76
               "Fourth-Oaktree intersection" "第４-オークの木交差点"
	       )
	      (
"あなたは第４通り(Fourth Street)とバーモント通り(Vermont Ave)の交差点
にいます。"  ;77
               "Fourth-Vermont intersection" "第４-バーモント交差点"
	       )
	      (
"あなたは第４通り(Fourth Street)と北の端とイチジク通り(Sycamore Ave)の
交差点にいます。"  ;78
               "Fourth-Sycamore intersection" "第４-イチジク交差点"
	       )
	      (
"あなたは第５通り(Fifth Street)の南の端とカエデ通り(Maple Ave)の
東の端とをつなぐ地点にいます。"  ;79
               "Fifth-Maple intersection" "第５-カエデ交差点"
	       )
	      (
"あなたは第５通り(Fifth Street)とオークの木通り(Orktree Ave)の東の端との
交差点にいます。東(E)は切り立った崖(cliff)です。"
               "Fifth-Oaktree intersection" "第５-オークの木交差点" ;80
	       )
	      (
"あなたは第５通り(Fifth Street)とバーモント通り(Vermont Ave)の東の端との
交差点にいます。"
               "Fifth-Vermont intersection" "第５-バーモント交差点" ;81
	       )
	      (
"あなたは第５通り(Fifth Street)の南の端とイチジク通り(Sycamore Ave)の
東の端とをつなぐ地点にいます。"
               "Fifth-Sycamore intersection" "第５-イチジク交差点" ;82
	       )
	      (
"あなたは自然歴史博物館(Museum of Natural History)の前にいます。
北(N)のドアは建物の中へとあなたを導きます。道は南東(SE)へつづいています。"
               "Museum entrance" "博物館の入り口"                 ;83
	       )
	      (
"あなたは自然歴史博物館のメイン・ロビーにいます。
部屋の中央に巨大な恐竜(dinosaur)のガイコツがあります。
南(S)と東(E)にドアがあります。 "
               "Museum lobby" "博物館のロビー"                    ;84
	       )
	      (
"あなたは地質学の展示室にいます。展示されていたはずのものは全て失われて
しまっています。東(E)と西(W)と北(N)に部屋があります。"
               "Geological display" "地質学の展示室"              ;85
	       )
	      (
"あなたは海洋生物のエリアにいます。部屋は水槽(tank)で満たされています。
それは見たところでは餌がなくなったために死んだと思われる魚(fish)の死骸で
満たされています。南(S)と東(E)にドアがあります。"
               "Marine life area" "海洋生物のエリア"                  ;86
	       )
	      (
"あなたは博物館の管理室のひとつにいます。壁の上に 「 BL 」と書かれた
ラベルのついたスイッチ(switch)があります。西(W)と北(N)へのドアがあります。"
               "Maintenance room" "管理室"                  ;87
	       )
	      (
"あなたは、博物学について子どもたちに教えるのに使われていた教室にいます。
黒板(blackboard)には「 子どもは下の階へ行くのは許可されていません」と
書いてあります。ここには東(E)へのドアがあり、その上には出口(exit)と
表示されています。もうひとつのドアが西(W)にあります。"
               "Classroom" "教室"                         ;88
	       )
	      (
"あなたはバーモント通りの地下鉄の駅にいます。電車(train)が出発を待って
停車しています。"
               "Vermont station" "バーモント駅"                   ;89
	       )
	      (
"あなたは博物館の地下鉄の駅にいます。通路が北(N)へとつづいています。"
               "Museum station" "博物館駅"                    ;90
	       )
	      (
"あなたは北(N)-南(S)をむすぶトンネルの中にいます。"
               "N/S tunnel" "北-南のトンネル"                         ;91
	       )
	      (
"あなたは北(N)-南(S)をむすぶトンネルの北の端にいます。
上下(U/D)へ移動するための階段があります。
ここにはゴミ処理機(garbage disposal)があります。"
               "North end of N/S tunnel" "北-南のトンネルの北の端"            ;92
               )
	      (
"あなたは地下鉄の駅のそばの階段の最上層部にいます。西(W)にドアがあります。"
               "Top of subway stairs" "地下鉄の階段の上"          ;93
	       )
	      (
"あなたは地下鉄の駅のそばの階段の最下層部にいます。北東(NE)に
部屋があります。"
               "Bottom of subway stairs" "地下鉄の駅の底"      ;94
	       )
	      (
"あなたはもうひとつの計算機室にいます。ここにはあなたが今までに見たこと
もないような巨大なコンピュータ(computer)があります。
それには製造元の名前などは書かれていませんが、次の掲示がなされています。
              「このマシンの名前は 'endgame'」
出口は南西(SW)にあります。あなたがコマンドをタイプできるような操作機器は
ここにはありません。"
               "Endgame computer room" "Endgame計算機室"        ;95
	       )
	      (
"あなたは、南(S)-北(N)をつなぐ通路にいます。"
               "Endgame N/S hallway" "Endgameの南-北の通路"          ;96
	       )
	      (
"あなたは第１質問ルームにつきました。あなたがここを切り抜けるためには、
正確に質問に答えなければなりません。質問に答えるには(answer)を使って
ください（例 ：answer foo)"
               "Question room 1" "第１質問ルーム"             ;97
	       )
	      (
"あなたは、南(S)-北(N)をつなぐ通路にいます。"
               "Endgame N/S hallway" "Endgameの南-北の通路"          ;98
	       )
	      (
"あなたは第２質問ルームにいます。"
               "Question room 2"  "第２質問ルーム"             ;99
	       )
	      (
"あなたは、南(S)-北(N)をつなぐ通路にいます。"
               "Endgame N/S hallway" "Endgameの南-北の通路"          ;100
	       )
	      (
"あなたは第３質問ルームにいます。"
               "Question room 3"  "第３質問ルーム"              ;101
	       )
	      (
"あなたは endgame の宝物庫にいます。北(N)へのドアがあり、通路は南(S)へ
つづいています。"
               "Endgame treasure room" "Endgameの宝物庫"        ;102
	       )
	      (
"あなたは勝利者の部屋にいます。南(S)にドアがあります。"
               "Winner's room" "勝利者の部屋"                ;103
	       )
	      (
"あなたは行き止まりにいます。ここの床にはパソコン(PC)があります。
そのパソコンには表示がなされていました。それは次のように読めます。
  「このパソコンをリセット（電源の入れ直し, reset ）せよ。」
穴は北(N)へつづいています。"
               "PC area"   "パソコンエリア"                    ;104
               )            
))

(setq dun-light-rooms '(0 1 2 3 4 5 6 7 8 9 10 11 12 13 24 25 26 27 28 58 59
		     60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76
		     77 78 79 80 81 82 83))

(setq dun-verblist '((die . dun-die) (ne . dun-ne) (north . dun-n) 
		     (south . dun-s) (east . dun-e) (west . dun-w)
		     (u . dun-up) (d . dun-down) (i . dun-inven)
		     (inventory . dun-inven) (look . dun-examine) (n . dun-n)
		     (s . dun-s) (e . dun-e) (w . dun-w) (se . dun-se)
		     (nw . dun-nw) (sw . dun-sw) (up . dun-up) 
		     (down . dun-down) (in . dun-in) (out . dun-out)
		     (go . dun-go) (drop . dun-drop) (southeast . dun-se)
		     (southwest . dun-sw) (northeast . dun-ne)
		     (northwest . dun-nw) (save . dun-save-game)
		     (restore . dun-restore) (long . dun-long) (dig . dun-dig)
		     (shake . dun-shake) (wave . dun-shake)
		     (examine . dun-examine) (describe . dun-examine) 
		     (climb . dun-climb) (eat . dun-eat) (put . dun-put)
		     (type . dun-type)  (insert . dun-put)
		     (score . dun-score) (help . dun-help) 
                     (helpeng . dun-helpeng) (helpunix . dun-helpunix) 
                     (helpverb . dun-helpverb)
                     (helpdos . dun-helpdos) (quit . dun-quit) 
		     (read . dun-examine) (verbose . dun-long) 
		     (urinate . dun-piss) (piss . dun-piss)
		     (flush . dun-flush) (sleep . dun-sleep) (lie . dun-sleep) 
		     (x . dun-examine) (break . dun-break) (drive . dun-drive)
		     (board . dun-in) (enter . dun-in) (turn . dun-turn)
		     (press . dun-press) (push . dun-press) (swim . dun-swim)
		     (on . dun-in) (off . dun-out) (chop . dun-break)
		     (switch . dun-press) (cut . dun-break) (exit . dun-out)
		     (leave . dun-out) (reset . dun-power) (flick . dun-press)
		     (superb . dun-superb) (answer . dun-answer)
		     (throw . dun-drop) (l . dun-examine) (take . dun-take)
		     (get . dun-take) (feed . dun-feed)))

(setq dun-inbus nil)
(setq dun-nomail nil)
(setq dun-ignore '(the to at))
(setq dun-mode 'moby)
(setq dun-sauna-level 0)

(defconst north 0)
(defconst south 1)
(defconst east 2)
(defconst west 3)
(defconst northeast 4)
(defconst southeast 5)
(defconst northwest 6)
(defconst southwest 7)
(defconst up 8)
(defconst down 9)
(defconst in 10)
(defconst out 11)

(setq dungeon-map '(
;		      no  so  ea  we  ne  se  nw  sw  up  do  in  ot
		    ( 96  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;0
		    ( -1  -1   2  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;1
		    ( -1  -1   3   1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;2
		    ( -1  -1  -1   2   4   6  -1  -1  -1  -1  -1  -1 ) ;3
		    ( -1  -1  -1  -1   5  -1  -1   3  -1  -1  -1  -1 ) ;4
		    ( -1  -1  -1  -1  255 -1  -1   4  -1  -1  255 -1 ) ;5
		    ( -1  -1  -1  -1  -1   7   3  -1  -1  -1  -1  -1 ) ;6
		    ( -1  -1  -1  -1  -1  255  6  27  -1  -1  -1  -1 ) ;7
		    ( 255  5   9  10  -1  -1  -1   5  -1  -1  -1   5 ) ;8
		    ( -1  -1  -1   8  -1  -1  -1  -1  -1  -1  -1  -1 ) ;9
		    ( -1  -1   8  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;10
		    ( -1   8  -1  58  -1  -1  -1  -1  -1  -1  -1  -1 ) ;11
		    ( -1  -1  13  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;12
		    ( 15  -1  14  12  -1  -1  -1  -1  -1  -1  -1  -1 ) ;13
		    ( -1  -1  -1  13  -1  -1  -1  -1  -1  -1  -1  -1 ) ;14
		    ( -1  13  16  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;15
		    ( -1  -1  -1  15  -1  -1  -1  -1  -1  17  16  -1 ) ;16
		    ( -1  -1  17  17  17  17 255  17 255  17  -1  -1 ) ;17
		    ( 18  18  18  18  18  -1  18  18  19  18  -1  -1 ) ;18
		    ( -1  18  18  19  19  20  19  19  -1  18  -1  -1 ) ;19
		    ( -1  -1  -1  18  -1  -1  -1  -1  -1  21  -1  -1 ) ;20
		    ( -1  -1  -1  -1  -1  20  22  -1  -1  -1  -1  -1 ) ;21
		    ( 18  18  18  18  16  18  23  18  18  18  18  18 ) ;22
		    ( -1 255  -1  -1  -1  19  -1  -1  -1  -1  -1  -1 ) ;23
		    ( 23  25  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;24
		    ( 24 255  -1  -1  -1  -1  -1  -1  -1  -1 255  -1 ) ;25
		    (255  28  -1  -1  -1  -1  -1  -1  -1  -1 255  -1 ) ;26
		    ( -1  -1  -1  -1   7  -1  -1  -1  -1  -1  -1  -1 ) ;27
		    ( 26 255  -1  -1  -1  -1  -1  -1  -1  -1  255 -1 ) ;28
		    ( -1  -1  30  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;29
		    ( -1  -1  31  29  -1  -1  -1  -1  -1  -1  -1  -1 ) ;30
		    ( 32  33  -1  30  -1  -1  -1  -1  -1  -1  -1  -1 ) ;31
		    ( -1  31  -1  255 -1  -1  -1  -1  -1  34  -1  -1 ) ;32
		    ( 31  -1  -1  -1  -1  -1  -1  -1  -1  35  -1  -1 ) ;33
		    ( -1  35  -1  -1  -1  -1  -1  -1  32  37  -1  -1 ) ;34
		    ( 34  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;35
		    ( -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;36
		    ( -1  -1  -1  -1  -1  -1  -1  38  34  -1  -1  -1 ) ;37
		    ( -1  -1  40  41  37  -1  -1  39  -1  -1  -1  -1 ) ;38
		    ( -1  -1  -1  -1  38  -1  -1  -1  -1  -1  -1  -1 ) ;39
		    ( -1  -1  -1  38  -1  -1  -1  -1  42  -1  -1  -1 ) ;40
		    ( -1  -1  38  -1  -1  -1  -1  -1  -1  43  -1  -1 ) ;41
		    ( -1  -1  -1  -1  -1  -1  -1  -1  -1  40  -1  -1 ) ;42
		    ( 44  -1  46  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;43
		    ( -1  43  45  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;44
		    ( -1  46  -1  44  -1  -1  -1  -1  -1  -1  -1  -1 ) ;45
		    ( 45  -1  -1  43  -1  -1  -1  -1  -1  255 -1  -1 ) ;46
		    ( 48  50  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;47
		    ( 49  47  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;48
		    ( -1  48  -1  -1  -1  -1  -1  -1  52  -1  -1  -1 ) ;49
		    ( 47  51  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;50
		    ( 50  104 -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;51
		    ( -1  -1  -1  -1  -1  -1  -1  -1  53  49  -1  -1 ) ;52
		    ( -1  -1  -1  -1  -1  -1  -1  -1  54  52  -1  -1 ) ;53
		    ( -1  -1  -1  -1  55  -1  -1  -1  -1  53  -1  -1 ) ;54
		    ( -1  -1  -1  -1  56  -1  -1  54  -1  -1  -1  54 ) ;55
		    ( -1  -1  -1  -1  -1  -1  -1  55  -1  31  -1  -1 ) ;56
		    ( -1  -1  32  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;57
		    ( 59  -1  11  -1  -1  -1  -1  -1  -1  -1  255 255) ;58
		    ( 60  58  63  -1  -1  -1  255 -1  -1  -1  255 255) ;59
		    ( 61  59  64  -1  -1  -1  -1  -1  -1  -1  255 255) ;60
		    ( 62  60  65  -1  -1  -1  -1  -1  -1  -1  255 255) ;61
		    ( -1  61  66  -1  -1  -1  -1  -1  -1  -1  255 255) ;62
		    ( 64  -1  67  59  -1  -1  -1  -1  -1  -1  255 255) ;63
		    ( 65  63  68  60  -1  -1  -1  -1  -1  -1  255 255) ;64
		    ( 66  64  69  61  -1  -1  -1  -1  -1  -1  255 255) ;65
		    ( -1  65  70  62  -1  -1  -1  -1  -1  -1  255 255) ;66
		    ( 68  -1  71  63  -1  -1  -1  -1  -1  -1  255 255) ;67
		    ( 69  67  72  64  -1  -1  -1  -1  -1  -1  255 255) ;68
		    ( 70  68  73  65  -1  -1  -1  -1  -1  -1  255 255) ;69
		    ( -1  69  74  66  -1  -1  -1  -1  -1  -1  255 255) ;70
		    ( 72  -1  75  67  -1  -1  -1  -1  -1  -1  255 255) ;71
		    ( 73  71  76  68  -1  -1  -1  -1  -1  -1  255 255) ;72
		    ( 74  72  77  69  -1  -1  -1  -1  -1  -1  255 255) ;73
		    ( -1  73  78  70  -1  -1  -1  -1  -1  -1  255 255) ;74
		    ( 76  -1  79  71  -1  -1  -1  -1  -1  -1  255 255) ;75
		    ( 77  75  80  72  -1  -1  -1  -1  -1  -1  255 255) ;76
		    ( 78  76  81  73  -1  -1  -1  -1  -1  -1  255 255) ;77
		    ( -1  77  82  74  -1  -1  -1  -1  -1  -1  255 255) ;78
		    ( 80  -1  -1  75  -1  -1  -1  -1  -1  -1  255 255) ;79
		    ( 81  79  255 76  -1  -1  -1  -1  -1  -1  255 255) ;80
		    ( 82  80  -1  77  -1  -1  -1  -1  -1  -1  255 255) ;81
		    ( -1  81  -1  78  -1  -1  -1  -1  -1  -1  255 255) ;82
		    ( 84  -1  -1  -1  -1  59  -1  -1  -1  -1  255 255) ;83
		    ( -1  83  85  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;84
		    ( 86  -1  87  84  -1  -1  -1  -1  -1  -1  -1  -1 ) ;85
		    ( -1  85  88  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;86
		    ( 88  -1  -1  85  -1  -1  -1  -1  -1  -1  -1  -1 ) ;87
		    ( -1  87 255  86  -1  -1  -1  -1  -1  -1  -1  -1 ) ;88
		    ( -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 255  -1 ) ;89
		    ( 91  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;90
		    ( 92  90  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;91
		    ( -1  91  -1  -1  -1  -1  -1  -1  93  94  -1  -1 ) ;92
		    ( -1  -1  -1  88  -1  -1  -1  -1  -1  92  -1  -1 ) ;93
		    ( -1  -1  -1  -1  95  -1  -1  -1  92  -1  -1  -1 ) ;94
		    ( -1  -1  -1  -1  -1  -1  -1  94  -1  -1  -1  -1 ) ;95
		    ( 97   0  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;96
		    ( -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;97
		    ( 99  97  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;98
		    ( -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;99
		    ( 101 99  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;100
		    ( -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;101
		    ( 103 101 -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;102
		    ( -1  102 -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;103
		    ( 51  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ) ;104
		    )
;		      no  so  ea  we  ne  se  nw  sw  up  do  in  ot
)


;;; How the user references *all* objects, permanent and regular.
(setq dun-objnames '(
		 (shovel . 0) 
		 (lamp . 1)
		 (cpu . 2) (board . 2) (card . 2) (chip . 2)
		 (food . 3) 
		 (key . 4) 
		 (paper . 5) (slip . 5)
		 (rms . 6) (statue . 6) (statuette . 6)  (stallman . 6)
		 (diamond . 7)
		 (weight . 8)
		 (life . 9) (preserver . 9)
		 (bracelet . 10) (emerald . 10) 
		 (gold . 11)
		 (platinum . 12)
		 (towel . 13) (beach . 13)
		 (axe . 14)
		 (silver . 15)
		 (license . 16)
		 (coins . 17)
		 (egg . 18)
		 (jar . 19)
		 (bone . 20)
		 (acid . 21) (nitric . 21)
		 (glycerine . 22)
		 (ruby . 23)
		 (amethyst . 24) 
		 (mona . 25)
		 (bill . 26) 
		 (floppy . 27) (disk . 27)
		 
		 (boulder . -1)
		 (tree . -2) (trees . -2) (palm . -2) 
		 (bear . -3)
		 (bin . -4) (bins . -4)
		 (cabinet . -5) (computer . -5) (vax . -5) (ibm . -5) 
		 (protoplasm . -6)
		 (dial . -7) 
		 (button . -8) 
		 (chute . -9) 
		 (painting . -10)
		 (bed . -11)
		 (urinal . -12)
		 (URINE . -13)
		 (pipes . -14) (pipe . -14) 
		 (box . -15) (slit . -15) 
		 (cable . -16) (ethernet . -16) 
		 (mail . -17) (drop . -17)
		 (bus . -18)
		 (gate . -19)
		 (cliff . -20) 
		 (skeleton . -21) (dinosaur . -21)
		 (fish . -22)
		 (tanks . -23) (tank . -23)
		 (switch . -24)
		 (blackboard . -25)
		 (disposal . -26) (garbage . -26)
		 (ladder . -27)
		 (subway . -28) (train . -28) 
		 (pc . -29) (drive . -29) (coconut . -30) (coconuts . -30)
		 (lake . -32) (water . -32)
))

(dolist (x dun-objnames)
  (let (name)
    (setq name (concat "obj-" (prin1-to-string (car x))))
    (eval (list 'defconst (intern name) (cdr x)))))

(defconst obj-special 255)

;;; The initial setup of what objects are in each room.
;;; Regular objects have whole numbers lower than 255.
;;; Objects that cannot be taken but might move and are
;;; described during room description are negative.
;;; Stuff that is described and might change are 255, and are
;;; handled specially by 'dun-describe-room. 

(setq dun-room-objects (list nil 

        (list obj-shovel)                     ;; treasure-room
        (list obj-boulder)                    ;; dead-end
        nil nil nil
        (list obj-food)                       ;; se-nw-road
        (list obj-bear)                       ;; bear-hangout
        nil nil
        (list obj-special)                    ;; computer-room
        (list obj-lamp obj-license obj-silver);; meadow
        nil nil
        (list obj-special)                    ;; sauna
        nil 
        (list obj-weight obj-life)            ;; weight-room
        nil nil
        (list obj-rms obj-floppy)             ;; thirsty-maze
        nil nil nil nil nil nil nil 
        (list obj-emerald)                    ;; hidden-area
        nil
        (list obj-gold)                       ;; misty-room
        nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil
        (list obj-towel obj-special)          ;; red-room
        nil nil nil nil nil
        (list obj-box)                        ;; stair-landing
        nil nil nil
        (list obj-axe)                        ;; smal-crawlspace
        nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil
        nil nil nil nil nil
        (list obj-special)                    ;; fourth-vermont-intersection
        nil nil
        (list obj-coins)                      ;; fifth-oaktree-intersection
        nil
        (list obj-bus)                        ;; fifth-sycamore-intersection
        nil
        (list obj-bone)                       ;; museum-lobby
        nil
        (list obj-jar obj-special obj-ruby)   ;; marine-life-area
        (list obj-nitric)                     ;; maintenance-room
        (list obj-glycerine)                  ;; classroom
        nil nil nil nil nil
        (list obj-amethyst)                   ;; bottom-of-subway-stairs
        nil nil
        (list obj-special)                    ;; question-room-1
        nil
        (list obj-special)                    ;; question-room-2
        nil
        (list obj-special)                    ;; question-room-three
        nil
        (list obj-mona)                       ;; winner's-room
nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil
nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil
nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil
nil))

;;; These are objects in a room that are only described in the
;;; room description.  They are permanent.

(setq dun-room-silents (list nil
        (list obj-tree obj-coconut)            ;; dead-end
        (list obj-tree obj-coconut)            ;; e-w-dirt-road
        nil nil nil nil nil nil
        (list obj-bin)                         ;; mailroom
        (list obj-computer)                    ;; computer-room
        nil nil nil
        (list obj-dial)                        ;; sauna
        nil
        (list obj-ladder)                      ;; weight-room
        (list obj-button obj-ladder)           ;; maze-button-room
        nil nil nil
        nil nil nil nil
	(list obj-lake)                        ;; lakefront-north
	(list obj-lake)                        ;; lakefront-south
	nil
        (list obj-chute)                       ;; cave-entrance
        nil nil nil nil nil
        (list obj-painting obj-bed)            ;; bedroom
        (list obj-urinal obj-pipes)            ;; bathroom
        nil nil nil nil nil nil
        (list obj-boulder)                     ;; horseshoe-boulder-room
        nil nil nil nil nil nil nil nil nil nil nil nil nil nil
        (list obj-computer obj-cable)          ;; gamma-computing-center
        (list obj-mail)                        ;; post-office
        (list obj-gate)                        ;; main-maple-intersection
        nil nil nil nil nil nil nil nil nil nil nil nil nil
        nil nil nil nil nil nil nil
        (list obj-cliff)                       ;; fifth-oaktree-intersection
        nil nil nil
        (list obj-dinosaur)                    ;; museum-lobby
        nil
        (list obj-fish obj-tanks)              ;; marine-life-area
        (list obj-switch)                      ;; maintenance-room
        (list obj-blackboard)                  ;; classroom
        (list obj-train)                       ;; vermont-station
        nil nil
        (list obj-disposal)                    ;; north-end-of-n-s-tunnel
        nil nil
        (list obj-computer)                    ;; endgame-computer-room
        nil nil nil nil nil nil nil nil 
	(list obj-pc)                          ;; pc-area
	nil nil nil nil nil nil
))
(setq dun-inventory '(1))

;;; Descriptions of objects, as they appear in the room description, and
;;; the inventory.

(setq dun-objects '(
		("ここにはシャベル（shovel）があります．" "シャベル shovel")                ;0
		("ここにはランプ(lamp)があります。" "ランプ lamp")                  ;1
		("ここにはＣＰＵボード(board)があります．" "ＣＰＵボード board")      ;2
		("ここには食べ物(food)が落ちています." "食べ物 food")              ;3
		("ここには輝く黄銅の鍵(key)があります。" "鍵 key")    ;4
		("ここには紙切れ(paper)があります。" "紙切れ paper")  ;5
		("ここには リチャードストールマンのろう人形(statue)があります。" ;6
		 "ろう人形 statue")
		("ここには輝くダイアモンド(diamond)があります。" "ダイアモンド diamond")   ;7
		("ここには 10 ポンドの鉄アレイ(weight)があります。" "鉄アレイ weight")       ;8
		("ここには救命具(life preserver)があります。" "救命具 preserver");9
		("ここにはエメラルドの腕輪(bracelet)があります。" "腕輪 bracelet")   ;10
		("ここには金の延べ棒(gold)があります。" "金の延べ棒 gold")            ;11
		("ここにはプラチナの延べ棒(platinum)があります。" "プラチナの延べ棒 platinum")    ;12
		("地面の上にビーチタオル(towel)が落ちています。" "タオル towel")
		("ここには斧(axe)があります。" "斧 axe") ;14
		("ここには銀の延べ棒(silver)があります。" "銀の延べ棒 silver")  ;15
		("ここにはバスの運転免許証(license)があります。" "運転免許証 license") ;16
		("ここには貴重な金貨(coins)があります。" "貴重な金貨 coins")
		("ここには宝石がちりばめられた殻をもつ卵(egg)があります。" "貴重な卵 egg") ;18
		("ここにはガラスのびん(jar)があります。" "びん jar") ;19
		("ここには恐竜の骨(bone)があります。" "骨 bone") ;20
		("ここには１パックの硝酸(acid)があります。" "硝酸 acid")
		("ここには１パックのグリセリン(glycerine)があります。" "グリセリン glycerine") ;22
		("ここには貴重なルビー(ruby)があります。" "ルビー ruby") ;23
		("ここには貴重な紫水晶(amethyst)があります。" "紫水晶 amethyst") ;24
		("ここにはモナリザ（Mona Lisa）があります。" "モナリザ Mona") ;25
		("ここには100ドルの紙幣(bill)があります。" "100ドル紙幣 bill") ;26
		("ここにはフロッピーディスク(disk)があります。" "ディスク disk") ;27
	       )
)

;;; Weight of objects

(setq dun-object-lbs 
      '(2 1 1 1 1 0 2 2 10 3 1 1 1 0 1 1 0 1 1 1 1 0 0 2 2 1 0 0))
(setq dun-object-pts 
      '(0 0 0 0 0 0 0 10 0 0 10 10 10 0 0 10 0 10 10 0 0 0 0 10 10 10 10 0))


;;; Unix representation of objects.
(setq dun-objfiles '(
		 "shovel.o" "lamp.o" "cpu.o" "food.o" "key.o" "paper.o"
		 "rms.o" "diamond.o" "weight.o" "preserver.o" "bracelet.o"
		 "gold.o" "platinum.o" "towel.o" "axe.o" "silver.o" "license.o"
		 "coins.o" "egg.o" "jar.o" "bone.o" "nitric.o" "glycerine.o"
		 "ruby.o" "amethyst.o"
		 ))

;;; These are the descriptions for the negative numbered objects from
;;; dun-room-objects

(setq dun-perm-objects '(
		     nil
		     ("ここには大きな丸石(boulder)があります。")
		     nil
		     ("ここには恐ろしい熊（bear）がいます！")
		     nil
		     nil
		     ("ここには価値のない汚物(protoplasm)の山があります。")
		     nil
		     nil
		     nil
		     nil
		     nil
		     nil
		     ("この部屋は奇妙な匂い(strange smell)がします。")
		     nil
		     (
"ここにはスリットのある箱(box)があり、壁にボルトで留められています。"
                     )
		     nil
		     nil
		     ("ここにはバス(bus)があります。")
		     nil
		     nil
		     nil
))


;;; These are the descriptions the user gets when regular objects are
;;; examined.

(setq dun-physobj-desc '(
"それは $19.99と書かれた値札のついた、ふつうのシャベルです。"
"それはゼベット(Geppetto)による手作りのランプです。"
"ＣＰＵボードには VAX のチップが乗っています。 2 メガバイトのオンボード
ＲＡＭが乗っているように見えます。"
"それは何かの肉のように見えます。ひどく臭いにおいがします。"
nil
"紙にはこう書かれています。「助けを求めるときは 'help'とタイプすることを
忘れないこと。そして、この単語を覚えておくこと 'worms'」"
"この人形は、有名な EMACSエディタの作者リチャード・ストールマン
(Richard Stallman)に似ています。あなたは、彼が靴をはいていないことに
気がつきました。"
nil
"あなたは鉄アレイが重いことを確認しました。"
"それには ＳＳの小魚（S.S.Minnow）と書かれています."
nil
nil
nil
"それはスヌーピー(snoopy)の書かれた絵です。"
nil
nil
"それにはあなたの写真が付いています！"
"それは19世紀から続く古い金貨です。"
"それは高価な Fabrege の卵です。"
"それは質素なガラスのビンです。"
nil
nil
nil
nil
nil
                     )
)

;;; These are the descriptions the user gets when non-regular objects
;;; are examined.

(setq dun-permobj-desc '(
		     nil
"それはただの石(boulder)です。それを動かすことはできません。"
"それらはヤシの実(coconut)を豊富に供給してくれるヤシの木々です。"
"それはグリズリー(grizzly)の一種のように見えます。"
"大箱は全て空です。よく見ると、あなたは大箱の底に名前が書かれて
いるのがわかりました。しかし、ほとんどの名前はかすれてしまっていて
読むことができません。あなたが読むことができたのは次の３つの
名前だけでした。
              ジェフリー・コラー     Jeffrey Collier
              ロバート・トクモンド   Robert Toukmond
              トーマス・ストック     Thomas Stock
"
                      nil
"それはただごちゃごちゃとした汚いものです。"
"ダイアルはずっと以前にかすれて消えてしまった温度の目盛を指しています。"
nil
nil
"それは、エルビス・プレスリー(Elvis Presley)のベルベットの絵です。
それは壁にくぎで打ち付けられているのか、動かすことができません。"
"それはとてもマットレスの硬いクイーンサイズのベッドです。"
"小便器は洞窟の中のほかのどれよりもきれいです。少しのサビもありません。
確かめるために近づくと、あなたは底の排水溝がなく、パイプのどこへも
つながっていない大きな穴だけがあることに気がつきました。
この穴は人が入るにはあまりにも小さいです。洗浄(flush)するためのハンドルは
とてもきれいで、あなたはその中に自分の姿が映るのを見ることができます。"
nil
nil
"箱の上面にはスリット(slit)があり、その上に汚い字で走り書きがしてあります。
「鍵(key)の更新。この中に鍵を挿入(put)せよ。」"
nil
"そこには「速達便(express mail)と書かれています。"
"それは35人乗りのバスで、側面に「モービーツアーズ(mobytours)」という会社名
が書かれています。"
"それは乗り越える(climb)にはあまりにも巨大な金属製の門です。"
"それはとてつもなく巨大な崖です。"
"残念ながら、あなたそれについてウンチクを述べるほど十分な知識は持って
いません。いずれにせよ、それはとても大きいです。"
"この魚は、かつてはとても美しかったように見えます。"
nil
nil
nil
nil
"永久に穴に取り付けられたままの、ごく普通のハシゴです。"
"それは出発準備のできている客車(train)です。"
"フロッピーディスクドライブ(floppy disk drive)がひとつだけついた
パーソナルコンピュータ(computer)です。"
		    )
)

(setq dun-diggables 
      (list nil nil nil (list obj-cpu) nil nil nil nil nil nil nil
		  nil nil nil nil nil nil nil nil nil nil      ;11-20
		  nil nil nil nil nil nil nil nil nil nil      ;21-30
		  nil nil nil nil nil nil nil nil nil nil      ;31-40
		  nil (list obj-platinum) nil nil nil nil nil nil nil nil))

(setq dun-room-shorts nil)
(dolist (x dun-rooms)
  (setq dun-room-shorts  
		     (append dun-room-shorts (list (downcase 
						    (dun-space-to-hyphen
						     (cadr x)))))))

(setq dun-endgame-questions '(
			  ("-1" "foo")
			  ("00" "robert")
			  ("01" "foo")
			  ("02" "4" "four")
			  ("03" "toukmond")
			  ("04" "20" "twenty")
			  ("05" "mobytours")
			  ("06" "collier" "stock")
			  ("07" "snoopy")
			  ("08" "stallman")
			  ("09" "2")
			  ("10" "vermont")
			  ("11" "ten" "10")
			  ("12" "fourth" "4" "4th")
			  ("13" "24" "twentyfour" "twenty-four")
			  ("14" "grizzly")
			  ("15" "cpu" "card" "vax" "board" "platinum")
			  ("16" "tcp/ip" "ip" "tcp")
))

(setq dun-endgame-questions-msg '(
			  ("-1".
" もう質問はありません。'answer foo' と入力してください。.")
			  ("00".
"'pokey'とよばれるマシンでのあなたのパスワードは何？")
			  ("01".
"gammaの匿名（anonymous）ftpでのあなたのパスワードは何？")
			  ("02".
"endgameを除き、あなたが得点を得るために宝物を入れる(put)ことができる
場所はいくつある？")
			  ("03".
"'endgame'マシンでのあなたのユーザログイン名は何？")
			  ("04".
"シャベルの値段はおよそ何ドル？（整数で入力）")
			  ("05".
"街をささえるバスの会社名は何？")
			  ("06".
"郵便物の部屋にのこされた、あなた以外の２人の名前のうち、どちらか一方の
ラストネーム（後半の名前）を答えよ。")
			  ("07".
"タオルに書かれていたマンガのキャラクターは何？")
			  ("08".
"EMACS の開発者のラストネーム（後半の名前）は何？")
			  ("09".
"VaxのCPUボード(board)にのっていたメモリは何メガバイト？（整数で入力）")
			  ("10".
"アメリカの州の名前がついた町の通りの名前は？")
			  ("11".
"鉄アレイの重さは何ポンドだった？（整数で入力）")
			  ("12".
"地下鉄の駅があったのは第何通り？（整数で入力）")
			  ("13".
"郵便局を除き、街の交差点（T字路,L字路等を含む）はいつくあった？（整数で入力）")
			  ("14".
"鍵を隠していた熊は何の種類だった？")
			  ("15".
"あなたが穴を掘ってみつけた物のうち、ひとつの名前を答えよ。")
			  ("16".
"pockyとgammaの間で使われていたネットワーク通信プロトコルは何？")
))

(let (a)
  (setq a 0)
  (dolist (x dun-room-shorts)
    (eval (list 'defconst (intern x) a))
    (setq a (+ a 1))))



;;;;
;;;; This section defines the UNIX emulation functions for dunnet.
;;;;

(defun dun-unix-parse (args)
  (interactive "*p")
  (beginning-of-line)
  (let (beg esign)
    (setq beg (+ (point) 2))
    (end-of-line)
    (if (and (not (= beg (point)))
	     (string= "$" (buffer-substring (- beg 2) (- beg 1))))
	(progn
	  (setq line (downcase (buffer-substring beg (point))))
	  (princ line)
	  (if (eq (dun-parse2 nil dun-unix-verbs line) -1)
	      (progn
		(if (setq esign (string-match "=" line))
		    (dun-doassign line esign)		
		  (dun-mprinc (car line-list))
		  (dun-mprincl ": not found.（コマンドがありません）")))))
      (goto-char (point-max))
      (dun-mprinc "\n"))
    (if (eq dungeon-mode 'unix)
	(progn
	  (dun-fix-screen)
	  (dun-mprinc "$ ")))))

(defun dun-doassign (line esign)
  (if (not dun-wizard)
      (let (passwd)
	(dun-mprinc "Enter wizard password: ")
	(setq passwd (dun-read-line))
	(if (not dun-batch-mode)
	    (dun-mprinc "\n"))
	(if (string= passwd "moby")
	    (progn
	      (setq dun-wizard t)
	      (dun-doassign line esign))
	  (dun-mprincl "Incorrect.")))

    (let (varname epoint afterq i value)
      (setq varname (substring line 0 esign))
      (if (not (setq epoint (string-match ")" line)))
	  (if (string= (substring line (1+ esign) (+ esign 2))
		       "\"")
	      (progn
		(setq afterq (substring line (+ esign 2)))
		(setq epoint (+
			      (string-match "\"" afterq)
			      (+ esign 3))))
	    
	    (if (not (setq epoint (string-match " " line)))
		(setq epoint (length line))))
	(setq epoint (1+ epoint))
	(while (and
		(not (= epoint (length line)))
		(setq i (string-match ")" (substring line epoint))))
	  (setq epoint (+ epoint i 1))))
      (setq value (substring line (1+ esign) epoint))
      (dun-eval varname value))))

(defun dun-eval (varname value)
  (let (eval-error)
    (switch-to-buffer (get-buffer-create "*dungeon-eval*"))
    (erase-buffer)
    (insert "(setq ")
    (insert varname)
    (insert " ")
    (insert value)
    (insert ")")
    (setq eval-error nil)
    (condition-case nil
	(eval-current-buffer)
      (error (setq eval-error t)))
    (kill-buffer (current-buffer))
    (switch-to-buffer "*dungeon*")
    (if eval-error
	(dun-mprincl "Invalid syntax."))))
  

(defun dun-unix-interface ()
  (dun-login)
  (if dun-logged-in
      (progn
	(setq dungeon-mode 'unix)
	(define-key dungeon-mode-map "\r" 'dun-unix-parse)
	(dun-mprinc "$ "))))

(defun dun-login ()
  (let (tries username password)
    (setq tries 4)
    (while (and (not dun-logged-in) (> (setq tries (- tries 1)) 0))
      (dun-mprinc "\n\nUNIX System V, Release 2.2 (pokey)\n\nlogin: ")
      (setq username (dun-read-line))
      (if (not dun-batch-mode)
	  (dun-mprinc "\n"))
      (dun-mprinc "password: ")
      (setq password (dun-read-line))
      (if (not dun-batch-mode)
	  (dun-mprinc "\n"))
      (if (or (not (string= username "toukmond"))
	      (not (string= password "robert")))
	  (dun-mprincl "login incorrect")
	(setq dun-logged-in t)
	(dun-mprincl "
Welcome to Unix\n
Please clean up your directories.  The filesystem is getting full.
（ディレクトリを整理せよ。ファイルシステムはいっぱいになっている。）
Our tcp/ip link to gamma is a little flaky, but seems to work.
（コンピュータ gamma へのTCP/IPによるリンクは不安定だが動作する。）
The current version of ftp can only send files from your home
directory, and deletes them after they are sent!  Be careful.
（ファイル転送ソフト ftp の現在のバージョンは、ホームディレクトリから
  のファイル送信のみ可能。ファイルは送信後に消去される！注意せよ。）

Note: Restricted bourne shell in use.（制限されたbourne shell動作中）
（ファイル名の一覧には コマンド ls を使います）\n")))
  (setq dungeon-mode 'dungeon)))

(defun dun-ls (args)
  (if (car args)
      (let (ocdpath ocdroom)
	(setq ocdpath dun-cdpath)
	(setq ocdroom dun-cdroom)
	(if (not (eq (dun-cd args) -2))
	    (dun-ls nil))
	(setq dun-cdpath ocdpath)
	(setq dun-cdroom ocdroom))
    (if (= dun-cdroom -10)
	(dun-ls-inven))
    (if (= dun-cdroom -2)
	(dun-ls-rooms))
    (if (= dun-cdroom -3)
	(dun-ls-root))
    (if (= dun-cdroom -4)
	(dun-ls-usr))
    (if (> dun-cdroom 0)
	(dun-ls-room))))

(defun dun-ls-root ()
  (dun-mprincl "total 4
drwxr-xr-x  3 root     staff           512 Jan 1 1970 .
drwxr-xr-x  3 root     staff          2048 Jan 1 1970 ..
drwxr-xr-x  3 root     staff          2048 Jan 1 1970 usr
drwxr-xr-x  3 root     staff          2048 Jan 1 1970 rooms"))

(defun dun-ls-usr ()
  (dun-mprincl "total 4
drwxr-xr-x  3 root     staff           512 Jan 1 1970 .
drwxr-xr-x  3 root     staff          2048 Jan 1 1970 ..
drwxr-xr-x  3 toukmond restricted      512 Jan 1 1970 toukmond"))

(defun dun-ls-rooms ()
  (dun-mprincl "total 16
drwxr-xr-x  3 root     staff           512 Jan 1 1970 .
drwxr-xr-x  3 root     staff          2048 Jan 1 1970 ..")
  (dolist (x dun-visited)
    (dun-mprinc
"drwxr-xr-x  3 root     staff           512 Jan 1 1970 ")
    (dun-mprincl (nth x dun-room-shorts))))

(defun dun-ls-room ()
  (dun-mprincl "total 4
drwxr-xr-x  3 root     staff           512 Jan 1 1970 .
drwxr-xr-x  3 root     staff          2048 Jan 1 1970 ..
-rwxr-xr-x  3 root     staff          2048 Jan 1 1970 description")
  (dolist (x (nth dun-cdroom dun-room-objects))
    (if (and (>= x 0) (not (= x 255)))
	(progn
	  (dun-mprinc "-rwxr-xr-x  1 toukmond restricted        0 Jan 1 1970 ")
	  (dun-mprincl (nth x dun-objfiles))))))

(defun dun-ls-inven ()
  (dun-mprinc "total 467
drwxr-xr-x  3 toukmond restricted      512 Jan 1 1970 .
drwxr-xr-x  3 root     staff          2048 Jan 1 1970 ..")
  (dolist (x dun-unix-verbs)
    (if (not (eq (car x) 'IMPOSSIBLE))
	(progn
	  (dun-mprinc"
-rwxr-xr-x  1 toukmond restricted    10423 Jan 1 1970 ")
	  (dun-mprinc (car x)))))
  (dun-mprinc "\n")
  (if (not dun-uncompressed)
      (dun-mprincl
"-rwxr-xr-x  1 toukmond restricted        0 Jan 1 1970 paper.o.Z"))
  (dolist (x dun-inventory)
    (dun-mprinc 
"-rwxr-xr-x  1 toukmond restricted        0 Jan 1 1970 ")
    (dun-mprincl (nth x dun-objfiles))))

(defun dun-echo (args)
  (let (nomore var)
    (setq nomore nil)
    (dolist (x args)
	    (if (not nomore)
		(progn
		  (if (not (string= (substring x 0 1) "$"))
		      (progn
			(dun-mprinc x)
			(dun-mprinc " "))
		    (setq var (intern (substring x 1)))
		    (if (not (boundp var))
			(dun-mprinc " ")
		      (if (member var dun-restricted)
			  (progn
			    (dun-mprinc var)
			    (dun-mprinc ": Permission denied")
			    (setq nomore t))
			(eval (list 'dun-mprinc var))
			(dun-mprinc " ")))))))
	    (dun-mprinc "\n")))


(defun dun-ftp (args)
  (let (host username passwd ident newlist)
    (if (not (car args))
	(dun-mprincl "ftp: hostname required on command line.
（コマンドの後に接続先コンピュータ名が必要。例 ftp <コンピュータ名> ）")
      (setq host (intern (car args)))
      (if (not (member host '(gamma dun-endgame)))
	  (dun-mprincl "ftp: Unknown host.（ftp:不明なホスト名）")
	(if (eq host 'dun-endgame)
	    (dun-mprincl "ftp: connection to endgame not allowed
（ftp: endgameはftpによる接続が許可されていない）")
	  (if (not dun-ethernet)
	      (dun-mprincl "ftp: host not responding.（ftp:ホストからの応答がない）")
	    (dun-mprincl "Connected to gamma. FTP ver 0.9 00:00:00 01/01/70
（ gamma へ接続。FTP バージョン 0.9 ）")
	    (dun-mprinc "Username（ユーザ名）: ")
	    (setq username (dun-read-line))
	    (if (string= username "toukmond")
		(if dun-batch-mode
		    (dun-mprincl "toukmond ftp access not allowed.
（toukmondのアクセスは不許可）")
		  (dun-mprincl "\ntoukmond ftp access not allowed.
（toukmondのアクセスは不許可）"))
	      (if (string= username "anonymous")
		  (if dun-batch-mode
		      (dun-mprincl
		       "Guest login okay, send your user ident as password.
（ゲストログインＯＫ、パスワードの代わりにあなたのユーザー名を送信せよ）")
		    (dun-mprincl 
		     "\nGuest login okay, send your user ident as password.
（ゲストログインＯＫ、パスワードの代わりにあなたのユーザー名を送信せよ）"))
		(if dun-batch-mode
		    (dun-mprinc "Password required for ")
		  (dun-mprinc "\nPassword required for "))
		(dun-mprincl username)
	        (dun-mprincl (format "（ユーザ %s のパスワードが必要）" username)))
	      (dun-mprinc "Password: ")
	      (setq ident (dun-read-line))
	      (if (not (string= username "anonymous"))
		  (if dun-batch-mode
		      (dun-mprincl "Login failed.（ログイン失敗）")
		    (dun-mprincl "\nLogin failed.（ログイン失敗）"))
		(if dun-batch-mode
		   (dun-mprincl 
		    "Guest login okay, user access restrictions apply.
（ゲストログインＯＫ，ユーザアクセス制限適用）")
		  (dun-mprincl 
		   "\nGuest login okay, user access restrictions apply.
（ゲストログインＯＫ，ユーザアクセス制限適用）"))
		(dun-ftp-commands)
;		(setq newlist 
;'("What password did you use during anonymous ftp to gamma?"))
		(setq newlist '("01"))
		(setq newlist (append newlist (list ident)))
		(rplaca (nthcdr 1 dun-endgame-questions) newlist)))))))))
  
(defun dun-ftp-commands ()
    (setq dun-exitf nil)
    (let (line)
      (while (not dun-exitf)
	(dun-mprinc "ftp> ")
	(setq line (dun-read-line))
	(if 
	    (eq
	     (dun-parse2 nil 
		    '((type . dun-ftptype) (binary . dun-bin) (bin . dun-bin)
		      (send . dun-send) (put . dun-send) (quit . dun-ftpquit)
		      (help . dun-ftphelp)(ascii . dun-fascii)
		      ) line)
	     -1)
	    (dun-mprincl "No such command.  Try help.
（そのようなコマンドはない。 help を試すこと。）")))
      (setq dun-ftptype 'ascii)))

(defun dun-ftptype (args)
  (if (not (car args))
      (dun-mprincl "Usage: type [binary | ascii] （使い方： type 「binary または ascii」）")
    (setq args (intern (car args)))
    (if (eq args 'binary)
	(dun-bin nil)
      (if (eq args 'ascii)
	  (dun-fascii 'nil)
	(dun-mprincl "Unknown type.（不明なタイプ）")))))

(defun dun-bin (args)
  (dun-mprincl "Type set to binary.（転送モードをバイナリに設定）")
  (setq dun-ftptype 'binary))

(defun dun-fascii (args)
  (dun-mprincl "Type set to ascii.（転送モードをアスキーに設定）")
  (setq dun-ftptype 'ascii))

(defun dun-ftpquit (args)
  (setq dun-exitf t))

(defun dun-send (args)
  (if (not (car args))
      (dun-mprincl "Usage: send <filename> （使い方： send <ファイル名>）")
    (setq args (car args))
    (let (counter foo)
      (setq foo nil)
      (setq counter 0)

;;; User can send commands!  Stupid user.


      (if (assq (intern args) dun-unix-verbs)
	  (progn
	    (rplaca (assq (intern args) dun-unix-verbs) 'IMPOSSIBLE)
	    (dun-mprinc "Sending ")
	    (dun-mprinc dun-ftptype)
	    (dun-mprinc " file for ")
	    (dun-mprincl args)
	  (dun-mprincl (format "（ファイル %s を %s モードで転送。）" 
		args dun-ftptype))
	    (dun-mprincl "Transfer complete.（転送完了）"))

	(dolist (x dun-objfiles)
	  (if (string= args x)
	      (progn
		(if (not (member counter dun-inventory))
		    (progn
		      (dun-mprincl "No such file.（そのようなファイルはない）")
		      (setq foo t))
		  (dun-mprinc "Sending ")
		  (dun-mprinc dun-ftptype)
		  (dun-mprinc " file for ")
		  (dun-mprinc (downcase (cadr (nth counter dun-objects))))
		  (dun-mprincl ", (0 bytes)")
	  (dun-mprincl (format "（ファイル %s を %s モードで転送。）" 
		args dun-ftptype))
		  (if (not (eq dun-ftptype 'binary))
		      (progn
			(if (not (member obj-protoplasm
					 (nth receiving-room 
					      dun-room-objects)))
			    (dun-replace dun-room-objects receiving-room
				     (append (nth receiving-room 
						  dun-room-objects)
					     (list obj-protoplasm))))
			(dun-remove-obj-from-inven counter))
		    (dun-remove-obj-from-inven counter)
		    (dun-replace dun-room-objects receiving-room
			     (append (nth receiving-room dun-room-objects)
				     (list counter))))
		  (setq foo t)
		  (dun-mprincl "Transfer complete.（転送完了）"))))
	  (setq counter (+ 1 counter)))
	(if (not foo)
	    (dun-mprincl "No such file."))))))

(defun dun-ftphelp (args)
  (dun-mprincl 
   "Possible commands are:\nsend    quit    type   ascii  binary   help
（可能なコマンドは send 送信／quit 終了／ type 転送モード指定／
    ascii 文書転送モード／ binary プログラム転送モード ／help 使い方の表示）"))

(defun dun-uexit (args)
  (setq dungeon-mode 'dungeon)
  (dun-mprincl "\nあなたはコンソールから一歩後ろへ下がりました。")
  (define-key dungeon-mode-map "\r" 'dun-parse)
  (if (not dun-batch-mode)
      (dun-messages)))

(defun dun-pwd (args)
  (dun-mprincl dun-cdpath))

(defun dun-uncompress (args)
  (if (not (car args))
      (dun-mprincl "Usage: uncompress <filename>（使い方： uncompress <ファイル名> ）")
    (setq args (car args))
    (if (or dun-uncompressed
	    (and (not (string= args "paper.o"))
		 (not (string= args "paper.o.z"))))
	(dun-mprincl "Uncompress command failed.（圧縮ファイルの展開コマンド失敗）")
      (setq dun-uncompressed t)
      (setq dun-inventory (append dun-inventory (list obj-paper))))))

(defun dun-rlogin (args)
  (let (passwd)
    (if (not (car args))
	(dun-mprincl "Usage: rlogin <hostname> （使い方： rlogin <コンピュータ名>） ")
      (setq args (car args))
      (if (string= args "endgame")
	  (dun-rlogin-endgame)
	(if (not (string= args "gamma"))
	    (if (string= args "pokey")
		(dun-mprincl "Can't rlogin back to localhost
（現在使用しているホストにrloginすることはできない）")
	      (dun-mprincl "No such host.（そのようなホストはない）"))
	  (if (not dun-ethernet)
	      (dun-mprincl "Host not responding.（ホストから応答がない）")
	    (dun-mprinc "Password（パスワード）: ")
	    (setq passwd (dun-read-line))
	    (if (not (string= passwd "worms"))
		(dun-mprincl "\nlogin incorrect（ログイン失敗）")
	      (dun-mprinc 
"\n■■■■■■■■■■■■■■■■■■■■■■■■■■■■
あなたは一瞬、奇妙な感じがして、そしてあなたは全ての持ち物を失いました。"
)
	      (dun-replace dun-room-objects computer-room 
		       (append (nth computer-room dun-room-objects) 
			       dun-inventory))
	      (setq dun-inventory nil)
	      (setq dun-current-room receiving-room)
	      (dun-uexit nil))))))))
  
(defun dun-cd (args)
  (let (tcdpath tcdroom path-elements room-check)
    (if (not (car args))
	(dun-mprincl "Usage: cd <path> （使い方： cd <移動先ディレクトリ名> ）")
      (setq tcdpath dun-cdpath)
      (setq tcdroom dun-cdroom)
      (setq dun-badcd nil)
      (condition-case nil
	  (setq path-elements (dun-get-path (car args) nil))
	(error (dun-mprincl "Invalid path.（不正なディレクトリ名）")
	       (setq dun-badcd t)))
      (dolist (pe path-elements)
	      (unless dun-badcd
		      (if (not (string= pe "."))
			  (if (string= pe "..")
			      (progn
				(if (> tcdroom 0)                  ;In a room
				    (progn
				      (setq tcdpath "/rooms")
				      (setq tcdroom -2))
					;In /rooms,/usr,root
				  (if (or 
				       (= tcdroom -2) (= tcdroom -4) 
				       (= tcdroom -3))
				      (progn
					(setq tcdpath "/")
					(setq tcdroom -3))
				    (if (= tcdroom -10)       ;In /usr/toukmond
					(progn
					  (setq tcdpath "/usr")
					  (setq tcdroom -4))))))
			    (if (string= pe "/")
				(progn
				  (setq tcdpath "/")
				  (setq tcdroom -3))
			      (if (= tcdroom -4)
				  (if (string= pe "toukmond")
				      (progn
					(setq tcdpath "/usr/toukmond")
					(setq tcdroom -10))
				    (dun-nosuchdir))
				(if (= tcdroom -10)
				    (dun-nosuchdir)
				  (if (> tcdroom 0)
				      (dun-nosuchdir)
				    (if (= tcdroom -3)
					(progn
					  (if (string= pe "rooms")
					      (progn
						(setq tcdpath "/rooms")
						(setq tcdroom -2))
					    (if (string= pe "usr")
						(progn
						  (setq tcdpath "/usr")
						  (setq tcdroom -4))
					      (dun-nosuchdir))))
				      (if (= tcdroom -2)
					  (progn
					    (dolist (x dun-visited)
						    (setq room-check 
							  (nth x 
							      dun-room-shorts))
						    (if (string= room-check pe)
							(progn
							  (setq tcdpath 
						 (concat "/rooms/" room-check))
							  (setq tcdroom x))))
					    (if (= tcdroom -2)
						(dun-nosuchdir)))))))))))))
      (if (not dun-badcd)
	  (progn
	    (setq dun-cdpath tcdpath)
	    (setq dun-cdroom tcdroom)
	    0)
      -2))))

(defun dun-nosuchdir ()
  (dun-mprincl "No such directory.（そのようなディレクトリはない）")
  (setq dun-badcd t))

(defun dun-cat (args)
  (let (doto checklist)
    (if (not (setq args (car args)))
	(dun-mprincl "Usage: cat <ascii-file-name>（使い方： cat <文章ファイル名> ）")
      (if (string-match "/" args)
	  (dun-mprincl "cat: only files in current directory allowed.
（cat:現在いるディレクトリ内のファイルのみ閲覧可能）")
	(if (and (> dun-cdroom 0) (string= args "description"))
	    (dun-mprincl (car (nth dun-cdroom dun-rooms)))
	  (if (setq doto (string-match "\\.o" args))
	      (progn
		(if (= dun-cdroom -10)
		    (setq checklist dun-inventory)
		  (setq checklist (nth dun-cdroom dun-room-objects)))
		(if (not (member (cdr 
				  (assq (intern 
					 (substring args 0 doto)) 
					dun-objnames))
				 checklist))
		    (dun-mprincl "File not found.（ファイルが見つからない）")
		  (dun-mprincl "Ascii files only.（文書ファイルのみ閲覧可能）")))
	    (if (assq (intern args) dun-unix-verbs)
		(dun-mprincl "Ascii files only.（文書ファイルのみ閲覧可能）")
	      (dun-mprincl "File not found.（ファイルが見つからない）"))))))))
  
(defun dun-zippy (args)
  (dun-mprincl (yow)))

(defun dun-rlogin-endgame ()
  (if (not (= (dun-score nil) 90))
;  (if (not (= (dun-score nil) 70))
      (dun-mprincl 
       "You have not achieved enough points to connect to endgame.
（あなたはendgameに接続するのに十分な得点をまだ獲得していません。）")
    (dun-mprincl"\nendgameへようこそ。あなたはとても気高い冒険家です。")
    (setq dun-current-room treasure-room)
    (setq dun-endgame t)
    (dun-replace dun-room-objects endgame-treasure-room (list obj-bill))
    (dun-uexit nil)))


(random t)
(setq tloc (+ 60 (random 18)))
(dun-replace dun-room-objects tloc 
	     (append (nth tloc dun-room-objects) (list 18)))

(setq tcomb (+ 100 (random 899)))
(setq dun-combination (prin1-to-string tcomb))

;;;;
;;;; This section defines the DOS emulation functions for dunnet
;;;;

(defun dun-dos-parse (args)
  (interactive "*p")
  (beginning-of-line)
  (let (beg)
    (setq beg (+ (point) 3))
    (end-of-line)
    (if (not (= beg (point)))
	(let (line)
	  (setq line (downcase (buffer-substring beg (point))))
	  (princ line)
	  (if (eq (dun-parse2 nil dun-dos-verbs line) -1)
	      (progn
		(sleep-for 1)
		(dun-mprincl "Bad command or file name （不正な命令またはファイル名）"))))
      (goto-char (point-max))
      (dun-mprinc "\n"))
    (if (eq dungeon-mode 'dos)
	(progn
	  (dun-fix-screen)
	  (dun-dos-prompt)))))

(defun dun-dos-interface ()
  (dun-dos-boot-msg)
  (setq dungeon-mode 'dos)
  (define-key dungeon-mode-map "\r" 'dun-dos-parse)
  (dun-dos-prompt))

(defun dun-dos-type (args)
  (sleep-for 2)
  (if (setq args (car args))
      (if (string= args "foo.txt")
	  (dun-dos-show-combination)
	(if (string= args "command.com")
	    (dun-mprincl "Cannot type binary files（バイナリファイルは不可）")
	  (dun-mprinc "File not found - ")
	  (dun-mprincl (upcase args))
	  (dun-mprincl (format "（ファイル %s が見つからない）" (upcase args)))
	))
    (dun-mprincl "Must supply file name")))

(defun dun-dos-invd (args)
  (sleep-for 1)
  (dun-mprincl "Invalid drive specification （そのドライブは存在しない）"))

(defun dun-dos-dir (args)
  (sleep-for 1)
  (if (or (not (setq args (car args))) (string= args "\\"))
      (dun-mprincl "
 Volume in drive A is FOO        
 Volume Serial Number is 1A16-08C9
 Directory of A:\\

COMMAND  COM     47845 04-09-91   2:00a
FOO      TXT        40 01-20-93   1:01a
        2 file(s)      47845 bytes
                     1065280 bytes free
")
    (dun-mprincl "
 Volume in drive A is FOO        
 Volume Serial Number is 1A16-08C9
 Directory of A:\\

File not found")))


(defun dun-dos-prompt ()
  (dun-mprinc "A> "))

(defun dun-dos-boot-msg ()
  (sleep-for 3)
  (dun-mprinc "Current time is ")
  (dun-mprincl (substring (current-time-string) 12 20))
  (dun-mprincl (format "（現在の時刻は %s ）" (substring (current-time-string) 12 20)))
  (dun-mprinc "Enter new time（時刻を入力せよ）: ")
  (dun-read-line)
  (if (not dun-batch-mode)
      (dun-mprinc "\n")))

(defun dun-dos-spawn (args)
  (sleep-for 1)
  (dun-mprincl "Cannot spawn subshell"))

(defun dun-dos-exit (args)
  (setq dungeon-mode 'dungeon)
  (dun-mprincl "\nあなたはパソコンの電源を落として離れた。")
  (define-key dungeon-mode-map "\r" 'dun-parse)
  (if (not dun-batch-mode)
      (dun-messages)))

(defun dun-dos-no-disk ()
  (sleep-for 3)
  (dun-mprincl "Boot sector not found （起動に必要な情報が見つからない）"))


(defun dun-dos-show-combination ()
  (sleep-for 2)
  (dun-mprinc "\nThe combination is ")
  (dun-mprinc dun-combination)
  (dun-mprinc ".")
  (dun-mprinc (format "（組み合わせは %s です。）\n" dun-combination)) )

(defun dun-dos-nil (args))


;;;;
;;;; This section defines the save and restore game functions for dunnet.
;;;;

(defun dun-save-game (filename)
  (if (not (setq filename (car filename)))
      (dun-mprincl "ゲームを保存するには save の後ろに保存先ファイル名を与える必要があります。
（カレントディレクトリに指定した名前のファイルが作られます）")
    (if (file-exists-p filename)
	(delete-file filename))
    (setq dun-numsaves (1+ dun-numsaves))
    (dun-make-save-buffer)
    (dun-save-val "dun-current-room")
    (dun-save-val "dun-computer")
    (dun-save-val "dun-combination")
    (dun-save-val "dun-visited")
    (dun-save-val "dun-diggables")
    (dun-save-val "dun-key-level")
    (dun-save-val "dun-floppy")
    (dun-save-val "dun-numsaves")
    (dun-save-val "dun-numcmds")
    (dun-save-val "dun-logged-in")
    (dun-save-val "dungeon-mode")
    (dun-save-val "dun-jar")
    (dun-save-val "dun-lastdir")
    (dun-save-val "dun-black")
    (dun-save-val "dun-nomail")
    (dun-save-val "dun-unix-verbs")
    (dun-save-val "dun-hole")
    (dun-save-val "dun-uncompressed")
    (dun-save-val "dun-ethernet")
    (dun-save-val "dun-sauna-level")
    (dun-save-val "dun-room-objects")
    (dun-save-val "dun-room-silents")
    (dun-save-val "dun-inventory")
    (dun-save-val "dun-endgame-questions")
    (dun-save-val "dun-endgame")
    (dun-save-val "dun-cdroom")
    (dun-save-val "dun-cdpath")
    (dun-save-val "dun-correct-answer")
    (dun-save-val "dun-inbus")
    (dun-save-val "dun-question-message")
    (if (dun-compile-save-out filename)
	(dun-mprincl "ゲームをファイルに保存する際にエラーが発生しました。")
      (dun-do-logfile 'save nil)
      (switch-to-buffer "*dungeon*")
      (princ "")
      (dun-mprincl "ゲームの状態を保存しました。"))))

(defun dun-make-save-buffer ()
  (switch-to-buffer (get-buffer-create "*save-dungeon*"))
  (erase-buffer))

(defun dun-compile-save-out (filename)
  (let (ferror)
    (setq ferror nil)
    (condition-case nil
	(dun-rot13)
      (error (setq ferror t)))
    (if (not ferror)
	(progn
	  (goto-char (point-min))))
    (condition-case nil
        (write-region 1 (point-max) filename nil 1)
        (error (setq ferror t)))
    (kill-buffer (current-buffer))
    ferror))
    

(defun dun-save-val (varname)
  (let (value)
    (setq varname (intern varname))
    (setq value (eval varname))
    (dun-minsert "(setq ")
    (dun-minsert varname)
    (dun-minsert " ")
    (if (or (listp value)
	    (symbolp value))
	(dun-minsert "'"))
    (if (stringp value)
	(dun-minsert "\""))
    (dun-minsert value)
    (if (stringp value)
	(dun-minsert "\""))
    (dun-minsertl ")")))


(defun dun-restore (args)
  (let (file)
    (if (not (setq file (car args)))
	(dun-mprincl "ゲームを再開するには restore の後ろにファイル名を与える必要があります。")
      (if (not (dun-load-d file))
	  (dun-mprincl "ファイルを読むことができません。")
	(dun-mprincl "ゲームの途中から再開しました。")
	(setq room 0)))))


(defun dun-do-logfile (type how)
  (let (ferror newscore)
    (setq ferror nil)
    (switch-to-buffer (get-buffer-create "*score*"))
    (erase-buffer)
    (condition-case nil
	(insert-file-contents dun-log-file)
      (error (setq ferror t)))
    (unless ferror
	    (goto-char (point-max))
	    (dun-minsert (current-time-string))
	    (dun-minsert " ")
	    (dun-minsert (user-login-name))
	    (dun-minsert " ")
	    (if (eq type 'save)
		(dun-minsert "saved ")
	      (if (= (dun-endgame-score) 110)
		  (dun-minsert "won ")
		(if (not how)
		    (dun-minsert "quit ")
		  (dun-minsert "killed by ")
		  (dun-minsert how)
		  (dun-minsert " "))))
	    (dun-minsert "at ")
	    (dun-minsert (cadr (nth (abs room) dun-rooms)))
	    (dun-minsert ". score: ")
	    (if (> (dun-endgame-score) 0)
		(dun-minsert (setq newscore (+ 90 (dun-endgame-score))))
	      (dun-minsert (setq newscore (dun-reg-score))))
	    (dun-minsert " saves: ")
	    (dun-minsert dun-numsaves)
	    (dun-minsert " commands: ")
	    (dun-minsert dun-numcmds)
	    (dun-minsert "\n")
	    (write-region 1 (point-max) dun-log-file nil 1))
    (kill-buffer (current-buffer))))


;;;;
;;;; These are functions, and function re-definitions so that dungeon can
;;;; be run in batch mode.


(defun dun-batch-mprinc (arg)
   (if (stringp arg)
       (send-string-to-terminal arg)
     (send-string-to-terminal (prin1-to-string arg))))


(defun dun-batch-mprincl (arg)
   (if (stringp arg)
       (progn
           (send-string-to-terminal arg)
           (send-string-to-terminal "\n"))
     (send-string-to-terminal (prin1-to-string arg))
     (send-string-to-terminal "\n")))

(defun dun-batch-parse (dun-ignore dun-verblist line)
  (setq line-list (dun-listify-string (concat line " ")))
  (dun-doverb dun-ignore dun-verblist (car line-list) (cdr line-list)))

(defun dun-batch-parse2 (dun-ignore dun-verblist line)
  (setq line-list (dun-listify-string2 (concat line " ")))
  (dun-doverb dun-ignore dun-verblist (car line-list) (cdr line-list)))

(defun dun-batch-read-line ()
  (read-from-minibuffer "" nil dungeon-batch-map))


(defun dun-batch-loop ()
  (setq dun-dead nil)
  (setq room 0)
  (while (not dun-dead)
    (if (eq dungeon-mode 'dungeon)
	(progn
	  (if (not (= room dun-current-room))
	      (progn
		(dun-describe-room dun-current-room)
		(setq room dun-current-room)))
	  (dun-mprinc ">")
	  (setq line (downcase (dun-read-line)))
	  (if (eq (dun-vparse dun-ignore dun-verblist line) -1)
	      (dun-mprinc "I don't understand that.\n"))))))

(defun dun-batch-dos-interface ()
  (dun-dos-boot-msg)
  (setq dungeon-mode 'dos)
  (while (eq dungeon-mode 'dos)
    (dun-dos-prompt)
    (setq line (downcase (dun-read-line)))
    (if (eq (dun-parse2 nil dun-dos-verbs line) -1)
	(progn
	  (sleep-for 1)
	  (dun-mprincl "Bad command or file name"))))
  (goto-char (point-max))
  (dun-mprinc "\n"))

(defun dun-batch-unix-interface ()
    (dun-login)
    (if dun-logged-in
	(progn
	  (setq dungeon-mode 'unix)
	  (while (eq dungeon-mode 'unix)
	    (dun-mprinc "$ ")
	    (setq line (downcase (dun-read-line)))
	    (if (eq (dun-parse2 nil dun-unix-verbs line) -1)
		(let (esign)
		  (if (setq esign (string-match "=" line))
		      (dun-doassign line esign)		
		    (dun-mprinc (car line-list))
		    (dun-mprincl ": not found.")))))
	  (goto-char (point-max))
	  (dun-mprinc "\n"))))

(defun dungeon-nil (arg)
  "noop"
  (interactive "*p")
  nil)

(defun dun-batch-dungeon ()
  (load "dun-batch")
  (setq dun-visited '(27))
  (dun-mprinc "\n")
  (dun-batch-loop))

(unless (not noninteractive)
  (fset 'dun-mprinc 'dun-batch-mprinc)
  (fset 'dun-mprincl 'dun-batch-mprincl)
  (fset 'dun-vparse 'dun-batch-parse)
  (fset 'dun-parse2 'dun-batch-parse2)
  (fset 'dun-read-line 'dun-batch-read-line)
  (fset 'dun-dos-interface 'dun-batch-dos-interface)
  (fset 'dun-unix-interface 'dun-batch-unix-interface)
  (dun-mprinc "\n")
  (setq dun-batch-mode t)
  (dun-batch-loop))

(provide 'dunnet)

;; dunnet.el ends here

