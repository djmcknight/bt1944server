FROM debian:stretch-slim

LABEL maintainer="derek.mcknight@mcknightsolutions.io"

USER root

RUN apt-get update && \
        apt-get install -y \
                bash \
                binutils \
                curl \
                dnsutils \
                gdb \
                libc6-i386 \
                lib32stdc++6 \
                lib32gcc1 \
                lib32ncurses5 \
                lib32z1 \
                locales \
                net-tools \
                ssmtp \
                sudo \
                tar \
                wget \
                procps

ENV STEAM_APP_ID 805140
ENV EXTERNAL_IP $(dig +short myip.opendns.com @resolver1.opendns.com.)
ENV SERVER_ROOT /home/steam/bt1944server

#Settings for the server
ENV SERVERNAME="Community Server built by djmcknight/bt1944server"
ENV PASSWORD="change_me"
ENV PLAYMODE=Arcade
ENV ADMINSTEAMID=000000000000000
ENV STARTTYPE=ReadyUp
ENV REQUIREDPLAYERS=2

RUN useradd -m steam
RUN su - steam -c "mkdir /home/steam/steamcmd && \
        cd /home/steam/steamcmd && \
        /usr/bin/wget -qO- http://media.steampowered.com/client/steamcmd_linux.tar.gz | tar -xz "


WORKDIR /home/steam

USER steam
RUN set -x \
        && steamcmd/steamcmd.sh \
                +login anonymous \
                +force_install_dir ${SERVER_ROOT} \
                +app_update ${STEAM_APP_ID} validate \
                +quit \
        && mkdir ${SERVER_ROOT}/logs


WORKDIR ${SERVER_ROOT}

USER steam
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/usr/local/lib64:/usr/lib6

CMD ./Linux/Battalion/Binaries/Linux/BattalionServer \
        /Game/Maps/Final_Maps/Derailed?Game=/Script/ShooterGame.BombGameMode?listen \
        -broadcastip=$EXTERNAL_IP \
        -PORT=7777 \
        -QueryPort=7780 \
        -log \
        -logfilesloc=$SERVER_ROOT/logs \
        -defgameini=$SERVER_ROOT/Linux/DefaultGame.ini

EXPOSE 7777 7778 7779 7780