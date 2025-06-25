// Copyright (C)2001-2009 Altera Corporation
// Any megafunction design, and related net list (encrypted or decrypted),
// support information, device programming or simulation file, and any other
// associated documentation or information provided by Altera or a partner
// under Altera's Megafunction Partnership Program may be used only to
// program PLD devices (but not masked PLD devices) from Altera.  Any other
// use of such megafunction design, net list, support information, device
// programming or simulation file, or any other related documentation or
// information is prohibited for any other purpose, including, but not
// limited to modification, reverse engineering, de-compiling, or use with
// any other silicon devices, unless such use is explicitly licensed under
// a separate agreement with Altera or a megafunction partner.  Title to
// the intellectual property, including patents, copyrights, trademarks,
// trade secrets, or maskworks, embodied in any such megafunction design,
// net list, support information, device programming or simulation file, or
// any other related documentation or information provided by Altera or a
// megafunction partner, remains with Altera, the megafunction partner, or
// their respective licensors.  No other licenses, including any licenses
// needed under any third party's intellectual property, are provided herein.
// Copying or modifying any file, or portion thereof, to which this notice
// is attached violates this copyright.

module alt_vipcti131_common_functions;

    //This function returns the width in bits required to represent the passed number
    //Max size input 512 bit value
    function integer alt_clogb2;
        input [511:0] value;
        integer i;
        begin
            alt_vipfunc_required_width = 512;
            for (i=512; i>0; i=i-1) begin
                if (2**i>value)
                alt_clogb2 = i;
            end
        end
    endfunction
    
    localparam EVENT_WIDTH = 32
    localparam PID_WIDTH = 32
    localparam PID_BASE = 32
    localparam SRC_WIDTH = 32
    localparam SRC_BASE = 32
    localparam DEST_WIDTH = 32
    localparam DEST_BASE = 32
    localparam EVENTID_WIDTH = 32
    localparam EVENTID_BASE = 32
    localparam DEBUG_WIDTH = 32
    localparam DEBUG_BASE = 32

endmodule
