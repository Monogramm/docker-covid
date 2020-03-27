#!/bin/sh

set -e

echo "Waiting to ensure everything is fully ready for the tests..."
sleep 60

echo "Checking main containers are reachable..."
if ! ping -c 10 -q covid-db ; then
    echo 'Covid Database container is not responding!'
    # TODO Display logs to help bug fixing
    #echo 'Check the following logs for details:'
    #tail -n 100 logs/*.log
    exit 2
fi

if ! ping -c 10 -q covid ; then
    echo 'Covid Main container is not responding!'
    # TODO Display logs to help bug fixing
    #echo 'Check the following logs for details:'
    #tail -n 100 logs/*.log
    exit 4
fi

# Add your own tests
# https://docs.docker.com/docker-hub/builds/automated-testing/
echo "Executing Covid app tests..."
wget https://covid:3000/admin/ --no-check-certificate
cat index.html

# Success
echo 'Docker tests successful'
exit 0
