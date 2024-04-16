#!/bin/bash

Green='\x1B[32m'      # zelena
Blue='\x1B[36m'       # modra
Magenta='\x1B[35m'    # vijolična
Red='\x1B[31m'        # rdeča
Yellow='\x1B[33m'     # rumena

iGreen='\x1B[1;32m'   # svetlo zelena
iBlue='\x1B[1;36m'    # svetlo modra
iMagenta='\x1B[1;35m' # svetlo vijolična
iRed='\x1B[1;31m'     # svetlo rdeča
iYellow='\x1B[1;33m'  # svetlo rumena

C_Off='\x1B[0m'       # izklopi obarvanje

./check-all-org | jq -c '.[] | [.PHONE,.HOST,.POOL,.KHS]' | sed \
-e "s/null/${Red}&${C_Off}/g" \
-e "s/mrr/${Green}&${C_Off}/g" \
-e "s/de.vipor.net/${Yellow}&${C_Off}/g" \
-e "s/luckpool/${Blue}&${C_Off}/g" \
-e "s/eu.cloudiko.io/${Magenta}&${C_Off}/g" \
-e "s/pool.verus.io/${Red}&${C_Off}/g" \
-e "s/zerg-solo/${Green}&${C_Off}/g" \
-e "s/ALL/${iRed}&${iRed}/g" \
-e "s/active/${iGreen}&${iGreen}/g" \
-e "s/VRSC_24h/${iYellow}&${iYellow}/g" \
-e "s/USDT_24h/${iBlue}&${iBlue}/g" \
-e "s/time/${iMagenta}&${iMagenta}/g" \
-e "s/]/${C_Off}&${C_Off}/g" \
 | column
