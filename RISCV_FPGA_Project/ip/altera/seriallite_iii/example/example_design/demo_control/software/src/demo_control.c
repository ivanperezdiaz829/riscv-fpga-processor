//
//	SerialLite III Streaming Demo Control
//
#define  BURST 1
#define  CONT  0
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include "sys/alt_alarm.h"
#include "alt_types.h"
#include "system.h"
#include "vt100.h"


// Function prototypes
int lcd_init();
int mif_init();
int crc_err_insert();
int display_menu();
int get_lanes();
int reset_sink();
int reset_source();
int enable_source();
int disable_source();
int reset_statistics();
int display_error_summary();
int update_main_counts();
int update_error_counts();
int toggle_mode();


// Management CSR offsets
#define  DEMO_MGMT_CONTROL_ADDR                        DEMO_MGMT_BASE + 0x000

#define  DEMO_MGMT_SRC_BURST_COUNT_ADDR                DEMO_MGMT_BASE + 0x080
#define  DEMO_MGMT_SRC_WORDS_TRANS_L_ADDR              DEMO_MGMT_BASE + 0x084
#define  DEMO_MGMT_SRC_WORDS_TRANS_H_ADDR              DEMO_MGMT_BASE + 0x088
#define  DEMO_MGMT_SRC_TOTAL_ERRORS_ADDR               DEMO_MGMT_BASE + 0x08C

#define  DEMO_MGMT_SNK_BURST_COUNT_ADDR                DEMO_MGMT_BASE + 0x100
#define  DEMO_MGMT_SNK_WORDS_RECVD_L_ADDR              DEMO_MGMT_BASE + 0x104
#define  DEMO_MGMT_SNK_WORDS_RECVD_H_ADDR              DEMO_MGMT_BASE + 0x108
#define  DEMO_MGMT_SNK_TOTAL_ERRORS_ADDR               DEMO_MGMT_BASE + 0x10C
#define  DEMO_MGMT_SNK_OVERFLOW_ERRORS_ADDR            DEMO_MGMT_BASE + 0x110
#define  DEMO_MGMT_SNK_LOSS_ALIGN_NORMAL_ERRORS_ADDR   DEMO_MGMT_BASE + 0x114
#define  DEMO_MGMT_SNK_LOSS_ALIGN_INIT_ERRORS_ADDR     DEMO_MGMT_BASE + 0x118
#define  DEMO_MGMT_SNK_LANE_SWAP_ERRORS_OFFSET         DEMO_MGMT_BASE + 0x11C
#define  DEMO_MGMT_SNK_LANE_SEQUENCE_ERRORS_OFFSET     DEMO_MGMT_BASE + 0x120
#define  DEMO_MGMT_SNK_LANE_ALIGNMENT_ERRORS_OFFSET    DEMO_MGMT_BASE + 0x124

#define  DEMO_MGMT_SNK_MF_CRC_ERRORS_BASE_ADDR         DEMO_MGMT_BASE + 0x180
#define  LOCAL_ADDR_XR_MIF_LCH                         SOURCE_RECONFIG_BASE + (0x38 + 0)*4
#define  LOCAL_ADDR_XR_MIF_PCH                         SOURCE_RECONFIG_BASE + (0x38 + 1)*4
#define  LOCAL_ADDR_XR_MIF_STATUS                      SOURCE_RECONFIG_BASE + (0x38 + 2)*4
#define  LOCAL_ADDR_XR_MIF_OFFSET                      SOURCE_RECONFIG_BASE + (0x38 + 3)*4
#define  LOCAL_ADDR_XR_MIF_DATA                        SOURCE_RECONFIG_BASE + (0x38 + 4)*4


#define  MAIN_SCREEN             0
#define  ERROR_DETAILS_SCREEN    1


// Global Variables
int   screen_context;
int   lanes;
int   mode;

//
// The status refresh callback function.
//
alt_u32 status_refresh_alarm_callback (void* context)
{
   if (screen_context == MAIN_SCREEN)
   {
	   update_main_counts();	      // Refresh counts on the main screen
   }
   else
   {
	   update_error_counts();	      // Refresh counts on the error summary screen
   }

	return alt_ticks_per_second()/2;   // This function is called every 500 mS
}


