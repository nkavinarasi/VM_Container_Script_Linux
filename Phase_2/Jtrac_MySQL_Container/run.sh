#!/bin/bash
currentpath=$(pwd)
echo inprogress>$currentpath/status.log
echo inprogress>$currentpath/info.log

sudo chmod 775 $currentpath/src/container_execution.sh > /dev/null
sudo ./src/container_execution.sh > $currentpath/null.log 2>&1
sudo rm -rf  $currentpath/null.log