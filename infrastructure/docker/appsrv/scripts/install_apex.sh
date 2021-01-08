#!/bin/bash

export SQLPLUS=/${FILE_INSTANT_CLIENT_VERION}/sqlplus
SQLPLUS_ARGS="sys/${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SID} as sysdba"
target_dir=/u01/apps

is_apex_040000_deinstalled () {
    $SQLPLUS -S $SQLPLUS_ARGS <<!
    set heading off
    set feedback off
    set pages 0
    with checksql as (select count(1) cnt
  from all_users
 where username = 'APEX_040000')
 select case when cnt = 1 then 'false' else 'true' end ding
   from checksql;
!
}

verify(){
  echo "exit" | ${SQLPLUS} -L $SQLPLUS_ARGS | grep Connected > /dev/null
  if [ $? -eq 0 ]; then
    echo "Database Connetion is OK"

    echo "Waiting for APEX_040000 to be removed"

    COUNTER=0
    while [  $COUNTER -lt 10 ]; do
      echo "The counter is $COUNTER"
      APEX_DEINSTALLED=$(is_apex_040000_deinstalled)

      echo "Apex deinstalled: '${APEX_DEINSTALLED}'"
      if [ "${APEX_DEINSTALLED}" = "true" ]
      then
        echo "Database Connetion is OK"
        let COUNTER=10
      else
        let COUNTER=COUNTER+1
        sleep 60s
      fi
    done

  else
    echo -e "Database Connection Failed. Connection failed with:\n $SQLPLUS -S $SQLPLUS_ARGS\n `$SQLPLUS -S $SQLPLUS_ARGS` < /dev/null"
    exit 1
  fi
}

create_apex_tablespace(){
  cd ${target_dir}/apex

  echo "Creating tablespace APEX"

  $SQLPLUS -S $SQLPLUS_ARGS <<!  
  CREATE TABLESPACE APEX DATAFILE '/opt/oracle/oradata/XE/XEPDB1/apex01.dbf' SIZE 100M AUTOEXTEND ON NEXT 10M;
!
  echo "-----------------------------------------------------------------"

}

apex_install(){
  cd ${target_dir}/apex

  echo "Installing apex..."

  $SQLPLUS -S $SQLPLUS_ARGS <<!
  @apexins APEX APEX TEMP /i/
!
  echo "-----------------------------------------------------------------"

  # when patch included, it has been unzipped, now install it too
  if [ -f /files/$FILE_APEX_PATCH ]
  then
    cd ${target_dir}/$APEX_PATCH
    echo "Installing Patch $APEX_PATCH"
    $SQLPLUS -S $SQLPLUS_ARGS <<!
  @catpatch
!
  echo "-----------------------------------------------------------------"
  else
    echo "No Patch $APEX_PATCH found"
  fi


  # set image-prexix
  if [[ ! -z ${APEX_IMAGE_PREFIX} ]]; then
    echo "-----------------------------------------------------------------"
    cd ${target_dir}/apex/utilities
    echo "setting Image Prefix to ${APEX_IMAGE_PREFIX}"  
    $SQLPLUS -S $SQLPLUS_ARGS <<!
  @reset_image_prefix_core.sql ${APEX_IMAGE_PREFIX}
!

  fi

}




