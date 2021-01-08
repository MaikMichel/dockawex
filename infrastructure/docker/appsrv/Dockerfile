FROM ubuntu:14.04

# needed to install correctly
ENV DEBIAN_FRONTEND noninteractive

# here are our db connection values
ENV DB_PASSWORD=${DB_PASSWORD:-secret} \
    DB_HOST=${DB_HOST:-localhost} \
    DB_PORT=1521 \
    DB_SID=${DB_SID:-XEPDB1} \
    DB_HTTP_PORT=8888

# Used when defining SMTP
ENV SMTP_HOST_ADDRESS=${SMTP_HOST_ADDRESS} \
    SMTP_FROM=${SMTP_FROM} \
    SMTP_USERNAME=${SMTP_USERNAME} \
    SMTP_PASSWORD=${SMTP_PASSWORD} \
    INTERNAL_MAIL=${INTERNAL_MAIL}

# we use that for application server
ENV ORDS_PASSWORD ${ORDS_PASSWORD:-secret}
ARG TOM_PASSWORD

RUN apt-get update && apt-get install -y libaio1 unzip curl locales nano
RUN locale-gen de_DE.UTF-8
# NLS
ENV LANG=de_DE.UTF-8 \
    LANGUAGE=de_DE.UTF-8 \
    LC_ALL=de_DE.UTF-8 \
    TZ=Europe/Berlin

# ORDS Port
EXPOSE 8080

# we need our binaries to install
ARG DOWNLOAD_URL
ONBUILD RUN if [ -z "${DOWNLOAD_URL}" ]; then echo "DOWNLOAD_URL NOT SET - ERROR"; exit 1; else : ; fi

ARG FILE_JRE=${FILE_JRE:-}
ARG FILE_JRE_VERSION=${FILE_JRE:-}
ARG FILE_ORDS=${FILE_ORDS}
ARG FILE_TOMCAT=${FILE_TOMCAT}
ARG FILE_APEX=${FILE_APEX}
ARG FILE_CLIENT=${FILE_CLIENT}
ARG FILE_SQLPLUS=${FILE_SQLPLUS}
ARG FILE_INSTANT_CLIENT_VERION=${FILE_INSTANT_CLIENT_VERION}
ARG FILE_APEX_PATCH=${FILE_APEX_PATCH}
ARG APEX_PATCH=${APEX_PATCH}
ARG APEX_IMAGE_PREFIX=${APEX_IMAGE_PREFIX}

ENV FILE_JRE=${FILE_JRE} \
    FILE_JRE_VERSION=${FILE_JRE_VERSION} \
    FILE_ORDS=${FILE_ORDS} \
    FILE_TOMCAT=${FILE_TOMCAT} \
    FILE_APEX=${FILE_APEX} \
    FILE_CLIENT=${FILE_CLIENT} \
    FILE_SQLPLUS=${FILE_SQLPLUS} \
    FILE_INSTANT_CLIENT_VERION=${FILE_INSTANT_CLIENT_VERION} \
    FILE_APEX_PATCH=${FILE_APEX_PATCH} \
    APEX_PATCH=${APEX_PATCH} \
    APEX_IMAGE_PREFIX=${APEX_IMAGE_PREFIX}

# here is our client
ENV LD_LIBRARY_PATH /${FILE_INSTANT_CLIENT_VERION}

# all installation files
COPY scripts /scripts

# Copy files
COPY _binaries /files

# start the installation
RUN chmod +x /scripts/*.sh; sync && /scripts/install_main.sh


# ENTRYPOINT
ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
