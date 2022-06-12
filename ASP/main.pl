state(me(x,y), hit(x), monster(x,y), rock(x,y), trapActivated(x), key(x,y), lock(x,y)).

/* Actions */

notIn(_,[]).
notIn(X,[H|T]) :-
    dif(X,H),
    notIn(X,T).

enleve(_,[],[]).
enleve(E,[H|T],[H|L2]):-
    dif(E,H),
    enleve(E,T,L2).
enleve(E,[E|T],T).

ends([X],X).
ends([_|T],X) :- ends(T,X).

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

do(act(move,D),
    state(me(X1,Y1), hit(H1), monster(M), rock(R), safe(S), unsafe(U), key(K), kown(KO), lock(L)),
    state(me(X2,Y2), hit(H2), monster(M), rock(R), safe(U), unsafe(S), key(K), kown(KO), lock(L))) :-
        positionRelative(D,pos(X1,Y1), pos(X2,Y2)),
        notIn(pos(X2,Y2),R),
        notIn(pos(X2,Y2),U),
        notIn(pos(X2,Y2),S),
        notIn(pos(X2,Y2),K),
        notIn(pos(X2,Y2),M),
        notIn(pos(X2,Y2),L),
        H2 is H1 - 1.

do(act(collect,D),
    state(me(X1,Y1), hit(H1), monster(M), rock(R), safe(S), unsafe(U), key(K1), kown(KO1), lock(L)),
    state(me(X2,Y2), hit(H2), monster(M), rock(R), safe(U), unsafe(S), key(K2), kown(KO2), lock(L))) :-
        positionRelative(D,pos(X1,Y1), pos(X2,Y2)),
        enleve(pos(X2,Y2),K1,K2),
        notIn(pos(X2,Y2),R),
        notIn(pos(X2,Y2),U),
        notIn(pos(X2,Y2),S),
        notIn(pos(X2,Y2),M),
        notIn(pos(X2,Y2),L),
        KO2 is KO1 + 1,
        H2 is H1 - 1.

do(act(pushRock,D),
    state(me(X1,Y1), hit(H), monster(M), rock(R1), safe(S), unsafe(U), key(K), lock(L)),
    state(me(X1,Y1), hit(H), monster(M), rock([(X3,Y3)|R2]), safe(U), unsafe(S), key(K), lock(L))) :-
        positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
        enleve(pos(X2,Y2),R1,R2),
        positionRelative(D,pos(X2,Y2),pos(X3,Y3)),
        notIn(pos(X3,Y3),K),
        notIn(pos(X2,Y2),U),
        notIn(pos(X2,Y2),S),
        notIn(pos(X3,Y3),L),
        notIn(pos(X3,Y2),M),
        notIn(pos(X3,Y3),R1),
        H2 is H1 - 1.

% Juste pousser le monstre
do(act(pushMonster,D),
    state(me(X1,Y1), hit(H), monster(M1), rock(R), safe(S), unsafe(U), key(K), lock(L)),
    state(me(X1,Y1), hit(H), monster([(X3,Y3)|M2]), rock(R), safe(U), unsafe(S), key(K), lock(L))) :-
        positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
        enleve(pos(X2,Y2),M1,M2),
        positionRelative(D,pos(X2,Y2),pos(X3,Y3)),
        notIn(pos(X2,Y2),L),
        notIn(pos(X3,Y3),M1),
        notIn(pos(X2,Y2),U),
        notIn(pos(X2,Y2),S),
        notIn(pos(X3,Y3),K),
        notIn(pos(X3,Y3),L),
        notIn(pos(X3,Y3),R),
        H2 is H1 - 1.

%Pousser le monstre sur un mur = le tuer
do(act(pushMonster,D),
    state(me(X1,Y1), hit(H), monster(M1), rock(R), safe(S), unsafe(U), key(K), lock(L)),
    state(me(X1,Y1), hit(H), monster(M2), rock(R), safe(U), unsafe(S), key(K), lock(L))) :-
        positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
        enleve(pos(X2,Y2),R1,R2),
        positionRelative(D,pos(X2,Y2),pos(X3,Y3)),
        wall(X3,Y3),
        enleve(pos(X2,Y2),M1,M2),
        H2 is H1 - 1.

do(act(moveSpike,D),
    state(me(X1,Y1), hit(H1), monster(M), rock(R), safe(S), unsafe(U), key(K), kown(KO), lock(L)),
    state(me(X2,Y2), hit(H2), monster(M), rock(R), safe(U), unsafe(S), key(K), kown(KO), lock(L))) :-
        positionRelative(D,pos(X1,Y1), pos(X2,Y2)),
        spike(X2,Y2),
        notIn(pos(X2,Y2),U),
        notIn(pos(X2,Y2),S),
        notIn(pos(X2,Y2),K),
        notIn(pos(X2,Y2),L),
        notIn(pos(X2,Y2),M),
        notIn(pos(X2,Y2),R),
        H2 is H1 - 2.

do(act(moveSafe,D),
    state(me(X1,Y1), hit(H1), monster(M), rock(R), safe(S), unsafe(U), key(K), kown(KO), lock(L)),
    state(me(X2,Y2), hit(H2), monster(M), rock(R), safe(U), unsafe(S), key(K), kown(KO), lock(L))) :-
        positionRelative(D,pos(X1,Y1), pos(X2,Y2)),
        notIn(pos(X2,Y2),R),
        notIn(pos(X2,Y2),U),
        notIn(pos(X2,Y2),S),
        notIn(pos(X2,Y2),K),
        notIn(pos(X2,Y2),L),
        H2 is H1 - 2.

do(act(moveUnsafe,D),
    state(me(X1,Y1), hit(H1), monster(M), rock(R), safe(S), unsafe(U), key(K), kown(KO), lock(L)),
    state(me(X2,Y2), hit(H2), monster(M), rock(R), safe(U), unsafe(S), key(K), kown(KO), lock(L))) :-
        positionRelative(D,pos(X1,Y1), pos(X2,Y2)),
        notIn(pos(X2,Y2),R),
        notIn(pos(X2,Y2),T),
        notIn(pos(X2,Y2),K),
        notIn(pos(X2,Y2),L),
        H2 is H1 - 1.

planValide([],[_],0).
planValide([A|AT],[S1,S2|ST],N) :-
    N>0,
    N1 is N-1,
    do(A,S1,S2),
    planValide(AT,[S2|ST], N1).

planGagnant(A, [X|T],N) :-
    start(X),
    planValide(A,[X|T],N),
    ends(T, state(_, boxes(L))),
    allOnTarget(L).
