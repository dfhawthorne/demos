#!/bin/bash
# ------------------------------------------------------------------------------
# Stress test all PDBs using CPU hog script
#
# ./stress_test.sh [-b base_line]
#                  [-i num_iterations]
#                  [-l temp_awr_snapshot_interval]
#                  [-o awr_report]
#                  [-p resource_plan]
#                  [-s job_check_interval]
#                  [-v]
# stress_test.sh -h
#
# Description:
#
#     This script performs a CPU stress test on a preset list of PDBs in the
#     JAR CDB for a given CDB resource plan.
#
#     The AWR snapshots are done automatically and can be used to create an AWR
#     report and/or an AWR baseline, if required.
#
# Options:
#
# -h:
#     Shows this help and exit.
#
# -b:
#     Name of AWR workload baseline to be created based on the snapshots created
#     in this stress test.
#
# -i:
#     Number of iterations of CPU hog SQL statement. Default is ten (10).
#
# -l:
#     Long AWR Snapshot interval - used to enable AWR snapshots without doing
#     any unexpected snapshots. Default is 120 minutes.
#
# -o:
#     Name of file for an AWR workload report (in HTML format) to be created
#     based on the snapshots created in this stress test.
#
# -p:
#     Name of Oracle Resource Manager CDB Plan to be used in this stress test.
#     The default value is 'ORA$INTERNAL_CDB_PLAN'.
#
# -s:
#     Sleep interval between checking for completion of jobs. Default is 60
#     seconds.
#
# -v:
#     Enable verbose mode.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Interpret command line options
# ------------------------------------------------------------------------------

verbose=0

while getopts "b:hi:l:o:p:s:v" opt
do case ${opt} in
    b) baseline_name=${OPTARG};;
    h) show_help=0;;
    i) iterations=${OPTARG};;
    l) awr_interval=${OPTARG};;
    o) awr_file_name=${OPTARG};;
    p) resource_plan=${OPTARG};;
    s) sleep_interval=${OPTARG};;
    v) verbose=$(( verbose + 1 ));;
    *) printf "Invalid arg: opt=%q, OPTARG=%q, OPTIND=%d\n" ${opt} ${OPTARG} ${OPTIND};;
  esac
done

if [ ${show_help} ]
then printf "%s [-b base_line] [-i num_iterations] [-l temp_awr_snapshot_interval] [-o awr_report] [-p resource_plan] [-s job_check_interval] [-v]\n" ${0}
  printf "%s -h\n" ${0}
  printf "\nDescription:\n\n\tThis script performs a CPU stress test on a preset list of PDBs in the JAR CDB for a given CDB resource plan.\n\n"
  printf "\tThe AWR snapshots are done automatically and can be used to create an AWR report and/or an AWR baseline, if required.\n\n"
  printf "Options:\n\n"
  printf "%s:\n\tShows this help and exit.\n\n" "-h"
  printf "%s:\n\tName of AWR workload baseline to be created based on the snapshots created in this stress test.\n\n" "-b"
  printf "%s:\n\tNumber of iterations of CPU hog SQL statement. Default is ten (10).\n\n" "-i"
  printf "%s:\n\tLong AWR Snapshot interval - used to enable AWR snapshots without doing any unexpected snapshots. Default is 120 minutes.\n\n" "-l"
  printf "%s:\n\tName of file for an AWR workload report (in HTML format) to be created based on the snapshots created in this stress test.\n\n" "-o"
  printf "%s:\n\tName of Oracle Resource Manager CDB Plan to be used in this stress test. The default value is 'ORA\$INTERNAL_CDB_PLAN'.\n\n" "-p"
  printf "%s:\n\tSleep interval between checking for completion of jobs. Default is 60 seconds.\n\n" "-s"
  printf "%s:\n\tEnable verbose mode.\n\n" "-v"
  exit 0
fi

# ------------------------------------------------------------------------------
# Set the environment for connection to the JAR CDB
# ------------------------------------------------------------------------------

export ORAENV_ASK=NO
export ORACLE_SID=jar
. oraenv

