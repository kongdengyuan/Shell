#!/bin/bash
HANA_HOST=192.168.0.40
INSTANCE_NUMBER=00
USER=system
PASSWD=Sapkdy@ANW123
HDBSQL_COMMAND="hdbsql -n $HANA_HOST -i $INSTANCE_NUMBER -u $USER -p $PASSWD"

$HDBSQL_COMMAND  "select * from \"MG_STOCKSERVICE\".\"STOCK_ENGINE_DB_VERSION\" " &>/dev/null  &&  $HDBSQL_COMMAND "drop schema  MG_STOCKSERVICE CASCADE " &>/dev/null  && \

echo -e "\e[1;32mDrop MG_STOCKSERVICE schema Success \e[0m" || echo " MG_STOCKSERVICE already droped"

$HDBSQL_COMMAND  "IMPORT \"STOCKSERVICEDB1286\".\"*\" AS BINARY FROM '/usr/sap/NDB/HDB00/backup/data/mnt/backup/stock' WITH REPLACE THREADS 20 RENAME SCHEMA STOCKSERVICEDB1286 to MG_STOCKSERVICE" &>/dev/null && \

rm -f stock.tgz && sudo rm -r /usr/sap/NDB/HDB00/backup/data/mnt/backup/stock && echo -e "\e[1;32mImport MG_STOCKSERVICE schema Success \e[0m"
