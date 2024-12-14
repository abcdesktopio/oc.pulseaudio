#!/bin/bash
exec /usr/bin/pulseaudio --load="module-native-protocol-tcp listen=$CONTAINER_IP_ADDR auth-cookie=/etc/pulse/abcdesktopcookie"
