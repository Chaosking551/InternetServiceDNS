#!/bin/bash

mkdir -p backups

mysqldump --opt --protocol=TCP --user=dns_user --password=dns --host=ipvar dns_db > FILE=backups/`date +"%Y%m%d"`.sql