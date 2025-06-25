// file: boot_loader_cfi_bits.S
// asmsyntax=nios2
//
// Copyright 2003-2004 Altera Corporation, San Jose, California, USA.
// All rights reserved.
//
// written by TPA, moved around by dvb, 2003-2004
// routines for accessing data out of a CFI-compliant
// flash device. This device appears like memory,
// so to get bytes you do memory accesses.
//
// Who would have thought?
//
// optimized by kds 2004.
//


#include "boot_loader.h"

    .global sub_find_payload_cfi
    .global sub_read_int_from_flash_cfi
    .global sub_streaming_copy_cfi

////////
// Read_Int_From_Flash_CFI
//
//   Pseudo-subroutine which reads four bytes from flash and concatenates
//   them into an integer.  The four bytes start at a
//   not-necessarily-aligned flash offset.
//
//   Register usage:
//      local variable:      r_riff_count
//      local return ptr:    r_riff_return_address
//      return-value:        r_read_int_return_value
//
sub_read_int_from_flash_cfi:
    // Fix-up and stash return address
    addi    r_riff_return_address, return_address_less_4, 4

    //
    // read the bytes (LBA first) and or/shift them into the result
    //

    // clear the return value
    mov     r_read_int_return_value, r_zero

    // number of bytes to retrieve.
    movi    r_riff_count, 4

riffc_loop:
    // retrieve a byte and bump the flash pointer
    ldbuio  r_read_byte_return_value, 0(r_flash_ptr)
    addi    r_flash_ptr, r_flash_ptr, 1

    // OR it into the LSB of the result
    or      r_read_int_return_value, r_read_int_return_value, r_read_byte_return_value

    // rotate the result so that the latest byte is in the MSB,
    //  moving the other bytes down toward the LSB (no rori)
    roli    r_read_int_return_value, r_read_int_return_value, 24

    // decrement the counter, and loop
    subi    r_riff_count, r_riff_count, 1
    bne     r_riff_count, r_zero, riffc_loop

    // Return.
    jmp     r_riff_return_address


////////
// Streaming copy
//
//   Copies r_data_size bytes from r_flash_ptr to r_dest
//
//   Register usage:
//       argument:   r_data_size - number of bytes to copy
//       argument:   r_dest      - destination of the copy
//       implied:    r_flash_ptr - source address for the copy
//       temporary:  rf_temp
//       return-value : none
//
//   All args are smashed by this routine
//
sub_streaming_copy_cfi:
    // Fix-up return-address  (NOTE: LEAF)
    addi    return_address_less_4, return_address_less_4, 4

    // for legibility
    #define r_dest_end_plus_one r_data_size

    // convert the length to the ending address + 1
    //   same number of instructions, but one less in the loop
    add     r_dest_end_plus_one, r_data_size, r_dest

    //
    // do {
    //   *r_dest++ = (char*)r_flash_ptr++)
    // while (r_dest != r_dest_end_plus_one);
    //
cfi_copy_loop:
    ldbuio  rf_temp, 0(r_flash_ptr)
    addi    r_flash_ptr, r_flash_ptr, 1
    stbio   rf_temp, 0(r_dest)
    addi    r_dest, r_dest, 1

    // loop until the destination == 1 + the ending address
    bne     r_dest, r_dest_end_plus_one, cfi_copy_loop

    // Return
    jmp     return_address_less_4   // Don't worry--we fixed it.


////////
// Find_Payload
//
//   returns the flash-offset of the first byte of the payload in
//   r_flash_ptr.  Takes no arguments.
//
// CFI:
//    The payload is just the next address after the end of this very
//    boot-copier program.  Use some nextpc position-independent
//    trickery to find it.

sub_find_payload_cfi:

    // Fix-up and save return-address
    addi    r_findp_return_address, return_address_less_4, 4

    nextpc  r_flash_ptr
payload_offset_base:

    // |
    // | One might suspect the code below to be
    // | off by four or something. It could happen easily.
    // | But I've confirmed that it's right.
    // | dvb 2004.
    // |

    addi    r_flash_ptr, r_flash_ptr, (end_of_boot_copier - payload_offset_base)

    // Payload found! r_flash_ptr now contains the first address of the payload.

    jmp     r_findp_return_address

// |
// | For a flash-based boot sequence, we put this very code
// | at the reset address, and the data to be copied right
// | after it. How do we know where the data is? Well, I
// | just said, it's right after it. This is right after it.
// |
// | Mind the link order, boys.
// |

end_of_boot_copier:

// | Data goes here.

    .end


// end of file
