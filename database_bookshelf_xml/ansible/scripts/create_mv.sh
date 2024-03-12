#!/usr/bin/bash
# ------------------------------------------------------------------------------
# Creates Materialised Views
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

sqlplus / as sysdba <<SQL_DONE
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
WHENEVER OSERROR EXIT FAILURE ROLLBACK

ALTER SESSION SET CONTAINER=${pdb_name};
ALTER SESSION SET current_schema=${user_name};
SET SQLPROMPT ""
SET FEEDBACK OFF
SET SERVEROUTPUT ON SIZE UNLIMITED FORMAT TRUNCATED
SET LINESIZE 120

SPOOL /tmp/create_mv.sql

DECLARE

  PROCEDURE create_mv(p_mv IN VARCHAR2, p_script IN VARCHAR2) IS
    l_found NUMBER := NULL;
  BEGIN
    SELECT
        1 INTO l_found
      FROM dba_objects
      WHERE owner = '${user_name}'
        AND object_name = p_mv
        AND object_type = 'MATERIALIZED VIEW';
      dbms_output.put_line('PROMPT Materialised view ''' || p_mv || ''' already exists in database.');
  EXCEPTION
    WHEN no_data_found THEN
      dbms_output.put_line('@' || p_script);
      dbms_output.put_line('PROMPT Materialised ''' || p_mv || ''' created in database.');
  END create_mv;

BEGIN
  create_mv('BOOKS', 'create_books_mv.sql');
  create_mv('BOOK_LABELS', 'create_book_labels_mv.sql');
  create_mv('BOOK_CONTRIBUTORS', 'create_book_contributors_mv.sql');
END;
/

SPOOL OFF

@/tmp/create_mv.sql

EXIT
SQL_DONE

exit $?
