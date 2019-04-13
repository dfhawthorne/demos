-- -----------------------------------------------------------------------------
-- Count the number of rows in the V$SESSION view.
-- -----------------------------------------------------------------------------

SET AUTOTRACE ON EXPLAIN

SELECT count(*) FROM v$session;