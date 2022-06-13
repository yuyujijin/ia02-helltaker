import sys
sys.path.append('./python')
from helltaker_utils import *

def level2ASP(file :str):
    var = grid_from_file(file)
    print(var)

    f = open("test.txt", "a")

    tab=var["grid"]

    types = [' ','#','H','D','B','K','L','M','S','T','U']

    for k in types :
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == ' ':
                    tmp="case(pos(%s,%s)).\n" %(i,j)
                    f.write(tmp)
                if k == tab[i][j] == '#':
                    tmp="wall(pos(%s,%s)).\n" %(i,j)
                    f.write(tmp)
                if k == tab[i][j] == 'S':
                    tmp="spike(pos(%s,%s)).\n" %(i,j)
                    f.write(tmp)                    
                if k == tab[i][j] == 'D':
                    tmp="goal(pos(%s,%s)).\n" %(i,j)
                    f.write(tmp)
    f.write("state(")   
        for i in range(var["m"]):
            for j in range(var["n"]):
                if k == tab[i][j] == 'H':
                    print("player(",i,",",j,").")
                if k == tab[i][j] == 'B':
                    print("rock(",i,",",j,").")
                if k == tab[i][j] == 'K':
                    print("key(",i,",",j,").")
                if k == tab[i][j] == 'L':
                    print("lock(",i,",",j,").")
                if k == tab[i][j] == 'M':
                    print("monster(",i,",",j,").")
                if k == tab[i][j] == 'T':
                    print("safe(",i,",",j,").")                
                if k == tab[i][j] == 'U':
                    print("unsafe(",i,",",j,").")      
    f.close()

level2ASP("levels\level2.txt")