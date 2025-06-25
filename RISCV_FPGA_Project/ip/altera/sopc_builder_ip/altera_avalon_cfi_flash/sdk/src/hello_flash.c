// file: hello_flash.c
//
// 2001 december 16
//
// This is a partial rewrite of the old classic
// software composition, "hello_AMD29LV800.c".
// It was misnamed, since it doesn't have much
// to do with that particular chip (other than
// the choice of addresses to try out in it.)
//
// 2204 november 12
//
// create random byte buffer to r/w test
//

#include "nios.h"



#ifdef __nios32__

	#define k_test_offset 0x0000	// bytes from base of flash
	#define k_short_count 0x1000	// number of shorts to write

#else

	#define k_test_offset 0x0	// bytes from base of flash
	#define k_short_count 0x1000	// number of shorts to write

#endif




int main(void)
	{
	unsigned short buf[k_short_count];
	unsigned short *flash_test_address;
	int i;
	int result;
	int fail_count = 0;

#ifndef nasys_main_flash
	printf("no flash memory in design. sorry.\n");
	exit(0);

#else

	flash_test_address = (unsigned short *)((char *)nasys_main_flash + k_test_offset);

	printf ("\n\n amd_avalon_am29lv065d_flash flash memory test\n\n");

	// |
	// | Erase the flash. Report result.
	// |

	printf("(1) erasing flash at 0x%08x\n",flash_test_address);

	result = nr_flash_erase_sector(nasys_main_flash, flash_test_address);

	printf("    result = %d\n",result);


	// |
	// | Fill the buffer with random (but repeatable) values.
	// |

	srand(0x0440);
	for (i = 0; i < k_short_count; ++i)
		buf[i] = rand();

	// |
	// | Write that stuff to flash...
	// |

	printf("(2) writing flash...\n");

	result = nr_flash_write_buffer(nasys_main_flash,
									flash_test_address,
									buf,
									k_short_count);	// api wants number of short words

	printf("    result = %d\n",result);

	// |
	// | Read that stuff back, and report if it matches, or what.
	// |

	printf("(3) reading flash.\n");

	for (i = 0; i < k_short_count; ++i)
	{
		unsigned char a,b;

		a = buf[i];
		b = flash_test_address[i];

		if(a != b)
		{
			printf("verify failure at location 0x%08x (expected 0x%04x, got 0x%04x)\n",
					&flash_test_address[i],
					a,b);
			fail_count++;
			if(fail_count >= 10)
				goto no_more_verifying;
		}
	}
no_more_verifying:

	printf("done reading flash\n");

#endif

	exit(0);
}



