FROM centos:7
MAINTAINER Dieudonne,simolx@163.com

ENV TZ Asia/Shanghai
ENV LC_ALL en_US.UTF-8
ENV SPARK_VERSION 2.2.1
ENV HADOOP_VERSION 2.7.2
ENV SPARK_HADOOP_VERSION 2.7
ENV AIRFLOW_VERSION 1.8.2
ENV JAVA_HOME /opt/sparkdistribute/jdk1.8.0_151
ENV PATH $JAVA_HOME/bin:/opt/miniconda/bin:$PATH
ENV AIRFLOW_HOME /opt/airflow
ENV HADOOP_HOME /opt/sparkdistribute/hadoop-${HADOOP_VERSION}

RUN /bin/cp -f /usr/share/zoneinfo/$TZ /etc/localtime
RUN yum -y update \
    && yum install -y which openssh openssh-clients openssh-server bzip2 mariadb mariadb-devel gcc gcc-c++ cyrus-sasl-devel cyrus-sasl-plain cyrus-sasl-gssapi cyrus-sasl-scram cyrus-sasl-md5 libffi-devel libxml2-devel libxslt-devel vim sudo postgresql-devel crontabs \
    && yum clean all \
    && rm -rf /var/cache/yum
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
RUN mkdir -p /opt/sparkdistribute /var/log/airflow
# install supervisor suds with os python
RUN curl -O https://bootstrap.pypa.io/get-pip.py \
    && /usr/bin/python2 get-pip.py \
    && /usr/bin/pip install -U supervisor suds \
    && rm -rf get-pip.py ~/.cache/pip/*
# install miniconda3 and airflow
RUN curl -O https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda \
    && rm -f Miniconda3-latest-Linux-x86_64.sh
# install jdk
RUN curl -O -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-x64.tar.gz \
    && tar -xzf jdk-8u151-linux-x64.tar.gz -C /opt/sparkdistribute \
    && mv jdk-8u151-linux-x64.tar.gz /opt
#    && rm -f jdk-8u151-linux-x64.tar.gz
# install spark
RUN curl -O -L https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}.tgz \
    && tar -xzf spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}.tgz -C /opt/sparkdistribute \
    && rm -f spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}.tgz
# install hadoop
RUN curl -O -L https://archive.apache.org/dist/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -xzf hadoop-${HADOOP_VERSION}.tar.gz -C /opt/sparkdistribute \
    && rm -f hadoop-${HADOOP_VERSION}.tar.gz
COPY conf/spark/* /opt/sparkdistribute/spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}/conf/
COPY conf/hadoop/* /opt/sparkdistribute/hadoop-${HADOOP_VERSION}/etc/hadoop/
COPY hbase-1.0.0.tar.gz /opt/
RUN pip install --upgrade pip setuptools \
    && pip install apache-airflow[devel,postgres,mysql,hive,hdfs,vertica,cloudant,doc,samba,crypto,docker,async,celery,cgroups,datadog,druid,emr,gcp_api,webhdfs,jira,jdbc,salesforce,statsd,ldap,kerberos,password,qds]==${AIRFLOW_VERSION} kafka-python pyhive[hive,sqlalchemy] thrift \
    && pip install /opt/hbase-1.0.0.tar.gz \
    && rm -rf /opt/hbase-1.0.0.tar.gz ~/.cache/pip/*
COPY conf/supervisor/supervisord.conf /etc/
COPY conf/airflow/* $AIRFLOW_HOME/
RUN sed -i -e '/Defaults    requiretty/{ s/.*/# Defaults    requiretty/ }' /etc/sudoers
RUN useradd dataflow \
    && useradd elasticsearch \
    && useradd gdata
WORKDIR /opt/baitu

VOLUME [ "/etc/supervisord", "$AIRFLOW_HOME/dags", "/opt/baitu" ]
EXPOSE 8081 9001 19090
CMD ["/bin/bash", "-c", "supervisord -n -c /etc/supervisord.conf"]
