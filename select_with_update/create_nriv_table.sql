-- ------------------------------------------------------------------------------
-- Create base table for a simulated queue.
-- ------------------------------------------------------------------------------

CREATE TABLE "DEER"."NRIV" (
    "CLIENT"
      VARCHAR2(32)
      NOT NULL ,
    "SEQUENCE_ID"
      NUMBER
      NOT NULL ,
    "IS_UPDATED"
      CHAR(1)
      DEFAULT 'N'
      NOT NULL,
    "UPDATED_FROM"
      VARCHAR2(64),
    "UPDATED_TIME"
      TIMESTAMP
);

COMMENT ON TABLE "DEER"."NRIV"
    IS 'Simulated queue of work to be done asynchronously by multiple workers';
    
COMMENT ON COLUMN "DEER"."NRIV"."CLIENT"
    IS 'Partitions queue by client';
COMMENT ON COLUMN "DEER"."NRIV"."SEQUENCE_ID"
    IS 'Differentiates between pieces of work';
COMMENT ON COLUMN "DEER"."NRIV"."IS_UPDATED"
    IS 'A flag indicating that the work has been processed';
COMMENT ON COLUMN "DEER"."NRIV"."UPDATED_FROM"
    IS 'The terminal ID of the worker that made the update';
COMMENT ON COLUMN "DEER"."NRIV"."UPDATED_TIME"
    IS 'When the update was made';

-- -----------------------------------------------------------------------------
-- Create Auxiliary Index
-- -----------------------------------------------------------------------------

CREATE INDEX "DEER"."NRIV_IX1"
  ON "DEER"."NRIV" ("CLIENT", "IS_UPDATED" );
