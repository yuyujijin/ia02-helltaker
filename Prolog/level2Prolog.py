
import sys, os
sys.path.append(os.path.join(sys.path[0],'..','python'))
from helltaker_utils import grid_from_file

def level2Prolog(file: str):
    var = grid_from_file(file)
    print(var)

    f = open("test.txt", "w")

    tab = var["grid"]

    types = [' ', '#', 'H', 'D', 'B', 'K', 'L', 'M', 'S', 'T', 'U']

    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == ' ':
                    tmp = "case(pos(%s,%s)).\n" % (i, j)
                    f.write(tmp)
                if k == tab[i][j] == '#':
                    tmp = "wall(pos(%s,%s)).\n" % (i, j)
                    f.write(tmp)
                if k == tab[i][j] == 'S':
                    tmp = "spike(pos(%s,%s)).\n" % (i, j)
                    f.write(tmp)
                if k == tab[i][j] == 'D':
                    tmp = "goal(pos(%s,%s)).\n" % (i, j)
                    f.write(tmp)
    f.write("start(state(")
    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'H':
                    tmp = "\n\tplayer(pos(%s,%s))" %(i,j)
                    f.write(tmp)
    f.write(",")

    f.write("\n\trock([")
    check = 1
    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'B':
                    if check == 1:
                        tmp = "pos(%s,%s)" %(i,j)
                        f.write(tmp)
                        check=0
                    else:
                        tmp = ",pos(%s,%s)" %(i,j)
                        f.write(tmp)
    f.write("]),")

    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'K':
                    tmp = "\n\tkey(pos(%s,%s))," %(i,j)
                    f.write(tmp)   

    f.write("\n\tlock([")
    check = 1
    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'L':
                    if check == 1:
                        tmp = "pos(%s,%s)" %(i,j)
                        f.write(tmp)
                        check=0
                    else:
                        tmp = ",pos(%s,%s)" %(i,j)
                        f.write(tmp)
    f.write("]),")

    f.write("\n\tmonster([")
    check = 1
    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'M':
                    if check == 1:
                        tmp = "pos(%s,%s)" %(i,j)
                        f.write(tmp)
                        check=0
                    else:
                        tmp = ",pos(%s,%s)" %(i,j)
                        f.write(tmp)
    f.write("]),")

    f.write("\n\tsafe([")
    check = 1
    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'T':
                    if check == 1:
                        tmp = "pos(%s,%s)" %(i,j)
                        f.write(tmp)
                        check=0
                    else:
                        tmp = ",pos(%s,%s)" %(i,j)
                        f.write(tmp)
    f.write("]),")

    f.write("\n\tunsafe([")
    check = 1
    for k in types:
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'U':
                    if check == 1:
                        tmp = "pos(%s,%s)" %(i,j)
                        f.write(tmp)
                        check=0
                    else:
                        tmp = ",pos(%s,%s)" %(i,j)
                        f.write(tmp)
    f.write("])")

    f.write("\n)).")

    f.close()


level2Prolog("levels/level4.txt")
