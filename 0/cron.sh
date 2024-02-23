#!/bin/bash



# Nastavitev cron da preveri vsako uro pool
(crontab -l ; echo "0 * * * * /pot/do/poolupdate.sh") | crontab -
