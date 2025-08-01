// file: boot_loader_epcq256_bits_cv.S
// asmsyntax=nios2
//
// Copyright 2009 Altera Corporation, San Jose, California, USA.
// All rights reserved.
//
// Refactored by jrk, 2006.01.26
// - Cyclone III/Stratix II GX added 2007.08.15
//
// - FPGA device-family-specific code moved to separate sources.
//
// - This file contains EPCS boot routines specific to the Stratix II, II GX,
//   III, IV, IV GX, Arria GX, Arria II GX, and x II, and Cyclone III device
//   families only; support for other device families is provided in separate
//   sources, so that separate (and thus small) boot loader executables will
//   be built.
//
// Refactored by dyum, 2008.03.06
// Adding Stratix III support
//
// Updated by dyum, 2008.03.25
// Adding ArriaGX support
//
// Updated by jkempa 2009.08.14:
// Adding Stratix IV & Arria II GX support
//
// Updated by jkempa 2012.06.15:
// Refactoring new support for EPCQ 256 devices. The changes
// make the boot loader too big for Cyclone/Cyclone II. They won't
// support the new chip Johnny, sorry about that.
//
// Updated by Chin Liang 2013.01.08
// Added Cyclone V EPCQ256 support
// For EPCQ128 and EPCS, need to create a new one. This version served as
// temporary solution while pending for unite version which applicable for
// all device family and EPCS/EPCQ flashes with various size 128/256
//

#include "boot_loader.h"

    .global sub_epcs_open_address
    .global sub_epcs_close
    .global sub_epcs_config
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
//       argument:          r_flash_ptr
//       temporary:         r_eopen_eclose_tmp
//       local return ptr:  r_open_close_return_address
//       return-value:      --none--
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

    // backup return address
    mov     r_open_close_return_address, return_address_less_4

    // Check for Device ID and enable 4-byte address mode if its density is
    // greater than 256M bits.
    nextpc  return_address_less_4
    br      sub_epcs_config

    movi    r_eopen_eclose_tmp, EPCS_CONTROL_SSO_MASK
    stwio   r_eopen_eclose_tmp, EPCS_CONTROL_OFFSET (r_epcs_base_address)

    beq     r_epcs_4_bytes_mode, r_zero, three_bytes_mode
    /* It is in 4-byte mode.
     * Transmit the READ command first then send the flash address pointer later.
     */
    movi    r_epcs_tx_value, EPCS_COMMAND_READ

    nextpc  return_address_less_4
    br      sub_tx_rx_byte_epcs

    // r_epcs_tx_value contains 4-bytes address
    mov     r_epcs_tx_value, r_flash_ptr

    br      start_tx

three_bytes_mode:
    /*
     * r_epcs_tx_value[31:24]: EPCS_COMMAND_READ
     * r_epcs_tx_value[23:0] : 3-byte address
     */

    // get the read command into our the transmit byte
    movhi   r_epcs_tx_value, (EPCS_COMMAND_READ << 8)

    // put the flash pointer into the lower 24 bits
    or      r_epcs_tx_value, r_epcs_tx_value, r_flash_ptr

start_tx:
    // restore return address
    mov     return_address_less_4, r_open_close_return_address

    // functionally fall through to the tx_rx_int routine.
    br      sub_tx_rx_int_epcs

    // The EPCS flash is now open at r_flash_ptr.


