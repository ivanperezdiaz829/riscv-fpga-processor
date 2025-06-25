// file: boot_loader_epcs_bits_cyclone.S
// asmsyntax=nios2
//
// Copyright 2006 Altera Corporation, San Jose, California, USA.
// All rights reserved.
//
// written by TPA, moved around by dvb, 2003-2004
// routines for accessing data out of EPCS serial
// flash device. This device is made of registers
// and you gotta talk to the registers to get
// your bytes.
//
// optimized by kds 2004.
//
// re-factored by jrk, 2006.01.26:
// - FPGA device-family-specific code moved to
//   separate sources.
// - This file contains EPCS boot routines
//   specific to the Cyclone I & Cyclone II
//   device families only; Stratix II support
//   is provided in a separate file, so that
//   separate (and thus small) boot loader
//   executables will be built.
//
// re-factored again by jrk 2012.06.15:
// - Added EPCQ256 support to other 'half' of the
//   boot loader. Cyclone III and newer families
//   support it, this boot loader (Cyclone I & II)
//   do not. This was omitted because the
//   extra code would push this Cyclone I/II
//   code over its current 512-byte budget per
//   EPCS controller on-ship memory size for
//   those families. You have been warned.

#include "boot_loader.h"

    .global sub_epcs_open_address
    .global sub_epcs_close
    .global sub_read_int_from_flash_epcs
    .global sub_read_byte_from_flash_epcs
    .global sub_find_payload_epcs

// |
// | Let the code begin
// |

    .text

////////
// EPCS_Open_Address
//
// "Open-up" the EPCS-device so we can start reading sequential bytes
// from a given address (the address is 'given' in r_flash_ptr).
//
// This is simply a front-end for the sub_tx_rx_int_epcs routine.
// as such, it doesn't need to fix up a return address.  Instead,
// it branches directly to sub_tx_rx_int_epcs, and lets the
// sub-routine return to origional caller.
//
//   Register usage:
//       argument:       r_flash_ptr
//       temporary:      r_eopen_eclose_tmp
//       return-value:   --none--
//
sub_epcs_open_address:

    // For RTL simulation purposes, this routine can be built to
    // simply return
#ifdef EPCS_SIMULATION_TEST
    // Fix-up return-address  (NOTE: LEAF)
    addi    return_address_less_4, return_address_less_4, 4

    // Return
    jmp     return_address_less_4   // Don't worry--we fixed it.
#endif /* EPCS_SIMULATION_TEST */
    // No fix-up, we're just a front-end

    // Enable device CS via control-register bit.
    movi    r_eopen_eclose_tmp, EPCS_CONTROL_SSO_MASK
    stwio   r_eopen_eclose_tmp, EPCS_CONTROL_OFFSET (r_epcs_base_address)

    // get the read command into our the transmit byte
    movhi   r_epcs_tx_value, (EPCS_COMMAND_READ << 8)

    // put the flash pointer into the lower 24 bits
    or      r_epcs_tx_value, r_epcs_tx_value, r_flash_ptr

    // functionally fall through to the tx_rx_int routine.
    br      sub_tx_rx_int_epcs

    // The EPCS flash is now open at r_flash_ptr.


////////
// EPCS_Close
//
// Terminate current EPCS transaction.
//
sub_epcs_close:
    // Fix-up return-address  (NOTE: LEAF)
    addi    return_address_less_4, return_address_less_4, 4

    // For RTL simulation purposes, this routine can be built to
    // simply return
#ifndef EPCS_SIMULATION_TEST
    // Wait until controller says "Transmitter empty."
close_ready_loop:
    ldwio   r_eopen_eclose_tmp, EPCS_STATUS_OFFSET (r_epcs_base_address)
    andi    r_eopen_eclose_tmp, r_eopen_eclose_tmp, EPCS_STATUS_TMT_MASK
    beq     r_eopen_eclose_tmp, r_zero, close_ready_loop

    // Deassert CS by clearing the SSO-bit (write zero to entire register):
    stwio   r_zero, EPCS_CONTROL_OFFSET (r_epcs_base_address)
#endif /* EPCS_SIMULATION_TEST */

    // Return
    jmp     return_address_less_4   // Don't worry--we fixed it.

////////
// sub_read_int_from_flash_epcs
//
// Alternate entry point for epcs_rx_tx.
//
//   Zero the epcs_tx_value before falling through to sub_tx_rx_int_epcs.
//
sub_read_int_from_flash_epcs:

    // This reads the NEXT sequential integer from the EPCS device,
    // on the assumption that a valid read-command, with address,
    // has already been sent, and the CS-bit has been left on.
    //
    // Zero the word we're transmitting.
    //
    mov     r_epcs_tx_value, r_zero

    //
    // fall through to the sub_tx_rx_int_epcs routine
    //


