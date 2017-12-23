FROM centos:7
MAINTAINER Dieudonne,simolx@163.com

ENV TZ Asia/Shanghai
ENV LC_ALL en_US.UTF-8
ENV SPARK_VERSION=2.1.1
#ENV TINI_VERSION v0.16.1
ENV JAVA_HOME /opt/sparkdistribute/jdk1.8.0_152
ENV PATH $JAVA_HOME/bin:/opt/miniconda2/bin:$PATH
ENV AIRFLOW_HOME /opt/airflow
ENV HADOOP_HOME /opt/sparkdistribute/hadoop-2.5.2

RUN /bin/cp -f /usr/share/zoneinfo/$TZ /etc/localtime
RUN yum -y update \
    && yum install -y which openssh openssh-clients openssh-server bzip2 mariadb mariadb-devel gcc gcc-c++ cyrus-sasl-devel cyrus-sasl-plain cyrus-sasl-gssapi cyrus-sasl-scram cyrus-sasl-md5 libffi-devel libxml2-devel libxslt-devel vim sudo postgresql-devel crontabs \
    && yum clean all \
    && rm -rf /var/cache/yum
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
RUN mkdir -p /opt/sparkdistribute /var/log/airflow
#RUN curl -o /tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini \
#    && chmod +x /tini
RUN curl -O https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh \
    && bash Miniconda2-latest-Linux-x86_64.sh -b -p /opt/miniconda2 && rm -f Miniconda2-latest-Linux-x86_64.sh
RUN curl -O -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/jdk-8u152-linux-x64.tar.gz \
    && tar -xzf jdk-8u152-linux-x64.tar.gz -C /opt/sparkdistribute \
    && rm -f jdk-8u152-linux-x64.tar.gz
RUN curl -O -L https://archive.apache.org/dist/spark/spark-2.1.1/spark-${SPARK_VERSION}-bin-hadoop2.4.tgz \
    && tar -xzf spark-${SPARK_VERSION}-bin-hadoop2.4.tgz -C /opt/sparkdistribute \
    && rm -f spark-${SPARK_VERSION}-bin-hadoop2.4.tgz
RUN curl -O -L https://archive.apache.org/dist/hadoop/core/hadoop-2.5.2/hadoop-2.5.2.tar.gz \
    && tar -xzf hadoop-2.5.2.tar.gz -C /opt/sparkdistribute \
    && rm -f hadoop-2.5.2.tar.gz
COPY conf/spark/* /opt/sparkdistribute/spark-${PARK_VERSION}-bin-hadoop2.4/conf/
COPY conf/hadoop/* /opt/sparkdistribute/hadoop-2.5.2/etc/hadoop/
COPY hbase-1.0.0.tar.gz /opt/
RUN pip install --upgrade pip && pip install apache-airflow[devel,postgres,mysql,hive,hdfs,vertica,cloudant,doc,samba,crypto,docker,async,celery,cgroups,datadog,druid,emr,gcp_api,webhdfs,jira,jdbc,rabbitmq,salesforce,statsd,ldap,kerberos,password,qds]==1.8.2 supervisor suds kafka-python pyhive[hive,sqlalchemy] thrift \
    && pip install /opt/hbase-1.0.0.tar.gz \
    && rm -rf /opt/hbase-1.0.0.tar.gz ~/.cache/pip/*
COPY conf/supervisor/supervisord.conf /etc/
COPY conf/airflow/* $AIRFLOW_HOME/
RUN sed -i -e '/Defaults    requiretty/{ s/.*/# Defaults    requiretty/ }' /etc/sudoers
RUN useradd dataflow && useradd isearch
WORKDIR /opt/baitu

VOLUME [ "/etc/supervisord", "$AIRFLOW_HOME/dags", "/opt/baitu" ]
EXPOSE 8081 9001 19090
#ENTRYPOINT ["/tini", "--"]
CMD ["/bin/bash", "-c", "supervisord -n -c /etc/supervisord.conf"]
