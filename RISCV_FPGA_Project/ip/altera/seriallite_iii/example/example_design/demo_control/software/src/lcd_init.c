/*
 *   SerialLite III Streaming Demo LCD Initialization
 */

#include <stdio.h>

int lcd_init()
{
   FILE*	lcd_dev;
   char     lcd_message_1[] = " SerialLite III\n";
   char     lcd_message_2[] = "    Streaming";

   lcd_dev = fopen("/dev/lcd", "w");

   fwrite(lcd_message_1, 1, sizeof(lcd_message_1), lcd_dev);
   fwrite(lcd_message_2, 1, sizeof(lcd_message_2), lcd_dev);

   fclose(lcd_dev);

   return 0;
}
