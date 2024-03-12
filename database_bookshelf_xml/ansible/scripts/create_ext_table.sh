#!/usr/bin/bash
# ------------------------------------------------------------------------------
# Creates External Table
# ------------------------------------------------------------------------------

user_name="$1"
pdb_name="$2"
xml_file_name="$3"

if [[ -z "${user_name}" ]]
then
    printf "%s: No user name provided. Exiting...\n" "$0" >&2
    exit 1
fi

if [[ -z "${xml_file_name}" ]]
then
    printf "%s: No XML file name provided. Exiting...\n" "$0" >&2
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
SET SERVEROUTPUT ON

DECLARE
  l_found NUMBER := NULL;
  l_cmd CONSTANT VARCHAR2(1024) :=
    'CREATE TABLE "DATABASE_BOOKSHELF_EXT" 
   (	"OBJECT_VALUE" CLOB
   ) 
   ORGANIZATION EXTERNAL 
    ( TYPE ORACLE_LOADER
      DEFAULT DIRECTORY "XML_DIR"
      ACCESS PARAMETERS
      ( records
    xmltag ("books")
    FIELDS NOTRIM MISSING FIELD VALUES ARE NULL (
      object_value char(1000000)
    )
  )
      LOCATION
       ( ''${xml_file_name}''
       )
    )
   REJECT LIMIT UNLIMITED';
BEGIN
  SELECT
      1 INTO l_found
    FROM dba_external_tables
    WHERE owner = '${user_name}'
      AND table_name = 'DATABASE_BOOKSHELF_EXT';
    dbms_output.put_line('Table ''DATABASE_BOOKSHELF_EXT'' already exists in database.');
EXCEPTION
  WHEN no_data_found THEN
    EXECUTE IMMEDIATE l_cmd;
    dbms_output.put_line('Table ''DATABASE_BOOKSHELF_EXT'' created in database.');
END;
/
EXIT
SQL_DONE

exit $?
