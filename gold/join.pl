:- initialization main.

:- use_module(pythonTypeSystem).
:- use_module(prettyTypes).

f(join, [Z0, Z1], X) :-
    z_assign(Z2, str, Z3),
    z_unary_op(int, Z6),
    z_slice(Z0, Z6, Z6, Z5),
    z_bin_op(Z4, Z1, Z7),
    z_aug_assign(Z2, Z7, Z8),
    z_for(Z4, Z5, [Z8], Z9),
    z_unary_op(int, Z11),
    z_index(Z0, Z11, Z10),
    z_aug_assign(Z2, Z10, Z12),
    =(Z2, X).


main :-
    f(join, ArgTypes, ReturnType),

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

