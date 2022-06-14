from utils import State, Action
from typing import List, Tuple, Callable, Dict

# SEARCH APPENDING / REMOVING

# BFS Search (Parcours en largeur)
# Insert at the end of the list
def insert_tail(s : State, L : List[State]) -> List[State]:
    L.append(s)
    return L

# Remove the head of the list
def remove_head(L : List[State]) -> Tuple[State, List[State]]:
    if len(L) != 0:
            elt = L.pop(0)
            return(elt, L)
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

# A* Search
# Factory for heuristic
def heuristic_astar_factory(map_rules : Dict[str, set]) -> Callable[[State, int], int]:
    # Manhattan
    def heuristic_astar(elt : State, h : int) -> int:
        (x,y) = elt.me
        (x_end, y_end) = list(map_rules['goals'])[0]
        h2 = abs(x - x_end) + abs(y - y_end)
        return h2
    return heuristic_astar

# Insert in order of heuristics
def insert_astar(elt : State, L : List[State]) -> List[State]:
    if L == []:
        return [elt]

    (_, h) = elt

    i, n  = 0, len(L)
    while i < n:
        (_, h2) = L[i]
        if h <= h2:
            break
        i += 1
    
    L = L[:i] + [elt] + L[i:]
    return L

# Remove the head of the list
def remove_astar(L : List[State]) -> Tuple[State, List[State]]:
    if len(L) != 0:
            elt = L.pop(0)
            return(elt, L)
    return (None, [])

# Search with parent known (works with A* or not)
def search_with_parent(s0 : State, 
                       goals : Callable[[State], bool], 
                       succ : Callable[[State], Dict[State, Action]], 
                       remove : Callable[[List[State]], State], 
                       insert : Callable[[State, List[State]], List[State]],
                       heuristic : Callable[[Tuple[State, int]], int] = lambda s, h : 0,
                       debug : bool = True) :
    l = [(s0, 0)]
    save = {s0: None}
    s = s0
    # While l is not empty
    while l:
        # Used for printing
        if debug:
            print("l =", l)
        # Remove the head of the list with heuristics
        (s, h), l = remove(l)
        # For every possible successors
        for s2 ,a in succ(s).items():
            # If exact same state is not already visited
            if not s2 in save:
                # Save it
                save[s2] = (s, a)
                # If its the goal return
                if goals(s2):
                    return s2, save
                # Else insert it in the list and repeat
                h2 = heuristic(s2, h)
                l = insert((s2, h2), l)
    # Nothing found
    return None, save