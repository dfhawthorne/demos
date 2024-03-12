CREATE OR REPLACE PACKAGE contributor_pkg AUTHID current_user IS
    TYPE contributor_list_type IS RECORD (
        "ID"             VARCHAR2(32),
        contributor_list VARCHAR2(1024)
    );
    TYPE contributor_type IS RECORD (
        "ID"        VARCHAR2(32),
        contributor VARCHAR2(64)
    );
    TYPE contributor_tab IS
        TABLE OF contributor_type;
    FUNCTION get_contributor (
        p_csr sys_refcursor
    ) RETURN contributor_tab
        PIPELINED;

END contributor_pkg;