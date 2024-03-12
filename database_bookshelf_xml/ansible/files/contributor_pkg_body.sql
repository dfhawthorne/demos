CREATE OR REPLACE PACKAGE BODY contributor_pkg IS

    FUNCTION get_contributor (
        p_csr SYS_REFCURSOR
    ) RETURN contributor_tab
        PIPELINED
    IS
        out_rec           contributor_type;
        in_rec            contributor_list_type;
        l_num_contributor NUMBER := 0;
        l_idx_contributor NUMBER := 0;
    BEGIN
        LOOP
            FETCH p_csr INTO in_rec;  -- input row
            EXIT WHEN p_csr%notfound;
            out_rec.id := in_rec.id;
            l_num_contributor := regexp_count(in_rec.contributor_list, '[^,]+');
            FOR l_idx_contributor IN 1..l_num_contributor LOOP
                out_rec.contributor := ltrim(regexp_substr(in_rec.contributor_list, '[^,]+', 1, l_idx_contributor));
                PIPE ROW ( out_rec );
            END LOOP;

        END LOOP;

        CLOSE p_csr;
        RETURN;
    END get_contributor;

END contributor_pkg;
/
