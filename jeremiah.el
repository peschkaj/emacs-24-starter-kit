;;; ---------------------------------------------------------------------
;;; Make this crap hole look nice...
(load-theme 'tango-dark t)

;;; ---------------------------------------------------------------------
;;; load `$MANPATH`, `$PATH` and `exec-path` from your shell, but only on OS X.
;;;
;;; This solves errors where git flow wasn't being used. Original solution
;;; found via https://github.com/magit/magit/issues/770
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

(setenv "PATH" (concat (getenv "PATH") ":/bin"))
(setq exec-path (append exec-path '("/bin")))



;;; ---------------------------------------------------------------------
;;; customize toolbars
;(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(menu-bar-mode t)
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))



;;; ---------------------------------------------------------------------
;;; Enable recent files mode
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\C-r" 'recentf-open-files)
(add-hook 'server-done-hook 'recentf-save-list)
(add-hook 'server-visit-hook 'recentf-save-list)
(add-hook 'delete-frame-hook 'recentf-save-list)



;;; ---------------------------------------------------------------------
;;; OS X mouse setup
(setq mac-emulate-three-button-mouse t)



;;; ---------------------------------------------------------------------
;;; Visual customizations
(defun set-frame-size-to-launch-default ()
  (interactive)
  (if (window-system)
      (set-frame-height (selected-frame) 50)))

(defun set-frame-size-to-single-width ()
  (interactive)
  (if (window-system)
      (set-frame-width (selected-frame) 80)))

(defun set-frame-size-to-double-width ()
  (interactive)
  (if (window-system)
      (set-frame-width (selected-frame) 187)))

(defun jp-ws-dw ()
  (interactive)
  (if (window-system)
      (progn (set-frame-size-to-double-width)
             (split-window-right))))

(defun jp-ws-sw ()
  (interactive)
  (if (window-system)
      (progn (set-frame-size-to-single-width)
             (delete-other-windows))))


;;; ---------------------------------------------------------------------
;;; Text editing
(defun disable-electric-indent ()
  (set (make-local-variable 'electric-indent-mode) nil))

;;; Add custom markdown mode since ELPA only includes 1.9.0 
;(add-to-list 'load-path "~/src/markdown-mode")

;;; markdown-mode configuration
(autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'markdown-mode-hook 'turn-on-auto-fill)
(add-hook 'markdown-mode-hook 'disable-electric-indent)
; just in case someone wants to turn out auto-fill-mode by hand
(global-set-key (kbd "C-c q") 'auto-fill-mode)

;;; Word count mode
; should work out how to only do this for text modes...
(autoload 'wc-mode "wc-mode" "Minor mode to count words." t nil)
(global-set-key "\M-+" 'wc-mode)

;;; sentences don't end with double spaces, we're not writing in
;;; cursive!
(setq sentence-end-double-space nil)



;;; ---------------------------------------------------------------------
;;; Code related crap

;;; Set up magit-gitflow
(require 'magit-gitflow)
(add-hook 'magit-mode-hook 'turn-on-magit-gitflow)

;;; yasnippet configuration
;;; documentation available at:
;;; http://github.com/capitaomorte/yasnippet
;(require 'yas-jit)
;(yas/jit-load)
;(yas/global-mode 1)



;;; Set tab-width because Doug
(setq tab-width 4)



;;; Set up hippie expand
;;; Create try-expand-tag to work with ctags/etags
(require 'cc-mode)
(require 'etags-table)
(defun he-tag-beg ()
  (let ((p
         (save-excursion 
           (backward-word 1)
           (point))))
    p))

(defun tags-complete-tag (string predicate what)
  (save-excursion
    ;; If we need to ask for the tag table, allow that.
    (if (eq what t)
	(all-completions string (tags-completion-table) predicate)
      (try-completion string (tags-completion-table) predicate))))

(defun try-expand-tag (old)
  (unless  old
    (he-init-string (he-tag-beg) (point))
    (setq he-expand-list (sort
                          (all-completions he-search-string 'tags-complete-tag) 'string-lessp)))
  (while (and he-expand-list
              (he-string-member (car he-expand-list) he-tried-table))
    (setq he-expand-list (cdr he-expand-list)))
  (if (null he-expand-list)
      (progn
        (when old (he-reset-string))
        ())
    (he-substitute-string (car he-expand-list))
    (setq he-expand-list (cdr he-expand-list)) t))

;;; Set up hippie-expand function list to use for tag/expansion
(setq hippie-expand-try-functions-list
      '(try-expand-dabbrev
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-expand-tag
        try-complete-file-name-partially
        try-complete-file-name
        try-expand-all-abbrevs
        try-expand-list
        try-expand-line
        try-complete-lisp-symbol-partially
        try-complete-lisp-symbol))

;;; Set up find file in project
;(require 'find-file-in-project)
;(global-set-key (kbd "C-c f") 'find-file-in-project)
;(add-to-list 'ffip-patterns "*.sql")



;;; ---------------------------------------------------------------------
;;; Global keybindings
;;; bind to ALT+/
(global-set-key (kbd "M-/")         'hippie-expand)
(global-set-key (kbd "M-g")         'goto-line)
(global-set-key (kbd "<delete>")    'delete-char)

(global-set-key (kbd "RET") 'newline-and-indent)

;;; Set up editor customizations to make text editing not a PITA
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)



;;; ---------------------------------------------------------------------
;;; Autostart emacs server
;(server-force-delete)
(server-start) 



;;; ---------------------------------------------------------------------
;;; Resize emacs window to something reasonable
(set-frame-size-to-launch-default)



;;; ---------------------------------------------------------------------
;;; ispell customizations
(setq ispell-program-name "/usr/bin/aspell")
(setq ispell-extra-args '("--sug-mode=ultra"))
(setq ispell-dictionary "american")
(setq ispell-process-directory (expand-file-name "~/"))



;;; ---------------------------------------------------------------------
;;; Configure dired to use gls instead of ls
(when (memq window-system '(mac ns))
  (setq ls-lisp-use-insert-directory-program t)
  (setq insert-directory-program "/usr/bin/ls")
)



;;; ---------------------------------------------------------------------
;;; Configure auto stop of emacs as a service.
;;; Taken from
;;; http://lists.gnu.org/archive/html/emacs-devel/2011-11/msg00348.html
(defun jp-stop-emacs ()
  (interactive)
  (if (daemonp)
      (save-buffers-kill-emacs)
      (save-buffers-kill-terminal)))



;;; ---------------------------------------------------------------------
;;; Set up for Oracle
(let ((oracle-home (shell-command-to-string ". ~/.zshrc; echo -n $ORACLE_HOME")))
  (if oracle-home
      (setenv "ORACLE_HOME" oracle-home)))


