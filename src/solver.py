#!/usr/bin/python3
import sys
import os
# Used to import helltaker_utils
sys.path.append(os.path.join(sys.path[0], "..", "python"))
import helltaker_utils

from utils import Action, State, actions
from typing import Callable, Dict, List, Set, Tuple
import argparse


# Create starting state


def create_starting_state(grid: List[str], max_steps: int, n: int, m: int) -> State:
    # Initiate sets
    me = None
    blocks = set()
    keys = set()
    locks = set()
    mobs = set()
    safeTraps = set()
    unsafeTraps = set()
    # Fill the sets
    for i in range(m):
        for j in range(n):
            e = grid[i][j]
            if e in ['H']:
                me = (i, j)
            if e in ['B', 'O', 'P', 'Q']:
                blocks.add((i, j))
            if e in ['K']:
                keys.add((i, j))
            if e in ['L']:
                locks.add((i, j))
            if e in ['M']:
                mobs.add((i, j))
            if e in ['T', 'P']:
                safeTraps.add((i, j))
            if e in ['U', 'Q']:
                unsafeTraps.add((i, j))

    # Returns starting state
    return State(me=me, max_steps=max_steps, nbKeys=0, blocks=frozenset(blocks),
                 keys=frozenset(keys), locks=frozenset(locks), mobs=frozenset(mobs),
                 safeTraps=frozenset(safeTraps), unsafeTraps=frozenset(unsafeTraps))

# Create non-fluents


def create_map_rules(grid: List[str], n: int, m: int) -> Dict[str, set]:
    # Initiate dictionnary
    map_rules = {'goals': set(), 'walls': set(), 'spikes': set()}

    # Fill the dictionnary
    for i in range(m):
        for j in range(n):
            e = grid[i][j]
            if e in ['D']:
                map_rules['goals'].add((i, j))
            elif e in ['#']:
                map_rules['walls'].add((i, j))
            elif e in ['S', 'O']:
                map_rules['spikes'].add((i, j))

    return map_rules

# Return the new position after taking one step


def one_step(position: Tuple[int, int], direction: str) -> Tuple[int, int]:
    i, j = position
    return {'d': (i, j+1), 'g': (i, j-1), 'h': (i-1, j), 'b': (i+1, j)}[direction]

# Check if tile is accessible


def free(position: Tuple[int, int], map_rules: Dict[str, set]) -> bool:
    return not(position in map_rules['walls'] or position in map_rules['goals'])

# Copy a state and returns a copy of a it


def copy_state(state: State) -> State:
    return State(**{k: v for k, v in state._asdict().items()})

# Make a copy of a frozen set and adds an element to it


def add_in_frozenset(fset: frozenset, elt: Tuple[int, int]) -> frozenset:
    s = {x for x in fset}
    s.add(elt)
    return frozenset(s)


def remove_in_frozenset(fset: frozenset, elt: Tuple[int, int]) -> frozenset:
    s = {x for x in fset}
    s.remove(elt)
    return frozenset(s)

# Removes every move that are on spikes and active traps and returns a new state


def kill_mobs_on_spike(state: State, map_rules: Dict[str, set]) -> State:
    newState = copy_state(state)

    fixedMobs = {x for x in newState.mobs}

    newMobs = newState.mobs

    for mob in fixedMobs:
        if (mob in newState.unsafeTraps) or (mob in map_rules['spikes']):
            newMobs = remove_in_frozenset(newState.mobs, mob)

    newState = newState._replace(mobs=newMobs)
    return newState

# Swap the safe and unsafe traps and remove steps depending on the state of the game


def action_cost(state: State, map_rules: Dict[str, set]) -> State:
    x0 = state.me
    newState = copy_state(state)

    # Swap safe and unsafe traps
    newState = newState._replace(safeTraps=newState.unsafeTraps,
                                 unsafeTraps=newState.safeTraps)

    newState = kill_mobs_on_spike(newState, map_rules)

    if (x0 in newState.unsafeTraps) or (x0 in map_rules['spikes']):
        newState = newState._replace(max_steps=newState.max_steps - 2)
    else:
        newState = newState._replace(max_steps=newState.max_steps - 1)
    return newState

# Execute an action and returns a new state


