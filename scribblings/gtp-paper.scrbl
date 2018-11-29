#lang scribble/manual
@require[
  (for-label racket/base scribble-abbrevs scribble/acmart scribble/core (except-in scriblib/autobib authors))]

@title{GTP Paper}
@author{Ben Greenman}

A @tt{raco} command for writing SIGPLAN-style papers with Scribble.

See @secref["command" #:doc '(lib "scribblings/raco/raco.scrbl")] for more about @tt{raco} commands.


@section{Usage}

To start a new paper named @exec{MY-PAPER}:

@codeblock[#:expand values]|{
  $ raco gtp-paper --new MY-PAPER
  $ cd MY-PAPER
  $ make all}|

If all goes well, then you'll have:
@itemlist[#:style 'ordered
@item{
  a directory named @filepath{MY-PAPER/};
}
@item{
  a Scribble file @filepath{MY-PAPER/MY-PAPER.scrbl};
}
@item{
  a language @tt{#lang MY-PAPER};
}
@item{
  and a few other support files, including an @filepath{introduction.scrbl},
   @filepath{appendix.scrbl}, a @filepath{Makefile}, and a bibliography @filepath{bib.rkt}.
}
]

To finish writing your paper,
@itemlist[
@item{
  add Scribble files to the current directory,
}
@item{
  begin these files with @tt{#lang MY-PAPER},
}
@item{
  and include them in @filepath{MY-PAPER/MY-PAPER.scrbl}
}
]


@section{Reference}

This section documents the bindings available in your newly-created  @hash-lang[].

In addition to the bindings below, the @hash-lang[] also has access to:
@itemlist[
@item{
  your @filepath{bib.rkt},
}
@item{
  the @racketmodname[scribble-abbrevs] package,
}
@item{
  @racketmodname[scribble/acmart], @racketmodname[scribble/example],
}
@item{
  @racketmodname[scriblib/autobib], @racketmodname[scriblib/figure], @racketmodname[scriblib/footnote],
}
]

The idea is that @tt{.scrbl} files should never use the @racket[require] form.
Everything they need should be in the @hash-lang[] --- if something's missing,
 you should add it to @filepath{MY-PAPER/main.rkt} or @filepath{MY-PAPER/bib.rkt}.

@defproc[#:link-target? #f (~cite [b bib?] ...) element?]{
  Renders a citation to the given bibliography entries.
}

@defproc[#:link-target? #f (citet [b bib?] ...) element?]{
  Renders a noun-style citation to the given bibliography entries.
}

See @racket[define-cite] for a little more information about @racket[~cite] and @racket[~citet].

