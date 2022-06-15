#defined wall/2.
#defined case/2.
#defined spike/2.
#defined wall/2.


init(hasKey(0)).
case(2,1).
case(3,1).
case(4,1).
case(2,2).
case(3,2).
case(4,2).
case(1,3).
case(2,3).
case(3,3).
case(4,3).
case(2,4).
case(3,4).
case(4,4).
case(5,4).
case(2,5).
case(4,5).
case(5,5).
case(6,5).
case(7,5).
case(2,6).
case(3,6).
case(4,6).
case(5,6).
case(6,6).
case(5,7).
case(6,7).
case(7,7).
case(5,8).
case(6,8).
wall(0,0).
wall(1,0).
wall(2,0).
wall(3,0).
wall(4,0).
wall(5,0).
wall(6,0).
wall(7,0).
wall(8,0).
wall(0,1).
wall(1,1).
wall(5,1).
wall(6,1).
wall(7,1).
wall(8,1).
wall(0,2).
wall(1,2).
wall(5,2).
wall(6,2).
wall(7,2).
wall(8,2).
wall(0,3).
wall(5,3).
wall(6,3).
wall(7,3).
wall(8,3).
wall(0,4).
wall(1,4).
wall(6,4).
wall(7,4).
wall(8,4).
wall(0,5).
wall(1,5).
wall(3,5).
wall(8,5).
wall(0,6).
wall(1,6).
wall(7,6).
wall(8,6).
wall(0,7).
wall(1,7).
wall(2,7).
wall(3,7).
wall(4,7).
wall(8,7).
wall(0,8).
wall(1,8).
wall(2,8).
wall(3,8).
wall(4,8).
wall(7,8).
wall(8,8).
wall(0,9).
wall(1,9).
wall(2,9).
wall(3,9).
wall(4,9).
wall(5,9).
wall(6,9).
wall(7,9).
wall(8,9).
goal(6,8).
init(at(3,1)).
init(block(2,2)).
init(block(3,2)).
init(block(4,2)).
init(block(4,5)).
init(block(5,5)).
init(block(4,6)).
init(block(6,7)).
init(key(4,3)).
init(lock(5,7)).
init(mob(2,5)).
init(mob(6,6)).
trap(pos(2,4),on,0).
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
    aie;
    mob;
    nop
    ).

direction(
    up;
    right;
    down;
    left
).


%%%%%%%%%%%%%%%%%%%%
%%%%%%% BUTS %%%%%%%
%%%%%%%%%%%%%%%%%%%%

achieved(T) :- 
    fluent(at(X,Y), T), 
    goal(X+1,Y).
achieved(T) :- 
    fluent(at(X,Y), T), 
    goal(X,Y+1).
achieved(T) :- 
    fluent(at(X,Y), T), 
    goal(X-1,Y).
achieved(T) :- 
    fluent(at(X,Y), T), 
    goal(X,Y-1).

:- not achieved(_). % on doit finir
:- achieved(T), T > h. % on doit finir avant l'horizon
:- achieved(T), do(Act, _, T), Act != nop. % la seule action possible une fois qu'on a fini : nop
:- do(nop, _, T), not achieved(T). % mais on ne peut faire nop qu'une fois qu'on a fini


fluent(F, 0) :- init(F).

%%% tous les buts doivent être atteints au pas hitmax
% :- goal(X,Y), not fluent(at(X,Y), h).

%%% générateur d'actions..
{ do(Act, To, T): action(Act), direction(To) } = 1 :- step(T).

% Trouver la direction
%% Calculer l'endroit où sera situé un objet relativement à une position en fonction d'une direction donnée en param
positionRelative(up,pos(X,Y),pos(X,Y-1)) :-
    case(X,Y),
    case(X,Y+1).

positionRelative(down,pos(X,Y),pos(X,Y+1)) :-
    case(X,Y),
    case(X,Y-1).

positionRelative(right,pos(X,Y),pos(X+1,Y)) :-
    case(X,Y),
    case(X+1,Y).

positionRelative(left,pos(X,Y),pos(X-1,Y)) :-
    case(X,Y),
    case(X-1,Y).

%murs
positionRelative(up,pos(X,Y),pos(X,Y-1)) :-
    case(X,Y),
    wall(X,Y+1).

positionRelative(down,pos(X,Y),pos(X,Y+1)) :-
    case(X,Y),
    wall(X,Y-1).

positionRelative(right,pos(X,Y),pos(X+1,Y)) :-
    case(X,Y),
    wall(X+1,Y).

positionRelative(left,pos(X,Y),pos(X-1,Y)) :-
    case(X,Y),
    wall(X-1,Y).

%%% les actions %%%

% ACTION : SE DEPLACER
% a) préconditions