int main()
{
   int 					choice;
   static alt_alarm		alarm;
   extern int           lanes;
   mode            = CONT;
	
   lcd_init();
   screen_context = MAIN_SCREEN;

   lanes = get_lanes();
   mif_init();



   //
   // Initialize the alarm to refresh the screen
   //
   if (alt_alarm_start(&alarm, alt_ticks_per_second()/2, status_refresh_alarm_callback, NULL) < 0)
   {
	   printf ("No system clock available\n");
   }


   //
   // Put up the menu and run demo tasks based on user input.
   //
   while (1)
   {
      choice = display_menu();

      switch (choice)
      {
         case '1': { enable_source();              break; }
         case '2': { disable_source();             break; }
         case '3': { reset_source();               break; }
         case '4': { reset_sink();                 break; }
         case '5': { display_error_summary();      break; }
	 case '6': { toggle_mode();                break; }
	 case '7': { crc_err_insert();             break; }
      }
   }

   return 0;
}

// Enable CRC32 error injection by enabling following DPRIO bit 
//Register	          Field Name	 Field Bit Offset	Field Bit Width	Field Access
//r_tx_crc_err	pcs10g_tx_ctrl_13	 15	             1	              rw						

//Instance Name	   Domain	   Domain Offset	Register Offset
//pcs10g_tx_ctrl_13    avalon_tx     0x0             0xC

//Channel	Domain	 Base Address (hex)
//0	      hd_pcs10g	0x12c
//1	      hd_pcs10g	0x384
//2	     hd_pcs10g	0x5dc

//So you can calculate the offset depending on which ch from triplet you are using = ch<0/1/2> base address + Avalon TX Domain offset + Register offset for pcs10g_tx_ctrl_13.
// so for ch0 = 12c (300 decimal) + 0xc (12 decimal) = 0x138 (312 decimal)
int mif_init() 
{
   unsigned int   mif;
   unsigned int   *reg_ptr_lch    = (unsigned int *)(LOCAL_ADDR_XR_MIF_LCH);
   unsigned int   *reg_ptr_status = (unsigned int *)(LOCAL_ADDR_XR_MIF_STATUS);
   unsigned int   *reg_ptr_offset = (unsigned int *)(LOCAL_ADDR_XR_MIF_OFFSET);
   unsigned int   *reg_ptr_data   = (unsigned int *)(LOCAL_ADDR_XR_MIF_DATA);

    // set up logical channel
    *reg_ptr_lch = 0;
    // ctrl write to mif_mode = 01b
    *reg_ptr_status = 4;
    //Set up Offset User to pcs10g_tx_ctrl register_13 which is 0x138
    *reg_ptr_offset = 0x138;

    //Ctrl write, mif_mode = 01b, enable rd, as its read modify register befre writing read the contents of the register 138
    *reg_ptr_status = 6;
    //wait for busy to clear
    while((*(reg_ptr_status)) != 4);

   // setup data, field bit offset is 15 so set that bit to enbale the error injection.
    mif = *reg_ptr_data;
    mif = mif | 0x00008000 ;
    *reg_ptr_data = mif;
	 
    //Ctrl write, mif_mode = 01b
    *reg_ptr_status = 5;
    //wait for busy to clear
    while((*(reg_ptr_status)) != 4);
}

// Insert Error
int crc_err_insert() {

    unsigned int	*reg_ptr = (unsigned int *)(DEMO_MGMT_CONTROL_ADDR);
    unsigned int	demo_mgmt_control;
    unsigned int	flag_crc;
    	
    // Set/Reset crc error insertion bit
    demo_mgmt_control = *reg_ptr;
    flag_crc = demo_mgmt_control & 0x00000020 ;

    if(flag_crc)
        demo_mgmt_control = demo_mgmt_control & 0xFFFFFFDF;
    else
        demo_mgmt_control = demo_mgmt_control | 0x00000020;
    
    *reg_ptr = demo_mgmt_control;
    demo_mgmt_control = *reg_ptr;
}

int display_menu()
{
   int            response;
   extern int     lanes;

   printf( "%c[2J", ASCII_ESC);     // Clear the screen
   printf( "%c[0;0H", ASCII_ESC);   // Position cursor at line 0 col 0

   // Display the menu
   printf("\n\r");
   printf("\n\r");
   printf( "%c[1m", ASCII_ESC);  // Display bold text
   printf("                       SerialLite III Streaming %d Lane Demo\n\r", lanes);
   printf( "%c[m", ASCII_ESC);   // Display regular text
   printf("\n\r");
   printf("      Total Words Transmitted:\n\r");
   printf("      Bursts Transmitted:\n\r");
   printf("      Total Transmission Errors:\n\r");
   printf("\n\r");
   printf("      Total Words Received:\n\r");
   printf("      Bursts Received:\n\r");
   printf("      Total Reception Errors:\n\r");
   printf("\n\r");
   printf("\n\r");
   printf("\n\r");
   printf("      1) Enable Data Generator/Checker\n\r");
   printf("      2) Disable Data Generator/Checker\n\r");
   printf("      3) Reset Source Core\n\r");
   printf("      4) Reset Sink Core\n\r");
   //printf("      5) Reset Error Statistics\n\r");
   printf("      5) Display Error Details\n\r");
   printf("      6) Toggle Burst/Continuous mode\n\r");
   printf("      7) Toggle CRC Error Insertion \n\r");
   printf("\n\r");
   printf("\n\r");
   printf("      Enter Selection (1-7): ");

   printf( "%c[21;30H", ASCII_ESC);       // Position cursor at line 21 col 30 as a prompt for selection

   response = getchar();                  // Get the user response

   return (response);
}


