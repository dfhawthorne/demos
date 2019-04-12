Select With Update
==================

These scripts accompany the blog post, [Technical Note on SKIP LOCKED](https://yaocm.wordpress.com/2019/04/13/technical-note-on-skip-locked/). (**Published 2019-04-13**)

Prerequisites
-------------

These scripts have been tested on an Oracle 12.1.0.2 RDBMS database.

1. Run the [create_deer_user.sql](../blob/master/create_deer_user.sql) script to create the 'DEER' user with the required privileges.
1. Run the [create_nriv_table.sql](../blob/master/create_nriv_table.sql) script to create the base table and associated index.
1. Run the [populate_nriv_table.sql](../blob/master/populate_nriv_table.sql) script to populate the base table.

Test Cases
----------

Use the following scripts to create the test cases:
1. [create_WORKER_ORIGINAL_proc.sql](../blob/master/create_WORKER_ORIGINAL_proc.sql) for the base case.
1. [create_WORKER_SKIP_LOCKED_1_proc.sql](../blob/master/create_WORKER_SKIP_LOCKED_1_proc.sql) for test case #2 - add SKIP LOCKED from first row.
1. [create_WORKER_SKIP_LOCKED_4_proc.sql](../blob/master/create_WORKER_SKIP_LOCKED_4_proc.sql) for test case #3 - add SKIP LOCKED from first 4 rows.
1. [create_WORKER_SKIP_LOCKED_ALL_proc.sql](../blob/master/create_WORKER_SKIP_LOCKED_ALL_proc.sql) for test case #4 - add SKIP LOCKED from all rows.
