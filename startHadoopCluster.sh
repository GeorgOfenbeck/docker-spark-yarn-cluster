#!/bin/bash

# VARIABLES
IMG_NAME="spark-hadoop-cluster:latest"
HOST_PREFIX="mycluster"
NETWORK_NAME=$HOST_PREFIX

N=${1:-2}
NET_QUERY=$(docker network ls | grep -i $NETWORK_NAME)
if [ -z "$NET_QUERY" ]; then
	docker network create --driver=bridge $NETWORK_NAME
fi

# START HADOOP SLAVES 
i=1
while [ $i -le $N ]
do
	HADOOP_SLAVE="$HOST_PREFIX"-slave-$i
	docker run --name $HADOOP_SLAVE -h $HADOOP_SLAVE --rm --net=$NETWORK_NAME -itd "$IMG_NAME"
	i=$(( $i + 1 ))
done

# START HADOOP MASTER
HADOOP_MASTER="$HOST_PREFIX"-master
docker run --name $HADOOP_MASTER -h $HADOOP_MASTER --rm --net=$NETWORK_NAME -p 8123:8123 -itd "$IMG_NAME"

# START MULTI-NODES CLUSTER
docker exec -it $HADOOP_MASTER "/usr/local/hadoop/spark-services.sh"






