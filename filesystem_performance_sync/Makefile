# ------------------------------------------------------------------------------
# Make file for filesystem performance demonstration
# ------------------------------------------------------------------------------

.PHONY : all run
all : do_perf_io_test run

do_perf_io_test: do_perf_io_test.c
	gcc -o do_perf_io_test do_perf_io_test.c

run: do_perf_io_test
	./do_perf_io_test ~/test_dir/mp{0..3} >results.csv
