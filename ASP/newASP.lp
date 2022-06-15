%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%        HELLTAKER IN ASP        %%%
%%%         version: 0.1           %%%
%%%    authors : HABERT Thomas     %%%
%%%              MASSINON Isabelle %%%
%%%              VALTY Eugène      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% clingo -c h=24 -n0 main.lp

#defined spike/2.
#defined step/1.

step(0..h-1).

init(has_key(0)).
state_trap(on; off).
fluent(F, 0) :- init(F).

%%%%%% ACTIONS %%%%%%
action(
  move;
  push;
  push_mob;
  aie;
  nop).

direction(
    up;
    right;
    down;
    left
).

%%%%%%%%%%%%%%%%%%%%
%%%%%%% BUTS %%%%%%%
%%%%%%%%%%%%%%%%%%%%

achieved(T) :- fluent(F, T), goal(F).

:- not achieved(_).
:- achieved(T), T > h.
:- achieved(T), do(Act, To, T), Act != nop.
:- do(nop, _, T), not achieved(T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

{do(Act, To, T): action(Act), direction(To)} = 1 :- step(T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% TROUVER DIRECTION %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculer l'endroit où sera situé un objet relativement à une position en fonction d'une direction donnée en param
positionRelative(up,pos(X,Y),pos(X-1,Y)) :-
    case(X,Y).

positionRelative(down,pos(X,Y),pos(X+1,Y)) :-
    case(X,Y).

positionRelative(right,pos(X,Y),pos(X,Y+1)) :-
    case(X,Y).

positionRelative(left,pos(X,Y),pos(X,Y-1)) :-
    case(X,Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% ACTIONS DEPLACEMENT %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% préconditions
:-  do(move, D, T),
    fluent(at(X1, Y1), T),
    not case(X2, Y2),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)).

:-  do(move, D, T),
    fluent(at(X1, Y1), T),
    fluent(rock(X2, Y2), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)).

:-  do(move, D, T),
    fluent(at(X1, Y1), T),
    fluent(mob(X2, Y2), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)).

:- do(move, D, T),
    fluent(at(X1, Y1), T),
    spike(X2, Y2),
    not do(aie, D, T + 1),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)).

:- do(move, D, T),
    fluent(at(X1, Y1), T),
    trap(X2, Y2, on, T),
    not do(aie, D, T + 1),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)).

% effets
fluent(at(X2, Y2), T + 1) :-
    do(move, D, T),
    fluent(at(X1, Y1), T),
    case(X2, Y2),
    not fluent(rock(X2, Y2), T),
    not fluent(mob(X2, Y2), T),
    not fluent(lock(X2, Y2), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)).

fluent(at(X2, Y2), T + 1) :-
    do(move, D, T),
    fluent(at(X1, Y1), T),
    case(X2, Y2),
    spike(X2, Y2),
    not fluent(rock(X2, Y2), T),
    not fluent(mob(X2, Y2), T),
    not fluent(lock(X2, Y2), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)).

fluent(at(X1, Y1), T + 1) :-
    do(move, D, T),
    fluent(at(X1, Y1), T),
    case(X2, Y2),
    fluent(lock(X2, Y2), T),
    fluent(has_key(0), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)).

fluent(at(X2, Y2), T + 1) :-
    do(move, D, T),
    fluent(at(X1, Y1), T),
    case(X2, Y2),
    fluent(lock(X2, Y2), T),
    fluent(has_key(1), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)).

removed(lock(X2, Y2), T + 1) :-
    do(move, D, T),
    fluent(at(X1, Y1), T),
    fluent(has_key(1), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)).

removed(at(X, Y), T) :-
    do(move, _, T),
    fluent(at(X, Y), T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% TROUVER DIRECTION PUSH %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculer l'endroit où sera situé un objet relativement à une position en fonction d'une direction donnée en param
pushRelative(up,pos(X,Y),pos(X-2,Y)) :-
    case(X,Y).

pushRelative(down,pos(X,Y),pos(X+2,Y)) :-
    case(X,Y).

pushRelative(right,pos(X,Y),pos(X,Y+2)) :-
    case(X,Y).

pushRelative(left,pos(X,Y),pos(X,Y+2)) :-
    case(X,Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% ACTIONS PUSH ROCKS %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% préconditions
:-  do(push, D, T),
    fluent(at(X1, Y1), T),
    not fluent(rock(X2, Y2), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)).

:-  do(push, D, T),
    fluent(at(X1, Y1), T),
    not case(X2, Y2),
    pushRelative(D,pos(X1,Y1),pos(X2,Y2)).

:-  do(push, _, T),
    fluent(at(X, Y), T),
    spike(X, Y),
    not do(aie, _, T + 1).

:-  do(push, _, T),
    fluent(at(X, Y), T),
    trap(X, Y, on, T),
    not do(aie, _, T + 1).

% effets
fluent(rock(X2, Y2), T + 1) :-
    do(push, D, T),
    fluent(at(X1, Y1), T),
    not demoness(X2, Y2),
    not fluent(rock(X2, Y2), T),
    not fluent(lock(X2, Y2), T),
    not fluent(mob(X2, Y2), T),
    pushRelative(D,pos(X1,Y1),pos(X2,Y2)).

fluent(rock(X2, Y2), T + 1) :-
    do(push, D, T),
    fluent(at(X1, Y1), T),
    demoness(X2, Y2),
    pushRelative(D,pos(X1,Y1),pos(X2,Y2)).

fluent(rock(X1, Y1), T + 1) :-
    do(push, D, T),
    fluent(at(X1, Y1), T),
    fluent(rock(X3, Y3), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)),
    pushRelative(D,pos(X1,Y1),pos(X3,Y3)).

