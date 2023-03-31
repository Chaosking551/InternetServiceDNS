#!/bin/bash

cd /etc/bind

echo '' >> named.conf.local
echo 'zone "bild.de" {' >> named.conf.local
echo '	type master;' >> named.conf.local
echo '	file "/etc/bind/zones/block"' >> named.conf.local
echo '};' >> named.conf.local


sudo systemctl restart named