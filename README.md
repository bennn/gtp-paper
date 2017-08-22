gtp-paper
===
[![Scribble](https://img.shields.io/badge/Docs-Scribble-blue.svg)](http://docs.racket-lang.org/gtp-paper/index.html)

Raco tool for starting a new [GTP](http://prl.ccs.neu.edu/gtp/)-flavor Scribble paper.


### Usage

```
$ raco pkg install gtp-paper
$ raco gtp-paper --new <NAME>
$ raco pkg install ./<NAME>
```

Where `<NAME>` is any name.

This makes:
1. a new directory, `<NAME>`
2. a new file for the paper, `<NAME>/<NAME>.scrbl`
3. a new bibliography, `<NAME>/bib.rkt`
4. a new language, `#lang <NAME>`, defined in `<NAME>/lang`
5. a new library file `<NAME>/main.rkt`
6. a `Makefile`

To build your new paper, run `make`.

If you add a file to the paper, start the file with `#lang <NAME>`.
This language installs the Scribble reader and imports bindings from `main.rkt`.


### History

Really this is a tool for making a "Ben Greenman style" Scribble paper,
 but the citations are relevant to gradual typing performance.
