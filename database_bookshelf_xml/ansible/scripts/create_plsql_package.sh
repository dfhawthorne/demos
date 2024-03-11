#!/usr/bin/bash
# ------------------------------------------------------------------------------
# Creates PL/SQL Package
# ------------------------------------------------------------------------------

user_name="$1"
pdb_name="$2"

if [[ -z "${user_name}" ]]
then
    printf "%s: No user name provided. Exiting...\n" "$0" >&2
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

cd

if [[ ! -r contributor_pkg.sql ]]
then
    printf "%s: Unable to read contributor_pkg.sql. Exiting...\n" "$0" >&2
    exit 1
fi 

if [[ ! -r contributor_pkg_body.sql ]]
then
    printf "%s: Unable to read contributor_pkg_body.sql. Exiting...\n" "$0" >&2
    exit 1
fi 

sqlplus / as sysdba <<SQL_DONE
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
WHENEVER OSERROR EXIT FAILURE ROLLBACK

ALTER SESSION SET CONTAINER=${pdb_name};
ALTER SESSION SET current_schema=${user_name};
SET SQLPROMPT ""
SET FEEDBACK OFF
SET SERVEROUTPUT ON SIZE UNLIMITED FORMAT TRUNCATED
SET LINESIZE 120

SPOOL /tmp/compile_pkg.sql

DECLARE
  l_found NUMBER := NULL;
BEGIN
  BEGIN
    SELECT
        1 INTO l_found
      FROM dba_objects
      WHERE owner = '${user_name}'
        AND object_name = 'CONTRIBUTOR_PKG'
        AND object_type = 'PACKAGE';
      dbms_output.put_line('PROMPT Package ''CONTRIBUTOR_PKG'' already exists in database.');
  EXCEPTION
    WHEN no_data_found THEN
      dbms_output.put_line('@contributor_pkg.sql');
      dbms_output.put_line('PROMPT Package ''CONTRIBUTOR_PKG'' created in database.');
  END;
  BEGIN
    SELECT
        1 INTO l_found
      FROM dba_objects
      WHERE owner = '${user_name}'
        AND object_name = 'CONTRIBUTOR_PKG'
        AND object_type = 'PACKAGE BODY';
      dbms_output.put_line('PROMPT Package Body ''CONTRIBUTOR_PKG'' already exists in database.');
  EXCEPTION
    WHEN no_data_found THEN
      dbms_output.put_line('@contributor_pkg_body.sql');
      dbms_output.put_line('PROMPT Package Body ''CONTRIBUTOR_PKG'' created in database.');
  END;
END;
/
SPOOL OFF
@/tmp/compile_pkg.sql
EXIT
SQL_DONE

exit $?