def do(action: Action, state: State, map_rules: Dict[str, set]) -> State:
    # We retrieve the actual position
    x0 = state.me

    # Fluents used and moveable
    blocks = state.blocks
    mobs = state.mobs
    spikes = map_rules['spikes']
    safeTraps = state.safeTraps
    unsafeTraps = state.unsafeTraps
    keys = state.keys
    nbKeys = state.nbKeys
    locks = state.locks

    # We make the action
    x1 = one_step(x0, action.direction)

    # NOW DEFINE EVERY POSSIBLE ACTIONS (REDUNDANT)
    # Simple move
    if action.verb == 'move':
        # if tile is accessible and empty
        if free(x1, map_rules) and not (x1 in blocks | mobs | spikes
                                        | safeTraps | unsafeTraps | keys | locks):
            # We move ourselve
            newState = copy_state(state)
            newState = newState._replace(me=x1)
            # Turn cost
            newState = action_cost(newState, map_rules)
            if newState.max_steps < 0:
                return None
            # The return
            return newState
        else:
            return None
    # Move on a spike
    elif action.verb == 'moveSpike':
        # if tile is accessible and has spikes on it
        if not (x1 in blocks) and (x1 in spikes):
            # We move ourselve
            newState = copy_state(state)
            newState = newState._replace(me=x1)
            # Turn cost
            newState = action_cost(newState, map_rules)
            if newState.max_steps < 0:
                return None
            # The return
            return newState
        else:
            return None
    # Move on a trap
    elif action.verb == 'moveTrap':
        # if tile is accessible and has traps on it
        if not (x1 in blocks) and (x1 in safeTraps | unsafeTraps):
            # We move ourselve
            newState = copy_state(state)
            newState = newState._replace(me=x1)
            # Turn cost
            newState = action_cost(newState, map_rules)
            if newState.max_steps < 0:
                return None
            # The return
            return newState
        else:
            return None
    # Move on a key
    elif action.verb == 'moveKey':
        # if tile is accessible and has key on it
        if (x1 in keys) and not (x1 in blocks):
            # We move ourselve and decrement the number of max_steps by one
            newState = copy_state(state)
            newState = newState._replace(me=x1)
            # Turn cost
            newState = action_cost(newState, map_rules)
            if newState.max_steps < 0:
                return None
            # Remove the key from the set
            newKeys = remove_in_frozenset(keys, x1)
            newState = newState._replace(keys=newKeys)
            # Increment the number of held keys
            newState = newState._replace(nbKeys=newState.nbKeys + 1)
            # Then return
            return newState
        else:
            return None
    # Unlock a lock
    elif action.verb == 'unlock':
        # if tile is accessible and has lock on it and the player is a holding a key
        if (x1 in locks) and (nbKeys > 0):
            # We move ourselve and decrement the number of max_steps by one
            newState = copy_state(state)
            newState = newState._replace(me=x1)
            # Turn cost
            newState = action_cost(newState, map_rules)
            if newState.max_steps < 0:
                return None
            # Remove the lock from the set
            newLocks = remove_in_frozenset(locks, x1)
            newState = newState._replace(locks=newLocks)
            # Decrement the number of held keys
            newState = newState._replace(nbKeys=newState.nbKeys - 1)
            # Then return
            return newState
        else:
            return None
    # Push a block
    elif action.verb == 'pushBlock':
        # Get the tile were the block would be pushed
        x2 = one_step(x1, action.direction)
        # if there is a block on
        if x1 in blocks and free(x2, map_rules) and not (x2 in locks | mobs | blocks):
            # We move ourselve and decrement the number of max_steps by one
            newState = copy_state(state)
            # Turn cost
            newState = action_cost(newState, map_rules)
            if newState.max_steps < 0:
                return None
            # Remove the block and add its new position
            newBlocks = remove_in_frozenset(blocks, x1)
            newBlocks = add_in_frozenset(newBlocks, x2)
            newState = newState._replace(blocks=newBlocks)
            # Then return
            return newState
        else:
            return None
    # Push a mob
    elif action.verb == 'pushMob':
        # Get the tile were the mob would be pushed
        x2 = one_step(x1, action.direction)
        if x1 in mobs and free(x2, map_rules) and not (x2 in keys | locks | mobs | blocks):
            # We move ourselve and decrement the number of max_steps by one
            newState = copy_state(state)
            # Turn cost
            newState = action_cost(newState, map_rules)
            if newState.max_steps < 0:
                return None
            # Remove the block and add its new position
            newMobs = remove_in_frozenset(mobs, x1)
            newMobs = add_in_frozenset(newMobs, x2)
            newState = newState._replace(mobs=newMobs)
            # Then return
            return newState
        else:
            return None
    # Kill a mob
    elif action.verb == 'killMob':
        # Get the tile were the mob would be pushed
        x2 = one_step(x1, action.direction)
        if x1 in mobs and (not free(x2, map_rules) or x2 in blocks):
            # We move ourselve and decrement the number of max_steps by one
            newState = copy_state(state)
            # Turn cost
            newState = action_cost(newState, map_rules)
            if newState.max_steps < 0:
                return None
            # Remove the block and add its new position
            newMobs = remove_in_frozenset(mobs, x1)
            newState = newState._replace(mobs=newMobs)
            # Then return
            return newState
        else:
            return None
    # We did nothing
    return None

