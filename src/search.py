from utils import State, Action
from typing import List, Tuple, Callable, Dict
import heapq
from collections import deque

# SEARCH APPENDING / REMOVING

# BFS Search (Parcours en largeur)
# Insert at the end of the list
def insert_tail(elt: State, L: List[State]) -> List[State]:
    L.append(elt)
    return L

# Remove the head of the list
def remove_head(L: List[State]) -> Tuple[State, List[State]]:
    elt = L.popleft()
    return(elt, L)

# DFS Search (Parcours en profondeur)
# Insert at the head of the list
def insert_prof(elt: State, L: List[State]) -> List[State]:
    L.appendleft(elt)
    return L

# Remove the end of the list
def remove_prof(L: List[State]) -> Tuple[State, List[State]]:
    elt = L.pop()
    return(elt, L)

# A* Search
# Factories for heuristic
def heuristic_manhattan_factory(map_rules: Dict[str, set]) -> Callable[[State, int], int]:
    # Manhattan
    def heuristic_astar(elt: State) -> int:
        (x, y) = elt.me
        (x_end, y_end) = list(map_rules['goals'])[0]
        h = abs(x - x_end) + abs(y - y_end)
        return h
    return heuristic_astar

# An advanced version of manhattan searching first for keys, then locks then goal
def heuristic_manhattan_advanced_factory(map_rules: Dict[str, set]) -> Callable[[State, int], int]:
    # Manhattan
    def heuristic_astar(elt: State) -> int:
        (x, y) = elt.me
        # If there is a key go get it
        if len(elt.keys) > 0:
            (x_end, y_end) = list(elt.keys)[0]
        # If there is a lock go get it
        elif len(elt.locks) > 0:
            (x_end, y_end) = list(elt.locks)[0]
        # Else aim for the goal
        else:
            (x_end, y_end) = list(map_rules['goals'])[0]
        h = abs(x - x_end) + abs(y - y_end)
        return h
    return heuristic_astar

# Euclidean
def heuristic_euclidean_factory(map_rules: Dict[str, set]) -> Callable[[State, int], int]:
    def heuristic_astar(elt: State) -> int:
        (x, y) = elt.me
        (x_end, y_end) = list(map_rules['goals'])[0]
        h = (x - x_end)**2 + (y - y_end)**2
        return h
    return heuristic_astar

# Insert in order of heuristics
def insert_astar(elt: State, L: List[State]) -> List[State]:
    heapq.heappush(L, elt)
    return L

# Remove the head of the list
def remove_astar(L: List[State]) -> Tuple[State, List[State]]:
    return heapq.heappop(L), L

# Search with parent known (works with A* or not)
def search_with_parent(s0: State,
                        goals: Callable[[State], bool],
                        succ: Callable[[State], Dict[State, Action]],
                        remove: Callable[[List[State]], State],
                        insert: Callable[[State, List[State]], List[State]],
                        # Default heuristic just doesn't value anything
                        heuristic: Callable[[
                           Tuple[State, int]], int] = lambda s: 0,
                        # G function for heuristic
                        g_func : Callable[[int], int] = lambda x : 0,
                        debug: bool = True,
                        l = []):
    # Insertion first element
    l = insert((0, 0, s0), l)
    # Save for traceback
    save = {s0: None}
    s = s0
    # While l is not empty
    while l:
        # Used for printing
        if debug:
            print("l =", l)
        # Remove the head of the list with heuristics
        (_, g, s), l = remove(l)
        # For every possible successors
        for s2, a in succ(s).items():
            # If exact same state is not already visited
            if not s2 in save:
                # Save it
                save[s2] = (s, a)
                # If its the goal return
                if goals(s2):
                    return s2, save
                # Else insert it in the list and repeat
                h2 = heuristic(s2) + g
                l = insert((h2, g_func(g), s2), l)
    # Nothing found
    return None, save
