
// file: show_some_epcs.c
//
// dvb 2004
// 
// This simple little number fills the first 500 bytes
// of epcs with a simple pattern.
//
// Use in conjunction with erase and read_some to see
// the real action.
//

#include "excalibur.h"

int main(void)
    {
    int i;
    int j;
    int byte_count = 500;
    int err;
    int t;

    printf("starting to write a pattern into epcs...\n");
    t = nr_timer_milliseconds();
    
    j = 0;
    for(i = 0; i < byte_count; i++)
        {
        err = nr_epcs_write_byte (i , j);
        j += 17;
        j &= 0x000000ff;
        }

    t = nr_timer_milliseconds() - t;

    printf("all done. writing %d bytes to epcs took %d milliseconds\n\n",
            byte_count,
            t);
    printf("(note: this is using the slowest nonbulk byte-by-byte write method.)\n\n");

    return 0;
    }

// end of file
