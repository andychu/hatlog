#!/usr/bin/swipl -s

% Without this, it stars the REPL?
:- initialization main.


% What is this syntax?

f(X:(Y->Z)) :-
        X = 1,
        Y = 2,
        Z = 3,
        format('~a\n', X),
        format('~a\n', Y),
        format('~a\n', Z),
        halt.

main :-
  f(X:(Y->Z)).

main :-
  writeln('Failed'),
  halt(1).
