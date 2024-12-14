#!/bin/bash



# create vars
export CONTAINER_IP_ADDR=${POD_IP:-$(hostname -i)}
export PULSE_SERVER=${PULSE_SERVER:-/tmp/.pulse.sock}
export WEBRELAY_INTERNAL_TCP_PORT=${WEBRELAY_INTERNAL_TCP_PORT:-29780}

# wait for pulseaudio unix socket
if [ ! -S "${PULSE_SERVER}" ]; then
        echo "waiting 1 s for $PULSE_SERVER";
        sleep 1s
fi

echo "$PULSE_SERVER is a unix socket"

# npm install -g wait-port
echo "waiting for ${CONTAINER_IP_ADDR}:${WEBRELAY_INTERNAL_TCP_PORT}"
wait-port "${CONTAINER_IP_ADDR}:${WEBRELAY_INTERNAL_TCP_PORT}"
echo "${CONTAINER_IP_ADDR}:${WEBRELAY_INTERNAL_TCP_PORT} is listening"

# start ffmpeg
echo "starting ffmpeg..."
exec ffmpeg -v verbose -f pulse -fragment_size 2000 -ar 44100 -i auto_null.monitor -f mpegts -correct_ts_overflow 0 -codec:a mp2 -b:a 128k -ac 1 -muxdelay 0.001 "http://${CONTAINER_IP_ADDR}:${WEBRELAY_INTERNAL_TCP_PORT}/audioout"
~                                                                                                                                                                                                           
~                               
