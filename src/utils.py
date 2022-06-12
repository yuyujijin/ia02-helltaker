from collections import namedtuple

Action = namedtuple('action', ('verb', 'direction'))
State = namedtuple('state',('me','max_steps','nbKeys', 'blocks', 
'keys', 'locks', 'mobs', 'safeTraps', 'unsafeTraps'))

actionNames = ['move', 'moveSpike', 'moveTrap', 
'moveKey', 'unlock', 'pushBlock', 'pushMob', 'killMob']

actions = {d : [] for d in 'hbgd'}

for d in 'hbgd':
    for a in actionNames:
        actions[d].append(Action(a,d))