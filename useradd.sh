#!/bin/bash

read -p "Please input a user:" USER

id $USER >&/dev/null

if [ $? -eq 0 ] ; then
echo "$USER already exists"
else
   groupadd $USER && useradd -m $USER -d /home/$USER -g $USER -s /bin/bash &&   echo "Create $USER success !"
fi
