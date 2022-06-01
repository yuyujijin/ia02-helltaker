# Représentation STRIPS

0. [Règles du jeu](#0-règles-du-jeu)
1. [Prédicats](#1-prédicats)
    1. [Fluents](#11-fluents)
    2. [Non fluents](#12-non-fluents)
2. [Init](#2-init)
3. [But](#3-but)
4. [Actions](#4-actions)
5. [Sauvegarde d'états](#5-sauvegarde-détats)

## 0. Règles du jeu

- Les niveaux sont composées de case et de mur
- On part d'une case donnée
- On doit atteindre un but
- On a un nombre de coup donné au départ
- Le but doit être atteint avec un nombre de coups >= 0
- Chaque déplacement consomme un coup
- Dans chaque niveau il peut y a voir : **des monstres**, **des rochers**, **des pièges**, **des clés** et **des locks**
- Les monstres peuvent être poussés (cela consomme une action). Si un monstre est poussé contre un mur il disparait
- Les rochers peuvent être poussés (cela consomme une action)
- Les pièges peuvent être dans deux états : **on** et **off**. Chaque action inverse l'état de tous les pièges. Marcher sur un piège **on** coûte un nombre de coup (en plus du déplacement).
- Les clés peuvent êtres récupérées
- Les locks peuvent êtres ouverts (cela consomme une action)

## 1. Prédicats

### 1.1 Fluents

Les fluents sont tous les prédicats dont l'état est ammené à **changer**
- `hit(n) # Nombre de coups`
- `player(x,y) # Coordoonée du joueur`
- `monster(x,y) # Coordoonée d'un monstre`
- `rock(x,y) # Coordoonées d'un rocher`
- `trapActivated(p) # Etat des pièges`
- `key(x,y) # Position d'une clé`
- `lock(x,y) # Position d'un lock`

### 1.2 Non fluents

- `wall(x,y) # Coordonnée d'un mur`
- `case(x,y) # Coordonnées d'une case (nécessaire?)`
- `goal(x,y) # Coordoonée de la sortie`
- `trap(x,y) # Position d'un piège`


## 2. Init

- `player(X,Y) # Dépend du niveau`

## 3. But

- `but = player(x,y) and goal(x,y)`

## 4. Actions
```
Action(hit(),
PRECOND : ,
EFFECT : )
```

## 5. Sauvegarde d'états

On sauvegarde **tous** les fluents à chaque état