-- -----------------------------------------------------------------------------
-- Scenario Establishment
-- ======================
--
-- ===> Run ONLY in a Crash and Burn Database <===
--
-- Run as SYS AS SYSDBA
--
-- This gives erroneous results when querying V$SESSION as a non-SYS user.
-- -----------------------------------------------------------------------------

create or replace view v_$session as select * from v$session where username='DEER';
create or replace public synonym v$session for v_$session;
grant select on v_$session to select_catalog_role;
