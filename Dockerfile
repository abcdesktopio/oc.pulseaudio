FROM ubuntu:24.04

ENV PULSEUID=102
ENV PULSEGID=104
ENV PULSELOGNAME=pulse
ENV PULSEUSER=pulse
ENV PULSEGROUP=pulse

# correct debconf: (TERM is not set, so the dialog frontend is not usable.)
ENV DEBCONF_FRONTEND=noninteractive
ENV TERM=linux
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Next command use $BUSER context
RUN groupadd --gid $PULSEGID $PULSEUSER
RUN useradd --create-home --shell /bin/bash --uid $PULSEUID -g $PULSEUSER --groups $PULSEGID $PULSEUSER 
RUN DEBIAN_FRONTEND=noninteractive  apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
    pulseaudio \
    pulseaudio-utils \
	supervisor \
	libnss-extrausers \
	ffmpeg \
	gnupg \
	curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*		

ENV NODE_MAJOR=20

# install npm nodejs 
# install nodejs
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# copy supervisor configuration
COPY etc /etc

# copy source code
COPY composer /composer

# copy nsswitch.conf
COPY etc/nsswitch.conf /etc/nsswitch.conf

# install websocket-relay speaker
WORKDIR /composer/node/websocket-relay.speaker
RUN npm ci --omit=dev

# install websocket-relay microphone
WORKDIR /composer/node/websocket-relay.microphone
RUN npm ci --omit=dev

WORKDIR /

RUN mkdir -p \
 	/var/run/dbus \
 	/var/log/desktop \
 	/var/run/desktop \
 	/var/run/local \
 	/var/log/local && \
    touch /var/lib/dbus/machine-id  && \
    chmod 777     \
        /var/run/dbus              \
        /var/lib/dbus              \
        /var/lib/dbus/machine-id \
 	/var/log/desktop \
 	/var/run/desktop \
 	/var/run/local \
 	/var/log/local 
RUN chmod 777 /etc/pulse && \
    touch /etc/pulse/abcdesktopcookie && \
    chmod 666 /etc/pulse/abcdesktopcookie 
 
RUN mkdir -m 777 /container

ENV PULSE_SERVER=/tmp/.pulse.sock

# hack: be shure to own the home dir 
RUN chown -R $PULSEUSER:$PULSEGROUP /home/$PULSEUSER
RUN echo `date` > /etc/build.date

COPY docker-entrypoint.sh /docker-entrypoint.sh
USER pulse
CMD [ "/docker-entrypoint.sh" ]
# expose websockert tcp port
EXPOSE 29788 29789

