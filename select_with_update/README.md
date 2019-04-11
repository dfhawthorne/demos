Select With Update
==================

These scripts accompany the blog post, [Technical Note on SKIP LOCKED](https://yaocm.wordpress.com/2019/04/02/technical-note-on-skip-locked).

Prerquisites
------------

These scripts have been tested on an Oracle 12.1.0.2 RDBMS database.

# Run the [create_deer_user.sql](../blob/master/create_deer_user.sql) script to create the 'DEER' user with the required privileges.
# Run the [create_nriv_table.sql](../blob/master/create_nriv_table.sql) script to create the base table and associated index.
# Run the [populate_nriv_table.sql](../blob/master/populate_nriv_table.sql) script to populate the base table.