////////
// sub_tx_rx_int_epcs
//
//   Subroutine which reads writes four bytes to flash while
//   at the same time reading four bytes.  EPCS does this whether
//   you like it or not.  The four bytes start at a
//   not-necessarily-aligned flash offset.
//
//   Strangly, this routine writes MSB first, and reads LSB first.
//   This is required because the EPCS device itself takes commands
//   (which is the only reason we write to EPCS inside a boot loader)
//   MSB first, but SOFs and code are organized LSB first.
//
//   This routine shares its input argument with the tx_rx_byte
//   routine.  This is only safe as long as the tx_rx_byte routine
//   doesn't trash it's argument.
//
//   Register usage:
//      argument:            r_epcs_tx_value
//      local variable:      r_trie_count
//      local return ptr:    r_riff_return_address
//      return-value:        r_read_int_return_value
//
sub_tx_rx_int_epcs:
    // Fix-up and stash return address
    addi    r_riff_return_address, return_address_less_4, 4

    //
    // write bytes (MSB first) and read them (LSB first)
    //

    // clear the return value
    mov     r_read_int_return_value, r_zero

    // number of bytes to tx/rx
    movi    r_trie_count, 4

trie_loop:
    // position the transmit byte
    roli    r_epcs_tx_value, r_epcs_tx_value, 8

    // tx/rx a byte
    nextpc  return_address_less_4
    br      sub_tx_rx_byte_epcs

    // put it into the LSB of the result
    or      r_read_int_return_value, r_read_int_return_value, r_read_byte_return_value

    // rotate the result so that the latest byte is in the MSB,
    //  moving the other bytes down toward the LSB (no rori)
    roli    r_read_int_return_value, r_read_int_return_value, 24

    // decrement the counter, and loop
    subi    r_trie_count, r_trie_count, 1
    bne     r_trie_count, r_zero, trie_loop

    // Return.
    jmp     r_riff_return_address


////////
// sub_read_byte_from_flash_epcs
//
// Alternate entry point for epcs_rx_tx.
//
//   Zero the epcs_tx_value before falling through to the
//       epcs_tx_rx routine.
//
sub_read_byte_from_flash_epcs:

    // This reads the NEXT sequential byte from the EPCS device,
    // on the assumption that a valid read-command, with address,
    // has already been sent, and the CS-bit has been left on.
    //
    // Just by transmitting another zero to the device, we end up
    // getting-back the next sequential byte.
    //
    mov     r_epcs_tx_value, r_zero

    //
    // fall through to the sub_tx_rx_byte_epcs routine
    //


////////
// sub_tx_rx_byte_epcs
//
// EPCS devices are funny--every time you want to send something, you
// also recieve something.  Every time you want to recieve something,
// you must send something.
//
// This routine transmits its argument, and returns whatever was
// recieved as its result.
//
// Because this is a boot-copier, and there's not a damned thing we could
// do or say if we got an error, the possibility of error-conditions is
// entirely ignored.
//
// Register usage:
//   argument:       r_epcs_tx_value
//   temporary:      rf_temp
//   return-value:   r_read_byte_return_value
//
sub_tx_rx_byte_epcs:
    // Fix-up return-address  (NOTE: LEAF)
    addi    return_address_less_4, return_address_less_4, 4

#ifndef EPCS_SIMULATION_TEST
    // Wait until controller is ready for a TX-char, then send it.
tx_ready_loop:
    ldwio   rf_temp, EPCS_STATUS_OFFSET (r_epcs_base_address)
    andi    rf_temp, rf_temp, EPCS_STATUS_TRDY_MASK
    beq     rf_temp, r_zero, tx_ready_loop

    stwio   r_epcs_tx_value, EPCS_TXDATA_OFFSET (r_epcs_base_address)

    // Wait until an RX-character shows-up, then get it.
rx_ready_loop:
    ldwio   rf_temp, EPCS_STATUS_OFFSET (r_epcs_base_address)
    andi    rf_temp, rf_temp, EPCS_STATUS_RRDY_MASK
    beq     rf_temp, r_zero, rx_ready_loop

    ldbuio  r_read_byte_return_value, EPCS_RXDATA_OFFSET (r_epcs_base_address)
