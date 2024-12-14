#!/bin/bash
# npm install -g wait-port
echo "waiting for ${CONTAINER_IP_ADDR}:${WEBRELAY_INTERNAL_TCP_PORT}"
wait-port "${CONTAINER_IP_ADDR}:${WEBRELAY_INTERNAL_TCP_PORT}"
# start ffmpeg
export PULSE_SERVER
exec ffmpeg -v verbose -f pulse -fragment_size 2000 -ar 44100 -i default -f mpegts -correct_ts_overflow 0 -codec:a mp2 -b:a 128k -ac 1 -muxdelay 0.001 "http://${CONTAINER_IP_ADDR}:${WEBRELAY_INTERNAL_TCP_PORT}/audioout"
