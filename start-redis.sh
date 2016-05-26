#!/bin/sh

PORT=${PORT}
REDIS_CONFIGURATION_FILE=/etc/redis.conf

echo "bind 0.0.0.0" > $REDIS_CONFIGURATION_FILE
echo "port ${PORT}" >> $REDIS_CONFIGURATION_FILE
echo "cluster-enabled yes" >> $REDIS_CONFIGURATION_FILE
echo "cluster-config-file nodes.conf" >> $REDIS_CONFIGURATION_FILE
echo "cluster-node-timeout 5000" >> $REDIS_CONFIGURATION_FILE
echo "appendonly yes" >> $REDIS_CONFIGURATION_FILE

nohup /usr/local/bin/redis-server $REDIS_CONFIGURATION_FILE &
sleep 6
/bin/join.sh 
