#!/bin/bash

read -p "Please input a user:" USER

id $USER >&/dev/null

if [ $? -eq 0 ] ; then
echo -e "\e[1;31m$USER already exists\e[0m"
else
   groupadd $USER && useradd -m $USER -d /home/$USER -g $USER -s /bin/bash &&   echo -e "\e[1;32mCreate user Success ! \e[0m"
fi
