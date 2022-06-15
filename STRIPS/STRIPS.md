# Représentation STRIPS

1. [Prédicats](#1-prédicats)
    1. [Fluents](#11-fluents)
    2. [Non fluents](#12-non-fluents)
2. [Init](#2-init)
3. [But](#3-but)
4. [Actions](#4-actions)
5. [Sauvegarde d'états](#5-sauvegarde-détats)

## 1. Prédicats

### 1.1 Fluents

Les fluents sont tous les prédicats dont l'état est ammené à **changer**
- `hit(n) # Nombre de coups`
- `player(x,y) # Coordoonée du joueur`
- `monster(x,y) # Coordoonée d'un monstre`
- `rock(x,y) # Coordoonées d'un rocher`
- `unsafeTrap(x,y) # Coordoonée d'un piège unsafe`
- `safeTrap(x,y) # Coordoonée d'un piège safe`
- `spike(x,y) # Coordoonée de pics`
- `key(x,y) # Position d'une clé`
- `nbKey(x) # Nombre de clés`
- `lock(x,y) # Position d'un lock`

### 1.2 Non fluents

- `wall(x,y) # Coordonnée d'un mur`
- `case(x,y) # Coordonnées d'une case (nécessaire?)`
- `goal(x,y) # Coordoonée de la sortie`
- `trap(x,y) # Position d'un piège`
- `plusOne(x,y) # y = x + 1`

## 2. Init

On définit les coordoonées de tous les fluents et non fluents comme indiqué dans le niveau étudié.

On définit aussi toute la suite d'entier nécessaire pour plusUn *(ex : plusOne(1,2), plusOne(2,3), ..., plusOne(n - 1, n))*

## 3. But

- `but = player(x + 1, y) and goal(x,y)`
- `but = player(x - 1, y) and goal(x,y)`
- `but = player(x, y + 1) and goal(x,y)`
- `but = player(x, y - 1) and goal(x,y)`


## 4. Actions
```python
# Action to clean up mob on traps
Action(
    CleanMob(x, y),
    PRECOND : 
        monster(x, y) and (unsafeTrap(x, y) or spike(x, y))
    ,
    EFFECT : 
        not monster(x, y)
)

# Simple actions of moving (nothing else)
# Moving up
Action(
    MoveUp(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(y,z) and case(x, z) and not wall(x, z) and not rock(x, z) and not unsafeTrap(x, z) and not safeTrap(x, z) and not spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z) and not monster(x, z)
    ,
    EFFECT : 
        # Moving the player
        plusOne(y, z) and player(x, z) and not player(x, y) 
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving right
Action(
    MoveRight(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(x, z) and case(z, y) and not wall(z, y) and not rock(z, y) and not unsafeTrap(z, y) and not safeTrap(z, y) and not spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y) and not monster(z, y)
    ,
    EFFECT : 
        # Moving the player
        plusOne(x, z) and player(z, y) and not player(x, y) 
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving down
Action(
    MoveUp(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, y) and case(x, z) and not wall(x, z) and not rock(x, z) and not unsafeTrap(x, z) and not safeTrap(x, z) and not spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z) and not monster(x, z)
    ,
    EFFECT : 
        # Moving the player
        plusOne(z, y) and player(x, z) and not player(x, y) 
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving left
Action(
    MoveRight(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, x) and case(z, y) and not wall(z, y) and not rock(z, y) and not unsafeTrap(z, y) and not safeTrap(z, y) and not spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y) and not monster(z, y)
    ,
    EFFECT : 
        # Moving the player
        plusOne(z, x) and player(z, y) and not player(x, y) 
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )

# Simple action of moving on a spike
# Moving up
Action(
    MoveSpikeUp(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(y,z) and case(x, z) and not wall(x, z) and not rock(x, z) and not unsafeTrap(x, z) and not safeTrap(x, z) and spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z) and not monster(x, z)
    ,
    EFFECT : 
        # Moving the player
        plusOne(y, z) and player(x, z) and not player(x, y) 
        # Removing two hit
        and plusOne(m, n) and plusOne (l, m) and hit(l) and not hit(n)
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving right
Action(
    MoveSpikeRight(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(x, z) and case(z, y) and not wall(z, y) and not rock(z, y) and not unsafeTrap(z, y) and not safeTrap(z, y) and spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y) and not monster(z, y)
    ,
    EFFECT : 
        # Moving the player
        plusOne(x, z) and player(z, y) and not player(x, y) 
        # Removing two hit
        and plusOne(m, n) and plusOne (l, m) and hit(l) and not hit(n)
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving down
Action(
    MoveSpikeDown(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, y) and case(x, z) and not wall(x, z) and not rock(x, z) and not unsafeTrap(x, z) and not safeTrap(x, z) and spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z) and not monster(x, z)
    ,
    EFFECT : 
        # Moving the player
        plusOne(z, y) and player(x, z) and not player(x, y) 
        # Removing two hit
        and plusOne(m, n) and plusOne (l, m) and hit(l) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving left
Action(
    MoveSpikeLeft(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, x) and case(z, y) and not wall(z, y) and not rock(z, y) and not unsafeTrap(z, y) and not safeTrap(z, y) and spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y) and not monster(z, y)
    ,
    EFFECT : 
        # Moving the player
        plusOne(z, x) and player(z, y) and not player(x, y) 
        # Removing two hit
        and plusOne(m, n) and plusOne (l, m) and hit(l) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )

# Simple action of moving on an unsafeTrap
# Moving up
Action(
    MoveUnsafeUp(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(y,z) and case(x, z) and not wall(x, z) and not rock(x, z) and unsafeTrap(x, z) and not safeTrap(x, z) and not spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z) and not monster(x, z)
    ,
    EFFECT : 
        # Moving the player
        plusOne(y, z) and player(x, z) and not player(x, y) 
        # Removing a hit (since traps are going to be swapped)
        and plusOne(m, n) and hit(m) and not hit(n)
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving right
Action(
    MoveUnsafeRight(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(x, z) and case(z, y) and not wall(z, y) and not rock(z, y) and unsafeTrap(z, y) and not safeTrap(z, y) and not spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y) and not monster(z, y)
    ,
    EFFECT : 
        # Moving the player
        plusOne(x, z) and player(z, y) and not player(x, y) 
        # Removing a hit (since traps are going to be swapped)
        and plusOne(m, n) and hit(m) and not hit(n)
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving down
Action(
    MoveUnsafeDown(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, y) and case(x, z) and not wall(x, z) and not rock(x, z) and unsafeTrap(x, z) and not safeTrap(x, z) and not not spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z) and not monster(x, z)
    ,
    EFFECT : 
        # Moving the player
        plusOne(z, y) and player(x, z) and not player(x, y) 
        # Removing a hit (since traps are going to be swapped)
        and plusOne(m, n) and hit(m) and not hit(n)
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving left
Action(
    MoveUnsafeLeft(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, x) and case(z, y) and not wall(z, y) and not rock(z, y) and unsafeTrap(z, y) and not safeTrap(z, y) and not spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y) and not monster(z, y)
    ,
    EFFECT : 
        # Moving the player
        plusOne(z, x) and player(z, y) and not player(x, y) 
        # Removing a hit (since traps are going to be swapped)
        and plusOne(m, n) and hit(m) and not hit(n)
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )

# Simple action of moving on a safeTrap
# Moving up
Action(
    MoveSafeUp(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(y,z) and case(x, z) and not wall(x, z) and not rock(x, z) and not unsafeTrap(x, z) and safeTrap(x, z) and not spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z) and not monster(x, z)
    ,
    EFFECT : 
        # Moving the player
        plusOne(y, z) and player(x, z) and not player(x, y) 
        # Removing two hit (since traps are going to be swapped)
        and plusOne(m, n) and plusOne (l, m) and hit(l) and not hit(n)
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving right
Action(
    MoveSafeRight(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(x, z) and case(z, y) and not wall(z, y) and not rock(z, y) and not unsafeTrap(z, y) and safeTrap(z, y) and not spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y) and not monster(z, y)
    ,
    EFFECT : 
        # Moving the player
        plusOne(x, z) and player(z, y) and not player(x, y) 
        # Removing two hit (since traps are going to be swapped)
        and plusOne(m, n) and plusOne (l, m) and hit(l) and not hit(n)
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving down
Action(
    MoveSafeDown(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, y) and case(x, z) and not wall(x, z) and not rock(x, z) and not unsafeTrap(x, z) and safeTrap(x, z) and not spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z) and not monster(x, z)
    ,
    EFFECT : 
        # Moving the player
        plusOne(z, y) and player(x, z) and not player(x, y) 
        # Removing two hit (since traps are going to be swapped)
        and plusOne(m, n) and plusOne (l, m) and hit(l) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving left
Action(
    MoveSafeLeft(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, x) and case(z, y) and not wall(z, y) and not rock(z, y) and not unsafeTrap(z, y) and safeTrap(z, y) and not spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y) and not monster(z, y)
    ,
    EFFECT : 
        # Moving the player
        plusOne(z, x) and player(z, y) and not player(x, y) 
        # Removing two hit (since traps are going to be swapped)
        and plusOne(m, n) and plusOne (l, m) and hit(l) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )

# Simple actions of moving on a key
# Moving up
Action(
    MoveKeyUp(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(y,z) and case(x, z) and not wall(x, z) and not rock(x, z) and not unsafeTrap(x, z) and not safeTrap(x, z) and not spike(x, z) and key(x, z) and not lock(x, z) and not trap(x, z)
        and nbKey(k) and not monster(x, z)
    ,
    EFFECT : 
        # Moving the player
        plusOne(y, z) and player(x, z) and not player(x, y) 
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n)
        # Adding a key and removing the key
        plusOne(k, nk) and nbKey(nk) and not nbKey(k)
        # Removing the key on the map
        and not key(x, z)
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving right
Action(
    MoveKeyRight(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(x, z) and case(z, y) and not wall(z, y) and not rock(z, y) and not unsafeTrap(z, y) and not safeTrap(z, y) and not spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y) and nbKey(k) and not monster(z, y)
    ,
    EFFECT : 
        # Moving the player
        plusOne(x, z) and player(z, y) and not player(x, y) 
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n)
        # Adding a key and removing the key
        plusOne(k, nk) and nbKey(nk) and not nbKey(k)
        # Removing the key on the map
        and not key(z, y) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving down
Action(
    MoveKeyUp(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, y) and case(x, z) and not wall(x, z) and not rock(x, z) and not unsafeTrap(x, z) and not safeTrap(x, z) and not spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z) and nbKey(k) and not monster(x, z)
    ,
    EFFECT : 
        # Moving the player
        plusOne(z, y) and player(x, z) and not player(x, y) 
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n)
        # Adding a key and removing the key
        plusOne(k, nk) and nbKey(nk) and not nbKey(k)
        # Removing the key on the map
        and not key(x, z) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving left
Action(
    MoveKeyLeft(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, x) and case(z, y) and not wall(z, y) and not rock(z, y) and not unsafeTrap(z, y) and not safeTrap(z, y) and not spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y) and nbKey(k) and not monster(z, y)
    ,
    EFFECT : 
        # Moving the player
        plusOne(z, x) and player(z, y) and not player(x, y) 
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Adding a key and removing the key
        plusOne(k, nk) and nbKey(nk) and not nbKey(k)
        # Removing the key on the map
        and not key(z, y)
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )

# Simple actions of moving on a lock
# Moving up
Action(
    MoveLockDown(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(y,z) and case(x, z) and not wall(x, z) and not rock(x, z) and not unsafeTrap(x, z) and not safeTrap(x, z) and not spike(x, z) and not key(x, z) and lock(x, z) and not trap(x, z) and nbKey(k) and not monster(x, z)
    ,
    EFFECT : 
        # Moving the player
        plusOne(y, z) and player(x, z) and not player(x, y) 
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Removing a key
        plusOne(nk, k) and nbKey(nk) and not nbKey(k)
        # Removing the lock on the map
        and not lock(x, z)
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving right
Action(
    MoveLockRight(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(x, z) and case(z, y) and not wall(z, y) and not rock(z, y) and not unsafeTrap(z, y) and not safeTrap(z, y) and not spike(z, y) and not key(z, y) and lock(z, y) and not trap(z, y) and nbKey(k) and not monster(z, y)
    ,
    EFFECT : 
        # Moving the player
        plusOne(x, z) and player(z, y) and not player(x, y) 
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Removing a key
        plusOne(nk, k) and nbKey(nk) and not nbKey(k)
        # Removing the lock on the map
        and not lock(z, y)
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving down
Action(
    MoveLockDown(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, y) and case(x, z) and not wall(x, z) and not rock(x, z) and not unsafeTrap(x, z) and not safeTrap(x, z) and not spike(x, z) and not key(x, z) and lock(x, z) and not trap(x, z) and nbKey(k) and not monster(x, z)
    ,
    EFFECT : 
        # Moving the player
        plusOne(z, y) and player(x, z) and not player(x, y) 
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Removing a key
        plusOne(nk, k) and nbKey(nk) and not nbKey(k)
        # Removing the lock on the map
        and not lock(x, z)
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Moving left
Action(
    MoveLockLeft(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, x) and case(z, y) and not wall(z, y) and not rock(z, y) and not unsafeTrap(z, y) and not safeTrap(z, y) and not spike(z, y) and not key(z, y) and lock(z, y) and not trap(z, y) and nbKey(k) and not monster(z, y)
    ,
    EFFECT : 
        # Moving the player
        plusOne(z, x) and player(z, y) and not player(x, y) 
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Removing a key
        plusOne(nk, k) and nbKey(nk) and not nbKey(k)
        # Removing the lock on the map
        and not lock(z, y)
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )

# Simple actions of hitting a block (no pushing)
# Hitting up
Action(
    HitRockUp(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(y,z) and case(x, z) and not wall(x, z) 
        # Checking if something is behind
        and rock(x, z) and plusOne(z, w) and (wall(x, w) or monster(x, w) or rock (x, w) or lock(x, w) or goal(x, w))
        and not unsafeTrap(x, z) and not safeTrap(x, z) and not spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z) and not monster(x, z)
    ,
    EFFECT : 
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Hitting right
Action(
    HitRockRight(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(x, z) and case(z, y) and not wall(z, y)
        # Checking if something is behind
        and rock(z, y) and plusOne(z, w) and (wall(w, y) or monster(w, y) or rock(w, y) lock(w, y) or goal(w, y))
        and not unsafeTrap(z, y) and not safeTrap(z, y) and not spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y) and not monster(z, y)
    ,
    EFFECT : 
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Hitting down
Action(
    HitRockDown(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, y) and case(x, z) and not wall(x, z)
        # Checking if something is behind
        and rock(x, z) and plusOne(w, z) and (wall(x, w) or monster(x, w) or rock(x, w) or lock(x, w) or goal(x, w))
        and not unsafeTrap(x, z) and not safeTrap(x, z) and not spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z) and not monster(x, z)
    ,
    EFFECT : 
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Hitting left
Action(
    HitRockLeft(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, x) and case(z, y) and not wall(z, y)
        # Checking if something is behind
        and rock(z, y) and plusOne(w, z) and (wall(w, y) or monster(w, y) or rock(w, y) or lock(w, y) or goal(w, y))
        and not unsafeTrap(z, y) and not safeTrap(z, y) and not spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y) and not monster(z, y)
    ,
    EFFECT : 
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )

# Simple actions of pushing a block
# Push up
Action(
    PushRockUp(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(y,z) and case(x, z) and not wall(x, z) 
        # Checking if something is not behind
        and rock(x, z) and plusOne(z, w) and (not wall(x, w) and not monster(x, w) and not rock(x, w) and not lock(x, w) and not goal(x, w))
        and not unsafeTrap(x, z) and not safeTrap(x, z) and not spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z) and not monster(x, z)
    ,
    EFFECT : 
        # Moving the rock
        plusOne(y, z) and plusOne(z, w) and not rock(x, z) and rock(x, w)
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Push right
Action(
    PushRockRight(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(x, z) and case(z, y) and not wall(z, y)
        # Checking if something is not behind
        and rock(z, y) and plusOne(z, w) and (not wall(w, y) and not monster(w, y) and not rock(w, y) and not lock(w, y) and not goal(w, y))
        and not unsafeTrap(z, y) and not safeTrap(z, y) and not spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y) and not monster(z, y)
    ,
    EFFECT : 
        # Moving the rock
        plusOne(x, z) and plusOne(z, w) and not rock(z, y) and rock(w, y)
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Push down
Action(
    PushRockDown(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, y) and case(x, z) and not wall(x, z)
        # Checking if something is not behind
        and rock(x, z) and plusOne(w, z) and (not wall(x, w) and not monster(x, w) and not rock(x, w) and not lock(x, w) and not goal(x, w))
        and not unsafeTrap(x, z) and not safeTrap(x, z) and not spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z) and not monster(x, z)
    ,
    EFFECT : 
        # Moving the rock
        plusOne(z, y) and plusOne(w, z) and not rock(x, z) and rock(x, w)
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Push left
Action(
    PushRockLeft(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, x) and case(z, y) and not wall(z, y)
        # Checking if something is not behind
        and rock(z, y) and plusOne(w, z) and (not wall(w, y) and not monster(w, y) and not rock(w, y) and not lock(w, y) and not goal(w, y))
        and not unsafeTrap(z, y) and not safeTrap(z, y) and not spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y) and not monster(z, y)
    ,
    EFFECT : 
        # Moving the rock
        plusOne(z, x) and plusOne(w, z) and not rock(z, y) and rock(w, y)
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )

# Simple actions of killing a mob
# Killing up
Action(
    KillMobUp(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(y,z) and case(x, z) and not wall(x, z) and not rock(x, z)
        # Checking if something is behind
        and monster(x, z) and plusOne(z, w) and (wall(x, w) or or rock(x, w) or lock(x, w))
        and not unsafeTrap(x, z) and not safeTrap(x, z) and not spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z)
    ,
    EFFECT : 
        # Removing the mob
        not monster(x, z)
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Killing right
Action(
    KillMobRight(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(x, z) and case(z, y) and not wall(z, y) and not rock(z, y)
        # Checking if something is behind
        and monster(z, y) and plusOne(z, w) and (wall(w, y) or block (w, y) or lock(w, y))
        and not unsafeTrap(z, y) and not safeTrap(z, y) and not spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y)
    ,
    EFFECT : 
        # Removing the mob
        not monster(w, y)
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Killing down
Action(
    KillMobDown(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, y) and case(x, z) and not wall(x, z) and not rock(x, z)
        # Checking if something is behind
        and monster(x, z) and plusOne(w, z) and (wall(x, w) or block(x, w) or lock(x, w))
        and not unsafeTrap(x, z) and not safeTrap(x, z) and not spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z)
    ,
    EFFECT : 
        # Removing the mob
        not monster(x, z)
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Killing left
Action(
    KillMobLeft(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, x) and case(z, y) and not wall(z, y) and not rock(z, y)
        # Checking if something is behind
        and monster(z, y) and plusOne(w, z) and (wall(w, y) or block(w, y) or lock(w, y))
        and not unsafeTrap(z, y) and not safeTrap(z, y) and not spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y)
    ,
    EFFECT : 
        # Removing the mob
        not monster(z, y)
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )

# Simple actions of pushing a monster
# Push up
Action(
    PushMonsterUp(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(y,z) and case(x, z) and not wall(x, z) and not rock(x, z)
        # Checking if something is not behind
        and monster(x, z) and plusOne(z, w) and (not wall(x, w) and not monster(x, w) and not rock(x, w) and not lock(x, w) and not goal(x, w))
        and not unsafeTrap(x, z) and not safeTrap(x, z) and not spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z)
    ,
    EFFECT : 
        # Moving the mob
        plusOne(y, z) and plusOne(z, w) and not monster(x, z) and monster(x, w)
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Push right
Action(
    PushMobRight(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(x, z) and case(z, y) and not wall(z, y) and not rock(z, y)
        # Checking if something is not behind
        and monster(z, y) and plusOne(z, w) and (not wall(w, y) and not monster(w, y) and not rock(w, y) and not lock(w, y) and not goal(w, y))
        and not unsafeTrap(z, y) and not safeTrap(z, y) and not spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y)
    ,
    EFFECT : 
        # Moving the mob
        plusOne(x, z) and plusOne(z, w) and not monster(z, y) and monster(w, y)
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Push down
Action(
    PushMobDown(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, y) and case(x, z) and not wall(x, z) and not rock(x, z)
        # Checking if something is not behind
        and monster(x, z) and plusOne(w, z) and (not wall(x, w) and not monster(x, w) and not rock(x, w) and not lock(x, w) and not goal(x, w))
        and not unsafeTrap(x, z) and not safeTrap(x, z) and not spike(x, z) and not key(x, z) and not lock(x, z) and not trap(x, z)
    ,
    EFFECT : 
        # Moving the mob
        plusOne(z, y) and plusOne(w, z) and not monster(x, z) and monster(x, w)
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
# Push left
Action(
    PushRockLeft(x, y, n),
    PRECOND : 
        player(x,y) and plusOne(z, x) and case(z, y) and not wall(z, y) and not rock(z, y)
        # Checking if something is not behind
        and monster(z, y) and plusOne(w, z) and (not wall(w, y) and not monster(w, y) and not rock(w, y) and not lock(w, y) and not goal(w, y))
        and not unsafeTrap(z, y) and not safeTrap(z, y) and not spike(z, y) and not key(z, y) and not lock(z, y) and not trap(z, y)
    ,
    EFFECT : 
        # Moving the mob
        plusOne(z, x) and plusOne(w, z) and not monster(z, y) and monster(w, y)
        # Removing a hit
        and plusOne(m, n) and hit(m) and not hit(n) 
        # Swapping safe and unsafe
        and safeTrap(a, b) => (not safeTrap(a, b) and unsafeTrap(a, b))
        # Swapping unsafe and safe
        and unsafeTrap(a, b) => (not unsafeTrap(a, b) and safeTrap(a, b))
        # Not sure if authorized but call action to clean every mob on traps
        CleanMob(u, v)
    )
```

## 5. Sauvegarde d'états

On sauvegarde **tous** les fluents à chaque état