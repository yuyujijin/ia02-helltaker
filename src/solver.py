import sys
import time
sys.path.append('./python')
import helltaker_utils
from typing import List

from collections import namedtuple

Action = namedtuple('action', ('verb', 'direction'))
State = namedtuple('state',('me','max_steps','nbKeys', 'blocks', 
'keys', 'locks', 'mobs', 'safeTraps', 'unsafeTraps'))

actionNames = ['move', 'moveSpike', 'moveTrap', 
'moveKey', 'unlock', 'pushBlock', 'pushMob', 'killMob']

actions = {d : [] for d in 'udrl'}

for d in 'udrl':
    for a in actionNames:
        actions[d].append(Action(a,d))

# Create starting state
def create_starting_state(grid : List[str], max_steps: int, n : int, m : int):
    # Initiate sets
    me = None; blocks = set(); keys = set(); locks = set();
    mobs = set(); safeTraps = set(); unsafeTraps = set();
    # Fill the sets
    for i in range(m):
        for j in range(n):
            e = grid[i][j]
            if e in ['H']:
                me = (i,j)
            elif e in ['B','O','P','Q']:
                blocks.add((i,j))
            elif e in ['K']:
                keys.add((i,j))
            elif e in ['L']:
                locks.add((i,j))
            elif e in ['M']:
                mobs.add((i,j))
            elif e in ['T','P']:
                safeTraps.add((i,j))
            elif e in ['U','Q']:
                unsafeTraps.add((i,j))
    # Returns starting state
    return State(me = me, max_steps = max_steps, nbKeys = 0, blocks = frozenset(blocks), 
    keys = frozenset(keys), locks = frozenset(locks),mobs = frozenset(mobs), 
    safeTraps = frozenset(safeTraps), unsafeTraps = frozenset(unsafeTraps))

# Create non-fluents
def create_map_rules(grid : List[str], n : int, m : int):
    # Initiate dictionnary
    map_rules = {'goals': set(), 'walls' : set(), 'spikes' : set()}

    # Fill the dictionnary
    for i in range(m):
        for j in range(n):
            e = grid[i][j]
            if e in ['D']:
                map_rules['goals'].add((i,j))
            elif e in ['#']:
                map_rules['walls'].add((i,j))
            elif e in ['S','O']:
                map_rules['spikes'].add((i,j))
    
    return map_rules

# Return the new position after taking one step
def one_step(position, direction):
    i, j = position
    return {'r' : (i,j+1), 'l' : (i,j-1), 'u' : (i-1,j), 'd' : (i+1,j)}[direction]

# Check if tile is accessible
def free(position, map_rules) :
    return not(position in map_rules['walls'] or position in map_rules['goals'])

def copy_state(state):
    return State(**{k : v for k,v in state._asdict().items()})

def add_in_frozenset(fset, elt):
    s = {x for x in fset}
    s.add(elt)
    return frozenset(s)

def remove_in_frozenset(fset,elt):
    s = {x for x in fset}
    s.remove(elt)
    return frozenset(s)

# Removes every move that are on spikes and active traps
def kill_mobs_on_spike(state, map_rules):
    newState = copy_state(state)

    fixedMobs = {x for x in state.mobs}

    newMobs = newState.mobs

    for mob in fixedMobs:
        if (mob in state.unsafeTraps) or (mob in map_rules['spikes']):
            newMobs = remove_in_frozenset(newState.mobs, mob)

    newState = newState._replace(mobs = newMobs)
    return newState

def action_cost(state, map_rules):
    x0 = state.me
    newState = copy_state(state)

    # Swap safe and unsafe traps
    newState = newState._replace(safeTraps = newState.unsafeTraps, 
        unsafeTraps = newState.safeTraps)

    newState = kill_mobs_on_spike(state, map_rules)
            
    if (x0 in state.unsafeTraps) or (x0 in map_rules['spikes']):
        newState = newState._replace(max_steps = newState.max_steps - 2)
    else :
        newState = newState._replace(max_steps = newState.max_steps - 1)
    return newState

def print_state(state, map_rules):
    print("state : ")
    for b in state.blocks:
        print(b)
    print()

