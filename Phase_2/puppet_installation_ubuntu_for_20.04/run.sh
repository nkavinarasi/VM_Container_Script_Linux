#!/bin/bash
currentpath=$(pwd)
sudo rm -rf *.log
echo inprogress > $currentpath/info.log
sudo chmod 775 $currentpath/src/ubuntu/ubuntu_20.sh > /dev/null
sudo bash ./src/ubuntu/ubuntu_20.sh> $currentpath/null.log 2>&1
sudo rm -rf  $currentpath/null.log
exit 0
