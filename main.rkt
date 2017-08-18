#lang racket/base

;; Script for starting a new scribble paper

(require racket/contract)
(provide
  GTP-PAPER
  (contract-out
   [make-new-paper
    (-> (and/c path-relative-to-cwd/c free-directory-name/c) boolean? void?)]))


(require
  (only-in racket/string
    string-replace)
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

;; TODO stop using quiet? argument
(define (make-new-paper paper-name quiet?)
  (unless quiet?
    #;(log-gtp-paper-info "making new paper '~a' ..." paper-name)
    (printf "gtp-paper: making new paper '~a' ...~n" paper-name))
  (make-paper-directory! paper-name)
  (make-info-file! paper-name)
  (make-main-file! paper-name)
  (make-scrbl-file! paper-name)
  (make-texstyle-file! paper-name)
  (make-bib-file! paper-name)
  (make-makefile! paper-name)
  (make-reader-file! paper-name)
  (unless quiet?
    #;(log-gtp-paper-info "successfully created paper. Next: `cd ~a; make all`" paper-name)
    (printf "gtp-paper: successfully created paper, next run: `cd ~a; make all`~n" paper-name))
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
              (displayln (string-replace ln "~a" paper-name)))))))]))

;; =============================================================================

(module* main racket/base
  (require racket/cmdline racket/match (submod ".."))
  (define *mode* (make-parameter #f))
  (define *quiet?* (make-parameter #f))
  (command-line
   #:program (symbol->string GTP-PAPER)
   #:once-any
   [("-n" "--new") name "Start a new paper" (*mode* (cons 'new name))]
   #:once-each
   [("-q" "--quiet") "Run quietly" (*quiet?* #true)]
   #:args ()
   (match (*mode*)
    [(cons 'new name)
     (make-new-paper name (*quiet?*))]
    [_
     (printf "unrecognized mode, try 'raco gtp-paper --help'~n")])))
