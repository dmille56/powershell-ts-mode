;;; powershell-ts-mode --- Summary

;; Powershell mode using treesitter

;; To install treesitter grammar (requires Emacs 29, git, C compiler, C++ compiler):
;; M-x treesit-install-language-grammer
;; Enter in powershell as your language
;; Enter yes to build recipe for powershell interactively
;; Enter in the url of the grammar: https://github.com/airbus-cert/tree-sitter-powershell
;; Stick to the defaults for git branch, "src" directory, C compiler, and C++ compilers
;; Tested with commit: 9d95502e730fb403bdf56279d84630c8178b10be

;;; Commentary:

;; Useful references:
;; - https://www.masteringemacs.org/article/lets-write-a-treesitter-major-mode
;; - https://github.com/mickeynp/html-ts-mode

;; Notes:
;; :TODO: go through tutorial / language features make sure everything looks good
;; :TODO: syntax highlighting
;;  - fix all the features being functions...
;; :TODO: indentation support
;;  - test more thoroughly... figure out if anything seems missing
;; :TODO: imenu support
;;  - make top level variables work better
;;  - get rid of duplicates in the list (for top level variables)
;; :TODO: make sure Which Function Mode works
;; :TODO: add powershell shell support
;; :TODO: add code folding support

;;; Code:

