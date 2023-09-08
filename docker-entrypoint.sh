#!/bin/bash


# export UID=102
# export GID=104
# export LOGNAME=pulse
# export USER=pulse
# export HOME=/home/pulse

export ABCDESKTOP_LOG_DIR=${ABCDESKTOP_LOG_DIR:-'/var/log/desktop'}
export ABCDESKTOP_RUN_DIR=${ABCDESKTOP_RUN_DIR:-'/var/run/desktop'}

# dump for debug
id  >  ${ABCDESKTOP_LOG_DIR}/docker-entrypoint-pulseaudio.log
env >> ${ABCDESKTOP_LOG_DIR}/docker-entrypoint-pulseaudio.log

echo "ls -la $HOME" >> ${ABCDESKTOP_LOG_DIR}/docker-entrypoint-pulseaudio.log
ls -la $HOME        >> ${ABCDESKTOP_LOG_DIR}/docker-entrypoint-pulseaudio.log
echo "ls done"      >> ${ABCDESKTOP_LOG_DIR}/docker-entrypoint-pulseaudio.log
ls -la /etc/pulse   >> ${ABCDESKTOP_LOG_DIR}/docker-entrypoint-pulseaudio.log

CONTAINER_IP_ADDR=$(hostname -i)
echo "Container local ip addr is $CONTAINER_IP_ADDR" >> ${ABCDESKTOP_LOG_DIR}/docker-entrypoint-pulseaudio.log
export CONTAINER_IP_ADDR

# replace CONTAINER_IP_ADDR in listen for pulseaudio
# sed -i "s/module-http-protocol-tcp/module-http-protocol-tcp listen=$CONTAINER_IP_ADDR/g" /etc/pulse/default.pa 
# sed -i "s/module-native-protocol-tcp/module-native-protocol-tcp listen=$CONTAINER_IP_ADDR/g" /etc/pulse/default.pa 


for i in {1..8}
do
   echo "$PULSEAUDIO_COOKIE" >> /etc/pulse/abcdesktopcookie
done


# create the pulse/cookie
# do not let pulseaudio to create it
if [ ! -z "$PULSEAUDIO_COOKIE" ]; then
	if [ ! -f ~/.config/pulse/cookie ]; then
  		mkdir -p ~/.config/pulse
		echo "$PULSEAUDIO_COOKIE" | sha256sum -z > /etc/pulse/abcdesktopcookie
  		# cat /etc/pulse/cookie | openssl rc4 -K "$PULSEAUDIO_COOKIE" -nopad -nosalt > /etc/pulse/abcdesktopcookie
	fi
fi

#mkdir -p /home/balloon/.pulseaudio
# /usr/bin/pulseaudio --log-level=0 --log-target=newfile:/tmp/docker-entrypoint-pulseaudio.pulseaduio.log 
#HOME=/home/balloon/.pulseaudio 
#  -L, --load="MODULE ARGUMENTS"         Load the specified plugin module with
#                                        the specified argument

# --disable-shm=true

/usr/bin/pulseaudio --load="module-http-protocol-tcp listen=$CONTAINER_IP_ADDR"  --load="module-native-protocol-tcp listen=$CONTAINER_IP_ADDR auth-cookie=/etc/pulse/abcdesktopcookie" --log-level=4 -vvvv
#/usr/bin/pulseaudio --load="module-http-protocol-tcp listen=$CONTAINER_IP_ADDR"  --load="module-native-protocol-tcp listen=$CONTAINER_IP_ADDR auth-anonymous=true"
