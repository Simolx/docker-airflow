FROM dieudonne/docker-spark:1.0.0

MAINTAINER Dieudonne lx <lx.simon@yahoo.com>

ENV AIRFLOW_VERSION=1.10.2 \
    AIRFLOW_HOME="/opt/airflow" \
    AIRFLOW_METASTORE_PORT=3306
RUN yum -y update \
    && yum install -y mariadb mariadb-devel gcc gcc-c++ cyrus-sasl-devel cyrus-sasl-plain cyrus-sasl-gssapi cyrus-sasl-scram cyrus-sasl-md5 libffi-devel libxml2-devel libxslt-devel postgresql-devel \
    && yum clean all \
    && rm -rf /var/cache/yum
RUN mkdir -p /var/log/airflow
# install airflow
COPY app/hbase-1.0.0.tar.gz /opt/
RUN pip install kafka-python apache-airflow[async,celery,cloudant,crypto,dask,databricks,datadog,devel_hadoop,doc,docker,emr,jdbc,jira,ldap,postgres,qds,redis,salesforce,samba,sendgrid,ssh,statsd,vertica,druid]==${AIRFLOW_VERSION} \
    && pip install /opt/hbase-1.0.0.tar.gz \
    && conda clean --all -y \
    && rm -rf /opt/hbase-1.0.0.tar.gz ~/.cache/pip/*
COPY app/python_operator.py ${USER_PATH}/python3/lib/python3.6/site-packages/airflow/operators/
COPY app/conf/* $AIRFLOW_HOME/
COPY app/bin/airflow-daemon.sh /usr/local/bin/airflow-daemon
RUN chmod +x /usr/local/bin/airflow-daemon
VOLUME [ "$AIRFLOW_HOME/dags", "/opt/baitu", "$AIRFLOW_HOME/logs" ]
EXPOSE 8081 19090
CMD ["/usr/local/bin/airflow-daemon"]
