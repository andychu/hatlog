#!/usr/bin/swipl -s

% Without this, it stars the REPL?
:- initialization main.


% What is this syntax?

f(X,Y,Z) :-
        X = 1,
        Y = 2,
        format('f ~a\n', X),
        format('f ~a\n', Y),
        format('f ~a\n', Z),
        halt.

main :-
  f( _, _, 3),
  % format('f ~a\n', X),
  write('done main\n').

main :-
  writeln('Failed'),
  halt(1).
