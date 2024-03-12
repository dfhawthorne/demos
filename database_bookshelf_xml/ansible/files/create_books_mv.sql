CREATE MATERIALIZED VIEW books AS
  SELECT
      b.ID,
      b.title,
      b.url,
      b.isbn
  FROM
    database_bookshelf_ext e,
    XMLTABLE ( '/books/book'
            PASSING xmltype(e.object_value)
        COLUMNS
            "ID" VARCHAR2(16) PATH 'id',
            url VARCHAR2(512) PATH 'url',
            title VARCHAR2(1024) PATH 'title',
            contributer VARCHAR2(1024) PATH 'contributor',
            isbn VARCHAR2(16) PATH 'identifier/value'
    )                      b;
