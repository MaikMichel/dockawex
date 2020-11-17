# LICENSE UPL 1.0
#
# Copyright (c) 2018, 2020 Oracle and/or its affiliates.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle Database 18c Express Edition
# 
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# None
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Run: 
#      $ docker build -t oracle/database:18.4.0-xe -f Dockerfile.xe .
#
#
# Pull base image
# ---------------
FROM oraclelinux:7-slim

# Labels
# ------
LABEL "provider"="Oracle"                                               \
      "issues"="https://github.com/oracle/docker-images/issues"         \
      "volume.data"="/opt/oracle/oradata"                               \
      "volume.setup.location1"="/opt/oracle/scripts/setup"              \
      "volume.setup.location2"="/docker-entrypoint-initdb.d/setup"      \
      "volume.startup.location1"="/opt/oracle/scripts/startup"          \
      "volume.startup.location2"="/docker-entrypoint-initdb.d/startup"  \
      "port.listener"="1521"                                            \
      "port.oemexpress"="5500"                                          \
      "port.apex"="8888"

ARG FILE_DB
ARG DB_PASSWORD
ARG DOWNLOAD_URL
ONBUILD RUN if [ -z "${DOWNLOAD_URL}" ]; then echo "DOWNLOAD_URL NOT SET - ERROR"; exit 1; else : ; fi

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV ORACLE_BASE=/opt/oracle \
    ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE \
    ORACLE_SID=XE \
    INSTALL_FILE_1="oracle-database-xe-18c-1.0-1.x86_64.rpm" \
    RUN_FILE="runOracle.sh" \
    PWD_FILE="setPassword.sh" \
    CONF_FILE="oracle-xe-18c.conf" \
    CHECK_SPACE_FILE="checkSpace.sh" \
    CHECK_DB_FILE="checkDBStatus.sh" \
    INSTALL_DIR="$HOME/install" \
    ORACLE_DOCKER_INSTALL="true" \
    ORACLE_PWD=${DB_PASSWORD} \
    DOWNLOAD_BINARIES_FILE="oracle-prepare.sh"

# Use second ENV so that variable get substituted
ENV PATH=$ORACLE_HOME/bin:$PATH

# Copy scripts
# -------------
COPY scripts/$DOWNLOAD_BINARIES_FILE scripts/$CHECK_SPACE_FILE scripts/$RUN_FILE scripts/$PWD_FILE scripts/$CHECK_DB_FILE scripts/$CONF_FILE $INSTALL_DIR/

# Copy binaries
# -------------
COPY _binaries $INSTALL_DIR/

# Download via URL
RUN chmod ug+x $INSTALL_DIR/oracle-prepare.sh; sync && \
  $INSTALL_DIR/oracle-prepare.sh

   
RUN chmod ug+x $INSTALL_DIR/*.sh && \
    sync && \
    $INSTALL_DIR/$CHECK_SPACE_FILE && \
    cd $INSTALL_DIR && \
    yum -y install openssl oracle-database-preinstall-18c && \
    yum -y localinstall $INSTALL_FILE_1 && \
    rm -rf /var/cache/yum && \
    mkdir -p $ORACLE_BASE/scripts/setup && \
    mkdir $ORACLE_BASE/scripts/startup && \
    ln -s $ORACLE_BASE/scripts /docker-entrypoint-initdb.d && \
    mkdir -p $ORACLE_BASE/oradata /home/oracle && \
    chown -R oracle:oinstall $ORACLE_BASE /home/oracle && \
    mv $INSTALL_DIR/$RUN_FILE $ORACLE_BASE/ && \
    mv $INSTALL_DIR/$PWD_FILE $ORACLE_BASE/ && \
    mv $INSTALL_DIR/$CHECK_DB_FILE $ORACLE_BASE/ && \
    mv $INSTALL_DIR/$CONF_FILE /etc/sysconfig/ && \
    ln -s $ORACLE_BASE/$PWD_FILE / && \
    cd $HOME && \
    rm -rf $INSTALL_DIR && \
    chmod ug+x $ORACLE_BASE/*.sh

#VOLUME ["$ORACLE_BASE/oradata"]
#EXPOSE 1521 8080 5500

HEALTHCHECK --interval=1m --start-period=5m \
   CMD "$ORACLE_BASE/$CHECK_DB_FILE" >/dev/null || exit 1

CMD exec $ORACLE_BASE/$RUN_FILE
