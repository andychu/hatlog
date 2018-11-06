:- initialization main.

:- use_module(pythonTypeSystem).
:- use_module(prettyTypes).

f(last, [Z0], X) :-
    z_assign(Z3, Z2, Z4),
    z_for(Z2, Z1, [Z4], Z5),
    z_for(Z1, Z0, [Z5], Z6),
    =(Z3, X).

main :-
    f(last, Z0, Z1),
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
