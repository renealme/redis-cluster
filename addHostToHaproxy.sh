#!/bin/sh

Ip=`hostname -I |cut -f1 -d " "`
echo "IP $Ip"
HAfile=/etc/haproxy/haproxy.cfg
SSC=caldelas@caldelas-ThinkCentre-M92p
tmpFile=/tmp/haproxy.cfg
scp $SSC:$HAfile $tmpFile
Ip=`ifconfig | grep "inet addr:9." | cut -f2 -d : | cut -f1 -d " "`
#PORT=7015
echo "PORT $PORT"
##
exist=`cat ${tmpFile} | grep "server" | grep ":" | grep "$Ip" | grep ":$PORT "| wc -l`
echo "Exist $exist"
if [ "$exist" -eq 0 ]; then
        echo "Does not exist yet on the HAProxy.... Lets add it"
        echo "server redis_$PORT $Ip:$PORT check inter 1s" >> ${tmpFile}
        echo "tryng to copy...."
        scp $tmpFile $SSC:/etc/haproxy
        tail ${tmpFile}
        echo "file Copyed..."
fi
echo "Done"
