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

# Read first $POD_IP if not set get from hostname -i ip addr
export CONTAINER_IP_ADDR=${POD_IP:-$(hostname -i)}
echo "Container local ip addr is $CONTAINER_IP_ADDR" >> ${ABCDESKTOP_LOG_DIR}/docker-entrypoint-pulseaudio.log
export LC_ALL=C

# create the pulse/cookie
# do not let pulseaudio to create it
if [ ! -z "$PULSEAUDIO_COOKIE" ]; then
	# clear file content
	true > /etc/pulse/abcdesktopcookie
	for i in {1..8}
	do
		echo -n "$PULSEAUDIO_COOKIE" >> /etc/pulse/abcdesktopcookie
	done
else
 	echo "error PULSEAUDIO_COOKIE is not defined, sound goes wrong"
fi

export WEBRELAY_INTERNAL_TCP_PORT=29780

# start supervisord
/usr/bin/supervisord --pidfile /var/run/desktop/supervisord.pid --nodaemon --configuration /etc/supervisord.conf

# --disable-shm=true
# /usr/bin/pulseaudio --load="module-http-protocol-tcp listen=$CONTAINER_IP_ADDR"  --load="module-native-protocol-tcp listen=$CONTAINER_IP_ADDR auth-cookie=/etc/pulse/abcdesktopcookie" 
#/usr/bin/pulseaudio --load="module-http-protocol-tcp listen=$CONTAINER_IP_ADDR"  --load="module-native-protocol-tcp listen=$CONTAINER_IP_ADDR auth-anonymous=true"
