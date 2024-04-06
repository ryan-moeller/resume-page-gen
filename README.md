Resume page generator
=====================

Outputs my resume as `index.html` in the current directory.

An existing `index.html` will be overwritten, so be careful!

The output is not nicely formatted, but you can use browser
dev tools for manually checking the generated HTML.

Requirements
------------

This project uses [Racket][], a dialect of Scheme.  Racket packages are
commonly available in package repositories.  Check the Racket website for
additional details.

[Racket]: https://racket-lang.org

Usage
-----

First ensure the dependencies are installed:
```
raco pkg install txexpr css-expr
```

Then run the program:
```
racket main.rkt
```

Credits
-------

The photograph used as the topbar background is originally from
[acheronnights][] on DeviantArt.

[acheronnights]: https://acheronnights.deviantart.com/art/Glitter-1-409578173
