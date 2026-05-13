#!/bin/bash

# ffmpeg.speaker.sh
#
# Purpose:
# - Capture audio from the PulseAudio monitor source `speaker.monitor`.
# - Transcode the live stream to MPEG-TS with MP2 audio.
# - Write the resulting stream into the FIFO `/container/speaker`.
#
# Runtime contract:
# - Input: PulseAudio server socket `${PULSE_SERVER}` (default: /tmp/.pulse.sock).
# - Input: PulseAudio source `speaker.monitor`.
# - Output: MPEG-TS audio stream to `/container/speaker`.
# - Consumer: websocket relay process that reads `/container/speaker` and exposes TCP websocket audio.
#
# Environment variables:
# - POD_IP: optional container IP override.
# - PULSE_SERVER: PulseAudio unix socket path.
# - WEBRELAY_INTERNAL_TCP_PORT: relay internal port metadata.

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
