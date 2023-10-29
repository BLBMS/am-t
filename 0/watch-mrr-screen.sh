#!/bin/bash

Green='\x1B[32m'   # zelena
Blue='\x1B[36m'    # modra
Magenta='\x1B[35m' # vijolična
Red='\x1B[31m'     # rdeča
Yellow='\x1B[33m'  # rumena
C_Off='\x1B[0m'    # izklopi obarvanje

./check-all-org | jq -c '.[] | [.PHONE,.HOST,.POOL,.KHS]' | sed -e "s/null/${Red}&${C_Off}/g" -e "s/mrr/${Green}&${C_Off}/g" \
-e "s/active/${Blue}&${Blue}/g" -e "s/ALL/${Magenta}&${Magenta}/g" | column
