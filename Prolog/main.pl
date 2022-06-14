%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%        HELLTAKER IN PROLOG     %%%
%%%         version: 0.1           %%%
%%%  authors : HABERT Thomas       %%%
%%%            MASSINON Isabelle   %%%
%%%            VALTY Eugène        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% clingo -c horizon=10 -n0 main.pl

% state(me(X,Y), hit(X), monster(M), rock(R), safe(S), unsafe(U), key(K), lock(L)).

case(pos(1,4)).
case(pos(2,1)).
case(pos(2,5)).
case(pos(2,7)).
case(pos(3,2)).
case(pos(3,4)).
case(pos(3,7)).
case(pos(4,1)).
case(pos(4,3)).
case(pos(4,5)).
case(pos(4,8)).
case(pos(5,2)).
case(pos(5,4)).
case(pos(5,6)).
wall(pos(0,0)).
wall(pos(0,1)).
wall(pos(0,2)).
wall(pos(0,3)).
wall(pos(0,4)).
wall(pos(0,5)).
wall(pos(0,6)).
wall(pos(0,7)).
wall(pos(0,8)).
wall(pos(0,9)).
wall(pos(1,0)).
wall(pos(1,2)).
wall(pos(1,6)).
wall(pos(1,7)).
wall(pos(1,8)).
wall(pos(1,9)).
wall(pos(2,0)).
wall(pos(2,8)).
wall(pos(2,9)).
wall(pos(3,0)).
wall(pos(3,9)).
wall(pos(4,0)).
wall(pos(4,9)).
wall(pos(5,0)).
wall(pos(5,1)).
wall(pos(5,7)).
wall(pos(5,8)).
wall(pos(5,9)).
wall(pos(6,0)).
wall(pos(6,1)).
wall(pos(6,2)).
wall(pos(6,3)).
wall(pos(6,4)).
wall(pos(6,5)).
wall(pos(6,6)).
wall(pos(6,7)).
wall(pos(6,8)).
wall(pos(6,9)).
goal(pos(3,8)).
spike(pos(2,3)).
start(state(
	player(pos(1,1)),
	rock([pos(1,5),pos(2,2),pos(3,1),pos(3,3),pos(3,5),pos(3,6),pos(4,2),pos(4,4),pos(4,6),pos(4,7),pos(5,3),pos(5,5)]),
	key(pos(1,3)),
	lock([pos(2,6)]),
	monster([]),
	safe([]),
	unsafe([])
)).
%%%%%% UTILITAIRES %%%%%%

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

%%%%%% ACTIONS %%%%%%

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

%se déplacer
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

%Marcher sur une clé = la récupérer
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

%Pousser un rocher
do(act(pushRock,D),
    state(me(X1,Y1), hit(H1), monster(M), rock(R1), safe(S), unsafe(U), key(K), lock(L)),
    state(me(X1,Y1), hit(H2), monster(M), rock([(X3,Y3)|R2]), safe(U), unsafe(S), key(K), lock(L))) :-
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
    state(me(X1,Y1), hit(H1), monster(M1), rock(R), safe(S), unsafe(U), key(K), lock(L)),
    state(me(X1,Y1), hit(H2), monster([(X3,Y3)|M2]), rock(R), safe(U), unsafe(S), key(K), lock(L))) :-
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
    state(me(X1,Y1), hit(H1), monster(M1), rock(R), safe(S), unsafe(U), key(K), lock(L)),
    state(me(X1,Y1), hit(H2), monster(M2), rock(R), safe(U), unsafe(S), key(K), lock(L))) :-
        positionRelative(D, pos(X1,Y1), pos(X2,Y2)),
        positionRelative(D,pos(X2,Y2),pos(X3,Y3)),
        wall(X3,Y3),
        enleve(pos(X2,Y2),M1,M2),
        H2 is H1 - 1.

%Marcher sur un pic
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

