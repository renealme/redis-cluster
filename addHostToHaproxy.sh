#!/bin/sh

#Ip=`hostname -I |cut -f1 -d " "`

HAfile=/etc/haproxy/haproxy.cfg
SSC=caldelas@9.7.121.55
tmpFile=/tmp/haproxy.cfg
scp -o StrictHostKeyChecking=no $SSC:$HAfile $tmpFile
Ip=`ifconfig | grep "inet addr:9." | cut -f2 -d : | cut -f1 -d " "`
echo "IP $Ip"
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
        sleep 2
        ## second try
        echo "---Second Try---"
        scp -o StrictHostKeyChecking=no $SSC:$HAfile $tmpFile
        Ip=`ifconfig | grep "inet addr:9." | cut -f2 -d : | cut -f1 -d " "`
        exist=`cat ${tmpFile} | grep "server" | grep ":" | grep "$Ip" | grep ":$PORT "| wc -l`
        echo "Exist $exist"
        if [ "$exist" -eq 0 ]; then
                echo "Does not exist yet on the HAProxy.... Lets add it"
                echo "server redis_$PORT $Ip:$PORT check inter 1s" >> ${tmpFile}
                echo "tryng to copy...."
                scp $tmpFile $SSC:/etc/haproxy
        fi
        ##
        tail ${tmpFile}
        echo "file Copyed..."
fi
echo "Done"
