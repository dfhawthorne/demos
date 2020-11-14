#!/bin/bash
# ------------------------------------------------------------------------------
# Verifying Client Libraries
# https://hammerdb.com/docs/ch01s06.html
# ------------------------------------------------------------------------------

export ORACLE_HOME={{ oracle_home }}
export PATH=${ORACLE_HOME}/bin:{{ hammerdb_loc }}:${PATH}
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib:${LD_LIBRARY_PATH}

hammerdbcli <<DONE
librarycheck
exit
DONE

