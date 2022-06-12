from utils import State, Action
from typing import List, Tuple, Callable, Dict

# Insert at the end of the list
def insert_tail(s : State, l : List[State]) -> List[State]:
    l.append(s)
    return l

# Remove the head of the list
def remove_head(l : List[State]) -> Tuple[State, List[State]]:
    return l.pop(0), l

# BFS Search (Parcours en Largeur)
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