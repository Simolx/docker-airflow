FROM dieudonne/docker-spark
MAINTAINER Dieudonne lx <lx.simon@yahoo.com>

ENV AIRFLOW_VERSION=1.9.0 \
    AIRFLOW_HOME="/opt/airflow"
RUN yum -y update \
    && yum install -y mariadb mariadb-devel gcc gcc-c++ cyrus-sasl-devel cyrus-sasl-plain cyrus-sasl-gssapi cyrus-sasl-scram cyrus-sasl-md5 libffi-devel libxml2-devel libxslt-devel postgresql-devel \
    && yum clean all \
    && rm -rf /var/cache/yum
RUN mkdir -p /var/log/airflow
# install supervisor suds with os python
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    /usr/bin/python2 get-pip.py && \
    /usr/bin/pip install -U supervisor suds && \
    rm -rf get-pip.py ~/.cache/pip/*
# install airflow
COPY hbase-1.0.0.tar.gz /opt/
RUN pip install apache-airflow[async,celery,cloudant,crypto,dask,databricks,datadog,devel_hadoop,doc,docker,emr,jdbc,jira,ldap,postgres,qds,redis,salesforce,samba,sendgrid,ssh,statsd,vertica,druid]==${AIRFLOW_VERSION} kafka-python pyhive[hive,sqlalchemy] celery[redis] thrift \
    && pip install /opt/hbase-1.0.0.tar.gz \
    && conda clean --all -y \
    && rm -rf /opt/hbase-1.0.0.tar.gz ~/.cache/pip/*
COPY conf/supervisor/supervisord.conf /etc/
COPY conf/airflow/* $AIRFLOW_HOME/
VOLUME [ "/etc/supervisord", "$AIRFLOW_HOME/dags", "/opt/baitu" ]
EXPOSE 8081 9001
CMD ["/bin/bash", "-c", "supervisord -n -c /etc/supervisord.conf"]
