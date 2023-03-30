#!/bin/bash
IP=$1

sudo sed -i "s/ipvar/$IP/" DBRestoreDumb.sh
sudo sed -i "s/ipvar/$IP/" DBCreateDumb.sh
sudo sed -i "s/ipvar/$IP/" initDB.sh