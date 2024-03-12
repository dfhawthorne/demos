CREATE MATERIALIZED VIEW book_contributors AS
  SELECT
      "ID",
      contributor
  FROM
    TABLE (
      contributor_pkg.get_contributor(
        CURSOR(
          SELECT
              c.*
            FROM
              database_bookshelf_ext e,
              XMLTABLE(
                '/books/book'
                PASSING xmltype(e.object_value)
                COLUMNS
                  "ID" VARCHAR2(32) PATH 'id',
                  contributors VARCHAR2(1024) PATH 'contributor'
              ) c
        )
      )
    );
