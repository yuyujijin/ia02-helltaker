
import sys, os
sys.path.append(os.path.join(sys.path[0],'..','python'))
from helltaker_utils import grid_from_file

def level2ASP(file: str):
    var = grid_from_file(file)
    print(var)

    s = ""

    tab = var["grid"]

    types = [' ', '#', 'H', 'S', 'O', 'D', 'B', 'K', 'L', 'M', 'T', 'U']

    # Mettre des defined dans le fichier pour gérer les predicats non-définis/absents
    s += "#defined wall/2.\n#defined case/2.\n#defined spike/2.\n#defined wall/2.\n\n\n"
    s += "init(hasKey(0)).\n"

    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k==' ' and tab[i][j] != '#':
                    tmp = "case(%s,%s).\n" % (j, i)
                    s += tmp
                if k == tab[i][j] == '#':
                    tmp = "wall(%s,%s).\n" % (j, i)
                    s += tmp                    
                if k == tab[i][j] == 'S':
                    tmp = "spike(%s,%s).\n" % (j, i)
                    s += tmp
                if k == tab[i][j] == 'O':
                    tmp = "init(block(%s,%s)).\n" % (j, i)
                    s += tmp
                    tmp = "spike(%s,%s).\n" % (j, i)
                    s += tmp
                if k == tab[i][j] == 'D':
                    tmp = "goal(%s,%s).\n" % (j, i)
                    s += tmp


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'H':
                    tmp = "init(at(%s,%s)).\n" %(j,i)
                    s += tmp

    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'B':
                    tmp = "init(block(%s,%s)).\n" %(j,i)
                    s += tmp

    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'K':
                    tmp = "init(key(%s,%s)).\n" %(j,i)
                    s += tmp   


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'L':
                    tmp = "init(lock(%s,%s)).\n" %(j,i)
                    s += tmp


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'M':
                    tmp = "init(mob(%s,%s)).\n" %(j,i)
                    s += tmp


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'T':
                    tmp = "trap(pos(%s,%s),on,0).\n" %(j,i)
                    s += tmp


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'U':
                    tmp = "trap(pos(%s,%s),off,0).\n" %(j,i)
                    s += tmp


    return s