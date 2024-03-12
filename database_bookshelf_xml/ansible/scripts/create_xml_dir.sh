#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Creates XML Directory in Database
# ------------------------------------------------------------------------------

xml_dir="$1"
pdb_name="$2"

if [[ -z "${xml_dir}" ]]
then
    printf "%s: No directory provided. Exiting...\n" "$0" >&2
    exit 1
fi

if [[ -z "${pdb_name}" ]]
then
    printf "%s: No PDB Name provided. Exiting...\n" "$0" >&2
    exit 1
fi

if [[ ! -d "${xml_dir}" ]]
then
    printf "%s: Directory '%s' not accessible. Exiting...\n" "$0" "${xml_dir}" >&2
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
  l_found NUMBER := 0;
BEGIN
  SELECT
      1 INTO l_found
    FROM dba_directories
    WHERE directory_name = 'XML_DIR';
    dbms_output.put_line('Directory ''XML_DIR'' already exists in database.');
EXCEPTION
  WHEN no_data_found THEN
    EXECUTE IMMEDIATE 'CREATE DIRECTORY xml_dir AS ''${xml_dir}''';
    dbms_output.put_line('Directory ''XML_DIR'' created in database.');
END;
/
EXIT
SQL_DONE

exit $?
