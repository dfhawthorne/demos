select version from v$instance;
sys_context('userenv','con_dbid')

select snap_id from dba_hist_snapshot where dbid=DBMS_WORKLOAD_REPOSITORY.LOCAL_AWR_DBID();
