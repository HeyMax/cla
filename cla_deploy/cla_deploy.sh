#!/bin/bash
imagename=cla-$1:$(date --rfc-3339=date)
answer='n'
SERVER_IP=$(echo $1)
PORT=$(echo $2)

if [ $# != 2 ]
then
    echo -e 'usage: bash cla_deploy.sh $SERVER_IP $PORT\n'
else
    if [[ $SERVER_IP = $(echo $SERVER_IP|grep -P "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$") ]]
    then
        read -p "WARNING: To set $SERVER_IP:$PORT as server_ip?(y/n):"         
        if [ $REPLY = 'y' ]
        then
           echo -e "FROM docker.io/cartk7/cla-base\nENV HOST_IP $SERVER_IP\nENV HOST_PORT $PORT" > ./dockerfile && docker build -t $imagename -f dockerfile . && nohup docker run -p $PORT:80 $imagename & 
        fi
    else
        echo "INVALID SERVER_IP"
    fi
fi
