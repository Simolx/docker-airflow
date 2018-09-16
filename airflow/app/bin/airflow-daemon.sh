#!/bin/bash

ping -c 3 db
db_connected=$?
while [ "$db_connected" != "0" ]; do
	echo "sleep 3 seconds for db container up"
	sleep 3
	ping -c 3 db
	db_connected=$?
done

tables=$(mysql -u airflow -p'airflow' -h ${AIRFLOW_METASTORE} -e 'select table_name from information_schema.tables where table_schema="airflow";')
while [ "$?" != "0" ]; do
	echo "sleep 5 seconds for db service start up"
	sleep 5
    tables=$(mysql -u airflow -p'airflow' -h ${AIRFLOW_METASTORE} -e 'select table_name from information_schema.tables where table_schema="airflow";')
done

wordsnum=$(echo ${tables} | wc -w)
if [ ${wordsnum} -eq 0 ]; then
	echo 'database airflow is empty, run airflow initdb'
	airflow initdb
fi
airflow webserver -p 8081
