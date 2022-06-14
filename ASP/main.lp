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


%%% les actions
%%  action left
% préconditions
:-  do(left, T), 
    fluent(at(X, Y), T), 
    fluent(block(X, Y - 1), T).

:-  do(left, T), 
    fluent(at(X, Y), T), 
    fluent(mob(X, Y - 1), T).

:-  do(left, T), 
    fluent(at(X, Y), T), 
    not case(X, Y -1), not fluent(lock(X,Y-1),T). 

% effets
fluent(at(X, Y - 1), T + 1) :-
    do(left, T),
    fluent(at(X, Y), T).

removed(at(X, Y), T) :-
    do(left, T),
    fluent(at(X, Y), T).

%% action right
% préconditions
:-  do(right, T), 
    fluent(at(X, Y), T),
    not case(X, Y + 1).

:-  do(right, T), 
    fluent(at(X, Y), T), 
    fluent(block(X, Y + 1), T).

:-  do(right, T), 
    fluent(at(X, Y), T), 
    fluent(mob(X, Y + 1), T).

% effets
fluent(at(X, Y + 1), T + 1) :- 
    do(right, T), 
    fluent(at(X, Y), T).

removed(at(X, Y), T) :- 
    do(right, T), 
    fluent(at(X, Y), T).

%% action up
% préconditions
:-  do(up, T), 
    fluent(at(X, Y), T),
    not case(X + 1, Y).

:-  do(up, T), 
    fluent(at(X, Y), T), 
    fluent(block(X + 1, Y), T).

:-  do(up, T), 
    fluent(at(X, Y), T), 
    fluent(mob(X + 1, Y), T).

% effets
fluent(at(X + 1, Y), T + 1) :- 
    do(up, T), 
    fluent(at(X, Y), T).

removed(at(X, Y), T) :- 
    do(up, T), 
    fluent(at(X, Y), T).

%% action down
% préconditions
:-  do(down, T), 
    fluent(at(X, Y), T),
    not case(X - 1, Y).

:-  do(down, T), 
    fluent(at(X, Y), T), 
    fluent(block(X - 1, Y), T).

:-  do(down, T), 
    fluent(at(X, Y), T), 
    fluent(mob(X - 1, Y), T).

% effets
fluent(at(X - 1, Y), T + 1) :- 
    do(down, T), 
    fluent(at(X, Y), T).

removed(at(X, Y), T) :- 
    do(down, T), 
    fluent(at(X, Y), T).    

%% action push_right
% préconditions
:-  do(push_right, T), 
    fluent(at(X, Y), T), 
    not fluent(block(X, Y + 1), T).

:-  do(push_right, T), 
    fluent(at(X, Y), T), 
    not case(X, Y + 2), not fluent(spike(X,Y+2),T).

:-  do(push_right, T), 
    fluent(at(X, Y), T),
    fluent(block(X, Y + 2), T).

% effets
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

%% action push_left
% préconditions
:-  do(push_left, T), 
    fluent(at(X, Y), T), 
    not fluent(block(X, Y - 1), T).

:-  do(push_left, T), 
    fluent(at(X, Y), T), 
    not case(X, Y - 2).

:-  do(push_left, T), 
    fluent(at(X, Y), T),
    fluent(block(X, Y - 2), T).

% effets
fluent(at(X, Y - 1), T + 1) :- 
    do(push_left, T),
    fluent(at(X, Y), T).

fluent(block(X, Y - 2), T + 1) :- 
    do(push_left, T),
    fluent(at(X, Y), T).

removed(block(X, Y - 1), T) :- 
    do(push_left, T),
    fluent(at(X, Y), T).

removed(at(X, Y), T) :- 
    do(push_left, T),
    fluent(at(X, Y), T).

%% action push_up
% préconditions
:-  do(push_up, T), 
    fluent(at(X, Y), T), 
    not fluent(block(X+1,Y), T).

:-  do(push_up, T), 
    fluent(at(X, Y), T), 
    not case(X+2, Y).

:-  do(push_up, T), 
    fluent(at(X, Y), T),
    fluent(block(X+2, Y), T).

% effets
fluent(at(X+1, Y), T + 1) :- 
    do(push_up, T),
    fluent(at(X, Y), T).

fluent(block(X+2, Y), T + 1) :- 
    do(push_up, T),
    fluent(at(X, Y), T).

removed(block(X+1, Y), T) :- 
    do(push_up, T),
    fluent(at(X, Y), T).

removed(at(X, Y), T) :- 
    do(push_up, T),
    fluent(at(X, Y), T).

%% action push_down
% préconditions
:-  do(push_down, T), 
    fluent(at(X, Y), T), 
    not fluent(block(X-1,Y), T).

:-  do(push_down, T), 
    fluent(at(X, Y), T), 
    not case(X-2, Y).

:-  do(push_down, T), 
    fluent(at(X, Y), T),
    fluent(block(X-2, Y), T).

% effets
fluent(at(X-1, Y), T + 1) :- 
    do(push_down, T),
    fluent(at(X, Y), T).

fluent(block(X-2, Y), T + 1) :- 
    do(push_down, T),
    fluent(at(X, Y), T).

removed(block(X-1, Y), T) :- 
    do(push_down, T),
    fluent(at(X, Y), T).

removed(at(X, Y), T) :- 
    do(push_down, T),
    fluent(at(X, Y), T).

%% action monster_right
% préconditions
:-  do(monster_right, T), 
    fluent(at(X, Y), T), 
    not fluent(mob(X,Y+1), T).

:-  do(monster_right, T), 
    fluent(at(X, Y), T), 
    not case(X, Y+2).

:-  do(monster_right, T), 
    fluent(at(X, Y), T),
    fluent(mob(X, Y+2), T).

% effets
fluent(at(X, Y+1), T + 1) :- 
    do(monster_right, T),
    fluent(at(X, Y), T).

fluent(mob(X, Y+2), T + 1) :- 
    do(monster_right, T),
    fluent(at(X, Y), T).

removed(mob(X, Y+2), T) :- 
    do(monster_right, T),
    fluent(at(X, Y), T).

removed(at(X, Y), T) :- 
    do(monster_right, T),
    fluent(at(X, Y), T).

%% action monster_left
% préconditions
:-  do(monster_left, T), 
    fluent(at(X, Y), T), 
    not fluent(mob(X,Y-1), T).

:-  do(monster_left, T), 
    fluent(at(X, Y), T), 
    not case(X, Y-2).

:-  do(monster_left, T), 
    fluent(at(X, Y), T),
    fluent(mob(X, Y-2), T).

% effets
fluent(at(X, Y-1), T + 1) :- 
    do(monster_left, T),
    fluent(at(X, Y), T).

fluent(mob(X, Y-2), T + 1) :- 
    do(monster_left, T),
    fluent(at(X, Y), T).

removed(mob(X, Y-2), T) :- 
    do(monster_left, T),
    fluent(at(X, Y), T).

removed(at(X, Y), T) :- 
    do(monster_left, T),
    fluent(at(X, Y), T).


%%% Frame Problem
% les fluents qui n'ont pas été supprimés restent à leur valeur
fluent(F, T + 1) :- 
    fluent(F, T), 
    T + 1 <= h,
    not removed(F, T).

#show do/2.