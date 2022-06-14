#!/bin/bash
echo $0
FILES="./levels";
bold=$(tput bold)
normal=$(tput sgr0)
green='\033[0;32m'
nc='\033[0m'

echo -n "${bold}### "
if [ $# -eq 0 ] ; then
    CMD="./solver.py --algorithm A* --heuristic manhattan_advanced"
    echo -n "No command given, using "
else
    CMD=$1
    echo -n 'Using '
fi
echo -e "$CMD${normal}\n"


for f in $(find $FILES -type f | sort)
do
    echo "# ${bold}Launching test on '$f'${normal}"
    res1=$(date +%s.%N)
    echo $($CMD --filename $f)
    res2=$(date +%s.%N)
    dt=$(echo "$res2 - $res1" | bc)
    echo -e "${green}Program executed in $dt seconds.${nc}\n"
done