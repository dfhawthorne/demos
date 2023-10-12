-- -----------------------------------------------------------------------------
-- Load data into example tables used by C.J.Date 
-- -----------------------------------------------------------------------------

ALTER SESSION SET current_schema=cj_date_examples;

INSERT INTO suppliers(sno,sname,status,city) VALUES('S1','Smith',20,'London');
INSERT INTO suppliers(sno,sname,status,city) VALUES('S2','Jones',10,'Paris');
INSERT INTO suppliers(sno,sname,status,city) VALUES('S3','Blake',30,'Paris');
INSERT INTO suppliers(sno,sname,status,city) VALUES('S4','Clark',20,'London');
INSERT INTO suppliers(sno,sname,status,city) VALUES('S5','Adams',30,'Athens');

INSERT INTO parts(pno,pname,colour,weight,city) VALUES('P1','Nut','Red',12.0,'London');
INSERT INTO parts(pno,pname,colour,weight,city) VALUES('P2','Bolt','Green',17.0,'Paris');
INSERT INTO parts(pno,pname,colour,weight,city) VALUES('P3','Screw','Blue',17.0,'Oslo');
INSERT INTO parts(pno,pname,colour,weight,city) VALUES('P4','Screw','Red',14.0,'London');
INSERT INTO parts(pno,pname,colour,weight,city) VALUES('P5','Cam','Blue',12.0,'Paris');
INSERT INTO parts(pno,pname,colour,weight,city) VALUES('P6','Cog','Red',19.0,'London');

INSERT INTO shipments(sno,pno,qty) VALUES('S1','P1',300);
INSERT INTO shipments(sno,pno,qty) VALUES('S1','P2',200);
INSERT INTO shipments(sno,pno,qty) VALUES('S1','P3',400);
INSERT INTO shipments(sno,pno,qty) VALUES('S1','P4',200);
INSERT INTO shipments(sno,pno,qty) VALUES('S1','P5',100);
INSERT INTO shipments(sno,pno,qty) VALUES('S1','P6',100);
INSERT INTO shipments(sno,pno,qty) VALUES('S2','P1',300);
INSERT INTO shipments(sno,pno,qty) VALUES('S2','P2',400);
INSERT INTO shipments(sno,pno,qty) VALUES('S3','P2',200);
INSERT INTO shipments(sno,pno,qty) VALUES('S4','P2',200);
INSERT INTO shipments(sno,pno,qty) VALUES('S4','P4',300);
INSERT INTO shipments(sno,pno,qty) VALUES('S4','P5',400);

COMMIT;

