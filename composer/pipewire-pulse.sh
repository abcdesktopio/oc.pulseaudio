#!/bin/bash
#
until [ -S "/tmp/runtime/pipewire-0" ]; do sleep 1; done
exec /usr/bin/pipewire-pulse listen=$CONTAINER_IP_ADDR auth-cookie=/etc/pulse/abcdesktopcookie
# --load="module-native-protocol-tcp listen=$CONTAINER_IP_ADDR auth-cookie=/etc/pulse/abcdesktopcookie"
