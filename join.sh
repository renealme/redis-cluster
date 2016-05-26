#!/bin/sh

echo $PORT
IP="9.7.116.148"

while true
do
        echo -e "Waiting..."
        isUp=`redis-cli -p $PORT info`
        if [ "$isUp" != "" ]; then
                break
        fi
done


for i in 7001 7002 7003 7004 7005 7006
do
        echo $i
        res=`redis-cli -p $i cluster slots`
        #echo $res
        if [ $res=="" ]; then
                echo "Empty Cluster"
        else
                echo "Starting......"
                res2=`redis-cli -p $i cluster nodes | grep master | grep -v fail | cut -f1 -d " "`
                for c in $res2
                do
                        res3=`redis-cli -p $i cluster slaves $c | grep -v fail`
                        if [ $res3=="" ]; then
                                echo -e "c $c"
                                echo "First Slaveless Master"
                                portMaster=`redis-cli -p $i cluster nodes | grep master | grep -v fail | grep $c | cut -f2 -d " " | cut -f2 -d :`
                                ruby redis-trib.rb add-node --slave $IP:$PORT $IP:$portMaster
                        fi
                        if [ -n "$portMaster" ];then
                                 break
                        fi
                done
                echo -e "$res2"

        fi
        echo -e "\n_____________________________________"
        if [ -n "$portMaster" ]; then
                 break
        fi
done
