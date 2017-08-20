#lang info
(define collection "gtp-paper")
(define deps '("base" "pollen" "scribble-abbrevs"))
(define build-deps '("rackunit-lib" "racket-doc" "scribble-doc"))
(define pkg-desc "Package for creating Scribble papers")
(define version "0.0")
(define pkg-authors '(ben))
(define scribblings '(("docs/gtp-paper.scrbl" () (omit-start))))
(define raco-commands '(("gtp-paper" (submod gtp-paper main) "Start a new paper" #f)))