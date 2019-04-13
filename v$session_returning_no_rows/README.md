V$session Is Producing Wrong Results For Non Sys Users (Doc ID 1457865.1)
=========================================================================

These files accompany the blog post, [Technical Note on V$session Is Producing Wrong Results For Non Sys Users](https://yaocm.wordpress.com/2019/04/13/technical-note-on-vsession-is-producing-wrong-results-for-non-sys-users), that demonstrates a scenario that was solved by [V$session Is Producing Wrong Results For Non Sys Users (Doc ID 1457865.1)](https://support.oracle.com/epmos/faces/DocContentDisplay?id=1457865.1).

Scenario Establishment
----------------------

# Run ONLY in a Crash and Burn database

1. Run [establish_scenario.sql](../blob/master/establish_scenario.sql) as SYSDBA to damage your data dictionary
1. Run [count_sessions.sql](../blob/master/count_sessions.sql) as SYS and as SYSTEM to see the different results.

Scenario Recovery
-----------------

1. Run [recover_scenario.sql](../blob/master/recover_scenario.sql) as SYSDBA to undo the damage.
