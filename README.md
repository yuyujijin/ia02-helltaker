# Projet Helltaker

- [0. Rapport](#0-rapport)
- [1. Python](#1-python)
    - [1.1 Execution](#11-execution)
    - [1.2 Sortie](#12-sortie)

## 0. Rapport

Le rapport est disponible dans le fichier `rapport.pdf`. Il décrit le projet dans sa globalité.

## 1. Python
### 1.1 Execution

Le programme s'éxecute en lançant le fichier `solver.py` via `./solver.py` ou `python3 solver.py`. Il est nécessaire de préciser le fichier de niveau, via l'option `--filename`. Trois autres options optionnelles sont disponibles ; `--search`, `--verbose` et `--arrow`. 

Les options disponibles pour `--search` sont :
- `BFS` (Parcours en largeur) **[Défaut]**
- `DFS` (Parcours en profondeur)
- `A*` (Parcours A*). 
Des heuristiques sont disponibles pour `A*` via l'option `--heuristic` :
    - `manhattan` (Distance de Manhattan)
    - `manhattan_advanced` (Une version un peu modifié de la distance de Manhattan)
    - `euclidean` (Distance euclidienne) 

    Des fonctions `g` sont aussi disponibles pour le cacul des heuristiques via l'option `--g` :
    - `zero` (g = g + 0)
    - `incr` (g = g + 1)

`--arrow` permet de rendre la sortie en "format fleché".

Taper `--help` ou `-h` pour plus d'aide.

### 1.2 Sortie

Le programme rend sur la sortie standard une suite d'instruction pour résoudre le niveau donné en argument

### 1.3 Utilitaires

Un script `launchTest.sh` est disponible et executable via `./launchTest.sh` ou `bash launchTest.sh`. Il permet de lancer tous les fichiers récursivement dans `levels/` et indique le temps d'éxecution pour chacun et la solution (si elle existe). Le script execute les fichiers par défaut avec `A*`, **la distance d'euclide** et **g = g + 1**, mais il est possible de donner en argument une chaine de caractère indiquant la commande à executer *(ex : `bash launchTest.sh './solver.py --algorithm BFS'`)*.