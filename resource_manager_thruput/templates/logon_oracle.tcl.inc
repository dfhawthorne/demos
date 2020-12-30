# ------------------------------------------------------------------
# Test connection to Oracle database
# The Oratcl package is loaded automatically by the hammerbcli
# command.
# ------------------------------------------------------------------

package require Oratcl

set env(ORACLE_HOME) "/opt/app/oracle/product/12.1.0.2/client"
set instance         "{{ SUT_SERVICE_NAME.split('.')[0] }}"

set lda [oralogon system/"{{ pw_all }}"@$instance]
set sth [oraopen $lda]

if {[oramsg $sth rc] == 0} {
    puts "Successfully connected"
} else {
    puts stderr "Unable to connect to the database."
    exit 1
}

