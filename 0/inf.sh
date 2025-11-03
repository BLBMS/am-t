
free -h | grep Mem | awk '{print "Total: " $2 "  Used: " $3 "\n Free: " $4 "  Available: " $7}'
