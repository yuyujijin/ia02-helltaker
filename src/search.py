from utils import State, Action
from typing import List, Tuple, Callable, Dict

# SEARCH APPENDING / REMOVING

# BFS Search (Parcours en largeur)
# Insert at the end of the list
def insert_tail(s : State, l : List[State]) -> List[State]:
    l.append(s)
    return l

# Remove the head of the list
def remove_head(l : List[State]) -> Tuple[State, List[State]]:
    if len(l) != 0:
            elt = l.pop(0)
            return(elt, l)
    return (None, [])

# DFS Search (Parcours en profondeur)
# Insert at the head of the list
def insert_prof(elt : State, L : List[State]) -> List[State]:
    L += [elt]
    return L

# Remove the end of the list
def remove_prof(L : List[State]) -> Tuple[State, List[State]]:
    if len(L) != 0:
        elt = L.pop()
        return(elt, L)
    return (None, [])

# Search with parent known
def search_with_parent(s0 : State, 
                       goals : Callable[[State], bool], 
                       succ : Callable[[State], Dict[State, Action]], 
                       remove : Callable[[List[State]], State], 
                       insert : Callable[[State, List[State]], List[State]], 
                       debug : bool = True) :
    l = [s0]
    save = {s0: None}
    s = s0
    while l:
        if debug:
            print("l =", l)
        s, l = remove(l)
        for s2,a in succ(s).items():
            if not s2 in save:
                save[s2] = (s,a)
                if goals(s2):
                    return s2, save
                insert(s2, l)
    return None, save