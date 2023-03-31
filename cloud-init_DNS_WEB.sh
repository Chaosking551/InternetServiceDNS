#!/bin/bash

echo "start install and update" > /home/ubuntu/install_log.txt

echo | sudo add-apt-repository ppa:isc/bind
sudo apt-get update
echo "y" | sudo apt-get install bind9
sudo systemctl enable named

echo "configure bind" >> /home/ubuntu/install_log.txt

sudo sed -i 's/^OPTIONS.*/OPTIONS=" -4 -u bind"' /etc/default/named
self_ip=$(hostname -I)
#listen-on port 53{localhost;${self_ip};};\n\n
sudo sed -i "4a              allow-query {any;};\n\n       forwarders {1.1.1.1;};\n\n       recursion yes;" /etc/bind/named.conf.options
sudo sed -i '8azone "lookup.de" {\n    type master;\n    file "/etc/bind/zones/forward.lookup.de";\n};' /etc/bind/named.conf.local
sudo mkdir -p /etc/bind/zones
sudo cp /etc/bind/db.local /etc/bind/zones/forward.lookup.de
sudo cp /etc/bind/zones/forward.lookup.de /etc/bind/zones/block
sudo sed -i "s/127.0.0.1/0.0.0.0/" /etc/bind/zones/block
sudo sed -i "s/::1/::0/" /etc/bind/zones/block
sudo systemctl restart named

echo "install apache, sql and php" >> /home/ubuntu/install_log.txt

sudo apt-get -y install apache2
sudo apt-get -y install php
echo "y" | sudo apt install mysql-server 
sudo apt install php libapache2-mod-php php-mysql
rm /var/www/html/index.html
cd /var/www/html

echo "get website" >> /home/ubuntu/install_log.txt

wget https://raw.githubusercontent.com/Chaosking551/InternetServiceDNS/main/website/index.php
wget https://raw.githubusercontent.com/Chaosking551/InternetServiceDNS/main/website/login.php
wget https://raw.githubusercontent.com/Chaosking551/InternetServiceDNS/main/website/logout.php
wget https://raw.githubusercontent.com/Chaosking551/InternetServiceDNS/main/website/addIP.php
wget https://raw.githubusercontent.com/Chaosking551/InternetServiceDNS/main/website/db_config.php
wget https://raw.githubusercontent.com/Chaosking551/InternetServiceDNS/main/website/home.php
wget https://raw.githubusercontent.com/Chaosking551/InternetServiceDNS/main/website/removeIP.php
wget https://raw.githubusercontent.com/Chaosking551/InternetServiceDNS/main/website/register.php

sudo systemctl restart apache2


cd /home/ubuntu
wget https://raw.githubusercontent.com/Chaosking551/InternetServiceDNS/main/changeDBConfig.sh

echo "start node_exporter" >> /home/ubuntu/install_log.txt

wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.5.0.linux-amd64.tar.gz
cd node_exporter-1.5.0.linux-amd64
./node_exporter &

echo "finish init" >> /home/ubuntu/install_log.txt
