:- dynamic rule/4 as rule.

%used from example
split_line([],[[]]) :- !.
split_line([' '|T], [[]|S1]) :- !, split_line(T,S1).
split_line([32|T], [[]|S1]) :- !, split_line(T,S1).   
split_line([H|T], [[H|G]|S1]) :- split_line(T,[G|S1]).

%map list of codes to list of atoms
codes_to_atoms([], []).
codes_to_atoms([Code|Codes], [Atom|Atoms]) :-
    atom_codes(Atom, [Code]),
    codes_to_atoms(Codes, Atoms).

%read and parse lines of input to dynamic rule predicate and last line as initial TS config
read_input(tsconfig(Left, State, Head, Right)) :-
     read_line_to_codes(user_input, Line),
     (at_end_of_stream ->
        codes_to_atoms(Line, Atoms),
        Left = [],
        State = 'S',
        [Head | Right] = Atoms
        ;
        split_line(Line, Parts),
        maplist(atom_codes, AtomParts, Parts),
        Rule =.. [rule | AtomParts],
        assertz(Rule),
        read_input(tsconfig(Left, State, Head, Right))
     ).

%one step of NTM - takes tsconfig as input and ouputs new possible tsconfig by applying some of rules loaded from input
step(tsconfig(Left, State, Head, Right), tsconfig(NextLeft, NextState, NextHead, NextRight)) :- 
    rule(State, Head, NextState, Action),
    (
        Action == 'R' -> append(Left,[Head], NextLeft), [NextHead|NextRight] = Right;
        Action == 'L' -> append([Head],Right, NextRight), append(NextLeft, [NextHead], Left);
        NextLeft = Left, NextRight = Right, NextHead = Action
    ).

%print NTM configuration
print_config(tsconfig(Left, State, Head, Right)) :-
    (Left == [] -> LeftString = "" ; atomic_list_concat(Left, '', LeftString)),
    (Right == [] -> RightString = "" ; atomic_list_concat(Right, '', RightString)),
    write(LeftString),
    write(State),
    write(Head),
    write(RightString),
    nl.

%find accepting state by trying possible steps, outputs list of configurations from init to accepting state
accepting(tsconfig(_, State, _, _),  _) :- 
    State == 'F'.
accepting(TSConfig,  ResultSequence) :- 
    step(TSConfig, NextTSConfig), 
    accepting(NextTSConfig,  Tmp),
    append( [NextTSConfig],Tmp, ResultSequence). 

%start function - reads input, finds accepting state and prints configurations sequence to stdout
start :-
    read_input(InitTSConfig),
    accepting(InitTSConfig, ResultSequence),
    print_config(InitTSConfig),
    maplist(print_config, ResultSequence),
    halt.