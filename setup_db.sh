#!/bin/bash
sudo mysql -u root -padmin -e "CREATE DATABASE dns_db; CREATE USER  'dns_user'@'localhost' IDENTIFIED BY 'dns'; GRANT ALL ON db-name.* to 'dns_user'@'%' IDENTIFIED BY 'dns' WITH GRANT OPTION; FLUSH PRIVILEGES;"
sudo mysql -u root -padmin -e "CREATE TABLE user_data (user_id int auto_increment, user_name VARCHAR(50), password VARCHAR(75), PRIMARY KEY (user_id)); CREATE TABLE user_ip (ip_id int auto_increment, user_id int, ip VARCHAR(16), PRIMARY KEY(ip_id), FOREIGN KEY(user_id) REFERENCES user_data(user_id));CREATE TABLE block_list (block_id int auto_increment, url VARCHAR(100), PRIMARY KEY(block_id));"


