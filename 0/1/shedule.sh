#!/bin/bash

# Function to start the miner
start_miner() {
    echo "Cleaning up existing screen sessions..."
    # Kill all existing screen sessions
    screen -ls | grep Detached | awk '{print $1}' | xargs -I {} screen -X -S {} quit
    screen -ls | grep Dead | awk '{print $1}' | xargs -I {} screen -wipe {}

    echo "Starting the miner..."
    ./ccminer/start.sh
}

# Function to stop the miner
stop_miner() {
    echo "Stopping the miner..."
    screen -X -S CCminer quit
}

# Infinite loop to run the miner in cycles
while true; do
    start_miner
    echo "Miner running for 3 hours..."
    sleep 3h  # Run miner for 3 hours

    stop_miner
    echo "Miner resting for 10 minutes..."
    sleep 10m  # Rest for 10 minutes
done


exit
________________
#!/bin/bash

# Function to start the miner
start_miner() {
    echo "Starting the miner..."
    ./ccminer/start.sh
}

# Function to stop the miner
stop_miner() {
    echo "Stopping the miner..."
    screen -X -S CCminer quit
}

# Infinite loop to run the miner in cycles
while true; do
    start_miner
    echo "Miner running for 3 hours..."
    sleep 3h  # Run miner for 3 hours

    stop_miner
    echo "Miner resting for 10 minutes..."
    sleep 10m  # Rest for 10 minutes
done
