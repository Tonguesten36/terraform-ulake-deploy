#!/bin/bash

# Predefine variable
HOST="ulake-nginx";
PORT="80";
BASE_DIR=$(readlink -f $(dirname $0));
ROOT_DIR=$(readlink -f $BASE_DIR/../);
CONF="$BASE_DIR/nginx.conf.mini";
NET="ulake-network";
FRONTEND=""
HTML="html"

# Parse args
while test ${#} -gt 0; do
    case "$1" in
        --help) echo "start-nginx.sh [-p port] [-h html_dir] [frontend_name]"
        	exit
                ;;
        -p)     shift
                PORT="$1"
                ;;
        -h)     shift
                HTML="$1"
                ;;
        *)      FRONTEND="$1"
                ;;
    esac
    shift
done

if [ "$FRONTEND" == "" ]; then
    # Start nginx docker with ALL frontends mounted
    FRONTENDS=`find $ROOT_DIR -name "html" -type d | sed 's#/html##;s#.*/##' | while read -r line; do echo "-v $ROOT_DIR/$line/html:/opt/$line:ro"; done`
    docker run --name $HOST -p $PORT:80 \
        -v $CONF:/etc/nginx/nginx.conf:ro \
        $FRONTENDS \
        --network $NET \
        -d nginx:latest
else
    # Start nginx docker with a specific port and configurations
    docker run --name $HOST-$FRONTEND -p $PORT:80 \
        -v $CONF:/etc/nginx/nginx.conf:ro \
        -v $ROOT_DIR/$FRONTEND/$HTML:/opt/$FRONTEND:ro \
        --network $NET \
        -d nginx:latest
fi