//
// Return the number of lanes on the link based on contents of control/status CSR.
//
int get_lanes()
{
   unsigned int   *reg_ptr = (unsigned int *)(DEMO_MGMT_CONTROL_ADDR);
   unsigned int   demo_mgmt_control;
   unsigned int   lanes;

   demo_mgmt_control = *reg_ptr;

   lanes = (demo_mgmt_control & 0xF8000000) >> 27;

   return lanes;
}


//
// Reset Sink core and traffic checker using control/status CSR.
//
int reset_sink()
{
   unsigned int   reset_delay = 100000; // Long delay so user gets visual feedback via LED
   unsigned int   *reg_ptr = (unsigned int *)(DEMO_MGMT_CONTROL_ADDR);
   unsigned int   demo_mgmt_control;

   // Set Sink Reset bit
   demo_mgmt_control = *reg_ptr;
   demo_mgmt_control = demo_mgmt_control | 0x00000002;
   *reg_ptr = demo_mgmt_control;

   // wait for reset to take
   while (reset_delay != 0) --reset_delay;

   // Clear Sink Reset bit
   demo_mgmt_control = *reg_ptr;
   demo_mgmt_control = demo_mgmt_control & 0xFFFFFFFD;
   *reg_ptr = demo_mgmt_control;

   return 0;
}


//
// Reset Source core and traffic generator using control/status CSR.
//
int reset_source()
{
    unsigned int   reset_delay = 100000; // Long delay so user gets visual feedback via LED
	unsigned int	*reg_ptr = (unsigned int *)(DEMO_MGMT_CONTROL_ADDR);
	unsigned int	demo_mgmt_control;
    
	
   // Set Source Reset bit
	demo_mgmt_control = *reg_ptr;
	demo_mgmt_control = demo_mgmt_control | 0x00000001 ;
	*reg_ptr = demo_mgmt_control;

   // wait for reset to take
   while (reset_delay != 0) --reset_delay;

   // Clear Sink Reset bit
	demo_mgmt_control = *reg_ptr;
	demo_mgmt_control = demo_mgmt_control & 0xFFFFFFFE;
	*reg_ptr = demo_mgmt_control;

	return 0;
}


//
// Enable traffic generator using control/status CSR.
//
int enable_source()
{
	unsigned int	*reg_ptr = (unsigned int *)(DEMO_MGMT_CONTROL_ADDR);
	unsigned int	demo_mgmt_control;

	demo_mgmt_control = *reg_ptr;

	demo_mgmt_control = demo_mgmt_control | 0x00000010;

	*reg_ptr = demo_mgmt_control;

	return 0;
}


//
// Disable traffic generator using control/status CSR.
//
int disable_source()
{
	unsigned int	*reg_ptr = (unsigned int *)(DEMO_MGMT_CONTROL_ADDR);
	unsigned int	demo_mgmt_control;


	demo_mgmt_control = *reg_ptr;

	demo_mgmt_control = demo_mgmt_control & 0xFFFFFFEF;

	*reg_ptr = demo_mgmt_control;

	return 0;
}


