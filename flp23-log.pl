:- dynamic rule/4 as rule.

:- functor(tsconfig(left, state, head, right), tsconfig, 4).


%used from example
split_line([],[[]]) :- !.
split_line([' '|T], [[]|S1]) :- !, split_line(T,S1).
split_line([32|T], [[]|S1]) :- !, split_line(T,S1).   
split_line([H|T], [[H|G]|S1]) :- split_line(T,[G|S1]).

atom_codes_list_to_atoms_list([], []).
atom_codes_list_to_atoms_list([H|T], [AtomH|AtomT]) :-
    atom_codes(AtomH, H),
    atom_codes_list_to_atoms_list(T, AtomT).



read_input(TSConfig) :-
     read_line_to_codes(user_input, Line),
     (at_end_of_stream ->
        split_line(Line, Parts),
        maplist(atom_codes, AtomParts, Parts),
        Left = [],
        State = 'S',
        nth0(0, AtomParts, Head),
        Right = AtomParts,
        TSConfig = tsconfig(Left, State, Head, Right)
        ;
        split_line(Line, Parts),
        maplist(atom_codes, AtomParts, Parts),
        Rule =.. [rule | AtomParts],
        assertz(Rule),
        read_input(TSConfig)
     ).
% [State, HeadSymbol, NewState, NewHeadSymbol]

print_rules :- 
    rule(X, Y, Z, W),
    format("~w ~w ~w ~w", [X, Y, Z, W]),
    nl,

    fail.

start :-
    read_input(TSConfig),
    writeln("config:"),
    writeln(TSConfig),
    writeln("rules:"),
    
    print_rules -> true ; true,
    halt.