#!/bin/sh

#IP="9.7.116.148"
#Declaring Variables
tmpFile=/tmp/haproxy.cfg
HAfile=/etc/haproxy/haproxy.cfg.tmp
SSH="caldelas@caldelas-thinkcentre-m92p.gdl.mex.ibm.com"

#get the Docker host IP
IP=`ifconfig |  grep -A 1 em1 | grep "addr:" | cut -f2 -d : | cut -f1 -d " "`
if [ $IP=="" ]; then
        IP=`ifconfig |  grep -A 1 eth0 | grep "inet:" | cut -f2 -d : | cut -f1 -d " "`
fi
##

#whait until the redis for this container get ready
while true
do
        echo -e "Waiting..."
        isUp=`redis-cli -h $IP -p $PORT info`
        if [ "$isUp" != "" ]; then
                break
        fi
done
##
echo IP $IP

#copy remote haproxy file to a local dir
scp -o StrictHostKeyChecking=no $SSH:$HAfile $tmpFile
result=`cat $tmpFile | grep "^server" | cut -f3 -d " "`
#cat $tmpFile
toCluster=""


for i in $result; do
        Ip=`echo $i | cut -f1 -d:`
        Port=`echo $i | cut -f2 -d:`
        echo  -e " i = $i "
        echo Ip $Ip
        echo Port $Port
        toCluster="$toCluster $Ip:$Port"

	echo toCluster $toCluster

        #echo $i
        res=`redis-cli -h $Ip -p $Port cluster slots`
        echo  res $res
        if [ $res=="" ] ; then
                echo "Empty Cluster " $res  
        else
                echo "Starting......"
                res2=`redis-cli -h $Ip -p $Port cluster nodes | grep master | grep -v fail | cut -f1 -d " "`
                for c in $res2
                do
                        res3=`redis-cli -h $Ip -p $Port cluster slaves $c | grep -v fail`
                        if [ ${res3}=="" ]; then
                                portMaster=`redis-cli -h $Ip -p $Port cluster nodes | grep master | grep -v fail | grep $c | cut -f2 -d " " | cut -f2 -d :`
                                echo "-----------------First Slaveless Master $portMaster----------------------"
                                # add anode as slave
				ruby redis-trib.rb add-node --slave $IP:$PORT $Ip:$portMaster
                        fi
                        if [ -n "$portMaster" ];then
                                 break
                        fi
                done
        fi
        echo -e "\n_____________________________________"
        if [ -n "$portMaster" ]; then
                 break
        fi
done
