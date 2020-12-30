# ------------------------------------------------------------------------------
# Count the number of objects in the TPC-C schema
# ------------------------------------------------------------------------------

set sql {SELECT count(*) AS num_tpcc_objs FROM dba_objects WHERE owner = :owner}
oraparse $sth $sql
orabind  $sth :owner "TPCC"
oraexec  $sth

if {[set rc [orafetch $sth -datavariable num_tpcc_objs]] != 0} {
    puts stderr "rc=$rc error = [oramsg $sth error]"
    exit 1
} else {
    puts "Number of TPCC objects=$num_tpcc_objs"
}