int reset_statistics()
{
   extern int           lanes;
   int                  lane_index;
   unsigned int        *reg_ptr;
 
    // Update Source Adaptation FIFO Overflow error count.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SRC_TOTAL_ERRORS_ADDR);
   *reg_ptr = 0;

    // Update Adaptation FIFO Overflow error count.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SNK_OVERFLOW_ERRORS_ADDR);
   *reg_ptr = 0;

    // Update Loss of Alignment During Normal Operation error count.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SNK_LOSS_ALIGN_NORMAL_ERRORS_ADDR);
   *reg_ptr = 0;

    // Update Loss of Alignment During Initialization error count.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SNK_LOSS_ALIGN_NORMAL_ERRORS_ADDR);
   *reg_ptr = 0;

    // Update Meta Frame CRC Errors error counts.

   for (lane_index = 0; lane_index < lanes; ++lane_index)
   {
      reg_ptr     = (unsigned int *)(DEMO_MGMT_SNK_MF_CRC_ERRORS_BASE_ADDR + (lane_index*4));
      *reg_ptr = 0;
   }

   // Update Lane Swap error count.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SNK_LANE_SWAP_ERRORS_OFFSET);
   *reg_ptr = 0;
   
   // Update Lane Sequence error count.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SNK_LANE_SEQUENCE_ERRORS_OFFSET);
   *reg_ptr = 0;
  
   // Update Lane Sink Lane Alignment error count.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SNK_LANE_ALIGNMENT_ERRORS_OFFSET);
   *reg_ptr = 0;
  
    return 0;
}


int display_error_summary()
{
   int                  lane_index;
   extern int           lanes;

   screen_context = ERROR_DETAILS_SCREEN;

   printf("%c[2J", ASCII_ESC);     // Clear the screen
   printf("%c[0;0H", ASCII_ESC);   // Position cursor at line 0. col 0

   printf("\n\r");
   printf("\n\r");
   printf( "%c[1m", ASCII_ESC);  // Display bold text
   printf("   Source Errors\n\r");
   printf( "%c[m", ASCII_ESC);   // Display regular text
   printf("\n\r");
   printf("      Adaptation FIFO Overflow:\n\r");
   printf("\n\r");
   printf("\n\r");
   printf( "%c[1m", ASCII_ESC);  // Display bold text
   printf("   Sink Errors\n\r");
   printf( "%c[m", ASCII_ESC);   // Display regular text
   printf("\n\r");
   printf("      Adaptation FIFO Overflow:\n\r");
   printf("      Loss of Alignment During Normal Operation:\n\r");
   printf("      Loss of Alignment During Initialization:\n\r");

   for (lane_index = 0; lane_index < lanes; ++lane_index)
   {
      printf("      Lane %d Meta Frame CRC Errors:\n\r", lane_index);
   }

   printf("\n\r");
   printf("\n\r");
   printf( "%c[1m", ASCII_ESC);  // Display bold text
   printf("   Traffic Checker Errors\n\r");
   printf( "%c[m", ASCII_ESC);   // Display regular text
   printf("\n\r");
   printf("      Lane Swap Errors:\n\r");
   printf("      Lane Sequence Errors:\n\r");
   printf("      Lane Alignment Errors:\n\r");

   printf( "%c[23;0H   Press any key to return to main menu:", ASCII_ESC);       // Position cursor at line 23 col 0 as a prompt for selection

   getchar();                  // Get the user response

   screen_context = MAIN_SCREEN;

   return 0;
}

int toggle_mode() 
{
    
	disable_source();
	//reset_source();
        //reset_sink();
	reset_statistics();
	
	unsigned int	*reg_ptr = (unsigned int *)(DEMO_MGMT_CONTROL_ADDR);
	unsigned int	demo_mgmt_control;
    
	
    // Set/Reset mode bit
	demo_mgmt_control = *reg_ptr;
	
	if (mode == BURST) {
		demo_mgmt_control = demo_mgmt_control & 0xFFFFFFFB ;
		mode = CONT;
	} else {
		demo_mgmt_control = demo_mgmt_control | 0x4 ;
		mode = BURST;
	}
	
	*reg_ptr = demo_mgmt_control;
	
	
	enable_source();
}

