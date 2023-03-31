#!/bin/bash

sudo apt update
sudo apt install mariadb-server mariadb-client -y
sudo apt install -y software-properties-common
sudo mysql_secure_installation

sudo systemctl start mariadb.service
sudo sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

sudo sed -i "$ a [mysqld]" /etc/mysql/my.cnf
sudo sed -i "$ a #replication" /etc/mysql/my.cnf
sudo sed -i "$ a server_id = 2" /etc/mysql/my.cnf
sudo sed -i "$ a report_host = 'master2'" /etc/mysql/my.cnf
sudo sed -i "$ a log_bin = /var/lib/mysql/mariadb-bin" /etc/mysql/my.cnf
sudo sed -i "$ a log_bin_index = /var/lib/mysql/mariadb-bin.index" /etc/mysql/my.cnf
sudo sed -i "$ a relay_log = /var/lib/mysql/relay-bin" /etc/mysql/my.cnf
sudo sed -i "$ a relay_log_index = /var/lib/mysql/relay-bin.index" /etc/mysql/my.cnf

sudo systemctl restart mariadb

sudo mysql -u root -padmin -e "create user 'master2'@'%' identified by 'master2';"
sudo mysql -u root -padmin -e "grant replication slave on *.* to 'master2'@'%';"

wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.5.0.linux-amd64.tar.gz
cd node_exporter-1.5.0.linux-amd64
./node_exporter &