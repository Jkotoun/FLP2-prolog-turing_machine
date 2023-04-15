:- dynamic rule/4 as rule.

% :- functor(tsconfig(left, state, head, right), tsconfig, 4).


%used from example
split_line([],[[]]) :- !.
split_line([' '|T], [[]|S1]) :- !, split_line(T,S1).
split_line([32|T], [[]|S1]) :- !, split_line(T,S1).   
split_line([H|T], [[H|G]|S1]) :- split_line(T,[G|S1]).


codes_to_atoms([], []).
codes_to_atoms([Code|Codes], [Atom|Atoms]) :-
    atom_codes(Atom, [Code]),
    codes_to_atoms(Codes, Atoms).

read_input(tsconfig(Left, State, Head, Right)) :-
     read_line_to_codes(user_input, Line),
     (at_end_of_stream ->
        codes_to_atoms(Line, Atoms),
        Left = [],
        State = 'S',
        nth0(0, Atoms, Head),
        Right = Atoms
        ;
        split_line(Line, Parts),
        maplist(atom_codes, AtomParts, Parts),
        Rule =.. [rule | AtomParts],
        assertz(Rule),
        read_input(tsconfig(Left, State, Head, Right))
     ).
% [State, HeadSymbol, NewState, NewHeadSymbol]


step(tsconfig(Left, State, Head, Right), tsconfig(NextLeft, NextState, NextHead, NextRight)).

accepting(tsconfig(_, State, _, _)) :- State == 'F'.
accepting(TSConfig) :- step(TSConfig, NextTSConfig), accepting(NextTSConfig).




print_rules :- 
    rule(X, Y, Z, W),
    format("~w ~w ~w ~w", [X, Y, Z, W]),
    nl,
    fail.

start :-
    read_input(TSConfig),
    writeln(TSConfig),
    (accepting(TSConfig) -> writeln("True") ; writeln("False")),
    
    writeln("rules:"),
    
    print_rules -> true ; true,
    halt.