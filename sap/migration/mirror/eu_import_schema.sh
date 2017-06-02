#!/bin/bash
HANA_HOST=hostname
INSTANCE_NUMBER=00
USER=username
PASSWD=passwd
HDBSQL_COMMAND="hdbsql -n $HANA_HOST -i $INSTANCE_NUMBER -u $USER -p $PASSWD"
DB_SCHEMA=$1
T_DIR=$2
IMPORT_DIR=/usr/sap/NDB/HDB00/backup/data/mnt/backup

$HDBSQL_COMMAND "\ds" | grep $DB_SCHEMA &>/dev/null

if [ $? -eq 0 ];then 
    echo -e "\e[1;31mSchema already imported\e[0m"
$HDBSQL_COMMAND "\ds" | grep $DB_SCHEMA | cut -d',' -f1  | sed 's/"//g'| awk '{print "drop schema "$1" cascade"}' | $HDBSQL_COMMAND &>/dev/null && echo -e "\e[1;31mDrop schema success\e[0m"  && 
$HDBSQL_COMMAND "IMPORT ${DB_SCHEMA}.\"*\" AS BINARY FROM '${IMPORT_DIR}/${T_DIR}' with threads 20" &>/dev/null && rm ${T_DIR}.tgz && sudo rm -r ${IMPORT_DIR}/${T_DIR}&& echo -e "\e[1;32mImport schema Success \e[0m"
 else
$HDBSQL_COMMAND "IMPORT ${DB_SCHEMA}.\"*\" AS BINARY FROM '${IMPORT_DIR}/${T_DIR}' with threads 20" &>/dev/null && rm ${T_DIR}.tgz  &&  sudo rm -r ${IMPORT_DIR}/${T_DIR} &&  echo -e "\e[1;32mImport schema Success \e[0m"
fi

