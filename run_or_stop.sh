#!/bin/bash

# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <action>"
    exit 1
fi

# Extract the direction parameter
action="$1"

# Perform actions based on the provided direction
case "$action" in
    "run")
        echo "Starting containers"
        docker-compose up -d --build
        ;;
    "stop")
        echo "Stopping containers"
        docker-compose down
        ;;
    *)
        echo "Invalid action. Please specify 'run' or 'stop'."
        exit 1
        ;;
esac
exit 0