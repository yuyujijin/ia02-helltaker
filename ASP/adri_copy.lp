    cell(7,1).
    cell(7,2).
    init(at(7,2)).
    cell(7,3).
    cell(6,1).
    init(box(6,1)).
    cell(6,2).
    init(box(6,2)).
    cell(6,3).
    init(box(6,3)).
    cell(5,0).
    cell(5,1).
    cell(5,2).
    cell(5,3).
    init(key(5,3)).
    cell(4,1).
    {trap(4, 1, S, T) : state_trap(S)} = 1 :- step(T). 
    :- trap(4, 1, S, 0), S != on.
    cell(4,2).
    init(box(4,2)).
    {trap(4, 2, S, T) : state_trap(S)} = 1 :- step(T). :- trap(4, 2, S, 0), S != on.
    cell(4,3).
    cell(4,4).
    cell(3,1).
    init(monster(3,1)).
    cell(3,3).
    init(box(3,3)).
    cell(3,4).
    init(box(3,4)).
    cell(3,5).
    cell(3,6).
    cell(2,1).
    cell(2,2).
    cell(2,3).
    init(box(2,3)).
    cell(2,4).
    cell(2,5).
    init(monster(2,5)).
    cell(1,4).
    init(chest(1,4)).
    cell(1,5).
    init(box(1,5)).
    cell(1,6).
    cell(0,4).
    cell(0,5).
    demoness(0,5).
    goal(at(-1,5)).
    goal(at(0,4)).
    goal(at(1,5)).
    goal(at(0,6)).
    step(0..maxstep-1).

    #defined spikes/2.
    #defined step/1.

    init(has_key(0)).
    state_trap(on; off).
    fluent(F, 0) :- init(F).

    %%%%%% ACTIONS %%%%%%
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
      monster_up;
      on_spike;
      nop).

    %%%%%%%%%%%%%%%%%%%%
    %%%%%%% BUTS %%%%%%%
    %%%%%%%%%%%%%%%%%%%%

    achieved(T) :- fluent(F, T), goal(F).

    :- not achieved(_).
    :- achieved(T), T > maxstep.
    :- achieved(T), do(Act, T), Act != nop.
    :- do(nop, T), not achieved(T).

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% ACTIONS DEPLACEMENT %%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    positionRelative(up,pos(X,Y),pos(X,Y-1)) :-
        cell(X,Y),
        cell(X,Y+1).

    positionRelative(down,pos(X,Y),pos(X,Y+1)) :-
        cell(X,Y),
        cell(X,Y-1).

    positionRelative(right,pos(X,Y),pos(X+1,Y)) :-
        cell(X,Y),
        cell(X+1,Y).

    positionRelative(left,pos(X,Y),pos(X-1,Y)) :-
        cell(X,Y),
        cell(X-1,Y).

    {do(Act, T): action(Act)} = 1 :- step(T).

    % préconditions
    :-  do(D, T),
        positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
        fluent(at(X1, Y1), T),
        not cell(X2, Y2).

    :-  do(D, T),
        positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
        fluent(at(X1, Y1), T),
        fluent(box(X2, Y2), T).

    :-  do(D, T),
        positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
        fluent(at(X1, Y1), T),
        fluent(monster(X2, Y2), T).

    :- do(D, T),
        positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
        fluent(at(X1, Y1), T),
        spikes(X1, Y2),
        not do(on_spike, T + 1).

    :- do(D, T),
        fluent(at(X1, Y1), T),
        trap(X2, Y2, on, T),
        not do(on_spike, T + 1).

    % effets
    fluent(at(X2, Y2), T + 1) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        fluent(at(X1, Y1), T),
        cell(X2, Y2),
        not fluent(box(X2, Y2), T),
        not fluent(monster(X2, Y2), T),
        not fluent(chest(X2, Y2), T).

    fluent(at(X2, Y2), T + 1) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        fluent(at(X1, Y1), T),
        cell(X2, Y2),
        spikes(X2, Y2),
        not fluent(box(X2, Y2), T),
        not fluent(monster(X2, Y2), T),
        not fluent(chest(X2, Y2), T).

    fluent(at(X1, Y1), T + 1) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        fluent(at(X1, Y1), T),
        cell(X2, Y2),
        fluent(chest(X2, Y2), T),
        fluent(has_key(0), T).

    fluent(at(X2, Y2), T + 1) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        fluent(at(X1, Y1), T),
        cell(X2, Y2),
        fluent(chest(X2, Y2), T),
        fluent(has_key(1), T).

    removed(chest(X2, Y2), T + 1) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        fluent(at(X1, Y1), T),
        fluent(has_key(1), T).

    removed(at(X1, Y1), T) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        fluent(at(X1, Y1), T).

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% ACTIONS PUSH BOXES %%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%% ACTION PUSH LEFT %%%%%%
    % préconditions
    :-  do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        fluent(at(X1, Y1), T),
        not fluent(box(X2, Y2), T).

    :-  do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        fluent(at(X1, Y1), T),
        not cell(X2, Y2).

    :-  do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        fluent(at(X1, Y1), T),
        spikes(X1, Y1),
        not do(on_spike, T + 1).

    :-  do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        fluent(at(X1, Y1), T),
        trap(X1, Y1, on, T),
        not do(on_spike, T + 1).

    % effets
    fluent(box(X3, Y3), T + 1) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        positionRelative(D, pos(X2, Y2), pos(X3, Y3)),
        fluent(at(X1, Y1), T),
        not demoness(X3, Y3),
        not fluent(box(X3, Y3), T),
        not fluent(chest(X3, Y3), T),
        not fluent(monster(X3, Y3), T).

    fluent(box(X2, Y2), T + 1) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        positionRelative(D, pos(X2, Y2), pos(X3, Y3)),
        fluent(at(X1, Y1), T),
        demoness(X3, Y3).

    fluent(box(X2, Y2), T + 1) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        positionRelative(D, pos(X2, Y2), pos(X3, Y3)),
        fluent(at(X1, Y1), T),
        fluent(box(X3, Y3), T).

    fluent(box(X2, Y2), T + 1) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        positionRelative(D, pos(X2, Y2), pos(X3, Y3)),
        fluent(at(X1, Y1), T),
        fluent(chest(X3, Y3), T).

    fluent(box(X2, Y2), T + 1) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        positionRelative(D, pos(X2, Y2), pos(X3, Y3)),
        fluent(at(X1, Y1), T),
        fluent(monster(X3, Y3), T).

    removed(box(X2, Y2), T) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        fluent(at(X1, Y1), T).

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% ACTIONS PUSH MONSTERS %%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%% ACTION MONSTER LEFT %%%%%%
    % préconditions
    :-  do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        fluent(at(X1, Y1), T),
        not fluent(monster(X2, Y2), T).

    :-  do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        positionRelative(D, pos(X2, Y2), pos(X3, Y3)),
        fluent(at(X1, Y1), T),
        fluent(monster(X3, Y3), T).

    :-  do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        fluent(at(X1, Y1), T),
        spikes(X1, Y1),
        not do(on_spike, T + 1).

    :-  do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        fluent(at(X1, Y1), T),
        trap(X1, Y1, off, T),
        not do(on_spike, T + 1).

    % effets
    fluent(monster(X3, Y3), T + 1) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        positionRelative(D, pos(X2, Y2), pos(X3, Y3)),
        fluent(at(X1, Y1), T),
        cell(X3, Y3),
        not fluent(box(X3, Y3), T),
        not fluent(chest(X3, Y3), T).

    removed(monster(X2, Y2), T) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        fluent(at(X1, Y1), T).

    removed(monster(X2, Y2), T) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        positionRelative(D, pos(X2, Y2), pos(X3, Y3)),
        fluent(at(X1, Y1), T),
        fluent(box(X3, Y3), T).

    removed(monster(X2, Y2), T) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        positionRelative(D, pos(X2, Y2), pos(X3, Y3)),
        fluent(at(X1, Y1), T),
        spikes(X3, Y3).

    removed(monster(X2, Y2), T) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        positionRelative(D, pos(X2, Y2), pos(X3, Y3)),
        fluent(at(X1, Y1), T),
        not cell(X3, Y3).
    
    %%%%%% SWITCH TRAPS %%%%%%

    :- trap(X, Y, S1, T), trap(X, Y, S2, T + 1), S1 = S2.

    removed(monster(X, Y), T) :-
        trap(X, Y, on, T),
        fluent(monster(X, Y), T).

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% KEY AND CHEST %%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%

    fluent(has_key(1), T) :-
        do(D, T),
        positionRelative(D, pos(X1, Y1), pos(X2, Y2)),
        fluent(at(X1, Y1), T),
        fluent(key(X2, Y2), T).

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
        T + 1 < maxstep,
        not removed(F, T).

    fluent(F, T + 1) :-
        fluent(F, T),
        achieved(T),
        T + 1 <= maxstep.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    #show do/2.