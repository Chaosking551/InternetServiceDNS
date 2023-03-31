#!/bin/bash
IP=$1

sudo sed -i "s/ipvar/$IP/" DBRestoreDump.sh
sudo sed -i "s/ipvar/$IP/" DBCreateDump.sh

crontab -l > fiveDayBackup
echo "59 23 */5 * * /home/ubuntu/DBCreateDump.sh > /dev/null 2>&1" >> fiveDayBackup
crontab fiveDayBackup