# ------------------------------------------------------------------------------
# Settings for this stress test
# - A snapshot interval of zero (0) disables all snapshots (including manual
#   ones)
# - The chosen snapshot interval (120) is greater than the expected run time of
#   the entire test.
# - Jobs are checked every minute (60 seconds) to give a one (1) minute
#   granualartity to the AWR reports.
# ------------------------------------------------------------------------------

printf -v new_plan_name "%s" ${resource_plan:-ORA\$INTERNAL_CDB_PLAN}
new_snap_interval=${awr_interval:-120}
job_check_interval=${sleep_interval:-60}
num_iterations=${iterations:-10}

# ------------------------------------------------------------------------------
# Get current settings
# ------------------------------------------------------------------------------

raw_old_plan_name=$(sqlplus -S / as sysdba <<DONE
SET HEADING OFF FEEDBACK OFF
SELECT value FROM v\$parameter WHERE name = 'resource_manager_plan';
EXIT
DONE
)

raw_old_snap_interval=$(sqlplus -S / as sysdba <<DONE
SET HEADING OFF FEEDBACK OFF
SELECT 60*EXTRACT(HOUR FROM snap_interval) + EXTRACT(MINUTE FROM snap_interval) FROM DBA_HIST_WR_CONTROL;
EXIT
DONE
)

printf -v old_plan_name     "%s" ${raw_old_plan_name}
printf -v old_snap_interval "%d" ${raw_old_snap_interval}

if [ ${verbose} -gt 0 ]
then
  printf "Old values: plan=%q, snap_interval=%d\n" ${old_plan_name} ${old_snap_interval}
  printf "New values: plan=%q, snap_interval=%d\n" ${new_plan_name} ${new_snap_interval}
fi

# ------------------------------------------------------------------------------
# Change settings, if needed, for this stress test.
# ------------------------------------------------------------------------------

if [ "${new_plan_name}" != "${old_plan_name}" ]
then
  if [ ${verbose} -gt 0 ]
  then printf "Setting resource manager plan for CDB to '%s'...\n" ${new_plan_name}
  fi

  printf -v sql_cmd "ALTER SYSTEM SET resource_manager_plan='%s';" ${new_plan_name}
  output1=$(sqlplus -S / as sysdba <<DONE
${sql_cmd}
EXIT
DONE
)

  if [ ${verbose} -gt 0 ]
  then printf "${output1}\n"
  fi
fi

if [ ${new_snap_interval} -ne ${old_snap_interval} ]
then
  if [ ${verbose} -gt 0 ]
  then printf "Setting AWR snapshot interval to %d...\n" ${new_snap_interval}
  fi

  output2=$(sqlplus -S / as sysdba <<DONE
EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(interval=>${new_snap_interval});
EXIT
DONE
)

  if [ ${verbose} -gt 0 ]
  then printf "${output2}\n"
  fi
fi

# ------------------------------------------------------------------------------
# Create an AWR snapshot
# ------------------------------------------------------------------------------

if [ ${verbose} -gt 0 ]
then printf "Create AWR snapshot before stress test...\n"
fi

raw_start_snap_id=$(sqlplus -S / as sysdba <<DONE
SET HEADING OFF FEEDBACK OFF
REM Take a manual snapshot
SELECT DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT() FROM DUAL;
EXIT
DONE
)

printf -v start_snap_id "%d" ${raw_start_snap_id}
if [ ${verbose} -gt 0 ]
then printf "Start snapshot ID=%d\n" ${start_snap_id}
fi

# ------------------------------------------------------------------------------
# Start background jobs to hog the CPU on all selected PDBs
# ------------------------------------------------------------------------------

PDBs="PLUM JAM JAM0 JAM1 VEGEMITE VEGEMITER"
for pdb in $PDBs
do
  nohup ./cpu_hog.sh ${pdb} ${num_iterations} >/dev/null 2>&1 &
  if [ ${verbose} -gt 0 ]
  then printf "Job submit for PDB=%s to run over %d iterations\n" ${pdb} ${num_iterations}
  fi
done

# ------------------------------------------------------------------------------
# Wait until all jobs have completed
# ------------------------------------------------------------------------------

