-- -----------------------------------------------------------------------------------------------------------------------------
-- <a href="https://docs.oracle.com/database/121/ADMIN/cdb_dbrm.htm">44 Using Oracle Resource Manager for PDBs with SQL*Plus</a>
-- <a href="https://docs.oracle.com/database/121/ADMIN/cdb_dbrm.htm#ADMIN-GUID-36E58D2B-2873-4ED1-B042-624DB42A5C8E">44.3.1 Creating a CDB Resource Plan: A Scenario</a>
-- -----------------------------------------------------------------------------------------------------------------------------

-- SET ECHO ON

PROMPT Disable CDB Plan

ALTER SYSTEM SET resource_manager_plan='ORA$INTERNAL_CDB_PLAN' SCOPE=BOTH;

PROMPT Drop resource plan

BEGIN
  DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();
  DBMS_RESOURCE_MANAGER.DELETE_CDB_PLAN('jar_cdb_plan');
  DBMS_RESOURCE_MANAGER.VALIDATE_PENDING_AREA();
  DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA();
END;
/

PROMPT  Create a pending area using the CREATE_PENDING_AREA procedure:

exec DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();

PROMPT  Create a CDB resource plan named newcdb_plan using the CREATE_CDB_PLAN procedure:

BEGIN
  DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN(
    plan    => 'jar_cdb_plan',
    comment => 'CDB resource plan for JAR');
END;
/

PROMPT    Create the CDB resource plan directives for the PDBs using the CREATE_CDB_PLAN_DIRECTIVE procedure. Each directive specifies how resources are allocated to a specific PDB.

BEGIN
  DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN_DIRECTIVE(
    plan                  => 'jar_cdb_plan', 
    pluggable_database    => 'PLUM', 
    shares                => 3, 
    utilization_limit     => 100,
    parallel_server_limit => 100);
END;
/

BEGIN
  DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN_DIRECTIVE(
    plan                  => 'jar_cdb_plan', 
    pluggable_database    => 'VEGEMITER', 
    shares                => 3, 
    utilization_limit     => 100,
    parallel_server_limit => 100);
END;
/

BEGIN
  DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN_DIRECTIVE(
    plan                  => 'jar_cdb_plan', 
    pluggable_database    => 'VEGEMITE', 
    shares                => 1, 
    utilization_limit     => 70,
    parallel_server_limit => 70);
END;
/

PROMPT All other PDBs in this CDB use the default PDB directive.

PROMPT Validate the pending area using the VALIDATE_PENDING_AREA procedure:

exec DBMS_RESOURCE_MANAGER.VALIDATE_PENDING_AREA();

PROMPT Submit the pending area using the SUBMIT_PENDING_AREA procedure:

exec DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA();

PROMPT Enable CDB Plan

ALTER SYSTEM SET resource_manager_plan='JAR_CDB_PLAN' SCOPE=BOTH;
