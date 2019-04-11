-- -----------------------------------------------------------------------------
-- Populate the queue with simulated data
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Clear out any existing data
-- -----------------------------------------------------------------------------

TRUNCATE TABLE "DEER"."NRIV";

-- -----------------------------------------------------------------------------
-- Add simulated data
-- -----------------------------------------------------------------------------

INSERT INTO "DEER"."NRIV" ("CLIENT", "SEQUENCE_ID")
  VALUES ( 'ALPHA', 1 );
INSERT INTO "DEER"."NRIV" ("CLIENT", "SEQUENCE_ID")
  VALUES ( 'ALPHA', 2 );
INSERT INTO "DEER"."NRIV" ("CLIENT", "SEQUENCE_ID")
  VALUES ( 'ALPHA', 3 );
INSERT INTO "DEER"."NRIV" ("CLIENT", "SEQUENCE_ID")
  VALUES ( 'ALPHA', 4 );
INSERT INTO "DEER"."NRIV" ("CLIENT", "SEQUENCE_ID")
  VALUES ( 'ALPHA', 5 );
INSERT INTO "DEER"."NRIV" ("CLIENT", "SEQUENCE_ID")
  VALUES ( 'ALPHA', 6 );
INSERT INTO "DEER"."NRIV" ("CLIENT", "SEQUENCE_ID")
  VALUES ( 'ALPHA', 7 );
INSERT INTO "DEER"."NRIV" ("CLIENT", "SEQUENCE_ID")
  VALUES ( 'ALPHA', 8 );
INSERT INTO "DEER"."NRIV" ("CLIENT", "SEQUENCE_ID")
  VALUES ( 'ALPHA', 9 );
INSERT INTO "DEER"."NRIV" ("CLIENT", "SEQUENCE_ID")
  VALUES ( 'ALPHA', 10 );
COMMIT;