int update_main_counts()
{
   unsigned int        *reg_ptr;
   unsigned int         reg_value;
   unsigned int         reg_value_h;
   unsigned long long   long_reg_value;

   printf( "%c[1m", ASCII_ESC);  // Display bold text

   // Update total words transmitted.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SRC_WORDS_TRANS_L_ADDR);
   reg_value = *reg_ptr;
   reg_ptr = (unsigned int *)(DEMO_MGMT_SRC_WORDS_TRANS_H_ADDR);
   reg_value_h = *reg_ptr;
   long_reg_value = reg_value_h;
   long_reg_value = (long_reg_value << 32) + reg_value;
   printf("%c[5;34H", ASCII_ESC);   // Position cursor at line 5 col 34
   printf("%llu", long_reg_value);

   // Update total bursts transmitted.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SRC_BURST_COUNT_ADDR);
   reg_value = *reg_ptr;
   printf("%c[6;34H", ASCII_ESC);   // Position cursor at line 6 col 34
   printf("%u", reg_value);

   // Update total transmission errors.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SRC_TOTAL_ERRORS_ADDR);
   reg_value = *reg_ptr;
   printf("%c[7;34H", ASCII_ESC);   // Position cursor at line 7 col 34
   printf("%u", reg_value);

   // Update total words received.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SNK_WORDS_RECVD_L_ADDR);
   reg_value = *reg_ptr;
   reg_ptr = (unsigned int *)(DEMO_MGMT_SNK_WORDS_RECVD_H_ADDR);
   reg_value_h = *reg_ptr;
   long_reg_value = reg_value_h;
   long_reg_value = (long_reg_value << 32) + reg_value;
   printf("%c[9;34H", ASCII_ESC);   // Position cursor at line 9 col 34
   printf("%llu", long_reg_value);

   // Update total bursts received.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SNK_BURST_COUNT_ADDR);
   reg_value = *reg_ptr;
   printf("%c[10;34H", ASCII_ESC);   // Position cursor at line 10 col 34
   printf("%u", reg_value);

   // Update total reception errors.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SNK_TOTAL_ERRORS_ADDR);
   reg_value = *reg_ptr;
   printf("%c[11;34H", ASCII_ESC);   // Position cursor at line 11 col 34
   printf("%u", reg_value);

   printf( "%c[m", ASCII_ESC);   // Display regular text

   return 0;
}


int update_error_counts()
{
   extern int           lanes;
   int                  lane_index;
   unsigned int        *reg_ptr;
   unsigned int         reg_value;
   int                  screen_line;
   char                 screen_line_string[4];

   printf( "%c[1m", ASCII_ESC);  // Display bold text

   // Update Source Adaptation FIFO Overflow error count.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SRC_TOTAL_ERRORS_ADDR);
   reg_value = *reg_ptr;
   printf("%c[5;50H", ASCII_ESC);   // Position cursor at line 5 col 50
   printf("%u", reg_value);

   // Update Adaptation FIFO Overflow error count.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SNK_OVERFLOW_ERRORS_ADDR);
   reg_value = *reg_ptr;
   printf("%c[10;50H", ASCII_ESC);   // Position cursor at line 10 col 50
   printf("%u", reg_value);

   // Update Loss of Alignment During Normal Operation error count.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SNK_LOSS_ALIGN_NORMAL_ERRORS_ADDR);
   reg_value = *reg_ptr;
   printf("%c[11;50H", ASCII_ESC);   // Position cursor at line 11 col 50
   printf("%u", reg_value);

   // Update Loss of Alignment During Initialization error count.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SNK_LOSS_ALIGN_NORMAL_ERRORS_ADDR);
   reg_value = *reg_ptr;
   printf("%c[12;50H", ASCII_ESC);   // Position cursor at line 12 col 50
   printf("%u", reg_value);

   // Update Meta Frame CRC Errors error counts.
   screen_line = 13;

   for (lane_index = 0; lane_index < lanes; ++lane_index)
   {
      reg_ptr     = (unsigned int *)(DEMO_MGMT_SNK_MF_CRC_ERRORS_BASE_ADDR + (lane_index*4));
      reg_value = *reg_ptr;
      sprintf(screen_line_string, "%d", screen_line+lane_index);
      printf("%c[%s;50H", ASCII_ESC, screen_line_string);   // Position cursor at line screen_line col 50
      printf("%u", reg_value);
   }

   // Update Lane Swap error count.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SNK_LANE_SWAP_ERRORS_OFFSET);
   reg_value = *reg_ptr;
   sprintf(screen_line_string, "%d", screen_line + 4+lanes);
   printf("%c[%s;50H", ASCII_ESC, screen_line_string);   // Position cursor at line screen_line + 5 col 50
   printf("%u", reg_value);

   // Update Lane Swap error count.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SNK_LANE_SEQUENCE_ERRORS_OFFSET);
   reg_value = *reg_ptr;
   sprintf(screen_line_string, "%d", screen_line + 5 + lanes);
   printf("%c[%s;50H", ASCII_ESC, screen_line_string);   // Position cursor at line screen_line + 6 col 50
   printf("%u", reg_value);

   // Update Lane Swap error count.
   reg_ptr = (unsigned int *)(DEMO_MGMT_SNK_LANE_ALIGNMENT_ERRORS_OFFSET);
   reg_value = *reg_ptr;
   sprintf(screen_line_string, "%d", screen_line + 6 + lanes);
   printf("%c[%s;50H", ASCII_ESC, screen_line_string);   // Position cursor at line screen_line + 7 col 50
   printf("%u", reg_value);

   printf( "%c[m", ASCII_ESC);   // Display regular text

   return 0;
}
