#lang racket/base

;; Script for starting a new scribble paper

(require racket/contract)
(provide
  GTP-PAPER

  gtp-paper-logger
  log-gtp-paper-debug
  log-gtp-paper-info
  log-gtp-paper-warning
  log-gtp-paper-error
  log-gtp-paper-fatal

  (contract-out
   [make-new-paper
    (-> (and/c path-relative-to-cwd/c free-directory-name/c) void?)]
   [rename-paper
    (-> (and/c path-relative-to-cwd/c directory-exists?)
        (and/c path-relative-to-cwd/c free-directory-name/c)
        void?)]))


(require
  (only-in racket/string
    string-replace)
  racket/file
  racket/match
  racket/runtime-path)

;; =============================================================================

(define-logger gtp-paper)

(define GTP-PAPER 'gtp-paper)

(define-runtime-path TEMPLATE "./template")

;; -----------------------------------------------------------------------------

(define path-relative-to-cwd/c
  (flat-named-contract "path-relative-to-cwd"
    (and/c string?
           (λ (p)
             (let-values (((base name mbd?) (split-path p)))
               (eq? base 'relative))))))

(define free-directory-name/c
  (flat-named-contract "free-directory-name/c"
    (not/c (or/c directory-exists?
                 file-exists?))))

(define (make-new-paper paper-name)
  (log-gtp-paper-info "making new paper '~a' ..." paper-name)
  (make-paper-directory! paper-name)
  (make-info-file! paper-name)
  (make-main-file! paper-name)
  (make-scrbl-file! paper-name)
  (make-texstyle-file! paper-name)
  (make-bib-file! paper-name)
  (make-makefile! paper-name)
  (make-reader-file! paper-name)
  (log-gtp-paper-info "successfully created paper '~a'" paper-name)
  (log-gtp-paper-info "NEXT STEPS: `cd ~a; make all`" paper-name)
  (void))

(define (make-paper-directory! paper-name)
  (make-directory paper-name)
  (make-directory (build-path paper-name "lang"))
  (void))

(define (make-info-file! paper-name)
  (instantiate-template paper-name "info.rkt")
  (void))

(define (make-main-file! paper-name)
  (instantiate-template paper-name "main.rkt")
  (void))

(define (make-scrbl-file! paper-name)
  (instantiate-template paper-name "paper.scrbl" (format "~a.scrbl" paper-name))
  (instantiate-template paper-name "introduction.scrbl")
  (instantiate-template paper-name "appendix.scrbl")
  (void))

(define (make-texstyle-file! paper-name)
  (instantiate-template paper-name "texstyle.tex")
  (void))

(define (make-bib-file! paper-name)
  (instantiate-template paper-name "bib.rkt")
  (void))

(define (make-makefile! paper-name)
  (instantiate-template paper-name "Makefile")
  (void))

(define (make-reader-file! paper-name)
  (instantiate-template paper-name "reader.rkt" (build-path "lang" "reader.rkt"))
  (void))

;; instantiate-template : (-> string? path-string? (or/c #f path-string?) void?)
;; Copy the contents of #:src
;;  to the (new) file #:dst
;;  replacing any occurrences of `~a` in the source
;;  with the given string.
;;
;; This is simple and brittle for now, may add better search/replace later.
(define (instantiate-template paper-name src-name [pre-dst-name #f])
  (define src-path (build-path TEMPLATE src-name))
  (define dst-path (build-path paper-name (or pre-dst-name src-name)))
  (cond
   [(not (file-exists? src-path))
    (raise-arguments-error 'instantiate-template "file name for template" "filename" src-name "derived template name" src-path)]
   [else
    (with-output-to-file dst-path #:exists 'error
      (λ ()
        (with-input-from-file src-path
          (λ ()
            (for ((ln (in-lines)))
              (displayln (string-replace ln "~a" paper-name)))))))
    (log-gtp-paper-info "- ~a" dst-path)
    (void)]))

;; -----------------------------------------------------------------------------

(define (rename-paper src-name dst-name)
  (log-gtp-paper-info "renaming paper '~a' to '~a' ..." src-name dst-name)
  (copy-directory/files src-name dst-name)
  (rename-names/contents! dst-name src-name dst-name)
  (log-gtp-paper-info "successfully renamed paper '~a' to '~a'" src-name dst-name)
  (log-gtp-paper-info "NEXT STEPS: `raco pkg remove ~a; cd ~a; make all`" src-name dst-name)
  (void))

(define (rename-names/contents! root src-name dst-name)
  (let loop ([dir root])
    (parameterize ([current-directory dir])
      (for ([x (in-list (directory-list #:build? #false))])
        (define old-name (path->string x))
        (define new-name (string-replace old-name src-name dst-name))
        (unless (string=? old-name new-name)
          (rename-file-or-directory old-name new-name))
        (if (directory-exists? new-name)
          (loop new-name)
          (rename-file-contents new-name src-name dst-name))))))

(define (rename-file-contents filename src-name dst-name)
  (define tmpfile (make-tmp-filename filename))
  (with-output-to-file tmpfile #:exists 'error
    (lambda ()
      (with-input-from-file filename
        (lambda ()
          (for ((ln (in-lines)))
            (displayln (string-replace ln src-name dst-name)))))))
  (rename-file-or-directory tmpfile filename #true)
  (void))

(define (make-tmp-filename orig-filename)
  (let loop ([f0 orig-filename])
    (define f1 (path-add-extension f0 #".tmp"))
    (if (file-exists? f1)
      (loop f1)
      f1)))

;; =============================================================================

(module* main racket/base
  (require racket/cmdline racket/match (submod ".."))
  (define *mode* (make-parameter #f))
  (let loop ([argv (current-command-line-arguments)])
    (command-line
     #:program (symbol->string GTP-PAPER)
     #:argv argv
     #:once-any
     [("-n" "--new") name "Start a new paper" (*mode* (cons 'new name))]
     [("-r" "--rename") from to "Rename existing paper" (*mode* (list 'rename from to))]
     #:once-each
     #:args ()
     (match (*mode*)
      [(cons 'new name)
       (make-new-paper name)]
      [(list 'rename from to)
       (rename-paper from to)]
      [other-mode
       (log-gtp-paper-error "unrecognized mode ~a" other-mode)
       (loop '#("--help"))]))))

;; -----------------------------------------------------------------------------

(module+ test
  ;; TODO
)