%Marcher sur un piège désactivé (il sera activé quand on est dessus)
do(act(moveSafe,D),
    state(me(X1,Y1), hit(H1), monster(M), rock(R), safe(S), unsafe(U), key(K), kown(KO), lock(L)),
    state(me(X2,Y2), hit(H2), monster(M), rock(R), safe(U), unsafe(S), key(K), kown(KO), lock(L))) :-
        positionRelative(D,pos(X1,Y1), pos(X2,Y2)),
        notIn(pos(X2,Y2),R),
        notIn(pos(X2,Y2),U),
        notIn(pos(X2,Y2),K),
        notIn(pos(X2,Y2),L),
        notIn(pos(X2,Y2),M),
        H2 is H1 - 2.

%Marchers sur un piège activé (il sera désactivé quand on est dessus)
do(act(moveUnsafe,D),
    state(me(X1,Y1), hit(H1), monster(M), rock(R), safe(S), unsafe(U), key(K), kown(KO), lock(L)),
    state(me(X2,Y2), hit(H2), monster(M), rock(R), safe(U), unsafe(S), key(K), kown(KO), lock(L))) :-
        positionRelative(D,pos(X1,Y1), pos(X2,Y2)),
        notIn(pos(X2,Y2),R),
        notIn(pos(X2,Y2),S),
        notIn(pos(X2,Y2),K),
        notIn(pos(X2,Y2),M),
        notIn(pos(X2,Y2),L),
        H2 is H1 - 1.

%Ouvrir une serrure
do(act(unlock,D),
    state(me(X1,Y1), hit(H1), monster(M), rock(R), safe(S), unsafe(U), key(K), kown(KO1), lock(L1)),
    state(me(X2,Y2), hit(H2), monster(M), rock(R), safe(U), unsafe(S), key(K), kown(KO2), lock(L2))) :-
        positionRelative(D,pos(X1,Y1), pos(X2,Y2)),
        notIn(pos(X2,Y2),R),
        notIn(pos(X2,Y2),U),
        notIn(pos(X2,Y2),S),
        notIn(pos(X2,Y2),K),
        notIn(pos(X2,Y2),M),
        enleve(pos(X2,Y2),L1,L2),
        KO1 > 0,
        KO2 is KO1 - 1,
        H2 is H1 - 1.

killMobOnSpike(
    state(me(X1,Y1), hit(H), monster([]), rock(R), safe(U), unsafe(S), key(K), kown(KO2), lock(L2)),state(me(X1,Y1), hit(H), monster([]), rock(R), safe(U), unsafe(S), key(K), kown(KO2), lock(L2))).
killMobOnSpike(
    state(me(X1,Y1), hit(H), monster(M1), rock(R), safe(S), unsafe(U), key(K), kown(KO), lock(L)),
    state(me(X1,Y1), hit(H), monster(M3), rock(R), safe(U), unsafe(S), key(K), kown(KO), lock(L)))
    :-
        killMobOnSpike(
            state(me(X1,Y1), hit(H), monster(M1), rock(R), safe(U), unsafe(S), key(K), kown(KO), lock(L)),
            state(me(X1,Y1), hit(H), monster([pos(X2,Y2)|M2]), rock(R), safe(U), unsafe(S), key(K), kown(KO), lock(L))
        ),
        spike(pos(X2,Y2)),
        enleve(pos(X2,Y2),M2,M3).    

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

victory(state(me(X,Y), hit(H), monster(_), rock(_), safe(_), unsafe(_), key(_), kown(_), lock(_))) :- 
    goal(X,Y+1),
    H >= 0.
victory(state(me(X,Y), hit(H), monster(_), rock(_), safe(_), unsafe(_), key(_), kown(_), lock(_))) :- 
    goal(X,Y-1),
    H >= 0.
victory(state(me(X,Y), hit(H), monster(_), rock(_), safe(_), unsafe(_), key(_), kown(_), lock(_))) :- 
    goal(X+1,Y),
    H >= 0.
victory(state(me(X,Y), hit(H), monster(_), rock(_), safe(_), unsafe(_), key(_), kown(_), lock(_))) :- 
    goal(X-1,Y),
    H >= 0. 



