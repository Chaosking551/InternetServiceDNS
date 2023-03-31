#!/bin/bash
IP=$1

sudo sed -i "s/ipvar/$IP/" /var/www/html/db_config.php
