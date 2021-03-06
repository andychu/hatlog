# Fork of hatlog

This is a demo of type inference on a tiny subset of Python in Prolog.

The original blog post describing this work is **offline** as of November 2018,
but there is a [copy on archive.org][archived-post].  ([Hacker News
comments](https://news.ycombinator.com/item?id=12108041))

There are three Python functions that can be inferred:
`examples/{fib,join,map}.py`.  The prolog output is in
`gold/{fib,join,map}.pl`.

I combined all the Python code into a single file `gen_prolog.py`.  I also
changed it to use more of a Unix style driven by shell scripts.

Try this:

    # for each example, generate Prolog code and run it, printing the inferred type
    $ ./run.sh all

    ... (snip) ...

    ==> _tmp/fib.txt <==
    ::int -> int
    
    ==> _tmp/join.txt <==
    ::List[str] -> str -> str
    
    ==> _tmp/map.txt <==
    ...
    A,B::Callable[['A'],'B'] -> List['A'] -> List['B']
    a

TODO:

- Why is there spurious text on `stdout` for `map.py`?  I got rid of one
  `writeln()` but I can't find the remaining "print".
- How to get rid of the remaining Prolog warnings?  I shut up one about
  discontiguous definitions, but I'm not sure if that is advisable.  (The
  original `bin/hatlog` Python script swallowed the `stderr` of `swipl`!)
- Can we get `examples/pathjoin.py` to work?  It uses `*p` which may not be
  supported.
- Can we infer more than one function at a time?  Imports, etc.?
- Can these programs be ported to a toy Python prolog engine?  It would be help
  me understand what Prolog is doing.
  - http://code.activestate.com/recipes/303057/
  - http://openbookproject.net/py4fun/prolog/intro.html

Questions:

- Is it possible to generate error messages when a function fails to infer?
  (e.g. `pathjoin.py`).
- How does using Prolog compare to just writing a unification / type inference
  algorithm by hand in Python?  (or OCaml, etc.)
- How does Prolog compare to [miniKanren](http://minikanren.org/)?  These
  programs are pretty simple so maybe a simpler dialect suffices?

[archived-post]: https://web.archive.org/web/20170216030548/http://code.alehander42.me/prolog_type_systems

This is a small amount of code:

    $ ./run.sh count
    324 gen_prolog.py

     86 prettyTypes.pl
     84 pythonTypeSystem.pl
    170 total

## Links

- [Production Prolog](https://www.youtube.com/watch?v=G_eYTctGZw8) -- Nice
  Strange Loop talk that evangelizes Prolog in the first half, and then
  discusses the downsides:
  - Syntax (period vs. comma)
  - Small ecosystem
  - Learning curve (even for a Haskell programmer)
  - Failure is hard to debug -- Prolog just says `false.`
    - Macros are hard to debug.
  - Performance issues more likely than in other languages.

- [Negative Reasoning in Chalk](https://aturon.github.io/blog/2017/04/24/negative-chalk/) -- Chalk is a project to use logic programming in the Rust compiler.  They want a sound specification for traits rather than ad hoc code.

- [Scala's Type Checker Happens To Contain Prolog](https://www.reddit.com/r/scala/comments/6yhrh6/scalas_type_checker_happens_to_contain_prolog/) -- I don't really understand this.  From what I gather, the type system for Scala collections is very complex.

I'm not exactly sure how related hatlog is to these systems, in principle.
It's of course much smaller and simpler.  Note that hatlog does type inference
but no type checking.

# Original README

## hatlog

a proof of concept of a type inference tool for Python written in Prolog. Idea described in [blog](http://code.alehander42.me/prolog_type_systems)

## how?

currently it works for simple one-function python files

```bash
bin/hatlog examples/map.py
# A,B::Callable[[A],B] -> List[A] -> List[B]
```

* hatlog flattens the python ast and annotates the types:  constants for literals and variables otherwise
* it generates a prolog program with the flattened ast: each node is represented as a prolog rule applied on its element types
* the program imports the specified type system, infers the types of the function based on it and saves it
* hatlog prints it

the type system is described as a simple file with prolog rules:

they describe the type rules for python nodes, e.g.

```prolog
z_cmp(A, A, bool)     :- comparable(A).

z_index([list, X], int, X).
z_index([dict, X, Y], X, Y).
z_index(str, int, str).

```

and some builtin methods, e.g.

```prolog
m([list, A], index, [A], int).
```

You can easily define your custom type systems just by tweaking those definitions.


## Author

[Alexander Ivanov](http://code.alehander42.me), 2016
