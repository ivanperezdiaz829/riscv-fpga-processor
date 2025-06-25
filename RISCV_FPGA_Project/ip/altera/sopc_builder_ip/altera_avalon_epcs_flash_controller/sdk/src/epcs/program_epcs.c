// Write config data into an EPCS4 serial flash device.
//
// Update an EPCS4 device with a new configuration by following
// these steps:
// 1) Convert a pof file into a form GCC can handle:
//    pof2dat.pl [path to new pof file] > converted_pof.dat
// 2) Rebuild the new configuration data into program_epcs.srec:
//    nb program_epcs.c
// 3) Write the new configuration data into the EPCS4:
//    nr program_epcs.srec (download the
//
// WARNING: This program erases the entire EPCS4 device before writing the
// new pof file.  All existing data in the EPCS4 device will be lost!
//

#include "excalibur.h"
#include <stdio.h>

unsigned char* error_string(int error_code)
{
  switch (error_code)
  {
    case na_epcs_success: return "na_epcs_success";
    case na_epcs_err_device_not_present: return "na_epcs_err_device_not_present";
    case na_epcs_err_device_not_ready: return "na_epcs_err_device_not_ready";
    case na_epcs_err_timedout: return "na_epcs_err_timedout";
    case na_epcs_err_write_failed: return "na_epcs_err_write_failed";
    case na_epcs_invalid_config: return "na_epcs_invalid_config";
  }

  return "unknown error code";
}

inline unsigned char bit_reverse(unsigned char b)
{
  return
      ((b & 0x80) ? 0x01 : 0) |
      ((b & 0x40) ? 0x02 : 0) |
      ((b & 0x20) ? 0x04 : 0) |
      ((b & 0x10) ? 0x08 : 0) |
      ((b & 0x08) ? 0x10 : 0) |
      ((b & 0x04) ? 0x20 : 0) |
      ((b & 0x02) ? 0x40 : 0) |
      ((b & 0x01) ? 0x80 : 0);
}

void my_srand(void)
{
  srand(443);
}

unsigned char config_data[] = {
// Include the converted POF file as a comma-separated list of numbers.
#include "converted_pof.dat"
};

unsigned char buf[na_epcs_bulk_size / 8];

int config_data_size = sizeof(config_data) / sizeof(*config_data);

const int print_mask = 0x1FF;
int main(void)
{
  char answer;
  int s = 0;
  int i;
  unsigned long first_address;

  if (config_data_size > na_epcs_bulk_size)
  {
    printf("Error: config data size (%d) larger than EPCS size (%d)\n",
      config_data_size, na_epcs_bulk_size);
    return 0;
  }

  printf("\nWARNING:\nThis program writes new hardware configuration data into\n"
    "the EPCS4 device.  Existing EPCS4 contents will be lost.  Are you sure you\n"
    "want to proceed?  (type 'Y' to continue, 'N' to abort)\n");

  while (1)
  {
    answer = nm_printf_rxchar(0);
    if (answer == 'y' || answer == 'Y') break;
    if (answer != 'n' && answer != 'N') continue;
    printf("\nAborting EPCS4 write.  EPCS4 contents is unchanged.\n\n\004");
    return 0;
  }

  // Unprotect the EPCS4.
  printf("unprotecting EPCS4...\n");
  s = nr_epcs_protect_region(na_epcs_protect_none);
  if (na_epcs_success != s)
  {
    printf("nr_epcs_protect_region() failed ('%s').\n\004", error_string(s));
    return 0;
  }

  // Erase the EPCS4.
  printf("erasing EPCS4...\n");
  s = nr_epcs_erase_bulk();
  if (na_epcs_success != s)
  {
    printf("nr_epcs_erase_bulk() failed ('%s').\n\004", error_string(s));
    return 0;
  }

  printf("writing config data to EPCS4...\n");
  s = nr_epcs_write_buffer(0, config_data_size, config_data);
  if (na_epcs_success != s)
  {
    printf("nr_epcs_write_buffer() failed ('%s').\n\004", error_string(s));
    return 0;
  }

  printf("reading back data...\n");
  s = nr_epcs_read_buffer(0, config_data_size, buf);
  if (na_epcs_success != s)
  {
    printf("nr_epcs_read_buffer() failed ('%s').\n\004", error_string(s));
    return 0;
  }

  printf("comparing read and write data...\n");
  for (i = 0; i < config_data_size; ++i)
  {
    if (buf[i] != config_data[i])
    {
      printf("compare failure at location 0x%X (wrote: 0x%X; read: 0x%X)\n",
        i, config_data[i], buf[i]);
      return 0;
    }
  }

  printf("Converted pof file 'converted_pof.dat' programmed into EPCS4.\n");
  printf("Press Power-On Reset (SW10) to load the new hardware configuration\n\004");
  return 0;
}

// end of file
