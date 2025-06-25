// file: show_some_epcs.c
//
// dvb 2004
// 
// This simple little number displays the first 1024 bytes
// of epcs. Nice, huh?
//
// Use in conjunction with erase and write_some to see
// the real action.
//

#include "excalibur.h"

int main(void)
    {
    int i;
    int j;
    int err;
    int per_line = 16;

    for(i = 0; i < 1024; i+= per_line)
        {
        printf("%08x : ",i);
        for(j = i; j < i + per_line; j++)
            {
            unsigned char b;
            err = nr_epcs_read_byte(j,&b);
            printf("%02x ",b);
            }
        printf("| ");
        for(j = i; j < i + per_line; j++)
            {
            unsigned char b;
            err = nr_epcs_read_byte(j,&b);
            printf("%c",(b > 0x20 && b < 0x7f) ? b : '.');
            }
        printf("\n");

        }
    }

// end of file
