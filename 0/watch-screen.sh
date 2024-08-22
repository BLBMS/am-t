  GNU nano 6.2                                                                                                                     watch-screen.sh *                                                                                                                            #!/bin/bash
# v.2024-08-22

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
iWhite='\x1B[1;37m'   # svetlo bela

C_Off='\x1B[0m'       # izklopi obarvanje

./check-all.sh | jq -c '.[] | [.PHONE,.HOST,.POOL,.MHS]' | sed \
-e "s/null/${Red}&${C_Off}/g" \
-e "s/\"0\./${Red}&${Red}/g" \
-e "s/\"1\./${iRed}&${iRed}/g" \
-e "s/\"2\./${iYellow}&${iYellow}/g" \
-e "s/mrr/${Green}&${C_Off}/g" \
-e "s/vipor_/${Yellow}&${C_Off}/g" \
-e "s/luckpool/${Blue}&${C_Off}/g" \
-e "s/eu.cloudiko.io/${Magenta}&${C_Off}/g" \
-e "s/pool.verus.io/${Red}&${C_Off}/g" \
-e "s/zerg-solo/${Green}&${C_Off}/g" \
-e "s/all/${iRed}&${iRed}/g" \
-e "s/active/${iGreen}&${iGreen}/g" \
-e "s/VRSC\/day/${iBlue}&${iBlue}/g" \
-e "s/USDT\/day/${iWhite}&${iWhite}/g" \
-e "s/time/${iMagenta}&${iMagenta}/g" \
-e "s/missing/${iYellow}&${iYellow}/g" \
-e "s/NOT ON LIST/${iRed}&${C_Off}/g" \
-e "s/OFF LINE/${Red}&${C_Off}/g" \
-e "s/]/${C_Off}&${C_Off}/g" \
 | column
