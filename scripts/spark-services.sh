#!/bin/bash

$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

jps -lm

hdfs dfsadmin -report

hdfs dfs -mkdir -p /apps/spark
zip /usr/local/spark/jars/spark-jars.zip /usr/local/spark/jars/*
hadoop fs -put /usr/local/spark/jars/spark-jars.zip  /apps/spark
mkdir /tmp/spark-events

$SPARK_HOME/sbin/start-all.sh

scala -version
service danted start
mkdir $DERBY_HOME/data
$HADOOP_HOME/bin/hadoop fs -mkdir       /tmp
$HADOOP_HOME/bin/hadoop fs -mkdir       /user/
$HADOOP_HOME/bin/hadoop fs -mkdir       /user/hive
$HADOOP_HOME/bin/hadoop fs -mkdir       /user/hive/warehouse
$HADOOP_HOME/bin/hadoop fs -chmod g+w   /tmp
$HADOOP_HOME/bin/hadoop fs -chmod g+w   /user/hive/warehouse
cd $HIVE_HOME
$HIVE_HOME/bin/schematool -initSchema -dbType derby
nohup $HIVE_HOME/bin/hiveserver2 &

$HADOOP_HOME/bin/hadoop fs -mkdir       /tmp/spark
$HADOOP_HOME/bin/hadoop fs -mkdir       /tmp/spark/history
$SPARK_HOME/sbin/start-history-server.sh 
jps -lm



