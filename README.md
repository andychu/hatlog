# Fork of hatlog

This is a demo of type inference on a tiny subset of Python in Prolog.

The original blog post describing this work is **offline** as of November 2018,
but there is a [copy on archive.org][archived-post].

There are three Python functions that can be inferred:
`examples/{fib,join,map}.py`.  The prolog output is in
`gold/{fib,join,map}.pl`.

I combined all the Python code into a single file `gen_prolog.py`.  I also
changed it to use more of a Unix style driven by shell scripts.

Try this:

    # for each example, generate Prolog code and run it, printing the inferred type
    $ ./run.sh all

TODO:

- Why is there spurious text on `stdout` for `map.py`?  I got rid of one
  `writeln()` but I can't find the remaining "print".
- How to get rid of the remaining Prolog warnings?  I shut up one about
  discontiguous definitions, but I'm not sure if that is advisable.  (The
  original `bin/hatlog` Python script swallowed the `stderr` of `swipl`!)
- Can we get `examples/pathjoin.py` to work?  It uses `*p` which may not be supported.
- Can we infer more than one function at a time?  Imports, etc.?
- Can these programs be ported to a toy Python prolog engine?  It would be help
  me understand what Prolog is doing.
  - http://code.activestate.com/recipes/303057/
  - http://openbookproject.net/py4fun/prolog/intro.html

[archived-post]: https://web.archive.org/web/20170216030548/http://code.alehander42.me/prolog_type_systems


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
