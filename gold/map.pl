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
    f(map, ArgTypes, ReturnType),

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

