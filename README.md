# Projet Helltaker

- [1. Python](#1-python)
    - [1.1 Execution](#11-execution)
    - [1.2 Sortie](#12-sortie)

## 1. Python
### 1.1 Execution

Le programme s'éxecute en lançant le fichier `solver.py` via `./solver.py` ou `python3 solver.py`. Il est nécessaire de préciser le fichier de niveau, via l'option `--filename`. Trois autres options optionnelles sont disponibles ; `--search`, `--verbose` et `--arrow`. 

Les options disponibles pour `--search` sont :
- `BFS` (Parcours en largeur) **[Défaut]**
- `DFS` (Parcours en profondeur)

`--arrow` permet de rendre la sortie en "format fleché".

Taper `--help` ou `-h` pour plus d'aide.

### 1.2 Sortie

Le programme rend sur la sortie standard une suite d'instruction pour résoudre le niveau donné en argument