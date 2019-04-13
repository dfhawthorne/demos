-- -----------------------------------------------------------------------------
-- Scenario Recovery
-- =================
--
-- ===> Run ONLY in a Crash and Burn Database <===
--
-- Run as SYS AS SYSDBA
--
-- Undoes the damage by the establish_scenario.sql script.
-- This is the recommended action from MOS DOC Id 1457865.1
-- -----------------------------------------------------------------------------

create or replace view v_$session as select * from v$session;
create or replace public synonym v$session for v_$session;
grant select on v_$session to select_catalog_role;