%% Pas de murs où on veut aller
:-  do(move, D, T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T), 
    wall(X2, Y2).

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

%% Les pics ça pique
:- do(move,D,T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    spike(X2,Y2),
    fluent(at(X1,Y1),T),
    not do(aie, D, T+1).

%% Les safe ça pique
:- do(move,D,T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    trap(pos(X2,Y2),off,T),
    fluent(at(X1,Y1),T),
    not do(aie, _, T+1).

% b) effets
%% Update la position du perso (peu importe sur quoi il tombe)
fluent(at(X2, Y2), T + 1) :-
    do(move, D, T),
    positionRelative(D, pos(X1,Y1),pos(X2,Y2)),
    fluent(at(X1, Y1), T),
    not fluent(block(X2,Y2),T),
    not fluent(mob(X2,Y2),T),
    not fluent(lock(X2,Y2),T).

%% S'il se déplace sur un spike, aïe 
fluent(at(X2,Y2), T + 1) :-
    do(move, D, T),
    positionRelative(D, pos(X1,Y1),pos(X2,Y2)),
    spike(X2,Y2),
    fluent(at(X1, Y1), T),
    not fluent(block(X2,Y2),T),
    not fluent(mob(X2,Y2),T),
    not fluent(lock(X2,Y2),T).

%% S'il se déplace sur un unsafe, aïe 
fluent(at(X2,Y2), T + 1) :-
    do(move, D, T),
    positionRelative(D, pos(X1,Y1),pos(X2,Y2)),
    trap(pos(X2,Y2),off,T),
    fluent(at(X1, Y1), T),
    not fluent(block(X2,Y2),T),
    not fluent(mob(X2,Y2),T),
    not fluent(lock(X2,Y2),T).

% immobile devant la serrure si pas clé
fluent(at(X1, Y1), T + 1) :-
    do(move, D, T),
    positionRelative(D, pos(X1,Y1),pos(X2,Y2)),
    fluent(at(X1, Y1), T),
    case(X2, Y2),
    fluent(lock(X2, Y2), T),
    fluent(hasKey(0), T).

% S'il se déplace sur une serrure, si il a clé
fluent(at(X2, Y2), T + 1) :-
    do(move, D, T),
    positionRelative(D, pos(X1,Y1),pos(X2,Y2)),
    fluent(at(X1, Y1), T),
    case(X2, Y2),
    fluent(lock(X2, Y2), T),
    fluent(hasKey(1), T).

%% Donne l'attribut "removed" quand le perso a fait une action
removed(at(X, Y), T) :-
    do(move, _, T),
    fluent(at(X, Y), T).
 
%% Removed le lock
removed(lock(X2, Y2), T + 1) :-
    do(move, D, T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T),
    fluent(hasKey(1), T).

% CLES

%% S'il est sur une clé, la collecter

%fluent(hasKey(1), T) :-
%    do(move, D, T),
%    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
%    fluent(at(X1, Y1), T),
%    fluent(key(X2, Y2), T).
fluent(hasKey(1), T) :-
    fluent(key(X, Y), T),
    fluent(at(X, Y), T).

%% S'il est sur une clé la supprimer
removed(key(X, Y), T) :-
    fluent(at(X, Y), T).

% s'il est sur un lock enlever serrure
removed(hasKey(0), T) :-
    fluent(hasKey(1), T),
    fluent(at(X, Y), T),
    fluent(lock(X, Y), T).


% Pushs relatifs
%% Calculer l'endroit où sera poussé un objet relativement à une position en fonction d'une direction donnée en param
pushRelative(up,pos(X,Y),pos(X,Y-2)) :-
    case(X,Y),
    case(X,Y+2).

pushRelative(down,pos(X,Y),pos(X,Y+2)) :-
    case(X,Y),
    case(X,Y-2).

pushRelative(right,pos(X,Y),pos(X+2,Y)) :-
    case(X,Y),
    case(X+2,Y).

pushRelative(left,pos(X,Y),pos(X-2,Y)) :-
    case(X,Y),
    case(X-2,Y).

%% ACTION : POUSSER BLOCS
% a) préconditions

% check s'il y a bien un bloc où on veut pousser
:-  do(push, D, T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T), 
    not fluent(block(X2, Y2), T).

% si ya une case derriere on peut pousser
%:-  do(push, D, T),
%    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
%    fluent(at(X1, Y1), T), 
%    not case(X2, Y2).

% Si ya des pics derriere on peut pousser
%:-  do(push, D, T), 
%    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
%    fluent(at(X1, Y1), T), 
%    not fluent(spike(X2,Y2),T).

% Si ya une clé derriere on peut pousser
%:-  do(push, D, T), 
%    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
%    fluent(at(X1, Y1), T), 
%    not fluent(key(X2,Y2),T).

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

