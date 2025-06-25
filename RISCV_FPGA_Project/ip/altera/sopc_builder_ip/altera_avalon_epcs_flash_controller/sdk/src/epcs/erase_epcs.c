/*
	
	Erase the EPCS4 device.
	
	WARNING: This program erases the entire EPCS4 device

	-TR-
*/

#include "excalibur.h"

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

int main(void){

	char answer = 0;
	int s = 0;

  printf("\nWARNING:\nExisting EPCS4 contents will be lost.\nAre you sure you "
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

	printf("Erase Done.\n\n\004");

	return 0;

}