#else /* EPCS_SIMULATION_TEST */
    // For simulation tests, read a byte from the address in r_flash_ptr
    // and increment it to mimic the sequential read nature of an EPCS
    // device. r_flash_ptr in the context of the EPCS bootloader
    // refers to the flash offset within the EPCS device. We'll
    // add this to any flash base specified with the preprocessor.
    // to allow testing with a conventional parallel flash simulation model.
    mov     rf_temp, r_zero
#ifdef EPCS_SIMULATION_TEST_FLASH_BASE
    movhi   rf_temp, %hi(EPCS_SIMULATION_TEST_FLASH_BASE)
    addi    rf_temp, rf_temp, %lo(EPCS_SIMULATION_TEST_FLASH_BASE)
#endif
    add     r_flash_ptr, r_flash_ptr, rf_temp

    // Read byte from the flash image & increment pointer for next time
    ldbuio  r_read_byte_return_value, 0(r_flash_ptr)
    addi    r_flash_ptr, r_flash_ptr, 1
#endif /* EPCS_SIMULATION_TEST */
    // Return
    jmp     return_address_less_4   // Don't worry--we fixed it.

//
// Find_Payload for EPCS:
//
// The process:
//     - Open the EPCS at zero (where device-config lives)
//     - Analyze the config. to get the payload-start-address.
//     - Close the EPCS.
//     - Open the EPCS up again at the payload-address.
//
sub_find_payload_epcs:
    // Fix-up and save return-address
    addi    r_findp_return_address, return_address_less_4, 4

  //
  // Compute the address of the EPCS control/status register block.
  //
  // This is 512 bytes from the very *start* of this program.
  //
  // | dvb adds: Since the code must be aligned on a 512-byte
  // | boundary, we simply take our current address, and round up
  // | to the next 512-byte boundary.
  //
  // | for debugging purposes, you may define EPCS_REGS_BASE
  // | to be the epcs registers base. Otherwise, it is presumed
  // | to be the first 512-byte-boundary after this very code.
  //
    nextpc  r_findp_temp

#ifdef EPCS_REGS_BASE
    movhi   r_epcs_base_address, %hi(EPCS_REGS_BASE)
    ori    r_epcs_base_address, r_epcs_base_address, %lo(EPCS_REGS_BASE)
#else
    ori     r_epcs_base_address, r_findp_temp, 511
    addi    r_epcs_base_address, r_epcs_base_address, 1
#endif

    //
    // Open EPCS-device at flash-offset zero.
    //
    movi    r_flash_ptr, 0
    nextpc  return_address_less_4
    br      sub_epcs_open_address

    //
    // Analyze the device config by sequentially reading bytes out of the
    //  flash until one of three things happen:
    //       1) We find an 0xA6 (well, really 0x56 because we're not reversing
    //           the bits while searching).  When we find it, we've found the
    //           device configuration, and can continue figuring out it's
    //           length
    //       2) We see a byte other than 0xFF, in which case we're not looking
    //           at a device configuration at all.  Instead we assume we must
    //           be looking at a boot loader record.  Skip the whole "length
    //           of the configuration" calculation, and start loading.
    //       3) We don't find anything other than 0xFF's for an arbitrarily
    //           long time.  We then surmise that the flash must be blank, and
    //           having no other recourse, we hang.
    //

    // search an arbitrarily large number of bytes
    movi    r_findp_count, 0x400

    // the pattern we're looking for
    movi    r_findp_pattern, 0x56

    // what we'll accept until we see the pattern
    movi    r_findp_temp, 0xFF

fp_look_for_56_loop:
    nextpc  return_address_less_4
    br      sub_read_byte_from_flash_epcs

    // did we find our pattern?
    beq     r_read_byte_return_value, r_findp_pattern, fp_found_sync

    // did we see something other than an FF?
    bne     r_read_byte_return_value, r_findp_temp, fp_short_circuit

    // update the loop counter, and loop
    subi    r_findp_count, r_findp_count, 1
    bne     r_findp_count, r_zero, fp_look_for_56_loop

    // we didn't find a pattern, or anything else for that matter. Hang.
    br      sub_epcs_hang_forever

