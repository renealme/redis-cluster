#!/bin/sh

IP=${IP}
M1_PORT=${M1_PORT}
M2_PORT=${M2_PORT}
M3_PORT=${M3_PORT}
R1_PORT=${R1_PORT}
R2_PORT=${R2_PORT}
R3_PORT=${R3_PORT}
LOG_FILE=/redis-cluster.log

ruby redis-trib.rb create --replicas 1 ${IP}:${M1_PORT} ${IP}:${M2_PORT} ${IP}:${M3_PORT} ${IP}:${R1_PORT} ${IP}:${R2_PORT} ${IP}:${R3_PORT} >> ${LOG_FILE} 
tail -f ${LOG_FILE}
