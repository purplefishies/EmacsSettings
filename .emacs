;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;(defconst my-root (expand-file-name "~/elisp"))
; Set up some home directories...
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

(defvar server-socket-dir
  (let ((uid (user-uid)))
    (if (floatp uid)
        (format "/tmp/emacs%1.0f" uid)
      (format "/tmp/emacs%d" uid))))
(require 'server)
(server-ensure-safe-dir server-socket-dir)
(server-start) 


;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Useful for copying and pasting in emacs in a terminal
; Not sure if this will cause a bug or not
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
(setq x-select-enable-primary t)
(setq x-select-enable-clipboard t)
;; (setq interprogram-paste-function 'x-cut-buffer-or-selection-value)

(unless window-system
 (when (getenv "DISPLAY")
  ;; Callback for when user cuts
  (defun xsel-cut-function (text &optional push)
    ;; Insert text to temp-buffer, and "send" content to xsel stdin
    (with-temp-buffer
      (insert text)
      ;; I prefer using the "clipboard" selection (the one the
      ;; typically is used by c-c/c-v) before the primary selection
      ;; (that uses mouse-select/middle-button-click)
      (call-process-region (point-min) (point-max) "xsel" nil 0 nil "--clipboard" "--input")))
  ;; Call back for when user pastes
  (defun xsel-paste-function()
    ;; Find out what is current selection by xsel. If it is different
    ;; from the top of the kill-ring (car kill-ring), then return
    ;; it. Else, nil is returned, so whatever is in the top of the
    ;; kill-ring will be used.
    (let ((xsel-output (shell-command-to-string "xsel --clipboard --output")))
      (unless (string= (car kill-ring) xsel-output)
        xsel-output )))
  ;; Attach callbacks to hooks
  (setq interprogram-cut-function 'xsel-cut-function)
  (setq interprogram-paste-function 'xsel-paste-function)
  ;; Idea from
  ;; http://shreevatsa.wordpress.com/2006/10/22/emacs-copypaste-and-x/
  ;; http://www.mail-archive.com/help-gnu-emacs@gnu.org/msg03577.html
 ))




;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Linux Kernel settings
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
(defun c-lineup-arglist-tabs-only (ignored)
  "Line up argument lists by tabs, not spaces"
  (let* ((anchor (c-langelem-pos c-syntactic-element))
	 (column (c-langelem-2nd-pos c-syntactic-element))
	 (offset (- (1+ column) anchor))
	 (steps (floor offset c-basic-offset)))
    (* (max steps 1)
       c-basic-offset)))

(add-hook 'c-mode-common-hook
          (lambda ()
            ;; Add kernel style
            (c-add-style
             "linux-tabs-only"
             '("linux" (c-offsets-alist
                        (arglist-cont-nonempty
                         c-lineup-gcc-asm-reg
                         c-lineup-arglist-tabs-only))))))

(add-hook 'c-mode-hook
          (lambda ()
            (let ((filename (buffer-file-name)))
              ;; Enable kernel mode for the appropriate files
              (when (and filename
                         (string-match (expand-file-name "~/src/linux-trees")
                                       filename))
                (setq indent-tabs-mode t)
                (c-set-style "linux-tabs-only")))))

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Imaxima stuff
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
(setq imaxima-fnt-size "Huge")

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Compilation stuff
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
(defun save-all-and-compile ()
  (save-some-buffers 1)
  (compile compile-command))

(setq compilation-ask-about-save nil)
(global-set-key [f5] 'compile)



;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Check for Doxymacs 
;
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
(condition-case nil
  (require 'doxymacs)
  (setq doxymacs-doxygen-style "JavaDoc")
  (add-hook 'c-mode-common-hook'doxymacs-mode)
  (error nil)
)


;; (setq tramp-default-method "ftp")


(if (not (boundp 'MULE))
    (if (featurep 'xemacs)
      ;; xemacs20, xemacs21
      (progn
    (define-key global-map 'button4
     '(lambda (&rest args)
        (interactive) 
        (let ((curwin (selected-window)))
         (select-window (car (mouse-pixel-position)))
          (scroll-down 5)
          (select-window curwin)
    )))
    (define-key global-map [(shift button4)]
     '(lambda (&rest args)
            (interactive) 
            (let ((curwin (selected-window)))
             (select-window (car (mouse-pixel-position)))
              (scroll-down 1)
              (select-window curwin)
    )))
 
    (define-key global-map [(control button4)]
     '(lambda (&rest args)
        (interactive) 
        (let ((curwin (selected-window)))
         (select-window (car (mouse-pixel-position)))
          (scroll-down)
          (select-window curwin)
    )))
 
 
 
    (define-key global-map 'button5
      '(lambda (&rest args)
        (interactive) 
        (let ((curwin (selected-window)))
          (select-window (car (mouse-pixel-position)))
          (scroll-up 5)
          (select-window curwin)
    )))
 
    (define-key global-map [(shift button5)]
      '(lambda (&rest args)
        (interactive) 
        (let ((curwin (selected-window)))
          (select-window (car (mouse-pixel-position)))
          (scroll-up 1)
          (select-window curwin)
    )))
 
    (define-key global-map [(control button5)]
      '(lambda (&rest args)
        (interactive) 
        (let ((curwin (selected-window)))
          (select-window (car (mouse-pixel-position)))
          (scroll-up)
          (select-window curwin)
    )))
    )
 
    ;;  emacs20
    (progn
      (defun up-slightly () (interactive) (scroll-up 5))
      (defun down-slightly () (interactive) (scroll-down 5))
        (global-set-key [mouse-4] 'down-slightly)
        (global-set-key [mouse-5] 'up-slightly)
 
      (defun up-one () (interactive) (scroll-up 1))
      (defun down-one () (interactive) (scroll-down 1))
        (global-set-key [S-mouse-4] 'down-one)
        (global-set-key [S-mouse-5] 'up-one)
 
      (defun up-a-lot () (interactive) (scroll-up))
      (defun down-a-lot () (interactive) (scroll-down))
        (global-set-key [C-mouse-4] 'down-a-lot)
        (global-set-key [C-mouse-5] 'up-a-lot)
    )
        )
  )


(add-to-list 'load-path "/usr/share/emacs24/site-lisp/")
(add-to-list 'load-path "/usr/share/emacs24/site-lisp/auto-complete")
;; (condition-case nil
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "/usr/share/emacs23/site-lisp//ac-dict")
(ac-config-default)
;; (error nil)
;; )



;
;check system name
;

(add-to-list 'load-path "/home/jdamon/.emacs.d/")
(add-to-list 'load-path "/home/jdamon/.emacs.d/xcscope")
(add-to-list 'load-path "/usr/share/emacs23/site-lisp/")

(condition-case nil
  (load "auctex.el" nil t t)
  (load "preview-latex.el" nil t t)
  (error nil)
)



;; (load "smart-compile.el" nil t t )

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Auto compilation
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;; (load "mode-compile.el" nil t t )


(defun mode-compile-quiet ()
  (interactive)
  (flet ((read-string (&rest args) ""))
    (mode-compile)))

;; Bury the compilation buffer when compilation is finished and successful.
(add-to-list 'compilation-finish-functions
             (lambda (buffer msg)
               (when 
                 (bury-buffer buffer)
                 (replace-buffer-in-windows buffer))))

;; C-c C-% will set a buffer local hook to use mode-compile after saving
(global-set-key '[(ctrl c) (ctrl %)]
                (lambda () 
                  (interactive)
                  (if (member 'mode-compile-quiet after-save-hook)
                      (progn
                        (setq after-save-hook 
                            (remove 'mode-compile-quiet after-save-hook))
                        (message "No longer compiling after saving."))
                    (progn
                      (add-to-list 'after-save-hook 'mode-compile-quiet)
                      (message "Compiling after saving.")))))

;; Prevent compilation buffer from showing up
;; (defadvice compile (around compile/save-window-excursion first () activate)
;;   (save-window-excursion ad-do-it))

;; Bury the compilation buffer when compilation is finished and successful.
(add-to-list 'compilation-finish-functions
             (lambda (buffer msg)
               (when 
                 (bury-buffer buffer)
                 (replace-buffer-in-windows buffer))))

(setq compilation-scroll-output 'first-error)

; Auto compilation completed
;



;; (require  'xcscope )
(define-key global-map [(control f4)]  'cscope-pop-mark)
(define-key global-map [(control f5)]  'cscope-find-this-text-string)
(define-key global-map [(control f6)]  'cscope-find-this-symbol)
(define-key global-map [(control f7)]  'cscope-find-functions-calling-this-function)
(define-key global-map [(control f8)]  'cscope-find-called-functions)
(define-key global-map [(control f9)]  'cscope-prev-symbol)
(define-key global-map [(control f10)] 'cscope-next-symbol)
;;; XEmacs backwards compatibility file


(line-number-mode t)
;(put 'my-operator 'scheme-indent-function 3)
; Stuff for setting up key bindings...
 
;(autoload 'imaxima "imaxima" "Image support for Maxima" t )
(add-to-list 'load-path "~/.emacs.d/")


(condition-case nil
  (require 'auto-complete-config)
  (error nil)
)    



 
(defun describe-face-at-point ()
              "Return face used at point."
              (interactive)
              (hyper-describe-face (get-char-property (point) 'face)))
 
(defun forward-word-correctly (&optional n)
  "Jump forward a word at a time"
  (interactive "P")
  (search-forward-regexp "[][[()_@#A-Za-z0-9&\\*\\\-\\.\\$]+")
; [A-Za-z0-9-]+"
)
 
(defun backward-word-correctly (&optional n)
  "Jump backward a word at a time"
  (interactive "P")
  (let (i)
  (search-backward-regexp "\\b[ ]+")
;    (search-backward-regexp "[A-Za-z0-9_=)]+")
;    (search-backward-regexp "[A-Za-z0-9_=\-\\)\\(]+")
  )
)
 
 
(global-set-key "\C-xg" 'goto-line)
(global-set-key "\C-b" 'backward-kill-word)
(global-set-key "\C-n" 'kill-word)
(global-set-key "\C-f" 'backward-word)
(global-set-key "\M-s" 'search-forward-regexp)
(global-set-key "\C-g" 'forward-word-correctly)

; New binding to try out
(global-set-key "\M-b" 'backward-sexp)
(global-set-key "\M-n" 'forward-sexp)


(global-set-key "\C-cc" 'comment-region)
(global-set-key [(control left)]    'backward-word-correctly)
(global-set-key [(control right)] 'forward-word-correctly)
 
 
 
(defun jump-down (&optional n )
  "Jump downwards by n secions of 8 lines"
  (interactive "P")
  (let (i count)
    (if n
        (progn 
          (setq count n)
        )
        (setq count 1)
    )
    (dotimes ( i count)
      (forward-line (* 8 (+ i 1)))
    )
  )
)
 
 
 
(defun jump-up (&optional n )
  "Jump upwards by n sections of 8 lines"
  (interactive "P")
  (let (i count)
    (if n
        (progn 
          (setq count n)
        )
        (setq count 1)
    )
    (dotimes ( i count)
      (forward-line (* -8 (+ i 1)))
    )
  )
)
 
(defun charlie-settings( &optional n )
  "Setup the charlie settings"
  (interactive "P")
  (c-set-offset 'statement-block-intro 4)
  (c-set-offset 'defun-block-intro 4)
)
 
 
 
(setq-default indent-tabs-mode nil)     ; Turn off default tabs
(setq inhibit-startup-message t)        ; Turn off start up message
(setq inhibit-default-init t)           ; Turn off default init and messages
(setq home-dir (getenv "HOME"))
;;(setq PERL_HEADER_LENGTH 76)            ;length of my Perl header
(defvar PERL_HEADER_LENGTH 76
  "Controls the length of headers")
 
(setq load-path (cons (expand-file-name "~/Emacs") load-path))
(setq load-path (cons (expand-file-name "/Users/jdamon/Emacs/spectre-mode") load-path))
(setq load-path (cons "/usr/share/emacs/site-lisp/site-start.d" load-path))
 
;( setq load-path (cons (expand-file-name "/usr/share/xemacs/site-packages") load-path))
 
 
 
(global-set-key [(control button2)] 'x-copy-primary-selection)
(global-set-key [(button4)] 'scroll-down)
(global-set-key [(button5)] 'scroll-up)
(global-set-key "\M-[a" 'jump-up)
(global-set-key "\M-[b" 'jump-down)

(global-set-key "\C-b" 'backward-kill-word)
(global-set-key "\C-n" 'kill-word)
(global-set-key "\M-?" 'help-command)
(global-set-key "\C-h" 'delete-backward-char) ; get rid of those annoying character
(global-set-key "\M-\C-s" 'shell)
(global-set-key "\M-\C-l" 'toggle-buffers-in-window)
(global-set-key "\C-xg" 'goto-line)
(global-set-key "\C-h" 'delete-backward-char)
(global-set-key "\C-c\C-c" 'comment-region)
;(global-set-key [(control left)]  'backward-word-correctly )
;(global-set-key [(control right)] 'forward-word-correctly )
(global-set-key [(control right)] 'forward-word)
(global-set-key [(control left)]  'backward-word )
;(global-set-key [(control down)]  'jump-down )
;(global-set-key [(control up )]   'jump-up )
 
;(global-set-key "\C-" 'backward-paragraph)
(define-key global-map [(control bracket)] 'backward-paragraph)
(defalias 'scroll-ahead 'scroll-up)
(defalias 'scroll-behind 'scroll-down)
 
 
 
 
 
 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; 
; Defined functions for customization 
;
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 
 
 
 
(defun scroll-n-lines-ahead ( &optional n )
  "Scroll Ahead N lines( 1 by default )."
  (interactive "P")
  (scroll-ahead (prefix-numeric-value n)))
(defun scroll-n-lines-behind (&optional n)
  "Scroll Behind N lines( 1 by default )."
  (interactive "P")
  (scroll-behind (prefix-numeric-value n)))
 
;:*======================
 
 
;*****************************************************************************
; defun::name= add-perl-header
; defun::desc= "Allows me to add headers to the top of Perl files"
; defun::options= 1. Would like to be able to add the PERL header at the
;                    top of the file
;                 2. Would like to change the name from "script" to "mod" in
;                    the case that the file in question is a script or
;                    a module. This will be determined by the suffix of the file
;                    .pm ='s mod, and .pl  ='s script. This requires looking
;                    at the suffix of the file.
;******************************************************************************
(defun add-perl-header( &optional n) 
  "Add a default header line at the start of a script"
  (interactive "P")                     ;need this for args
  (let (i j)
    (setq i 0 )
    ;;  (princ PERL_HEADER_LENGTH)
    (if n 
        (progn
          (setq count n) 
          )
      (setq count PERL_HEADER_LENGTH)
      )
    (insert "#")
    (dotimes (i count)
      (insert "*")
     )
    (let (fname prefix suffix )
      (setq fname (buffer-name))
      (string-match ".*\\.\\(.*\\)" fname)
      (setq suffix (match-string 1 fname))
      (setq prefix (perl-suffix-lookup suffix))
      (insert "\n")
      (insert "# " prefix "::name= " fname "\n")
      (insert "# " prefix "::desc=\n" )
      (insert "# " prefix "::author= " (user-real-login-name) "\n")
      (insert "# " prefix "::cvs= $Id$\n")
      (insert "# " prefix "::changed= $Date$\n")
      (insert "# " prefix "::modusr= $Author$\n")
      (insert "# " prefix "::notes=\n")
      (insert "# " prefix "::todo=\n#")
      (dotimes (i count)
        (insert "*"))
      (insert "\n")
;      (dotimes (j 2 )
;        (insert "#")
;;        (dotimes ( i count )
;;          (insert "*")
;;          )
;        (insert "\n")
;      );dotimesx
;      (_add-perl-divider "Copyright (c) 2009, MaxLinear, Inc" )
;      (dotimes (i count)
;        (insert "*"))
;      (dotimes (j 2 )
;        (insert "#")
;        (dotimes ( i count )
;          (insert "*")
;          )
;        (insert "\n")
;      );dotimes
    );let
    (insert "\n\n\n")
    ( _add-perl-divider "LIBRARIES")
    (insert "\n\n")
;    ( _add-perl-divider "FUNCTION PROTOTYPES")
;    (insert "\n\n")
    ( _add-perl-divider "GLOBAL VARIABLES")
    (insert "\n\n")
    ( _add-perl-divider "CODE")
    (insert "\n\n")
    ( _add-perl-divider "SUBROUTINES")
   );let
);defun
 
 
 
(defun perl-suffix-lookup (n)
  "Looks up the tail of a perl script and determines what the header name should be"
;  (interactive "P")
  (cond ((string= n "pl") "script")
        ((string= n "pm")  "mod" )
        ((string= n "module") "mod" )
        ((string= n "script") "script")
        (t "script"))
)
 
 
 
 
;****************************************************************************
; defun::name= add-perl-sub-header
; defun::desc= Adds a header to a perl subroutine
; defun::notes= 1. Would like to be able to parse the actual definition of
;                  the subroutine.
;****************************************************************************
 
(defun add-perl-sub-header( &optional n)
  "Add a default header to a subroutine"
  (interactive "P")
  (setq i 0 )
  (if n 
      (setq count n )
    (setq count (/ PERL_HEADER_LENGTH 2))
    )
    (insert "#")
 
  (dotimes (i count)
    (insert "=-")
    )
  (insert "\n")
  (insert "# sub::name= ")
  (yank)
  (insert "\n")
  (insert "# sub::desc= \n")
  (insert "# sub::args= \n")
  (insert "# sub::return= \n")
  (insert "# sub::notes= \n")
  (insert "# sub::todo=\n#")
  (dotimes (i count)
    (insert "=-")
  )
)
 
 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; fn::name= _add-perl-dividier
; fn::desc= Adds a Banner line, with the string in question in the exact
;           middle.  
; fn::args= 1: a string that gets put in the middle.
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 
 
(defun _add-perl-divider( &optional n char)
  "Add a Label in the middle of a line"
  (interactive "P")
  (setq char nil)
;  (if ((! char)) 1 )
;  (if 
;(cond  (if char char )
;       (t "*"))
;(cond ((char ) char)
;       (t "*"))
  (if n 
      (let (strln)
        (setq strln (length n))
        (setq i 0 )
        (if n 
            (setq count n )
          (setq count (/ PERL_HEADER_LENGTH 2) )
          )
        (insert "#")
        (let (tmp_length extra) 
          (setq tmp_length (/ (- PERL_HEADER_LENGTH strln 4) 2))
          (setq extra (mod (- PERL_HEADER_LENGTH strln 4) 2))
          (dotimes (i tmp_length)
            (insert "*"))
          (insert (format "  %s  " n ))
;          (insert "  LIBRARIES  " )
          (dotimes (i tmp_length)
            (insert "*"))
          (if (= extra 1)
              (insert "*"))
;          (insert (format "\n%d\n" extra))
        )
 
       )
    nil
    )
  t
)
; Skill stuff
 
(defun skill-suffix-lookup (n)
  "Looks up the tail of a perl script and determines what the header name should be"
;  (interactive "P")
  (cond ((string= n "ils") "skclass")
        ((string= n "il")  "skill" )
        (t "script"))
)
 
(defun add-skill-divider( &optional n)
  "Add a Skill divider"
  (interactive "P")
  (let (function_name return_type function_args
                      args i tmp)
    (setq a (point-marker))
    (end-of-line)
    (kill-region a (point-marker))
    (setq line (car kill-ring-yank-pointer))
    (_add-skill-divider line)
   )
)
 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; fn::name= _add-perl-dividier
; fn::desc= Adds a Banner line, with the string in question in the exact
;           middle.  
; fn::args= 1: a string that gets put in the middle.
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 
 
(defun _add-skill-divider( &optional n)
  "Add a Label in the middle of a line"
  (interactive "P")
  (if n 
      (let (strln)
        (setq strln (length n))
        (setq i 0 )
        (if n 
            (setq count n )
          (setq count (/ PERL_HEADER_LENGTH 2) )
          )
        (insert ";")
        (let (tmp_length extra) 
          (setq tmp_length (/ (- PERL_HEADER_LENGTH strln 4) 2))
          (setq extra (mod (- PERL_HEADER_LENGTH strln 4) 2))
          (dotimes (i ( / tmp_length 2 ))
            (insert "=~"))
          (insert (format "  %s  " n ))
          (dotimes (i (/ tmp_length 2 ) )
            (insert "=~"))
          (if (= extra 1)
              (insert "="))
;          (insert (format "\n%d\n" extra))
        )
 
       )
    nil
    )
  t
)
 
 
 
;*****************************************************************************
; defun::name= add-perl-header
; defun::desc= "Allows me to add headers to the top of Perl files"
; defun::options= 1. Would like to be able to add the PERL header at the
;                    top of the file
;                 2. Would like to change the name from "script" to "mod" in
;                    the case that the file in question is a script or
;                    a module. This will be determined by the suffix of the file
;                    .pm ='s mod, and .pl  ='s script. This requires looking
;                    at the suffix of the file.
;******************************************************************************
(defun add-skill-class-header( &optional n) 
  "Add a default header line at the Skill script"
  (interactive "P")                     ;need this for args
  (setq i 0 )
  ;;  (princ PERL_HEADER_LENGTH)
  (if n 
      (progn
        (setq count n) 
        )
    (setq count PERL_HEADER_LENGTH)
    )
  (insert ";")
  (dotimes (i ( / count 2 ))
    (insert "=~")
    )
  (let (fname prefix suffix) 
    (setq fname (buffer-name))
    (string-match ".*\\.\\(.*\\)" fname)
    (setq suffix (match-string 1 fname))
    (setq prefix (skill-suffix-lookup suffix))
    (insert "\n")
    (insert "; " prefix "::name= " fname "\n")
    (insert "; " prefix "::desc=\n" )
    (insert "; " prefix "::author= " (user-real-login-name) "\n")
    (insert "; " prefix "::cvs= $Id$\n")
    (insert "; " prefix "::changed= $Date$\n")
    (insert "; " prefix "::modusr= $Author$\n")
    (insert "; " prefix "::notes=\n")
    (insert "; " prefix "::todo=\n;")
    (dotimes (i (/ count 2))
      (insert "=~")
    );dotimes
    (insert "\n" )
    (insert ";\n")
    (insert ";           Copyright (c) 2009, MaxLinear, Inc\n" )
    (insert ";\n;")
    (dotimes (i (/ count 2))
      (insert "=~")
    );dotimes
  );let
);defun
 
 
 
 
(defun add-perl-divider( &optional n)
  "Add a Perl divider"
  (interactive "P")
  (let (function_name return_type function_args
                      args i tmp)
    (setq a (point-marker))
    (end-of-line)
    (kill-region a (point-marker))
    (setq line (car kill-ring-yank-pointer))
    (_add-perl-divider line)
   )
)
 
 
 
 
 
 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; fn::name= add-c-header
; fn::desc= Adds a c header to the top of the C file
; fn::notes= 1. Need to do a search , to find out if there is indeed another
;               header file for the file. If there isn't one.. .ADD it!
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 
(defun add-c-header( &optional n )
  "Adds the header title information for the C file"
  (interactive "P")
  (let (i count ) 
    (setq count (/ PERL_HEADER_LENGTH 2))
    (insert "/*")
    (dotimes (i count) 
      (insert "**")
    )
    (insert "\n")
    (insert " * source::name= " (buffer-name) "\n")
    (insert " * source::desc=\n")
    (insert " * source::author= " (user-real-login-name) "\n")
    (insert " * source::cvs= $Id$\n")
    (insert " * source::changed= $Date$\n")
    (insert " * source::modusr= $Author$\n")
    (insert " * source::notes=\n")
    (insert " * source::todo=\n *")
    (dotimes (i (- count 1))
      (insert "**")
    )
    (insert "*/")
  )
)
 
(defun add-tex-stuff( &optional n )
  "Adds the default TeX header stuff I like"
  (interactive "P")
  (insert "\\ifdefined\\MASTERDOCUMENT\n")
  (insert "\\else\n")
  (insert "\\documentclass{article}\n")
  (insert "\\input{header.tex}\n")
  (insert "\\begin{document}\n")
  (insert "\\fi\n")
  (insert "\\ifdefined\\MASTERDOCUMENT\n")
  (insert "\\endinput\n")
  (insert "\\else\n" )
  (insert "\\end{document}\n")
  (insert "\\fi\n") 
)

 
(defun add-perl-top-banner( &optional n )
  "Adds a top banner to the Perl subroutine"
  (interactive "P")
  (let (i count)
    (if n 
        (setq count n )
      (setq count (/ PERL_HEADER_LENGTH 2))
      )
    (insert "#")
    (dotimes (i count)
      (insert "=-")
    )
    (insert "\n")
  )
)
 
(defun add-skill-top-banner( &optional n )
  "Adds a Skill banner to the top of a subroutine"
  (interactive "P")
  (let (i count)
    (if n 
        (setq count n )
      (setq count (/ PERL_HEADER_LENGTH 2))
      )
    (indent-for-tab-command)
    (insert ";")
    (dotimes (i count)
      (insert "=~")
    )
  )
)
 
 
(defun add-perl-mod-sub-header( &optional n )
  "Adds a complex header title for the Perl subroutine"
  (interactive "P")
  (let (function_name return_type function_args
        args search listargs counter optionalargs) 
    (setq a (point-marker))
    (setq optionalargs nil)
    (end-of-line)
    (copy-region-as-kill a (point-marker))
    (setq line (car kill-ring-yank-pointer))    
    ( posix-string-match "^ *sub +\\([A-Za-z0-9_]+\\) *(\\([&$@;%*\\ ]*\\))?" line )
      (setq function_name (match-string 1 line))
      (setq function_args (match-string 2 line))
      (setq search (posix-string-match "^\\([\\]?[@&%;$*]\\)\\(.*\\)" function_args))
      (while search
        (setq arg (match-string 1 function_args))
        (setq function_args (match-string 2 function_args))
        (setq search (posix-string-match "^\\([\\]?[&@%;$*]\\)\\(.*\\)" function_args))
        (cond ((if (eq optionalargs nil) t) 
               (cond 
                ((string= arg "\\$")  (push "(SCALAR REF)" listargs ))
                ((string= arg "\\@")  (push "(ARRAY REF)" listargs ))
                ((string= arg "\\%")  (push "(HASH REF)" listargs ))
                ((string= arg "\\*")  (push "(GLOB REF)" listargs ))
                ((string= arg "\\&")  (push "(CODE REF)" listargs ))
                ((string= arg "$" )  (push "(SCALAR)" listargs ))
                ((string= arg "@" )  (push "(ARRAY)" listargs ))
                ((string= arg "%" )  (push "(HASH)" listargs))
                ((string= arg "*" )  (push "(GLOB)" listargs))
                ((string= arg ";" )  (setq optionalargs t))
                )
               )                        ;else...
              ((string= arg "\\$")  (push "(OP:SCALAR REF)" listargs ))
              ((string= arg "\\@")  (push "(OP:ARRAY REF)" listargs ))
              ((string= arg "\\%")  (push "(OP:HASH REF)" listargs ))
              ((string= arg "\\*")  (push "(OP:GLOB REF)" listargs ))
              ((string= arg "\\&")  (push "(OP:CODE REF)" listargs ))
              ((string= arg "$" )  (push "(OP:SCALAR)" listargs ))
              ((string= arg "@" )  (push "(OP:ARRAY)" listargs ))
              ((string= arg "%" )  (push "(OP:HASH)" listargs))
              ((string= arg "*" )  (push "(OP:GLOB)" listargs))
              )
        )
      (goto-char a )
      (add-perl-top-banner)
      (insert (format "# sub::name= %s\n" function_name ) )
      (insert "# sub::desc=\n")
      (insert "# sub::args=\n")
      (setq counter 1)
      (dolist (i (reverse listargs))
        (insert (format "#              %d. %-12s:\n" counter i))
        (setq counter (+ counter 1))
        )
      (insert "# sub::return=\n")
      (insert "# sub::notes=\n")
      (insert "#              None\n")
      (insert "# sub::todo=\n")
      (insert "#              None\n")
      (add-perl-top-banner)
  )
)
 
(defun sw-add-perl-package-header( &optional n )
  "Adds a header title for a Perl Package"
  (interactive "P")
  (let (function_name return_type function_args )
 
 
 
  )
)
 
(defun sw-add-perl-pod-section( &optional n)
  "Adds POD documentation at the end of the file"
  (interactive "P")
  (let ( bufname )
    (insert "__END__\n")
    (insert "\n\n=head1 NAME\n\n")
    (insert (format "%s - INSERT DESCRIPTION\n\n" (buffer-name)))
    (insert "=head1 SYNOPSIS\n\n=over 12\n\n")
    (insert "=item B<fuse_layer.pl>\n\n[][]\n\n")
    (insert "=back\n\n")
    (insert "=head1 OPTIONS AND ARGUMENTS\n\n")
    (insert "=over 8\n\n")
    (insert "=head1 DESCRIPTION\n\n")
    (insert "=head1 SEE ALSO\n\n")
    (insert "=head1 AUTHOR\n\n")
    (insert "Please report bugs to jdamon@maxlinear\n\n")
  )
); defun
 
 
(defun sw-add-perl-mod-sub-header( &optional n )
  "Adds a complex header title for the Perl subroutine"
  (interactive "P")
  (let (function_name return_type function_args
        args search listargs counter optionalargs) 
    (setq a (point-marker))
    (setq optionalargs nil)
    (end-of-line)
    (copy-region-as-kill a (point-marker))
    (setq line (car kill-ring-yank-pointer))    
    ( posix-string-match "^ *sub +\\([A-Za-z0-9_]+\\) *(\\([&$@;%*\\ ]*\\))?" line )
      (setq function_name (match-string 1 line))
      (setq function_args (match-string 2 line))
      (setq search (posix-string-match "^\\([\\]?[@&%;$*]\\)\\(.*\\)" function_args))
      (while search
        (setq arg (match-string 1 function_args))
        (setq function_args (match-string 2 function_args))
        (setq search (posix-string-match "^\\([\\]?[&@%;$*]\\)\\(.*\\)" function_args))
        (cond ((if (eq optionalargs nil) t) 
               (cond 
                ((string= arg "\\$")  (push "(SCALAR REF)" listargs ))
                ((string= arg "\\@")  (push "(ARRAY REF)" listargs ))
                ((string= arg "\\%")  (push "(HASH REF)" listargs ))
                ((string= arg "\\*")  (push "(GLOB REF)" listargs ))
                ((string= arg "\\&")  (push "(CODE REF)" listargs ))
                ((string= arg "$" )  (push "(SCALAR)" listargs ))
                ((string= arg "@" )  (push "(ARRAY)" listargs ))
                ((string= arg "%" )  (push "(HASH)" listargs))
                ((string= arg "*" )  (push "(GLOB)" listargs))
                ((string= arg ";" )  (setq optionalargs t))
                )
               )                        ;else...
              ((string= arg "\\$")  (push "(OP:SCALAR REF)" listargs ))
              ((string= arg "\\@")  (push "(OP:ARRAY REF)" listargs ))
              ((string= arg "\\%")  (push "(OP:HASH REF)" listargs ))
              ((string= arg "\\*")  (push "(OP:GLOB REF)" listargs ))
              ((string= arg "\\&")  (push "(OP:CODE REF)" listargs ))
              ((string= arg "$" )  (push "(OP:SCALAR)" listargs ))
              ((string= arg "@" )  (push "(OP:ARRAY)" listargs ))
              ((string= arg "%" )  (push "(OP:HASH)" listargs))
              ((string= arg "*" )  (push "(OP:GLOB)" listargs))
              )
        )
      (goto-char a )
      (add-perl-top-banner)
      (insert (format "# Name     : %s\n" function_name ) )
      (insert "# Desc     :\n")
      (insert "# Args     :\n")
      (setq counter 1)
      (dolist (i (reverse listargs))
        (insert (format "#              %d. %-12s:\n" counter i))
        (setq counter (+ counter 1))
        )
      (insert "# Returns  :\n")
      (insert "# Throws   :\n")
      (insert "# Notes    :\n")
      (insert "#              none\n")
      (insert "# Todo     :\n")
      (insert "#              none\n")
      (add-perl-top-banner)
  )
)
 
 
 
;------------------------------------------------------------------------------
;
; fn::name= add-c-mod-function-header
; fn::desc= adds a C function header
; fn::args= 1: optional, that describes number of characers
; fn::desc= 1. Goal is to extract from a given line, the args passed to the
;              function, and the arguments that are returned back to the
;              user itself.
; 
; fn::todos= 1. Paste the elements from the start of the line until the
;               end of the line into a buffer.............................DONE!
;            2. Save the current point, and then insert the text above
;               it........................................................DONE!
;            3. Eventually allow functions to span multiple lines until it
;               reaches the '{' character.................................
;            4. Correctly parse Pointers to functions.....................
;
;            5. Allow correct matching for a term such as follows:
;               const void *key... would be const void *..................DONE!
;            6. Allow pointer to pointer declarations.....................DONE!
;
;            7. Add fix to allow for  function declarations that return
;               pointers, like :  static int *function()..................DONE!
;            8. Add fix for base case, such as void Do_something(void)
;               and just pick up void.....................................
;------------------------------------------------------------------------------
 
(defun add-c-mod-function-header( &optional n)
  "Add a default header to a subroutine"
  (interactive "P")
  (let (function_name return_type function_args
        args i tmp)
    (setq a (point-marker))
    (end-of-line)
    (copy-region-as-kill a (point-marker))
    (setq line (car kill-ring-yank-pointer))    
;    (string-match "\\(.*\\) +\\([A-Za-z0-9_-\\*]+\\) *( *\\([^)]*\\) *) *{?" line)
    (string-match "\\(.* +\\** *\\)\\([A-Za-z0-9_-]+\\) *( *\\([^)]*\\) *) *{?" line)
    (setq return_type (match-string 1 line))
    (setq function_name (match-string 2 line))
    (setq function_args (match-string 3 line))
    (setq args (split-string function_args "," )) ; Split on the commas...
    (goto-char a)
    (insert "\n")
    (if n 
        (setq count n )
        (setq count (/ PERL_HEADER_LENGTH 2)  )
    )
    (insert "/*")
    (dotimes (i count)
      (insert "**")
    )
    (insert "\n")
    (insert " * fn::name= " function_name "\n" )
    (insert " * fn::desc= \n")
    (insert " * fn::args= \n")
    (setq i 1)
    (dolist (value args)
      (stringp value)
      (posix-string-match "^ *\\([A-Za-z0-9_ ]+\\**\\)\\b\\w+" value)
      (setq tmp (match-string 1 value))
      (insert (format " *%12s%d (%s): \n" " " i tmp) )
      (setq i (+ i 1))
    )
    (insert " * fn::return=\n")
    (insert (format " *%12s%s: \n" " " return_type ))
    (insert " * fn::notes=\n")
    (insert " * fn::todo= \n *")
    (dotimes (i (- count 1))
      (insert "**")
    )
    (insert "*/\n")
  )
)
 
 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; fn::name= add-c-function-header
; fn::desc= adds a C function header
; fn::args= 1: optional, that describes number of characers
;
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 
(defun add-c-function-header( &optional n)
  "Add a default header to a subroutine"
  (interactive "P")
  (setq i 0 )
  (if n 
      (setq count n )
    (setq count (/ PERL_HEADER_LENGTH 2))
    )
    (insert "/*")
  (dotimes (i count)
    (insert "**")
    )
  (insert "\n")
  (insert " * fn::name= ")
  (yank)
  (insert "\n")
  (insert " * fn::desc= \n")
  (insert " * fn::args= \n")
  (insert " * fn::return= \n")
  (insert " * fn::notes=\n")
  (insert " * fn::todo= \n *")
  (dotimes (i (- count 1))
    (insert "**")
  )
  (insert "*/")
 
)
 
(defun lets-test-it (&optional n )
  "Examining the characteristics of parameters"
  (interactive)                         ;no args
  (princ n)
)
 
(require 'font-lock)
;(require 'tex-site)
;(require 'xcscope)
 
(defvar null-device "/dev/null")
;; (set-face-foreground 'font-lock-type-face'            "dodgerblue")
;;(message "Making pretty Colors")
;;(message "HELLO THERE")
;(load-file "/Users/jdamon/Emacs/spice-mode.el")
;(load-file "/Users/jdamon/Emacs/modes.el")
(autoload 'vht-mode         "verilog"      "Vht programming mode" t)
(autoload 'c++-mode         "cc-mode"      "C++ programming mode" t)
(autoload 'c-mode           "cc-mode"      "C programming mode" t)
(autoload 'cvs-update       "pcl-cvs" t)
(autoload 'cvs-update-other-window "pcl-cvs" t)
(autoload 'hexl-find-file   "hexl"     "Edit file in hexl-mode." t)
(autoload 'perl-mode        "perl"     "Perl programming mode" t)
(autoload 'rdf-mode         "rdf"      "RDF analysis mode" t)
(autoload 'tm-mode          "tm"       "Time budget mode" t)
(autoload 'tcl-mode         "tcl"      "Tcl programming mode" t)
(autoload 'verilog-mode     "verilog"  "Verilog programming mode" t)
(autoload 'vm               "vm"       "VM mail reader" t)
(autoload 'spice-mode       "spice"    "Spice Mode"  t)
(autoload 'spectre-mode "spectre-mode" "Spectre Editing Mode" t)
 
(setq auto-mode-alist (append (list (cons "\\.scs$" 'spectre-mode)
                                    (cons "\\.inp$" 'spectre-mode))
                              auto-mode-alist))
 
 
;(load "auctex.el" nil t t )
;(load "preview-latex.el" nil t t )
 
 
; (add-hook 'LaTeX-mode-hook #'LaTeX-install-toolbar)
 
(setq perl-indent-level 4)
(setq cperl-indent-level 4)
(setq cperl-font-lock t)
(setq cperl-syntaxify-by-font-lock t)
;(cperl-set-style "BSD")   ; Need to find a way to specify the style with a variable...
 
 
(add-hook 'cperl-hook-mode 'outline-minor-mode)
 
(line-number-mode t)
(display-time )
(defun refill-mode (&optional arg)
  "Refill Minor Mode"
  (interactive "P")
  (setq refill-mode
        (if (null arg)
            (not refill-mode)
            (> (prefix-numeric-value arg) 0))
         
  )
  (make-local-hook 'after-change-functions)
  (if refill-mode
      (add-hook 'after-change-functions 'refill nil t)
      (remove-hook 'after-change-functions 'refill t)
  )
)
 
 
;=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
; Add a skill function header
;
;=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
(defun add-skill-function-header( &optional n )
  "Adds a Skill function header"
  (interactive "P")
  (let (function_name function_type start end indpos indent
        ) 
    (beginning-of-line)
    (setq start (point-marker (beginning-of-line)))
    (setq indpos (point-marker (forward-sexp)))
    (setq indent (- (marker-position indpos) (marker-position start)))
    (end-of-line)
    (copy-region-as-kill indpos (point-marker))
    (setq line (car kill-ring-yank-pointer))
;    (posix-string-match "^ *\( *\\([A-z0-9]+\\) *\(" line )
    (posix-string-match "^ *\( *\\([A-z0-9]+\\) *\(?.*$" line )
    (setq function_name ( match-string 1 line))
    (copy-region-as-kill start indpos )
    (setq line (car kill-ring-yank-pointer))
    (posix-string-match "^ *\\([A-z0-9]+\\)$" line )
    (setq function_type (match-string 1 line))
    (goto-char (marker-position start))
    (add-skill-top-banner)
    (insert "\n")
    (skill-fun-header-helper function_type function_name)
;    (add-skill-top-banner)
    (indent-for-tab-command)
  )
)
 
(defun writeroom ()
  "Switches to a WriteRoom-like fullscreen style"
  (interactive) 
  (when (featurep 'aquamacs)
    ;; switch to white on black
    ;; (color-theme-initialize)
    ;; (color-theme-clarity)
    ;; (color-theme-scintilla)
    ;; switch to Garamond 36pt
    (aquamacs-autoface-mode 0)
    (set-frame-font "-apple-garamond-medium-r-normal--36-360-72-72-m-360-iso10646-1")
    ;; switch to fullscreen mode
    (aquamacs-toggle-full-frame)))
 
 
(defun iconify-or-deiconify-frame-fullscreen-even ()
   (interactive)
   (if (eq (cdr (assq 'visibility (frame-parameters))) t)
     (progn
       (if (frame-parameter nil 'fullscreen) 
       (aquamacs-toggle-full-frame))     
 ;       (switch-to-buffer "*scratch*") 
       (iconify-frame))
     (make-frame-visible))) 
 (define-key global-map "\C-z" #'iconify-or-deiconify-frame-fullscreen-even)
 
 
(defun skill-fun-header-helper( name function_name )
"Extra helper function that uses the name and extra to setup headers"
    (indent-for-tab-command)
    (insert (format "; %s::name=     : %s\n" name function_name ) )
    (indent-for-tab-command)
    (insert (format "; %s::desc=     :\n" name ))
    (indent-for-tab-command)
    (insert (format "; %s::args=     :\n" name ))
    (setq counter 1)
    (indent-for-tab-command)
    (insert (format "; %s::returns=  :\n" name ))
    (indent-for-tab-command)
    (insert (format "; %s::throws=   :\n" name ))
    (indent-for-tab-command)
    (insert (format "; %s::notes=    :\n" name ))
    (indent-for-tab-command)
    (insert (format ";              none\n"))
    (indent-for-tab-command)
    (insert (format "; %s::todo     :\n" name ))
    (indent-for-tab-command)
    (insert (format ";              none\n"))
    (add-skill-top-banner)
    (insert "\n")
)


;; (delete-file filename)
(condition-case nil
    (require 'package)
  (add-to-list 'package-archives
               '("melpa" . "http://melpa.milkbox.net/packages/") t)
  (package-initialize)
  (unless (package-installed-p 'scala-mode2)
    (package-refresh-contents) (package-install 'scala-mode2))
  (require 'scala-mode2)
  (error nil))

 

 
;************************* Custimization of Faces *******************************
 
 
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(c-basic-offset 4)
 '(c-default-style (quote ((c-mode . "gnu") (c++-mode . "gnu") (java-mode . "java") (awk-mode . "awk") (other . "linux"))))
 '(cperl-brace-offset -4)
 '(cperl-continued-brace-offset 0)
 '(cperl-continued-statement-offset 4)
 '(cperl-electric-parens (quote null))
 '(cperl-indent-level 4 t)
 '(cperl-indent-parens-as-block t)
 '(display-time-mode t)
 '(load-home-init-file t t)
 '(preview-gs-options (quote ("-q" "-dNOSAFER" "-dNOPAUSE" "-DNOPLATFONTS" "-dPrinted" "-dTextAlphaBits=4" "-dGraphicsAlphaBits=4")))
 '(query-user-mail-address nil)
 '(toolbar-mail-reader (quote vm))
 '(user-mail-address "james.damon@accesio.com"))

(load-library "color-theme")
;
;(color-theme-select)
;(color-theme-scintilla)

;; '(font-lock-comment-face ((t (:foreground "pale green" :slant italic))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 143 :width normal :foundry "unknown" :family "DejaVu Sans Mono"))))
 '(cperl-array-face ((((class color) (background light)) (:foreground "Blue" :bold t :italic t))))
 '(font-lock-comment-face ((t (:foreground "tomato"))))
 '(font-lock-constant-face ((t (:foreground "CadetBlue"))))
 '(font-lock-doc-face ((t (:foreground "forest green"))))
 '(font-lock-function-name-face ((t (:foreground "sea green" :family "Monaco"))))
 '(font-lock-keyword-face ((t (:foreground "SkyBlue4"))))
 '(font-lock-string-face ((t (:foreground "plum"))))
 '(font-lock-variable-name-face ((t (:foreground "SkyBlue3"))))
 '(region ((t (:background "CornFlowerBlue"))))
 '(hl-line ((t (:background "gray16"))))
 '(highlight ((t (:background "powderblue"))))
 '(list-mode-item-selected ((t (:background "lightseagreen")))))
(set-default-font "Monaco-14")

 
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
;(princ edit-tab-stops-map)
 
;;; This was installed by package-install.el.
;;; This provides support for the package system and
;;; interfacing with ELPA, the package archive.
;;; Move this code earlier if you want to reference
;;; packages in your .emacs.
(if nil
    (when
        (load
         (expand-file-name "~/.emacs.d/elpa/package.el"))
      (package-initialize))
)
