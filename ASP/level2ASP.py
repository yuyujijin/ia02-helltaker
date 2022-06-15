
import sys, os
sys.path.append(os.path.join(sys.path[0],'..','python'))
from helltaker_utils import grid_from_file

def level2ASP(file: str):
    var = grid_from_file(file)
    print(var)

    s = ""

    tab = var["grid"]

    types = [' ', '#', 'H', 'S', 'O', 'D', 'B', 'K', 'L', 'M', 'T', 'U', 'P', 'Q']

    # Mettre des defined dans le fichier pour gérer les predicats non-définis/absents
    s += "#defined wall/2.\n#defined case/2.\n#defined spike/2.\n#defined wall/2.\n#defined trap/4.\n\n\n"
    s += "init(hasKey(0)).\n"

    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k==' ' and tab[i][j] != '#':
                    tmp = "case(%s,%s).\n" % (i, j)
                    s += tmp
                if k == tab[i][j] == '#':
                    tmp = "wall(%s,%s).\n" % (i, j)
                    s += tmp                    
                if k == tab[i][j] == 'S':
                    tmp = "spike(%s,%s).\n" % (i, j)
                    s += tmp
                if k == tab[i][j] == 'O':
                    tmp = "init(block(%s,%s)).\n" % (i, j)
                    s += tmp
                    tmp = "spike(%s,%s).\n" % (i, j)
                    s += tmp
                if k == tab[i][j] == 'D':
                    tmp = "demoness(%s,%s).\n" % (i, j)
                    s += tmp
                    s += "goal(at(%s,%s)).\n" % (i, j+1)
                    s += "goal(at(%s,%s)).\n" % (i, j-1)
                    s += "goal(at(%s,%s)).\n" % (i+1, j)
                    s += "goal(at(%s,%s)).\n" % (i-1, j)


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'H':
                    tmp = "init(at(%s,%s)).\n" %(i, j)
                    s += tmp

    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'B':
                    tmp = "init(block(%s,%s)).\n" %(i, j)
                    s += tmp

    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'K':
                    tmp = "init(key(%s,%s)).\n" %(i, j)
                    s += tmp   


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'L':
                    tmp = "init(lock(%s,%s)).\n" %(i, j)
                    s += tmp


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'M':
                    tmp = "init(mob(%s,%s)).\n" %(i, j)
                    s += tmp


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'T':
                    tmp = "{trap(%s, %s, S, T) : state_trap(S)} = 1 :- step(T). :- trap(%s, %s, S, 0), S != on.\n"%(i, j, i, j)
                    s += tmp


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'U':
                    tmp = "{trap(%s, %s, S, T) : state_trap(S)} = 1 :- step(T). :- trap(%s, %s, S, 0), S != on.\n"%(i, j, i, j)
                    s += tmp


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'O':
                    tmp = "spike(%s,%s).\ninit(block(%s,%s)).\n"%(i, j, i, j)
                    s += tmp        


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'P':
                    tmp = "{trap(%s, %s, S, T) : state_trap(S)} = 1 :- step(T). :- trap(%s, %s, S, 0), S != on.\ninit(block(%s,%s)).\n"%(i, j, i, j, i, j)
                    s += tmp           


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'Q':
                    tmp = "{trap(%s, %s, S, T) : state_trap(S)} = 1 :- step(T). :- trap(%s, %s, S, 0), S != off.\ninit(block(%s,%s)).\n"%(i, j, i, j, i, j)
                    s += tmp                                



    return s


    level2ASP("ia02-helltaker\levels\level6.txt")