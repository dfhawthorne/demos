File System Performance Demonstration
=====================================

# Associated Blog Post

The blog post discussing the results of these performance tests can be found [here]().

# Running a Performance Test

To run a performance test, do:
1. Build the program using `make`.
1. Run a performance test using `./do_perf_io_test`

# Command Options

The command options are:
1. __-o__ - file for timing statistics
1. output file name

# Output File Fields

Output file has the following fields:
1. Block Size
2. Synchronisation flag set?
3. Number of bytes read
4. Wall clock time in seconds
5. User time in seconds
6. System time in seconds

