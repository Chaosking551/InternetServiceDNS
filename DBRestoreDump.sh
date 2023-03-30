#!/bin/bash
FILE=$1

if [ -f "$FILE" ]; then
	SERVER=ipvar
	USER=dns_user
	PW=dns
	DB=dns_db

	mysql --user=${USER} --password=${PW} --host=${SERVER} ${DB} < ${FILE}
	
	echo "Restored $FILE"
else
	echo "$FILE not found"
fi


