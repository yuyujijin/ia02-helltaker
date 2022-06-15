import sys
import os

from level2ASP import level2ASP

def parse(levelname):
    filename = levelname.split(os.sep)
    filename = filename[len(filename) - 1]
    filename = filename.split('.')[0]
    with open(filename + '.lp', "w") as f:
        s = level2ASP(levelname)
        print('s :',s)
        f.write(s)
        with open('newASP.lp', "r") as g:
            for line in g.readlines():
                f.write(line)

if __name__ == "__main__":
    levelname = sys.argv[1]

    parse(levelname)