apex_config(){
  echo "Configuring apex..."
  cd ${target_dir}/apex

  $SQLPLUS -S $SQLPLUS_ARGS <<!

  Prompt setting PWD for APEX_PUBLIC_USER
  alter user APEX_PUBLIC_USER identified by "$ORDS_PASSWORD" account unlock;

  Prompt calling apex_rest_config_core
  @apex_rest_config_core @ $ORDS_PASSWORD $ORDS_PASSWORD

  Prompt setting ACLS
  -- From Joels blog: http://joelkallman.blogspot.ca/2017/05/apex-and-ords-up-and-running-in2-steps.html
  declare
    l_acl_path varchar2(4000);
    l_apex_schema varchar2(100);
  begin
    for c1 in (
      select schema
      from sys.dba_registry
      where comp_id = 'APEX') loop
        l_apex_schema := c1.schema;
    end loop;

    sys.dbms_network_acl_admin.append_host_ace(
      host => '*',
      ace => xs\$ace_type(privilege_list => xs\$name_list('connect'),
      principal_name => l_apex_schema,
      principal_type => xs_acl.ptype_db));
    commit;
  end;
  /


PROMPT  =============================================================================
PROMPT  ==   CLEAR ACLs
PROMPT  =============================================================================
PROMPT
DECLARE
  v_check number(1);
BEGIN
  begin
    select 1
      into v_check
      from dba_network_acls
     where acl = '/sys/acls/smtp-permissions-DOCKAWEX.xml';

    dbms_network_acl_admin.drop_acL(acl => 'smtp-permissions-DOCKAWEX.xml');
  exception
    when no_data_found then
      null;
  end;

  begin
    select 1
      into v_check
      from dba_network_acls
     where acl = '/sys/acls/http-permissions-DOCKAWEX.xml';

    dbms_network_acl_admin.drop_acl(acl => 'http-permissions-DOCKAWEX.xml');
  exception
    when no_data_found then
      null;
  end;

   commit;
END;
/

PROMPT  =============================================================================
PROMPT  ==   SETUP ACL SMTP
PROMPT  =============================================================================
PROMPT
begin
  dbms_network_acl_admin.create_acl (acl         => 'smtp-permissions-DOCKAWEX.xml',
                                     description => 'Permissions for smtp',
                                     principal   => '${APEX_USER}',
                                     is_grant    => true,
                                     privilege   => 'connect');

  dbms_network_acl_admin.assign_acl (acl        => 'smtp-permissions-DOCKAWEX.xml',
                                     host       => '*',
                                     lower_port => 25,
                                     upper_port => 25);
  commit;
end;
/

PROMPT  =============================================================================
PROMPT  ==   SETUP ACL HTTP-PROXY
PROMPT  =============================================================================
PROMPT
begin
  dbms_network_acl_admin.create_acl (acl          => 'http-permissions-DOCKAWEX.xml',
                                     description  => 'An ACL for wildcard',
                                     principal    => '${APEX_USER}',
                                     is_grant     => TRUE,
                                     privilege    => 'connect');

  dbms_network_acl_admin.assign_acl (acl         => 'http-permissions-DOCKAWEX.xml',
                                     host        => '*',
                                     lower_port  => 3000,
                                     upper_port  => 3000);
  commit;
end;
/

PROMPT  =============================================================================
PROMPT  ==   SETUP INTERNAL
PROMPT  =============================================================================
PROMPT

alter session set current_schema=${APEX_USER};
begin
  wwv_flow_security.g_security_group_id := 10;
  wwv_flow_security.g_user              := 'admin';
  wwv_flow_fnd_user_int.create_or_update_user( p_user_id  => NULL,
                                                p_username => 'admin',
                                                p_email    => '${INTERNAL_MAIL}',
                                                p_password => '${DB_PASSWORD}'||'!' );
  commit;
end;
/


PROMPT  =============================================================================
PROMPT  ==   SETUP SMTP
PROMPT  =============================================================================
PROMPT INTERNAL_MAIL:     ${INTERNAL_MAIL}
PROMPT SMTP_HOST_ADDRESS: ${SMTP_HOST_ADDRESS}
PROMPT SMTP_FROM:         ${SMTP_FROM}
PROMPT SMTP_USERNAME:     ${SMTP_USERNAME}
PROMPT  =============================================================================
BEGIN

  apex_instance_admin.set_parameter('SMTP_HOST_ADDRESS', '${SMTP_HOST_ADDRESS}');
  apex_instance_admin.set_parameter('SMTP_FROM', '${SMTP_FROM}');
  apex_instance_admin.set_parameter('SMTP_USERNAME', '${SMTP_USERNAME}');
  apex_instance_admin.set_parameter('SMTP_PASSWORD', '${SMTP_PASSWORD}');

  commit;

  apex_mail.send(p_from => '${SMTP_FROM}'
                ,p_to   => '${INTERNAL_MAIL}'
                ,p_subj => 'DOCKAWEX successfully installed'
                ,p_body => 'Test Hey ho, that works');

  apex_mail.push_queue();
END;
/

!

}

unzip_apex(){
  echo "Extracting ${FILE_APEX}"
  rm -rf ${target_dir}/apex
  unzip -q /files/$FILE_APEX -d ${target_dir}/

  # when patch file found then unzip
  if [ -f /files/$FILE_APEX_PATCH ]
  then
    unzip -q /files/$FILE_APEX_PATCH -d ${target_dir}/
  fi
}


set_pwd_profile () {
    $SQLPLUS -S $SQLPLUS_ARGS <<!
    ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
!
}


verify
unzip_apex
create_apex_tablespace
apex_install
apex_config
set_pwd_profile

