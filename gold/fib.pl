:- initialization main.

:- use_module(pythonTypeSystem).
:- use_module(prettyTypes).

f(fib, [Z0], X) :-
    z_cmp(Z0, int, Z1),
    =(int, X),
    z_bin_op(Z0, int, Z2),
    =(Z2, Z0),
    z_bin_op(Z0, int, Z3),
    =(Z3, Z0),
    z_bin_op(X, X, Z4),
    =(Z4, X),
    z_if(Z1, [int], [Z4], Z5).


main :-
    f(fib, ArgTypes, ReturnType),

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

