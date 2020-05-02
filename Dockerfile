FROM ubuntu:18.04


USER root

RUN apt-get update && apt-get -y dist-upgrade && apt-get install -y openssh-server openjdk-8-jdk wget scala dante-server curl net-tools
RUN  apt-get -y update
RUN  apt-get -y install zip 
RUN  apt-get -y install vim
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

RUN ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -P "" \
    && cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys

RUN wget -O /hadoop.tar.gz -q http://archive.apache.org/dist/hadoop/core/hadoop-2.7.3/hadoop-2.7.3.tar.gz \
        && tar xfz hadoop.tar.gz \
        && mv /hadoop-2.7.3 /usr/local/hadoop \
        && rm /hadoop.tar.gz

RUN wget -O /spark.tar.gz -q https://archive.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz
RUN tar xfz spark.tar.gz
RUN mv /spark-2.4.4-bin-hadoop2.7 /usr/local/spark
RUN rm /spark.tar.gz

RUN wget -O /spark212.tar.gz -q https://archive.apache.org/dist/spark/spark-2.4.2/spark-2.4.2-bin-hadoop2.7.tgz
RUN tar xfz spark212.tar.gz
RUN mv /spark-2.4.2-bin-hadoop2.7 /usr/local/spark212
RUN rm /spark212.tar.gz


RUN wget -O /derby.tar.gz -q http://archive.apache.org/dist/db/derby/db-derby-10.15.2.0/db-derby-10.15.2.0-bin.tar.gz
RUN tar xfz derby.tar.gz
RUN mv /db-derby-10.15.2.0-bin /usr/local/derby
RUN rm /derby.tar.gz


RUN wget -O /hive.tar.gz -q https://downloads.apache.org/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz
RUN tar xfz hive.tar.gz
RUN mv /apache-hive-3.1.2-bin /usr/local/hive
RUN rm /hive.tar.gz




ENV HADOOP_HOME=/usr/local/hadoop
ENV SPARK_HOME=/usr/local/spark
ENV DERBY_HOME=/usr/local/derby
ENV HIVE_HOME=/usr/local/hive
ENV HADOOP_COMMON_HOME=${HADOOP_HOME}
ENV HADOOP_MAPRED_HOME=${HADOOP_HOME}
ENV HADOOP_HDFS_HOME=${HADOOP_HOME}
ENV YARN_HOME={HADOOP_HOME}
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$SPARK_HOME:$HIVE_HOME/bin:$DERBY_HOME/bin:sbin
ENV CLASSPATH=$CLASSPATH:$DERBY_HOME/lib/derby.jar:$DERBY_HOME/lib/derbytools.jar


RUN mkdir -p $HADOOP_HOME/hdfs/namenode \
        && mkdir -p $HADOOP_HOME/hdfs/datanode

COPY config/ /tmp/
RUN mv /tmp/ssh_config $HOME/.ssh/config \
    && mv /tmp/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
    && mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml \
    && mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml \
    && mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml.template \
    && cp $HADOOP_HOME/etc/hadoop/mapred-site.xml.template $HADOOP_HOME/etc/hadoop/mapred-site.xml \
    && mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml \
    && cp /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves \
    && mv /tmp/slaves $SPARK_HOME/conf/slaves \
    && mv /tmp/spark/spark-env.sh $SPARK_HOME/conf/spark-env.sh \    
    && mv /tmp/spark/log4j.properties $SPARK_HOME/conf/log4j.properties \
    && mv /tmp/spark/spark-defaults.conf $SPARK_HOME/conf/spark-defaults.conf \
    && cp /tmp/hive-site.xml $SPARK_HOME/conf/hive-site.xml \
    && mv /tmp/danted.conf /etc/danted.conf \
    && cp $SPARK_HOME/conf/* /usr/local/spark212/conf/ \
    && mv /tmp/hive-site.xml /usr/local/hive/conf/hive-site.xml
    

ADD scripts/spark-services.sh $HADOOP_HOME/spark-services.sh

RUN chmod 744 -R $HADOOP_HOME


RUN $HADOOP_HOME/bin/hdfs namenode -format

EXPOSE 8123

ENTRYPOINT service ssh start; cd $SPARK_HOME; bash