////////
// EPCS_Close
//
// Terminate current EPCS transaction.
//
//       local return ptr:  r_open_close_return_address
//                          (shared with sub_epcs_open_address)
//
sub_epcs_close:
    // Fix-up and stash return address
    addi    r_open_close_return_address, return_address_less_4, 4

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

    // If we entered "4-byte" address mode, exit it. Other IP may expect
    // the EPCS device to be in conventioanl 3-byte address mode. We're so
    // nice here in the SCTC, thinking of these things for you.
    beq     r_epcs_4_bytes_mode, r_zero, close_3_bytes_mode

    // Enable device CS via control-register bit.
    movi    r_eopen_eclose_tmp, EPCS_CONTROL_SSO_MASK
    stwio   r_eopen_eclose_tmp, EPCS_CONTROL_OFFSET (r_epcs_base_address)

    movi    r_epcs_tx_value, EPCS_COMMAND_WREN
    nextpc  return_address_less_4
    br      sub_tx_rx_byte_epcs

    //disable CS
    stwio   r_zero, EPCS_CONTROL_OFFSET (r_epcs_base_address)

    // Enable device CS via control-register bit.
    movi    r_eopen_eclose_tmp, EPCS_CONTROL_SSO_MASK
    stwio   r_eopen_eclose_tmp, EPCS_CONTROL_OFFSET (r_epcs_base_address)

    movi    r_epcs_tx_value, EPCS_COMMAND_EX4B
    nextpc  return_address_less_4
    br      sub_tx_rx_byte_epcs

    //disable CS
    stwio   r_zero, EPCS_CONTROL_OFFSET (r_epcs_base_address)

close_3_bytes_mode:
#endif /* EPCS_SIMULATION_TEST */

    // Return
    jmp     r_open_close_return_address   // Don't worry--we fixed it.

/////////
// Check the EPCS device ID and enable the 4-byte address mode if
// it is device with density greater than 256Mbit.
//
//   Register usage:
//       local return ptr:      r_riff_return_address (shared with sub_tx_rx_int_epcs!)
//       return-value:          r_epcs_4_bytes_mode
//
sub_epcs_config:
    // Fix-up and stash return address
    addi    r_riff_return_address, return_address_less_4, 4

    // Clear to 0
    mov    r_epcs_4_bytes_mode, r_zero

    // Enable device CS via control-register bit.
    movi    r_eopen_eclose_tmp, EPCS_CONTROL_SSO_MASK
    stwio   r_eopen_eclose_tmp, EPCS_CONTROL_OFFSET (r_epcs_base_address)

    // Read the device ID from hardware
    movi    r_epcs_tx_value, EPCS_COMMAND_RDID
    nextpc  return_address_less_4
    br      sub_tx_rx_byte_epcs

   // read 3-bytes response
   mov     r_epcs_tx_value, r_zero
   nextpc  return_address_less_4
   br      sub_tx_rx_byte_epcs          // read byte 0

   /* ChinLiang: check whether is Spansion flash or not */
   mov     r_epcs_spansion_flash, r_zero	/* clear to zero before check */
   movi    r_epcs_tx_value, EPCS_SPANSION_ID1
   cmpne   r_epcs_tx_value, r_read_byte_return_value, r_epcs_tx_value
   beq     r_epcs_tx_value, r_zero, spansion_flash

   /* ChinLiang: check the 2nd ID as Spansion have 2 ID */
   movi    r_epcs_tx_value, EPCS_SPANSION_ID2
   cmpeq   r_epcs_tx_value, r_read_byte_return_value, r_epcs_tx_value
   beq     r_epcs_tx_value, r_zero, not_spansion_flash

spansion_flash:
   /* ChinLiang: initialize back to r_zero */
   mov     r_epcs_tx_value, r_zero
   movi    r_epcs_spansion_flash, 1	/* ChinLiang: set Spansion flash */

not_spansion_flash:

   nextpc  return_address_less_4
   br      sub_tx_rx_byte_epcs          // read byte 1

   nextpc  return_address_less_4
   br      sub_tx_rx_byte_epcs          // read byte 2 (density)

    //disable CS
   stwio   r_zero, EPCS_CONTROL_OFFSET (r_epcs_base_address)

   // Check the device density ID
   cmpgeui r_read_byte_return_value, r_read_byte_return_value, EPCS_256
   beq     r_read_byte_return_value, r_zero, go_return

