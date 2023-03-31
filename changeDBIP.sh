#!/bin/bash
IP=$1

sudo sed -i "s/ipvar/$IP/" DBRestoreDump.sh
sudo sed -i "s/ipvar/$IP/" DBCreateDump.sh
