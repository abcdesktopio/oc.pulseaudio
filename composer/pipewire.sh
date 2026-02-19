#!/bin/bash
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-'/tmp/runtime'}
export DISABLE_RTKIT=${DISABLE_RTKIT:-'y'}
export DISPLAY=:0
exec /usr/bin/pipewire
# --load="module-native-protocol-tcp listen=$CONTAINER_IP_ADDR auth-cookie=/etc/pulse/abcdesktopcookie"
