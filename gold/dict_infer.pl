:- initialization main.

:- use_module(pythonTypeSystem).
:- use_module(prettyTypes).

f(f, [Z0], X) :-
    z_method_call(Z0, keys, [], Z1),
    =(Z1, X).

main :-
    f(f, Z0, Z1),
    unvar(Z0, Z1, Z2, Z3, Z4), % replace free vars with names
    pretty_args(Z2, Y),
    pretty_type(Z3, Z),
    pretty_generic(Z4, X),
    format('~a::', [X]),
    write(Y),
    write(' -> '),
    write(Z),
    write('\n'),
    halt.

main :-
    writeln('No solution'),
    halt(1).
