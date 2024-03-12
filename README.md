# demos

Various demonstration scripts

## Wiki

The [wiki](https://github.com/dfhawthorne/demos/wiki) lists all published reports from demonstrations.

## Demonstrations

### Filesystem Performance

Investigates the effects of `O_SYNC` and blocksize on I/O response time. Final report published
[here](https://github.com/dfhawthorne/demos/wiki/O_SYNC-and-Blocksize-Effects-on-IO-Performance).

### Filesystem Performance Sync

In progress. Will expand on the demonstration in _Filesystem Performance_ by considering `O_DIRECT`
and filesystem types.

### High CPU and CDB Resource Plans

Demonstrates the effect of using CDB resource plans under 100% CPU load. Final report published
[here](https://yaocm.wordpress.com/2019/12/17/high-cpu-usage-with-a-cdb-resource-plan/). The
associated blog post is [here](https://yaocm.wordpress.com/2020/07/02/effects-of-o_sync-flag-on-i-o-response-time/).

### Resource Manager Thruput

In progress. Investigates whether the use of Oracle Resource Manager plans improves the throughput
under 100% CPU load. Preliminary reports have been published on [Wiki page](https://github.com/dfhawthorne/demos/wiki).

### Select With Update

Investigates the use of `SELECT ... FOR UPDATE SKIP LOCKED` in processing a staging table with many
concurrent clients. Published final report [here](https://yaocm.wordpress.com/2019/04/13/technical-note-on-skip-locked/).

Will follow up comments with an expanded demonstration.

### V$SESSION Returning No Rows

Demonstrated the case of the `V$SESSION` view returning no rows. Final report published
[here](https://yaocm.wordpress.com/2019/04/13/technical-note-on-vsession-is-producing-wrong-results-for-non-sys-users/).

### Demonstration of Loading Database Bookshelf into XE Database

[Demonstration of Loading Database Bookshelf into XE Database](https://github.com/dfhawthorne/demos/wiki/database_bookshelf_xml)
