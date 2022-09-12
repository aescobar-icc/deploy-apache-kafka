#!/bin/bash


if [ $# -lt 1 ];
then
    DOCKER_RUN="cd /opt/kafka/bin && ./kafka-topics.sh "
    docker exec broker-1 bash -c "$DOCKER_RUN"
    exit 1
fi


TOPIC_ACTION="--list"
TOPIC_ARGS=""
TOPIC_REPLICATION=2
TOPIC_PARTITIONS=3

#read run arguments
for args in "$@"
do
    key=$(echo $args | cut -f1 -d=)
    value=$(echo $args | cut -f2 -d=)   

    case "$key" in
        "--create") TOPIC_ACTION="--create";; 
        "--list")   TOPIC_ACTION="--list";; 
        "--describe")   TOPIC_ACTION="--describe";; 
        "--topic")  TOPIC_ARGS="$TOPIC_ARGS --topic=${value}";; 
        "--replic") TOPIC_ARGS="$TOPIC_ARGS --replication-factor=${value}";; 
        "--part")   TOPIC_ARGS="$TOPIC_ARGS --partitions=${value}";;  
            *)   
    esac
done

source ./base.sh
load_env_file ../services/global.env

#samples
# ./topics.sh --topic gps_signal --create --replication-factor 2 --partitions 2
# ./topics.sh --topic gps_signal --describe
# ./topics.sh --list


DOCKER_RUN="cd /opt/kafka/bin && ./kafka-topics.sh $@ --bootstrap-server localhost:9092"
log "topic action: $TOPIC_ACTION"
docker exec broker-1 bash -c "$DOCKER_RUN"