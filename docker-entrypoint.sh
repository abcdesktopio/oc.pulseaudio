#!/bin/bash


export ABCDESKTOP_LOG_DIR=${ABCDESKTOP_LOG_DIR:-'/var/log/desktop'}
export ABCDESKTOP_RUN_DIR=${ABCDESKTOP_RUN_DIR:-'/var/run/desktop'}

#export GSTREAMER_PATH=${GSTREAMER_PATH:-/opt/gstreamer}
#export PATH=${GSTREAMER_PATH}/bin:${PATH}
#export LD_LIBRARY_PATH=${GSTREAMER_PATH}/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}
#export GI_TYPELIB_PATH=${GSTREAMER_PATH}/lib/x86_64-linux-gnu/girepository-1.0:/usr/lib/x86_64-linux-gnu/girepository-1.0:${GI_TYPELIB_PATH}
#GST_PY_PATH=$(find ${GSTREAMER_PATH}/lib -type d -name "python3.*")
#export PYTHONPATH=${GST_PY_PATH}/site-packages:${GSTREAMER_PATH}/lib/python3/dist-packages:${PYTHONPATH}



export GSTREAMER_PATH=/
export GI_TYPELIB_PATH=/lib/x86_64-linux-gnu/girepository-1.0:/usr/lib/x86_64-linux-gnu/girepository-1.0
export PYTHONPATH=/lib/python3/dist-packages

# dump for debug
id  >  ${ABCDESKTOP_LOG_DIR}/docker-entrypoint-pulseaudio.log
env >> ${ABCDESKTOP_LOG_DIR}/docker-entrypoint-pulseaudio.log

echo "ls -la $HOME" >> ${ABCDESKTOP_LOG_DIR}/docker-entrypoint-pulseaudio.log
ls -la $HOME        >> ${ABCDESKTOP_LOG_DIR}/docker-entrypoint-pulseaudio.log
echo "ls done"      >> ${ABCDESKTOP_LOG_DIR}/docker-entrypoint-pulseaudio.log
ls -la /etc/pulse   >> ${ABCDESKTOP_LOG_DIR}/docker-entrypoint-pulseaudio.log

echo "Container local ip addr is $POD_IP" >> ${ABCDESKTOP_LOG_DIR}/docker-entrypoint-pulseaudio.log
export LC_ALL=C

# create the pulse/cookie
# do not let pulseaudio to create it
# pulse audio cookie is shared with others containers
# like application containers and X11 container
# create the pulse audio cookie from $PULSEAUDIO_COOKIE value
if [ ! -z "$PULSEAUDIO_COOKIE" ]; then
	echo "creating /etc/pulse/abcdesktopcookie file from PULSEAUDIO_COOKIE env"
	# clear file content
	true > /etc/pulse/abcdesktopcookie
	for i in {1..8}
	do
		echo -n "$PULSEAUDIO_COOKIE" >> /etc/pulse/abcdesktopcookie
	done
	echo "PULSEAUDIO_COOKIE has been built"
else
 	echo "error PULSEAUDIO_COOKIE is not defined, sound goes wrong"
fi

# --disable-shm=true

# Start signalling
# signalling is a simple webrtc signalling server 
/bin/python3 /signalling/simple_server.py --disable-ssl --addr ${POD_IP} --port 29787 > /tmp/signalling.log &

# Start webrtc_sendrecv
# python3 /sendrecv/webrtc_sendrecv.py --signallingserver ws://${POD_IP}:29787 front.abcdesktop &
/sendrecv/loop_sendrecv.sh &

# Start pulse audio with module-native-protocol-tcp listening on POP_IP address
# other modules module-null-sink are loaded in the /etc/pulse/default.pa file
# for virtual speaker and virtual microphone
/usr/bin/pulseaudio --realtime=true --load="module-native-protocol-tcp listen=$POD_IP auth-cookie=/etc/pulse/abcdesktopcookie" --log-level=4 -vvvv 