enable_four_bytes:

    /* Device more than 256Mbit, enable 4-bytes address mode. */
    movi    r_epcs_4_bytes_mode, 1   /* Set 4-byte mode*/

    /* ChinLiang: check whether its Spansion flash or not */
    bne     r_epcs_spansion_flash, r_zero, enable_four_bytes_spansion

    // Enable device CS via control-register bit.
    movi    r_eopen_eclose_tmp, EPCS_CONTROL_SSO_MASK
    stwio   r_eopen_eclose_tmp, EPCS_CONTROL_OFFSET (r_epcs_base_address)

    movi    r_epcs_tx_value, EPCS_COMMAND_WREN
    nextpc  return_address_less_4
    br      sub_tx_rx_byte_epcs

    //disable CS
    stwio   r_zero, EPCS_CONTROL_OFFSET (r_epcs_base_address)

    // Enable device CS via control-register bit.
    movi    r_eopen_eclose_tmp, EPCS_CONTROL_SSO_MASK
    stwio   r_eopen_eclose_tmp, EPCS_CONTROL_OFFSET (r_epcs_base_address)

    movi    r_epcs_tx_value, EPCS_COMMAND_EN4B
    nextpc  return_address_less_4
    br      sub_tx_rx_byte_epcs

    //disable CS
    stwio   r_zero, EPCS_CONTROL_OFFSET (r_epcs_base_address)
    br      go_return

enable_four_bytes_spansion:

    // Enable device CS via control-register bit.
    movi    r_eopen_eclose_tmp, EPCS_CONTROL_SSO_MASK
    stwio   r_eopen_eclose_tmp, EPCS_CONTROL_OFFSET (r_epcs_base_address)

    //ChinLiang: using Bank Register Write command
    movi    r_epcs_tx_value, EPCS_COMMAND_BRWR
    nextpc  return_address_less_4
    br      sub_tx_rx_byte_epcs

    //ChinLiang: with value where set EXTADD bit to 1
    movi    r_epcs_tx_value, EPCS_SPANSION_EXTADD
    nextpc  return_address_less_4
    br      sub_tx_rx_byte_epcs

    //disable CS
    stwio   r_zero, EPCS_CONTROL_OFFSET (r_epcs_base_address)

go_return:
    jmp     r_riff_return_address

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

// |
// | Find_Payload for EPCS (Arria GX/Stratix II/Stratix III/Cyclone III
// | edition):
// |
// | The process:
// |  1) Open the EPCS at zero (where device-config lives)
// |
// |  2) We see a byte other than 0xFF, prior to where non-0xFF FPGA
// |     configuration data is expected (byte[32]), in which case we're
// |     not looking at a device configuration. Instead we assume we must
// |     be looking at a boot loader record. Skip the whole "length
// |     of the configuration" calculation, and start loading.
// |
// |  3) If a boot loader record isn't found, we assume* that we're examining
// |     an FPGA bitstream targeting a Stratix II/III/IV/IV GX, Arria GX,
// |     Arria II GX, or Cyclone III device. Extract the precise FPGA
// |     configuration length. Close/re-open the EPCS device after the
// |     FPGA configuration before returning to load software.
// |
// |     * One exception is if the extracted length is all "1" -- in this
// |       case we can safely assume that we're reading erased flash, and not
// |       FPGA bitstream. Instead of jumping to a high address, the boot
// |       loader will hang.
// |
// | A note about nomenclature in this code's documentation: data[N] refers to
// | Nth unit of data, assuming that you start counting at zero.
// |

sub_find_payload_epcs:
    // Fix-up and save return-address
    addi    r_findp_return_address, return_address_less_4, 4

  //
  // Compute the address of the EPCS control/status register block.
  //
  // This is 1024 bytes from the very *start* of this program, for this
  // edition of the boot loader. On Cyclone I/II its 512 bytes.
  //
  // | dvb adds: Since the code must be aligned on a 1024-byte
  // | boundary, we simply take our current address, and round up
  // | to the next 1024-byte boundary.
  //
  // | for debugging purposes, you may define EPCS_REGS_BASE
  // | to be the epcs registers base. Otherwise, it is presumed
  // | to be the first 1024-byte-boundary after this very code/
  //
    nextpc  r_findp_temp

