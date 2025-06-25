
// Nios Flash Memory Routines

// All routines take a "flash base" parameter.
// If -1 is supplied,
// nasys_main_flash is used.

int nr_flash_erase_sector
		(
			unsigned short *flash_base,
  			unsigned short *sector_address
		);

int nr_flash_erase
		(
			unsigned short *flash_base
		);

int nr_flash_write
		(
			unsigned short *flash_base,
  			unsigned short *address,
			unsigned short value
		);

int nr_flash_write_buffer
		(
			unsigned short *flash_base,
  			unsigned short *start_address,
  			unsigned short *buffer,
			int halfword_count
		);

