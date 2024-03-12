CREATE MATERIALIZED VIEW book_labels AS
  SELECT
      l.ID,
      l.label
  FROM
    database_bookshelf_ext e,
  XMLTABLE (
    'for $i in /books/book/labels/label
      return <row>
        {
          $i/../../id,
          $i
        }
      </row>'
    PASSING xmltype(e.object_value)
    COLUMNS
      "ID" VARCHAR2(16) PATH 'id',
      label VARCHAR2(32) PATH 'label'
    ) l;
