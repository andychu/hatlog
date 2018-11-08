:- initialization main.

:- use_module(pythonTypeSystem).
:- use_module(prettyTypes).

f(last, [Z0], X) :-
    z_assign(Z3, Z2, Z4),
    z_for(Z2, Z1, [Z4], Z5),
    z_for(Z1, Z0, [Z5], Z6),
    =(Z3, X).


main :-
    f(last, ArgTypes, ReturnType),

    % ~k gives the argument to write_canonical.  ~s for string output.
    format('ArgTypes = ~k\n', [ArgTypes]),
    format('ReturnType = ~k\n', [ReturnType]),

    % replace free vars with names.  This changes things for 'map'.
    unvar(ArgTypes, ReturnType, NArgTypes, NReturnType, GenericId), 

    format('NArgTypes = ~k\n', [NArgTypes]),
    format('NReturnType = ~k\n', [NReturnType]),

    format('GenericId = ~k\n', [GenericId]),

    pretty_args(NArgTypes, B),
    pretty_type(NReturnType, C),
    pretty_generic(GenericId, A),

    write('\n'),
    write('\ttype inferred:\n'),
    format('\t~a::~s -> ~s\n', [A, B, C]),
    halt.

main :-
    writeln('No solution'),
    halt(1).

