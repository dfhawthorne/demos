-- -----------------------------------------------------------------------------
-- Create a user for the demonstration
--
-- This user will be able to:
-- (1) Connect to the database
-- (2) Create tables and indexes
-- (3) Create PL/SQL procedures
-- (4) Use the DBMS_LOCK package
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Create the user
--
-- =====> Need to supply a value for the DEFINE variable, PW. <=====
--
-- -----------------------------------------------------------------------------

SET VERIFY OFF
DEFINE pw = "password"

CREATE USER deer
    IDENTIFIED BY "&pw."
    DEFAULT TABLESPACE users
    QUOTA UNLIMITED ON user;

-- -----------------------------------------------------------------------------
-- Grant the required privileges
-- -----------------------------------------------------------------------------

GRANT CREATE SESSION TO deer;
GRANT CREATE TABLE TO deer;
GRANT CREATE PROCEDURE TO deer;
GRANT EXECUTE ON dbms_lock TO deer;
