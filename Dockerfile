FROM casjaysdevdocker/alpine:latest AS build

ARG ALPINE_VERSION="edge"
ARG PHP_VERSION="php7"

ARG LICENSE="MIT"
ARG DEFAULT_DATA_DIR="/usr/local/share/template-files/data"
ARG DEFAULT_CONF_DIR="/usr/local/share/template-files/config"
ARG DEFAULT_TEMPLATE_DIR="/usr/local/share/template-files/defaults"

ARG SERVICE_PORT="9000"
ARG EXPOSE_PORTS="9000"

ARG IMAGE_NAME="php7"
ARG PHP_SERVER="php7"
ARG NODE_VERSION="system"
ARG NODE_MANAGER="system"
ARG BUILD_VERSION="latest"
ARG TIMEZONE="America/New_York"
ARG BUILD_DATE="Mon Nov 14 08:16:21 PM EST 2022"

ARG PACK_LIST="composer ${PHP_VERSION}-apache2 ${PHP_VERSION}-bcmath ${PHP_VERSION}-bz2 ${PHP_VERSION}-calendar ${PHP_VERSION}-cgi ${PHP_VERSION}-common ${PHP_VERSION}-ctype \
  ${PHP_VERSION}-curl ${PHP_VERSION}-dba ${PHP_VERSION}-dev ${PHP_VERSION}-doc ${PHP_VERSION}-dom ${PHP_VERSION}-embed ${PHP_VERSION}-enchant ${PHP_VERSION}-exif ${PHP_VERSION}-ffi \
  ${PHP_VERSION}-fileinfo ${PHP_VERSION}-fpm ${PHP_VERSION}-ftp ${PHP_VERSION}-gd ${PHP_VERSION}-gettext ${PHP_VERSION}-gmp ${PHP_VERSION}-iconv ${PHP_VERSION}-imap ${PHP_VERSION}-intl \
  ${PHP_VERSION}-ldap ${PHP_VERSION}-litespeed ${PHP_VERSION}-mbstring ${PHP_VERSION}-mysqli ${PHP_VERSION}-mysqlnd ${PHP_VERSION}-odbc ${PHP_VERSION}-opcache ${PHP_VERSION}-openssl \
  ${PHP_VERSION}-pcntl ${PHP_VERSION}-pdo ${PHP_VERSION}-pdo_dblib ${PHP_VERSION}-pdo_mysql ${PHP_VERSION}-pdo_odbc ${PHP_VERSION}-pdo_pgsql ${PHP_VERSION}-pdo_sqlite ${PHP_VERSION}-pear \
  ${PHP_VERSION}-pgsql ${PHP_VERSION}-phar ${PHP_VERSION}-phpdbg ${PHP_VERSION}-posix ${PHP_VERSION}-pspell ${PHP_VERSION}-session ${PHP_VERSION}-shmop ${PHP_VERSION}-simplexml ${PHP_VERSION}-snmp \
  ${PHP_VERSION}-soap ${PHP_VERSION}-sockets ${PHP_VERSION}-sodium ${PHP_VERSION}-sqlite3 ${PHP_VERSION}-sysvmsg ${PHP_VERSION}-sysvsem ${PHP_VERSION}-sysvshm ${PHP_VERSION}-tidy ${PHP_VERSION}-tokenizer \
  ${PHP_VERSION}-xml ${PHP_VERSION}-xmlreader ${PHP_VERSION}-xmlwriter ${PHP_VERSION}-xsl ${PHP_VERSION}-zip ${PHP_VERSION}-pecl-memcached  ${PHP_VERSION}-pecl-mcrypt ${PHP_VERSION}-pecl-mongodb ${PHP_VERSION}-pecl-redis"

ENV LANG=en_US.UTF-8
ENV ENV=ENV=~/.bashrc
ENV TZ="America/New_York"
ENV SHELL="/bin/sh"
ENV TERM="xterm-256color"
ENV TIMEZONE="${TZ:-$TIMEZONE}"
ENV HOSTNAME="casjaysdev-php7"

COPY ./rootfs/. /

