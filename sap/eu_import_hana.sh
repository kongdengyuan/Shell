#!/bin/bash
#set -ex
## For 1605 info
HOST=hostname
PASSWORD=passwd
USER=username
INSTANCE_NUMBER=00
DUMP_DIR=/mnt/backup
DB_SCHEMA=$1
T_DIR=$2

## For mirror info
REMOTE_HANA=us-mirror-hana
IMPORT_DIR=/usr/sap/NDB/HDB00/backup/data

### Dump schema DB

[ -d ${DUMP_DIR}/${T_DIR} ] || mkdir ${DUMP_DIR}/${T_DIR}  && chmod 777 ${DUMP_DIR}/${T_DIR}

echo -e "\e[1;34mBegin to dump  schema \e[0m"

hdbsql -n $HOST -i $INSTANCE_NUMBER -u $USER -p $PASSWORD "export ${DB_SCHEMA}.\"*\" as binary into '${DUMP_DIR}/${T_DIR}' with threads 20 " &>/dev/null

cd ${DUMP_DIR}/${T_DIR}/export/$1/PA

sudo rm -r PAL_LITE_APRIORI_RULE_PROC PAL_LITEAPRIORI_RESULT_T  && cd &&  echo -e "\e[1;32mExport  schema success \e[0m"

if [ $? -eq 0 ] ; then
   
    echo -e "\e[1;34mBegin to compress  schema \e[0m"
 
    sudo tar zcf ${DUMP_DIR}/${T_DIR}.tgz ${DUMP_DIR}/${T_DIR} &>/dev/null && sudo rm -r ${DUMP_DIR}/${T_DIR}  && echo -e "\e[1;32mCompress schema Success \e[0m"

else
    
    echo -e "\e[1;33mDump schema failed  \e[0m"

fi

### Copy file to mirror or MSA  hana server

    echo -e "\e[1;34mBegin to copy  file \e[0m"

scp ${DUMP_DIR}/${T_DIR}.tgz  $REMOTE_HANA:/home/sapadmin &>/dev/null && sudo rm ${DUMP_DIR}/${T_DIR}.tgz || echo -e "\e[1;31mCopy file failed \e[0m"

ssh $REMOTE_HANA "sudo tar xf ${T_DIR}.tgz -C $IMPORT_DIR" &>/dev/null && echo -e "\e[1;32mUnzip schema Success \e[0m"

    echo -e "\e[1;34mBegin to import schema \e[0m"

### Import schema DB

ssh $REMOTE_HANA "bash eu_import_schema.sh $DB_SCHEMA $T_DIR"

