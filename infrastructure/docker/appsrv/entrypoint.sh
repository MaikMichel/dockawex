#!/bin/bash

exec >> >(tee -ai /docker_log.txt)
exec 2>&1

echo "should we ddns? "
if [[ -z "$DDNS_URL" ]]; then
  echo "DDNS not set"
else
  echo "https://${DDNS_USER}:${DDNS_PASSWORD}@${DDNS_URL}"
  curl https://${DDNS_USER}:${DDNS_PASSWORD}@${DDNS_URL}/ > /dev/null
fi


export SQLPLUS=sqlplus
# SQLPLUS_ARGS="sys/${DB_PASSWORD}@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=${DB_HOST})(Port=${DB_PORT}))(CONNECT_DATA=(SERVICE=${DB_SID}))) as sysdba"
SQLPLUS_ARGS="sys/${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SID} as sysdba"

is_pdb_in_read_write_mode () {
    $SQLPLUS -S -L $SQLPLUS_ARGS <<!
set serveroutput on
set heading off
set feedback off
set pages 0
Declare
  v_banner varchar2(2000);
Begin
  execute immediate 'SELECT decode(open_mode, ''READ WRITE'', ''true'', ''false'') FROM v\$pdbs WHERE name COLLATE BINARY_CI = ''XEPDB1''' into v_banner;
  dbms_output.put_line(v_banner);
exception
  when others then
    dbms_output.put_line('false');
End;
/
!

}


echo "Waiting for 40m ORACLE XE to be ready ..."
COUNTER=0
while [  $COUNTER -lt 20 ]; do
  echo The counter is $COUNTER

  DB_IS_RW_MODE=$(is_pdb_in_read_write_mode)

  echo "Oracle RW Mode: '${DB_IS_RW_MODE}'"
  if [[ "${DB_IS_RW_MODE}" =~ "true" ]]; then
    echo "Database Connetion is OK"
    let COUNTER=20
  else
    echo "waiting ..."
    let COUNTER=COUNTER+1
    sleep 60s
  fi
done

if [ -e "/tomcat/webapps/ords.war" ]; then
  echo "ORDS already installed"
else
  echo "--------------------------------------------------"
  echo "Installing ORACLE APEX............................"
  ./scripts/install_apex.sh

  echo "--------------------------------------------------"
  echo "Installing ORACLE ORDS............................"
  ./scripts/install_ords.sh

  echo "--------------------------------------------------"
  echo "Configuring NginX ................................"
  ./scripts/config_nginx.sh

  echo "--------------------------------------------------"
  echo "Installing Wallets................................"
  ./scripts/install_wallet.sh
fi

echo "--------------------------------------------------"


/etc/init.d/tomcat start

tail -f /dev/null
