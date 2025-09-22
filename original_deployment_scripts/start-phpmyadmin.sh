#!/bin/bash

# Predefine variable
HOST="ulake-phpmyadmin";
PORT="8081";
PASSWORD="root"; # for root user
SQL_HOST="ulake-mysql"; # default machine host in docker
SQL_PORT="3306"; # follow start-mysql.sh
NET="ulake-network";

# Start phpmyadmin
docker run --detach --name $HOST \
    --env MYSQL_ROOT_PASSWORD="$PASSWORD" \
    --env PMA_HOST=$SQL_HOST \
    --env PMA_PORT=$SQL_PORT \
    --network $NET \
    -p $PORT:80 phpmyadmin:latest;
