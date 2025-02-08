#!/bin/bash
# username password master_host slave_host
#create_cluster.sh root f00bar ec2-34-207-211-209.compute-1.amazonaws.com ec2-35-153-52-32.compute-1.amazonaws.com
# USER=root
# PASS=f00bar
# MASTER_HOST=ec2-34-207-211-209.compute-1.amazonaws.com
# SLAVE_HOSTS=ec2-35-153-52-32.compute-1.amazonaws.com
 
USER=${1}
PASS=${2}
MASTER_HOST=${3}
SLAVE_HOST=${4}

MYSQL_M_PORT=3002
MYSQL_S_PORT=3003
DB=mydb
DUMP_FILE="/tmp/$DB-export-$(date +"%Y%m%d%H%M%S").sql" 

echo "MASTER: $MASTER_HOST"
sleep 10 
mysql -h $MASTER_HOST -P ${MYSQL_M_PORT} "-u$USER" "-p$PASS" $DB <<-EOSQL &
	GRANT REPLICATION SLAVE ON *.* TO '$USER'@'%' IDENTIFIED BY '$PASS';
	FLUSH PRIVILEGES;
	FLUSH TABLES WITH READ LOCK;
	DO SLEEP(3600);
EOSQL
 
echo "  - Waiting for database to be locked"
sleep 5
 
echo "  - Dumping database to $DUMP_FILE"
mysqldump -h $MASTER_HOST -P ${MYSQL_M_PORT} "-u$USER" "-p$PASS" --opt $DB > $DUMP_FILE
echo "  - Dump complete."
 
sleep 5

MASTER_STATUS=$(mysql -h $MASTER_HOST -P ${MYSQL_M_PORT} "-u$USER" "-p$PASS" -ANe "SHOW MASTER STATUS;" | awk '{print $1 " " $2}')
LOG_FILE=$(echo $MASTER_STATUS | cut -f1 -d ' ')
LOG_POS=$(echo $MASTER_STATUS | cut -f2 -d ' ')
echo "  - Current log file is $LOG_FILE and log position is $LOG_POS"
 

kill $! 2>/dev/null
wait $! 2>/dev/null
 
echo "  - Master database unlocked"
 
echo "SLAVE: $SLAVE_HOST"
USER=root
echo "  - Creating database copy"
sleep 10
mysql -h $SLAVE_HOST -P ${MYSQL_S_PORT} "-u$USER" "-p$PASS" -e "DROP DATABASE IF EXISTS $DB; CREATE DATABASE $DB;"
sleep 10
mysql -h $SLAVE_HOST -P ${MYSQL_S_PORT} "-u$USER" "-p$PASS" $DB < $DUMP_FILE
sleep 10
echo "  - Setting up slave replication"
mysql -h $SLAVE_HOST -P ${MYSQL_S_PORT} "-u$USER" "-p$PASS" $DB <<-EOSQL &
	STOP SLAVE;
	CHANGE MASTER TO MASTER_HOST='$MASTER_HOST',
	MASTER_PORT=3002,
	MASTER_USER='$USER',
	MASTER_PASSWORD='f00bar',
	MASTER_LOG_FILE='$LOG_FILE',
	MASTER_LOG_POS=$LOG_POS;
	START SLAVE;
EOSQL

sleep 10

SLAVE_OK=$(mysql -h $SLAVE_HOST -P ${MYSQL_S_PORT} "-u$USER" "-p$PASS" -e "SHOW SLAVE STATUS\G;" | grep 'Waiting for master')
if [ -z "$SLAVE_OK" ]; then
	echo "  - Error ! Wrong slave IO state."
else
	echo "  - Slave IO state OK"
fi
