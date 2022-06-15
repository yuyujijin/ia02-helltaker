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
    fluent(safe(X2,Y2), T),
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
    fluent(safe(X2,Y2), T),
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
    fluent(safe(X2,Y2), T),
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

%% Les safe ça pique
:- do(mob,D,T),
    positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
    fluent(safe(X2,Y2), T),
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
    not fluent(trap(pos(X,Y),off), T).

:- do(aie, _,T),
    do(aie, _,T-1).

% effets
fluent(at(X, Y), T) :-
    do(aie, _, T + 1),
    spike(X, Y),
    fluent(at(X, Y), T).

fluent(at(X, Y), T) :-
    do(aie,_, T + 1),
    fluent(unsafe(X, Y),T + 1),
    fluent(at(X, Y), T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Intervertir les safe et unsafe %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Safe
fluent(safe(X,Y),T+1) :-
    do(_,_,T), 
    fluent(unsafe(X,Y),T).

removed(unsafe(X,Y),T) :-
    do(_,_,T), 
    fluent(unsafe(X,Y),T).

%% Unsafe
fluent(unsafe(X,Y),T+1) :-
    do(_,_,T), 
    fluent(unsafe(X,Y),T).

removed(safe(X,Y),T) :-
    do(_,_,T), 
    fluent(safe(X,Y),T).

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


#show do/3.