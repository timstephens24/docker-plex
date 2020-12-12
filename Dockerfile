FROM timstephens24/ubuntu

# set version label
ARG BUILD_DATE
ARG VERSION
ARG PLEX_RELEASE
LABEL build_version="stephens.cc version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="timstephens24"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"
ENV PLEX_DOWNLOAD="https://downloads.plex.tv/plex-media-server-new"
ENV PLEX_ARCH="amd64"
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support"
ENV PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver"
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6"
ENV PLEX_MEDIA_SERVER_USER="abc"
ENV PLEX_MEDIA_SERVER_INFO_VENDOR="Docker"
ENV PLEX_MEDIA_SERVER_INFO_DEVICE="Docker Container (stephens.cc)"

RUN echo "**** install plex ****" \
  && if [ -z ${PLEX_RELEASE+x} ]; then \
      PLEX_RELEASE=$(curl -sX GET 'https://plex.tv/api/downloads/5.json' | jq -r '.computer.Linux.version'); \
    fi \
  && curl -o /tmp/plexmediaserver.deb -L \
    "${PLEX_DOWNLOAD}/${PLEX_RELEASE}/debian/plexmediaserver_${PLEX_RELEASE}_${PLEX_ARCH}.deb" \
  && dpkg -i /tmp/plexmediaserver.deb \
  && echo "**** ensure abc user's home folder is /app ****" \
  && usermod -d /app abc \
  && echo "**** cleanup ****" \
  && apt-get clean \
  && rm -rf /etc/default/plexmediaserver /tmp/* /var/lib/apt/lists/* /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 32400/tcp 1900/udp 3005/tcp 5353/udp 8324/tcp 32410/udp 32412/udp 32413/udp 32414/udp 32469/tcp
VOLUME /config
