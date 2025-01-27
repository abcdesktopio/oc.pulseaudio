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

#
# like source https://github.com/phoboslab/jsmpeg
# juut remove video and define a fifo as output for fffmpeg 
#
# description
# read from pulse 
# -i speaker.monitor
# and format to mpeg 2 
# 1 channel 
# 128 k
# live option
# to a fifo file /container/speaker
#
exec ffmpeg -f pulse -fragment_size 2000 -ar 44100 -i speaker.monitor -f mpegts -correct_ts_overflow 0 -codec:a mp2 -b:a 128k -ac 1 -muxdelay 0.001 pipe:1 > /container/speaker