#ifdef EPCS_REGS_BASE
    movhi   r_epcs_base_address, %hi(EPCS_REGS_BASE)
    ori    r_epcs_base_address, r_epcs_base_address, %lo(EPCS_REGS_BASE)
#else
    ori     r_epcs_base_address, r_findp_temp, 1023
    addi    r_epcs_base_address, r_epcs_base_address, 1
#endif

    //
    // 1) Open EPCS-device at flash-offset zero.
    //
    movi    r_flash_ptr, 0
    nextpc  return_address_less_4
    br      sub_epcs_open_address

    //
    // 2) Attempt to find software boot record
    //

    // Search until we expect configuration data to start
    movi    r_findp_count, 32

    // What we'll accept until we see the pattern
    subi    r_findp_temp, r_zero, 1	//ChinLiang

fp_look_for_software_boot_record:
    nextpc  return_address_less_4
    br      sub_read_int_from_flash_epcs	//ChinLiang

    // Did we see something other than an 0xFFFFFFFF?
    bne     r_read_int_return_value, r_findp_temp, fp_short_circuit

    // Update the loop counter, and loop
    subi    r_findp_count, r_findp_count, 1
    bne     r_findp_count, r_zero, fp_look_for_software_boot_record

    //
    // 3) If we arrive at this point we have assume that there is valid-looking
    // configuration data. Extract its length. If the extracted length is all
    // "1", assume that we're looking at erased flash. In this case, we have
    // no other recourse than to hang.
    //
    // The configuration bitstream length is encoded in a particular bit of a
    // run of words. Total length field is 32 bits, which goes from CB Option
    // bits 86..55 corresponding to bit[4] of words[39] to words[33] (for the most
    // significant 7 bits) followed by the range of bits made up of bit[5] of
    // words[72..48].
    //
    // The note about EPCS bit reversal still applies (so we're really looking
    // at bits[4] and [5], respectively.
    //

    // First, loop through bits in words [48..72] - LSB of the length first
    // Number of words we'll traverse to get the length
    movi    r_findp_count, 25

    // Clear the register we'll construct the length into
    movi    r_findp_temp, 0

    // Close & re-open EPCS where we will start extracting the length
    movi    r_flash_ptr, 48
    // x4 for word location instead byte location (use shift as no multiplier)
    slli    r_flash_ptr, r_flash_ptr, 2		//ChinLiang

    nextpc  return_address_less_4
    br      sub_epcs_close
    nextpc  return_address_less_4
    br      sub_epcs_open_address

fp_assemble_configuration_length:
    // Read sequential byte from EPCS
    nextpc  return_address_less_4
    br      sub_read_int_from_flash_epcs	//ChinLiang

    // Mask off all but bit[5] as described above
    andi    r_read_int_return_value, r_read_int_return_value, 0x20

    // Shift to the MSB position of the value we're constructing
    // (which happens to be 26 bits left of the bit we're working with)
    // (the data we're after is being read LSB first)... this may
    // seem backwards (it is), but the sub_read_byte_from_flash_epcs
    // routine auto increments the EPCS addres for us; thus the cleanest
    // implementation is to load data from sequential addresses, LSB first.
    slli    r_read_int_return_value, r_read_int_return_value, 26

    // Shift result register & capture new data into bit[31]
    srli    r_findp_temp, r_findp_temp, 0x1
    or      r_findp_temp, r_findp_temp, r_read_int_return_value

    // Update loop counter & loop
    subi    r_findp_count, r_findp_count, 1
    bne     r_findp_count, r_zero, fp_assemble_configuration_length

    // We've assembled 25 bits of the length; 7 to go.
    // We're gonna look at bit[4] of byte[33..39].

    // Number of words we'll traverse to get the length
    movi    r_findp_count, 7

    // Close & re-open EPCS at byte 33
    movi    r_flash_ptr, 33
    // x4 for word location instead byte location (use shift as no multiplier)
    slli    r_flash_ptr, r_flash_ptr, 2		//ChinLiang

    nextpc  return_address_less_4
    br      sub_epcs_close
    nextpc  return_address_less_4
    br      sub_epcs_open_address

