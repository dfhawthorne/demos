-- -----------------------------------------------------------------------------
-- Load data into example tables used by C.J.Date 
-- -----------------------------------------------------------------------------

CREATE USER cj_date_examples NO AUTHENTICATION;

CREATE SCHEMA AUTHORIZATION cj_date_examples
  CREATE TABLE suppliers (
    sno
      CHAR(02)
      CONSTRAINT suppliers_pk PRIMARY KEY,
    sname
      VARCHAR2(10)
      CONSTRAINT suppliers_sname_nn NOT NULL,
    status
      NUMBER(2,0)
      CONSTRAINT suppliers_status_nn NOT NULL,
    city
      VARCHAR2(10)
      CONSTRAINT suppliers_city_nn NOT NULL
    )
  CREATE TABLE parts (
    pno
      CHAR(02)
      CONSTRAINT parts_pk PRIMARY KEY,
    pname
      VARCHAR2(10)
      CONSTRAINT parts_pname_nn NOT NULL,
    colour
      VARCHAR2(10)
      CONSTRAINT parts_colour_nn NOT NULL,
    weight
      NUMBER(3,1)
      CONSTRAINT parts_weight_nn NOT NULL,
    city
      VARCHAR2(10)
      CONSTRAINT suppliers_city_nn NOT NULL
    )
  CREATE TABLE shipments (
    sno
      CHAR(02)
      CONSTRAINT shipments_sno_nn NOT NULL
      CONSTRAINT shipments_sno_fk REFERENCES suppliers,
    pno
      CHAR(02)
      CONSTRAINT shipments_pno_nn NOT NULL
      CONSTRAINT shipments_pno_fk REFERENCES parts,
    qty
      NUMBER(3,0)
      CONSTRAINT shipments_qty_nn NOT NULL,
    CONSTRAINT PRIMARY KEY( sno, pno )
    )
  GRANT ALL ON suppliers TO demo
  GRANT ALL ON parts TO demo
  GRANT ALL ON shipments TO demo
;

