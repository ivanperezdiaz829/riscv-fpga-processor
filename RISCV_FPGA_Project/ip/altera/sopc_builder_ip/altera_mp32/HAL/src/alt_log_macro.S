/*  alt_log_macro.S
 *
 *  Implements the function tx_log_str, called by the assembly macro 
 *  ALT_LOG_PUTS().  The macro will be empty when logging is turned off,
 *  and this function will not be compiled.  When logging is on,
 *  this function is used to print out the strings defined in the beginning
 *  of alt_log_printf.c, using port information taken from system.h and 
 *  alt_log_printf.h.  
 *
 *  This routine only handles strings, and sends a character into the defined
 *  output device's output buffer when the device is ready. It's intended for 
 *  debugging purposes, where messages can be set to print out at certain 
 *  points in the boot code to indicate the progress of the program.
 *
 */

#ifndef __ALT_LOG_MACROS__
#define __ALT_LOG_MACROS__

/* define this flag to skip assembly-incompatible parts
 * of various include files. */
#define ALT_ASM_SRC

#ifdef ALT_LOG_ENABLE // only compile this function if this flag is defined. 
	
	#include "alt_mips32.h"
	#include "system.h"
	#include "io.h"
	#include "sys/alt_log_printf.h"

        .global tx_log_str
tx_log_str:
	/* load base uart / jtag uart address into r6 */
    la     r6, UNCACHEABLE_ADDR(ALT_LOG_PORT_BASE)

tx_next_char:
        /* if pointer points to null, return 
         * r4 is the pointer to the str to be printed, set by ALT_LOG_PUTS */
	lb     r7, (r4)
	beq    r7, zero, end_tx

	/* check device transmit ready  */
wait_tx_ready_loop:
    lw     r5, ALT_LOG_PRINT_REG_OFFSET(r6)
    andi   r5, r5, ALT_LOG_PRINT_MSK
    beq    r5, zero, wait_tx_ready_loop	

	/* write char */
	sw     r7, ALT_LOG_PRINT_TXDATA_REG_OFFSET (r6)		

	/* advance string pointer */
	addiu  r4, r4, 1

	b      tx_next_char
    nop
end_tx:	
    jr     ra

#endif /* ALT_LOG_ENABLE */

#endif /* __ALT_LOG_MACROS__ */

