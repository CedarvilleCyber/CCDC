#!/bin/bash
# 
# do-linpeas.sh
# 
# Runs linpeas
# 
# Kaicheng Ye
# Feb. 2025

printf "${info}Starting do-linpeas script${reset}\n"

wget https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh
chmod 700 ./linpeas.sh

./linpeas.sh > lin-output.txt
chmod 0000 ./linpeas.sh

printf "\n\n\n"

cat lin-output.txt | grep -P "\x1B\[1;31;103m"

printf "\n\n"

printf "${info}Finished do-linpeas script${reset}\n"

exit 0