fp_found_sync:
    // The magic sync pattern is followed by four bytes we aren't interested
    //  in.  Toss 'em.
    nextpc  return_address_less_4
    br      sub_read_int_from_flash_epcs

    // The next four bytes are the length of the configuration
    // They are in little-endian order, but (perversely), they
    // are each bit-reversed.
    nextpc  return_address_less_4
    br      sub_read_int_from_flash_epcs

    // put length in the flash pointer
    mov     r_flash_ptr, r_read_int_return_value

    // Ok, we've got the length, but in EPCS devices, Quartus stores the
    //   bytes in bit-reversed order.
    //
    //   We're going to reverse the bits by reversing nibbles, then di-bits,
    //   then bits, like this:
    //
    //  76543210 -- nibbles --> 32107654 -- di-bits --> 10325476 -- bits --> 01234567
    //
    //   Here are the machinations the following loop goes through.
    //       You'll notice that the sequence only illustrates one byte.
    //       Never fear, all of the bytes in the word are being reversed
    //       at the same time
    //
    //   ("x" == unknown, "." == zero)
    //
    //                             byte        temp        mask    count
    //                           --------    --------    --------  -----
    //   Initial state           76543210    xxxxxxxx    00001111    4
    //
    // 1 temp = byte & mask      76543210    ....3210    00001111    4
    // 2 temp <<= count          76543210    3210....    00001111    4
    // 3 byte >>= count          xxxx7654    3210....    00001111    4
    // 4 byte &= mask            ....7654    3210....    00001111    4
    // 5 byte |= temp            32107654    3210....    00001111    4
    // 6 count >>= 1             32107654    3210....    00001111    2
    // 7 temp = mask << count    32107654    00111100    00001111    2
    // 8 mask ^= temp            32107654    00111100    00110011    2
    //
    //   loop on (count != 0)
    //
    //   temp = byte & mask      32107654    ..10..54    00110011    2
    //   temp <<= count          32107654    10..54..    00110011    2
    //   byte >>= count          xx321076    10..54..    00110011    2
    //   byte &= mask            ..32..76    10..54..    00110011    2
    //   byte |= temp            10325476    10..54..    00110011    2
    //   count >>= 1             10325476    10..54..    00110011    1
    //   temp = mask << count    10325476    01100110    00110011    1
    //   mask ^= temp            10325476    01100110    01010101    1
    //
    //   loop on (count != 0)
    //
    //   temp = byte & mask      10325476    .0.2.4.6    01010101    1
    //   temp <<= count          10325476    0.2.4.6.    01010101    1
    //   byte >>= count          x1032547    0.2.4.6.    01010101    1
    //   byte &= mask            .1.3.5.7    0.2.4.6.    01010101    1
    //   byte |= temp            01234567    0.2.4.6.    01010101    1
    //   count >>= 1             01234567    0.2.4.6.    01010101    0
    //   temp = mask << count    01234567    01010101    01010101    0
    //   mask ^= temp            01234567    01010101    00000000    0
    //

    // initialize the mask
    movhi   r_revbyte_mask, 0x0F0F
    addi    r_revbyte_mask, r_revbyte_mask, 0x0F0F

    // load the count
    movi    r_findp_count, 4

fp_reverse_loop:
    // mask off half of the bits, and put the result in TEMP
    and     r_findp_temp, r_flash_ptr, r_revbyte_mask       // 1

    // shift the bits in TEMP over to where we want 'em
    sll     r_findp_temp, r_findp_temp, r_findp_count       // 2

    // shift the bits in PTR the other way, so that they
    //   don't collide with those in TEMP
    srl     r_flash_ptr, r_flash_ptr, r_findp_count         // 3

    // mask off the bits in PTR we're going to replace with those from TEMP
    and     r_flash_ptr, r_flash_ptr, r_revbyte_mask        // 4

    // combine the bits in PTR with the bits from TEMP
    or      r_flash_ptr, r_flash_ptr, r_findp_temp          // 5

    // update the shift COUNT
    srli    r_findp_count, r_findp_count, 1                 // 6

    // shift the MASK
    sll     r_findp_temp, r_revbyte_mask, r_findp_count     // 7

    // update the MASK
    xor     r_revbyte_mask, r_revbyte_mask, r_findp_temp    // 8

    // loop if there's more to do
    bne     r_findp_count, r_zero, fp_reverse_loop

    //
    // Finally, it turns out the length was given in BITS.  Round-up
    //  to the next byte, and convert to bytes
    //
    addi    r_flash_ptr, r_flash_ptr, 7      // r_flash_ptr += 7
    srli    r_flash_ptr, r_flash_ptr, 3      // r_flash_ptr /= 8;

fp_short_circuit:
    // Close the EPCS device
    nextpc  return_address_less_4
    br      sub_epcs_close

    // Open it up again (at r_flash_ptr)
    nextpc  return_address_less_4
    br      sub_epcs_open_address

    jmp     r_findp_return_address

// end of file
