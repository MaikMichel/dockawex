#!/bin/bash

export SQLPLUS=sqlplus
SQLPLUS_ARGS="sys/${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SID} as sysdba"
target_dir=/u01/apps
FILE_APEX_PATCH=apex_patch.zip


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


verify(){
  echo "checking DB Connection"

  DB_IS_RW_MODE=$(is_pdb_in_read_write_mode)

  echo "Oracle RW Mode: '${DB_IS_RW_MODE}'"
  if [[ "${DB_IS_RW_MODE}" =~ "true" ]]; then
    echo "Database Connetion is OK"
  else
    echo -e "Database Connection Failed. Connection failed with:\n $SQLPLUS -S $SQLPLUS_ARGS\n `$SQLPLUS -S $SQLPLUS_ARGS` < /dev/null"
    exit 1
  fi
}

apex_install(){
  # when patch included, it has been unzipped, now install it too
  if [ -f /files/$FILE_APEX_PATCH ]
  then
    cd ${target_dir}/apexpatch/*
    echo "Installing Patch $FILE_APEX_PATCH"
    $SQLPLUS -S $SQLPLUS_ARGS <<!
  @catpatch
!
  echo "-----------------------------------------------------------------"
  else
    echo "No Patch $FILE_APEX_PATCH found"
  fi

}


unzip_apex(){
  # when patch file found then unzip
  if [ -f /files/$FILE_APEX_PATCH ]
  then
    echo "Extracting PatchSet $FILE_APEX_PATCH"
    mkdir ${target_dir}/apexpatch
    unzip -q /files/$FILE_APEX_PATCH -d ${target_dir}/apexpatch/
  else
    echo "No PatchSet $FILE_APEX_PATCH found"
  fi
}

downloadFiles(){
  echo "downloading files"
  curl -# --retry 6 -m 1800 --create-dirs -o /files/apex_patch.zip ${URL_APEX_PATCH}
}

updateORDS(){
  # when patch included, it has been unzipped, now install it too
  if [ -f /files/$FILE_APEX_PATCH ]
  then
    echo "Copy files from patch $FILE_APEX_PATCH"
    cp -rf ${target_dir}/apexpatch/*/images/* /tomcat/webapps/i
  else
    echo "No Patchfile $FILE_APEX_PATCH found"
  fi
}

verify
downloadFiles
unzip_apex
apex_install
updateORDS

/etc/init.d/tomcat restart