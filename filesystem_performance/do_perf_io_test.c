/******************************************************************************\
* Performance test on a file system using varying block sizes, file size, and  *
* whether I/O is synchronous or not                                            *
\******************************************************************************/

/* --------------------------------------------------------------------------
 | System includes
 * -------------------------------------------------------------------------- */
 
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/times.h>
#include <time.h>
#include <unistd.h>

/* --------------------------------------------------------------------------
 | Perform a single performance test with a single buffer setting, number of
 | kilobytes to output, whether to use synchronous I/O or not.
 | The file name is used as a surrogate for the file system location.
 * -------------------------------------------------------------------------- */

void 
do_perf_test(
    const char    *file_name,
    const int     buffer_size,
    const ssize_t amt_of_data,
    const int     open_sync,
    const int     verbosity
    )
{
    int     output_fd,
            open_flags;
    mode_t  file_perms;
    
    if ( verbosity > 0 )
    {
        fprintf(
            stderr,
            "File_name='%s',buffer_size=%d,amt_of_data=%ld,sync=%c\n",
            file_name,
            buffer_size,
            amt_of_data,
            (open_sync) ? 'Y' : 'N'
        );
    }
    
    /* Allocate a buffer of the required size and set it to zeroes */
    
    char    *buf = malloc(buffer_size);
    if (buf == NULL)
    {
        fprintf(stderr, "malloc of %d: %m\n", buffer_size);
        exit(EXIT_FAILURE);
    }
    memset(buf, '\0', buffer_size);

    /* Open output file */

    open_flags = O_CREAT | O_WRONLY | O_TRUNC;
    if (open_sync) open_flags |= O_SYNC;
    file_perms = S_IRUSR | S_IWUSR | 
                 S_IRGRP | S_IWGRP |
                 S_IROTH | S_IWOTH;      /* rw-rw-rw- */
    output_fd = open(file_name, open_flags, file_perms);
    if (output_fd == -1)
    {
        fprintf(stderr, "opening file %s: %m\n", file_name);
        exit(EXIT_FAILURE);
    }

    /* Transfer data until we encounter end of input or an error */

    long bytes_read;
    for (bytes_read = 0L; bytes_read <= amt_of_data; bytes_read += buffer_size)
    {
        if (write(output_fd, buf, buffer_size) != buffer_size)
        {
            fprintf(stderr, "couldn't write whole buffer: %m\n");
            exit(EXIT_FAILURE);
        }
    }

    /* ----------------------------------------------------------------------
     | Force completion of all I/O and close output file
     * ---------------------------------------------------------------------- */
     
    sync();
    
    if (close(output_fd) == -1)
    {
        fprintf(stderr, "close output: %m\n");
        exit(EXIT_FAILURE);
    }
    
    /*------------------------------------------------------------------------*\
    | Print statistics for later analysis                                      |
    |  1. Block Size                                                           |
    |  2. Synchronisation flag set?                                            |
    |  3. Number of bytes read                                                 |
    |  4. Wall clock time in seconds                                           |
    |  5. User time in seconds                                                 |
    |  6. System time in seconds                                               |
    \*------------------------------------------------------------------------*/
    
    struct tms t;
    clock_t clockTime = clock();
    long clockTicks = sysconf(_SC_CLK_TCK);  /* Clocks per tick for conversion */
    
    if (clockTicks == -1)
    {
        fprintf(stderr, "sysconf(_SC_CLK_TCK) failed: %m\n");
        exit(EXIT_FAILURE);
    }
    if (clockTime  == -1)
    {
        fprintf(stderr, "clock() failed: %m\n");
        exit(EXIT_FAILURE);
    }
    if (times(&t)  == -1)
    {
        fprintf(stderr, "times() failed: %m\n");
        exit(EXIT_FAILURE);
    }
    printf("%d\t%c\t%ld\t%.3f\t%.3f\t%.3f\n",
        buffer_size,
        (open_sync) ? 's' : '-',
        bytes_read,
        (double) clockTime / CLOCKS_PER_SEC,
        (double) t.tms_utime / clockTicks,
        (double) t.tms_stime / clockTicks
        );
}

/* --------------------------------------------------------------------------
 | Main program
 * -------------------------------------------------------------------------- */

int
main(int argc, char *argv[])
{
    int opt;
    int verbosity = 0;
    int num_iter = 0;
    
    while ((opt = getopt(argc, argv, "n:v")) != -1) {
        switch (opt) {
        case 'n':
            num_iter = atoi(optarg);
            break;
        case 'v':
            verbosity++;
            break;
        default: /* '?' */
            fprintf(stderr, "Usage: %s output-file-name\n",
                    argv[0]);
            exit(EXIT_FAILURE);
        }
    }

    if (verbosity > 0)
    {
        printf("verbosity=%d; argc=%d; optind=%d\n",
           verbosity, argc, optind);
    }

    if (optind >= argc) {
        fprintf(stderr, "Expected one (1) argument after options\n");
        exit(EXIT_FAILURE);
    }

    if (verbosity > 0)
    {
        printf("output file name argument = %s\n", argv[optind]);
    }    
    
    int file_sizes[]  = {512, 1024, 2048, 4096, 8192, 16384, 32768, 65536};
    int block_sizes[] = {512, 1024, 2048, 4096, 8192, 16384, 32768, 65536};
    
    for (int i = 0; i < 8; i++)
    {
        ssize_t req_file_size = (ssize_t) file_sizes[i] * 1024;
        for (int open_sync = 0; open_sync < 2; open_sync++)
        {
            for (int j = 0; j < 8; j++)
            {
                for (int k = 0; k < num_iter; k++)
                {
                    do_perf_test(
                        argv[optind],
                        block_sizes[j],
                        req_file_size,
                        open_sync,
                        verbosity
                        );
                }
            }
        }
    }
                
    exit(EXIT_SUCCESS);
}

