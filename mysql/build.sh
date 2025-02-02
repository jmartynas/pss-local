#!/bin/bash

docker-compose down -v
sudo rm -rf ./master_data/*
sudo rm -rf ./slave1_data/*
sudo rm -rf ./slave2_data/*
docker-compose build
docker-compose up -d

# Check master connection
until docker exec master sh -c 'mysql -u root -ppass -h 127.0.0.1 -P 3306 -e ";"'
do
    echo "Waiting for master database connection..."
    sleep 4
done

priv_stmt='CREATE USER "slave"@"%" IDENTIFIED BY "slave"; GRANT REPLICATION SLAVE ON *.* TO "slave"@"%"; FLUSH PRIVILEGES;'
docker exec master sh -c "mysql -u root -ppass -h 127.0.0.1 -P 3306 -e '$priv_stmt'"

# Check slave1 connection
until docker-compose exec slave1 sh -c 'mysql -u root -ppass -h 127.0.0.1 -e ";"'
do
    echo "Waiting for slave1 database connection..."
    sleep 4
done

# Check slave2 connection
until docker-compose exec slave2 sh -c 'mysql -u root -ppass -h 127.0.0.1 -e ";"'
do
    echo "Waiting for slave1 database connection..."
    sleep 4
done

MS_STATUS=`docker exec master sh -c 'mysql -u root -ppass -h 127.0.0.1 -P 3306 -e "SHOW MASTER STATUS"'`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`

start_slave_stmt="CHANGE MASTER TO MASTER_HOST='master',MASTER_USER='slave',MASTER_PASSWORD='slave',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd='mysql -u root -ppass -h 127.0.0.1 -P 3306 -e "'
start_slave_cmd+="$start_slave_stmt"
start_slave_cmd+='"'
docker exec slave1 sh -c "$start_slave_cmd"
docker exec slave2 sh -c "$start_slave_cmd"

docker exec slave1 sh -c "mysql -u root -ppass -h 127.0.0.1 -e 'SHOW SLAVE STATUS \G'"
docker exec slave2 sh -c "mysql -u root -ppass -h 127.0.0.1 -e 'SHOW SLAVE STATUS \G'"
