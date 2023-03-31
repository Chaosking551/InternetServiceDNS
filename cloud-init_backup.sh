#!/bin/bash
sudo apt-get update
echo "y" |sudo apt install mysql-server 

cd /home/ubuntu

wget https://raw.githubusercontent.com/Chaosking551/InternetServiceDNS/main/DBCreateDump.sh
wget https://raw.githubusercontent.com/Chaosking551/InternetServiceDNS/main/DBRestoreDump.sh
wget https://raw.githubusercontent.com/Chaosking551/InternetServiceDNS/main/changeDBIP.sh

sudo chmod 777 /home/ubuntu/DBCreateDump.sh
sudo chmod 777 /home/ubuntu/DBRestoreDump.sh
sudo chmod 777 /home/ubuntu/changeDBIP.sh

wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.5.0.linux-amd64.tar.gz
cd node_exporter-1.5.0.linux-amd64
./node_exporter


wget https://github.com/prometheus/prometheus/releases/download/v2.43.0/prometheus-2.43.0.linux-amd64.tar.gz
tar xvfz prometheus-2.43.0.linux-amd64.tar.gz
cd prometheus-2.43.0.linux-amd64
rm prometheus.yml
wget https://raw.githubusercontent.com/Chaosking551/InternetServiceDNS/main/prometheus.yml
//Put prometheus.yml into the prometheus-2.43.0.linux-amd64 folder
./prometheus --config.file=prometheus.yml

crontab -l > fiveDayBackup
echo "59 23 */5 * * /home/ubuntu/DBCreateDump.sh > /dev/null 2>&1" >> fiveDayBackup
crontab fiveDayBackup