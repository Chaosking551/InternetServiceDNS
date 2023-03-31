#!/bin/bash
IP=$1

sudo sed -i "s/ipvar/$IP/" db_config.php