(require 'treesit)
(require 'prog-mode)

(defgroup powershell-ts-mode nil
  "Customize group for powershell-ts-mode.el."
  :group 'emacs)

(defcustom powershell-ts-command-default 'pwsh
  "Default command pwsh or powershell."
  :type '(choice (const pwsh)
                 (const powershell))
  :group 'powershell-ts-mode)

(defcustom powershell-ts-compile-command
  '(concat (symbol-name powershell-ts-command-default) " \"" (buffer-file-name) "\"")
  "Default command compile command to run a powershell script."
  :type 'string
  :group 'powershell-ts-mode)

(defcustom powershell-ts-enable-imenu-top-level-vars t
  "Non-nil to enable top level vars in imenu."
  :type 'boolean
  :group 'powershell-ts-mode)

(defcustom powershell-ts-mode-indent-offset 4
  "Number of spaces for each indentation step in `powershell-ts-mode'."
  :type 'integer
  :group 'powershell-ts-mode)

(defvar powershell-ts-font-lock-rules
  '(
    :language powershell
    :feature comment
    ((comment) @font-lock-comment-face)

    :language powershell
    :feature variable
    ((unary_expression (variable) @font-lock-variable-name-face))

    :language powershell
    :feature variable
    ((variable) @font-lock-variable-name-face)

    :language powershell
    :feature string
    ((string_literal (verbatim_string_characters) @font-lock-string-face))

    :language powershell
    :feature string
    :override t
    ((string_literal (expandable_string_literal) @font-lock-string-face))

    :language powershell
    :feature string
    :override t
    ((string_literal (expandable_here_string_literal) @font-lock-string-face))

    ;; class definition
    :language powershell
    :feature function
    ((class_statement "class" @font-lock-keyword-face (simple_name)))
    
    ;; function definition (in a class)
    :language powershell
    :feature function
    ((class_method_definition (simple_name) @font-lock-function-name-face))

    ;; function definition
    :language powershell
    :feature function
    ((function_statement "function" @font-lock-operator-face (function_name) @font-lock-function-name-face))
    
    ;; function call
    :language powershell
    :feature function
    :override t
    ((command command_name: (command_name) @font-lock-function-call-face))
    
    ;; parameter
    :language powershell
    :feature function
    :override t
    ((command_parameter) @font-lock-constant-face)

    :language powershell
    :feature function
    :override t
    ((param_block "param" @font-lock-keyword-face))

    ;; comparison operator
    :language powershell
    :feature function
    :override t
    ((comparison_operator) @font-lock-builtin-face)

    ;; if statement
    :language powershell
    :feature function
    :override t
    ((if_statement "if" @font-lock-keyword-face))

    ;; else statement
    :language powershell
    :feature function
    :override t
    ((else_clause "else" @font-lock-keyword-face))

    ;; elseif statement
    :language powershell
    :feature function
    :override t
    ((elseif_clause "elseif" @font-lock-keyword-face))

    ;; foreach statement
    :language powershell
    :feature function
    :override t
    ((foreach_statement "foreach" @font-lock-keyword-face))

    ;; for statement
    :language powershell
    :feature function
    :override t
    ((for_statement "for" @font-lock-keyword-face))

    ;; while statement
    :language powershell
    :feature function
    :override t
    ((while_statement "while" @font-lock-keyword-face))

    ;; do while statement
    :language powershell
    :feature function
    :override t
    ((do_statement "do" @font-lock-keyword-face "while" @font-lock-keyword-face))

    ;; do until statement
    :language powershell
    :feature function
    :override t
    ((do_statement "do" @font-lock-keyword-face "until" @font-lock-keyword-face))

    ;; flow control statements (continue/break/return/throw/exit)
    :language powershell
    :feature function
    :override t
    ((flow_control_statement "continue" @font-lock-keyword-face))

    :language powershell
    :feature function
    :override t
    ((flow_control_statement "break" @font-lock-keyword-face))

    :language powershell
    :feature function
    :override t
    ((flow_control_statement "return" @font-lock-keyword-face))

    :language powershell
    :feature function
    :override t
    ((flow_control_statement "throw" @font-lock-keyword-face))

    :language powershell
    :feature function
    :override t
    ((flow_control_statement "exit" @font-lock-keyword-face))

    ;; type [System.Data] like syntax
    :language powershell
    :feature function
    :override t
    ((type_literal) @font-lock-type-face)
    
    ;; try/catch/finally statements
    :language powershell
    :feature function
    :override t
    ((try_statement "try"  @font-lock-keyword-face))

    :language powershell
    :feature function
    :override t
    ((catch_clause "catch"  @font-lock-keyword-face))

    :language powershell
    :feature function
    :override t
    ((finally_clause "finally"  @font-lock-keyword-face))
))

(defun powershell-ts-imenu-func-node-p (node)
  "Return non-nil if the NODE is a function definition."
  (and (equal (treesit-node-type node) "function_name")
       (equal (treesit-node-type (treesit-node-parent node)) "function_statement")))

(defun powershell-ts-imenu-func-name-function (node)
  "Return the name of a function from a function definition NODE."
  (treesit-node-text node))

(defun powershell-ts-imenu-class-node-p (node)
  "Return non-nil if the NODE is a class function definition."
  (and (equal (treesit-node-type node) "simple_name")
       (equal (treesit-node-type (treesit-node-parent node)) "class_statement")))

(defun powershell-ts-imenu-class-name-function (node)
  "Return the name of a function from a class function definition NODE."
  (treesit-node-text node))

(defun powershell-ts-imenu-class-func-node-p (node)
  "Return non-nil if the NODE is a class function definition."
  (and (equal (treesit-node-type node) "simple_name")
       (equal (treesit-node-type (treesit-node-parent node)) "class_method_definition")))

(defun powershell-ts--get-child-by-type (node type)
  "Return the first treesit NODE child that matches the given TYPE."
  (let (
        (children (treesit-node-children node))
        )
    (catch 'found-child
      (dolist (child children)
        (if (equal (treesit-node-type child) type)
            (throw 'found-child child))
        )
      nil)
    )
  )

(defun powershell-ts-imenu-class-func-name-function (node)
  "Return the name of a function from a class function definition NODE."
  (let (
        (func-name (treesit-node-text node))
        (cur (treesit-node-parent node))
        child
        class-name
        node-type
        )
    (while (and cur (not class-name))
      (setq node-type (treesit-node-type cur))

      (setq child (powershell-ts--get-child-by-type cur "simple_name"))
      (if (and (equal node-type "class_statement") child)
          (setq class-name (treesit-node-text child)))

      (setq cur (treesit-node-parent cur))
      )
    (concat class-name "." func-name)
    )
  )

(defun powershell-ts-imenu-var-node-is-top-level (node)
  "Return non-nil if the NODE has an assignment parent.
And not a class or function parent."
  (let (
        (has-assign-node nil)
        (has-func-node nil)
        (has-class-node nil)
        (node-type nil)
        (parent (treesit-node-parent node))
        )
    (while parent
      (setq node-type (treesit-node-type parent))
      (if (equal node-type "assignment_expression") (setq has-assign-node t))
      (if (equal node-type "function_statement") (setq has-func-node t))
      (if (equal node-type "class_statement") (setq has-class-node t))

      (setq parent (treesit-node-parent parent))
      )
    (if (and has-assign-node (not has-func-node) (not has-class-node)) t nil)
    )
  )

(defun powershell-ts-imenu-var-node-p (node)
  "Return non-nil if the NODE is a top level variable definition."
  (and (equal (treesit-node-type node) "variable")
       (equal (treesit-node-type (treesit-node-parent node)) "unary_expression")
       (powershell-ts-imenu-var-node-is-top-level node)))

(defun powershell-ts-imenu-var-name-function (node)
  "Return the text of a variable from a top level variable definition NODE."
  (treesit-node-text node))

(defvar powershell-ts-indent-rules
              `((powershell
                 ((parent-is "statement_block") parent-bol powershell-ts-mode-indent-offset)
                 ((parent-is "class_statement") parent-bol powershell-ts-mode-indent-offset)
                 ((parent-is "class_method_definition") parent-bol powershell-ts-mode-indent-offset)
                 ((parent-is "function_statement") parent-bol powershell-ts-mode-indent-offset)
                 ((parent-is "param_block") parent-bol powershell-ts-mode-indent-offset)
                 ((parent-is "hash_literal_expression") parent-bol powershell-ts-mode-indent-offset)
                 ((parent-is "array_expression") parent-bol powershell-ts-mode-indent-offset)
                 (no-node parent 0)
                 )))

(defun powershell-ts-setup ()
  "Setup treesit for powershell-ts-mode."
  (setq-local treesit-font-lock-settings
               (apply #'treesit-font-lock-rules
                    powershell-ts-font-lock-rules))

  (setq-local font-lock-defaults nil)
  (setq-local treesit-font-lock-level 5)

  (setq-local treesit-font-lock-feature-list
              '((comment)
                (variable)
                (string)
                ( function )))

  (setq-local treesit-simple-indent-rules powershell-ts-indent-rules)

  (setq-local treesit-simple-imenu-settings
              (append
               `(("Class" powershell-ts-imenu-class-node-p nil powershell-ts-imenu-class-name-function))
               `(("Method" powershell-ts-imenu-class-func-node-p nil powershell-ts-imenu-class-func-name-function))
               `(("Function" powershell-ts-imenu-func-node-p nil powershell-ts-imenu-func-name-function))
               (if powershell-ts-enable-imenu-top-level-vars
                   `(("Top variables" powershell-ts-imenu-var-node-p nil powershell-ts-imenu-var-name-function))
                 nil)))

  ;; some other non treesitter setup
  (setq-local electric-indent-chars
              (append "{}():;," electric-indent-chars))
  (setq-local compile-command powershell-ts-compile-command)
  (setq-local which-func-functions nil)

  ;; finish with this call to finalize the treesit setup
  (treesit-major-mode-setup))

;;;###autoload
(define-derived-mode powershell-ts-mode prog-mode "PS[ts]"
  "Major mode for editing Powershell with tree-sitter."
  :syntax-table prog-mode-syntax-table

  (setq-local font-lock-defaults nil)
  (when (treesit-ready-p 'powershell)
    (treesit-parser-create 'powershell)
    (powershell-ts-setup)))

(provide 'powershell-ts-mode)
;;; powershell-ts-mode.el ends here
