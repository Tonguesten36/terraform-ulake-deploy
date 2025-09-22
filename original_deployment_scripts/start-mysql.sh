

#!/bin/bash

# Predefine variable
BASE_DIR=$(readlink -f $(dirname $0));

HOST="ulake-mysql";
PORT="23306";
PASSWORD="root"; # for root user

SQL="$BASE_DIR/init.sql";
DATA="$BASE_DIR/data/mysql";
NET="ulake-network";
TIME=10; # temporary wait for waiting server up

# Start newest mariadb and initialize database
docker run --detach --name $HOST \
    --env MYSQL_ROOT_PASSWORD="$PASSWORD" \
    -v $DATA:/var/lib/mysql \
    --network $NET \
    -p $PORT:3306 mariadb:latest && \
    sleep $TIME && \
    docker exec -i $HOST mariadb -u root --password='root' < $SQL;
