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
    move;
    push;
    monster
    ).

direction(
    up;
    right;
    down;
    left
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
{ do(Act, To, T): action(Act), direction(To) } = 1 :- step(T).

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
:-  do(move, D, T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T), 
    fluent(block(X2, Y2), T).

%% Pas de mob où on veut aller
:-  do(move, D, T), 
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T), 
    fluent(mob(X2, Y2), T).

%% Pas de serrure où on veut aller, si on a pas de clé
:-  do(move, D, T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T), 
    fluent(hasKey(0),T),
    fluent(lock(X2,Y2),T). 

% b) effets
%% Update la position du perso (peu importe sur quoi il tombe)
fluent(at(X2, Y2), T + 1) :-
    do(move, D, T),
    positionRelative(D, pos(X1,Y1),pos(X2,Y2)),
    fluent(at(X1, Y1), T).

%% S'il se déplace sur une serrure avec une clé
fluent(at(X2, Y2), T + 1) :-
    do(move, D, T),
    positionRelative(D, pos(X1,Y1),pos(X2,Y2)),
    fluent(hasKey(1), T),    
    fluent(lock(X2,Y2),T),
    fluent(at(X1, Y1), T).

%% S'il se déplace sur une clé, la collecter
fluent(hasKey(1), T+1) :-
    do(move, D, T),
    positionRelative(D, pos(X1,Y1),pos(X2,Y2)),
    fluent(key(X2,Y2), T),
    fluent(at(X1, Y1), T).

%% S'il se déplace sur un spike, aïe 
fluent(at(X2,Y2), T+2) :-
    do(move, D, T),
    
    positionRelative(D, pos(X1,Y1),pos(X2,Y2)),
    fluent(at(X1, Y1), T).

%% S'il se déplace sur une clé la supprimer
removed(key(X,Y), T) :-
    fluent(hasKey(0), T),
    fluent(hasKey(1), T+1),
    fluent(at(X,Y),T).

%% Donne l'attribut "removed" quand le perso a fait une action
removed(at(X, Y), T) :-
    do(move, _, T),
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
:-  do(push, D, T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T), 
    not fluent(block(X2, Y2), T).

% si ya une case derriere on peut pousser
:-  do(push, D, T),
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T), 
    not case(X2, Y2).

% Si ya des pics derriere on peut pousser
:-  do(push, D, T), 
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T), 
    not fluent(spike(X2,Y2),T).

% Si ya une clé derriere on peut pousser
:-  do(push, D, T), 
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T), 
    not fluent(key(X2,Y2),T).

% check qu'il n'y a pas de bloc où on veut pousser
:-  do(push, D, T), 
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T),
    fluent(block(X2, Y2), T).

% check qu'il n'y a pas de lock où on veut pousser
:-  do(push, D, T), 
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T),
    fluent(lock(X2, Y2), T).

% check s'il n'y a pas de monstre où on veut pousser
:-  do(push, D, T), 
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T),
    fluent(mob(X2, Y2), T).

% check s'il n'y a pas le goal où on peut pousser
:-  do(push, D, T), 
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T),
    fluent(goal(X2, Y2), T).

% b) effets
% Update la position du bloc
fluent(block(X2, Y2), T + 1) :- 
    do(push, D, T),
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T).

% Si block poussé, son ancienne position est notée removed
removed(block(X2, Y2), T) :- 
    do(push, D, T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T).

%% ACTION : POUSSER MONSTRE
% a) préconditions

% Verifier qu'il y a bien un monstre à pousser
:-  do(monster, D, T), 
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T), 
    not fluent(mob(X2,Y2), T).

% Si case derriere on peut pousser
:-  do(monster, D, T),
    pushRelative(D, pos(X1, Y1), pos(X2, Y2)),
    fluent(at(X1, Y1), T), 
    not case(X2, Y2).

% Si block derriere on peut pousser
:-  do(monster, D, T),
    pushRelative(D, pos(X1, Y1), pos(X2, Y2)),
    fluent(at(X1, Y1), T), 
    not block(X2, Y2).

% Si pic derriere on peut pousser
:-  do(monster, D, T),
    pushRelative(D, pos(X1, Y1), pos(X2, Y2)),
    fluent(at(X1, Y1), T), 
    not spikes(X2, Y2).

% Si key derriere on peut pousser
:-  do(monster, D, T),
    pushRelative(D, pos(X1, Y1), pos(X2, Y2)),
    fluent(at(X1, Y1), T), 
    not key(X2, Y2).

% Si lock derriere = ??? MAIS c'est pas possible de le faire dans le jeu donc OSEF

% Si mob derriere on peut PAS pousser
:-  do(monster, D, T), 
    pushRelative(D, pos(X1,Y1), pos(X2, Y2)),
    fluent(at(X1, Y1), T),
    fluent(mob(X2, Y2), T).

% b) effets
% Update la position du monstre
fluent(mob(X2, Y2), T + 1) :- 
    do(monster, D, T),
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T).

% Le monstre est marqué comme removed, s'il rentre en contact avec :
%%% Un bloc 
removed(mob(X2, Y2), T) :- 
    do(monster, D, T),
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    block(pos(X2,Y2)),
    fluent(at(X1, Y1), T).
%%% Un pic 
removed(mob(X2, Y2), T) :- 
    do(monster, D, T),
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    spike(pos(X2,Y2)),
    fluent(at(X1, Y1), T).
%%% Un mur : COMMENT FAIRE ?


% Si block poussé, son ancienne position est notée removed
removed(mob(X2, Y2), T) :- 
    do(monster, D, T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Clés et déverouillage %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Intervertir les safe et unsafe %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Safe
fluent(safe(U),T+1) :-
    do(_,_,T), %pour dire "si une action (peu importe laquelle) est faite au tour T" ==> jsp si utile
    fluent(unsafe(U),T).

%% Unsafe
fluent(unsafe(S),T+1) :-
    do(_,_,T), %pour dire "si une action (peu importe laquelle) est faite au tour T" ==> jsp si utile
    fluent(safe(S),T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Frame Problem %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% les fluents qui n'ont pas été supprimés restent à leur valeur
fluent(F, T + 1) :- 
    fluent(F, T), 
    T + 1 <= h,
    not removed(F, T).

fluent(F, T + 1) :-
    fluent(F, T),
    achieved(T),
    T + 1 <= maxstep.


#show do/3.