# Factory for goals


def goal_factory(map_rules: Dict[str, set]) -> Callable[[State], bool]:
    def goals(state: State):
        offsets = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        return any([(state.me[0] + x[0], state.me[1] + x[1]) in map_rules['goals'] for x in offsets])
    return goals

# Factory for successor


def succ_factory(map_rules: Dict[str, set]) -> Set[Tuple[State, Action]]:
    def succ(state):
        l = []
        for x in actions.values():
            for a in x:
                l.append((do(a, state, map_rules), a))
        return {x: a for x, a in l if x}
    return succ

# Returns a list of action in string form


def dict2path(s: State, d: Dict[State, Tuple[State, Action]]) -> List[str]:
    l = [(s, None)]
    while not d[s] is None:
        parent, a = d[s]
        # print(s, a.direction)
        l.append((parent, a.direction))
        s = parent
    l.reverse()
    return l

# Returns an arrow from a string


def letter2arrow(letter: str) -> str:
    return {'d': '→', 'g': '←', 'h': '↑', 'b': '↓'}[letter]



from search import search_with_parent
# A* Search
from search import remove_astar, insert_astar, heuristic_manhattan_factory, heuristic_manhattan_advanced_factory
from search import heuristic_euclidean_factory
# DFS Search (Parcours en Profondeur)
from search import remove_prof, insert_prof
# BFS Search (Parcours en Largeur)
from search import remove_head, insert_tail

algorithms = {
    'BFS': {'remove': remove_head, 'insert': insert_tail},
    'DFS': {'remove': remove_prof, 'insert': insert_prof},
    'A*': {'remove': remove_astar, 'insert': insert_astar, 
        'heuristic': {
            'manhattan' : heuristic_manhattan_factory,
            'manhattan_advanced' : heuristic_manhattan_advanced_factory,
            'euclidean' : heuristic_euclidean_factory
        }
    }
}

# Solves a level


def solve(filename: str, algorithm: str, heuristic : str, verbose: bool, arrow: bool) -> None:
    # Parse the level
    grid = helltaker_utils.grid_from_file(filename)

    # Create the map rules
    map_rules = create_map_rules(grid['grid'], grid['n'], grid['m'])
    # Create the starting state
    s0 = create_starting_state(
        grid['grid'], grid['max_steps'], grid['n'], grid['m'])

    # If search algo is unknown
    if algorithm not in algorithms.keys():
        raise SystemExit("Error : Search algorithm %s unknown" % (algorithm))

    # Retrieve the search algorithms
    remove, insert = algorithms[algorithm]['remove'], algorithms[algorithm]['insert']

    # Search using the parameters
    # If it uses an heuristics, use it
    if 'heuristic' in algorithms[algorithm].keys():
        # If heuristic is unknown
        if heuristic not in algorithms[algorithm]['heuristic'].keys():
            raise SystemExit("Error : Heuristic %s unknown" % (heuristic))
        # Retrieve the heuristic
        heuristic = algorithms[algorithm]['heuristic'][heuristic](map_rules)
        s_end, save = search_with_parent(s0, goal_factory(map_rules), succ_factory(
            map_rules), remove, insert, debug=verbose, heuristic=heuristic)
    else:
        # Else ignore it
        s_end, save = search_with_parent(s0, goal_factory(
            map_rules), succ_factory(map_rules), remove, insert, debug=verbose)

    # If solution found
    if s_end:
        # Create a plan
        plan = ''.join([a for _, a in dict2path(s_end, save) if a])
        # Check if valid
        if helltaker_utils.check_plan(plan):
            print("Solution found with (valid) plan : ", end='')
            # Arrow mode or not
            if not arrow:
                print(plan)
            else:
                print(' '.join(list(map(letter2arrow, plan))))
        else:
            print("Plan is not valid...")
    else:
        print("No solution found...")

# Used to parse the args


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--filename", help="Level file to be solved", required=True)
    parser.add_argument(
        "--algorithm", help="Search algorithm to be used (default is BFS)", default="BFS")
    parser.add_argument(
        "--heuristic", help="Heuristic to be used (for informed algo.)(default is Manhattan)", default="manhattan")
    parser.add_argument("--verbose", help="Verbosity", action="store_true")
    parser.add_argument(
        "--arrow", help="Select if output is in arrow mode", action="store_true")
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    solve(args.filename, algorithm=args.algorithm, heuristic=args.heuristic,
          verbose=args.verbose, arrow=args.arrow)
