;;
;; italk.el version 0.41+tak1.15+iwa0.4
;;   by HARADA Masanori <hrd4@dolphin.c.u-tokyo.ac.jp>
;;   modified by Tak. <tak@st.rim.or.jp>
;;   modified by IWAMOTO Toshihiro <toshii@alles.or.jp>
;;
;;(autoload 'italk "italk" "Inter talk" t nil)
;;(autoload 'italk-other-frame "italk" "Inter talk" t nil)

;[$B:G?7$N(B italk.el $B$NF~<jK!(B]
;   http://italk.lefs.org/CIAN/
;   http://www.st.rim.or.jp/~tak/
;   http://www.sat.t.u-tokyo.ac.jp/~iwamoto/comp/italk/
;$B$N$I$A$i$+$K$O$"$k$N$G$O$J$$$+$HM=A[$5$l$^$9(B:-)

; history of 0.41 -> 0.41+tak1.2
;  $B?'$E$15,B'$NDI2C!"=$@5!#(B
;  #$B%G%U%)%k%H?'$NJQ99!#(B TODO: $BE,Ev$J(B hook $B$r:n$k(B
;  server $B$r(B completion $B$G$-$k$h$&$K$7$?!#(B
;  *inter-talk LOG* $B%P%C%U%!>e$G(B C-c {l,C-l,s,C-s} $B$,8z$/$h$&$K$7$?!#(B
;  /p $B%b!<%I?7@_!#(BC-c t, C-c C-t $B$G(B /p $B%b!<%I$KF~$k!#(B/p $B0J30$NJ8$NAw?.$G!"(B
;  $B<+F0E*$K%b!<%I$+$iH4$1$k!#(B
;  italk-send-region $B$GM>J,$J2~9T$,Aw?.$5$l$J$$$h$&$K$7$?!#(B
;  italk-startup-hook, italk-colorset-hook $B$r?7@_$7$?!#?'$OI8=`$KLa$9!#(B
;  C-c l $B$G%b!<%I9T$N%5!<%P!<L>$,I=<($5$l$J$/$J$i$J$/$J$C$?!#(B
; history of 0.41+tak1.2 -> 0.41+tak1.3
;  $BEEJs<u$1<h$j;~Aj<j$r5-21!"(BC-c p C-c p $B$GAw$j@h$r$=$NAj<j$KJQ99$9$k!#(B
;  $B%b!<%I9T$N%[%9%HL>I=<($rC;$/$7$?!#(B
;  C-u M-x italk $B$G%G%U%)%k%H%O%s%I%k$,F~NOBT5!$5$l$k$h$&$K$7$?!#(B
;  ping Handle $B$r<u?.$9$k$H%Y%k$rLD$i$9$h$&$K$7$?!#(B
; history of 0.41+tak1.3 -> 0.41+tak1.4
;  $BEEJs$G(B ping $B$5$l$?>l9g$K$bBP1~$9$k$h$&$K$7$?!#(B
;  ping $B$5$l$?J8;zNs$r(B hook $B4X?t$+$i;2>H$G$-$k$h$&$K$7$?!#(B
;  italk-window-handstand $B$N@_Dj$GF~NOIt$r2<$K;}$C$FMh$i$l$k$h$&$K$7$?!#(B
;  C-c o $B$G:G=*%m%0%"%&%H$r8!:w$9$k!#(B
;  $BEEJs%X%C%@$K?'$,$D$/$h$&$K$7$?!#(B
;  $B%P%C%/%m%0;2>HCf$K(B pinged-hook $B$r8F$P$J$$$h$&$K$7$?!#(B
;  quail-mode$B$N%-!<$r8z$+$J$$$h$&$K$7$?!#(B
;  $B4{$K(B connection $B$,D%$i$l$F$$$k$H$-!"(BM-x italk $B$G2hLL$r:F@_Dj$9$k!#(B
;  mule on Win32 $B$K(B($B$$$$2C8:$@$1$I(B)$BBP1~!#(B
; history of 0.41+tak1.4 -> 0.41+tak1.5
;  italk-kill-name $B?7@_!#H/8@$r%^%9%/$9$k?M$r;XDj$G$-$k!#(B
;  italk-paint-buffer $B?7@_!#(Bbuffer $BFb$N%F%-%9%H$K?'$E$1Ey$N=hM}$r$9$k!#(B
;  C-c k $B$G!"(Bkill-name $B5!G=$N(B on/off$B!#(B
;  *INPUT* $B%P%C%U%!$O?7$?$J(B major-mode $B$r:n$i$J$$$h$&$K$9$k!#(B
;  $BEEJs%b!<%I$GAj<j$N(Bch$BHV9f$,(B0$B$N$H$-$N%P%0$rD>$9!#(B
; history of 0.41+tak1.5 -> 0.41+tak1.6
;  connection closed $B%a%C%;!<%8$r%P%C%U%!$KA^F~$9$k$h$&$K$7$?!#(B
;  C-u M-x italk $B$G:G=i$K8uJd$r=P$5$J$$$h$&$K$G$-$k$h$&$K$9$k!#(B($B%G%U%)%k%H(B)
;  $B%G%U%)%k%H%5!<%P!<$r(Belectra$B$K$7$?!#(B
; history of 0.41+tak1.6 -> 0.41+tak1.7
;  logout $B%a%C%;!<%8$NJQ99$KBP1~$7$?!#(B
; history of 0.41+tak1.7 -> 0.41+tak1.8
;  $BAw?.$r(B*euc-japan*dos $B$K$7$F(B sendstr(str+"\n") $B$9$k(B($B;X<((BESC$B%7!<%1%s%9BP:v(B)$B!#(B
;  URL$B$rCf%/%j%C%/$7$F(Bnetscape$B@)8f$9$k(Btama$B%Q%C%A$r(Bmerge(italk-url-browse)$B!#(B
;  ping$B$5$l$?$i(Bframe$B$r(Bpop$B$9$k(BHRD$B%3!<%I$r(Bmerge(italk-force-pop-frame)$B!#(B
;  $B5/F0;~$K?'$,3NJ]$G$-$J$/$F$b$=$l$J$j$KF0:n$9$k$h$&$K$7$?!#(B
; history of 0.41+tak1.8 -> 0.41+tak1.9
;  URL$B$N:8C<$r%/%j%C%/$7$?$H$-$K@5$7$/F0$+$J$$%P%0$rD>$9!#(B
;  URL$B>e$G$7$+Cf%/%j%C%/$G$-$J$$$h$&$K$7$?!#(B
;  $BAw?.J8;z%3!<%I$r(B *euc-japan*dos $B$+$i(B *junet*dos $B$KJQ99$7$?!#(B
;  Win32$BMQ%Q%C%A(B(by HRD)$B$r%^!<%8!#(B
;  *italk-LOG* $B$r(B readonly $B$K$7$F!"$J$*$+$D(B undo $B$,8z$/$h$&$K$7$?!#(B
;  $B%m%0<+F0%;!<%V5!G=$r?7@_!#(Bitalk-logsave-mode$B$r(B.emacs$B$G(Bsetq$B$7$F;H$&!#(B
;  $BI8=`%5!<%P!<$r(B proton.is.s.u-tokyo.ac.jp $B$KJQ99!#(B
; history of 0.41+tak1.9 -> 0.41+tak1.9+iwa
;  $BJ#?t$N(Bitalk session$B$rF1;~$K9T$J$($k$h$&$K$7$?!#(B
; history of 0.41+tak1.9+iwa -> 0.41+tak1.9+iwa0.1
;  $B<u?.J8;z%3!<%I$r(Beuc-japan$B$+$i(Beuc-japan-dos$B$KJQ99$7$?!#(B
;  Mule for Win32$B$G(BURL$B%/%j%C%/=PMh$k$h$&$K$7$?!#(B(Applause$B$5$s$K$h$k(B)
; history of 0.41+tak1.9+iwa0.1 -> 0.41+tak1.9+iwa0.2
;  italk-secondary-server $B$NCM$rJQ99$7$?!#(B
;  italk-url-browse $B$N(B Mule for Win32$B4XO"$N%3!<%I$rJQ99$7$?!#(B(Applause$B$5$s$K$h$k(B)
; history of 0.41+tak1.9+iwa0.2 -> 0.41+tak1.11+iwa0.3
;  Summary buffer$B$r<BAu$7$?!#(B
;  $B=EJ#$9$k(BMessage from$B$NI=<($rM^@)$9$k$h$&$K$7$?!#(B
;  default$B$N%5!<%P!<$rJQ99$7$?!#(B
;  quotes.el$B$r%^!<%8$7$?!#(B (tak1.9 -> tak1.10)
;  italk-url-browse $B$NJQ99(B(tak1.9 -> tak1.11)$B$r<h$j$$$l$?!#(B
;  $B%5!<%P!<$r(BFQDN$B$G;XDj$7$F$$$J$$$H$-$N%b!<%I9T$N%[%9%HL>I=<(%P%0$rD>$9!#(B(taken from tak1.12)
;  login-face $BH=Dj$N@55,I=8=$rJQ99$7$F(B JST $B$K0MB8$7$J$$$h$&$K$7$?!#(B(taken from tak1.12)
; history of 0.41+tak1.11+iwa0.3 -> 0.41+tak1.15+iwa0.4
;  XEmacs20$B$KBP1~(B
;  process-filter $B$^$o$j$N(B performance bug $B$r=$@5!#(B
;  sync with tak1.15
;  ($BEEJs%b!<%I$GIT40A4$J(B /p $B$N$H$-!"%5!<%P!<$K9T$rAw?.$7$J$$$h$&$K$7$?!#(B
;   $B@55,I=8=$N>.JQ99(B: $BEA8@7/(B|Messenger
;   logmemo $B5!G=$r?7@_$9$k!#(Blog$BCf$K(B #: $B$G;O$^$k9T$,$"$l$P(B logmemo.txt $B$KJ]B8!#(B
;   S-mouse-2, S-mouse3(x2,x3), mouse-[45]($B%^%&%9%[%$!<%k>e2<(B) $B$KBP1~$9$k!#(B
;   NT$B$G(B&$B$r4^$`(BURL$B$r$D$C$D$1$J$$%P%0$r=$@5$9$k!#(B
;   italk-url-browse $B$rDL>o(Bcommand$B$H$7$F5/F0$G$-$k$h$&$K$9$k!#(B
;   italk-send-quoted-region $B$G;vA0$K(B untabify $B$9$k!#(B
;   C-c C-q $B$G(B 2$B=E$K(B logsave $B$5$l$k%P%0$r=$@5$9$k!#(B
;   italk-send-quoted-region $B<B9TCf$K@ZCG$5$l$k$H<!$N(B send $B$,<:GT$9$k%P%0$r(Bfix$B!#(B
;   $B8xF;:GB.(B(TM)$B!"F&Ie20%b!<%I(B(TM)$BBP1~!#(B)
;  ($B$?$@$70J2<$O4^$_$^$;$s(B:
;   /l$B$rAw$k$H(B/q$B$K$J$k!#(B:-)
;   /l$B"*(B/q $BCV49$r(B comment out $B$9$k!#(B
;   process-filter $B$^$o$j$N(B performance bug $B$r=$@5!#(B
;   egg$B;HMQ;~$NH/8@O3$l$r(B buffer-name $BHf3S$G?)$$;_$a$k!#(B)

; TODO: -$B!V=i2s$N(Bitalk$B5/F0;~!W!VFs2sL\0J9_$N(Bitalk$B5/F0;~!W$GI,MW$J=i4|2=$,(B
;        $BA4A3@0M}$5$l$F$J$$$N$G!"$-$A$s$HJ,$1$J$$$H$$$1$J$$!#<B32$J$$$1$I!#(B
;       -Byte compile$B$9$k$H$-(Bwarning$B=P$^$/$j$J$N$rD>$9!#(B
;       -Summary buffer$B$r(Bkill$B$7$F$bJ?5$$J$h$&$K$9$k!#(B
;       -INPUT buffer$B$r(Bkill$B$7$F$b(BM-x italk$B$GI|5l$G$-$k$h$&$K$9$k!#(B
;; $Id: italk.el,v 1.15 1999/11/04 16:03:20 toshii Exp toshii $

(defconst italk-version "italk.el 0.41+tak1.15+iwa0.4beta1")

(eval-when-compile
  (if (not (fboundp 'cadr))
      (require 'cl))
  (require 'easymenu))

(if (fboundp 'buffer-live-p)
    (defalias 'italk-buffer-live-p 'buffer-live-p)
  (defun italk-buffer-live-p (buffer)
    (and (bufferp buffer)
	 (buffer-name buffer))))

;;
;; variables for user customization
;;
(defvar italk-port 12345
  "*Default port number to connect to italk-server.")
(defvar italk-server "localhost"
  "*Default host which runs italk-server.")
(defvar italk-auto-scroll t
  "*If non-nil, LOG buffer scroll automatically.")
(make-variable-buffer-local 'italk-auto-scroll)
(defvar italk-use-channel-buffer nil
  "*If non-nil, channel buffer is also shown in summary-mode.")
(defvar italk-user-name nil     ; "$B$O$i$@(B"
  "*Default user name automatically registered to italk-server.
  If you do NOT want to start italking immediately, set nil to this variable.")
(defvar italk-secondary-servers
  '(  ; ("host [port [username]]")
    ("")  ; The first item is to be displayed at completion. (C-u M-x italk)
    ("localhost 12345")
    ("localhost 12345")
    ("locaohost 12345")
    ("localhost 12345")
    ("localhost 12345")
   )
  "*Secondary italk-servers.")
(defvar italk-server-nick-alist
  '(("vm" . "$B$a(B:"))
  "*Alist specifiying server nickname, which is prepended each line of LOG Summary buffer.
If not specified, first four letters are used.")

(defvar italk-historical-keybinding nil
  "*If non-nil, historical keybinds (C-c letter) are activated.")
(defvar italk-window-handstand nil
  "*If non-nil, INPUT buffer is placed below LOG buffer.") ; t or nil
(defvar italk-kill-name nil
  "*Regexp of the names not to be shown.")
(defvar italk-logsave-mode nil	; nil or t or 'telegram
  "*If non-nil(t or 'telegram), save *italk LOG* when connection is closed.
  t           -> save all contents of LOG.
  'telegram   -> save only telegrams and secret messages.")
(defvar italk-logsave-directory "~/Italk"
  "*Directory for saving italk logs*")
(defvar italk-netscape-program-name "netscape"
  "*Netscape program name.
Not vaild in Win32.")
;; hooks
(defvar italk-startup-hook nil
  "*A hook called at start up time.")
(defvar italk-colorset-hook nil
  "*An alternative color set function.")
(defvar italk-ping-hook 'italk-pinged-ding
  "*A hook called when pinged.")

;;
;; variables for internal use
;;
;; mule version detect
(defconst italk-xemacs (string-match "XEmacs" emacs-version))
(defvar italk-input-map nil
  "Keymap for Italk mode.")
(defvar italk-menu
  '("Italk"
    ["Quit italk"	italk-quit t]
    ["Describe Mode"	describe-mode t]
    ["Show Version"	italk-version t]
    ["-"		nil nil]
    ["Toggle kill name" italk-toggle-kill-name t]
    ["Telegram mode"	italk-telegram-mode t]
    ["Send region"	italk-send-region t]
    ["Send region with quotes" italk-send-quoted-region t]
    ["Roudoku region"	italk-roudoku-region t]
    ["Reconfigure windows" italk-reconfigure-windows t]
    ["Toggle auto scroll"  italk-toggle-auto-scroll t])
  "Menu used in italk mode.")
    
(if italk-input-map
    nil
  (setq italk-input-map (make-sparse-keymap))
  (define-key italk-input-map "\C-m" 'italk-send-message-full)
  (define-key italk-input-map "\C-j" 'italk-send-message)
  (define-key italk-input-map "\C-c\C-a" 'italk-toggle-session)
  (define-key italk-input-map "\C-c\C-l" 'italk-reconfigure-windows)
  (define-key italk-input-map "\C-c\C-k" 'italk-toggle-kill-name)
  (define-key italk-input-map "\C-c\C-r" 'italk-send-region)
  (define-key italk-input-map "\C-cR" 'italk-send-quoted-region)
  (define-key italk-input-map "\C-c\M-r" 'italk-roudoku-region)
  (define-key italk-input-map "\C-c\C-s" 'italk-toggle-auto-scroll)
  (define-key italk-input-map "\C-c\C-v" 'italk-version)
  (define-key italk-input-map "\C-c\C-q" 'italk-quit)
  (define-key italk-input-map "\C-c " 'scroll-other-window)
  (define-key italk-input-map "\C-c\177" 'scroll-other-window-down)
  (define-key italk-input-map "\C-c\C-p" 'italk-telegram-mode)
  (define-key italk-input-map "\C-c\C-o" 'italk-search-last-logout)
  (if italk-historical-keybinding
      (progn
	(define-key italk-input-map "\C-cl" 'italk-reconfigure-windows)
	(define-key italk-input-map "\C-co" 'italk-search-last-logout)
	(define-key italk-input-map "\C-cp" 'italk-telegram-mode)
	(define-key italk-input-map "\C-c?" 'describe-mode)
	(define-key italk-input-map "\C-ck" 'italk-toggle-kill-name)
	(define-key italk-input-map "\C-cr" 'italk-send-region)
	(define-key italk-input-map "\C-cs" 'italk-toggle-auto-scroll)
	(define-key italk-input-map "\C-cv" 'italk-version)
	(define-key italk-input-map "\C-cq" 'italk-quit)
	(if (equal (lookup-key global-map "\C-]") 'quail-mode)
	    (define-key italk-input-map "\C-]" ""))	; disable quail-mode
	))
  (if (and (memq window-system '(x win32 w32))
	   (not italk-xemacs))
      (progn
	(define-key italk-input-map [S-mouse-3] 'italk-toggle-auto-scroll)
	(define-key italk-input-map [S-double-mouse-3] 'italk-search-last-logout)
	(define-key italk-input-map [S-triple-mouse-3] 'italk))))
(easy-menu-define italk-input-menu italk-input-map
		  "Menu used in italk mode."
		  italk-menu)


(defvar italk-log-map nil
  "Keymap for Italk LOG buffer.")
(if italk-log-map
    nil
  (setq italk-log-map (make-sparse-keymap))
  (define-key italk-log-map "\C-c\C-l" 'italk-reconfigure-windows)
  (define-key italk-log-map "\C-c\C-s" 'italk-toggle-auto-scroll)
  (define-key italk-log-map "\C-c\C-o" 'italk-search-last-logout)
  (if italk-historical-keybinding
      (progn
	(define-key italk-log-map "\C-cl" 'italk-reconfigure-windows)
	(define-key italk-log-map "\C-cs" 'italk-toggle-auto-scroll)
	(define-key italk-log-map "\C-co" 'italk-search-last-logout)))
  (if (memq window-system '(x win32 w32))
      (progn
	(define-key italk-log-map   [mouse-2] 'italk-url-browse-mouse)
	(define-key italk-log-map   [S-mouse-2]
	  (lookup-key (current-global-map) "\C-l"))  ; recenter
	(define-key italk-log-map   [S-mouse-3] 'italk-toggle-auto-scroll)
	(define-key italk-log-map   [mouse-4] 'italk-scroll-down-1-mouse)
	(define-key italk-log-map   [mouse-5] 'italk-scroll-up-1-mouse)
	(define-key italk-log-map   [S-double-mouse-3] 'italk-search-last-logout)
	; reconfig windows and enable autoscroll.
	(define-key italk-log-map   [S-triple-mouse-3] 'italk))))

(defvar italk-input-summary-buffer nil)
(defvar italk-log-summary-buffer nil)
(defvar italk-sessions nil
  "List of italk sessions variables.
For each element of this list, see description of italk-session.")
(defvar italk-session nil
  "Session active in the buffer.
(process server port user-name prefix)")

(defvar italk-telegram-flag nil)    ; t (in telegram mode), or nil
(defvar italk-telegram-to nil)      ; channel number, or nil
(defvar italk-telegram-last-from nil)    ; channel from which telegram is sent
(defvar italk-kill-name-flag t)

(defvar italk-previous-window-configuration nil)
(defvar italk-default-window-configuration nil)

(defconst italk-regexp-receive-telegram "^#< Message from (\\([0-9]+\\)) \\[")
(defconst italk-log-buffer-name "*italk LOG*")
(defconst italk-input-buffer-name "*italk INPUT*")
(defconst italk-log-summary-buffer-name "*italk LOG Summary*")
(defconst italk-input-summary-buffer-name "*italk INPUT Summary*")
(defconst italk-temporary-buffer "*italk temporary*")
(defconst italk-month-alist '(
  ("Jan"  1)
  ("Feb"  2)
  ("Mar"  3)
  ("Apr"  4)
  ("May"  5)
  ("Jun"  6)
  ("Jul"  7)
  ("Aug"  8)
  ("Sep"  9)
  ("Oct" 10)
  ("Nov" 11)
  ("Dec" 12)
))

(if (and (>= emacs-major-version 20)
	 (not italk-xemacs))
    (if (string-match "4\\.0" mule-version)
	(make-coding-system
	 'italk-euc 2 ?E
	 "ISO 2022 based EUC encoding for Japanese"
	 '((ascii t) japanese-jisx0208 katakana-jisx0201 japanese-jisx0212
	   short ascii-eol ascii-cntl nil nil single-shift)
	 '((safe-charsets . t)))
      (define-coding-system-alias 'italk-euc 'euc-japan)))

;; faces, paint-alist
(make-face 'italk-time-face)
(make-face 'italk-name-face)
(make-face 'italk-login-face)
(make-face 'italk-system-face)
(make-face 'italk-evil-face)
(make-face 'italk-url-face)

; functions for set face
  ; (return non-nil value if succeeded)
(defun italk-set-face-foreground (face color)
  (condition-case err
    (set-face-foreground face color)
    (error
      (if (equal (nth 1 err) "X server cannot allocate color")
        nil (eval err)))))
(defun italk-set-face-background (face color)
  (condition-case err
    (set-face-background face color)
    (error
      (if (equal (nth 1 err) "X server cannot allocate color")
        nil (eval err)))))
; set face
(if (or (and (featurep 'mule) (null window-system))
        (and (facep 'region) (face-underline-p 'region)))
  (progn
    (defvar italk-terminal-p t)
    (copy-face 'default         'italk-time-face)
    (copy-face 'bold            'italk-name-face)
    (copy-face 'bold            'italk-login-face)
    (copy-face 'default         'italk-system-face)
    (copy-face 'bold-italic     'italk-evil-face)
    (copy-face 'underline       'italk-url-face)
  )
  (defvar italk-terminal-p nil)
  (if italk-colorset-hook
    (run-hooks 'italk-colorset-hook)
    (progn  ;else
      ;; 
      ;; color allocation policy:
      ;;  (0) Assume that X server has primary 8 colors.
      ;;  (1) If emacs can use all colors -> full spec
      ;;  (2) If only purple is not usable, use magenta altanatively.
      ;;  (3) If emacs can use no special colors -> colors like terminal-face
      ;; 
      (if (italk-set-face-foreground 'italk-name-face     "forestgreen")
        (progn  ; case (1)(2)
          (set-face-foreground 'italk-time-face     "blue")
          (if (not (italk-set-face-foreground 'italk-system-face   "purple"))
            (set-face-foreground 'italk-system-face   "magenta")
          )
          (set-face-foreground 'italk-login-face    "red")
          (set-face-background 'italk-evil-face     "yellow")
          (copy-face           'underline 'italk-url-face)
          (set-face-foreground 'italk-url-face      "blue")
        )
        (progn  ; case (3)
          (italk-set-face-foreground 'italk-name-face     "blue")
          (copy-face 'default        'italk-time-face)
          (copy-face 'default        'italk-system-face)
          (italk-set-face-foreground 'italk-login-face    "red")
          (italk-set-face-background 'italk-evil-face     "yellow")
          (copy-face 'underline      'italk-url-face)
          (italk-set-face-foreground 'italk-url-face      "blue")
        )
      )
    )
  )
)

(defvar italk-paint-alist-src
  (list
    ; format...
    ;   use raw regexp: (regexp face)
    ;   use compiler  : ('compile regexp-src face)
    
    '(")\\(\\[\\($BCf7Q7/(B\\|$BEA8@7/(B\\|Messenger\\)\\] \\)?\\[[^]]*\\]" italk-name-face)
    '(")\\[\\($BAjF#7/(B\\|$B%O=E3_(B\\|$B$O$k$_(B\\|$BCf7Q7/(B\\|$BEA8@7/(B\\|Messenger\\|log$B7/(B\\)\\]"
                                                        italk-system-face)
    '("^(\\[.*\\].*)$"                                  italk-login-face)
    '(" logged out "                                    default)
    '("^([0-9][0-9]:[0-9][0-9]:[0-9][0-9]\\(\\.[0-9]*\\)?)" italk-time-face)
    '("^#.*$"                                           italk-system-face)
    '("Message \\(from\\|to\\).* \\[[^]]*\\]"           italk-name-face)
    (list
      'compile
      (concat "["
        "$B,!(B-$B,~(B"
        "$B-!(B-$B-~(B"
        "$B)!(B-$B)~(B"			;NEC half width
        "$B*!(B-$B*~(B"
        "$B+!(B-$B+~(B"
        ;"$B(!(B-$B(~(B"
        "$By!(B-$B|~(B"			;NEC extend kanji
        "$B}!(B-$B~~(B"			;Undefined 
        "\C-a-\C-i"
        "\C-k-\C-z"
        "\C-[\C-\\\C-]\C-^\C-_"
      "]")
      'italk-evil-face
    )
    '("\\(http:/\\|ftp:/\\|file:/\\|gopher:/\\|telnet:/\\)[!#-'*-;=?-~]*"
      italk-url-face)
  )
)
(defvar italk-paint-alist nil)
(if (null italk-paint-alist)
  ; compile regular expression in italk-paint-alist
  (let ((s italk-paint-alist-src) (r '(nil)) p l a d)
    (setq p r)  ; init p(ointer) for r(esult value)
    (while s
      (setq l (car s))
      (if (eq (nth 0 l) 'compile)
        (progn
          (setq a (if (and (fboundp 'regexp-compile)
			   (not italk-xemacs))
		      (regexp-compile (nth 1 l))
		    (nth 1 l)))
          (setq d (nth 2 l))
        )
        (progn
          (setq a (nth 0 l)) ;pattern
          (setq d (nth 1 l)) ;face
        )
      )
      (if (and (memq window-system '(x win32 w32)) (eq d 'italk-url-face))
        (setq d (list 'face d 'mouse-face 'highlight))
        (setq d (list 'face d))
      )
      (setcdr p (cons (cons a d) nil))
      (setq p (cdr p))
      (setq s (cdr s))
    )
    (setq italk-paint-alist (cdr r))
  )
)
(defvar italk-regexp-kill-name nil)
(if (and (null italk-regexp-kill-name)
         (stringp italk-kill-name)
         (not (string= italk-kill-name "")))
  (setq italk-regexp-kill-name (concat "^(..:..:..)\\[\\("
                                       italk-kill-name
                                       "\\)\\] .*\n"))
)


;;
;; functions
;;
(defmacro italk-buffer-disable-undo (BUFFER)
  (if (fboundp 'buffer-disable-undo)
      (list 'buffer-disable-undo BUFFER)
    (list 'buffer-flush-undo BUFFER))
  )

(defun italk-prepare-buffer (&optional noswitch server)
  "Prepare italk buffers.
Reuse old buffers if SERVER is specified and
 closed italk buffers to the SERVER exists."
  (let ((l (and server (buffer-list)))
	(re (concat "\\`" (regexp-quote italk-input-buffer-name))))
    (while (and l
		(or (not (string-match re (buffer-name (car l))))
		    (progn (set-buffer (car l))
			   nil)
		    (not (boundp 'italk-session))
		    (and (processp (car italk-session))
			 (not (memq (process-status (car italk-session)) '(closed exit))))
		    (not (string= server (cadr italk-session)))))
      (setq l (cdr l)))
    (if (null l)
	(set-buffer (generate-new-buffer italk-input-buffer-name))))
  (italk-mode)
  (setq italk-previous-window-configuration (current-window-configuration))
  (if noswitch
      nil
    (switch-to-buffer (current-buffer))
    (italk-reconfigure-windows)))

(defun italk-create-summary-buffers ()
  "Create a pair of summary buffers."
  (interactive)
  (if (and (bufferp italk-input-summary-buffer)
	   (italk-buffer-live-p italk-input-summary-buffer))
      (progn
	(switch-to-buffer italk-input-summary-buffer)
	(italk-reconfigure-windows))
    (setq italk-input-summary-buffer
	  (get-buffer-create italk-input-summary-buffer-name))
    (setq italk-log-summary-buffer
	  (get-buffer-create italk-log-summary-buffer-name))
    (set-buffer italk-input-summary-buffer)
    (kill-all-local-variables)
    (switch-to-buffer italk-input-summary-buffer)
    (make-local-variable 'italk-log-buffer)
    (setq italk-log-buffer italk-log-summary-buffer)
    (italk-mode)			;;xxx needs clean up
    (setq italk-session (car-safe italk-sessions))
    (set-buffer italk-log-summary-buffer)
    (setq buffer-read-only t)
    (buffer-disable-undo)
    (italk-reconfigure-windows)))

(defun italk-toggle-session ()
  "Toggle target session of summary input buffer."
  (interactive)
  (if (not (eq italk-input-summary-buffer (current-buffer)))
      (error "Not a summary buffer"))
  (let ((s italk-sessions))
    (while (and s
		(not (equal (car s) italk-session)))
      (setq s (cdr s)))
    (setq s (cdr s))
    (if (null s)
	(setq italk-session (car italk-sessions))
      (setq italk-session (car s))
      (set-buffer italk-log-summary-buffer)
      (setq italk-session (car s))))
  (set-buffer italk-input-summary-buffer)
  (setq mode-line-process
	(if italk-session
	    (format "@%s:%d"
		    (italk-get-hostname-from-domainname (cadr italk-session))
		    (nth 2 italk-session))
	  nil))
  (if italk-use-channel-buffer
      (let ((newbuf (process-buffer (car italk-session))))
	(other-window 1)
	(switch-to-buffer newbuf)
	(other-window -1)))
  (redraw-frame (selected-frame)))

; added by Tak.
(defun italk-get-hostname-from-domainname (domainname)
  (if (string-match "^\\([^.]*\\)\\." domainname 0)
    (substring domainname (match-beginning 1) (match-end 1))
    domainname
  )
)

(defun italk-reconfigure-windows ()
  "Setup italk windows."
  (interactive)
  (if (and (boundp 'italk-input-buffer) (bufferp italk-input-buffer))
      nil
    (error "hoge"))
  (switch-to-buffer italk-input-buffer)

  (if (cadr italk-session)
    (setq mode-line-process
      (format "@%s:%d"
        (italk-get-hostname-from-domainname (cadr italk-session))
        (nth 2 italk-session))))
  (delete-other-windows)
  (if italk-window-handstand
      (split-window-vertically -4)
    (split-window-vertically 4)
    (other-window 1))

  (if (and italk-use-channel-buffer
	   (eq italk-input-summary-buffer (current-buffer))
	   italk-session)
      (progn
	(split-window-vertically)
	(switch-to-buffer (process-buffer (car italk-session)))
	(goto-char (point-max))
	(other-window 1)))
  (switch-to-buffer italk-log-buffer)
  (goto-char (point-max))

  (other-window 1)
  (goto-char (point-max))
  (redraw-frame (selected-frame)))

(defun italk-get-string ()
  (save-excursion
    (let ((p (point)))
      (beginning-of-line)
      (buffer-substring (point) p)
      )
    )
  )

(defun italk-send-message ()
  (interactive)
  (let ((str (italk-get-string)))
    (if (string= str "")
        (progn (ding) (message "no message"))
      (newline)
      (process-send-string (car italk-session) (concat str "\n"))
      )
    str
    )
  (setq italk-time-last-send-message (current-time))
  )

; modified by Tak.
(defun italk-telegram-parse-string (str)
;
; (other msg)   : nil
; /p            : (nil . nil)
; /p ch         : (ch  . nil)
; /p ch msg     : (ch  . t)
;
  (if (and (>= (length str) 3) (string= (substring str 0 3) "/p "))
    (let ((sc nil) (sv nil) (r (cons nil nil)))
      (setq sv (italk-parse-string str))
      (setq sc (car sv))  ; count of parsed strings
      (setq sv (cdr sv))  ; value of parsed strings
      (if (and (>= sc 2)
               (string-match "^[0-9]+$" (car (cdr sv)) 0))
        (progn
          (setcar r (string-to-number (car (cdr sv))))
          (if (>= sc 3)
            (setcdr r t))
        )
      )
      r
    )
    nil
  )
)
(defun italk-telegram-mode ()
  "Toggle telegram mode and register new address."
  (interactive)
  (setq italk-telegram-flag t)
  (if (not (and (bolp) (eolp)))
    (let ((a nil))
      (beginning-of-line)
      (setq a (point))
      (end-of-line)
      (setq a (italk-telegram-parse-string (buffer-substring a (point))))
      (end-of-line)
      (insert "\n")
      (if (and a (car a) (not (cdr a)) (= (car a) italk-telegram-to))
        (if (/= (car a) italk-telegram-last-from)
          (setq italk-telegram-to italk-telegram-last-from)
          (setq italk-telegram-flag nil)
        )
      )
    )
  )
  (if italk-telegram-flag 
    (if italk-telegram-to
      (insert (concat "/p " italk-telegram-to " "))
      (if italk-telegram-last-from
        (insert (concat "/p " italk-telegram-last-from " "))
        (insert (concat "/p "))
      )
    )
  )
)
(defun italk-send-message-full ()
  (interactive)
  (let ((sendskipf nil))
    (if italk-telegram-flag
	(let ((a nil))
	  (beginning-of-line)
	  (setq a (point))
	  (end-of-line)
	  (setq a (italk-telegram-parse-string (buffer-substring a (point))))
	  (if (or (not a) (not (car a)))
	      (setq italk-telegram-flag nil)
	    (progn
	      (setq italk-telegram-to (car a))
	      (if (not (cdr a))
		  (setq italk-telegram-flag nil)
		)
	      )
	    )
          (if (and a (not (and (car a) (cdr a))))
	      (setq sendskipf t))
	  )
      )
    (end-of-line)
    (if (not sendskipf)
	(italk-send-message))
    (if italk-telegram-flag
	(progn
	  (if (not (eolp))
	      (save-excursion (insert "\n"))
	    )
	  (if italk-telegram-to
	      (insert (concat "/p " italk-telegram-to " "))
	    (insert (concat "/p "))
	    )
	  )
      )
      ; italk-send-message updates italk-time-last-send-message
      ;(setq italk-time-last-send-message (current-time))
    )
)

(defun italk-send-region (beg end)
  "Send region to italk-server."
  (interactive "r")
; modified by Tak.
  (if (> end beg)
    (let ((ss (buffer-substring beg end)))
      (if (/= (aref ss (1- (length ss))) ?\n)
        (setq ss (concat ss "\n"))
      )
      (process-send-string (car italk-session) ss)
    )
  )
)

(defun italk-quit ()
  "Quit italk by sending /q."
  (interactive)
  (let ((italk-process (car italk-session)))
    (if (not (memq (process-status italk-process) '(closed exit)))
	(if (y-or-n-p "italk: Do you really want to quit talking?")
	    (progn
	      ;(if (and (buffer-modified-p) italk-logsave-mode)
	      ;  (italk-logsave-buffer))
	      (process-send-string italk-process "/q\n")
	      (accept-process-output italk-process)
	      ;;	    (if (frame-live-p italk-frame)
	      ;;		(delete-frame italk-frame))
	      (set-window-configuration italk-previous-window-configuration)
	      )
	  )
      (message "italk: Connection is not established.")
      (set-window-configuration italk-previous-window-configuration))))


(defun italk-version ()
  "Show the version number of italk.el"
  (interactive)
  (message italk-version))

(defun italk-toggle-auto-scroll ()
  "Stop/restart scrolling of *italk LOG* buffer."
  (interactive)
  (message (if (save-excursion
		 (set-buffer italk-log-buffer)
		 (setq italk-auto-scroll (not italk-auto-scroll)))
               "italk: Autoscroll enabled." "italk: Autoscroll disabled."))
  )
  
(defun italk-toggle-kill-name ()
  "Stop/restart kill-name facility."
  (interactive)
  (message (if (setq italk-kill-name-flag
                     (and italk-regexp-kill-name (not italk-kill-name-flag)))
               "italk: Kill name enabled." "italk: Kill name disabled."))
)

(defun italk-mode ()
  "Major mode for Inter-talk.
You should not use this function directly. Please use \\[italk] instead.
\n\\{italk-input-map}"
  (interactive)

  (make-local-variable 'italk-telegram-flag)    ; t (in telegram mode), or nil
  (make-local-variable 'italk-telegram-to)      ; channel number, or nil
  (make-local-variable 'italk-telegram-last-from)    ; channel from which telegram is sent
;  (make-local-variable 'italk-kill-name-flag)
  (make-local-variable 'italk-session)
  (make-local-variable 'italk-regexp-receive-ping)
  (make-local-variable 'italk-pinged-string)
  (make-local-variable 'italk-time-last-send-message)
  (make-local-variable 'italk-log-backlog-p)

  (make-local-variable 'italk-previous-window-configuration)
  (make-local-variable 'italk-log-buffer)
  (make-local-variable 'italk-input-buffer)
  (setq italk-input-buffer (current-buffer))
  (if (or (not (boundp 'italk-log-buffer))
	  (not (bufferp italk-log-buffer)))
      (setq italk-log-buffer (generate-new-buffer italk-log-buffer-name)))
  (setq major-mode 'italk-mode
	mode-name "Italk")
  (use-local-map italk-input-map)
  (easy-menu-add italk-menu italk-input-map)

  (let ((ib (current-buffer))
	(lb italk-log-buffer))
    (save-excursion
      (set-buffer italk-log-buffer)
      (use-local-map italk-log-map)
      (make-local-variable 'italk-log-buffer)
      (make-local-variable 'italk-input-buffer)
      (setq italk-input-buffer ib)
      (setq italk-log-buffer lb))))

(defun italk-other-frame (&optional who server port)
  "Start italking on a newly created frame."
  (interactive "P")
  (let ((italk-frame (make-frame
		     '(;;(name . "Inter-talk")
		       ;;(line-space . "0+0")
		       ;;(font . "14")
		       (height . 40) (width . 80)
		       ;;(menu-bar-lines . 1) (vertical-scroll-bars . t)
		       ))))
    (select-window (frame-selected-window italk-frame))
    (italk who server port))
  )

; added by Tak.
(defun italk-scroll-up-1 (arg)
  "Scroll text upward 1 line with keep cursor position in window."
  (interactive "p")
  (if (null arg) (setq arg 1))
  (if (< arg 0)
    (tak-scroll-down-1 (- arg))
    (let
      (
        (ln 0)
        (ws (window-start))
        (col (current-column))
      )
      (vertical-motion 0)
      (while (> (point) ws)
        (vertical-motion -1)
        (setq ln (1+ ln))
      )
      (while (> arg 0)
        (move-to-window-line -1)
        (end-of-line)
        (if (eobp)
          (progn
            (princ "End of buffer.")
            (setq arg 0)
          )
          (progn
            (move-to-window-line 0)
            (forward-line 1)
            (beginning-of-line)
            (set-window-start (selected-window) (point))
          )
        )
        (setq arg (1- arg))
      )
      (move-to-window-line ln)
      (move-to-column col)
    )
  )
)

(defun italk-scroll-down-1 (arg)
  "Scroll text downward 1 line with keep cursor position in window."
  (interactive "p")
  (if (null arg) (setq arg 1))
  (if (< arg 0)
    (tak-scroll-up-1 (- arg))
    (let
      (
        (ln 0)
        (ws (window-start))
        (col (current-column))
      )
      (vertical-motion 0)
      (while (> (point) ws)
        (vertical-motion -1)
        (setq ln (1+ ln))
      )
      (while (> arg 0)
        (move-to-window-line 0)
        (beginning-of-line)
        (if (bobp)
          (progn
            (princ "Beginning of buffer.")
            (setq arg 0)
          )
          (progn
            (forward-line -1)
            (set-window-start (selected-window) (point))
          )
        )
        (setq arg (1- arg))
      )
      (move-to-window-line ln)
      (move-to-column col)
    )
  )
)

(defun italk-scroll-down-1-mouse () (interactive) (italk-scroll-down-1 3))
(defun italk-scroll-up-1-mouse () (interactive) (italk-scroll-up-1 3))

(defun italk-parse-string (str)
;; (italk-parse-string " ab cd ef ") -> (3 "ab" "cd" "ef")
  (let ((l nil) (s 0) (e nil) (r (cons nil nil)) (p nil) (c 0))
    (setq p r)  ; ptr to last of list of strings
    (setq e (length str))
    ;
    ;(setq l (string-match "\\(\\S-+\\)" str s))
    (setq l (string-match "\\([^ \t]+\\)" str s))
    ;(while (and (< s e) (= (char-syntax (aref str s)) ? ))
    ;  (setq s (1+ s))
    ;)
    (while l
      (setq s (match-end 1))
      (setcdr p (cons (substring str l s) nil))
      (setq p (cdr p))
      (setq c (1+ c))
      (setq l (string-match "\\([^ \t]+\\)" str s))
    )
    (setcar r c)
    r
  )
)
(defun italk-diff-time-seconds (b a)
  (let ((r nil))
    (setq r (+ (* (- (car b) (car a))
                  65536)
               (- (car (cdr b)) (car (cdr a)))))
    (if (>= r 0) r (- r))
  )
)
(defun italk-pinged-ding ()
  (save-excursion
    (set-buffer italk-input-buffer)
    (if (> (italk-diff-time-seconds (current-time)
				    italk-time-last-send-message)
	   120)
	(progn
	  (ding)
	  (setq italk-time-last-send-message (current-time))
	)
    )
  )
)
(defun italk-search-last-logout ()
  "Search your last logout message in the LOG buffer."
  (interactive)
  (let (
      (re (concat "(\\[" (nth 3 italk-session) "[^ ]* logged out @ "))
      p
      w
    )
    (setq w (get-buffer-window italk-log-buffer))
    (if w (progn
      (select-window w)
      (setq p (re-search-backward re nil t nil))
      (if (null p)
        (message "Last logout message not found.")
        (message "found! Autoscroll disabled.")
        (setq italk-auto-scroll nil)
      )
    ))
  )
)
;; by HRD (97-02-14.italk)
(defun italk-force-pop-frame ()
  (let ((window (get-buffer-window (current-buffer) 'visible)))
    (and (window-live-p window)
      (let ((f (window-frame window)))
        (make-frame-visible f)
        (raise-frame f)))
    )
  )
;(add-hook 'italk-ping-hook 'italk-force-pop-frame t)  ; for add your .emacs

(defun italk-logsave-buffer (&optional arg)
  "Save *italk LOG* buffer into log spool directory.
   If italk-logsave-mode is 'telegram and optional arg is nil, save only
   telegrams and secret messages. Otherwise, save all contents of LOG buffer."
  (interactive "P")
  (save-window-excursion
    (let (buf
          start
          contents
          (mode (if arg t italk-logsave-mode))
          (path (file-name-as-directory
            (expand-file-name italk-logsave-directory)))
          (tim (current-time-string))
          mstart
          mpath)
      (setq mpath path)
      (switch-to-buffer (get-buffer-create italk-log-buffer))
      (if (eq mode 'telegram)
        (save-excursion
          (beginning-of-buffer)
          (if (re-search-forward "^#[<>:]" nil t)
            (setq start (match-beginning 0))
          )
        )
        (setq start (point-min))
      )
      ; for logmemo
      (save-excursion
        (beginning-of-buffer)
        (if (re-search-forward "^#:" nil t)
          (setq mstart (match-beginning 0))
        )
      )
      ;
      (if (not start)
        (message "logsave: There is no message to save.")
        ;else
        (if (file-exists-p path)
          nil
          ;else
          (message "logsave: making directory %s..." path)
          (make-directory path)
          (set-file-modes path 448)
          (message "logsave: directory has made.")
        )
        ;
        (setq contents (buffer-substring start (point-max)))
        (setq buf (get-buffer-create italk-temporary-buffer))
        (switch-to-buffer buf)
        (insert contents)
        ;(setq contents nil)
        (if (eq mode 'telegram)
          (progn
            (beginning-of-buffer)
            (keep-lines "^#[<>:]")
          )
        )
        ; for logmemo
        (if (not mstart)
          (setq contents nil)
          ;else
          (if (eq mode 'telegram)
            (progn
              (setq contents (buffer-string))
              (beginning-of-buffer)
              (keep-lines "^#[<>]")
            )
          )
        )
	;
        (if (eq (point-min) (point-max))
          (message "logsave: There is no message to save.")
          ;else
          (beginning-of-buffer)
          (insert (concat "## LOGSAVE AT: " tim "\n"))
          (end-of-buffer)
          (insert "\n")
          ;
          (setq path (concat path
            (format "%04d%02d%02d.log"
              (string-to-number (substring tim 20 24))
              (nth 1 (assoc (substring tim 4 7) italk-month-alist))
              (string-to-number (substring tim 8 10))
            )))
          (message "logsave: appending %s..." path)
          (append-to-file (point-min) (point-max) path)
          (message "logsave: done.")
        )
        (kill-buffer buf)
      )
      ; for logmemo
      (if (not mstart)
        nil
        ;else
        (setq buf (get-buffer-create italk-temporary-buffer))
        (switch-to-buffer buf)
        (insert contents)
        (setq contents nil)
        (beginning-of-buffer)
        (keep-lines "^#:")
        (if (eq (point-min) (point-max))
          nil ;(message "logsave: There is no message to save.")
          ;else
          (beginning-of-buffer)
          (insert (concat "## LOGSAVE AT: " tim "\n"))
          (end-of-buffer)
          (insert "\n")
          ;
          (setq path (concat mpath "logmemo.txt"))
          (message "logsave: appending %s..." path)
          (append-to-file (point-min) (point-max) path)
          (message "logsave: done.")
        )
        (kill-buffer buf)
      )
      ;
      (setq contents nil)
      ;
      (switch-to-buffer (get-buffer-create italk-log-buffer))
      (set-buffer-modified-p nil)
    )
  )
)

(defun italk-paint-buffer ()
  "Paint ordinary buffer with the same convention as italk LOG."
  (interactive)
  (let ((s (buffer-string)))
    (erase-buffer)
    (italk-insert-paint-string s)
    (beginning-of-buffer)
  )
)

(defun italk-validate-variables ()
  (if (and (italk-buffer-live-p italk-log-summary-buffer)
	   (italk-buffer-live-p italk-input-summary-buffer))
      nil
    (setq italk-log-summary-buffer nil
	  italk-input-summary-buffer nil))
  (setq italk-sessions
	(delq nil (mapcar (lambda (x)
			    (if (memq (process-status (car x)) '(closed exit))
				nil
			      x))
			  italk-sessions))))

;;; from quotes.el
(defvar italk-quote-string ">")
(defun italk-send-quoted-region (beg end &optional quotes fillp)
  "Send region to italk-server with quote."
  (interactive "r")
  (if (> end beg)
      (let ((ss (concat " " (buffer-substring beg end)))
	    (b (generate-new-buffer italk-temporary-buffer))
	    (ib (or (and (boundp 'italk-input-buffer)
			 italk-input-buffer)
		    italk-input-summary-buffer
		    (error "Cannot determine target session")))
	    col)
	(if (null quotes)
	    (setq quotes (read-from-minibuffer
			  "Send region with quote: " italk-quote-string))
	  )
	(while (= (aref ss (1- (length ss))) ?\n)
	  (setq ss (substring ss 0 (1- (length ss))))
	  )
	(setq ss (substring (concat ss "\n") 1))
	(save-excursion
	  (set-buffer ib)
	  (setq col fill-column)
	  (set-buffer b)
	  (setq fill-column (- col (length quotes)))
	  (insert ss)
	  (setq ss nil)
	  (if (not fillp)
	      (untabify (point-min) (point-max)))
	  (if fillp (progn
		      (goto-char (point-min))
		      (replace-regexp "^[ \t$B!!(B]+" "")
		      (fill-region (point-min) (point-max))
		      ))
	  (goto-char (point-min))
	  (replace-regexp "^" quotes)
	  (beginning-of-line)
	  (process-send-string (save-excursion (set-buffer ib) (car italk-session))
			       (buffer-substring (point-min) (point)))
	  (kill-buffer b)))))

(defun italk-roudoku-region (beg end &optional quotes)
  "Fill and send region to italk-server with quote."
  (interactive "r")
  (italk-send-quoted-region beg end quotes t))

;;; end of quotes.el

;;;;;;;

(defun italk (&optional who server port)
  "Start italking, or re-setup window configuration."
  (interactive "P")
  (italk-validate-variables)		; xxx dirty method
  (if (and who (not (stringp who)))
    (let ((sc nil) (sv nil) (firstsv (car italk-secondary-servers)))
      (if (null firstsv) (setq firstsv "") (setq firstsv (car firstsv)))
      (setq who nil)
      (setq port nil)
      ; input server name
      (setq server
        (completing-read
          "Inter-talk server?: "
          ;(cons (cons italk-server nil) italk-secondary-servers)
          (if (string= firstsv "") (cdr italk-secondary-servers)
                                   italk-secondary-servers)
          nil           ; predicate
          nil           ; require-match
          ;italk-server  ; initial(old convention)
          firstsv       ; initial
                        ; hist
        )
      )
      (setq sv (italk-parse-string server))
      (setq sc (car sv))  ; count of parsed strings
      (setq sv (cdr sv))  ; value of parsed strings
      (if (>= sc 1) (setq server (car sv)))
      (if (>= sc 2) (setq port (string-to-number (car (cdr sv)))))
      (if (>= sc 3) (setq who (car (cdr (cdr sv)))))
      ; input port number
      (if (or (not (numberp port)) (= port 0))
        (setq port
          (read (read-string "Server port?: " (int-to-string italk-port))))))

    ; set default user name
    (if (and (or (not (stringp who)) (string= who ""))
             (stringp italk-user-name)
             (not (string= italk-user-name ""))
        )
      (setq who italk-user-name)
    )
  )
  ; input user name
  (while (or (not (stringp who)) (string= who ""))
    (setq who (read-string "Your name?: "
                           (if italk-user-name italk-user-name "")))
  )
  (if (not server) (setq server italk-server))
  (if (not port) (setq port italk-port))

  (let ((s italk-sessions)
	(newsession (list server port who
			  (or (cdr-safe (assoc server italk-server-nick-alist))
			      (concat (substring server 0 (min 4 (length server)))
				      ":")))))
    (while (and s
		(not (equal newsession (cdar s))))
	  (setq s (cdr s)))
    (if (null s)
	nil
      (switch-to-buffer (process-buffer (caar s)))
      (italk-reconfigure-windows)
      (error "Inter-talk connection is still alive")) ; $BJ,Nv6X;_(B:-)

    (italk-prepare-buffer (or (eq (current-buffer) italk-input-summary-buffer)
			      (eq (current-buffer) italk-log-summary-buffer))
			  server)
    (if (< emacs-major-version 20)
	(define-service-coding-system port nil *euc-japan*))

    (message "trying to connect host %s:%d ..." server port)
    (setq italk-session
	  (cons (open-network-stream "italk" italk-log-buffer server port)
		newsession)))
  (let ((s italk-session))
    (save-excursion
      (set-buffer italk-log-buffer)
      (make-local-variable 'italk-session)
      (setq italk-session s)))

  (set-buffer (get-buffer italk-log-buffer))
  (setq italk-auto-scroll t)
  (setq buffer-read-only nil)
  (setq mode-line-process '(":%s"))
  (erase-buffer)
  (set-marker (process-mark (car italk-session)) (point))
  (if (< emacs-major-version 20)
      (set-current-process-coding-system '*euc-japan* '*junet*dos)
    (if italk-xemacs
	(set-process-coding-system
	 (car italk-session) 'euc-jp-dos 'iso-2022-7bit-dos)
      (set-process-coding-system
       (car italk-session) 'italk-euc-dos 'junet-dos)))
  (setq buffer-read-only t)
  (buffer-enable-undo)
  (goto-char (point-max))
  (set-buffer (get-buffer italk-input-buffer))
  (setq mode-line-process (format "@%s:%d" 
    (italk-get-hostname-from-domainname server) port))
  (setq fill-column 58)
  (setq italk-sessions (cons italk-session italk-sessions))
  (setq italk-kill-name-flag (and italk-regexp-kill-name))
  (run-hooks 'italk-startup-hook)
  (setq italk-time-last-send-message (current-time))

  (erase-buffer)
  (goto-char (point-min))
  (set-process-sentinel (car italk-session) 'italk-sentinel)
  (set-process-buffer (car italk-session) italk-log-buffer)
  (save-excursion
    (set-buffer italk-log-buffer)
    (make-local-variable 'italk-pushd-string)
    (make-local-variable 'italk-log-backlog-p)
    (make-local-variable 'italk-regexp-receive-ping)
    (setq italk-regexp-receive-ping
	  (concat
	   "^\\(([0-9][0-9]:[0-9][0-9]:[0-9][0-9])\\[.*\\]\\|#<\\) \\(\\[[^]]+\\] \\)?ping "
	   who
	   "$"))
    (setq italk-pushd-string nil
	  italk-log-backlog-p nil))
  (set-process-filter (car italk-session) 'italk-display-filter)
  (process-send-string (car italk-session) (concat who "\n"))
  (message "italk: Connection established. [%s:%d]" server port))


(defun italk-sentinel (process event)
  (let ((stat (process-status process)) mf)
    (save-excursion
      (set-buffer (process-buffer process))
      (goto-char (point-min))
      )
    (if (or (eq stat 'closed)
	    (eq stat 'exit))
	(progn
	  (message "italk: Connection closed.")

	  (let ((s nil)			; delete closed session from italk-sessions
		(so italk-sessions)
		s1)
	    (while so
	      (setq s1 (car so))
	      (setq so (cdr so))
	      (if (eq process (car s1))
		  nil
		(setq s (cons s1 s))))
	    (setq italk-sessions s))
	  
	  (delete-process process)
	  (force-mode-line-update t)
	  (save-excursion
	    (set-buffer (process-buffer process))
	    (setq mf (buffer-modified-p))
	    (goto-char (point-max))
	    (setq inhibit-read-only t)
	    (insert "*** Connection closed. ***\n"))
	    (setq inhibit-read-only nil)
	    (if (and mf italk-logsave-mode)
	      (italk-logsave-buffer))
	  )
      (error "italk: %s" event)
      )
    )
  )


(defun italk-display-filter (proc string)
  (let ((old-buffer (current-buffer)))
    (unwind-protect
	(let ((has-telegram nil)
	      (pushstr nil)
	      window undo-backup )
	  (set-buffer (process-buffer proc))
	  (setq window (get-buffer-window (current-buffer) 'visible))
	  (setq italk-pushd-string
		(concat italk-pushd-string string))
	  (if (or (= 10 (aref string (- (length string) 1)))
		  (and (> (length italk-pushd-string) 2048)
		       (let ((a (string-match ".*\\'" italk-pushd-string)))
			 (setq pushstr
			       (substring italk-pushd-string
					  a)
			       italk-pushd-string
			       (substring italk-pushd-string
					  0 a))
			 t)))
	      (progn
		(if (and (null italk-log-backlog-p)
			 (string-match "^## __ BACK LOG START __"
				       italk-pushd-string))
                    (setq italk-log-backlog-p t))
		(if (string-match italk-regexp-receive-telegram
				  italk-pushd-string)
                    (setq italk-telegram-last-from
			  (string-to-number
			   (substring italk-pushd-string
				      (match-beginning 1) (match-end 1)))
			  has-telegram t))
		(if (and italk-ping-hook (null italk-log-backlog-p))
		    (if (string-match italk-regexp-receive-ping
                                      italk-pushd-string)
			(progn
			  (setq italk-pinged-string italk-pushd-string)
			  (run-hooks 'italk-ping-hook))))
		(if (and italk-log-backlog-p
			 (string-match "^## -- BACK LOG END --"
				       italk-pushd-string))
                    (setq italk-log-backlog-p nil))
		
                  ;
                  
                  ;(if (not (string-match italk-regexp-kill-name
                  ;                  italk-pushd-string))
		(setq inhibit-read-only t
		      undo-backup buffer-undo-list)
		(save-excursion
		  (goto-char (point-max))
		  (if has-telegram
		      (setq italk-pushd-string (italk-delete-duplicated italk-pushd-string)))
		  (let ((str (italk-paint-string italk-pushd-string)))
		    (if (zerop (length str))
			nil
		      (insert str)
		      (if italk-log-summary-buffer
			  (let ((prefix (nth 4 italk-session)))
			    (set-buffer italk-log-summary-buffer)
			    (save-excursion
			      (goto-char (point-max))
			      (let ((inhibit-read-only t))
				(save-excursion
				  (insert str))
				(while (re-search-forward "^" (1- (point-max)) t)
				  (replace-match prefix t t)))))))))
			  
		(setq inhibit-read-only nil
		      buffer-undo-list undo-backup)
					;)
		(setq italk-pushd-string pushstr)))
	  (if (and (window-live-p window) italk-auto-scroll)
	      (set-window-point window (point-max)))
	  (if (and italk-log-summary-buffer
		   (progn (set-buffer italk-log-summary-buffer)
			  italk-auto-scroll))
	      (set-window-point (get-buffer-window italk-log-summary-buffer 'visible)
				(point-max)))
	  )
      (set-buffer old-buffer))))

(defun italk-display-duplicated-p (str)
  (and (string-match italk-regexp-receive-telegram str)
       (let ((telegram-from
	      (substring str
			 (match-beginning 1)
			 (match-end 1))))
	 (save-excursion
	   (beginning-of-line)
	   (while (and (zerop (forward-line -1))
		       (looking-at "#< ")
		       (not (looking-at italk-regexp-receive-telegram)))
	     nil))
	 (and (match-beginning 1)
	      (string= telegram-from
		       (buffer-substring (match-beginning 1)
					 (match-end 1)))))))
(defun italk-delete-duplicated (str)
  "Delete duplicated ``#< Message from'' lines."
  (let ((result "")
	(from t)
	(strp 0)
	from1 str1 a b)
    (while (not (string= str ""))
      (setq a (string-match "^#<" str strp)
	    b (string-match "\n" str strp))
      (if (null a)
	  (setq result (concat result (substring str strp))
		str "")
	(if (and a b
		 (< b a))
	    (progn 
	      (setq from nil)
	      (setq result (concat result (substring str strp a)))
	      (setq strp a)
	      (setq b (string-match "\n" str strp))))
	(if b
	    (setq str1 (substring str strp (1+ b))
		  strp (1+ b))
	  (setq str1 (substring str strp))
	  (setq str ""))
	
	(if (string-match italk-regexp-receive-telegram str1)
	    (progn
	      (setq from1 (substring str1 (match-beginning 1) (match-end 1)))
	      (if (and (eq from t)
		       (italk-display-duplicated-p str1))
		  (setq from from1))
	      (if (string= from from1)
		  nil
		(setq from from1)
		(setq result (concat result str1))))
	  (setq result (concat result str1))
	  (if (not (string-match "^#<" str1))
;	      (setq from nil)
	      (error "Unexpected in italk-delete-duplicated")))))
    result))

(defun italk-insert-paint-string (str)
  (if (or (null italk-kill-name-flag) (< (length str) 1000))
    (insert (italk-paint-string str))
    ;else
    (let ((len (length str)) (l 0) (s nil))
      ;else
      (while (< l len)
        (if (>= (setq l (+ (setq s l) 1000)) len)
          (setq l len)
          (if (setq l (string-match "\n" str l))
            (setq l (1+ l))
            (setq l len)
          )
        )
        (insert (italk-paint-string (substring str s l)))
      )
    )
  )
)

(defun italk-paint-string (str)
  (let* (head from
         (alist italk-paint-alist)
         pair regexp color)
    ;
    (if italk-kill-name-flag
      (progn
        (setq from 0)
        (while (setq head (string-match italk-regexp-kill-name str from))
          (setq from (match-end 0))
          (setq str (concat (substring str 0 head) (substring str from nil)))
          (setq from head)
        )
      )
    )
    ;
    (while (setq pair (car alist))
      (setq regexp (car pair)
            color (cdr pair)
            alist (cdr alist))
      (setq from 0)
      (while (setq head (string-match regexp str from))
        (setq from (match-end 0))
        (add-text-properties head from color str)
      )
    )
  )
  str
)

;; coded by tama@is.s.u-tokyo.ac.jp
(defun italk-url-browse-mouse (event)
  "Browse the URL at clicked point by Netscape."
  (interactive "e")
  (let ((posn (if italk-xemacs
		  nil
		(event-start event))))
    (save-excursion
      (if italk-xemacs
	  (progn
	    (set-buffer (event-buffer event))
	    (goto-char (event-point event)))
	(set-buffer (window-buffer (posn-window posn)))
	(goto-char (posn-point posn)))
      (if (get-text-property (point) 'mouse-face)
        (italk-url-browse)
      )
    )
  )
)

(defun italk-url-browse ()
  "Browse the URL at point by Netscape."
  (interactive)
  (save-excursion
;    (if (get-text-property (point) 'mouse-face)
      (let ((url
        (progn
          (forward-char 10)
          (re-search-backward
            "http:/\\|ftp:/\\|telnet:/\\|file:/\\|gopher:/" nil t 1)
          (re-search-forward
            "\\(\\(http:/\\|ftp:/\\|telnet:/\\|file:/\\|gopher:/\\)[!#-'*-;=?-~]*\\)"
            nil t 1)
          (buffer-substring (match-beginning 1) (match-end 1))
        )))
        (set-text-properties 0 (length url) nil url)
        (if (memq window-system '(win32 w32))
          ; Win32 support by Applause
          (if (string= (getenv "OS") "Windows_NT")
            (process-send-string 
              (start-process "start" nil
                (or (getenv "COMSPEC")
                    (concat (getenv "SystemRoot") "/system32/cmd.exe"))
              )
              (concat
                "start "
                (if (string= (substring url 0 7) "http://")
                  (concat "http://\042" (substring url 7) "\042")
                  url
                )
                "\nexit\n"
              )
            )
            ;else
            (start-process "start" nil
              (or (getenv "COMSPEC")
                  (concat (getenv "windir") "\\COMMAND.com"))
              (concat "/c " (getenv "windir") "\\command\\start " url)
            )
          )
          ;else
          (message "Calling external browser...")
          (or (zerop (apply 'call-process
                        italk-netscape-program-name nil nil nil
                        (list "-remote" (concat "openURL(" url ")"))))
              (progn ; Netscape not running - start it
                (message "Starting Netscape...")
                (apply 'start-process
                  italk-netscape-program-name nil
                  italk-netscape-program-name (list url))
              )
          )
        )
      )
;    )
  )
)

(provide 'italk)

;; [EOF]
