#!/usr/bin/bash
# ------------------------------------------------------------------------------
# Creates Database User
# ------------------------------------------------------------------------------

user_name="$1"
user_pw="$2"
pdb_name="$3"

if [[ -z "${user_name}" ]]
then
    printf "%s: No user name provided. Exiting...\n" "$0" >&2
    exit 1
fi

if [[ -z "${user_pw}" ]]
then
    printf "%s: No user password provided. Exiting...\n" "$0" >&2
    exit 1
fi

if [[ -z "${pdb_name}" ]]
then
    printf "%s: No PDB Name provided. Exiting...\n" "$0" >&2
    exit 1
fi

export ORACLE_HOME="/opt/oracle/product/21c/dbhomeXE"
export ORACLE_SID=XE

case ":${PATH}:" in
    "*:${ORACLE_HOME}/bin:*") ;;
    *) export PATH="${ORACLE_HOME}/bin:${PATH}" ;;
esac

sqlplus_cmd=$(command -v sqlplus)
if [[ -z "${sqlplus_cmd}" ]]
then
    printf "%s: Unable to find SQL*Plus command. Exiting...\n" "$0" >&2
    exit 1
fi

sqlplus / as sysdba <<SQL_DONE
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
WHENEVER OSERROR EXIT FAILURE ROLLBACK

ALTER SESSION SET CONTAINER=${pdb_name};
SET SERVEROUTPUT ON

DECLARE
  l_found NUMBER := NULL;

  PROCEDURE grant_sys_priv( p_sys_priv IN VARCHAR2 ) IS
    l_found NUMBER := NULL;
  BEGIN
    SELECT
        1 INTO l_found
      FROM dba_sys_privs
      WHERE grantee = '${user_name}'
        AND privilege = p_sys_priv;
      dbms_output.put_line('User ''${user_name}'' already has ''' || p_sys_priv || ''' privilege.');
  EXCEPTION
    WHEN no_data_found THEN
      EXECUTE IMMEDIATE 'GRANT CREATE ' || p_sys_priv || ' TO ${user_name}';
      dbms_output.put_line('User ''${user_name}'' granted ''' || p_sys_priv || ''' privilege.');
  END;

  PROCEDURE grant_obj_priv( p_obj_priv IN VARCHAR2 ) IS
    l_found NUMBER := NULL;
  BEGIN
    SELECT
        1 INTO l_found
      FROM dba_tab_privs
      WHERE grantee = '${user_name}'
        AND table_name = 'XML_DIR'
        AND privilege = p_obj_priv
        AND type = 'DIRECTORY';
      dbms_output.put_line('User ''${user_name}'' already has ''' || p_obj_priv || ''' privilege on ''XML_DIR'' directory.');
  EXCEPTION
    WHEN no_data_found THEN
      EXECUTE IMMEDIATE 'GRANT ' || p_obj_priv || ' ON DIRECTORY xml_dir TO ${user_name}';
      dbms_output.put_line('User ''${user_name}'' granted ''' || p_obj_priv || ''' privilege on ''XML_DIR'' directory.');
  END;
  
BEGIN
  BEGIN
    SELECT
        1 INTO l_found
      FROM dba_users
      WHERE username = '${user_name}';
      dbms_output.put_line('User ''${user_name}'' already exists in database.');
  EXCEPTION
    WHEN no_data_found THEN
      EXECUTE IMMEDIATE 'CREATE USER ${user_name} IDENTIFIED BY "${user_pw}" DEFAULT TABLESPACE users QUOTA UNLIMITED ON users';
      dbms_output.put_line('User ''${user_name}'' created in database.');
  END;
  grant_sys_priv('CREATE MATERIALIZED VIEW');
  grant_sys_priv('CREATE VIEW');
  grant_sys_priv('CREATE SESSION');
  grant_sys_priv('CREATE TABLE');
  grant_sys_priv('CREATE PROCEDURE');
  grant_obj_priv('READ');
  grant_obj_priv('WRITE');
END;
/
EXIT
SQL_DONE

exit $?
