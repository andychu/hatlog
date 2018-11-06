:- initialization main.

:- use_module(pythonTypeSystem).
:- use_module(prettyTypes).

f(map, [Z0, Z1], X) :-
    z_list(Z3, Z4),
    z_assign(Z2, Z4, Z5),
    z_fcall(Z0, [Z6], Z7),
    z_method_call(Z2, append, [Z7], Z8),
    z_for(Z6, Z1, [Z8], Z9),
    =(Z2, X).

main :-
    f(map, Z0, Z1),
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
