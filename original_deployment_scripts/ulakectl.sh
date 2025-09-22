#!/bin/bash

# Predefine variable
HOSTBASE="ulake-service";
NET="ulake-network"
BASE_DIR=$(readlink -f $(dirname $0));
ROOT_DIR=$(readlink -f $BASE_DIR/../);


help() {
    echo "Usage: service.sh <start/restart/stop> [service-name] [options]"
}

# Start service docker with proper configuration and installation
start() {
    QUARKUS_SERVICE="$1"

    # Quarkus service
    if [[ $QUARKUS_SERVICE == "" ]]; then
        echo "Service name is required!"
        return 1
    fi
    HOST="$HOSTBASE-$QUARKUS_SERVICE";

    # check native build
    RUNNER=`echo $ROOT_DIR/$QUARKUS_SERVICE/build/*-runner`
    if [[ -f "$RUNNER" && "$QUARKUS_SERVICE" != "core" && "$QUARKUS_SERVICE" != "ingestion" && "$QUARKUS_SERVICE" != "dashboard"&& "$QUARKUS_SERVICE" != "ir" && "$QUARKUS_SERVICE" != "lcc" ]]; then
        echo "+ Using native build at $RUNNER"
        TARGET_RUNNER="/home/ulake-service-$QUARKUS_SERVICE-runner"
        docker run -d --name $HOST \
            -v $RUNNER:$TARGET_RUNNER \
            --network $NET \
            --rm \
            --entrypoint $TARGET_RUNNER \
            registry.access.redhat.com/ubi8/ubi-minimal:8.6
    else
        # link container data volume to disk
        if [[ "$QUARKUS_SERVICE" == "core" ]]; then
            EXT="-v $ROOT_DIR/deployment/data/localfs:/home/data"
        fi

        # check if jar build is available
        JAR_DIR="$ROOT_DIR/$QUARKUS_SERVICE/build/quarkus-app"
        if [[ -d "$JAR_DIR" ]]; then
            echo "+ Using jar build at $JAR_DIR"
            docker run -d --name $HOST \
                -v $JAR_DIR:/home/$QUARKUS_SERVICE \
                --network $NET \
                --rm \
                -e JAVA_APP_JAR="/home/$QUARKUS_SERVICE/quarkus-run.jar" \
                $EXT \
                registry.access.redhat.com/ubi8/openjdk-11
        else
            # nah, let's use the default dev build
            DEV_DIR="$ROOT_DIR/$QUARKUS_SERVICE"
            echo "+ Using dev build at $DEV_DIR"
            docker run --name $HOST \
                -v $ROOT_DIR/common/src:/home/common/src \
                -v $DEV_DIR:/home/$QUARKUS_SERVICE \
                -e QUARKUS_SERVICE=$QUARKUS_SERVICE \
                --network $NET \
                --rm \
                $EXT \
                -d ulake/service:1.0.0-SNAPSHOT
        fi
    fi
}

start_all() {
    projects=$(cat $ROOT_DIR/settings.gradle  | grep include | sed "s/'//g;s/include //;s/,//g")
    projects=($projects)
    echo ${projects[@]}
    for i in ${projects[@]}; do
        echo Starting {$i}....
        if [[ "$i" != "common" ]]; then
		start $i
        fi
    done
}

stop () {
    CONTAINERS=""
    if [[ "$1" == "" ]]; then
        CONTAINERS=$( docker ps --format "{{.Names}}" -a | grep "^ulake-service" | paste -sd" " )
    else
        CONTAINERS=ulake-service-$1
    fi
    docker stop $CONTAINERS
    docker rm $CONTAINERS
}

restart () {
    CONTAINERS=""
    if [[ "$1" == "" ]]; then
        CONTAINERS=$( docker ps --format "{{.Names}}" -a | grep "^ulake-service" | paste -sd" " )
    else
        CONTAINERS=ulake-service-$1
    fi
    docker restart $CONTAINERS
}

case $1 in
    "") help
        ;;

    "start")
        shift
	    echo start $1
        if [[ "$1" == "" ]]; then
            start_all
        else
            start $@
        fi
        ;;

    "restart")
        shift
        restart $@
        ;;

    "stop")
        shift
        stop $@
        ;;
esac

