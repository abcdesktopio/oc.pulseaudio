#!/bin/bash
PEER_ID=${ABCDESKTOP_USERID:-'front.abcdesktop'}
echo "PEER_ID=$PEER_ID" >> /tmp/webrtc_sendrecv.log
while true
do
  # loop infinitely
  /bin/python3 /sendrecv/webrtc_sendrecv.py --signallingserver ws://${POD_IP}:29787 ${PEER_ID} >> /tmp/webrtc_sendrecv.log
  echo 'end of call, sleeping for 5s' >> /tmp/webrtc_sendrecv.log
  sleep 5
done
