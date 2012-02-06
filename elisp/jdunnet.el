;;; jdunnet.el --- Text adventure for Emacs(Japanese version)
;; Modified by HAKASE <hakase2772@yahoo.co.jp>, Since 9/30, 2006
;; Version: 2.01jp-0.04a

;; ���̃v���O������Ron Schnell���̍쐬�����e�L�X�g�A�h�x���`���[�Q�[��
;; dunnet Ver 2.01 �̃��b�Z�[�W����{�ꉻ���������ňꕔ�g���������̂ł��B
;; ���̃Q�[����emacs�n�̃G�f�B�^��œ��삵�܂��B
;; ���F���{��ł͂܂����łł��B�|�󂵂Ă��Ȃ����b�Z�[�W���c���Ă��܂��B
;;     ���̃v���O������|��Ɋւ��鎿���Ron Schnell���ɂ͑���Ȃ�
;;     �ł��������B

;; jdunnet �� ���쌠���� �I���W�i���� dunnet �Ɠ��l GPL �ɏ������܂��B
;; �ȉ��ɃI���W�i���̃v���O�����̃w�b�_�������܂��B
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
;;   �K�v�Ȃ�A�X�R�A�̃��O�t�@�C���������Ȃ��̃V�X�e���̏󋵂ɉ�����
;;   ���������āA�S�Ẵ��[�U�����������\�ɂ��Ă��������B

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
	    (dun-mprinc "����͗����ł��܂���B\n")))
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
      (dun-mprincl "�����͐^���Âł��B���̂܂܂ł̓O�[���ɐH����\���������ł��B")
;    (dun-mprincl (cadr (nth (abs room) dun-rooms)))
    (dun-mprinc "���ꏊ�F ")
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
	    (dun-mprincl "�т�̒��g�F")
	    (dolist (x dun-jar)
	      (dun-mprinc "     ")
	      (dun-mprincl (car (nth x dun-objects)))))))
    (if (and (member obj-bus (nth dun-current-room dun-room-objects)) dun-inbus)
	(dun-mprincl "���Ȃ��̓o�X(bus)�ɏ���Ă��܂��B"))))

;;; There is a special object in the room.  This object's description,
;;; or lack thereof, depends on certain conditions.

(defun dun-special-object ()
  (if (= dun-current-room computer-room)
      (if dun-computer
	  (dun-mprincl 
"�p�l���̃��C�g�͑g�D�����ꂽ�p�^�[����`�����̂悤�ɓ_�ł��Ă��܂��B")
	(dun-mprincl "�p�l���̃��C�g�͕ς�炸��~���Ă��܂��B")))

  (if (and (= dun-current-room red-room) 
	   (not (member obj-towel (nth red-room dun-room-objects))))
      (dun-mprincl "�����̏��ɂ͌�(hole)�������Ă��܂��B"))

  (if (and (= dun-current-room marine-life-area) dun-black)
      (dun-mprincl 
"�����̓u���b�N���C�g�ŏƂ炳��Ă��܂��B���ƁA�����Ă��Ȃ��̎�������
���̌��ɂ���ĕs�C���ɋP���Ă��܂��B"))
  (if (and (= dun-current-room fourth-vermont-intersection) dun-hole)
      (progn
	(if (not dun-inbus)
	    (progn
	      (dun-mprincl"���Ȃ��͒n�ʂ̌��ւƗ����܂����B")
	      (setq dun-current-room vermont-station)
	      (dun-describe-room vermont-station))
	  (progn
	    (dun-mprincl 
"�o�X�͒n�ʂɊJ�������ւƗ����A�����Ĕ������܂����B")
	    (dun-die "burning")))))

  (if (> dun-current-room endgame-computer-room)
      (progn
	(if (not dun-correct-answer)
	    (dun-endgame-question)
    (dun-mprincl "���Ȃ��ւ̎���͎��̒ʂ�ł��F")
    (dun-mprincl (cdr (assoc dun-question-message dun-endgame-questions-msg)))
;	  (dun-mprincl "Your question is:")
;	  (dun-mprincl dun-endgame-question)
)))

  (if (= dun-current-room sauna)
      (progn
	(dun-mprincl (nth dun-sauna-level '(
"���̎������x�͕��ʂł��B"
"�����͂Ȃܒg�����ł��B"
"�����͉��K�ȏ����ł��B"
"�����͍��܂Ŋ��������Ƃ̂Ȃ������ł��B"
"���Ȃ��͍�����ł��܂��B")))
	(if (= dun-sauna-level 3) 
	    (progn
	      (if (or (member obj-rms dun-inventory)
		      (member obj-rms (nth dun-current-room dun-room-objects)))
		  (progn
		    (dun-mprincl 
"���Ȃ��͂��Ȃ��̎����Ă���l�`���Ƃ��͂��߂āA�����Ċ��S�ɂƂ�������
���܂����̂ɋC�����܂����B�����āA���̂��Ƃɂ́A�������_�C�A�����h
(diamond)���c����܂����I")
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
"���Ȃ��͂��Ȃ��̎����Ă���t���b�s�[�f�B�X�N���n���͂��߂Ă���̂�
�C�����܂����B���Ȃ����������ɂƂ�ƁA���������ĔR���o���A���ł���
���܂��܂����B")
		    (dun-remove-obj-from-inven obj-floppy)
		    (dun-remove-obj-from-room dun-current-room obj-floppy))))))))


(defun dun-die (murderer)
  (dun-mprinc "\n")
  (if murderer
      (dun-mprincl "���Ȃ��͎���ł��܂��܂����B\n���f�`�l�d �n�u�d�q"))
  (dun-do-logfile 'dun-die murderer)
  (dun-score nil)
  (setq dun-dead t))

(defun dun-quit (args)
  (dun-die nil))

;;; Print every object in player's inventory.  Special case for the jar,
;;; as we must also print what is in it.

(defun dun-inven (args)
  (dun-mprinc "���Ȃ��͎��̂��̂������Ă��܂�:")
  (dun-mprinc "\n")
  (dolist (curobj dun-inventory)
    (if curobj
	(progn
	  (dun-mprincl (cadr (nth curobj dun-objects)))
	  (if (and (= curobj obj-jar) dun-jar)
	      (progn
		(dun-mprincl "�K���X�т�(jar)�Ɋ܂܂�����:")
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
	    (dun-mprinc (format "���Ȃ��� %s ���ӂ�܂����B\n�����������N���Ȃ����悤�ɂ݂��܂��B\n"
              (downcase (cadr (nth objnum dun-objects)))))
	    )
	(if (and (not (member objnum (nth dun-current-room dun-room-silents)))
		 (not (member objnum (nth dun-current-room dun-room-objects))))
	    (dun-mprincl "����͂����ɂ͌�������܂���B")
;;;     Shaking trees can be deadly
	  (if (= objnum obj-tree)
	      (progn
		(dun-mprinc
 "���Ȃ����؂�U��ƁA�󂩂烄�V�̎��������n�߂�̂ɋC�����܂����B
���Ȃ��͂��������邽�߂Ɏ����ɏグ�悤�Ƃ��܂������A���̑O�ɂ��Ȃ���
���ꂪ���̏�ɗ�����Ռ��������܂����B")
		(dun-die "a coconut"))
	    (if (= objnum obj-bear)
		(progn
		  (dun-mprinc
"���Ȃ��͌F�̂Ƃ���ɋ߂Â��ƁA�F�͂��Ȃ��̓�����苎�����āA
���Ȃ��̓��͒n��ɗ����܂����B")
		  (dun-die "a bear"))
	      (if (< objnum 0)
		  (dun-mprincl "������ӂ邱�Ƃ͂ł��܂���B")
		(dun-mprincl "���Ȃ��͂���������Ă��܂���B")))))))))


(defun dun-drop (obj)
  (if dun-inbus
      (dun-mprincl "�o�X�̒��ł͉����u�����Ƃ͂ł��܂���B")
  (let (objnum ptr)
    (when (setq objnum (dun-objnum-from-args-std obj))
      (if (not (setq ptr (member objnum dun-inventory)))
	  (dun-mprincl "���Ȃ��͂���������Ă��܂���B")
	(progn
	  (dun-remove-obj-from-inven objnum)
	  (dun-replace dun-room-objects dun-current-room
		   (append (nth dun-current-room dun-room-objects)
			   (list objnum)))
	  (dun-mprincl "�u���܂����B")
	  (if (member objnum (list obj-food obj-weight obj-jar))
	      (dun-drop-check objnum))))))))

;;; Dropping certain things causes things to happen.

(defun dun-drop-check (objnum)
  (if (and (= objnum obj-food) (= room bear-hangout)
	   (member obj-bear (nth bear-hangout dun-room-objects)))
      (progn
	(dun-mprincl
"�F�͐H�ו����Ђ���āA����������������܂����B�ނ͉����𗎂Ƃ���
�������悤�ł��B")
	(dun-remove-obj-from-room dun-current-room obj-bear)
	(dun-remove-obj-from-room dun-current-room obj-food)
	(dun-replace dun-room-objects dun-current-room
		 (append (nth dun-current-room dun-room-objects)
			 (list obj-key)))))

  (if (and (= objnum obj-jar) (member obj-nitric dun-jar) 
	   (member obj-glycerine dun-jar))
      (progn
	(dun-mprincl 
	 "�т񂪒n�ʂɂԂ���ƁA����͕��X�ɍӂ��܂����B")
	(setq dun-jar nil)
	(dun-remove-obj-from-room dun-current-room obj-jar)
	(if (= dun-current-room fourth-vermont-intersection)
	    (progn
	      (setq dun-hole t)
	      (setq dun-current-room vermont-station)
	      (dun-mprincl 
"��������������������������������������������������������
�������N����A�n�ʂɌ��������܂����B���Ȃ��͂��̌��ɗ����܂����B")))))

  (if (and (= objnum obj-weight) (= dun-current-room maze-button-room))
      (dun-mprincl "�ʘH���J���܂����B")))

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
	    (dun-mprincl "���ꂪ�����킩��܂���B")
	  (if (and (not (member objnum 
				(nth dun-current-room dun-room-objects)))
		   (not (and (member obj-jar dun-inventory)
			     (member objnum dun-jar)))
		   (not (member objnum 
				(nth dun-current-room dun-room-silents)))
		   (not (member objnum dun-inventory)))
	      (dun-mprincl "����͂����ɂ͌�������܂���B")
	    (if (>= objnum 0)
		(if (and (= objnum obj-bone) 
			 (= dun-current-room marine-life-area) dun-black)
		    (dun-mprincl 
"���̌��ɂ���āA���Ȃ��͍��̏�ɏ����ꂽ������ǂނ��Ƃ��ł��܂��B
�����ɂ͎��̂悤�ɏ����Ă���܂����B
  �u���������鎞�ɂ́A��S�ʂ�ƃo�[�����g�ʂ�̌����_�֍s���B�v")
		  (if (nth objnum dun-physobj-desc)
		      (dun-mprincl (nth objnum dun-physobj-desc))
		    (dun-mprincl "���Ɍ���ׂ����̂͂���܂���B")))
	      (if (nth (abs objnum) dun-permobj-desc)
		  (progn
		    (dun-mprincl (nth (abs objnum) dun-permobj-desc)))
		(dun-mprincl "���Ɍ���ׂ����̂͂���܂���B")))))))))

(defun dun-take (obj)
    (setq obj (dun-firstword obj))
    (if (not obj)
	(dun-mprincl "������邩�𓮎� take �̌��Ɏw�肵�Ă��������B")
      (if (string= obj "all")
	  (let (gotsome)
	    (if dun-inbus
		(dun-mprincl "�o�X(bus)�ɏ���Ă���Ԃ͉������܂���B")
	      (setq gotsome nil)
	      (dolist (x (nth dun-current-room dun-room-objects))
		(if (and (>= x 0) (not (= x obj-special)))
		    (progn
		      (setq gotsome t)
		      (dun-mprinc (cadr (nth x dun-objects)))
		      (dun-mprinc ": ")
		      (dun-take-object x))))
	      (if (not gotsome)
		  (dun-mprincl "���ׂ����̂͂���܂���B"))))
	(let (objnum)
	  (setq objnum (cdr (assq (intern obj) dun-objnames)))
	  (if (eq objnum nil)
	      (progn
		(dun-mprinc "���ꂪ�����킩��܂���B")
		(dun-mprinc "\n"))
	    (if (and dun-inbus (not (and (member objnum dun-jar)
					 (member obj-jar dun-inventory))))
		(dun-mprincl "�o�X(bus)�ɏ���Ă���Ԃ͉������܂���B")
	      (dun-take-object objnum)))))))

(defun dun-take-object (objnum)
  (if (and (member objnum dun-jar) (member obj-jar dun-inventory))
      (let (newjar)
	(dun-mprincl "���Ȃ��͂т񂩂炻�����菜���܂����B")
	(setq newjar nil)
	(dolist (x dun-jar)
	  (if (not (= x objnum))
	      (setq newjar (append newjar (list x)))))
	(setq dun-jar newjar)
	(setq dun-inventory (append dun-inventory (list objnum))))
    (if (not (member objnum (nth dun-current-room dun-room-objects)))
	(if (not (member objnum (nth dun-current-room dun-room-silents)))
	    (dun-mprinc "����͂����ɂ͌�������܂���B")
	  (dun-try-take objnum))
      (if (>= objnum 0)
	  (progn
	    (if (and (car dun-inventory) 
		     (> (+ (dun-inven-weight) (nth objnum dun-object-lbs)) 11))
		(dun-mprinc "���Ȃ��̉ו��͏d�����܂��B")
	      (setq dun-inventory (append dun-inventory (list objnum)))
	      (dun-remove-obj-from-room dun-current-room objnum)
	      (dun-mprinc "���܂����B ")
	      (if (and (= objnum obj-towel) (= dun-current-room red-room))
		  (dun-mprinc 
		   "�^�I�������ƁA���Ɍ��������Ă��邱�Ƃ��킩��܂����B"))))
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
  (dun-mprinc "�������邱�Ƃ͂ł��܂���B"))

(defun dun-dig (args)
  (if dun-inbus
      (dun-mprincl "�����Ō����@���Ă������݂���܂���B")
  (if (not (member 0 dun-inventory))
      (dun-mprincl "���Ȃ��͌@�邽�߂̓���������Ă��܂���B")
    (if (not (nth dun-current-room dun-diggables))
	(dun-mprincl "�����Ō����@���Ă������݂���܂���B")
      (dun-mprincl "�����@��Ɖ������o�Ă��܂����B")
      (dun-replace dun-room-objects dun-current-room
	       (append (nth dun-current-room dun-room-objects)
		       (nth dun-current-room dun-diggables)))
      (dun-replace dun-diggables dun-current-room nil)))))

(defun dun-climb (obj)
  (let (objnum)
    (setq objnum (dun-objnum-from-args obj))
    (cond ((not objnum)
	   (dun-mprincl "���ꂪ�����킩��܂���B"))
	  ((and (not (eq objnum obj-special))
		(not (member objnum (nth dun-current-room dun-room-objects)))
		(not (member objnum (nth dun-current-room dun-room-silents)))
		(not (and (member objnum dun-jar) (member obj-jar dun-inventory)))
		(not (member objnum dun-inventory)))
	   (dun-mprincl "����͂����ɂ͌�������܂���B"))
	  ((and (eq objnum obj-special)
		(not (member obj-tree (nth dun-current-room dun-room-silents))))
	   (dun-mprincl "�����ɂ͓o�����͉̂�������܂���B"))
	  ((and (not (eq objnum obj-tree)) (not (eq objnum obj-special)))
	   (dun-mprincl "���Ȃ��͂���ɓo�邱�Ƃ͂ł��܂���B"))
	  (t
	   (dun-mprincl
	    "���Ȃ��͂Q�t�B�[�g�قǖ؂�o��A�����č~��܂����B
���Ȃ��͖؂��ƂĂ����炮�炵�Ă��邱�ƂɋC�Â��܂����B")))))

(defun dun-eat (obj)
  (let (objnum)
    (when (setq objnum (dun-objnum-from-args-std obj))
      (if (not (member objnum dun-inventory))
	  (dun-mprincl "����������Ă��܂���B")
	(if (not (= objnum obj-food))
	    (progn
	      (dun-mprinc "���Ȃ��� ")
	      (dun-mprinc (downcase (cadr (nth objnum dun-objects))))
	      (dun-mprincl " ���A�ɂ߂��ނƁA���Ȃ��͒������͂��߂܂����B")
	      (dun-die "choking"))
	  (dun-mprincl "����͋��낵���������܂����B")
	  (dun-remove-obj-from-inven obj-food))))))

(defun dun-put (args)
    (let (newargs objnum objnum2 obj)
      (setq newargs (dun-firstwordl args))
      (if (not newargs)
	  (dun-mprincl "�ړI����w�肵�Ă��������B")
	(setq obj (intern (car newargs)))
	(setq objnum (cdr (assq obj dun-objnames)))
	(if (not objnum)
	    (dun-mprincl "���ꂪ�����킩��܂���B")
	  (if (not (member objnum dun-inventory))
	      (dun-mprincl "���Ȃ��͂���������Ă��܂���B")
	    (setq newargs (dun-firstwordl (cdr newargs)))
	    (setq newargs (dun-firstwordl (cdr newargs)))
	    (if (not newargs)
		(dun-mprincl "�Ώۂ��w�肵�Ă��������iput A in B �Ȃǁj�B")
	      (setq objnum2 (cdr (assq (intern (car newargs)) dun-objnames)))
	      (if (and (eq objnum2 obj-computer) (= dun-current-room pc-area))
		  (setq objnum2 obj-pc))
	      (if (not objnum2)
		  (dun-mprincl "�w�肳�ꂽ�Ώۂ������킩��܂���B")
		(if (and (not (member objnum2 
				      (nth dun-current-room dun-room-objects)))
			 (not (member objnum2 
				      (nth dun-current-room dun-room-silents)))
			 (not (member objnum2 dun-inventory)))
		    (dun-mprincl "�w�肳�ꂽ�Ώۂ͂����ɂ͂���܂���B")
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
"���Ȃ����R���s���[�^��CPU�{�[�h������ƁA����͂����ɉғ����܂����B
�����_�ł��͂��߁A�t�@�������͂��߂܂����B"))
    (if (and (= obj1 obj-weight) (= obj2 obj-button))
	(dun-drop '("weight"))
      (if (= obj2 obj-jar)                 ;; Put something in jar
	  (if (not (member obj1 (list obj-paper obj-diamond obj-emerald
				      obj-license obj-coins obj-egg
				      obj-nitric obj-glycerine)))
	      (dun-mprincl "����͂т�ɓ����ɂ͓K���܂���B")
	    (dun-remove-obj-from-inven obj1)
	    (setq dun-jar (append dun-jar (list obj1)))
	    (dun-mprincl "����܂���"))
	(if (= obj2 obj-chute)                 ;; Put something in chute
	    (progn
	      (dun-remove-obj-from-inven obj1)
	      (dun-mprincl 
"���Ȃ�������𒆂ɂ��ׂ�����ƁA���ꂪ�����ւ������𕷂��܂����B")
	      (dun-put-objs-in-treas (list obj1)))
	  (if (= obj2 obj-box)              ;; Put key in key box
	      (if (= obj1 obj-key)
		  (progn
		    (dun-mprincl
"���Ȃ�����������ƁA���͐U�������͂��߂܂��B�����čŌ�ɂ͔�������
���܂��܂����B���͂Ȃ��Ȃ��Ă��܂����悤�Ɍ����܂��I")
		    (dun-remove-obj-from-inven obj1)
		    (dun-replace dun-room-objects computer-room (append
							(nth computer-room
							     dun-room-objects)
							(list obj1)))
		    (dun-remove-obj-from-room dun-current-room obj-box)
		    (setq dun-key-level (1+ dun-key-level)))
		(dun-mprincl "�L�[�{�b�N�X�ɂ͂�������邱�Ƃ͂ł��܂���I"))

	    (if (and (= obj1 obj-floppy) (= obj2 obj-pc))
		(progn
		  (setq dun-floppy t)
		  (dun-remove-obj-from-inven obj1)
		  (dun-mprincl "����܂����B"))

	      (if (= obj2 obj-urinal)                   ;; Put object in urinal
		  (progn
		    (dun-remove-obj-from-inven obj1)
		    (dun-replace dun-room-objects urinal (append 
						  (nth urinal dun-room-objects)
						   (list obj1)))
		    (dun-mprincl
		     "���Ȃ��͂��ꂪ���ɂ��鐅�̒��ɗ����鉹�𕷂��܂����B"))
		(if (= obj2 obj-mail)
		    (dun-mprincl "�X�֎󂯂ɂ͌����������Ă��܂��B")
		  (if (member obj1 dun-inventory)
		      (dun-mprincl 
"�������ǂ��g�ݍ��킹��΂����̂��킩��܂���B
�����P�ɗ��Ƃ�(drop)���邱�Ƃ������Ă݂Ă��������B")
		    (dun-mprincl"���Ȃ��͂���������ɓ���邱�Ƃ͂ł��܂���B")))))))))))

(defun dun-type (args)
  (if (not (= dun-current-room computer-room))
      (dun-mprincl "���Ȃ����^�C�v�ł�����̂͂����ɂ͂���܂���B")
    (if (not dun-computer)
	(dun-mprincl 
"���Ȃ��̓L�[�{�[�h���^�C�v���܂����B�������A���Ȃ��̃^�C�v����������
�\�����炳��܂���ł����B")
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
      (dun-mprinc "�ǂ��֍s���΂����̂��킩��܂���B\n")))

;;; Uses the dungeon-map to figure out where we are going.  If the
;;; requested direction yields 255, we know something special is
;;; supposed to happen, or perhaps you can't go that way unless
;;; certain conditions are met.

(defun dun-move (dir)
  (if (and (not (member dun-current-room dun-light-rooms)) 
	   (not (member obj-lamp dun-inventory)))
      (progn
	(dun-mprinc 
"���Ȃ��̓O�[���ɂ܂Â��Č��ɗ����A�����Ă��Ȃ��̑̂̑S�Ă̍���
�O�[���ɍӂ���Ă��܂��܂����B")
	(dun-die "a grue"))
    (let (newroom)
      (setq newroom (nth dir (nth dun-current-room dungeon-map)))
      (if (eq newroom -1)
	  (dun-mprinc "���Ȃ��͂��̕����֍s�����Ƃ͂ł��܂���B\n")
	(if (eq newroom 255)
	    (dun-special-move dir)
	  (setq room -1)
	  (setq dun-lastdir dir)
	  (if dun-inbus
	      (progn
		(if (or (< newroom 58) (> newroom 83))
		    (dun-mprincl "�o�X�͂����ւ͍s���܂���B")
		  (dun-mprincl 
		   "�o�X�͋}�ɑO���ɌX���A�����ċ}��~���܂����B")
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
	  (dun-mprincl "���Ȃ��̓h�A���J���邽�߂̌��������Ă��܂���B")
	(setq dun-current-room old-building-hallway))
    (if (= dun-current-room north-end-of-cave-passage)
	(let (combo)
	  (dun-mprincl 
"���Ȃ������̕����ɓ���ɂ͂R���̐������^�C�v���Ȃ���΂Ȃ�܂���B")
	  (dun-mprinc " �R���̐����́H : ")
	  (setq combo (dun-read-line))
	  (if (not dun-batch-mode)
	      (dun-mprinc "\n"))
	  (if (string= combo dun-combination)
	      (setq dun-current-room gamma-computing-center)
	    (dun-mprincl "���̐����̑g�ݍ��킹�͕s���ł��B"))))

    (if (= dun-current-room bear-hangout)
	(if (member obj-bear (nth bear-hangout dun-room-objects))
	    (progn
	      (dun-mprinc 
"���Ȃ����F�̂������΂������Ȃ��ɕ����Ēʂ�߂��悤�Ƃ������ƂɁA
�F�͂ƂĂ��՗������悤�ł��B�ނ́A���Ȃ��̓���H�������邱�Ƃ�
����������Ȃɋ����܂����B")
	      (dun-die "a bear"))
	  (dun-mprincl "���Ȃ��͂��̕����ւ͍s���܂���B")))

    (if (= dun-current-room vermont-station)
	(progn
	  (dun-mprincl
"��������������������������������������������������������
�����Ȃ�����Ԃɏ�荞�ނƁA����͂����ɉw���o�܂����B��Ԃ͏㉺���E��
�������h��A���S�n�͍ň��ł��B���Ȃ��͏����ł���ɂ��y�����邽�߂�
�֎q�̂ЂƂɍ���܂����B")
	  (dun-mprincl
"\n�Ō�ɂ͗�Ԃ͓ˑR��~���A�h�A���J���A���̏Ռ��ł��Ȃ��͊O�ւ�
�����o����܂����B�����āA��Ԃ͑��苎��܂����B\n")
	  (setq dun-current-room museum-station)))

    (if (= dun-current-room old-building-hallway)
	(if (and (member obj-key dun-inventory)
		 (> dun-key-level 0))
	    (setq dun-current-room meadow)
	  (dun-mprincl "���Ȃ��̓h�A���J���邽�߂̌��������Ă��܂���B")))

    (if (and (= dun-current-room maze-button-room) (= dir northwest))
	(if (member obj-weight (nth maze-button-room dun-room-objects))
	    (setq dun-current-room 18)
	  (dun-mprincl "���Ȃ��͂����֍s�����Ƃ͏o���܂���B")))

    (if (and (= dun-current-room maze-button-room) (= dir up))
	(if (member obj-weight (nth maze-button-room dun-room-objects))
	    (dun-mprincl "���Ȃ��͂����֍s�����Ƃ͏o���܂���B")
	  (setq dun-current-room weight-room)))

    (if (= dun-current-room classroom)
	(dun-mprincl "�h�A�̓��b�N����Ă��܂��B"))

    (if (or (= dun-current-room lakefront-north) 
	    (= dun-current-room lakefront-south))
	(dun-swim nil))

    (if (= dun-current-room reception-area)
	(if (not (= dun-sauna-level 3))
	    (setq dun-current-room health-club-front)
	  (dun-mprincl
"���Ȃ�����������o�悤�Ƃ����Ƃ��A���̂ЂƂ��牊���o�Ă���̂�
�C���t���܂����B�ˑR�A�����͋���ȉ΂̋ʂƂȂ��Ĕ������܂����B
�������Ȃ��̑̂��̂ݍ��݁A���Ȃ��͏Ă�����ł��܂��܂����B")
	  (dun-die "burning")))

    (if (= dun-current-room red-room)
	(if (not (member obj-towel (nth red-room dun-room-objects)))
	    (setq dun-current-room long-n-s-hallway)
	  (dun-mprincl "���Ȃ��͂����֍s�����Ƃ͏o���܂���B")))

    (if (and (> dir down) (> dun-current-room gamma-computing-center) 
	     (< dun-current-room museum-lobby))
	(if (not (member obj-bus (nth dun-current-room dun-room-objects)))
	    (dun-mprincl "���Ȃ��͂����֍s�����Ƃ͏o���܂���B")
	  (if (= dir in)
	      (if dun-inbus
		  (dun-mprincl
		   "���Ȃ��͊��Ƀo�X�̒��ɂ��܂��I")
		(if (member obj-license dun-inventory)
		    (progn
		      (dun-mprincl 
		       "���Ȃ��̓o�X�ɏ�荞�݁A�^�]�Ȃɓ���܂����B")
		      (setq dun-nomail t)
		      (setq dun-inbus t))
		  (dun-mprincl "���Ȃ��͂��̎�̏�蕨���^�]���邽�߂̖Ƌ��؂������Ă��܂���B")))
	    (if (not dun-inbus)
		(dun-mprincl "���Ȃ��͊��Ƀo�X����~��Ă��܂��I")
	      (dun-mprincl "���Ȃ��̓o�X�����э~��܂����B")
	      (setq dun-inbus nil))))
      (if (= dun-current-room fifth-oaktree-intersection)
	  (if (not dun-inbus)
	      (progn
		(dun-mprincl "���Ȃ��͊R�̉��ɂ������܂ɗ������A����n�ʂɂԂ��܂����B")
		(dun-die "a cliff"))
	    (dun-mprincl
"�o�X�͊R�ւƔ�яo���A�R�̒�ւƓ˂����݁A�����Ĕ������܂����B")
	    (dun-die "a bus accident")))
      (if (= dun-current-room main-maple-intersection)
	  (progn
	    (if (not dun-inbus)
		(dun-mprincl "��͊J���Ȃ��ł��傤�B")
	      (dun-mprincl
"��������������������������������������������������������
���o�X���߂Â��Ɩ傪�J���A���Ȃ��͂�����ʉ߂��܂����B")
	      (dun-remove-obj-from-room main-maple-intersection obj-bus)
	      (dun-replace dun-room-objects museum-entrance 
		       (append (nth museum-entrance dun-room-objects)
			       (list obj-bus)))
	      (setq dun-current-room museum-entrance)))))
    (if (= dun-current-room cave-entrance)
	(progn
	  (dun-mprincl
"��������������������������������������������������������
�����Ȃ��������ɓ���ƁA�������܂���������Ђт��܂����B
���Ȃ����ӂ肩����ƁA�V�䂩�狐��Ȋ₪���藎���A���Ȃ�����������
�ӂ����̂������܂����B\n")
	  (setq dun-current-room misty-room)))))

(defun dun-long (args)
  (setq dun-mode "long"))

(defun dun-turn (obj)
  (let (objnum direction)
    (when (setq objnum (dun-objnum-from-args-std obj))
      (if (not (or (member objnum (nth dun-current-room dun-room-objects))
		   (member objnum (nth dun-current-room dun-room-silents))))
	  (dun-mprincl "����͂����ɂ͌�������܂���B")
	(if (not (= objnum obj-dial))
	    (dun-mprincl "����͉�]�ł��܂���B")
	  (setq direction (dun-firstword (cdr obj)))
	  (if (or (not direction) 
		  (not (or (string= direction "clockwise")
			   (string= direction "counterclockwise"))))
	      (dun-mprincl "���߂ɑ����Ď��v����(clockwise)�������v����(counterclockwise)����
�w�肵�Ă��������B�i�� turn A clockwise�j")
	    (if (string= direction "clockwise")
		(setq dun-sauna-level (+ dun-sauna-level 1))
	      (setq dun-sauna-level (- dun-sauna-level 1)))
	    
	    (if (< dun-sauna-level 0)
		(progn
		  (dun-mprincl 
		   "�_�C�A���͂���ȏセ����̕����։񂷂��Ƃ͂ł��Ȃ��ł��傤�B")
		  (setq dun-sauna-level 0))
	      (dun-sauna-heat))))))))

(defun dun-sauna-heat ()
  (if (= dun-sauna-level 0)
      (dun-mprincl 
       "���x�͕W���I�Ȏ������x�ɖ߂�܂����B"))
  (if (= dun-sauna-level 1)
      (dun-mprincl "��C���Ȃܒg���Ȃ�܂����B���Ȃ��͊��������Ă��܂��B"))
  (if (= dun-sauna-level 2)
      (dun-mprincl "�����͍����Ȃ菋���ł��B�܂��ƂĂ����K�ł��B"))
  (if (= dun-sauna-level 3)
      (progn
	(dun-mprincl 
"�����͍��ƂĂ��Ȃ������ł��B���̉��x�ɂ͐��܂�ς��悤�ȉ���������܂��B")
	(if (or (member obj-rms dun-inventory) 
		(member obj-rms (nth dun-current-room dun-room-objects)))
	    (progn
	      (dun-mprincl 
"���Ȃ��͂��Ȃ��̎����Ă���l�`���Ƃ��͂��߂āA�����Ċ��S�ɂƂ�������
���܂����̂ɋC�����܂����B�����āA���̂��Ƃɂ́A�������_�C�A�����h
(diamond)���c����܂����I")
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
"���Ȃ��͂��Ȃ��̎����Ă���t���b�s�[�f�B�X�N���n���͂��߂Ă���̂�
�C�����܂����B���Ȃ����������ɂƂ�ƁA���������ĔR���o���A���ł���
���܂��܂����B")
	      (if (member obj-floppy dun-inventory)
		  (dun-remove-obj-from-inven obj-floppy)
		(dun-remove-obj-from-room dun-current-room obj-floppy))))))

  (if (= dun-sauna-level 4)
      (progn
	(dun-mprincl 
"�_�C�A�������̏ꏊ�������ƁA���Ȃ��͓̑̂ˑR���ŔR���オ��܂����B")
	(dun-die "burning"))))

(defun dun-press (obj)
  (let (objnum)
    (when (setq objnum (dun-objnum-from-args-std obj))
      (if (not (or (member objnum (nth dun-current-room dun-room-objects))
		   (member objnum (nth dun-current-room dun-room-silents))))
	  (dun-mprincl "����͂����ɂ͌�������܂���B")
	(if (not (member objnum (list obj-button obj-switch)))
	    (progn
	      (dun-mprinc "You can't ")
	      (dun-mprinc (car line-list))
	      (dun-mprincl " that."))
	  (if (= objnum obj-button)
	      (dun-mprincl
"���Ȃ����{�^���������ƁA�ʘH���J���̂ɋC�����܂����B�������{�^����
�����ƁA���̒ʘH�͕��Ă��܂��܂����B"))
	  (if (= objnum obj-switch)
	      (if dun-black
		  (progn
		    (dun-mprincl "�{�^���͍��I�t�̏�ԂɂȂ��Ă��܂��B")
		    (setq dun-black nil))
		(dun-mprincl "�{�^���͍��I���̏�ԂɂȂ��Ă��܂��B")
		(setq dun-black t))))))))

(defun dun-swim (args)
  (if (not (member dun-current-room (list lakefront-north lakefront-south)))
      (dun-mprincl "�j����悤�Ȑ��͌�������܂���I")
    (if (not (member obj-life dun-inventory))
	(progn
	  (dun-mprincl 
"���Ȃ��͌΂ɔ�э��݁A�����ł͂��߂Đ������ɗ₽�����ƂɋC�Â��܂����B
�����āA���Ȃ����A���͂܂Ƃ��ɂ͉j�����w��ł��Ȃ������񂾂ƌ��ɂ��
���Ȃ��͂��̕X�̂悤�ȗ₽���Ɋ���͂��߂Ă��܂����B")
	  (dun-die "drowning"))
      (if (= dun-current-room lakefront-north)
	  (setq dun-current-room lakefront-south)
	(setq dun-current-room lakefront-north)))))


(defun dun-score (args)
  (if (not dun-endgame)
      (let (total)
	(setq total (dun-reg-score))
	(dun-mprinc "���Ȃ��̍��v���_��")
	(dun-mprinc total)
	(dun-mprincl "�_�ł��i�擾�\�ȓ��_��90�_�ł��j�B") total)
    (dun-mprinc "���Ȃ��̍��v���_��")
    (dun-mprinc (dun-endgame-score))
    (dun-mprincl " �_�ł��i�Q�[���N���A���̍ō����_��110�_�ł��j�B")
    (if (= (dun-endgame-score) 110)
;    (if (= (dun-endgame-score) 90)
	(dun-mprincl 
"\n\n���������߂łƂ��B���Ȃ��͏������܂����B������
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
"�悤����jdunnet�ցB�����Ron Schnell����dunnet(2.01)����{�ꉻ����
���̂ł��B�����ł͗L�v�ȏ���񋟂��܂��i�����ɂ͑����̎肪���肪
������Ă���̂ŁA���ӂ��ēǂ�ł��������B�j

�������A�h�A���J���邱�Ƃ��ł���L�[(key)�������Ă���΁A���Ȃ���
  �h�A���J���铮�����͂���K�v�͂���܂���B���Ȃ��͒P�Ɂuin�v��
  �g�����A�h�A�̂�������֕��������Ńh�A�ɓ��邱�Ƃ��ł��܂��B
���������Ȃ��������v�������Ă���΁A���ł��_��(lit)�ł��܂��B

�����Ȃ����������ꏊ�Ɏ����Ă������Ƃɐ�������܂ł́A���Ȃ���
  ���_�𓾂邱�Ƃ��ł��܂���B�P�ɕ�������邾���ł͕s�\���ł��B
  �����ʂȏꏊ�֎����Ă������@�͂ЂƂł͂���܂���B
  ���̃��m���u�󂳂��Ɂv�u�������Ɂv�����Ă������Ƃ��d�v�ł��B
  ���_�͂����ɕω�����̂ŁA���� score �œ��_������΂��Ȃ������m��
  �ړ��ɐ����������ǂ�������܂��B
  ���_�𓾂�����A���̃��m����ꂽ�肵�Ȃ��悤�ɒ��ӂ��Ă��������B
  �������ꂪ�N����Γ��_������A�����Č��̓��_�ɖ߂邱�Ƃ͂Ȃ��ł��傤�B

�����Ȃ��́A�R�}���h�usave�v�ŃQ�[�����ꎞ�ۑ����邱�Ƃ��ł��܂��B
  �����āA�R�}���h�urestore�v�ɂ���āA��������ĊJ���邱�Ƃ��ł��܂��B
���I�u�W�F�N�g���̒����ɂ͐���������܂���B

���ړ��́F�k north, �� south, �� east, �� west,�k�� northeast , 
          �쓌 southeast , �k�� northwest, �k�� southwest ,
          �� up, �� down, ���� in , �o�� out ,���g���܂��B
�������� ���̒Z�k�`�ł����͂ł��܂��B n,s,e,w,ne,se,nw,sw,u,d,in,out 

���������Ȃ����n�V�S�̂悤�Ȏx���Ȃ��ŏ��ɂ��������ɉ��肽�Ȃ�΁A
  �����炭���Ȃ��͏�ɓo�邱�Ƃ͂ł��Ȃ��Ȃ�ł��傤�B

�����̃Q�[�����iemacs�̃E�C���h�E�ł͂Ȃ��j�o�b�`���[�h�œ������ɂ́A
  UNIX��Shell��ŉ��L�̃R�}���h�����s���Ă��������B
     emacs -batch -l dunnet
���ӁF���̃Q�[���̓o�b�`���[�h�œ������ׂ��ł��I

�p��̃I���W�i���̐�����ǂނɂ� �R�}���h helpeng �����s���Ă��������B
���ȉ��͓��{��ł̃I�}�P
  �uUNIX�̊ȈՐ����v��ǂނɂ� �R�}���h helpunix �����s���Ă��������B
  �uDos PC �̊ȈՐ����v��ǂނɂ� �R�}���h helpdos �����s���Ă��������B
  �u�������X�g�v������ɂ̓R�}���hhelpverb�����s���Ă��������B
"))
(defun dun-helpunix (args)
  (dun-mprincl
"�uUNIX�̊ȈՐ����v
�E���p�̊J�n�ƏI���F  Login  ���p���J�n����葱���B
    ���[�U���ƃp�X���[�h���K�v�B���[�U���ɂ͈�ʂɐl�̖��O��p����B
�E�R�}���h
   exit �s���p���I������t
   ls  �s���݂���f�B���N�g���̒��ɂ���t�@�C���̖��O��\���t
     �t�@�C���ɂ�[�f�B���N�g��]��[�����t�@�C��]��[�Q�i�t�@�C��]������B
     �E�[�ɏ����ꂽ�����񂪃t�@�C�����B
     ���[�̋L���� d �Ȃ�f�B���N�g���B - �Ȃ當���܂��͂Q�i�t�@�C���B
   pwd �s���݂̃f�B���N�g����\������t
   cd <�f�B���N�g����>  �s�ʂ̃f�B���N�g���ֈړ��t
     ��F cd ..    �^�ЂƂ�̃f�B���N�g���ֈړ��B
          cd user  �^user�Ƃ������O�̃f�B���N�g���ֈړ��B
   cat <�����t�@�C����> �s�����t�@�C���̋L�^���e���o�́t
   uncompress <���k�t�@�C����> �s���k���ꂽ�t�@�C�������ɖ߂��t
     ���k�t�@�C���ɂ̓t�@�C�����̌��� .Z �Ƃ����L��������B
   rlogin <�z�X�g�R���s���[�^��> �s�l�b�g���[�N����ĕʂ̃z�X�g�Ƀ��O�C���t
     ���[�U���ƃp�X���[�h���K�v�B
     ���u�n�ɂ���R���s���[�^�Ƀ��O�C�����Ďg�p����B
     �i���̊ԁA���ݎg�p���̃R���s���[�^�͎g�p�ł��Ȃ��Ȃ�j
   ftp <�z�X�g�R���s���[�^��>
     ���[�U���ƃp�X���[�h���K�v�B�����ł̃��O�C���ɂ̓��[�U�� anonymous �𗘗p�B
"))
(defun dun-helpdos (args)
  (dun-mprincl
"�uDos-PC�̊ȈՐ����v
�E���p�̊J�n�ƏI���F
    �t���b�s�[�f�B�X�N���Z�b�g���ēd�������Ȃ����ireset�j����ƋN������B
    �N���p�̃V�X�e������͑S�ăt���b�s�[�f�B�X�N�̒��ɓ����Ă���B
    �N�����Ɏ�������͂���悤������邪�A�������͂�����Enter�������ėǂ��B

�E�R�}���h
   exit �s���p���I������t
   dir  �s���݂���f�B���N�g���̒��ɂ���t�@�C���̖��O��\���t
     COMMAND  COM     47845 05-01-04   2:00
     AUTOEXEC BAT        24 05-27-04   1:01
     SAMPLE   TXT       102 06-12-08   0:00
        3 file(s)     47971 bytes
     ��L�̕\���ł́Acommand.com, autoexec.bat, sample.txt �Ƃ���
     ���O�̂R�̃t�@�C�������݂��邱�Ƃ��Ӗ�����B

   type <�����t�@�C����> �s�����t�@�C���̋L�^���e���o�́t
     ��F type sample.txt  
          �isample.txt �Ƃ������O�̃t�@�C���̒��g��\������j
"))
(defun dun-helpverb (args)
  (dun-mprincl
"�����̃��X�g�i�ꕔ�����j
  answer�i������j,board/on�i���j,break�i�󂷁j,chop/cut�i�؂�j,
  climb�i�o��j,drop�i�u���j, dig�i�@��j,drive�i�^�]����j,
  enter/in�i����j,exit/out�i�o��j,eat�i�H�ׂ�j,flush�i�r�������j,
  get/take�i���j,go�i�s���j,look/examine/read�i����j,
  press/push�i�����j,put/insert�i����� put A in B�j,reset�i�d�������Ȃ����j,
  shake/wave�i�U��j,sleep/lie�i�Q��j,swin�i�j���j,
  throw�i������j,turn�i�܂킷�j,type�i���͂���j, urinate/piss�i���ւ�����j,
����
  score �X�R�A������i�Q�[�����N���A����Ə܎^�̃��b�Z�[�W���\�������j
  inventory/i �i������������j
  save �t�@�C����    �i�w�肵�����O�̃t�@�C�����쐬���ăQ�[����ۑ�����j
  restore �t�@�C���� �i�w�肵���t�@�C����ǂݍ���ŃQ�[�����ĊJ����j
�ړ�
  east/e�i���j,west/w�i���j,south/s�i��j,north/n�i�k�j,southeast/se�i�쓌�j,
  southwest/sw�i�쐼�j,northeast/ne�i�k���j,northwest/nw�i�k���j,
  up/u�i��j,down/d�i���j
  
"
))

(defun dun-flush (args)
  (if (not (= dun-current-room bathroom))
      (dun-mprincl "�􂢗������̂͂���܂���B")
    (dun-mprincl "Whoooosh!!�i�W���@�@�@�[�|�|�|�|�b�I�I�j")
    (dun-put-objs-in-treas (nth urinal dun-room-objects))
    (dun-replace dun-room-objects urinal nil)))

(defun dun-piss (args)
  (if (not (= dun-current-room bathroom))
      (dun-mprincl "�����ł͂���͂ł��܂��񂵁A���Ȃ��͂�������悤�Ƃ��炵�܂���B")
    (if (not dun-gottago)
	(dun-mprincl "���Ȃ�������������ׂ��ł͂Ȃ��ł��傤�B")
      (dun-mprincl "�C�����悩�����ł��B")
      (setq dun-gottago nil)
      (dun-replace dun-room-objects urinal (append 
					    (nth urinal dun-room-objects)
					    (list obj-URINE))))))


(defun dun-sleep (args)
  (if (not (= dun-current-room bedroom))
      (dun-mprincl
"���Ȃ��͗������܂܂����ŐQ�悤�Ƃ��܂������A����͂ł��Ȃ��悤�ł��B")
    (setq dun-gottago t)
    (dun-mprincl
"���Ȃ��́A����ɂ��Ƃ����ɖ������܂����B���C�ƔM�̒��œz��̂悤��
���A���@���ē����Ă���J���҂̎p�������܂��B���Ȃ��͂��̘J���҂̂ЂƂ�
�������ł��鎖�ɋC�Â��܂��B�N�����Ă��Ȃ��ԂɁA���Ȃ��̓O���[�v��������
�����ւƕ����Ă����܂��B���̕����͂Ă��ĂɎ����`�������傫�ȐΈȊO�ɂ�
��������܂���B���Ȃ��͂��Ȃ����g���n�ʂɌ����@��A���̒��ɉ�����
�󕨂����A���̌�ōĂь��ɓy�������Ė��߂Ă���̂����܂��B
���̒���ɁA���Ȃ��͖ڂ��o�܂��܂����B")))

(defun dun-break (obj)
  (let (objnum)
    (if (not (member obj-axe dun-inventory))
	(dun-mprincl "���Ȃ��͉������󂷂��߂̓�������������Ă��܂���B")
      (when (setq objnum (dun-objnum-from-args-std obj))
	(if (member objnum dun-inventory)
	    (progn
	      (dun-mprincl
"���Ȃ��͂��̂��̂���ɂƂ�A�����ӂ�܂����B�������s�K�ɂ����Ȃ���
�������m�ɓ��Ă�̂Ɏ��s���A���؂��Ă��܂��܂����B
���Ȃ��͏o�����ʂŎ��S���܂��B")
	      (dun-die "an axe"))
	  (if (not (or (member objnum (nth dun-current-room dun-room-objects))
		       (member objnum 
			       (nth dun-current-room dun-room-silents))))
	      (dun-mprincl "����͂����ɂ͌�������܂���B")
	    (if (= objnum obj-cable)
		(progn
		  (dun-mprincl 
"���Ȃ����C�[�T�l�b�g�̃P�[�u����ؒf����ƁA���ׂĂ��ڂ����
�����݂͂��߂܂����B���Ȃ��͈�u�C�������A�������Ĉӎ������߂��܂����B")
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
		  (dun-mprincl "Connection closed.�i�ڑ��I���j")
		  (dun-unix-interface))
	      (if (< objnum 0)
		  (progn
		    (dun-mprincl "���͂��Ȃ��Ȃɍӂ��U���Ă��܂��܂����B")
		    (dun-remove-obj-from-inven obj-axe))
		(dun-mprincl "���͂�������Ȃ��Ȃɉ󂵂܂����B")
		(dun-remove-obj-from-room dun-current-room objnum)))))))))

(defun dun-drive (args)
  (if (not dun-inbus)
      (dun-mprincl "��蕨���Ȃ���΁A���Ȃ��͉^�]���邱�Ƃ��ł��܂���B")
    (dun-mprincl "�o�X�ɏ���Ă���Ԃ́A���p����͂��邾���ŉ^�]�ł��܂��B")))

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
      (dun-mprincl "�N�����Ȃ��ɓ��������߂Ă��Ȃ��͂��ł��B")
    (setq args (car args))
    (if (not args)
	(dun-mprincl "���� answer �̌��ɓ������L�q���Ă��������B")
      (if (dun-members args dun-correct-answer)
	  (progn
	    (dun-mprincl "�����B")
	    (if (= dun-lastdir 0)
		(setq dun-current-room (1+ dun-current-room))
	      (setq dun-current-room (- dun-current-room 1)))
	    (setq dun-correct-answer nil))
	(dun-mprincl "���̉񓚂͊Ԉ���Ă��܂��B")))))

(defun dun-endgame-question ()
(if (not dun-endgame-questions)
    (progn
      (dun-mprincl "���Ȃ��ւ̎���͎��̒ʂ�ł��F")
      (dun-mprincl " ��������͂���܂���B'answer foo' �Ɠ��͂��Ă��������B.")
      (setq dun-correct-answer '("foo"))
      (setq dun-question-message "-1"))
  (let (which i newques)
    (setq i 0)
    (setq newques nil)
    (setq which (random (length dun-endgame-questions)))
    (dun-mprincl "���Ȃ��ւ̎���͎��̒ʂ�ł��F")
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
      (dun-mprincl "���̑���͂����ł͏o���܂���B")
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
		(dun-mprincl "���Ȃ��͂���ɐH�ׂ�������̂����������Ă��܂���B")
	      (dun-drop '("food"))))
	(if (not (or (member objnum (nth dun-current-room dun-room-objects))
		     (member objnum dun-inventory)
		     (member objnum (nth dun-current-room dun-room-silents))))
	    (dun-mprincl "����͂����ɂ͌�������܂���B")
	  (dun-mprincl "���Ȃ��͂���ɐH�ׂ�����(feed)���Ƃ͂ł��܂���B
�i�����ɂ͐H�ׂ����鑊����w�肵�Ă��������j"))))))


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
      (dun-mprincl "�ړI���^����K�v������܂��B"))
  (if (eq result nil)
      (dun-mprincl "���ꂪ�����킩��܂���B"))
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
;;---------------XEmacs �Ƃ���ȊO�ŏ�����ύX
(if (boundp 'xemacsp)
; XEmacs�̏ꍇ
 (defvar dungeon-batch-map
  (let ((map (make-keymap))
        (n 32))
    (while (< 0 (setq n (- n 1)))
      (define-key map (make-string 1 n) 'dungeon-nil))
    (define-key map "\r" 'exit-minibuffer)
    (define-key map "\n" 'exit-minibuffer)
    map)) 
 (progn
; ����ȊO
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
"���Ȃ��͕󕨌ɂɂ��܂��B�k(north)�ɂ̓h�A������܂��B"
               "Treasure room" "�󕨌�"
	       )
	      (
"���Ȃ��ܑ͕�����Ă��Ȃ����̍s���~�܂�ɂ��܂��D���͓�(east,E)�ւƑ�����
���܂��D���̓��������̕��łQ��ɕ�����Ă���̂������܂��D
�����ɂ͂ƂĂ��w�̍������V�̖�(palm)�������Ă���C�����݂͌��ɓ��Ԋu��
�Ȃ��ł��܂��D"
	       "Dead end" "�s���~�܂�"
	       )
	      (
"���Ȃ��ܑ͕�����Ă��Ȃ����̓r���ɂ��܂��D���Ȃ��̍��E�ɂ͑����؁X��
�����Ă��܂��D���͓�(east,E)�Ɛ�(west,E)�ɑ����Ă��܂��D"
               "E/W Dirt road" "�����ɑ�����"
	       )
	      (
"���Ȃ��͂Q��ɕ����ꂽ���̕���_�ɂ��܂��D����̓��͖k��(northeast,NE)�C
��������̓��͓쓌(southeast,SE�j�ւƑ����Ă��܂��D�����̒n�ʂ͂ƂĂ�
���炩���悤�ł��D���Ȃ��͐�(west,W)�ւƖ߂邱�Ƃ��ł��܂��D"
               "Fork" "���̕���_"
	       )
	      (
"���Ȃ��́C�k��(NE)�Ɠ쐼(SW�j�ւƑ������̓r���ɂ��܂��D"
               "NE/SW road" "�k��-�쐼���Ȃ���"
	       )
	      (
"���Ȃ��͓��̂͂���ɂ��܂��D���Ȃ��̖ڂ̑O�C�k��(NE)�̕��p�Ɍ�����
����܂��D����̓��͓쐼(SW)�ւƑ����Ă��܂��D"
               "Building front" "�����̑O"
	       )
	      (
"���Ȃ��́C�쓌(SE)�Ɩk��(NW�j�ւƑ������̓r���ɂ��܂��D"
               "SE/NW road" "�쓌-�k�����Ȃ���"
	       )
	      (
"���Ȃ��͓��̍s���~�܂�ɗ����Ă��܂��D�߂铹�͖k��(NW)�ɂ���܂��D"
               "Bear hangout" "�F�̏Z�݂�"
	       )
	      (
"���Ȃ��͌Â������̘L���ɂ��܂��D��(E)�Ɛ�(W)�ɕ���������C
�k(N)�Ɠ�(S)�ɊO�֒ʂ���h�A������܂��D"
               "Old Building hallway" "�Â������̘L��"
	       )
	      (
"���Ȃ��͗X�֕��̕����̒��ɂ��܂��B�X�֕�(mail)�����Ă������߂̐�������
�唠(bin)������܂��B�����̏o���͐�(W)�ł��B"
               "Mailroom" "�X�֕��̕���"
	       )
	      (
"���Ȃ��͌v�Z�@���̒��ɂ��܂��B���u�̑啔���͎�菜����Ă���悤�ł��B
���Ȃ��̖ڂ̑O�ɂ́AVAX 11/780 �̃R���s���[�^(computer)������܂��B
�������A�R���s���[�^�̃L���r�l�b�g�̂ЂƂ��L���J���Ă��܂��B
�@�B�̑O�ʂ̏�ɂ͎��̂悤�ɏ�����Ă��܂��B
              �u���� VAX �̖��O�� 'pokey'�B�v
�R���\�[����p���ē��͂���ɂ́A���� 'type' ���g���Ă��������B
�o���͓�(E)�ɂ���܂��B"
               "Computer room" "�v�Z�@��"
	       )
	      (
"���Ȃ��͌Â������̌�ɂ���q���n�ɂ��܂��B�����ȏ�������(W)�ւƑ�����
���܂��B��(S)�ɂ̓h�A������܂��B"
               "Meadow" "�q���n"
	       )
	      (
"���Ȃ��͓�(E)�Ƀh�A������A�΂łł����ۂ������̒��ɂ��܂��B
�ǂɂ́ureceiving room�v�Ɠǂ߂镶����������Ă���B"
               "Receiving room" "��M���[��"
	       )
	      (
"���Ȃ��͖k(N)�ւƑ����L���̓�(S)�̒[�ɂ��܂��B
��(E)�Ɛ�(W)�ɕ���������܂��B"
               "Northbound Hallway" "�k�֑����L��"
	       )
	      (
"���Ȃ��̓T�E�i�ɂ��܂��B�ǂɂ���_�C�A��(dial)�ȊO�ɂ͕����ɉ���
����܂���B�h�A�͐�(W)�̊O�ւƓ����܂��B"
               "Sauna" "�T�E�i"
               )
	      (
"���Ȃ��͓�(S)�Ɩk(N)�ɑ����L���̖k�̒[�ɂ��܂��B���Ȃ��͓�(S)�ɖ߂邱�Ƃ��A
��(E)�ɂ��镔���ւƏo�邱�Ƃ��ł��܂��B"
               "End of N/S Hallway" "�k-����Ȃ��L���̒["
	       )
	      (
"���Ȃ��͌Â��E�G�C�g���[���ɂ��܂��B�S�Ẵg���[�j���O�@��͌̏Ⴕ��
���邩�A���邢�͊��S�ɉ��Ă��܂��B��(W)�ɊO�֏o��h�A������A
���ɊJ������(hole)�֍~���(down,D)���߂̃n�V�S(ladder)������܂��B"
               "Weight room" "�E�G�C�g���[��"                ;16
	       )
	      (
"���Ȃ��́A�S�Ă����ʂ����A�Ȃ��肭�˂����ׂ����̖��H�ɂ��܂��B
�����̒n�ʂ̏�ɂ̓{�^��(button)������܂��B"
               "Maze button room" "���H�F�{�^�����[��"
	       )
	      (
"���Ȃ��́A�S�Ă����ʂ����A�Ȃ��肭�˂����ׂ����̖��H�ɂ��܂��B"
               "Maze" "���H"
	       )
	      (
"���Ȃ��́A�S�Ă����ʂ����A�Ȃ��肭�˂������̖��H�ɂ��܂��B"
               "Maze" "���H"    ;19
	       )
	      (
"���Ȃ��́A�S�Ă��ގ������A�Ȃ��肭�˂����ׂ����̖��H�ɂ��܂��B"
               "Maze" "���H"
	       )
	      (
"���Ȃ��́A�S�Ă����ʂ����A�ׂ��ċȂ��肭�˂������H�ɂ��܂��B"
               "Maze" "���H"   ;21
	       )
	      (
"���Ȃ��́A�S�Ă����ʂ����A�Ȃ��肭�˂����ׂ��H�̖��H�ɂ��܂��B"
               "Maze" "���H"   ;22
	       )
	      (
"���Ȃ��͌��N�t�B�b�g�l�X�Z���^�[�̎�t���[���ɂ��܂��B
���̏ꏊ�͍ŋߗ��D���ꂽ�悤�ŁA�����c���Ă��܂���B
��(S)�ɊO�֏o��h�A�A�쓌(SE)�ɖ��H�ւ̓���������܂��B"
               "Reception area" "��t���[��"
	       )
	      (
"���Ȃ��͖k(N)�ɂ��錒�N�t�B�b�g�l�X�Z���^�[�������ł��낤�傫�Ȍ�����
�O�ɂ��܂��B���͓�(S)�֑����Ă��܂��B"
               "Health Club front" "�w���X�N���u�̑O"
	       )
	      (
"���Ȃ��͌�(lake)�̖k��(N)�ɂ��܂��B�΂̌������݂ɂ́A���A�ւƑ�������
����̂������܂��B���͂ƂĂ��[���悤�ł��B"
               "Lakefront North" "�΂̖k���̊�"
	       )
	      (
"���Ȃ��͌�(lake)�̓쑤(S)�ɂ��܂��B���͓�(S)�ɑ����Ă��܂��B"
               "Lakefront South" "�΂̓쑤�̊�"
	       )
	      (
"���Ȃ��͓����班�����ꂽ�A�B���ꂽ�G���A�ɂ��܂��B
�k��(NE)�ɂ���G�ؗт̌������ɁA�F�̏Z�݂��������܂��B"
               "Hidden area" "�B���ꂽ�G���A"
	       )
	      (
"���A�̓�����͓�(S)�ɂ���܂��B�k(N)�́A�[���΂֌��������ł��B
�������΂̒n�ʂɂ̓V���[�g(chute)������A�����ɊŔ�����܂��B
�����ɂ́u���_�𓾂�ɂ͕󕨂������֓����(put)�B�v�Ə�����Ă��܂��B"
               "Cave Entrance" "���A�̓����"                     ;28
	       )
	      (
"���Ȃ��͎R�̒��ɂ���ꂽ�A���̗������߂邵�߂��ۂ������ɂ��܂��B
�k(N)�ɂ͊����̌オ����܂��B��(E)�ɈÈłւƑ����ʘH������܂��B"              ;29
               "Misty Room" "�����������߂�����"
	       )
	      (
"���Ȃ��͓�(E),��(W)�ɑ����ʘH�ɂ��܂��B�����̕ǂ͗l�X�ȐF�̊��
�ł��Ă��āA�ƂĂ��Y��ł��B"
               "Cave E/W passage" "��-���֑������A�̒ʘH"                  ;30
	       )
	      (
"���Ȃ��͓��A�̕����ꓹ�ɂ��܂��B�k(N)�A��(S)�̑��ɁA��(W)�ւ�
�s���܂��B"
               "N/S/W Junction" "�k�E��E���̕����ꓹ"                    ;31
	       )
	      (
"���Ȃ��͓�-�k(S/N)�ɂ̂т�ʘH�̖k�̒[�ɂ��܂��B�������牺(D)�ւ�
�~��邽�߂̊K�i������܂��B��(W)�ɍs�����߂̃h�A������܂��B"
               "North end of cave passage" "���A�̒ʘH�̖k�["        ;32
	       )
	      (
"���Ȃ��͓�-�k(S/N)�ɂ̂т�ʘH�̓�̒[�ɂ��܂��B�����̏��ɂ͌�(hole)��
�����Ă��܂��B���傤�ǂ��Ȃ�������̂ɂ����傫���̌��ł��B"
               "South end of cave passage" "���A�̒ʘH�̓�["        ;33
	       )
	      (
"���Ȃ��J���҂̃x�b�h���[���̂悤�ȏꏊ�ɂ��܂��B�����̒����ɂ�
�N�C�[���T�C�Y�̃x�b�h(bed)������A�ǂɂ͊G(painting)���������Ă��܂��B
��(S)�ɂ͕ʂ̕����ւ̃h�A������A��(U)�Ɖ�(D)�֍s�����߂̊K�i��
����܂��B"
               "Bedroom" "�x�b�h���[��"                         ;34
	       )
	      (
"���Ȃ��͓��A�̒��ɂ���J���҂̂��߂̃o�X���[���ɂ��܂��B
���֊�(urinal)���ǂɂ��Ă��܂��B�����āA���Α��̕ǂł�
�V���N�Ŏg�����߂̃p�C�v(pipe)�������o���ɂȂ��Ă��܂��B
�k(N)�ɂ̓x�b�h���[��������܂��B"
               "Bathroom" "�o�X���[��"       ;35
	       )
	      (
"����͏��֊�̂��߂̃}�[�J�[�ł��B �Q�[���̃v���C���[�͌��邱�Ƃ��ł���
���񂪁A�����ɂ̓��m�����܂�܂��B"
               "Urinal" "���֊�"         ;36
	       )
	      (
"���Ȃ��͖k��-�쐼(NE/SW)�̒ʘH�̖k��(NE)�̒[�ɂ��܂��B
�K�i�͂悭�����Ȃ���(U)�̊K�ւƂÂ��Ă��܂��B"
               "NE end of NE/SW cave passage" "�k��-�쐼�̍B���̖k���̒["      ;37
	       )
	      (
"���Ȃ��͖k��-�쐼(NE/SW)�̒ʘH�Ɠ���(E/W)�̒ʘH�������ꏊ�ɂ��܂��B"
               "NE/SW-E/W junction" "�B���̌����_"                     ;38
	       )
	      (
"���Ȃ��͖k��-�쐼(NE/SW)�̒ʘH�̓쐼(SW)�̒[�ɂ��܂��B"
               "SW end of NE/SW cave passage" "�k��-�쐼�̍B���̓쐼�̒["       ;39
	       )
	      (
"���Ȃ��͓�-��(E/W)�̒ʘH�̓�(E)�̒[�ɂ��܂��B�K�i�͏�(U)�ɂ��镔���ւ�
�Â��Ă��܂��B"
               "East end of E/W cave passage" "��-���̍B���̓��̒["       ;40
	       )
	      (
"���Ȃ��͓�-��(E/W)�̒ʘH�̐�(W)�̒[�ɂ��܂��B�����̒n�ʂɂ͌���������
����A��(D)�ɂ��錩���Ȃ��ꏊ�ւƂÂ��Ă��܂��B"
               "West end of E/W cave passage" "��-���̍B���̐��̒["      ;41
	       )
	      (
"���Ȃ��́A�����ɂĂ��Ă̌`�������傫�Ȑ΁iboulder�j�����邾����
�����Ƃ��������ɂ��܂��B�������牺(D)�֍s���K�i������܂��B"     ;42
               "Horseshoe boulder room" "�Ă��Ă�̐΂̂��镔��"
	       )
	      (
"���Ȃ��͂܂����������Ȃ������̒��ɂ��܂��B�k(N)�ւ̃h�A������܂��B"
               "Empty room" "�����Ȃ�����"                     ;43
	       )
	      (
"���Ȃ��͉����Ȃ������ɂ��܂��B���̕����̐�(stone)�͐F�œh���Ă��܂��B
�h�A�̉��͓�(E)�Ɠ�(S)�ւƂÂ��܂��B"  ;44
               "Blue room" "������"
	       )
	      (
"
���Ȃ��͉����Ȃ������ɂ��܂��B���̕����̐�(stone)�͉��F�œh���Ă��܂��B
�h�A�̉��͓�(S)�Ɛ�(W)�ւƂÂ��܂��B"    ;45
               "Yellow room" "���F������"
	       )
	      (
"���Ȃ��͉����Ȃ������ɂ��܂��B���̕����̐�(stone)�͐ԐF�œh���Ă��܂��B
�h�A�̉��͐�(W)�Ɩk(N)�ւƂÂ��܂��B"
               "Red room" "�Ԃ�����"                                ;46
	       )
	      (
"���Ȃ��́A�k-��(N/S)���Ȃ������L���̒��Ԓn�_�ɂ��܂��B"     ;47
               "Long n/s hallway" "�k-��̒����L���̒���"
	       )
	      (
"���Ȃ��́A�k-��(N/S)���Ȃ������L���́A�k�[�֌�������3/4�قǐi��
�ʒu�ɂ��܂��B"
               "3/4 north" "3/4�k�֐i�񂾒n�_"                               ;48
	       )
	      (
"���Ȃ��́A�k-��(N/S)���Ȃ������L���̖k�̒[�ɂ��܂��B
�K�i����(U)�ւÂ��Ă��܂��B"
               "North end of long hallway" "�����L���̖k�̒["                ;49
	       )
	      (
"���Ȃ��́A�k-��(N/S)���Ȃ������L���́A��[�֌�������3/4�قǐi��
�ʒu�ɂ��܂��B"
               "3/4 south" "3/4��ւ������n�_"                                ;50
	       )
	      (
"���Ȃ��́A�k-��(N/S)���Ȃ������L���̓�̒[�ɂ��܂��B
��(S)�Ɍ�������܂��B"
               "South end of long hallway" "�����L���̓�̒["                ;51
	       )
	      (
"���Ȃ��͏�-��(U/D)�ɂÂ����������̊K�i�̗x���ɂ��܂��B"
               "Stair landing" "�K�i�̗x���"                            ;52
	       )
	      (
"���Ȃ��͏㉺(U/D)�ɂÂ��K�i�̓r���ɂ��܂��B"
               "Up/down staircase" "�㉺�ւÂ��K�i"                        ;53
	       )
	      (
"���Ȃ��͉�(D)�ւƂÂ��K�i�̈�ԏ�ɂ��܂��B
��ƘH(crawlway)���k��(NE)�ւÂ��Ă��܂��B"
               "Top of staircase." "�K�i�̒���"                       ;54
	       )
	      (
"���Ȃ��́A��ƘH�ɂ��܂��B��������k��(NE)�܂��͓쐼(SW)�ɍs���܂��B"
               "NE crawlway" "��ƘH�̖k��"                             ;55
	       )
	      (
"���Ȃ��͏����ȍ�ƃX�y�[�X�̒��ɂ��܂��B�����̒n�ʂɂ͑傫�Ȍ���
�����Ă��܂��B�����āA�����ȒʘH���쐼(SW)�ɑ����Ă��܂��B"
               "Small crawlspace" "��ƃX�y�[�X"                        ;56
	       )
	      (
"���Ȃ��� Gamma �R���s���[�^�Z���^�[�ɂ��܂��B
�����ł� IBM 3090/600s �Ƃ����@��̃R���s���[�^(computer)���t�@���̉���
�u���u���炵�Ȃ���ғ����Ă��܂��B���j�b�g�̂ЂƂ���C�[�T�l�b�g��
�P�[�u��(cable)���o�Ă���A���ꂪ�V��ւƂ̂тĂ��܂��B
���Ȃ����R�}���h���^�C�v�ł���悤�ȑ���@��͂����ɂ͂���܂���B"
               "Gamma computing center" "Gamma �R���s���[�^�Z���^�["                  ;57
	       )
	      (
"���Ȃ��͗X�֋ǂ̐Ղɂ��܂��B�����̐��ʂɗX�֎�(mail)������܂����A
���������Ȃ��͂��ꂪ�ǂ��֓͂������邱�Ƃ͂ł��܂���B
��(E)�ւƖ߂�ʘH�ƁA�k(N)�ւÂ���������܂��B"
               "Post office" "�X�֋�"                            ;58
	       )
	      (
"���Ȃ��̓��C���ʂ�(Main Street)�ƃJ�G�f�ʂ�(Maple Ave)�̌����_�ɂ��܂��B
���C���ʂ�͖k(N)�����(S)�ւƂ͂����Ă���A�J�G�f�ʂ�͓�(E)�̉�����
�������Ă͂����Ă��܂��B���Ȃ����k���ɖڂ����Ƃ�������̌����_��
�����܂��B�������A�ߋ��ɂ������ł��낤���ׂĂ̌����͂Ȃ��Ȃ��Ă��܂��B
���H�W��(sign)�ȊO�A�����c���Ă��܂���B
�k��(NW)�ɂ́A��������邩�̂悤�Ȗ�(gate)������܂��B"
               "Main-Maple intersection" "���C��-�J�G�f�����_"                      ;59
	       )
	      (
"���Ȃ��́A���C���ʂ�(Main Street)�ƃI�[�N�̖ؒʂ�(Oaktree Ave)�̐��̒[�Ƃ�
�����_�ɂ��܂��B"
               "Main-Oaktree intersection" "���C��-�I�[�N�̖،����_"  ;60
	       )
	      (
"���Ȃ��́A���C���ʂ�(Main Street)�ƃo�[�����g�ʂ�(Vermont Ave)�̐��̒[�Ƃ�
�����_�ɂ��܂��B"
               "Main-Vermont intersection" "���C��-�o�[�����g�����_" ;61
	       )
	      (
"���Ȃ��́A���C���ʂ�(Main Street)�̖k�̒[�ƃC�`�W�N�ʂ�(Sycamore Ave)��
���̒[�Ƃ��Ȃ��n�_�ɂ��܂��B" ;62
               "Main-Sycamore intersection" "���C��-�C�`�W�N�����_"
	       )
	      (
"���Ȃ��͑�P�ʂ�(First Street)�̓�̒[�ƃJ�G�f�ʂ�(Maple Ave)�̌����_
�ɂ��܂��B" ;63
               "First-Maple intersection" "��P-�J�G�f�����_"
	       )
	      (
"���Ȃ��͑�P�ʂ�(First Street)�ƃI�[�N�̖ؒʂ�(Oaktree Ave)�̌����_�ɂ��܂��B"  ;64
               "First-Oaktree intersection" "��P-�I�[�N�̖،����_"
	       )
	      (
"���Ȃ��͑�P�ʂ�(First Street)�ƃo�[�����g�ʂ�(Vermont Ave)�̌����_
�ɂ��܂��B"  ;65
               "First-Vermont intersection" "��P-�o�[�����g�����_"
	       )
	      (
"���Ȃ��͑�P�ʂ�(First Street)�̖k�̒[�ƃC�`�W�N�ʂ�(Sycamore Ave)��
�����_�ɂ��܂��B"  ;66
               "First-Sycamore intersection" "��P-�C�`�W�N�����_"
	       )
	      (
"���Ȃ��͑�Q�ʂ�(Second Street)�̓�̒[�ƃJ�G�f�ʂ�(Maple Ave)�̌����_��
���܂��B" ;67
               "Second-Maple intersection" "��Q-�J�G�f�����_"
	       )
	      (
"���Ȃ��͑�Q�ʂ�(Second Street)�ƃI�[�N�̖ؒʂ�(Oaktree Ave)�̌����_�ɂ��܂��B"  ;68
               "Second-Oaktree intersection" "��Q-�I�[�N�̖،����_"
	       )
	      (
"���Ȃ��͑�Q�ʂ�(Second Street)�ƃo�[�����g�ʂ�(Vermont Ave)�̌����_
�ɂ��܂��B"  ;69
               "Second-Vermont intersection" "��Q-�o�[�����g�����_"
	       )
	      (
"���Ȃ��͑�Q�ʂ�(Second Street)�Ɩk�̒[�ƃC�`�W�N�ʂ�(Sycamore Ave)��
�����_�ɂ��܂��B"  ;70
               "Second-Sycamore intersection" "��Q-�C�`�W�N�����_"
	       )
	      (
"���Ȃ��́A��R�ʂ�(Third Street)�̓�̒[�ƃJ�G�f�ʂ�(Maple Ave)�̌����_
�ɂ��܂��B"  ;71
               "Third-Maple intersection" "��R-�J�G�f�����_"
	       )
	      (
"���Ȃ��͑�R�ʂ�(Third Street)�ƃI�[�N�̖ؒʂ�(Oaktree Ave)�̌����_�ɂ��܂��B"  ;72
               "Third-Oaktree intersection" "��R-�I�[�N�̖،����_"
	       )
	      (
"���Ȃ��͑�R�ʂ�(Third Street)�ƃo�[�����g�ʂ�(Vermont Ave)�̌����_
�ɂ��܂��B"  ;73
               "Third-Vermont intersection" "��R-�o�[�����g�����_"
	       )
	      (
"���Ȃ��͑�R�ʂ�(Third Street)�Ɩk�̒[�ƃC�`�W�N�ʂ�(Sycamore Ave)��
�����_�ɂ��܂��B"  ;74
               "Third-Sycamore intersection" "��R-�C�`�W�N�����_"
	       )
	      (
"���Ȃ��͑�S�ʂ�(Fourth Street)�Ɠ�̒[�ƃJ�G�f�ʂ�(Maple Ave)�̌����_
�ɂ��܂��B"  ;75
               "Fourth-Maple intersection" "��S-�J�G�f�����_"
	       )
	      (
"���Ȃ��͑�S�ʂ�(Fourth Street)�ƃI�[�N�̖ؒʂ�(Oaktree Ave)�̌����_�ɂ��܂��B"  ;76
               "Fourth-Oaktree intersection" "��S-�I�[�N�̖،����_"
	       )
	      (
"���Ȃ��͑�S�ʂ�(Fourth Street)�ƃo�[�����g�ʂ�(Vermont Ave)�̌����_
�ɂ��܂��B"  ;77
               "Fourth-Vermont intersection" "��S-�o�[�����g�����_"
	       )
	      (
"���Ȃ��͑�S�ʂ�(Fourth Street)�Ɩk�̒[�ƃC�`�W�N�ʂ�(Sycamore Ave)��
�����_�ɂ��܂��B"  ;78
               "Fourth-Sycamore intersection" "��S-�C�`�W�N�����_"
	       )
	      (
"���Ȃ��͑�T�ʂ�(Fifth Street)�̓�̒[�ƃJ�G�f�ʂ�(Maple Ave)��
���̒[�Ƃ��Ȃ��n�_�ɂ��܂��B"  ;79
               "Fifth-Maple intersection" "��T-�J�G�f�����_"
	       )
	      (
"���Ȃ��͑�T�ʂ�(Fifth Street)�ƃI�[�N�̖ؒʂ�(Orktree Ave)�̓��̒[�Ƃ�
�����_�ɂ��܂��B��(E)�͐؂藧�����R(cliff)�ł��B"
               "Fifth-Oaktree intersection" "��T-�I�[�N�̖،����_" ;80
	       )
	      (
"���Ȃ��͑�T�ʂ�(Fifth Street)�ƃo�[�����g�ʂ�(Vermont Ave)�̓��̒[�Ƃ�
�����_�ɂ��܂��B"
               "Fifth-Vermont intersection" "��T-�o�[�����g�����_" ;81
	       )
	      (
"���Ȃ��͑�T�ʂ�(Fifth Street)�̓�̒[�ƃC�`�W�N�ʂ�(Sycamore Ave)��
���̒[�Ƃ��Ȃ��n�_�ɂ��܂��B"
               "Fifth-Sycamore intersection" "��T-�C�`�W�N�����_" ;82
	       )
	      (
"���Ȃ��͎��R���j������(Museum of Natural History)�̑O�ɂ��܂��B
�k(N)�̃h�A�͌����̒��ւƂ��Ȃ��𓱂��܂��B���͓쓌(SE)�ւÂ��Ă��܂��B"
               "Museum entrance" "�����ق̓����"                 ;83
	       )
	      (
"���Ȃ��͎��R���j�����ق̃��C���E���r�[�ɂ��܂��B
�����̒����ɋ���ȋ���(dinosaur)�̃K�C�R�c������܂��B
��(S)�Ɠ�(E)�Ƀh�A������܂��B "
               "Museum lobby" "�����ق̃��r�["                    ;84
	       )
	      (
"���Ȃ��͒n���w�̓W�����ɂ��܂��B�W������Ă����͂��̂��̂͑S�Ď�����
���܂��Ă��܂��B��(E)�Ɛ�(W)�Ɩk(N)�ɕ���������܂��B"
               "Geological display" "�n���w�̓W����"              ;85
	       )
	      (
"���Ȃ��͊C�m�����̃G���A�ɂ��܂��B�����͐���(tank)�Ŗ�������Ă��܂��B
����͌����Ƃ���ł͉a���Ȃ��Ȃ������߂Ɏ��񂾂Ǝv���鋛(fish)�̎��[��
��������Ă��܂��B��(S)�Ɠ�(E)�Ƀh�A������܂��B"
               "Marine life area" "�C�m�����̃G���A"                  ;86
	       )
	      (
"���Ȃ��͔����ق̊Ǘ����̂ЂƂɂ��܂��B�ǂ̏�� �u BL �v�Ə����ꂽ
���x���̂����X�C�b�`(switch)������܂��B��(W)�Ɩk(N)�ւ̃h�A������܂��B"
               "Maintenance room" "�Ǘ���"                  ;87
	       )
	      (
"���Ȃ��́A�����w�ɂ��Ďq�ǂ������ɋ�����̂Ɏg���Ă��������ɂ��܂��B
����(blackboard)�ɂ́u �q�ǂ��͉��̊K�֍s���̂͋�����Ă��܂���v��
�����Ă���܂��B�����ɂ͓�(E)�ւ̃h�A������A���̏�ɂ͏o��(exit)��
�\������Ă��܂��B�����ЂƂ̃h�A����(W)�ɂ���܂��B"
               "Classroom" "����"                         ;88
	       )
	      (
"���Ȃ��̓o�[�����g�ʂ�̒n���S�̉w�ɂ��܂��B�d��(train)���o����҂���
��Ԃ��Ă��܂��B"
               "Vermont station" "�o�[�����g�w"                   ;89
	       )
	      (
"���Ȃ��͔����ق̒n���S�̉w�ɂ��܂��B�ʘH���k(N)�ւƂÂ��Ă��܂��B"
               "Museum station" "�����ىw"                    ;90
	       )
	      (
"���Ȃ��͖k(N)-��(S)���ނ��ԃg���l���̒��ɂ��܂��B"
               "N/S tunnel" "�k-��̃g���l��"                         ;91
	       )
	      (
"���Ȃ��͖k(N)-��(S)���ނ��ԃg���l���̖k�̒[�ɂ��܂��B
�㉺(U/D)�ֈړ����邽�߂̊K�i������܂��B
�����ɂ̓S�~�����@(garbage disposal)������܂��B"
               "North end of N/S tunnel" "�k-��̃g���l���̖k�̒["            ;92
               )
	      (
"���Ȃ��͒n���S�̉w�̂��΂̊K�i�̍ŏ�w���ɂ��܂��B��(W)�Ƀh�A������܂��B"
               "Top of subway stairs" "�n���S�̊K�i�̏�"          ;93
	       )
	      (
"���Ȃ��͒n���S�̉w�̂��΂̊K�i�̍ŉ��w���ɂ��܂��B�k��(NE)��
����������܂��B"
               "Bottom of subway stairs" "�n���S�̉w�̒�"      ;94
	       )
	      (
"���Ȃ��͂����ЂƂ̌v�Z�@���ɂ��܂��B�����ɂ͂��Ȃ������܂łɌ�������
���Ȃ��悤�ȋ���ȃR���s���[�^(computer)������܂��B
����ɂ͐������̖��O�Ȃǂ͏�����Ă��܂��񂪁A���̌f�����Ȃ���Ă��܂��B
              �u���̃}�V���̖��O�� 'endgame'�v
�o���͓쐼(SW)�ɂ���܂��B���Ȃ����R�}���h���^�C�v�ł���悤�ȑ���@���
�����ɂ͂���܂���B"
               "Endgame computer room" "Endgame�v�Z�@��"        ;95
	       )
	      (
"���Ȃ��́A��(S)-�k(N)���Ȃ��ʘH�ɂ��܂��B"
               "Endgame N/S hallway" "Endgame�̓�-�k�̒ʘH"          ;96
	       )
	      (
"���Ȃ��͑�P���⃋�[���ɂ��܂����B���Ȃ���������؂蔲���邽�߂ɂ́A
���m�Ɏ���ɓ����Ȃ���΂Ȃ�܂���B����ɓ�����ɂ�(answer)���g����
���������i�� �Fanswer foo)"
               "Question room 1" "��P���⃋�[��"             ;97
	       )
	      (
"���Ȃ��́A��(S)-�k(N)���Ȃ��ʘH�ɂ��܂��B"
               "Endgame N/S hallway" "Endgame�̓�-�k�̒ʘH"          ;98
	       )
	      (
"���Ȃ��͑�Q���⃋�[���ɂ��܂��B"
               "Question room 2"  "��Q���⃋�[��"             ;99
	       )
	      (
"���Ȃ��́A��(S)-�k(N)���Ȃ��ʘH�ɂ��܂��B"
               "Endgame N/S hallway" "Endgame�̓�-�k�̒ʘH"          ;100
	       )
	      (
"���Ȃ��͑�R���⃋�[���ɂ��܂��B"
               "Question room 3"  "��R���⃋�[��"              ;101
	       )
	      (
"���Ȃ��� endgame �̕󕨌ɂɂ��܂��B�k(N)�ւ̃h�A������A�ʘH�͓�(S)��
�Â��Ă��܂��B"
               "Endgame treasure room" "Endgame�̕󕨌�"        ;102
	       )
	      (
"���Ȃ��͏����҂̕����ɂ��܂��B��(S)�Ƀh�A������܂��B"
               "Winner's room" "�����҂̕���"                ;103
	       )
	      (
"���Ȃ��͍s���~�܂�ɂ��܂��B�����̏��ɂ̓p�\�R��(PC)������܂��B
���̃p�\�R���ɂ͕\�����Ȃ���Ă��܂����B����͎��̂悤�ɓǂ߂܂��B
  �u���̃p�\�R�������Z�b�g�i�d���̓��꒼��, reset �j����B�v
���͖k(N)�ւÂ��Ă��܂��B"
               "PC area"   "�p�\�R���G���A"                    ;104
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
		("�����ɂ̓V���x���ishovel�j������܂��D" "�V���x�� shovel")                ;0
		("�����ɂ̓����v(lamp)������܂��B" "�����v lamp")                  ;1
		("�����ɂ͂b�o�t�{�[�h(board)������܂��D" "�b�o�t�{�[�h board")      ;2
		("�����ɂ͐H�ו�(food)�������Ă��܂�." "�H�ו� food")              ;3
		("�����ɂ͋P�������̌�(key)������܂��B" "�� key")    ;4
		("�����ɂ͎��؂�(paper)������܂��B" "���؂� paper")  ;5
		("�����ɂ� ���`���[�h�X�g�[���}���̂낤�l�`(statue)������܂��B" ;6
		 "�낤�l�` statue")
		("�����ɂ͋P���_�C�A�����h(diamond)������܂��B" "�_�C�A�����h diamond")   ;7
		("�����ɂ� 10 �|���h�̓S�A���C(weight)������܂��B" "�S�A���C weight")       ;8
		("�����ɂ͋~����(life preserver)������܂��B" "�~���� preserver");9
		("�����ɂ̓G�������h�̘r��(bracelet)������܂��B" "�r�� bracelet")   ;10
		("�����ɂ͋��̉��ז_(gold)������܂��B" "���̉��ז_ gold")            ;11
		("�����ɂ̓v���`�i�̉��ז_(platinum)������܂��B" "�v���`�i�̉��ז_ platinum")    ;12
		("�n�ʂ̏�Ƀr�[�`�^�I��(towel)�������Ă��܂��B" "�^�I�� towel")
		("�����ɂ͕�(axe)������܂��B" "�� axe") ;14
		("�����ɂ͋�̉��ז_(silver)������܂��B" "��̉��ז_ silver")  ;15
		("�����ɂ̓o�X�̉^�]�Ƌ���(license)������܂��B" "�^�]�Ƌ��� license") ;16
		("�����ɂ͋M�d�ȋ���(coins)������܂��B" "�M�d�ȋ��� coins")
		("�����ɂ͕�΂�����΂߂�ꂽ�k������(egg)������܂��B" "�M�d�ȗ� egg") ;18
		("�����ɂ̓K���X�̂т�(jar)������܂��B" "�т� jar") ;19
		("�����ɂ͋����̍�(bone)������܂��B" "�� bone") ;20
		("�����ɂ͂P�p�b�N�̏Ɏ_(acid)������܂��B" "�Ɏ_ acid")
		("�����ɂ͂P�p�b�N�̃O���Z����(glycerine)������܂��B" "�O���Z���� glycerine") ;22
		("�����ɂ͋M�d�ȃ��r�[(ruby)������܂��B" "���r�[ ruby") ;23
		("�����ɂ͋M�d�Ȏ�����(amethyst)������܂��B" "������ amethyst") ;24
		("�����ɂ̓��i���U�iMona Lisa�j������܂��B" "���i���U Mona") ;25
		("�����ɂ�100�h���̎���(bill)������܂��B" "100�h������ bill") ;26
		("�����ɂ̓t���b�s�[�f�B�X�N(disk)������܂��B" "�f�B�X�N disk") ;27
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
		     ("�����ɂ͑傫�Ȋې�(boulder)������܂��B")
		     nil
		     ("�����ɂ͋��낵���F�ibear�j�����܂��I")
		     nil
		     nil
		     ("�����ɂ͉��l�̂Ȃ�����(protoplasm)�̎R������܂��B")
		     nil
		     nil
		     nil
		     nil
		     nil
		     nil
		     ("���̕����͊�ȓ���(strange smell)�����܂��B")
		     nil
		     (
"�����ɂ̓X���b�g�̂��锠(box)������A�ǂɃ{���g�ŗ��߂��Ă��܂��B"
                     )
		     nil
		     nil
		     ("�����ɂ̓o�X(bus)������܂��B")
		     nil
		     nil
		     nil
))


;;; These are the descriptions the user gets when regular objects are
;;; examined.

(setq dun-physobj-desc '(
"����� $19.99�Ə����ꂽ�l�D�̂����A�ӂ��̃V���x���ł��B"
"����̓[�x�b�g(Geppetto)�ɂ�����̃����v�ł��B"
"�b�o�t�{�[�h�ɂ� VAX �̃`�b�v������Ă��܂��B 2 ���K�o�C�g�̃I���{�[�h
�q�`�l������Ă���悤�Ɍ����܂��B"
"����͉����̓��̂悤�Ɍ����܂��B�Ђǂ��L���ɂ��������܂��B"
nil
"���ɂ͂���������Ă��܂��B�u���������߂�Ƃ��� 'help'�ƃ^�C�v���邱�Ƃ�
�Y��Ȃ����ƁB�����āA���̒P����o���Ă������� 'worms'�v"
"���̐l�`�́A�L���� EMACS�G�f�B�^�̍�҃��`���[�h�E�X�g�[���}��
(Richard Stallman)�Ɏ��Ă��܂��B���Ȃ��́A�ނ��C���͂��Ă��Ȃ����Ƃ�
�C�����܂����B"
nil
"���Ȃ��͓S�A���C���d�����Ƃ��m�F���܂����B"
"����ɂ� �r�r�̏����iS.S.Minnow�j�Ə�����Ă��܂�."
nil
nil
nil
"����̓X�k�[�s�[(snoopy)�̏����ꂽ�G�ł��B"
nil
nil
"����ɂ͂��Ȃ��̎ʐ^���t���Ă��܂��I"
"�����19���I���瑱���Â����݂ł��B"
"����͍����� Fabrege �̗��ł��B"
"����͎��f�ȃK���X�̃r���ł��B"
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
"����͂����̐�(boulder)�ł��B����𓮂������Ƃ͂ł��܂���B"
"�����̓��V�̎�(coconut)��L�x�ɋ������Ă���郄�V�̖؁X�ł��B"
"����̓O���Y���[(grizzly)�̈��̂悤�Ɍ����܂��B"
"�唠�͑S�ċ�ł��B�悭����ƁA���Ȃ��͑唠�̒�ɖ��O���������
����̂��킩��܂����B�������A�قƂ�ǂ̖��O�͂�����Ă��܂��Ă���
�ǂނ��Ƃ��ł��܂���B���Ȃ����ǂނ��Ƃ��ł����͎̂��̂R��
���O�����ł����B
              �W�F�t���[�E�R���[     Jeffrey Collier
              ���o�[�g�E�g�N�����h   Robert Toukmond
              �g�[�}�X�E�X�g�b�N     Thomas Stock
"
                      nil
"����͂��������Ⴒ����Ƃ����������̂ł��B"
"�_�C�A���͂����ƈȑO�ɂ�����ď����Ă��܂������x�̖ڐ����w���Ă��܂��B"
nil
nil
"����́A�G���r�X�E�v���X���[(Elvis Presley)�̃x���x�b�g�̊G�ł��B
����͕ǂɂ����őł��t�����Ă���̂��A���������Ƃ��ł��܂���B"
"����͂ƂĂ��}�b�g���X�̍d���N�C�[���T�C�Y�̃x�b�h�ł��B"
"���֊�͓��A�̒��̂ق��̂ǂ�������ꂢ�ł��B�����̃T�r������܂���B
�m���߂邽�߂ɋ߂Â��ƁA���Ȃ��͒�̔r���a���Ȃ��A�p�C�v�̂ǂ��ւ�
�Ȃ����Ă��Ȃ��傫�Ȍ����������邱�ƂɋC�����܂����B
���̌��͐l������ɂ͂��܂�ɂ��������ł��B���(flush)���邽�߂̃n���h����
�ƂĂ����ꂢ�ŁA���Ȃ��͂��̒��Ɏ����̎p���f��̂����邱�Ƃ��ł��܂��B"
nil
nil
"���̏�ʂɂ̓X���b�g(slit)������A���̏�ɉ������ő��菑�������Ă���܂��B
�u��(key)�̍X�V�B���̒��Ɍ���}��(put)����B�v"
nil
"�����ɂ́u���B��(express mail)�Ə�����Ă��܂��B"
"�����35�l���̃o�X�ŁA���ʂɁu���[�r�[�c�A�[�Y(mobytours)�v�Ƃ�����Ж�
��������Ă��܂��B"
"����͏��z����(climb)�ɂ͂��܂�ɂ�����ȋ������̖�ł��B"
"����͂ƂĂ��Ȃ�����ȊR�ł��B"
"�c�O�Ȃ���A���Ȃ�����ɂ��ăE���`�N���q�ׂ�قǏ\���Ȓm���͎�����
���܂���B������ɂ���A����͂ƂĂ��傫���ł��B"
"���̋��́A���Ă͂ƂĂ������������悤�Ɍ����܂��B"
nil
nil
nil
nil
"�i�v�Ɍ��Ɏ��t����ꂽ�܂܂́A�������ʂ̃n�V�S�ł��B"
"����͏o�������̂ł��Ă���q��(train)�ł��B"
"�t���b�s�[�f�B�X�N�h���C�u(floppy disk drive)���ЂƂ�������
�p�[�\�i���R���s���[�^(computer)�ł��B"
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
" ��������͂���܂���B'answer foo' �Ɠ��͂��Ă��������B.")
			  ("00".
"'pokey'�Ƃ�΂��}�V���ł̂��Ȃ��̃p�X���[�h�͉��H")
			  ("01".
"gamma�̓����ianonymous�jftp�ł̂��Ȃ��̃p�X���[�h�͉��H")
			  ("02".
"endgame�������A���Ȃ������_�𓾂邽�߂ɕ󕨂�����(put)���Ƃ��ł���
�ꏊ�͂�������H")
			  ("03".
"'endgame'�}�V���ł̂��Ȃ��̃��[�U���O�C�����͉��H")
			  ("04".
"�V���x���̒l�i�͂��悻���h���H�i�����œ��́j")
			  ("05".
"�X����������o�X�̉�Ж��͉��H")
			  ("06".
"�X�֕��̕����ɂ̂����ꂽ�A���Ȃ��ȊO�̂Q�l�̖��O�̂����A�ǂ��炩�����
���X�g�l�[���i�㔼�̖��O�j�𓚂���B")
			  ("07".
"�^�I���ɏ�����Ă����}���K�̃L�����N�^�[�͉��H")
			  ("08".
"EMACS �̊J���҂̃��X�g�l�[���i�㔼�̖��O�j�͉��H")
			  ("09".
"Vax��CPU�{�[�h(board)�ɂ̂��Ă����������͉����K�o�C�g�H�i�����œ��́j")
			  ("10".
"�A�����J�̏B�̖��O���������̒ʂ�̖��O�́H")
			  ("11".
"�S�A���C�̏d���͉��|���h�������H�i�����œ��́j")
			  ("12".
"�n���S�̉w���������̂͑扽�ʂ�H�i�����œ��́j")
			  ("13".
"�X�֋ǂ������A�X�̌����_�iT���H,L���H�����܂ށj�͂����������H�i�����œ��́j")
			  ("14".
"�����B���Ă����F�͉��̎�ނ������H")
			  ("15".
"���Ȃ��������@���Ă݂������̂����A�ЂƂ̖��O�𓚂���B")
			  ("16".
"pocky��gamma�̊ԂŎg���Ă����l�b�g���[�N�ʐM�v���g�R���͉��H")
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
		  (dun-mprincl ": not found.�i�R�}���h������܂���j")))))
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
�i�f�B���N�g���𐮗�����B�t�@�C���V�X�e���͂����ς��ɂȂ��Ă���B�j
Our tcp/ip link to gamma is a little flaky, but seems to work.
�i�R���s���[�^ gamma �ւ�TCP/IP�ɂ�郊���N�͕s���肾�����삷��B�j
The current version of ftp can only send files from your home
directory, and deletes them after they are sent!  Be careful.
�i�t�@�C���]���\�t�g ftp �̌��݂̃o�[�W�����́A�z�[���f�B���N�g������
  �̃t�@�C�����M�̂݉\�B�t�@�C���͑��M��ɏ��������I���ӂ���B�j

Note: Restricted bourne shell in use.�i�������ꂽbourne shell���쒆�j
�i�t�@�C�����̈ꗗ�ɂ� �R�}���h ls ���g���܂��j\n")))
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
�i�R�}���h�̌�ɐڑ���R���s���[�^�����K�v�B�� ftp <�R���s���[�^��> �j")
      (setq host (intern (car args)))
      (if (not (member host '(gamma dun-endgame)))
	  (dun-mprincl "ftp: Unknown host.�iftp:�s���ȃz�X�g���j")
	(if (eq host 'dun-endgame)
	    (dun-mprincl "ftp: connection to endgame not allowed
�iftp: endgame��ftp�ɂ��ڑ���������Ă��Ȃ��j")
	  (if (not dun-ethernet)
	      (dun-mprincl "ftp: host not responding.�iftp:�z�X�g����̉������Ȃ��j")
	    (dun-mprincl "Connected to gamma. FTP ver 0.9 00:00:00 01/01/70
�i gamma �֐ڑ��BFTP �o�[�W���� 0.9 �j")
	    (dun-mprinc "Username�i���[�U���j: ")
	    (setq username (dun-read-line))
	    (if (string= username "toukmond")
		(if dun-batch-mode
		    (dun-mprincl "toukmond ftp access not allowed.
�itoukmond�̃A�N�Z�X�͕s���j")
		  (dun-mprincl "\ntoukmond ftp access not allowed.
�itoukmond�̃A�N�Z�X�͕s���j"))
	      (if (string= username "anonymous")
		  (if dun-batch-mode
		      (dun-mprincl
		       "Guest login okay, send your user ident as password.
�i�Q�X�g���O�C���n�j�A�p�X���[�h�̑���ɂ��Ȃ��̃��[�U�[���𑗐M����j")
		    (dun-mprincl 
		     "\nGuest login okay, send your user ident as password.
�i�Q�X�g���O�C���n�j�A�p�X���[�h�̑���ɂ��Ȃ��̃��[�U�[���𑗐M����j"))
		(if dun-batch-mode
		    (dun-mprinc "Password required for ")
		  (dun-mprinc "\nPassword required for "))
		(dun-mprincl username)
	        (dun-mprincl (format "�i���[�U %s �̃p�X���[�h���K�v�j" username)))
	      (dun-mprinc "Password: ")
	      (setq ident (dun-read-line))
	      (if (not (string= username "anonymous"))
		  (if dun-batch-mode
		      (dun-mprincl "Login failed.�i���O�C�����s�j")
		    (dun-mprincl "\nLogin failed.�i���O�C�����s�j"))
		(if dun-batch-mode
		   (dun-mprincl 
		    "Guest login okay, user access restrictions apply.
�i�Q�X�g���O�C���n�j�C���[�U�A�N�Z�X�����K�p�j")
		  (dun-mprincl 
		   "\nGuest login okay, user access restrictions apply.
�i�Q�X�g���O�C���n�j�C���[�U�A�N�Z�X�����K�p�j"))
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
�i���̂悤�ȃR�}���h�͂Ȃ��B help ���������ƁB�j")))
      (setq dun-ftptype 'ascii)))

(defun dun-ftptype (args)
  (if (not (car args))
      (dun-mprincl "Usage: type [binary | ascii] �i�g�����F type �ubinary �܂��� ascii�v�j")
    (setq args (intern (car args)))
    (if (eq args 'binary)
	(dun-bin nil)
      (if (eq args 'ascii)
	  (dun-fascii 'nil)
	(dun-mprincl "Unknown type.�i�s���ȃ^�C�v�j")))))

(defun dun-bin (args)
  (dun-mprincl "Type set to binary.�i�]�����[�h���o�C�i���ɐݒ�j")
  (setq dun-ftptype 'binary))

(defun dun-fascii (args)
  (dun-mprincl "Type set to ascii.�i�]�����[�h���A�X�L�[�ɐݒ�j")
  (setq dun-ftptype 'ascii))

(defun dun-ftpquit (args)
  (setq dun-exitf t))

(defun dun-send (args)
  (if (not (car args))
      (dun-mprincl "Usage: send <filename> �i�g�����F send <�t�@�C����>�j")
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
	  (dun-mprincl (format "�i�t�@�C�� %s �� %s ���[�h�œ]���B�j" 
		args dun-ftptype))
	    (dun-mprincl "Transfer complete.�i�]�������j"))

	(dolist (x dun-objfiles)
	  (if (string= args x)
	      (progn
		(if (not (member counter dun-inventory))
		    (progn
		      (dun-mprincl "No such file.�i���̂悤�ȃt�@�C���͂Ȃ��j")
		      (setq foo t))
		  (dun-mprinc "Sending ")
		  (dun-mprinc dun-ftptype)
		  (dun-mprinc " file for ")
		  (dun-mprinc (downcase (cadr (nth counter dun-objects))))
		  (dun-mprincl ", (0 bytes)")
	  (dun-mprincl (format "�i�t�@�C�� %s �� %s ���[�h�œ]���B�j" 
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
		  (dun-mprincl "Transfer complete.�i�]�������j"))))
	  (setq counter (+ 1 counter)))
	(if (not foo)
	    (dun-mprincl "No such file."))))))

(defun dun-ftphelp (args)
  (dun-mprincl 
   "Possible commands are:\nsend    quit    type   ascii  binary   help
�i�\�ȃR�}���h�� send ���M�^quit �I���^ type �]�����[�h�w��^
    ascii �����]�����[�h�^ binary �v���O�����]�����[�h �^help �g�����̕\���j"))

(defun dun-uexit (args)
  (setq dungeon-mode 'dungeon)
  (dun-mprincl "\n���Ȃ��̓R���\�[�����������։�����܂����B")
  (define-key dungeon-mode-map "\r" 'dun-parse)
  (if (not dun-batch-mode)
      (dun-messages)))

(defun dun-pwd (args)
  (dun-mprincl dun-cdpath))

(defun dun-uncompress (args)
  (if (not (car args))
      (dun-mprincl "Usage: uncompress <filename>�i�g�����F uncompress <�t�@�C����> �j")
    (setq args (car args))
    (if (or dun-uncompressed
	    (and (not (string= args "paper.o"))
		 (not (string= args "paper.o.z"))))
	(dun-mprincl "Uncompress command failed.�i���k�t�@�C���̓W�J�R�}���h���s�j")
      (setq dun-uncompressed t)
      (setq dun-inventory (append dun-inventory (list obj-paper))))))

(defun dun-rlogin (args)
  (let (passwd)
    (if (not (car args))
	(dun-mprincl "Usage: rlogin <hostname> �i�g�����F rlogin <�R���s���[�^��>�j ")
      (setq args (car args))
      (if (string= args "endgame")
	  (dun-rlogin-endgame)
	(if (not (string= args "gamma"))
	    (if (string= args "pokey")
		(dun-mprincl "Can't rlogin back to localhost
�i���ݎg�p���Ă���z�X�g��rlogin���邱�Ƃ͂ł��Ȃ��j")
	      (dun-mprincl "No such host.�i���̂悤�ȃz�X�g�͂Ȃ��j"))
	  (if (not dun-ethernet)
	      (dun-mprincl "Host not responding.�i�z�X�g���牞�����Ȃ��j")
	    (dun-mprinc "Password�i�p�X���[�h�j: ")
	    (setq passwd (dun-read-line))
	    (if (not (string= passwd "worms"))
		(dun-mprincl "\nlogin incorrect�i���O�C�����s�j")
	      (dun-mprinc 
"\n��������������������������������������������������������
���Ȃ��͈�u�A��Ȋ��������āA�����Ă��Ȃ��͑S�Ă̎������������܂����B"
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
	(dun-mprincl "Usage: cd <path> �i�g�����F cd <�ړ���f�B���N�g����> �j")
      (setq tcdpath dun-cdpath)
      (setq tcdroom dun-cdroom)
      (setq dun-badcd nil)
      (condition-case nil
	  (setq path-elements (dun-get-path (car args) nil))
	(error (dun-mprincl "Invalid path.�i�s���ȃf�B���N�g�����j")
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
  (dun-mprincl "No such directory.�i���̂悤�ȃf�B���N�g���͂Ȃ��j")
  (setq dun-badcd t))

(defun dun-cat (args)
  (let (doto checklist)
    (if (not (setq args (car args)))
	(dun-mprincl "Usage: cat <ascii-file-name>�i�g�����F cat <���̓t�@�C����> �j")
      (if (string-match "/" args)
	  (dun-mprincl "cat: only files in current directory allowed.
�icat:���݂���f�B���N�g�����̃t�@�C���̂݉{���\�j")
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
		    (dun-mprincl "File not found.�i�t�@�C����������Ȃ��j")
		  (dun-mprincl "Ascii files only.�i�����t�@�C���̂݉{���\�j")))
	    (if (assq (intern args) dun-unix-verbs)
		(dun-mprincl "Ascii files only.�i�����t�@�C���̂݉{���\�j")
	      (dun-mprincl "File not found.�i�t�@�C����������Ȃ��j"))))))))
  
(defun dun-zippy (args)
  (dun-mprincl (yow)))

(defun dun-rlogin-endgame ()
  (if (not (= (dun-score nil) 90))
;  (if (not (= (dun-score nil) 70))
      (dun-mprincl 
       "You have not achieved enough points to connect to endgame.
�i���Ȃ���endgame�ɐڑ�����̂ɏ\���ȓ��_���܂��l�����Ă��܂���B�j")
    (dun-mprincl"\nendgame�ւ悤�����B���Ȃ��͂ƂĂ��C�����`���Ƃł��B")
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
		(dun-mprincl "Bad command or file name �i�s���Ȗ��߂܂��̓t�@�C�����j"))))
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
	    (dun-mprincl "Cannot type binary files�i�o�C�i���t�@�C���͕s�j")
	  (dun-mprinc "File not found - ")
	  (dun-mprincl (upcase args))
	  (dun-mprincl (format "�i�t�@�C�� %s ��������Ȃ��j" (upcase args)))
	))
    (dun-mprincl "Must supply file name")))

(defun dun-dos-invd (args)
  (sleep-for 1)
  (dun-mprincl "Invalid drive specification �i���̃h���C�u�͑��݂��Ȃ��j"))

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
  (dun-mprincl (format "�i���݂̎����� %s �j" (substring (current-time-string) 12 20)))
  (dun-mprinc "Enter new time�i��������͂���j: ")
  (dun-read-line)
  (if (not dun-batch-mode)
      (dun-mprinc "\n")))

(defun dun-dos-spawn (args)
  (sleep-for 1)
  (dun-mprincl "Cannot spawn subshell"))

(defun dun-dos-exit (args)
  (setq dungeon-mode 'dungeon)
  (dun-mprincl "\n���Ȃ��̓p�\�R���̓d���𗎂Ƃ��ė��ꂽ�B")
  (define-key dungeon-mode-map "\r" 'dun-parse)
  (if (not dun-batch-mode)
      (dun-messages)))

(defun dun-dos-no-disk ()
  (sleep-for 3)
  (dun-mprincl "Boot sector not found �i�N���ɕK�v�ȏ�񂪌�����Ȃ��j"))


(defun dun-dos-show-combination ()
  (sleep-for 2)
  (dun-mprinc "\nThe combination is ")
  (dun-mprinc dun-combination)
  (dun-mprinc ".")
  (dun-mprinc (format "�i�g�ݍ��킹�� %s �ł��B�j\n" dun-combination)) )

(defun dun-dos-nil (args))


;;;;
;;;; This section defines the save and restore game functions for dunnet.
;;;;

(defun dun-save-game (filename)
  (if (not (setq filename (car filename)))
      (dun-mprincl "�Q�[����ۑ�����ɂ� save �̌��ɕۑ���t�@�C������^����K�v������܂��B
�i�J�����g�f�B���N�g���Ɏw�肵�����O�̃t�@�C��������܂��j")
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
	(dun-mprincl "�Q�[�����t�@�C���ɕۑ�����ۂɃG���[���������܂����B")
      (dun-do-logfile 'save nil)
      (switch-to-buffer "*dungeon*")
      (princ "")
      (dun-mprincl "�Q�[���̏�Ԃ�ۑ����܂����B"))))

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
	(dun-mprincl "�Q�[�����ĊJ����ɂ� restore �̌��Ƀt�@�C������^����K�v������܂��B")
      (if (not (dun-load-d file))
	  (dun-mprincl "�t�@�C����ǂނ��Ƃ��ł��܂���B")
	(dun-mprincl "�Q�[���̓r������ĊJ���܂����B")
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

