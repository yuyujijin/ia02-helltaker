%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%        HELLTAKER IN ASP        %%%
%%%         version: 0.1           %%%
%%%    authors : HABERT Thomas     %%%
%%%              MASSINON Isabelle %%%
%%%              VALTY Eugène      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% clingo -c h=24 -n0 main.lp

%%level 1

step(0..h-1).


%les actions
action( 
    right;
    left;
    up;
    down;
    push_right;
    push_left;
    push_down;
    push_up;
    monster_right;
    monster_left;
    monster_down;
    monster_up
    ).

%%% l'init


case(0,0).
case(0,1).
case(0,2).
case(0,3).
case(0,4).
case(0,8).
case(1,0).
case(1,1).
case(1,5).
case(1,8).
case(2,0).
case(2,2).
case(2,3).
case(2,5).
case(2,6).
case(2,8).
case(3,0).
case(3,2).
case(3,4).
case(3,7).
case(3,8).
case(4,1).
case(4,2).
case(4,7).
case(4,8).
case(5,1).
case(5,3).
case(5,4).
case(5,6).
case(5,8).
case(6,1).
case(6,3).
case(6,5).
case(6,6).
goal(player(6,7)).
init(player(1,6)).
init(block(5,2)).
init(block(5,5)).
init(block(6,2)).
init(block(6,4)).
init(mob(2,4)).
init(mob(3,3)).
init(mob(3,5)).



fluent(F, 0) :- init(F).

%%% tous les buts doivent être atteints au pas hitmax
:- goal(F), not fluent(F, h).

%%% générateur d'actions..
{ do(Act, T): action(Act) } = 1 :- step(T).

% Trouver la direction
%% Calculer l'endroit où sera situé un objet relativement à une position en fonction d'une direction donnée en param
positionRelative(up,pos(X,Y1),pos(X,Y2)) :-
    case(X,Y1),
    case(X,Y2),
    Y2 is Y1 + 1.

positionRelative(down,pos(X,Y1),pos(X,Y2)) :-
    case(X,Y1),
    case(X,Y2),
    Y2 is Y1 - 1.

positionRelative(right,pos(X1,Y),pos(X2,Y)) :-
    case(X1,Y),
    case(X2,Y),
    X2 is X1 + 1.

positionRelative(left,pos(X1,Y),pos(X2,Y)) :-
    case(X1,Y),
    case(X2,Y),
    X2 is X1 - 1.

%%% les actions %%%

% ACTION : SE DEPLACER
% a) préconditions

%% Pas de blocs où on veut aller
:-  do(D, T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T), 
    fluent(block(X2, Y2), T).

%% Pas de mob où on veut aller
:-  do(D, T), 
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T), 
    fluent(mob(X2, Y2), T).

    %% Pas de lock où on veut aller
:-  do(D, T), 
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T), 
    fluent(lock(X2, Y2), T).

    %% Case où on veut aller
:-  do(D, T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T), 
    not case(X2, Y2).

% b) effets
%% Update la position du perso
fluent(at(X2, Y2), T + 1) :-
    do(D, T),
    positionRelative(D, pos(X1,Y1),pos(X2,Y2)),    
    fluent(at(X1, Y1), T).

%% Donne l'attribut "removed" quand le perso a fait une action
removed(at(X, Y), T) :-
    do(_, T),
    fluent(at(X, Y), T).
 
% Pushs relatifs
%% Calculer l'endroit où sera poussé un objet relativement à une position en fonction d'une direction donnée en param
pushRelative(up,pos(X,Y1),pos(X,Y2)) :-
    case(X,Y1),
    case(X,Y2),
    Y2 is Y1 + 2.

pushRelative(down,pos(X,Y1),pos(X,Y2)) :-
    case(X,Y1),
    case(X,Y2),
    Y2 is Y1 - 2.

pushRelative(right,pos(X1,Y),pos(X2,Y)) :-
    case(X1,Y),
    case(X2,Y),
    X2 is X1 + 2.

pushRelative(left,pos(X1,Y),pos(X2,Y)) :-
    case(X1,Y),
    case(X2,Y),
    X2 is X1 - 2.

%% ACTION : POUSSER BLOCS
% a) préconditions

% check s'il y a bien un bloc où on veut pousser
:-  do(D, T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T), 
    not fluent(block(X2, Y2), T).

% check s'il ya bien une case où on veut pousser
:-  do(push_right, T), 
    fluent(at(X, Y), T), 
    not case(X, Y + 2).

:-  do(push_right, T), 
    fluent(at(X, Y), T), 
    not fluent(spike(X,Y+2),T).

% check qu'il n'y a pas de bloc où on veut pousser
:-  do(push_right, T), 
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T),
    fluent(block(X2, Y2), T).

% check qu'il n'y a pas de lock où on veut pousser
:-  do(push_right, T), 
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T),
    fluent(lock(X2, Y2), T).

% check s'il n'y a pas de monstre où on veut pousser
:-  do(push_right, T), 
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T),
    fluent(lock(X2, Y2), T).

% b) effets
fluent(at(X, Y + 1), T + 1) :- 
    do(push_right, T),
    fluent(at(X, Y), T).

fluent(block(X, Y + 2), T + 1) :- 
    do(push_right, T),
    fluent(at(X, Y), T).

removed(block(X, Y + 1), T) :- 
    do(push_right, T),
    fluent(at(X, Y), T).

removed(at(X, Y), T) :- 
    do(push_right, T),
    fluent(at(X, Y), T).


%% ACTION : POUSSER MONSTRE
% a) préconditions
:-  do(monster_right, T), 
    fluent(at(X, Y), T), 
    not fluent(mob(X,Y+1), T).

:-  do(monster_right, T), 
    fluent(at(X, Y), T), 
    not case(X, Y+2).

:-  do(monster_right, T), 
    fluent(at(X, Y), T),
    fluent(mob(X, Y+2), T).

% b) effets
fluent(at(X, Y+1), T + 1) :- 
    do(monster_right, T),
    fluent(at(X, Y), T).

fluent(mob(X, Y+2), T + 1) :- 
    do(monster_right, T),
    fluent(at(X, Y), T).

removed(mob(X, Y+1), T) :- 
    do(monster_right, T),
    fluent(at(X, Y), T).

removed(at(X, Y), T) :- 
    do(monster_right, T),
    fluent(at(X, Y), T).

removed(mob(X, Y+2), T) :- 
    do(monster_right, T),
    case(X,Y+2),
    fluent(at(X, Y), T).

%%% Frame Problem
% les fluents qui n'ont pas été supprimés restent à leur valeur
fluent(F, T + 1) :- 
    fluent(F, T), 
    T + 1 <= h,
    not removed(F, T).

#show do/2.