#!/bin/bash

cd /etc/bind

sudo sed -i '$ a zone "bild.de" {' named.conf.local
sudo sed -i "$ a   type master;" named.conf.local
sudo sed -i '$ a   file "/etc/bind/zones/block"' named.conf.local
sudo sed -i "$ a };" named.conf.local

sudo systemctl restart named