% check s'il n'y a pas de mob où on veut pousser
:-  do(push, D, T), 
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T),
    fluent(mob(X2, Y2), T).

%%%%%%% check s'il n'y a pas de mur où on veut pousser
:-  do(push, D, T), 
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T),
    wall(X2,Y2).    

% check s'il n'y a pas le goal où on peut pousser
:-  do(push, D, T), 
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T),
    goal(X2, Y2).

%% Les pics ça pique
:- do(push,D,T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    spike(X2,Y2),
    fluent(at(X1,Y1),T),
    not do(aie, D, T+1).

%% Les safe ça pique
:- do(push,D,T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    trap(pos(X2,Y2),off,T),
    fluent(at(X1,Y1),T),
    not do(aie, _, T+1).

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

%% ACTION : POUSSER mob
% a) préconditions

% Verifier qu'il y a bien un mob à pousser
:-  do(mob, D, T), 
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T), 
    not fluent(mob(X2,Y2), T).

% Si case derriere on peut pousser
%:-  do(mob, D, T),
%    pushRelative(D, pos(X1, Y1), pos(X2, Y2)),
%    fluent(at(X1, Y1), T), 
%    not case(X2, Y2).

% Si block derriere on peut pousser
%:-  do(mob, D, T),
%    pushRelative(D, pos(X1, Y1), pos(X2, Y2)),
%    fluent(at(X1, Y1), T), 
%    not fluent(block(X2, Y2), T).

% Si pic derriere on peut pousser
%:-  do(mob, D, T),
%    pushRelative(D, pos(X1, Y1), pos(X2, Y2)),
%    fluent(at(X1, Y1), T), 
%    not spike(X2, Y2).

% Si key derriere on peut pousser
%:-  do(mob, D, T),
%    pushRelative(D, pos(X1, Y1), pos(X2, Y2)),
%    fluent(at(X1, Y1), T), 
%    not fluent(key(X2, Y2), T).

% Si lock derriere = ??? MAIS c'est pas possible de le faire dans le jeu donc OSEF

% Si mob derriere on peut PAS pousser
:-  do(mob, D, T), 
    pushRelative(D, pos(X1,Y1), pos(X2, Y2)),
    fluent(at(X1, Y1), T),
    fluent(mob(X2, Y2), T).

% check s'il n'y a pas le goal où on peut pousser
:-  do(mob, D, T), 
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T),
    goal(X2, Y2).

%% Les pics ça pique
:- do(mob,D,T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    spike(X2,Y2),
    fluent(at(X1,Y1),T),
    not do(aie, D, T+1).

%% Les traps ça pique
:- do(mob,D,T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    trap(pos(X2,Y2),off,T),
    fluent(at(X1,Y1),T),
    not do(aie, _, T+1).

% b) effets
% Update la position du mob
fluent(mob(X2, Y2), T + 1) :- 
    do(mob, D, T),
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T).

% Le mob est marqué comme removed, s'il rentre en contact avec :
%%% Un bloc 
removed(mob(X2, Y2), T) :- 
    do(mob, D, T),
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(block(X2,Y2), T),
    fluent(at(X1, Y1), T).
%%% Un pic 
removed(mob(X2, Y2), T) :- 
    do(mob, D, T),
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    spike(X2,Y2),
    fluent(at(X1, Y1), T).
%%% Un mur : COMMENT FAIRE ?
removed(mob(X2, Y2), T) :- 
    do(mob, D, T),
    pushRelative(D, pos(X1,Y1), pos(X2,Y2)),
    wall(X2,Y2),
    fluent(at(X1, Y1), T).

% Si mob poussé, son ancienne position est notée removed
removed(mob(X2, Y2), T) :- 
    do(mob, D, T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(at(X1, Y1), T).


:-  do(aie, _, T),
    fluent(at(X, Y), T),
    not spike(X, Y),
    not trap(pos(X,Y),off, T).

:- do(aie, _,T),
    do(aie, _,T-1).

% effets
fluent(at(X, Y), T) :-
    do(aie, _, T + 1),
    spike(X, Y),
    fluent(at(X, Y), T).

fluent(at(X, Y), T) :-
    do(aie,_, T + 1),
    trap(pos(X,Y),on,T+1),
    fluent(at(X, Y), T).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Frame Problem %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% les fluents qui n'ont pas été supprimés restent à leur valeur
fluent(F, T + 1) :- 
    fluent(F, T), 
    T + 1 <= h,
    not removed(F, T),
    not fluent().

fluent(F, T + 1) :-
    fluent(F, T),
    achieved(T),
    T + 1 <= h.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Intervertir les safe et unsafe %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trap(pos(X,Y),off,T+1):-trap(pos(X,Y),on,T).
trap(pos(X,Y),on,T+1):-trap(pos(X,Y),off,T).

#show do/3.