fp_assemble_configuration_length_top_bits:
    // Read sequential words from EPCS
    nextpc  return_address_less_4
    br      sub_read_int_from_flash_epcs	//ChinLiang

    // Mask off all but bit[4] as described above
    andi    r_read_int_return_value, r_read_int_return_value, 0x10

    // Shift to the MSB position of the value we're constructing as before
    slli    r_read_int_return_value, r_read_int_return_value, 27

    // Shift result register & capture new data into bit[31]
    srli    r_findp_temp, r_findp_temp, 0x1
    or      r_findp_temp, r_findp_temp, r_read_int_return_value

    // Update loop counter & loop
    subi    r_findp_count, r_findp_count, 1
    bne     r_findp_count, r_zero, fp_assemble_configuration_length_top_bits

    // Put extracted length in the flash pointer
    mov     r_flash_ptr, r_findp_temp

    // Sanity check: Did we extract a length that appears to be erased
    // flash?
    subi     r_findp_temp, r_zero, 1
    beq      r_flash_ptr, r_findp_temp, sub_epcs_hang_forever

    // ChinLiang: The length obtained in previous steps are referring to option
    // bit which specify the POF length. From here, we need to do some
    // calculation to get the num_of_pof_bytes based on the formula documented
    // in Stratix V family NPP. It always assume that user will use compressed
    // POF as plain uncompressed POF will not able to fit into EPCS/EPCQ flash.
    // r_flash_ptr += 300*8 + 30 + 32*13
    addi    r_flash_ptr, r_flash_ptr, 2846

    //
    // Finally, it turns out the length was given in BITS.  Convert to bytes
    //
    addi    r_flash_ptr, r_flash_ptr, 7      // r_flash_ptr += 7
    srli    r_flash_ptr, r_flash_ptr, 3      // r_flash_ptr /= 8;

    // ChinLiang: Oops, not yet. As programmer team did additional stuff to
    // final data. We need to add additional length due to this.
    movhi   r_findp_temp, %hi(76500)
    ori	    r_findp_temp, r_findp_temp, %lo(76500)
    add     r_flash_ptr, r_flash_ptr, r_findp_temp	// r_flash_ptr += 76500

    // ChinLiang: A detection scheme as the algorithm above always use + 7.
    // In certain case, we need to add +9 as advised by prorgammer team. Due to
    // that, we will detect the next byte whether is 0xFF. If yes, we
    // will + 1 to the length.
    nextpc  return_address_less_4
    br      sub_epcs_close
    nextpc  return_address_less_4
    br      sub_epcs_open_address

    // Read sequential words from EPCS
    nextpc  return_address_less_4
    br      sub_read_byte_from_flash_epcs

    // Is next byte also 0xFF? If yes, +1 for the length
    movi    r_findp_temp, 0xFF
    bne     r_read_byte_return_value, r_findp_temp, fp_short_circuit
    addi    r_flash_ptr, r_flash_ptr, 1      // r_flash_ptr += 1

fp_short_circuit:

// Close the EPCS device
    nextpc  return_address_less_4
    br      sub_epcs_close

    // Open it up again (at r_flash_ptr)
    nextpc  return_address_less_4
    br      sub_epcs_open_address

    // Return; EPCS is now ready for boot-loading business
    jmp     r_findp_return_address

// end of file
