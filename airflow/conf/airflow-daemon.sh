#!/bin/bash

sleep 30
tables=$(mysql -u airflow -p'airflow' -h ${AIRFLOW_METASTORE} -e 'select table_name from information_schema.tables where table_schema="airflow";')
wordsnum=$(echo ${tables} | wc -w)
if [ ${wordsnum} -eq 0 ]; then
	echo 'database airflow is empty, run airflow initdb'
	airflow initdb
fi
airflow webserver -p 8081
