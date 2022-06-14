
import sys, os
sys.path.append(os.path.join(sys.path[0],'..','python'))
from helltaker_utils import grid_from_file

def level2ASP(file: str):
    var = grid_from_file(file)
    print(var)

    f = open("test.txt", "w")

    tab = var["grid"]

    types = [' ', '#', 'H', 'S', 'D', 'B', 'K', 'L', 'M', 'T', 'U']

    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == ' ':
                    tmp = "case(%s,%s).\n" % (i, j)
                    f.write(tmp)
                if k == tab[i][j] == 'S':
                    tmp = "spike(%s,%s).\n" % (i, j)
                    f.write(tmp)
                if k == tab[i][j] == 'D':
                    tmp = "goal(player(%s,%s)).\n" % (i, j)
                    f.write(tmp)
    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'H':
                    tmp = "init(player(%s,%s)).\n" %(i,j)
                    f.write(tmp)

    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'B':
                    tmp = "init(block(%s,%s)).\n" %(i,j)
                    f.write(tmp)

    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'K':
                    tmp = "init(key(%s,%s)).\n" %(i,j)
                    f.write(tmp)   


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'L':
                    tmp = "init(lock(%s,%s)).\n" %(i,j)
                    f.write(tmp)


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'M':
                    tmp = "init(mob(%s,%s)).\n" %(i,j)
                    f.write(tmp)


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'T':
                    tmp = "init(safe(%s,%s)).\n" %(i,j)
                    f.write(tmp)


    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'U':
                    tmp = "init(unsafe(%s,%s)).\n" %(i,j)
                    f.write(tmp)


    f.close()


level2ASP("levels/level1.txt")