RUN set -ex; \
  rm -Rf "/etc/apk/repositories"; \
  mkdir -p "${DEFAULT_DATA_DIR}" "${DEFAULT_CONF_DIR}" "${DEFAULT_TEMPLATE_DIR}"; \
  echo "http://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/main" >>"/etc/apk/repositories"; \
  echo "http://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/community" >>"/etc/apk/repositories"; \
  if [ "${ALPINE_VERSION}" = "edge" ]; then echo "http://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/testing" >>"/etc/apk/repositories" ; fi ; \
  apk update --update-cache && apk add --no-cache ${PACK_LIST}

RUN ln -sf "/etc/$PHP_VERSION" "/etc/php" && \
  cp -Rf "/usr/local/share/template-files/config/php/" "/etc/php"

RUN echo 'Running cleanup' ; \
  rm -Rf /usr/share/doc/* /usr/share/info/* /tmp/* /var/tmp/* ; \
  rm -Rf /usr/local/bin/.gitkeep /usr/local/bin/.gitkeep /config /data /var/cache/apk/* ; \
  rm -rf /lib/systemd/system/multi-user.target.wants/* ; \
  rm -rf /etc/systemd/system/*.wants/* ; \
  rm -rf /lib/systemd/system/local-fs.target.wants/* ; \
  rm -rf /lib/systemd/system/sockets.target.wants/*udev* ; \
  rm -rf /lib/systemd/system/sockets.target.wants/*initctl* ; \
  rm -rf /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* ; \
  rm -rf /lib/systemd/system/systemd-update-utmp* ; \
  if [ -d "/lib/systemd/system/sysinit.target.wants" ]; then cd "/lib/systemd/system/sysinit.target.wants" && rm $(ls | grep -v systemd-tmpfiles-setup) ; fi

FROM scratch

ARG \
  SERVICE_PORT \
  EXPOSE_PORTS \
  PHP_SERVER \
  NODE_VERSION \
  NODE_MANAGER \
  BUILD_VERSION \
  LICENSE \
  IMAGE_NAME \
  BUILD_DATE \
  TIMEZONE

LABEL maintainer="CasjaysDev <docker-admin@casjaysdev.com>" \
  org.opencontainers.image.vendor="CasjaysDev" \
  org.opencontainers.image.authors="CasjaysDev" \
  org.opencontainers.image.vcs-type="Git" \
  org.opencontainers.image.name="${IMAGE_NAME}" \
  org.opencontainers.image.base.name="${IMAGE_NAME}" \
  org.opencontainers.image.license="${LICENSE}" \
  org.opencontainers.image.vcs-ref="${BUILD_VERSION}" \
  org.opencontainers.image.build-date="${BUILD_DATE}" \
  org.opencontainers.image.version="${BUILD_VERSION}" \
  org.opencontainers.image.schema-version="${BUILD_VERSION}" \
  org.opencontainers.image.url="https://hub.docker.com/r/casjaysdevdocker/${IMAGE_NAME}" \
  org.opencontainers.image.vcs-url="https://github.com/casjaysdevdocker/${IMAGE_NAME}" \
  org.opencontainers.image.url.source="https://github.com/casjaysdevdocker/${IMAGE_NAME}" \
  org.opencontainers.image.documentation="https://hub.docker.com/r/casjaysdevdocker/${IMAGE_NAME}" \
  org.opencontainers.image.description="Containerized version of ${IMAGE_NAME}" \
  com.github.containers.toolbox="false"

ENV LANG=en_US.UTF-8 \
  ENV=~/.bashrc \
  SHELL="/bin/bash" \
  PORT="${SERVICE_PORT}" \
  TERM="xterm-256color" \
  PHP_SERVER="${PHP_SERVER}" \
  CONTAINER_NAME="${IMAGE_NAME}" \
  TZ="${TZ:-America/New_York}" \
  TIMEZONE="${TZ:-$TIMEZONE}" \
  HOSTNAME="casjaysdev-${IMAGE_NAME}"

COPY --from=build /. /

USER root
WORKDIR /root

VOLUME [ "/config","/data" ]

EXPOSE $EXPOSE_PORTS

#CMD [ "" ]
ENTRYPOINT [ "tini", "-p", "SIGTERM", "--", "/usr/local/bin/entrypoint.sh" ]
HEALTHCHECK --start-period=1m --interval=2m --timeout=3s CMD [ "/usr/local/bin/entrypoint.sh", "healthcheck" ]