fluent(rock(X2, Y2), T + 1) :-
    do(push, D, T),
    fluent(at(X1, Y1), T),
    fluent(lock(X3, Y3), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)),
    pushRelative(D,pos(X1,Y1),pos(X3,Y3)).

fluent(rock(X2, Y2), T + 1) :-
    do(push, D, T),
    fluent(at(X1, Y1), T),
    fluent(mob(X3, Y3), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)),
    pushRelative(D,pos(X1,Y1),pos(X3,Y3)).

removed(rock(X2, Y2), T) :-
    do(push, D_left, T),
    fluent(at(X1, Y1), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% ACTIONS PUSH MOBS %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% préconditions
:-  do(push_mob, D, T),
    fluent(at(X1, Y1), T),
    not fluent(mob(X2, Y2), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)).

:-  do(push_mob, D, T),
    fluent(at(X1, Y1), T),
    fluent(mob(X3, Y3), T),
    pushRelative(D,pos(X1,Y1),pos(X3,Y3)).

:- do(push_mob, _, T),
    fluent(at(X, Y), T),
    spike(X, Y),
    not do(aie, _, T + 1).

:- do(push_mob, _, T),
    fluent(at(X, Y), T),
    trap(X, Y, off, T),
    not do(aie, _, T + 1).

% effets
fluent(mob(X3, Y3), T + 1) :-
    do(push_mob, D, T),
    case(X3, Y3),
    fluent(at(X1, Y1), T),
    not fluent(rock(X3, Y3), T),
    not fluent(lock(X3, Y3), T),
    pushRelative(D,pos(X1,Y1),pos(X3,Y3)).

removed(mob(X2, Y2), T) :-
    do(push_mob, D, T),
    fluent(at(X1, Y1), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)).

removed(mob(X3, Y3), T) :-
    fluent(rock(X3, Y3), T),
    do(push_mob, D, T),
    fluent(at(X1, Y1), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)),
    pushRelative(D,pos(X1,Y1),pos(X3,Y3)).

removed(mob(X3, Y3), T) :-
    spike(X3, Y3),
    do(push_mob, D, T),
    fluent(at(X1, Y1), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)),
    pushRelative(D,pos(X1,Y1),pos(X3,Y3)).

removed(mob(X3, Y3), T) :-
    not case(X3, Y3),
    do(push_mob, D, T),
    fluent(at(X1, Y1), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)),
    pushRelative(D,pos(X1,Y1),pos(X3,Y3)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% SPIKE SPECIFICS %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% ON SPIKE %%%%%%
% préconditions
:-  do(aie, _, T),
    fluent(at(X, Y), T),
    not spike(X, Y),
    not trap(X, Y, off, T).

% effets
fluent(at(X, Y), T) :-
    do(aie, _, T + 1),
    spike(X, Y),
    fluent(at(X, Y), T).

fluent(at(X, Y), T) :-
    do(aie, _, T + 1),
    trap(X, Y, on, T + 1),
    fluent(at(X, Y), T).

%%%%%% SWITCH TRAPS %%%%%%

:- trap(X, Y, S1, T), trap(X, Y, S2, T + 1), S1 = S2.

removed(mob(X, Y), T) :-
    trap(X, Y, on, T),
    fluent(mob(X, Y), T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% KEY AND lock %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fluent(has_key(1), T) :-
    do(move, D, T),
    fluent(at(X1, Y1), T),
    fluent(key(X2, Y2), T),
    positionRelative(D,pos(X1,Y1),pos(X2,Y2)).

removed(key(X, Y), T) :-
    fluent(at(X, Y), T).

removed(has_key(0), T) :-
    fluent(has_key(1), T),
    fluent(at(X, Y), T),
    fluent(key(X, Y), T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% FRAME PROBLEM %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fluent(F, T + 1) :-
    fluent(F, T),
    T + 1 < h,
    not removed(F, T).

fluent(F, T + 1) :-
    fluent(F, T),
    achieved(T),
    T + 1 <= h.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#show do/3.