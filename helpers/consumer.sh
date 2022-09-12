#!/bin/bash


if [ $# -lt 1 ];
then
    DOCKER_RUN="cd /opt/kafka/bin && ./kafka-console-consumer.sh "
    docker exec broker-1 bash -c "$DOCKER_RUN"
    exit 1
fi

source ./base.sh

DOCKER_RUN="cd /opt/kafka/bin && ./kafka-console-consumer.sh $@ --bootstrap-server localhost:9092"
log "running: $DOCKER_RUN"
docker exec broker-1 bash -c "$DOCKER_RUN"