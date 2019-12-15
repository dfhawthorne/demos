#!/bin/bash
# ------------------------------------------------------------------------------
# Simple CPU Hog script
# - Requires cpu_hog.sql script
# - Parameters:
#    1: Container Name within JAR CDB
#    2: Number of iterations of CPU Intensive SQL statement (defaults to 10)
# ------------------------------------------------------------------------------

export ORAENV_ASK=NO
export ORACLE_SID=jar
. oraenv
sqlplus / as sysdba @cpu_hog.sql $1 ${2:-10}

exit 0