while [ $(jobs | wc -l) -gt 0 ]
do
  if [ ${verbose} -gt 0 ]
  then
    printf "$(date) %3d jobs are running:\n" $(jobs | wc -l)
    jobs
  else
    jobs >/dev/null
  fi
  sleep ${job_check_interval}
done

if [ ${verbose} -gt 0 ]
then
  printf "$(date) %3d jobs are running:\n" $(jobs | wc -l)
  jobs
else
  jobs >/dev/null
fi

# ------------------------------------------------------------------------------
# Create an AWR snapshot
# ------------------------------------------------------------------------------

if [ ${verbose} -gt 0 ]
then printf "Create AWR snapshot after stress test...\n"
fi

raw_end_snap_id=$(sqlplus -S / as sysdba <<DONE
SET HEADING OFF FEEDBACK OFF
REM Take a manual snapshot
SELECT DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT() FROM DUAL;
EXIT
DONE
)

printf -v end_snap_id "%d" ${raw_end_snap_id}
if [ ${verbose} -gt 0 ]
then printf "End snapshot ID=%d\n" ${end_snap_id}
fi

# ------------------------------------------------------------------------------
# Restore the database environment after stress test.
# Unless the scheduled maintenance window is in effect, then leave the
# resource plan unchanged. The generated plan is not a valid name.
# ------------------------------------------------------------------------------

case ${old_plan_name} in SCHEDULER*) old_plan_name=${new_plan_name};; esac

if [ "${new_plan_name}" != "${old_plan_name}" ]
then
  if [ ${verbose} -gt 0 ]
  then printf "Setting resource plan to '%s'\n" ${old_plan_name}
  fi

  printf -v sql_cmd "ALTER SYSTEM SET resource_manager_plan='%s';" ${old_plan_name}
  output3=$(sqlplus -S / as sysdba <<DONE
${sql_cmd}
EXIT
DONE
)

  if [ ${verbose} -gt 0 ]
  then printf "${output3}\n"
  fi
fi

if [ ${new_snap_interval} -ne ${old_snap_interval} ]
then
  if [ ${verbose} -gt 0 ]
  then printf "Setting AWR snapshot interval to '%q'\n" "${old_snap_interval}"
  fi

output4=$(sqlplus -S / as sysdba <<DONE
EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(interval=>${old_snap_interval});
EXIT
DONE
)

  if [ ${verbose} -gt 0 ]
  then printf "${output4}\n"
  fi
fi

# ------------------------------------------------------------------------------
# Produce an AWR Report if a file name is provided
# ------------------------------------------------------------------------------

if [ ! -z "${awr_file_name}" ]
then
  if [ ${verbose} -gt 0 ]
  then printf "Produce AWR report to '%s'\n" "${awr_file_name}"
  fi

output5=$(sqlplus -S / as sysdba >"${awr_file_name}" <<DONE
SET PAGESIZE 0 LINESIZE 1500 FEEDBACK OFF HEADING OFF VERIFY OFF
column dbid noprint new_value dbid
column instance_number noprint new_value instance_number
select dbid from v\$database;
select instance_number from v\$instance;
select * from
    table(DBMS_WORKLOAD_REPOSITORY.AWR_REPORT_HTML(
        l_dbid       => &dbid.,
        l_inst_num   => &instance_number.,
        l_bid        => ${start_snap_id},
        l_eid        => ${end_snap_id},
        l_options    => 8));
EXIT
DONE
)

  if [ ${verbose} -gt 0 ]
  then printf "${output5}\n"
  fi
fi

# ------------------------------------------------------------------------------
# Create an AWR Baseline, if required
# ------------------------------------------------------------------------------

if [ ! -z "${baseline_name}" ]
then
  if [ ${verbose} -gt 0 ]
  then printf "Create AWR baseline '%s'\n" "${baseline_name}"
  fi

output6=$(sqlplus -S / as sysdba <<DONE
EXEC DBMS_WORKLOAD_REPOSITORY.CREATE_BASELINE(${start_snap_id},${end_snap_id},'${baseline_name}');
EXIT
DONE
)

  if [ ${verbose} -gt 0 ]
  then printf "${output6}\n"
  fi
fi


exit 0
