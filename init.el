;;;; Packages

(add-hook 'package-menu-mode-hook #'hl-line-mode)

;; Also read: <https://protesilaos.com/codelog/2022-05-13-emacs-elpa-devel/>
(setq package-archives
      '(("gnu-elpa" . "https://elpa.gnu.org/packages/")
        ("gnu-elpa-devel" . "https://elpa.gnu.org/devel/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/")))

;; Highest number gets priority (what is not mentioned has priority 0)
(setq package-archive-priorities
      '(("gnu-elpa" . 3)
        ("melpa" . 2)
        ("nongnu" . 1)))

(setq package-install-upgrade-built-in nil)

(defvar nik/default-font-size 140)
(defvar nik/default-variable-font-size 140)

(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(set-face-attribute 'default nil :font "Hack Nerd Font" :height nik/default-font-size)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "Hack Nerd Font" :height nik/default-font-size)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "Cantarell" :height nik/default-variable-font-size :weight 'regular)

(use-package doom-themes
  :init (load-theme 'doom-tokyo-night t))

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

;; Use-package configuration for Evil mode
(use-package evil
  :ensure t
  :init
  ;; Set up any variables before loading evil
  (setq evil-want-integration t)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-keybinding nil)
  :config
  ;; Enable Evil mode
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package counsel
  :config
  (counsel-mode 1))

(use-package vertico
  :config
  (vertico-mode 1))

(use-package marginalia
  :config
  (marginalia-mode 1))

(global-set-key (kbd "C-x b") 'counsel-switch-buffer)
(global-set-key (kbd "C-x /") 'counsel-rg)
(global-set-key (kbd "C-x g") 'magit)

;; yank-media--registered-handlers org mode
  
  ;; Org mode customizations
  (defun nik/org-font-setup ()
    ;; Replace list hyphen with dot
    (font-lock-add-keywords 'org-mode
                            '(("^ *\\([-]\\) "
                               (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

    ;; Set faces for heading levels
    (dolist (face '((org-level-1 . 1.7)
                    (org-level-2 . 1.6)
                    (org-level-3 . 1.5)
                    (org-level-4 . 1.4)
                    (org-level-5 . 1.3)
                    (org-level-6 . 1.2)
                    (org-level-7 . 1.1)
                    (org-level-8 . 1.0)))
      (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

    ;; Ensure that anything that should be fixed-pitch in Org files appears that way
    (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
    (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
    (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
    (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
    (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
    (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
    (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
    (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
    (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch))

  (defun nik/org-mode-setup ()
    (org-indent-mode)
    (variable-pitch-mode 1)
    (visual-line-mode 1)
    (org-bullets-mode 1))

  (defun nik/ensure-heading-exists (file headline)
    "Ensure that a heading exists in the specified file. If the heading does not exist, it is created."
    (save-excursion
      (with-current-buffer (find-file-noselect file)
        (org-with-wide-buffer
         (goto-char (point-min))
         (unless (search-forward-regexp (format "^*\\s-+News" ) nil t)
           (goto-char (point-max))
           (insert "* News\n"))
         (unless (re-search-forward (format "^**\\s-+%s$" headline) nil t)
           (goto-char (point-max))
           (insert (format "** %s\n" headline)))
         (save-buffer)))))


  (use-package org
    :bind ("C-c c" . org-capture)
    :hook (org-mode . nik/org-mode-setup)
    :config
    (setq org-ellipsis " ▾")

    (setq org-agenda-start-with-log-mode t)
    (setq org-log-done 'time)
    (setq org-log-into-drawer t)

    (setq org-agenda-files
          '("~/org/inbox.org"
            "~/org/gr.org"
            "~/org/zencar.org"
            "~/org/loktar.org"
            "~/org/projects.org"
            "~/org/home.org"))
    (setq org-archive-location "~/org/archive.org::* From %s")
    (setq org-todo-keywords
          '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(e)")
            (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))
    (setq org-refile-targets
          '(("archive.org" :maxlevel . 1)
            ("gr.org" :maxlevel . 1)
            ("zencar.org" :maxlevel . 1)
            ("loktar.org" :maxlevel . 1)
            ("projects.org" :maxlevel . 1)
            ("home.org" :maxlevel . 1)))

    ;; Save Org buffers after refiling!
    (advice-add 'org-refile :after 'org-save-all-org-buffers)
    ;; Configure custom agenda views
    (setq org-agenda-custom-commands
          '(("d" "Dashboard"
             ((agenda "" ((org-deadline-warning-days 7)))
              (todo "NEXT"
                    ((org-agenda-overriding-header "Next Tasks")))
              (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

            ("n" "Next Tasks"
             ((todo "NEXT"
                    ((org-agenda-overriding-header "Next Tasks")))))

            ("W" "Work Tasks" tags-todo "+work-email")

            ;; Low-effort next actions
            ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
             ((org-agenda-overriding-header "Low Effort Tasks")
              (org-agenda-max-todos 20)
              (org-agenda-files org-agenda-files)))

            ("w" "Workflow Status"
             ((todo "WAIT"
                    ((org-agenda-overriding-header "Waiting on External")
                     (org-agenda-files org-agenda-files)))
              (todo "REVIEW"
                    ((org-agenda-overriding-header "In Review")
                     (org-agenda-files org-agenda-files)))
              (todo "PLAN"
                    ((org-agenda-overriding-header "In Planning")
                     (org-agenda-todo-list-sublevels nil)
                     (org-agenda-files org-agenda-files)))
              (todo "BACKLOG"
                    ((org-agenda-overriding-header "Project Backlog")
                     (org-agenda-todo-list-sublevels nil)
                     (org-agenda-files org-agenda-files)))
              (todo "READY"
                    ((org-agenda-overriding-header "Ready for Work")
                     (org-agenda-files org-agenda-files)))
              (todo "ACTIVE"
                    ((org-agenda-overriding-header "Active Projects")
                     (org-agenda-files org-agenda-files)))
              (todo "COMPLETED"
                    ((org-agenda-overriding-header "Completed Projects")
                     (org-agenda-files org-agenda-files)))
              (todo "CANC"
                    ((org-agenda-overriding-header "Cancelled Projects")
                     (org-agenda-files org-agenda-files)))))))

    (setq org-capture-templates
        `(("t" "Time-sensitive task" entry
           (file+headline "inbox.org" "Tasks with a date")
           ,(concat "* TODO %^{Title} %^g\n"
                    "%^{How time sensitive it is|SCHEDULED|DEADLINE}: %^t\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":END:\n\n"
                    "%?")
           :empty-lines-after 1)
          ("n" "News for scouts" plain
           (function
            (lambda ()
              (let ((headline (format-time-string "%Y-%m-%d" (org-read-date nil t "+mon")))
                    (org-file (expand-file-name "gr.org" org-directory)))
                (nik/ensure-heading-exists org-file headline)
                (find-file org-file)
                (goto-char (point-min))
                (re-search-forward (format "^*\\s-+News\\s-*$"))
                (re-search-forward (format "^**\\s-+%s$" headline))
                (org-end-of-subtree t))))
           ,(concat "*** [[%^{Link to news source}][%^{Title}]]\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":END:\n\n"
  		  "*Whatsapp & FB*:\n%^{Text for Whatsapp}\n------\n"
  		  "*Twitter*:\n%^{Text for Twitter}\n"
                    "%?")
           :empty-lines-after 2)
          ))



    (nik/org-font-setup))

(with-eval-after-load 'org
  (setq yank-media--registered-handlers '(("image/.*" . #'org-mode--image-yank-handler))))

;; org mode image yank handler
(yank-media-handler "image/.*" #'org-mode--image-yank-handler)

;; org-mode insert image as file link from the clipboard
(defun org-mode--image-yank-handler (type image)
  (let ((file (read-file-name (format "Save %s image to: " type))))
    (when (file-directory-p file)
      (user-error "%s is a directory"))
    (when (and (file-exists-p file)
               (not (yes-or-no-p (format "%s exists; overwrite?" file))))
      (user-error "%s exists"))
    (with-temp-buffer
      (set-buffer-multibyte nil)
      (insert image)
      (write-region (point-min) (point-max) file))
    (insert (format "[[file:%s]]\n" (file-relative-name file)))))
  (require 'org-tempo)


  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("ts" . "src typescript"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))

  ;; Automatically tangle our Emacs.org config file when we save it
  (defun nik/org-babel-tangle-config ()
    (when (string-equal (file-name-directory (buffer-file-name))
                        (expand-file-name user-emacs-directory))
      ;; Dynamic scoping to the rescue
      (let ((org-confirm-babel-evaluate nil))
        (org-babel-tangle))))

;;;; `ediff'
(use-package ediff
  :ensure nil
  :commands (ediff-buffers ediff-files ediff-buffers3 ediff-files3)
  :init
  (setq ediff-split-window-function 'split-window-horizontally)
  (setq ediff-window-setup-function 'ediff-setup-windows-plain)
  :config
  (setq ediff-keep-variants nil)
  (setq ediff-make-buffers-readonly-at-startup nil)
  (setq ediff-merge-revisions-with-ancestor t)
  (setq ediff-show-clashes-only t))

;;;; `project'
(use-package project
  :ensure nil
  :bind
  (("C-x p ." . project-dired)
   ("C-x p C-g" . keyboard-quit)
   ("C-x p <return>" . project-dired)
   ("C-x p <delete>" . project-forget-project))
  :config
  (setopt project-switch-commands
          '((project-find-file "Find file")
            (project-find-regexp "Find regexp")
            (project-find-dir "Find directory")
            (project-dired "Root dired")
            (project-vc-dir "VC-Dir")
            (project-shell "Shell")
            (keyboard-quit "Quit")))
  (setq project-vc-extra-root-markers '(".project")) ; Emacs 29
  (setq project-key-prompt-style t) ; Emacs 30

  (advice-add #'project-switch-project :after #'prot-common-clear-minibuffer-message))

(use-package magit
  :ensure t
  :bind ("C-c g" . magit-status)
  :init
  (setq magit-define-global-key-bindings nil)
  (setq magit-section-visibility-indicator '("⮧"))
  :config
  (setq git-commit-summary-max-length 50)
  (setq git-commit-style-convention-checks '(non-empty-second-line))
  (setq magit-diff-refine-hunk t)
  (setq magit-repository-directories
        '(("~/pro" . 1))))

(use-package password-store
  :ensure t
  :bind ("C-c k" . password-store-copy)
  :config
  (setq password-store-time-before-clipboard-restore 30))

(use-package pass
  :ensure t
  :commands (pass))
