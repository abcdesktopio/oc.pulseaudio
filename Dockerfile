FROM ubuntu:22.04

MAINTAINER Alexandre DEVELY

ENV PULSEUID=102
ENV PULSEGID=104
ENV PULSELOGNAME=pulse
ENV PULSEUSER=pulse
ENV PULSEGROUP=pulse

# correct debconf: (TERM is not set, so the dialog frontend is not usable.)
ENV DEBCONF_FRONTEND noninteractive
ENV TERM linux
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Next command use $BUSER context
RUN groupadd --gid $PULSEGID $PULSEUSER
RUN useradd --create-home --shell /bin/bash --uid $PULSEUID -g $PULSEUSER --groups sudo $PULSEUSER

RUN DEBIAN_FRONTEND=noninteractive  apt-get update && apt-get install -y --no-install-recommends\
        pulseaudio                      \
        pulseaudio-utils                \
        && apt-get clean		

# COPY --from=abcdesktopio/oc.pulseaudio:gstreamer /opt/gstreamer /opt/gstreamer
# ENV GSTREAMER_PATH=/opt/gstreamer
# RUN chmod -R 755 /opt/gstreamer/*
# ENV PATH=/opt/gstreamer/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# ENV LD_LIBRARY_PATH=/opt/gstreamer/lib/x86_64-linux-gnu:
# ENV GI_TYPELIB_PATH=/opt/gstreamer/lib/x86_64-linux-gnu/girepository-1.0:/usr/lib/x86_64-linux-gnu/girepository-1.0:
# ENV PYTHONPATH=/site-packages:/opt/gstreamer/lib/python3/dist-packages:


# reduce image size 
# replace previous COPY command
# COPY --from=abcdesktopio/oc.pulseaudio:gstreamer /opt/gstreamer /opt/gstreamer 
# 
# abcdesktopio/oc.pulseaudio:test                         d7e87bfa5b68   19 hours ago    743MB
# abcdesktopio/oc.pulseaudio:3.2                          28ae7368a7e9   45 hours ago    1.25GB
#
# COPY /opt/gstreamer/bin to bin
# COPY /opt/gstreamer/lib to lib 
COPY --from=abcdesktopio/oc.pulseaudio:gstreamer /opt/gstreamer/bin /bin
COPY --from=abcdesktopio/oc.pulseaudio:gstreamer /opt/gstreamer/lib /lib
ENV GSTREAMER_PATH=/
# prevent twice define
# ENV GI_TYPELIB_PATH=/lib/x86_64-linux-gnu/girepository-1.0:/usr/lib/x86_64-linux-gnu/girepository-1.0
# lrwxrwxrwx   1 root root       7 Dec 11 14:04 lib -> usr/lib
ENV GI_TYPELIB_PATH=/lib/x86_64-linux-gnu/girepository-1.0
ENV PYTHONPATH=/lib/python3/dist-packages

# install packages 
RUN DEBIAN_FRONTEND=noninteractive  apt-get update && apt-get install -y --no-install-recommends\
        python3 \
	python3-pip \
	python3-gi-cairo \
        python3-gi \
        python3-pylibsrtp && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install pip3 websockets gobject 
RUN pip3 install websockets
RUN pip3 install gobject

# install packages
RUN DEBIAN_FRONTEND=noninteractive  apt-get update && apt-get install -y --no-install-recommends \
	libpangocairo-1.0 \
	libpango1.0 \
	libva2 \
	libegl1 \
	libx264-163 \
	libmp3lame0 \
        libjpeg8 \
	libva-glx2 \
        libvpx7 \
        libwebp7 \
        libgdk-pixbuf2.0 \
        libgudev-1.0 \
        libva-drm2 \
        libwayland-egl1 \
        libxi6 \
	libwayland-client0 \
	libwayland-cursor0 \
        libopenjp2-7 \
        libxdamage1 \
	libpython3.10 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#
# PREVIOUS packages
#
# RUN DEBIAN_FRONTEND=noninteractive  apt-get update && apt-get install -y --no-install-recommends \
#        libglx0 \
#        libxdamage1 \
#  	 libpython3.10
#        libpangocairo-1.0 \
#        libpango1.0 \
#        libva2 \
#        libegl1 \
#        libopenjp2-7 \
#        libx264-163 \
#        libglx0 \
#        libmp3lame0 \
#        libjpeg8 \
#        libva-glx2 \
#        libvpx7 \
#        libwebp7 \
#        libgdk-pixbuf2.0 \
#        libgudev-1.0 \
#        libva-drm2 \
#        libxdamage1 \
#        libwayland-egl1 \
#        libxi6 \
#        libwayland-cursor0 \
#        libpython3.10
#RUN DEBIAN_FRONTEND=noninteractive  apt-get update && apt-get install -y --no-install-recommends \
# 	 libgudev-1.0 \
#        libgirepository1.0 \
#        libgtk2.0 \
#        libtool-bin \
#        libsoup2.4 \
#        libsoup-gnome2.4 \
#        libopenjp2-7 \
# 	 wayland-protocols \
#	 libgl1 \
#	 libgles1 \
#	 libgles2 \
#	 libgles2-mesa \
#	 libglvnd0 \
#	 libx11-xcb1 \
#	 libxkbcommon0 \
#	 libxkbcommon-x11-0 \
#	 libwayland-cursor0 \
#	 libwayland-client0 \
#	 libwayland-bin \
#	 libwayland-egl1  \
#	 libdrm2 \
#	 libmp3lame0  \
#	 libopus0 \
#	 libpulse0 \
#	 libwebrtc-audio-processing1 \
#	 libsrtp2-1  \
#	 libssl3 \ 
#	 libjpeg8 \
#	 libwebp7 \
#	 libx264-163 \
#	 libvpx7 \
#	 libva2 \
#        libva-drm2 \
#	 libva-glx2 \
#	 libva-wayland2 \ 
#	 libva-x11-2 
#RUN pip3 install PyGObject
#RUN pip3 install pycairo
#RUN pip3 install gobject

# add signalling
COPY /signalling /signalling
RUN chmod 755 /signalling/*

# Add sendrecv
COPY /sendrecv /sendrecv
RUN chmod 755 /sendrecv/*


COPY etc/pulse /etc/pulse
RUN  mkdir /var/log/desktop && chown -R $PULSEUID:$PULSEGID /var/log/desktop && \
     chown -R $PULSEUID:$PULSEGID /etc/pulse && \
     touch /etc/pulse/abcdesktopcookie && chmod 777 /etc/pulse/abcdesktopcookie 

# HACK: be shure to own the home dir 
RUN chown -R $PULSEUSER:$PULSEGROUP /home/$PULSEUSER \
    && echo `date` > /etc/build.date

ENV ABCDESKTOP_LOCALACCOUNT_DIR "/etc/localaccount"
RUN mkdir -p $ABCDESKTOP_LOCALACCOUNT_DIR && \
    for f in passwd shadow group gshadow ; do if [ -f /etc/$f ] ; then  cp /etc/$f $ABCDESKTOP_LOCALACCOUNT_DIR ; rm -f /etc/$f; ln -s $ABCDESKTOP_LOCALACCOUNT_DIR/$f /etc/$f; fi; done


ENV PULSE_SERVER=/tmp/.pulse.sock
COPY docker-entrypoint.sh /docker-entrypoint.sh
USER pulse
CMD /docker-entrypoint.sh

# expose pulseaudio tcp port
#
# 29787 signalling webrtc
EXPOSE 4713 4714 29787 
