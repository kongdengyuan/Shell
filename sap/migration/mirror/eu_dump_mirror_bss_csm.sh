#!/bin/bash
#set -ex
DATABASE=$1
IMPORT_DB=$2

IMPORT_HOST=hostname
IMPORT_PORT=PORT
IMPORT_USER=username
IMPORT_PASSWD=paswd
REMOTE_HOST=us-mirror-haproxy

SQL_CMD="mysql -h $IMPORT_HOST -P $IMPORT_PORT -u $IMPORT_USER -p$IMPORT_PASSWD"

# 1605  mysql info
HOST=hostname
PORT=prot
USER=root
PASSWD=passwd
DUMP_DIR=/root/mysql

DATE=`date +%F`

if [ $# -lt 2 ];then

     echo -e "\e[1;35mYou must input two parameter \e[0m"
     echo " Usage: ./dump.sh CSM CSM_US_MIRROR"

     exit 2

fi

dump_db(){

      echo -e "\e[1;34mbegain to export $DATABASE \e[0m"

mysqldump -h $HOST -P $PORT -u $USER -p$PASSWD $DATABASE | gzip -9 -c > ${DUMP_DIR}/${DATE}_${DATABASE}.sql.gz

if [ $? -eq 0  ];then

      echo -e "\e[1;32mExport $DATABASE success  \e[0m"
 
 else
			      
      echo -e "\e[1;31mExport $DATABASE failed   \e[0m"

fi

}

copy_file(){
	
cd $DUMP_DIR
                      
      echo -e "\e[1;34mBegain to copy  $DATABASE \e[0m"

scp ${DUMP_DIR}/${DATE}_${DATABASE}.sql.gz $REMOTE_HOST:/home/sapadmin &>/dev/null && rm ${DUMP_DIR}/${DATE}_${DATABASE}.sql.gz

if [ $? -eq 0 ];then

      echo -e "\e[1;32mCopy file ${DUMP_DIR}/${DATE}_${DATABASE}.sql.gz  success \e[0m"
      
 else

      echo "Copy file failed"

fi

}

import_db(){

      echo -e "\e[1;34mBegain to import  $DATABASE \e[0m"

ssh $REMOTE_HOST "$SQL_CMD -Bse 'show databases'" | grep $IMPORT_DB &>/dev/null

if [ $? -eq 0 ];then

ssh $REMOTE_HOST "$SQL_CMD -Bse \"drop database $IMPORT_DB; create database  $IMPORT_DB\"" && ssh $REMOTE_HOST "zcat ${DATE}_${DATABASE}.sql.gz | $SQL_CMD  $IMPORT_DB" && echo -e "\e[1;32mImport ${DATE}_${DATABASE}.sql.gz  success \e[0m"  && rm -f  ${DUMP_DIR}/${DATE}_${DATABASE}.sql.gz && ssh $REMOTE_HOST "rm -f ${DATE}_${DATABASE}.sql.gz "

 else

ssh $REMOTE_HOST "$SQL_CMD -Bse 'create database if not exists $IMPORT_DB'" && ssh $REMOTE_HOST "zcat ${DATE}_${DATABASE}.sql.gz | $SQL_CMD  $IMPORT_DB" && echo -e "\e[1;32mImport ${DATE}_${DATABASE}.sql.gz  success \e[0m"  && rm -f  ${DUMP_DIR}/${DATE}_${DATABASE}.sql.gz && ssh $REMOTE_HOST "rm -f ${DATE}_${DATABASE}.sql.gz "

fi

}

dump_db $1
copy_file
import_db $2

