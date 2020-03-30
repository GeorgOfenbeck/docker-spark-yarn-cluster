# Docker hadoop yarn cluster with hive for spark 2.4.4

# Differences to Original
Original: https://github.com/PierreKieffer/docker-spark-yarn-cluster
Upgraded Spark Version to 2.4.4 and added Hive to also run within the docker cluster.
Instead of opening a range of ports, included a Socks5 Server on the cluster to which one can then connect and hence get access to all ports

## docker-spark-yarn-cluster 
This application allows to deploy multi-nodes hadoop cluster with spark 2.4.4 on yarn. 

## Build image
- Clone the repo 
- cd inside ../docker-spark-yarn-cluster 
- Run `docker build -t spark-hadoop-cluster .`

## Run  
- Run `./startHadoopCluster.sh`
- Access to master `docker exec -it mycluster-master bash`

### Run spark applications on cluster : 
- spark-shell : `spark-shell --master yarn --deploy-mode client`
- spark : `spark-submit --master yarn --deploy-mode cluster --num-executors 2 --executor-memory 4G --executor-cores 4 --class org.apache.spark.examples.SparkPi $SPARK_HOME/examples/jars/spark-examples_2.11-2.4.4.jar`


### Access to the Web UI's

Connect via a Socks 5 proxy to mycluster-master:8123

- Access to Hadoop cluster Web UI : mycluster-master:8088 
- Access to spark Web UI : mycluster-master::8080
- Access to hdfs Web UI : mycluster-master::50070
- Access to the HIVE UI: mycluster-master:10002
  
## Stop 
- `docker stop $(docker ps -a -q)`
- `docker container prune`





