FROM oraclelinux:8-slim

LABEL maintainer="maik.michel@die21.de"

# update and install dependencies
#microdnf install -y python38 python3-pip python3-setuptools && \
#microdnf module enable python38 && \
RUN set -x && microdnf install -y unzip tar gzip freetype fontconfig ncurses openssl \
shadow-utils glibc-locale-source glibc-langpack-de java-11-openjdk java-11-openjdk-devel \
oracle-instantclient-release-el8 python3 && \
microdnf update -y && \
microdnf install oracle-instantclient-basic oracle-instantclient-sqlplus && \
rm -Rf /var/cache/yum && \
rm -Rf /var/cache/dnf

# here are our db connection values
ENV DB_PASSWORD=${DB_PASSWORD:-secret} \
    DB_HOST=${DB_HOST:-localhost} \
    DB_PORT=${DB_PORT:-1521} \
    DB_SID=${DB_SID:-XEPDB1} \
    DB_HTTP_PORT=${DB_HTTP_PORT:-8888}

# Used when defining SMTP
ENV SMTP_HOST_ADDRESS=${SMTP_HOST_ADDRESS} \
    SMTP_FROM=${SMTP_FROM} \
    SMTP_USERNAME=${SMTP_USERNAME} \
    SMTP_PASSWORD=${SMTP_PASSWORD} \
    INTERNAL_MAIL=${INTERNAL_MAIL}

# we use that for application server
ENV ORDS_PASSWORD ${ORDS_PASSWORD:-secret}

# NLS
RUN localedef -i de_DE -f UTF-8 de_DE.UTF-8
ENV LANG=de_DE.UTF-8 \
    LANGUAGE=de_DE.UTF-8 \
    LC_ALL=de_DE.UTF-8 \
    TZ=Europe/Berlin

# TOMCAT/ORDS Port
EXPOSE 8080

ARG TOM_PASSWORD=${TOM_PASSWORD}
ARG URL_ORDS=${URL_ORDS}
ARG URL_TOMCAT=${URL_TOMCAT}
ARG URL_APEX=${URL_APEX}
ARG FILE_APEX_PATCH=${FILE_APEX_PATCH}
ARG APEX_IMAGE_PREFIX=${APEX_IMAGE_PREFIX}

ENV URL_ORDS=${URL_ORDS} \
    URL_TOMCAT=${URL_TOMCAT} \
    URL_APEX=${URL_APEX} \
    FILE_APEX_PATCH=${FILE_APEX_PATCH} \
    APEX_IMAGE_PREFIX=${APEX_IMAGE_PREFIX}

# all installation files
COPY scripts /scripts

# Copy files
COPY _binaries /files

# start the installation
RUN set -x && chmod +x /scripts/*.sh; sync && /scripts/install_main.sh


# ENTRYPOINT
ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