# Execute an action and returns a new state
def do(action, state, map_rules):
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
            newState = newState._replace(me = x1)
            # Turn cost
            newState = action_cost(newState, map_rules)
            if newState.max_steps < 0 : 
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
            newState = newState._replace(me = x1)
            # Turn cost
            newState = action_cost(newState, map_rules)
            if newState.max_steps < 0 : 
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
            newState = newState._replace(me = x1)
            # Turn cost
            newState = action_cost(newState, map_rules)
            if newState.max_steps < 0 : 
                return None
            # The return
            return newState
        else:
            return None
    # Move on a key
    elif action.verb == 'moveKey':
        # if tile is accessible and has key on it
        if (x1 in keys):
            # We move ourselve and decrement the number of max_steps by one
            newState = copy_state(state)
            newState = newState._replace(me = x1)
            # Turn cost
            newState = action_cost(newState, map_rules)
            if newState.max_steps < 0 : 
                return None
            # Remove the key from the set
            newKeys = remove_in_frozenset(keys, x1)
            newState = newState._replace(keys = newKeys)
            # Increment the number of held keys
            newState = newState._replace(nbKeys = newState.nbKeys + 1)
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
            newState = newState._replace(me = x1)
            # Turn cost
            newState = action_cost(newState, map_rules)
            if newState.max_steps < 0 : 
                return None
            # Remove the lock from the set
            newLocks = remove_in_frozenset(locks, x1)
            newState = newState._replace(locks = newLocks)
            # Decrement the number of held keys
            newState = newState._replace(nbKeys = newState.nbKeys - 1)
            # Then return
            return newState
        else:
            return None
    # Push a block
    elif action.verb == 'pushBlock':
        # Get the tile were the block would be pushed
        x2 = one_step(x1, action.direction)
        # if there is a block on 
        if x1 in blocks and free(x2, map_rules) and not (x2 in keys | locks | mobs | blocks):
            # We move ourselve and decrement the number of max_steps by one
            newState = copy_state(state)
            # Turn cost
            newState = action_cost(newState, map_rules)
            if newState.max_steps < 0 : 
                return None
            # Remove the block and add its new position
            newBlocks = remove_in_frozenset(blocks, x1)
            newBlocks = add_in_frozenset(newBlocks, x2)
            newState = newState._replace(blocks = newBlocks)
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
            if newState.max_steps < 0 : 
                return None
            # Remove the block and add its new position
            newMobs = remove_in_frozenset(mobs, x1)
            newMobs = add_in_frozenset(newMobs, x2)
            newState = newState._replace(mobs = newMobs)
            # Then return
            return newState
        else:
            return None
    # Kill a mob
    elif action.verb == 'killMob':
        # Get the tile were the mob would be pushed
        x2 = one_step(x1, action.direction)
        if x1 in mobs and not (free(x2, map_rules) and (mobs | blocks)):
            # We move ourselve and decrement the number of max_steps by one
            newState = copy_state(state)
            # Turn cost
            newState = action_cost(newState, map_rules)
            if newState.max_steps < 0 : 
                return None
            # Remove the block and add its new position
            newMobs = remove_in_frozenset(mobs, x1)
            newState = newState._replace(mobs = newMobs)
            # Then return
            return newState
        else:
            return None
    # We did nothing
    return None

# Insert at the end of the list
def insert_tail(s, l):
    l.append(s)
    return l

# Remove the head of the list
def remove_head(l):
    return l.pop(0), l

def search_with_parent(s0, goals, succ, 
                       remove, insert, debug=True) :
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

def goal_factory(map_rules) :
    def goals(state) :
        offsets = [(0,1), (1,0), (0,-1), (-1,0)]
        return any([(state.me[0] + x[0], state.me[1] + x[1]) in map_rules['goals'] for x in offsets])
    return goals

def succ_factory(map_rules) :
    def succ(state) :
        l = []
        for x in actions.values():
            for a in x:
                l.append((do(a, state, map_rules), a))
        return {x : a for x,a in l if x}
    return succ

def dict2path(s, d):
    l = [(s,None)]
    while not d[s] is None:
        parent, a = d[s]
        # print(s, a.direction)
        l.append((parent,a.direction))
        s = parent
    l.reverse()
    return l

if __name__ == "__main__":
    # Check if filename is given
    if len(sys.argv) < 2:
        print("Préciser un fichier.", file=sys.stderr)
        exit()
    # Retrieve the filename
    filename = sys.argv[1]
    # Parse the level
    grid = helltaker_utils.grid_from_file(filename)

    map_rules = create_map_rules(grid['grid'], grid['n'], grid['m'])
    s0 = create_starting_state(grid['grid'], grid['max_steps'], grid['n'], grid['m'])

    print("GOAL IS : ",map_rules['goals'])

    s_end, save = search_with_parent(s0, goal_factory(map_rules), succ_factory(map_rules), remove_head, insert_tail, debug = False)
    
    if s_end :
        plan = ''.join([a for s,a in dict2path(s_end,save) if a])
        print("SAT :", plan)
    else :
        print("UNSAT : NO PLAN FOUND")