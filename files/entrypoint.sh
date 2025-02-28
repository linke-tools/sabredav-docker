#!/bin/bash
echo "Check if database exists..."
if mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "USE $MYSQL_DATABASE" 2>/dev/null; then
	echo "Database exists."
	TABLES=$(mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -N -e "SHOW TABLES FROM $MYSQL_DATABASE" 2>/dev/null)
	if [ -n "$TABLES" ]; then
		echo "Tables already created.";
	else
		echo "Creating tables..."
		cd /sabredav
		cat dav/examples/sql/mysql.* | mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$MYSQL_DATABASE"
		[ ! $? -eq 0 ] && echo "Tables could not be created." 1>&2 &&  exit 1
		echo "Table created."
	fi
else
	echo "Database does not exist.";
	exit 1
fi
envsubst < /config.json > /sabredav/config.json
exec "$@"
