REM ----------------------------------------------------------------------------
REM CPU Hog Script
REM 
REM Parameters:
REM   1: Container
REM   2: Number of iterations
REM ----------------------------------------------------------------------------

alter session set container=&1.;

SET TIMING ON

DECLARE
  l_result NUMBER := 0;
BEGIN
  FOR i IN 1..&2. LOOP
    SELECT SUM( dbms_random.value() ) INTO l_result FROM dual CONNECT BY LEVEL < 1000000;
  END LOOP;
END;
/
EXIT
